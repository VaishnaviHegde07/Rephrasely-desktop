import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/app_settings.dart';

class ThemeConfig {
  static ShadThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return _lightTheme();
      case AppThemeMode.dark:
        return _darkTheme();
      case AppThemeMode.neutral:
        return _neutralTheme();
      case AppThemeMode.ocean:
        return _oceanTheme();
      case AppThemeMode.sunset:
        return _sunsetTheme();
      case AppThemeMode.forest:
        return _forestTheme();
    }
  }

  static String getThemeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.neutral:
        return 'Neutral';
      case AppThemeMode.ocean:
        return 'Ocean';
      case AppThemeMode.sunset:
        return 'Sunset';
      case AppThemeMode.forest:
        return 'Forest';
    }
  }

  static String getThemeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Clean and bright, perfect for daytime';
      case AppThemeMode.dark:
        return 'Easy on the eyes in low light';
      case AppThemeMode.neutral:
        return 'Minimalist gray tones';
      case AppThemeMode.ocean:
        return 'Cool blues and teals';
      case AppThemeMode.sunset:
        return 'Warm oranges and purples';
      case AppThemeMode.forest:
        return 'Natural greens and earth tones';
    }
  }

  // Light Theme (Default)
  static ShadThemeData _lightTheme() {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadNeutralColorScheme.light(),
    );
  }

  // Dark Theme
  static ShadThemeData _darkTheme() {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: const ShadNeutralColorScheme.dark(),
    );
  }

  // Neutral Theme (Minimalist Gray)
  static ShadThemeData _neutralTheme() {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadSlateColorScheme.light(),
    );
  }

  // Ocean Theme (Blues & Teals)
  static ShadThemeData _oceanTheme() {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadBlueColorScheme.light(
        primary: Color(0xFF0284C7), // Sky blue
        primaryForeground: Color(0xFFFFFFFF),
      ),
    );
  }

  // Sunset Theme (Warm colors)
  static ShadThemeData _sunsetTheme() {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadOrangeColorScheme.light(
        primary: Color(0xFFEA580C), // Orange
        primaryForeground: Color(0xFFFFFFFF),
      ),
    );
  }

  // Forest Theme (Greens)
  static ShadThemeData _forestTheme() {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadGreenColorScheme.light(
        primary: Color(0xFF16A34A), // Green
        primaryForeground: Color(0xFFFFFFFF),
      ),
    );
  }
}
