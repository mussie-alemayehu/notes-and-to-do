import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './text_theme.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
  textTheme: textTheme,
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF121212),
    primary: Color(0xFF2A6A98),
    onPrimary: Color(0xFF3700B3),
    secondary: Color(0xFF001C2A),
    onSecondary: Color(0xFF018786),
    tertiary: Color(0xFFA7B6B2),
  ),
  checkboxTheme: const CheckboxThemeData(
    checkColor: WidgetStatePropertyAll<Color>(
      Colors.white,
    ),
  ),
  useMaterial3: true,
);
