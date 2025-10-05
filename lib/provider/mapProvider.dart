import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:EcoMiles/database/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:EcoMiles/utils/gurugram_boundary.dart';

class MapProvider extends ChangeNotifier {
  final Database database = Database();
  final Location _locationController = Location();

  GoogleMapController? _mapController;
  final _places = places.FlutterGooglePlacesSdk(
    dotenv.env['GOOGLE_MAPS_API_KEY']!,
  );
  static const LatLng _pIndia = LatLng(20.5937, 78.9629);
  LatLng? _currentP = null;
  LatLng? _destinationP = null;
  LatLng? _fromP = null;
  LatLng? _toP = null;
  MapType mapType = MapType.normal;

  List _predictionsResponse = [];
  bool _showCancelRoute = false;
  bool _getOptimisedRoute = true;
  List get predictionsResponse => _predictionsResponse;
  LatLng? get currentLocation => _currentP;
  LatLng? get destinationLocation => _destinationP;
  LatLng? get fromLocation => _fromP;
  LatLng? get toLocation => _toP;
  bool get optimisedRoute => _getOptimisedRoute;
  set setOptimisedRoute(bool value) => {
    _getOptimisedRoute = value,
    database.updatePreferences(value ? "Eco" : "Time"),
  };
  LatLng get getIndia => _pIndia;
  GoogleMapController? get mapController => _mapController;
  Location get locationController => _locationController;
  TextEditingController? _searchController = TextEditingController();
  TextEditingController? _sourceController = TextEditingController();
  TextEditingController? _destinationController = TextEditingController();
  bool get showCancelRoute => _showCancelRoute;

  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> _markers = {};
  StreamSubscription<LocationData>? get locationSubscription =>
      _locationSubscription;
  TextEditingController? get searchController => _searchController;
  TextEditingController? get sourceController => _sourceController;
  TextEditingController? get destinationController => _destinationController;
  Set<Marker> get markers => _markers;
  // int _markerIdCounter = 1;
  Marker? sourcePosition, destinationPosition, fromPosition, toPosition;
  set controller(GoogleMapController controller) => _mapController = controller;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  StreamSubscription<LocationData>? _locationSubscription;
  notifyListeners();

  MapProvider() {
    mapType = database.getMapStyle();
    _getOptimisedRoute = database.getPreferences() == "Eco" ? true : false;
  }
  void addCurrentLocationMarker() {
    if (_currentP != null) {
      _markers.add(
        Marker(
          markerId: MarkerId("current_location"),
          position: _currentP!,
          infoWindow: InfoWindow(title: "Current Location"),
        ),
      );
      notifyListeners();
    }
  }

  bool isCoordinatesInsideGurugram(LatLng pointA, LatLng pointB) {
    if (isInsideGurugram(pointA) && isInsideGurugram(pointB)) {
      return true;
    }
    return false;
  }
  // void _addMarker(LatLng position) {
  //   final markerId = MarkerId('marker_$_markerIdCounter');
  //   _markerIdCounter++;

  //   final Marker marker = Marker(
  //     markerId: markerId,
  //     position: position,
  //     infoWindow: InfoWindow(title: 'Marker $_markerIdCounter'),
  //   );

  //   _markers.add(marker);
  //   notifyListeners();
  // }

  Future<void> getCurrentLocation() async {
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

      final retryLocation = await _locationController.getLocation();
      if (retryLocation.latitude != null && retryLocation.longitude != null) {
        _currentP = LatLng(retryLocation.latitude!, retryLocation.longitude!);
        notifyListeners();
      }
    }

    final locationData = await _locationController.getLocation();
    if (locationData.latitude == null || locationData.longitude == null) return;

    final newPosition = LatLng(locationData.latitude!, locationData.longitude!);

    const double threshold = 0.0001;
    final hasMoved =
        _currentP == null ||
        (newPosition.latitude - _currentP!.latitude).abs() > threshold ||
        (newPosition.longitude - _currentP!.longitude).abs() > threshold;

    if (hasMoved) {
      _currentP = newPosition;

      notifyListeners();
    }

