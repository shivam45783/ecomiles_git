import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:EcoMiles/components/loadingOverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

// import 'package:google_place/google_place.dart';

class MapProvider extends ChangeNotifier {
  final Location _locationController = Location();
  GoogleMapController? _mapController;
  final _places = places.FlutterGooglePlacesSdk(
    dotenv.env['GOOGLE_MAPS_API_KEY']!,
  );
  static const LatLng _pIndia = LatLng(20.5937, 78.9629);
  LatLng? _currentP = null;
  final LatLng _pointA = LatLng(18.5204, 73.8567);
  // LatLng? _destinationP = LatLng(15.400399, 74.005508);
  LatLng? _destinationP = null;
  MapType mapType = MapType.normal;
  List _predictionsResponse = [];
  bool _showCancelRoute = false;
  List get predictionsResponse => _predictionsResponse;
  LatLng? get currentLocation => _currentP;
  LatLng? get destinationLocation => _destinationP;
  LatLng get getIndia => _pIndia;
  GoogleMapController? get mapController => _mapController;
  Location get locationController => _locationController;
  TextEditingController? _searchController = TextEditingController();
  LatLng get pointA => _pointA;
  LatLng get pointB => _destinationP!;
  bool get showCancelRoute => _showCancelRoute;

  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> _markers = {};
  StreamSubscription<LocationData>? get locationSubscription =>
      _locationSubscription;
  TextEditingController? get searchController => _searchController;
  Set<Marker> get markers => _markers;
  int _markerIdCounter = 1;
  Marker? sourcePosition, destinationPosition;
  set controller(GoogleMapController controller) => _mapController = controller;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  StreamSubscription<LocationData>? _locationSubscription;
  notifyListeners();

  // Future<void> getCurrentLocation() async {
  //   // Step 1: Ensure location service is enabled
  //   final serviceEnabled =
  //       await _locationController.serviceEnabled() ||
  //       await _locationController.requestService();
  //   if (!serviceEnabled) return;

  //   // Get one-time location
  //   // LocationData locationData = await _locationController.getLocation();

  //   // if (locationData.latitude != null && locationData.longitude != null) {
  //   //   final newPosition = LatLng(
  //   //     locationData.latitude!,
  //   //     locationData.longitude!,
  //   //   );

  //   //   // Compare with previous location
  //   //   const threshold = 0.0001; // ~11 meters
  //   //   final hasMoved =
  //   //       _currentP == null ||
  //   //       (newPosition.latitude - _currentP!.latitude).abs() > threshold ||
  //   //       (newPosition.longitude - _currentP!.longitude).abs() > threshold;

  //   //   if (hasMoved) {
  //   //     _currentP = newPosition;
  //   //     notifyListeners();
  //   //   }

  //   //   if (_mapController != null) {
  //   //     _mapController!.animateCamera(
  //   //       CameraUpdate.newCameraPosition(
  //   //         CameraPosition(target: _currentP!, zoom: 16.0),
  //   //       ),
  //   //     );
  //   //   }
  //   // }

  //   // Step 2: Ensure permission is granted
  //   PermissionStatus permissionGranted = await _locationController
  //       .hasPermission();
  //   if (permissionGranted == PermissionStatus.denied) {
  //     permissionGranted = await _locationController.requestPermission();
  //     if (permissionGranted != PermissionStatus.granted) return;
  //   }

  //   // Step 3: Listen for first location update, then cancel
  //   _locationSubscription = _locationController.onLocationChanged.listen(
  //     (locationData) {
  //       if (locationData.latitude == null || locationData.longitude == null)
  //         return;

  //       _currentP = LatLng(locationData.latitude!, locationData.longitude!);
  //       notifyListeners();

  //       if (_mapController != null) {
  //         _mapController!.animateCamera(
  //           CameraUpdate.newCameraPosition(
  //             CameraPosition(
  //               target: _currentP!,
  //               zoom: 16.0,
  //               // Optional:
  //               // tilt: 45,
  //               // bearing: 0,
  //             ),
  //           ),
  //         );
  //       }

