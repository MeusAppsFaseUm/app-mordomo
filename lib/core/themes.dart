import 'package:flutter/material.dart';

class AppThemes {
  /* ---------- AZUL SUAVE ---------- */
  static final ThemeData blueTheme = _base.copyWith(
    primaryColor: const Color(0xFF87CEEB),
    scaffoldBackgroundColor: const Color(0xFFF0F8FF),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF87CEEB),
      foregroundColor: Color(0xFF2F4F4F),
      centerTitle: true,
      elevation: 3,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF4682B4),
    ),
    inputDecorationTheme: _input(const Color(0xFF87CEEB), const Color(0xFF4682B4)),
  );

  /* ---------- VERDE SUAVE ---------- */
  static final ThemeData greenTheme = _base.copyWith(
    primaryColor: const Color(0xFF98FB98),
    scaffoldBackgroundColor: const Color(0xFFF0FFF0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF98FB98),
      foregroundColor: Color(0xFF2E8B57),
      centerTitle: true,
      elevation: 3,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF3CB371),
    ),
    inputDecorationTheme: _input(const Color(0xFF98FB98), const Color(0xFF3CB371)),
  );

  /* ---------- ROXO SUAVE ---------- */
  static final ThemeData purpleTheme = _base.copyWith(
    primaryColor: const Color(0xFFDDA0DD),
    scaffoldBackgroundColor: const Color(0xFFFAF0E6),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFDDA0DD),
      foregroundColor: Color(0xFF4B0082),
      centerTitle: true,
      elevation: 3,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF9370DB),
    ),
    inputDecorationTheme: _input(const Color(0xFFDDA0DD), const Color(0xFF9370DB)),
  );

  /* ---------- LISTAS AUXILIARES ---------- */
  static final List<ThemeData> allThemes = [blueTheme, greenTheme, purpleTheme];
  static const List<String> themeNames = ['Azul Suave', 'Verde Suave', 'Roxo Suave'];
  static const List<Color> themeColors = [
    Color(0xFF87CEEB),
    Color(0xFF98FB98),
    Color(0xFFDDA0DD),
  ];

  /* ---------- BASE & HELPERS ---------- */
  static final ThemeData _base = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    cardTheme: const CardThemeData( // CORRIGIDO: CardThemeData ao invés de CardTheme
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );

  static InputDecorationTheme _input(Color border, Color focus) =>
      InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: focus, width: 3),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
}
