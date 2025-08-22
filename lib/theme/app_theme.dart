import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // --- SOFT LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF7F9F9),
    primarySwatch: Colors.green,
    brightness: Brightness.light,
    hintColor: const Color(0xFF1E8A62),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1E8A62),
      secondaryContainer: Color(0xFF228662),
      onSecondaryContainer: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Color(0xFF1A1A1A),
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFF1A1A1A),
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      bodyLarge: TextStyle(color: Colors.black54, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
      // Custom styles for special cards
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(color: Colors.white70),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade200,
      selectedColor: const Color(0xFF1E8A62),
      labelStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Colors.white,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1E8A62),
    ),
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    primarySwatch: Colors.green,
    brightness: Brightness.dark,
    hintColor: const Color(0xFFB4FF5C),
    colorScheme: const ColorScheme.dark(onSecondaryContainer: Colors.white70),
    appBarTheme: const AppBarTheme(color: Colors.transparent, elevation: 0),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white54, fontSize: 14),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(color: Colors.white70),
    ),
    cardTheme: CardThemeData(
      color: Colors.grey.shade800.withAlpha(128),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade800.withAlpha(204),
      disabledColor: Colors.grey.shade900,
      selectedColor: const Color(0xFFB4FF5C),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
