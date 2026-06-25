import 'package:flutter/material.dart';

class AppTheme {
  // ── Core backgrounds ──────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0A0C);
  static const Color cardBackground = Color(0xFF161618);
  static const Color cardBorder = Color(0xFF242426);

  // ── Text ──────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF8E8E93);

  // ── Accent colours ────────────────────────────────────────────────────
  static const Color teamAAccent = Color(0xFF3B82F6); // blue
  static const Color teamBAccent = Color(0xFFEF4444); // red
  static const Color betButtonActive = Color(0xFF10B981); // green

  // ── Gradients ─────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Card decoration ───────────────────────────────────────────────────
  static BoxDecoration cardDecoration({
    Color? borderColor,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? cardBorder, width: 1),
    );
  }

  // ── Theme data ────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: background,
        primary: teamAAccent,
        secondary: betButtonActive,
        error: teamBAccent,
      ),
      fontFamily: 'SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: teamAAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: teamBAccent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teamAAccent,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardBackground,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
