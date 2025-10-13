import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData app = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 220, 200, 176),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFDCC8B0), // più scura del fondo
      foregroundColor: Color(0xFF402E26),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: Color.fromARGB(255, 91, 61, 63),
        letterSpacing: 0.5,
        height: 1.2,
        shadows: [
          Shadow(blurRadius: 2, offset: Offset(0, 1), color: Colors.black26),
        ],
        fontFamily: 'Playfair Display',
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color.fromARGB(255, 91, 61, 63),
        height: 1.2,
        fontFamily: 'Playfair Display',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.3,
        fontFamily: 'Playfair Display',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.3,
        fontFamily: 'Playfair Display',
      ),
      labelLarge: TextStyle(letterSpacing: 0.5, fontFamily: 'Playfair Display'),
    ),
  );
}
