import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _seedColor = Color(0xFF001E61);

  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
        surfaceContainerLowest: const Color(0xFFF8FAFC), // FFF on cards, but Scaffold is slightly blue-ish grey
        surface: Colors.white,
      ),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Light grey-blue background from design
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent, // No indicator shape, just icon/text color change
        selectedIconTheme: IconThemeData(color: _seedColor, size: 24),
        unselectedIconTheme: IconThemeData(color: Color(0xFF64748B), size: 24),
        selectedLabelTextStyle: TextStyle(
          color: _seedColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        labelType: NavigationRailLabelType.all,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: _seedColor,
        secondarySelectedColor: _seedColor,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        secondaryLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        pressElevation: 0,
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(Colors.white),
        side: WidgetStateProperty.all(
          const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        hintStyle: WidgetStateProperty.all(
          const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _seedColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }
}
