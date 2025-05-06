import 'package:flutter/material.dart';

// A simple ChangeNotifier to hold and manage the current ThemeMode.
class ThemeNotifier with ChangeNotifier {
  // Default theme mode is system default.
  ThemeMode _themeMode = ThemeMode.system;

  // Getter to access the current theme mode.
  ThemeMode get themeMode => _themeMode;

  // Setter to update the theme mode and notify listeners.
  void setThemeMode(ThemeMode mode) {
    // Only update and notify if the mode has actually changed.
    if (_themeMode != mode) {
      _themeMode = mode;
      // Notify all widgets listening to this notifier to rebuild.
      notifyListeners();
    }
  }
}
