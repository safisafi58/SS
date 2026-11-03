/// Theme: Dark Premium — Dark Navy, Purple, Electric Blue.
library;

import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0A0E21); // dark navy
  static const Color surface = Color(0xFF141936);
  static const Color surfaceHigh = Color(0xFF1D2447);
  static const Color primary = Color(0xFF7C4DFF); // purple
  static const Color accent = Color(0xFF2979FF); // electric blue
  static const Color textPrimary = Color(0xFFEDEFFF);
  static const Color textSecondary = Color(0xFF9FA8DA);
  static const Color divider = Color(0xFF232A4D);
  static const Color danger = Color(0xFFFF5252);
  static const Color success = Color(0xFF00E676);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );
}

class AppTheme {
  static ThemeData get darkPremium {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(0.25),
        labelTextStyle: WidgetStatePropertyAll(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerColor: AppColors.divider,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }
}
