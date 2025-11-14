import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode(isDarkMode);
    notifyListeners();
  }

  void _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDarkMode = prefs.getBool('isDarkMode');
    if (isDarkMode != null) {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system; // Default to system theme
    }
    notifyListeners();
  }

  void _saveThemeMode(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }
}
