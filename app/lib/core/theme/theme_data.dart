import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white, // Default card color for light theme
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.bold, color: Colors.black),
      titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black),
      bodyLarge: TextStyle(fontSize: 16.0, height: 1.5, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 14.0, height: 1.4, color: Colors.black),
      labelSmall: TextStyle(fontSize: 11.0, color: Colors.grey),
    ),
    // Add other component themes as needed
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C2128),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF2D333B), // Default card color for dark theme
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFF1C2128),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16.0, height: 1.5, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14.0, height: 1.4, color: Colors.white),
      labelSmall: TextStyle(fontSize: 11.0, color: Colors.grey),
    ),
    // Add other component themes as needed
  );
}
