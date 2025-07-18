import 'package:flutter/material.dart';

class AdminTheme {
  // Light Theme Colors
  static final Color _lightPrimaryColor = Color(0xFF4A90E2);
  static final Color _lightAccentColor = Color(0xFF50E3C2);
  static final Color _lightBackgroundColor = Color(0xFFF4F7FC);
  static final Color _lightCardColor = Colors.white;
  static final Color _lightTextColor = Color(0xFF333333);
  static final Color _lightSubtitleColor = Color(0xFF777777);

  // Dark Theme Colors
  static final Color _darkPrimaryColor =
      Color(0xFF4A90E2); // Blue remains prominent
  static final Color _darkAccentColor = Color(0xFF50E3C2);
  static final Color _darkBackgroundColor = Color(0xFF1A1D21); // Deep charcoal
  static final Color _darkCardColor =
      Color(0xFF252A30); // Slightly lighter charcoal
  static final Color _darkTextColor = Colors.white.withOpacity(0.9);
  static final Color _darkSubtitleColor = Colors.white.withOpacity(0.7);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: _lightPrimaryColor,
      scaffoldBackgroundColor: _lightBackgroundColor,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightPrimaryColor,
        brightness: Brightness.light,
        background: _lightBackgroundColor,
        surface: _lightCardColor,
        onBackground: _lightTextColor,
        onSurface: _lightTextColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightCardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _lightTextColor),
        titleTextStyle: TextStyle(
          color: _lightTextColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 1,
        color: _lightCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightBackgroundColor.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: _lightPrimaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: _lightSubtitleColor),
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
            color: _lightTextColor, fontWeight: FontWeight.bold, fontSize: 24),
        titleLarge: TextStyle(
            color: _lightTextColor, fontWeight: FontWeight.w600, fontSize: 20),
        bodyMedium: TextStyle(color: _lightTextColor, fontSize: 14),
        labelSmall: TextStyle(color: _lightSubtitleColor, fontSize: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _darkPrimaryColor,
      scaffoldBackgroundColor: _darkBackgroundColor,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: _darkPrimaryColor,
        brightness: Brightness.dark,
        background: _darkBackgroundColor,
        surface: _darkCardColor,
        onBackground: _darkTextColor,
        onSurface: _darkTextColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkCardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _darkTextColor),
        titleTextStyle: TextStyle(
          color: _darkTextColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 1,
        color: _darkCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkCardColor.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: _darkPrimaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: _darkSubtitleColor),
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
            color: _darkTextColor, fontWeight: FontWeight.bold, fontSize: 24),
        titleLarge: TextStyle(
            color: _darkTextColor, fontWeight: FontWeight.w600, fontSize: 20),
        bodyMedium: TextStyle(color: _darkTextColor, fontSize: 14),
        labelSmall: TextStyle(color: _darkSubtitleColor, fontSize: 12),
      ),
    );
  }
}