    if (_mapController != null && _currentP != null) {
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
      database.updateMapStyle(MapType.normal);
    } else if (type == MapType.hybrid) {
      mapType = MapType.hybrid;
      database.updateMapStyle(MapType.hybrid);
    } else if (type == MapType.terrain) {
      mapType = MapType.terrain;
      database.updateMapStyle(MapType.terrain);
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

  Future<bool> selectPlace(String placeId) async {
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=geometry'
      '&key=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == "OK") {
        print(data);
        final location = LatLng(
          data['result']['geometry']['location']['lat'],
          data['result']['geometry']['location']['lng'],
        );
        print("location: $location");
        if (!isCoordinatesInsideGurugram(_currentP!, location) &&
            _getOptimisedRoute == true) {
          print("Outside gurugram");
          return false;
        }
        _destinationP = location;

        // addMarker();
        await getDirectionsToPlot(_destinationP!);
        notifyListeners();
      }
    }
    return true;
  }

  Future<void> selectFromPlace(String placeId) async {
    // print("fromPlace: $placeId");
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=geometry'
      '&key=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == "OK") {
        print(data);
        final location = LatLng(
          data['result']['geometry']['location']['lat'],
          data['result']['geometry']['location']['lng'],
        );
        _fromP = location;
        print("fromP: $location");
        notifyListeners();
      }
    }
  }

  Future<void> selectToPlace(String placeId) async {
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=geometry'
      '&key=$apiKey',
    );
    final response = await http.get(url);
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("data: $data");
      if (data['status'] == "OK") {
        print(data);
        final location = LatLng(
          data['result']['geometry']['location']['lat'],
          data['result']['geometry']['location']['lng'],
        );
        _toP = location;
        print("toP: $location");

        // addMarker();
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
      List<LatLng> polylineCoordinates = [];
      if (_getOptimisedRoute == false) {
        final result = await polylinePoints.getRouteBetweenCoordinates(
          request: PolylineRequest(
            origin: PointLatLng(origin.latitude, origin.longitude),
            destination: PointLatLng(
              destination.latitude,
              destination.longitude,
            ),

            // arrivalTime: DateTime.now().millisecondsSinceEpoch,
            mode: TravelMode.driving,
          ),
        );
        if (result.points.isNotEmpty) {
          polylineCoordinates = result.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        }
      } else {
        polylineCoordinates = await getOptimisedRoute(origin, destination);
        print("apiCalled: ${polylineCoordinates}");
      }

      // print("HI");

      PolylineId id = PolylineId("route");
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        width: 5,
        points: polylineCoordinates,
      );

      polylines[id] = polyline;

      _markers.add(
        destinationPosition = Marker(
          markerId: MarkerId('destination'),
          position: LatLng(_destinationP!.latitude, _destinationP!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );

      notifyListeners();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getDirectionsToPlot(LatLng dst) async {
    try {
      if (_currentP == null || _destinationP == null) return;

      final origin = _currentP!;
      final destination = dst;

      final polylinePoints = PolylinePoints(
        apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
      );

      List<LatLng> polylineCoordinates = [];
      if (_getOptimisedRoute == false) {
        final result = await polylinePoints.getRouteBetweenCoordinates(
          request: PolylineRequest(
            origin: PointLatLng(origin.latitude, origin.longitude),
            destination: PointLatLng(
              destination.latitude,
              destination.longitude,
            ),

            // arrivalTime: DateTime.now().millisecondsSinceEpoch,
            mode: TravelMode.driving,
          ),
        );
        if (result.points.isNotEmpty) {
          polylineCoordinates = result.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
          print(polylineCoordinates);
        }
      } else {
        polylineCoordinates = await getOptimisedRoute(origin, destination);
        print("apiCalled: ${polylineCoordinates}");
      }
      PolylineId id = PolylineId("route");
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        width: 5,
        points: polylineCoordinates,
      );

      polylines[id] = polyline;

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
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<bool> getPloyLinesToPlot(LatLng from, LatLng to) async {
    try {
      final polylinePoints = PolylinePoints(
        apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
      );

      List<LatLng> polylineCoordinates = [];
      if (_getOptimisedRoute == false) {
        final result = await polylinePoints.getRouteBetweenCoordinates(
          request: PolylineRequest(
            origin: PointLatLng(from.latitude, from.longitude),
            destination: PointLatLng(to.latitude, to.longitude),

            // arrivalTime: DateTime.now().millisecondsSinceEpoch,
            mode: TravelMode.driving,
          ),
        );
        if (result.points.isNotEmpty) {
          polylineCoordinates = result.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        }
      } else {
        bool isInsideGurugram = isCoordinatesInsideGurugram(from, to);
        if (!isInsideGurugram) return false;
        polylineCoordinates = await getOptimisedRoute(from, to);
        // print("length: ${polylineCoordinates.length}");
        // print("apiCalled: ${polylineCoordinates}");
      }
      PolylineId id = PolylineId("route");
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        width: 5,
        points: polylineCoordinates,
      );

      polylines[id] = polyline;

      _markers.add(
        toPosition = Marker(
          markerId: MarkerId('to'),
          position: LatLng(to.latitude, to.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
      _markers.add(
        fromPosition = Marker(
          markerId: MarkerId('from'),
          position: LatLng(from.latitude, from.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              (to.latitude + from.latitude) / 2,
              (to.longitude + from.longitude) / 2,
            ),
            zoom: 10,
          ),
        ),
      );
      _showCancelRoute = true;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  getNavigation() async {
    _showCancelRoute = false;
    _locationController.changeSettings(accuracy: LocationAccuracy.high);

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

    LocationData startPosition = await _locationController.getLocation();
    _currentP = LatLng(startPosition.latitude!, startPosition.longitude!);

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

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newPosition, zoom: 18.0),
        ),
      );
      double? distanceKm;
      if (_destinationP != null) {
        distanceKm = getDistance(_destinationP!);
      }

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
      if (_getOptimisedRoute == false) await getDirections(_destinationP!);
      notifyListeners();
      // Future.delayed(Duration(milliseconds: 5000));
    });
    if (_getOptimisedRoute) await getDirections(_destinationP!);
    notifyListeners();
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
    _destinationP = null;

    notifyListeners();
  }

  void deletePoints() {
    polylines.clear();
    _markers.clear();
    sourcePosition = null;
    destinationPosition = null;
    fromPosition = null;
    toPosition = null;
    _destinationP = null;
    _fromP = null;
    _toP = null;
    _showCancelRoute = false;
    _sourceController!.text = "";
    _destinationController!.text = "";

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

  void onSourceChanged(String value) async {
    if (value.isNotEmpty) {
      final result = _places.findAutocompletePredictions(value);
      _predictionsResponse = extractPredictions(await result);
      // print("Predictions: $_predictionsResponse");
      notifyListeners();
    }
  }

  void onDestinationChanged(String value) async {
    if (value.isNotEmpty) {
      final result = _places.findAutocompletePredictions(value);
      _predictionsResponse = extractPredictions(await result);
      print("Predictions: $_predictionsResponse");
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

  Future<List<LatLng>> getOptimisedRoute(
    LatLng source,
    LatLng destination,
  ) async {
    List<LatLng> polylineCoordinates = [];
    try {
      print("BACKEND_URL: ${await dotenv.env['BACKEND_URL']}");
      print(dotenv.env);

      final url = Uri.parse("http://34.30.56.121/api/get-route");
      // final url = Uri.parse("http://10.196.46.194:5050/api/get-route");
      print("url: ${url}");
      Map<String, dynamic> data = {
        "source": {"lat": source.latitude, "long": source.longitude},
        "destination": {
          "lat": destination.latitude,
          "long": destination.longitude,
        },
        "date": DateTime.now().day,
        "month": DateTime.now().month,
        "hour": DateTime.now().hour,
        "day": DateTime.now().weekday,
      };
      print("data: ${data}");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Connection": "keep-alive",
        },

        body: jsonEncode(data),
      );
      print("response: ${response.body}");
      if (response.statusCode == 200) {
        polylineCoordinates = parseLatLngList(response.body);
      }
      print("polylineCoordinates: ${polylineCoordinates}");
    } catch (e) {
      print("ErrorCaused: $e");
    }
    return polylineCoordinates;
  }

  List<LatLng> parseLatLngList(String responseBody) {
    final List<dynamic> data = jsonDecode(responseBody);
    return data.map<LatLng>((coords) {
      final double lat = coords[0].toDouble();
      final double lng = coords[1].toDouble();
      return LatLng(lat, lng);
    }).toList();
  }
}
