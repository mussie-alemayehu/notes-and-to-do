import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme textTheme = TextTheme(
  bodyLarge: GoogleFonts.roboto(
    fontSize: 18,
  ),
  bodyMedium: GoogleFonts.roboto(
    fontSize: 14,
  ),
  bodySmall: GoogleFonts.roboto(
    fontSize: 11,
  ),
  labelMedium: GoogleFonts.roboto(
    fontSize: 13,
    fontStyle: FontStyle.italic,
    decoration: TextDecoration.lineThrough,
  ),
  headlineLarge: GoogleFonts.roboto(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
  headlineMedium: GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
);

TextTheme textThemeLight = textTheme.copyWith();
