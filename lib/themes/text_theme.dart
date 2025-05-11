// contains the text themes used throughout the app

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme textTheme = TextTheme(
  bodyLarge: GoogleFonts.poppins(
    fontSize: 18,
  ),
  bodyMedium: GoogleFonts.poppins(
    fontSize: 14,
  ),
  bodySmall: GoogleFonts.poppins(
    fontSize: 11,
  ),
  labelMedium: GoogleFonts.poppins(
    fontSize: 13,
    fontStyle: FontStyle.italic,
    decoration: TextDecoration.lineThrough,
  ),
  headlineLarge: GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
  headlineMedium: GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
);
