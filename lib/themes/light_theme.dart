// specification of the colors in light theme

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './text_theme.dart';

ThemeData lightTheme = ThemeData(
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
    background: Colors.white,
    primary: Colors.grey.shade100,
    secondary: Colors.grey.shade300,
    tertiary: const Color.fromARGB(128, 5, 157, 0),
  ),
  checkboxTheme: const CheckboxThemeData(
    checkColor: MaterialStatePropertyAll<Color>(
      Colors.black,
    ),
  ),
  textTheme: textTheme,
  useMaterial3: true,
);
