import 'package:flutter/material.dart';

const Color _darkPrimaryColor = Color(0xFF81C784);
const Color _darkPrimaryVariantColor = Color(0xFF4CAF50);
const Color _darkSecondaryColor = Color(0xFFFFD54F);
const Color _darkSecondaryVariantColor = Color(0xFFFFC107);
const Color _darkBackgroundColor = Color(0xFF121212);
const Color _darkSurfaceColor = Color(0xFF1E1E1E);
const Color _darkErrorColor = Color(0xFFEF9A9A);

// Dark Theme Definition
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: _darkPrimaryColor,
    primaryContainer: _darkPrimaryVariantColor,
    secondary: _darkSecondaryColor,
    secondaryContainer: _darkSecondaryVariantColor,
    surface: _darkSurfaceColor,
    error: _darkErrorColor,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white70,
    onError: Colors.black,
  ),
  scaffoldBackgroundColor: _darkBackgroundColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: _darkSurfaceColor,
    foregroundColor: _darkPrimaryColor,
    elevation: 4.0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: _darkPrimaryColor,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white70, fontSize: 16.0),
    titleMedium: TextStyle(
      color: Colors.white70,
      fontSize: 18.0,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: _darkPrimaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _darkPrimaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _darkPrimaryColor,
      side: const BorderSide(color: _darkPrimaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _darkSurfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: _darkPrimaryColor, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
    ),
    hintStyle: TextStyle(color: Colors.grey.shade500),
    labelStyle: const TextStyle(color: Colors.white70),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 15.0,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _darkSecondaryColor,
    foregroundColor: Colors.black,
    elevation: 6.0,
  ),
  cardTheme: CardTheme(
    color: _darkSurfaceColor,
    elevation: 2.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
  ),
);
