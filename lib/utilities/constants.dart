import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  static const String appName = 'Divine';

  static const Color lightPrimary = Color(0xfff3f4f9);
  static const Color darkPrimary = Color(0xff2B2B2B);

  static const Color lightAccent = Color(0xff886EE4);

  static const Color darkAccent = Color(0xff886EE4);

  static const Color lightBG = Color(0xfff3f4f9);
  static const Color darkBG = Color(0xff2B2B2B);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    // backgroundColor is deprecated
    backgroundColor: lightBG,
    primaryColor: lightPrimary,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: lightAccent,
    ),
    scaffoldBackgroundColor: lightBG,
    bottomAppBarTheme: const BottomAppBarTheme(
      elevation: 0,
      color: lightBG,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0.0,
      backgroundColor: lightBG,
      iconTheme: const IconThemeData(color: Colors.black),
      toolbarTextStyle: GoogleFonts.nunito(
        color: Colors.black,
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
      ),
      titleTextStyle: GoogleFonts.nunitoSans(
        color: Colors.black,
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: lightAccent,
    ),
  );

  //Dark Theme
  static ThemeData darkTheme = ThemeData(
    iconTheme: const IconThemeData(color: Colors.white),
    colorScheme: ColorScheme.fromSwatch(
      accentColor: darkAccent,
    ).copyWith(
      secondary: darkAccent,
      brightness: Brightness.dark,
    ),
    // backgroundColor is deprecated
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBG,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: darkAccent,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      elevation: 0,
      color: darkBG,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0.0,
      backgroundColor: darkBG,
      iconTheme: const IconThemeData(color: Colors.white),
      toolbarTextStyle: GoogleFonts.nunitoSans(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
      ),
      titleTextStyle: GoogleFonts.nunitoSans(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
