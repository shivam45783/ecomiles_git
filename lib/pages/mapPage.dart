// import 'package:EcoMiles/theme/theme_provider.dart';
import 'package:EcoMiles/provider/mapProvider.dart';
import 'package:EcoMiles/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  final isDark;
  // GoogleMapController? mapController;
  // Location locationController;
  // LatLng? currentLocation;
  // final getCurrentLocation;
  // LatLng? currentP;
  MapPage({
    super.key,
    required this.isDark,
    // this.mapController,
    // this.currentLocation,
    // this.getCurrentLocation,
    // this.currentP,
    // required this.locationController,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // String _mapStyle = '';
  final LatLng pointA = LatLng(18.5204, 73.8567);
  final LatLng pointB = LatLng(19.0760, 72.8777);
  void setMapStyle(bool isDark) async {
    String style = await DefaultAssetBundle.of(context).loadString(
      isDark
          ? 'assets/mapStyles/map_style_dark.json'
          : 'assets/mapStyles/map_style_light.json',
    );
    Provider.of<MapProvider>(context, listen: false).setMapStyle(style);
  }

  @override
  void didUpdateWidget(MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark) {
      setMapStyle(widget.isDark);
    }
  }

  // static const LatLng _pGooglePlex = LatLng(
  //   37.42796133580664,
  //   -122.085749655962,
  // );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    setMapStyle(isDark);
  }

  @override
  Widget build(BuildContext context) {
    // final isDark =
    //     Provider.of<ThemeProvider>(context).appThemeMode == AppThemeMode.dark;
    final mapProvider = Provider.of<MapProvider>(context);
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: mapProvider.currentLocation ?? mapProvider.getIndia,
        zoom: 5,
      ),
      // compassEnabled: true,
      // mapToolbarEnabled: true,
      zoomControlsEnabled: false,
      mapType: mapProvider.mapType,
      onMapCreated: (controller) async {
        mapProvider.controller = controller;
        // mapProvider.setMapController(controller);
        setMapStyle(widget.isDark);
        await mapProvider.getCurrentLocation();
        // await mapProvider.getLocationUpdates();
        // await mapProvider.addMarker();
      },

      // markers:
      //     (mapProvider.sourcePosition != null &&
      //         mapProvider.destinationPosition != null)
      //     ? {
      //       // mapProvider.sourcePosition!,
      //      mapProvider.destinationPosition!}
      //     : {},
      // markers: {
      //   if (mapProvider.destinationPosition != null)
      //     mapProvider.destinationPosition!,
      //   if (mapProvider.sourcePosition != null) mapProvider.sourcePosition!,
      // }.toSet(),
      markers: mapProvider.markers.toSet(),

      polylines: Set<Polyline>.of(mapProvider.polylines.values),
      myLocationButtonEnabled: false,

      // myLocationEnabled: true,
      myLocationEnabled: true,
    );
  }

  // Future<void> getLocationUpdates() async {
  //   bool serviceEnabled = await map.serviceEnabled();
  //   if (!serviceEnabled) {
  //     serviceEnabled = await widget.locationController.requestService();
  //     if (!serviceEnabled) return;
  //   }

  //   PermissionStatus permissionGranted = await widget.locationController
  //       .hasPermission();
  //   if (permissionGranted == PermissionStatus.denied) {
  //     permissionGranted = await widget.locationController.requestPermission();
  //     if (permissionGranted != PermissionStatus.granted) return;
  //   }

  //   widget.locationController.onLocationChanged.listen((
  //     LocationData currentLocation,
  //   ) {
  //     if (currentLocation.latitude != null &&
  //         currentLocation.longitude != null) {
  //       final newPosition = LatLng(
  //         currentLocation.latitude!,
  //         currentLocation.longitude!,
  //       );
  //       setState(() {
  //         widget.currentP = newPosition;
  //       });
  //       if (widget.mapController != null) {
  //         widget.mapController!.animateCamera(CameraUpdate.newLatLng(newPosition));
  //       }
  //     }
  //   });
  // }
}
