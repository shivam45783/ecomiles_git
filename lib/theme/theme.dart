import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  textTheme: GoogleFonts.poppinsTextTheme(),
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: Colors.purple.shade500,
    surface: Color.fromARGB(255, 255, 251, 246),
    primary: Colors.purple.shade500,
    secondary: Colors.purple.shade400,
    tertiary: Colors.purple.shade300,
    primaryContainer: const Color.fromARGB(136, 155, 39, 176),
    secondaryContainer: const Color.fromARGB(135, 159, 49, 179),
  ),
);

ThemeData darkMode = ThemeData(
  textTheme: GoogleFonts.poppinsTextTheme(),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: Colors.purple.shade500,
    surface: Color.fromARGB(255, 255, 251, 246),
    primary: Colors.purple.shade500,
    secondary: Colors.purple.shade400,
    tertiary: Colors.purple.shade300,
    primaryContainer: const Color.fromARGB(132, 155, 39, 176),
    secondaryContainer: const Color.fromARGB(184, 163, 84, 176),
  ),
);
