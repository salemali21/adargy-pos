import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: GoogleFonts.tajawal().fontFamily,
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.tajawal().fontFamily,
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: const Color(0xFF181818),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF22223B),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
