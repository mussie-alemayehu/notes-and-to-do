import 'package:flutter/material.dart';

const Color _darkPrimaryColor = Color(0xFF81C784);
const Color _darkPrimaryVariantColor = Color(0xFF4CAF50);
const Color _darkSecondaryColor = Color(0xFFFFD54F);
const Color _darkSecondaryVariantColor = Color(0xFFFFC107);
const Color _darkBackgroundColor = Color(0xFF1A1A1A);
const Color _darkSurfaceColor = Color(0xFF2E2E2E);
const Color _darkErrorColor = Color(0xFFEF9A9A);
const Color _darkOnSecondaryColor = Colors.black;

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
    onSecondary: _darkOnSecondaryColor,
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
    actionsIconTheme: IconThemeData(
      color: _darkPrimaryVariantColor,
      size: 24.0,
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
    bodySmall: TextStyle(color: Colors.white54),
    labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: _darkOnSecondaryColor,
      backgroundColor: _darkSecondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _darkPrimaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _darkPrimaryColor,
      side: const BorderSide(color: _darkPrimaryColor, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _darkSurfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: _darkPrimaryColor, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: _darkErrorColor, width: 2.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: _darkErrorColor, width: 2.5),
    ),
    hintStyle: TextStyle(color: Colors.grey.shade500),
    labelStyle: const TextStyle(color: Colors.white70),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 18.0,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _darkSecondaryColor,
    foregroundColor: Colors.black,
    elevation: 6.0,
  ),
  cardTheme: CardTheme(
    color: _darkSurfaceColor,
    elevation: 3.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
  ),
);
