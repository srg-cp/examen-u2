import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const fontFamily = 'sans-serif';
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      surface: AppColors.background,
    ).copyWith(primary: AppColors.ink, onPrimary: Colors.white);
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTheme.fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.4,
          height: 1.12,
          color: AppColors.ink,
        ),
        headlineMedium: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.18,
          color: AppColors.ink,
        ),
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: AppColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: AppColors.secondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.secondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.45,
          color: AppColors.secondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 76,
        titleTextStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: AppColors.ink,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF24282A),
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 60),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

abstract final class AppColors {
  static const background = Colors.white;
  static const ink = Color(0xFF111111);
  static const secondary = Color(0xFF747781);
  static const green = Color(0xFF137B50);
  static const mint = Color(0xFFE0F2E5);
  static const peach = Color(0xFFF5E9E0);
  static const divider = Color(0xFFE4E9E2);
  static const surface = Colors.white;
}
