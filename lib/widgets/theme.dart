/* ---- Tema app: palette chiara da seed, AppBar coerente e font "Playfair Display" ---- */
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData app = ThemeData(
    /* ---- Schema colori generato dal seed (variante chiara) ---- */
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 220, 200, 176),
      brightness: Brightness.light,
    ),

    /* ---- Stile AppBar: colore leggermente più scuro del fondo, testo scuro, no tint/elevazione ---- */
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFDCC8B0),
      foregroundColor: Color(0xFF402E26),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),

    /* ---- Gerarchia tipografica: titoli e testi con Playfair Display e palette coerente ---- */
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
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color.fromARGB(255, 91, 61, 63),
        height: 1.2,
        fontFamily: 'Playfair Display',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: Color.fromARGB(255, 91, 61, 63),
        height: 1.2,
        fontFamily: 'Playfair Display',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: Color.fromARGB(255, 91, 61, 63),
        height: 1.2,
        fontFamily: 'Playfair Display',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: Color.fromARGB(255, 91, 61, 63),
        height: 1.2,
        fontFamily: 'Playfair Display',
      ),
      labelLarge: TextStyle(
        letterSpacing: 0.5,
        fontFamily: 'Playfair Display',
      ),
    ),
  );
}
