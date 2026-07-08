import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xffFAFBFD),       //background
      secondary: Color(0xff1E0D3E),     //scaffold

      primaryContainer: Color(0xffFFFFFF),      // card
      onPrimaryContainer: Color(0xffE2E8F0),    //card border

      surface: Color(0xffF1F5F9),      //input bg
      onSurface: Color(0xffE2E8F0),   //input border

      onPrimary: Color(0xff0F172A),      //Primary text
      onSecondary: Color(0xff64748B),   //secondary text
      outline: Color(0xffF1F5F9),       //Divider

      tertiary: Color(0xffFFFFFF),    //Drawer surface
      secondaryContainer: Color(0xff6366F1)   //Button color

    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xff10111A),       //background
      secondary: Color(0xff1E0D3E),     //scaffold

      primaryContainer: Color(0xff181A25),      // card surface
      onPrimaryContainer: Color(0xff222538),    //card border

      surface: Color(0xff1F2131),      //input bg
      onSurface: Color(0xff2F324C),   //input border

      onPrimary: Color(0xffF1F5F9),      //Primary text
      onSecondary: Color(0xff94A3B8),   //secondary text
      outline: Color(0xff1E2131),       //Divider

      tertiary: Color(0xff151724),    //Drawer surface
      secondaryContainer: Color(0xff6366F1), //Button color

    ),
  );
}