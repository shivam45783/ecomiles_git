import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _showSettings = false;

  bool get showSettings => _showSettings;

  void show() {
    _showSettings = true;
    notifyListeners();
  }

  void hide() {
    _showSettings = false;
    notifyListeners();
  }

  void toggle() {
    _showSettings = !_showSettings;
    notifyListeners();
  }
}
