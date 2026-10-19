import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF081411);
  static const surface = Color(0xFF12231F);
  static const raised = Color(0xFF192D27);
  static const text = Color(0xFFF2F8F4);
  static const muted = Color(0xFF96ABA2);
  static const lime = Color(0xFFB5FF70);
  static const mint = Color(0xFF55DFC3);
  static const coral = Color(0xFFE69A8D);
  static const radius = 24.0;
  static const gap = 16.0;
}

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  scrollbarTheme: ScrollbarThemeData(
    thickness: const WidgetStatePropertyAll(4),
    radius: const Radius.circular(8),
    thumbColor: WidgetStatePropertyAll(AppColors.muted.withValues(alpha: .4)),
    crossAxisMargin: 8,
  ),
  colorScheme: const ColorScheme.dark(
    primary: AppColors.lime,
    secondary: AppColors.mint,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    error: AppColors.coral,
  ),
  textTheme: const TextTheme(
    displaySmall: TextStyle(
      fontSize: 40,
      height: 1.08,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.8,
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      height: 1.15,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
    ),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w600,
    ),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.5),
    labelSmall: TextStyle(
      fontSize: 11,
      letterSpacing: 2,
      fontWeight: FontWeight.w700,
    ),
  ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    hintStyle: const TextStyle(color: AppColors.muted),
    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.raised),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.lime),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
);
