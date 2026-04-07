import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0D0F14);
  static const surface = Color(0xFF13161D);
  static const surface2 = Color(0xFF1A1E28);
  static const border = Color(0x12FFFFFF);
  static const border2 = Color(0x21FFFFFF);
  static const text = Color(0xFFE8EAF0);
  static const muted = Color(0xFF6B7280);
  static const accent = Color(0xFF4ADE80);
  static const accentDim = Color(0x1F4ADE80);
  static const amber = Color(0xFFFBBF24);
  static const amberDim = Color(0x1FFBBF24);
  static const blue = Color(0xFF60A5FA);
  static const blueDim = Color(0x1A60A5FA);
  static const red = Color(0xFFF87171);
  static const redDim = Color(0x1AF87171);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.accent,
          onPrimary: AppColors.bg,
          secondary: AppColors.amber,
        ),
        fontFamily: 'Sora',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.text,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface2,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.accent),
          ),
          hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
          labelStyle: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.bg,
            textStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        dividerColor: AppColors.border,
      );
}
