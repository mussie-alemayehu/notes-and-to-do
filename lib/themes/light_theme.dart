import 'package:flutter/material.dart';

const Color _lightPrimaryColor = Color(0xFF4CAF50);
const Color _lightPrimaryVariantColor = Color(0xFF388E3C);
const Color _lightSecondaryColor = Color(0xFFFFC107);
const Color _lightSecondaryVariantColor = Color(0xFFFFA000);
const Color _lightBackgroundColor = Color(0xFFFFFFFF);
const Color _lightSurfaceColor = Color(0xFFEEEEEE);
const Color _lightErrorColor = Color(0xFFF44336);

// Light Theme Definition
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: _lightPrimaryColor,
    primaryContainer: _lightPrimaryVariantColor,
    secondary: _lightSecondaryColor,
    secondaryContainer: _lightSecondaryVariantColor,
    surface: _lightSurfaceColor,
    error: _lightErrorColor,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.black87,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: _lightBackgroundColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: _lightPrimaryColor,
    foregroundColor: Colors.white,
    elevation: 4.0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black87, fontSize: 16.0),
    titleMedium: TextStyle(
      color: Colors.black87,
      fontSize: 18.0,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: TextStyle(
      color: Colors.black87,
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: _lightPrimaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _lightPrimaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _lightPrimaryColor,
      side: const BorderSide(color: _lightPrimaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _lightSurfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: _lightPrimaryColor, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
    ),
    hintStyle: TextStyle(color: Colors.grey.shade600),
    labelStyle: const TextStyle(color: Colors.black87),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 15.0,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _lightSecondaryColor,
    foregroundColor: Colors.black,
    elevation: 6.0,
  ),
  cardTheme: CardTheme(
    color: _lightSurfaceColor,
    elevation: 2.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
  ),
);
