// specification of the colors in light theme

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './text_theme.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
  colorScheme: ColorScheme.light(
    surface: Color(0xFFF5F5F5),
    primary: Color(0xFF3700B3),
    onPrimary: Color(0xFF873AF3),
    secondary: Color(0xFF4ABBEF),
    onSecondary: Color(0xFF0277BD),
    tertiary: Color(0xFF484948),
  ),
  checkboxTheme: const CheckboxThemeData(
    checkColor: WidgetStatePropertyAll<Color>(
      Colors.black,
    ),
  ),
  textTheme: textTheme,
  useMaterial3: true,
);
