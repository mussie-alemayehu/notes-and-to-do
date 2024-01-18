import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './text_theme.dart';

ThemeData darkTheme = ThemeData(
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
    background: Colors.black,
    primary: Colors.grey.shade900,
    secondary: Colors.grey.shade800,
    tertiary: const Color.fromARGB(128, 81, 255, 75),
  ),
  checkboxTheme: const CheckboxThemeData(
    checkColor: MaterialStatePropertyAll<Color>(
      Colors.white,
    ),
  ),
  useMaterial3: true,
);
