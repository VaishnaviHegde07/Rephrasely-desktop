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
      colorScheme: const ShadSlateColorScheme.light(
        background: Color(0xFFF8F9FA), // Very light gray background
        foreground: Color(0xFF111827), // Deep charcoal for text
        card: Color(0xFFFFFFFF), // Pure white cards
        cardForeground: Color(0xFF111827),
        popover: Color(0xFFFFFFFF),
        popoverForeground: Color(0xFF111827),
        primary: Color(0xFF475569), // Slate gray
        primaryForeground: Color(0xFFFFFFFF),
        secondary: Color(0xFFF1F5F9), // Light slate
        secondaryForeground: Color(0xFF334155),
        muted: Color(0xFFF1F5F9), // Softer muted background
        mutedForeground: Color(0xFF64748B), // Medium gray for muted text
        accent: Color(0xFFF1F5F9),
        accentForeground: Color(0xFF334155),
        border: Color(0xFFE2E8F0), // Subtle border
        input: Color(0xFFE2E8F0),
        ring: Color(0xFF94A3B8),
      ),
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
