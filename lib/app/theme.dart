import 'package:flutter/material.dart';

class AppColors {
  static const Color bg = Color(0xFFF6FBF4);
  static const Color surface = Color(0xFFE3F0E2);
  static const Color primary = Color(0xFF2E6B3A);
  static const Color primaryDark = Color(0xFF1F4D2A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1B2B1F);
  static const Color textMuted = Color(0xFF5B6B5F);
  static const Color warning = Color(0xFFC77700);
  static const Color danger = Color(0xFFB3261E);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.primaryDark,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, color: AppColors.text, height: 1.5),
        bodyMedium: TextStyle(fontSize: 16, color: AppColors.text, height: 1.4),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
