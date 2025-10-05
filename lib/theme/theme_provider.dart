import 'package:EcoMiles/database/database.dart';
import 'package:flutter/material.dart';
import 'package:EcoMiles/theme/theme.dart';
// import 'package:hive_flutter/adapters.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider with ChangeNotifier, WidgetsBindingObserver {
   final Database database = Database();

  late AppThemeMode _appThemeMode;
  late ThemeData _themeData;

  ThemeProvider() {
    WidgetsBinding.instance.addObserver(this);

    // ensure Hive box is created
    database.createData();

    // load theme from Hive
    _appThemeMode = database.getTheme();
    _themeData = _resolveTheme(_appThemeMode);
  }

  
  ThemeData get themeData => _themeData;
  AppThemeMode get appThemeMode => _appThemeMode;

  void setThemeMode(AppThemeMode mode) {
    _appThemeMode = mode;
    if (mode == AppThemeMode.system) {
      _updateThemeFromSystem();
      database.updateTheme(AppThemeMode.system);
    } else if (mode == AppThemeMode.light) {
      _themeData = lightMode;
      database.updateTheme(AppThemeMode.light);
    } else if (mode == AppThemeMode.dark) {
      _themeData = darkMode;
      database.updateTheme(AppThemeMode.dark);
    }
    notifyListeners();
  }

  void toggleTheme() {
    if (_appThemeMode == AppThemeMode.system) {
      setThemeMode(AppThemeMode.light);
    } else if (_appThemeMode == AppThemeMode.light) {
      setThemeMode(AppThemeMode.dark);
    } else {
      setThemeMode(AppThemeMode.system);
    }
  }

  void selectTheme(theme) {
    if (theme == AppThemeMode.system) {
      setThemeMode(AppThemeMode.system);
    } else if (theme == AppThemeMode.light) {
      setThemeMode(AppThemeMode.light);
    } else {
      setThemeMode(AppThemeMode.dark);
    }
  }

  void _updateThemeFromSystem() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _themeData = brightness == Brightness.dark ? darkMode : lightMode;
  }

  @override
  void didChangePlatformBrightness() {
    if (_appThemeMode == AppThemeMode.system) {
      _updateThemeFromSystem();
      notifyListeners();
    }
  }

  void disposeObserver() {
    WidgetsBinding.instance.removeObserver(this);
  }
   ThemeData _resolveTheme(AppThemeMode mode) {
    if (mode == AppThemeMode.system) {
      _updateThemeFromSystem();
      return _themeData;
    } else if (mode == AppThemeMode.light) {
      return lightMode;
    } else {
      return darkMode;
    }
  }

}
