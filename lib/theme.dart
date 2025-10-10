import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData app = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.amber,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: Colors.blueGrey,
        letterSpacing: 0.5,
        height: 1.2,
        shadows: [
          Shadow(blurRadius: 2, offset: Offset(0, 1), color: Colors.black26),
        ],
        fontFamily: 'Poppins',
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.blueGrey,
        height: 1.2,
        fontFamily: 'Poppins',
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.3, fontFamily: 'Poppins'),
      bodyMedium: TextStyle(fontSize: 14, height: 1.3, fontFamily: 'Poppins'),
      labelLarge: TextStyle(letterSpacing: 0.5, fontFamily: 'Poppins'),
    ),
  );
}
