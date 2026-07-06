import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xff4F46E5),
      secondary: Color(0xff7C3AED),

      // primaryContainer: Color(0xffF5F5F5),      // Scaffold
      // onPrimaryContainer: Color(0xff4F46E5),    // AppBar/FAB


      primaryContainer: Color(0xffF5F5F5),      // Scaffold
      onPrimaryContainer: Color(0xFF1E0D3E),    // AppBar/FAB


      surface: Colors.white,
      onSurface: Colors.black87,

      onPrimary: Colors.white,
      outline: Color(0xffD6D6D6),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xff7C8CFF),
      secondary: Color(0xffB388FF),

      primaryContainer: Color(0xff121212),      // Scaffold
      onPrimaryContainer: Color(0xff1E1E1E),    // AppBar/FAB

      surface: Color(0xff1F1F1F),
      onSurface: Colors.white,

      onPrimary: Colors.white,
      outline: Color(0xff555555),
    ),
  );
}