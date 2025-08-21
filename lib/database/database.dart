import 'package:EcoMiles/theme/theme_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Database {
  // default data structure
  Map<String, dynamic> data = {
    "mapStyle": MapType.normal.index,
    "theme": AppThemeMode.system.index,
    "prefrence": "Eco",
  };

  final Box box = Hive.box('database');

  void createData() {
    if (!box.containsKey('data')) {
      box.put('data', data);
    }
  }

  void updateData(String key, dynamic value) {
    Map<String, dynamic> currentData = Map<String, dynamic>.from(
      box.get('data'),
    );
    currentData[key] = value;
    box.put('data', currentData);
  }

  /// Save theme (store enum as index)
  void updateTheme(AppThemeMode theme) {
    updateData("theme", theme.index);
  }

  /// Read theme back from Hive (convert int → enum)
  AppThemeMode getTheme() {
    final currentData = Map<String, dynamic>.from(
      box.get('data', defaultValue: {}),
    );

    final stored = currentData["theme"];
    if (stored is int && stored >= 0 && stored < AppThemeMode.values.length) {
      return AppThemeMode.values[stored];
    }
    return AppThemeMode.system; // fallback
  }

  void updateMapStyle(MapType style) {
    updateData("mapStyle", style.index);
  }

  MapType getMapStyle() {
    final currentData = Map<String, dynamic>.from(
      box.get('data', defaultValue: {}),
    );
    final stored = currentData["mapStyle"];
    if (stored is int && stored >= 0 && stored < MapType.values.length) {
      return MapType.values[stored];
    }
    return MapType.normal; // fallback, never null
  }

  Map<String, dynamic> readData() {
    return Map<String, dynamic>.from(box.get('data', defaultValue: {}));
  }

  void updatePreferences(String pref) {
    final currentData = Map<String, dynamic>.from(box.get('data'));
    currentData["prefrence"] = pref;
    box.put('data', currentData);
  }

  String getPreferences() {
    final currentData = Map<String, dynamic>.from(
      box.get('data', defaultValue: {}),
    );

    // If key missing or value is null, return "Eco"
    return currentData["prefrence"] ?? "Eco";
  }

  void clearData() {
    box.delete('data');
  }
}