  //       // Cancel after first update
  //       _locationSubscription?.cancel();
  //       _locationSubscription = null;
  //     },
  //     onError: (e) {
  //       print("Location error: $e");
  //       _locationSubscription?.cancel();
  //       _locationSubscription = null;
  //     },
  //   );
  // }
  void addCurrentLocationMarker() {
    if (_currentP != null) {
      _markers.add(
        Marker(
          markerId: MarkerId("current_location"),
          position: _currentP!,
          infoWindow: InfoWindow(title: "Current Location"),
        ),
      );
      notifyListeners(); // if using Provider or ChangeNotifier
    }
  }

  void _addMarker(LatLng position) {
    final markerId = MarkerId('marker_$_markerIdCounter');
    _markerIdCounter++;

    final Marker marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: 'Marker $_markerIdCounter'),
    );

    _markers.add(marker);
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    // Step 1: Ensure location service is enabled
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    // Step 2: Ensure permission is granted
    PermissionStatus permissionGranted = await _locationController
        .hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Step 3: Get one-time current location
    final locationData = await _locationController.getLocation();
    if (locationData.latitude == null || locationData.longitude == null) return;

    final newPosition = LatLng(locationData.latitude!, locationData.longitude!);

    // Step 4: Check if user has moved significantly
    const double threshold = 0.0001; // ~11 meters
    final hasMoved =
        _currentP == null ||
        (newPosition.latitude - _currentP!.latitude).abs() > threshold ||
        (newPosition.longitude - _currentP!.longitude).abs() > threshold;

    if (hasMoved) {
      _currentP = newPosition;

      // addCurrentLocationMarker();

      notifyListeners();
    }

    // Step 5: Animate camera if controller exists
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentP!, zoom: 16.0),
        ),
      );
    }
  }

  void setMapStyles(MapType type) {
    if (type == MapType.normal) {
      mapType = MapType.normal;
    } else if (type == MapType.satellite) {
      mapType = MapType.satellite;
    } else if (type == MapType.terrain) {
      mapType = MapType.terrain;
    }
    notifyListeners();
  }

  void setMapStyle(String style) {
    _mapController?.setMapStyle(style);
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _locationController
        .hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        final newPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        _currentP = newPosition;
        // addCurrentLocationMarker();

        notifyListeners();

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: newPosition, zoom: 16.0),
            ),
          );
        }
      }
    });
  }

  // addMarker() {
  //   //  sourcePosition = Marker(
  //   //     markerId: MarkerId('source'),
  //   //     position: _currentP!,
  //   //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
  //   //   );

  //   destinationPosition = Marker(
  //     markerId: MarkerId('destination'),
  //     position: LatLng(_destinationP!.latitude, _destinationP!.longitude),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
  //   );
  //   notifyListeners();
  // }

  // Future<void> getDirections() async {
  //   bool serviceEnabled = await _locationController.serviceEnabled();
  //   if (!serviceEnabled) {
  //     serviceEnabled = await _locationController.requestService();
  //     if (!serviceEnabled) return;
  //   }

  //   PermissionStatus permissionGranted = await _locationController
  //       .hasPermission();
  //   if (permissionGranted == PermissionStatus.denied) {
  //     permissionGranted = await _locationController.requestPermission();
  //     if (permissionGranted != PermissionStatus.granted) return;
  //   }
  //   if (permissionGranted == PermissionStatus.granted) {
  //     await getCurrentLocation();
  //     _locationSubscription = _locationController.onLocationChanged.listen((
  //       LocationData currentLocation,
  //     ) async {
  //       if (_mapController != null) {
  //         _mapController!.animateCamera(
  //           CameraUpdate.newCameraPosition(
  //             CameraPosition(target: _currentP!, zoom: 16.0),
  //           ),
  //         );

  //       }
  //     });
  //   }
  // }
  Future<void> selectPlace(String placeName) async {
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/findplacefromtext/json'
      '?input=${Uri.encodeComponent(placeName)}'
      '&inputtype=textquery'
      '&fields=geometry'
      '&key=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == "OK") {
        print(data);
        final location = LatLng(
          data['candidates'][0]['geometry']['location']['lat'],
          data['candidates'][0]['geometry']['location']['lng'],
        );
        _destinationP = location;

        // addMarker();
        await getDirectionsToPlot(_destinationP!);
        notifyListeners();
      }
    }
  }

  Future<void> getDirections(LatLng dst) async {
    // Step 1: Make sure location is available
    try {
      // if (_currentP == null) await getCurrentLocation();
      if (_currentP == null || _destinationP == null) return;

      final origin = _currentP!;
      final destination = dst;

      final polylinePoints = PolylinePoints(
        apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
      );

      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),

          // arrivalTime: DateTime.now().millisecondsSinceEpoch,
          mode: TravelMode.driving,
        ),
      );
      // print("HI");
      if (result.points.isNotEmpty) {
        final List<LatLng> polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
        // List<LatLng> polylineCoordinates = [
        //   LatLng(28.4556545, 77.0453846),
        //   LatLng(28.457069, 77.0467425),
        //   LatLng(28.4588032, 77.0480546),
        //   LatLng(28.4601935, 77.0493957),
        //   LatLng(28.4613966, 77.0505517),
        //   LatLng(28.4621721, 77.0512426),
        //   LatLng(28.4624519, 77.0515201),
        //   LatLng(28.4652525, 77.0542935),
        //   LatLng(28.466951, 77.0556489),
        //   LatLng(28.4678528, 77.0562961),
        //   LatLng(28.4688056, 77.0572826),
        //   LatLng(28.4679847, 77.0570698),
        //   LatLng(28.4651349, 77.0549357),
        //   LatLng(28.461291, 77.0512648),
        //   LatLng(28.4605629, 77.0505601),
        //   LatLng(28.4603835, 77.0503867),
        //   LatLng(28.4602685, 77.0502706),
        //   LatLng(28.4596605, 77.0501843),
        //   LatLng(28.4574251, 77.0526913),
        //   LatLng(28.4570758, 77.0532523),
        //   LatLng(28.4558367, 77.0559917),
        //   LatLng(28.4553479, 77.0566226),
        //   LatLng(28.4553251, 77.056652),
        //   LatLng(28.4543087, 77.0580256),
        //   LatLng(28.4522801, 77.0607981),
        //   LatLng(28.4502381, 77.063531),
        //   LatLng(28.450273, 77.0641939),
        //   LatLng(28.4524901, 77.0663441),
        //   LatLng(28.4525408, 77.0663916),
        //   LatLng(28.4524511, 77.0665035),
        //   LatLng(28.4521467, 77.0668909),
        //   LatLng(28.4517572, 77.0674019),
        //   LatLng(28.4502022, 77.0694702),
        //   LatLng(28.4501646, 77.0694334),
        //   LatLng(28.4520059, 77.0669857),
        //   LatLng(28.4520165, 77.0666582),
        //   LatLng(28.4520233, 77.0665073),
        //   LatLng(28.4516402, 77.0661221),
        // ];

        PolylineId id = PolylineId("route");
        Polyline polyline = Polyline(
          polylineId: id,
          color: Colors.blue,
          width: 5,
          points: polylineCoordinates,
        );

        polylines[id] = polyline;

        // Add markers
        // print("polylines, $polylineCoordinates");
        // addMarker();
        _markers.add(
          destinationPosition = Marker(
            markerId: MarkerId('destination'),
            position: LatLng(_destinationP!.latitude, _destinationP!.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        );
        // _mapController!.animateCamera(
        //   CameraUpdate.newCameraPosition(
        //     CameraPosition(
        //       target: LatLng(
        //         (_destinationP!.latitude + _currentP!.latitude) / 2,
        //         (_destinationP!.longitude + _currentP!.longitude) / 2,
        //       ),
        //       zoom: 15,
        //     ),
        //   ),
        // );
        notifyListeners();
      } else {
        print("No route found: ${result.errorMessage}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getDirectionsToPlot(LatLng dst) async {
    // Step 1: Make sure location is available
    try {
      // if (_currentP == null) await getCurrentLocation();
      if (_currentP == null || _destinationP == null) return;

      final origin = _currentP!;
      final destination = dst;

      final polylinePoints = PolylinePoints(
        apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
      );

      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),

          // arrivalTime: DateTime.now().millisecondsSinceEpoch,
          mode: TravelMode.driving,
        ),
      );
      // print("HI");
      if (result.points.isNotEmpty) {
        final List<LatLng> polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
        // List<LatLng> polylineCoordinates = [
        //   LatLng(28.4556545, 77.0453846),
        //   LatLng(28.457069, 77.0467425),
        //   LatLng(28.4588032, 77.0480546),
        //   LatLng(28.4601935, 77.0493957),
        //   LatLng(28.4613966, 77.0505517),
        //   LatLng(28.4621721, 77.0512426),
        //   LatLng(28.4624519, 77.0515201),
        //   LatLng(28.4652525, 77.0542935),
        //   LatLng(28.466951, 77.0556489),
        //   LatLng(28.4678528, 77.0562961),
        //   LatLng(28.4688056, 77.0572826),
        //   LatLng(28.4679847, 77.0570698),
        //   LatLng(28.4651349, 77.0549357),
        //   LatLng(28.461291, 77.0512648),
        //   LatLng(28.4605629, 77.0505601),
        //   LatLng(28.4603835, 77.0503867),
        //   LatLng(28.4602685, 77.0502706),
        //   LatLng(28.4596605, 77.0501843),
        //   LatLng(28.4574251, 77.0526913),
        //   LatLng(28.4570758, 77.0532523),
        //   LatLng(28.4558367, 77.0559917),
        //   LatLng(28.4553479, 77.0566226),
        //   LatLng(28.4553251, 77.056652),
        //   LatLng(28.4543087, 77.0580256),
        //   LatLng(28.4522801, 77.0607981),
        //   LatLng(28.4502381, 77.063531),
        //   LatLng(28.450273, 77.0641939),
        //   LatLng(28.4524901, 77.0663441),
        //   LatLng(28.4525408, 77.0663916),
        //   LatLng(28.4524511, 77.0665035),
        //   LatLng(28.4521467, 77.0668909),
        //   LatLng(28.4517572, 77.0674019),
        //   LatLng(28.4502022, 77.0694702),
        //   LatLng(28.4501646, 77.0694334),
        //   LatLng(28.4520059, 77.0669857),
        //   LatLng(28.4520165, 77.0666582),
        //   LatLng(28.4520233, 77.0665073),
        //   LatLng(28.4516402, 77.0661221),
        // ];

        PolylineId id = PolylineId("route");
        Polyline polyline = Polyline(
          polylineId: id,
          color: Colors.blue,
          width: 5,
          points: polylineCoordinates,
        );

        polylines[id] = polyline;

        // Add markers
        // print("polylines, $polylineCoordinates");
        // addMarker();
        _markers.add(
          destinationPosition = Marker(
            markerId: MarkerId('destination'),
            position: LatLng(_destinationP!.latitude, _destinationP!.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        );
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                (_destinationP!.latitude + _currentP!.latitude) / 2,
                (_destinationP!.longitude + _currentP!.longitude) / 2,
              ),
              zoom: 10,
            ),
          ),
        );
        _showCancelRoute = true;
        notifyListeners();
      } else {
        print("No route found: ${result.errorMessage}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  getNavigation() async {
    _showCancelRoute = false;
    _locationController.changeSettings(accuracy: LocationAccuracy.high);

    // Step 1: Ensure location service is enabled
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    // Step 2: Ensure permission is granted
    PermissionStatus permissionGranted = await _locationController
        .hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Step 3: Get initial position
    LocationData startPosition = await _locationController.getLocation();
    _currentP = LatLng(startPosition.latitude!, startPosition.longitude!);

    // Step 4: Draw the route once
    // await getDirections(_destinationP);

    // Step 5: Track location updates (throttled)
    DateTime? lastUpdate;
    _locationSubscription = _locationController.onLocationChanged.listen((
      currentLocation,
    ) async {
      if (currentLocation.latitude == null || currentLocation.longitude == null)
        return;

      if (lastUpdate != null &&
          DateTime.now().difference(lastUpdate!) < Duration(seconds: 1)) {
        return;
      }
      lastUpdate = DateTime.now();

      final newPosition = LatLng(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );
      _currentP = newPosition;

      // Animate camera smoothly
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newPosition, zoom: 18.0),
        ),
      );
      double? distanceKm;
      if (_destinationP != null) {
        distanceKm = getDistance(_destinationP!);
      }

      // Update current location marker
      sourcePosition = Marker(
        markerId: const MarkerId("current_location"),
        position: newPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: distanceKm != null
              ? "Distance: ${distanceKm.toStringAsFixed(2)} km"
              : "Calculating...",
        ),
      );

      // Instead of remove + add, update set in place:
      _markers
        ..removeWhere((m) => m.markerId.value == "current_location")
        ..add(sourcePosition!);

      notifyListeners();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_mapController != null) {
          _mapController!.showMarkerInfoWindow(
            const MarkerId("current_location"),
          );
        }
      });

      notifyListeners();
      // Future.delayed(Duration(milliseconds: 5000));
      await getDirections(_destinationP!);
      notifyListeners();
    });
  }

  void endNavigation() {
    // 1. Stop listening for location updates
    _locationSubscription?.cancel();
    _locationSubscription = null;

    polylines.clear();
    _markers.clear();
    sourcePosition = null;
    destinationPosition = null;
    _showCancelRoute = false;

    notifyListeners();
  }

  void deletePoints() {
    polylines.clear();
    _markers.clear();
    sourcePosition = null;
    destinationPosition = null;
    _showCancelRoute = false;

    notifyListeners();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a =
        0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double getDistance(LatLng destination) {
    return calculateDistance(
      _currentP!.latitude,
      _currentP!.longitude,
      destination.latitude,
      destination.longitude,
    );
  }

  void onSearchChanged(String value) async {
    if (value.isNotEmpty) {
      final result = _places.findAutocompletePredictions(value);
      _predictionsResponse = extractPredictions(await result);
      // print("Predictions: $_predictionsResponse");
      notifyListeners();
    }
  }

  List<Map<String, String>> extractPredictions(
    places.FindAutocompletePredictionsResponse response,
  ) {
    List<Map<String, String>> placesList = [];

    if (response.predictions.isEmpty) return placesList;

    for (var prediction in response.predictions) {
      // Fallbacks in case any field is null
      final placeId = prediction.placeId ?? '';
      final primaryText = prediction.primaryText?.trim().isNotEmpty == true
          ? prediction.primaryText
          : '(No Name)';
      final secondaryText = prediction.secondaryText?.trim().isNotEmpty == true
          ? prediction.secondaryText
          : '';
      final fullText = prediction.fullText?.trim().isNotEmpty == true
          ? prediction.fullText
          : primaryText;

      placesList.add({
        "placeId": placeId,
        "primaryText": primaryText,
        "secondaryText": secondaryText,
        "fullText": fullText,
      });
    }

    return placesList;
  }

  void setDestination(LatLng destination) {
    _destinationP = destination;
    notifyListeners();
  }
}
