import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final lightThemeData = ThemeData(
  fontFamily: GoogleFonts.lato().fontFamily,
  appBarTheme: const AppBarTheme(
    elevation: 0,
  ),
  textTheme: GoogleFonts.latoTextTheme(
    ThemeData.light().textTheme,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.teal),
);
