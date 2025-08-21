import 'package:EcoMiles/provider/mapProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  final isDark;

  MapPage({super.key, required this.isDark});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    setMapStyle(isDark);
  }

  Future<void>? _locationFuture;

  @override
  void initState() {
    super.initState();

    _locationFuture = Provider.of<MapProvider>(
      context,
      listen: false,
    ).getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    return FutureBuilder(
      future: _locationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: mapProvider.currentLocation ?? mapProvider.getIndia,
            zoom: 5,
          ),
          zoomControlsEnabled: false,
          mapType: mapProvider.mapType,
          compassEnabled: false,
          onMapCreated: (controller) async {
            mapProvider.controller = controller;

            setMapStyle(widget.isDark);
            await mapProvider.getCurrentLocation();
          },
          markers: mapProvider.markers.toSet(),
          polylines: Set<Polyline>.of(mapProvider.polylines.values),
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
        );
      },
    );
  }
}
