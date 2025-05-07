import 'package:flutter/material.dart';

const Color _lightPrimaryColor = Color(0xFF4CAF50);
const Color _lightPrimaryVariantColor = Color(0xFF388E3C);
const Color _lightSecondaryColor = Color(0xFFFFC107);
const Color _lightSecondaryVariantColor = Color(0xFFFFA000);
const Color _lightOnSecondaryColor = Colors.black;
const Color _lightBackgroundColor = Color(0xFFFFFFFF);
const Color _lightSurfaceColor = Color(0xFFF5F5F5);
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
    onSecondary: _lightOnSecondaryColor,
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
    actionsIconTheme: IconThemeData(
      color: _lightSurfaceColor,
      size: 24.0,
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
    bodySmall: TextStyle(color: Colors.black54),
    labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: _lightOnSecondaryColor,
      backgroundColor: _lightSecondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      elevation: 4.0,
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
      side: const BorderSide(color: _lightPrimaryColor, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _lightSurfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: _lightPrimaryColor, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: _lightErrorColor, width: 2.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: _lightErrorColor, width: 2.5),
    ),
    hintStyle: TextStyle(color: Colors.grey.shade600),
    labelStyle: const TextStyle(color: Colors.black87),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _lightSecondaryColor,
    foregroundColor: Colors.black,
    elevation: 6.0,
  ),
  cardTheme: CardTheme(
    color: _lightSurfaceColor,
    elevation: 3.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
  ),
);
