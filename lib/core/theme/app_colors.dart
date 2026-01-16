import 'package:flutter/material.dart';

/// Color palette for FocusQuest app.
///
/// Designed with ADHD-friendly principles:
/// - No pure black (#000000) or pure white (#FFFFFF)
/// - Soft pastels and muted tones
/// - Low contrast for reduced visual stress
/// - Calm greens and warm neutrals
class AppColors {
  AppColors._();

  // ==================== Light Theme Colors ====================

  /// Warm cream / soft beige background
  static const Color lightBackground = Color(0xFFF5F1E8);

  /// Muted green - primary action color
  static const Color lightPrimary = Color(0xFF7A9E7E);

  /// Soft teal - secondary actions
  static const Color lightSecondary = Color(0xFF6B9A9A);

  /// Off-white surface for cards and elevated elements
  static const Color lightSurface = Color(0xFFFAF8F3);

  /// Charcoal - primary text color
  static const Color lightTextPrimary = Color(0xFF2C2C2C);

  /// Muted gray - secondary text
  static const Color lightTextSecondary = Color(0xFF6B6B6B);

  /// Soft yellow - accent highlights
  static const Color lightAccent = Color(0xFFE8D5A3);

  /// Calm green - success states
  static const Color lightSuccess = Color(0xFF7A9E7E);

  /// Soft orange - warning states
  static const Color lightWarning = Color(0xFFD4A574);

  /// Muted red - error states
  static const Color lightError = Color(0xFFC97D7D);

  // ==================== Dark Theme Colors ====================

  /// Deep olive / warm dark background
  static const Color darkBackground = Color(0xFF1E2A1F);

  /// Muted mint - primary action color
  static const Color darkPrimary = Color(0xFF7A9E7E);

  /// Soft teal - secondary actions
  static const Color darkSecondary = Color(0xFF6B9A9A);

  /// Dark gray-green surface for cards
  static const Color darkSurface = Color(0xFF2A352B);

  /// Warm off-white - primary text
  static const Color darkTextPrimary = Color(0xFFE8E5DF);

  /// Soft gray - secondary text
  static const Color darkTextSecondary = Color(0xFF9A9A9A);

  /// Desaturated yellow - accent highlights
  static const Color darkAccent = Color(0xFFB8A67A);

  /// Calm green - success states
  static const Color darkSuccess = Color(0xFF7A9E7E);

  /// Soft orange - warning states
  static const Color darkWarning = Color(0xFFD4A574);

  /// Muted red - error states
  static const Color darkError = Color(0xFFC97D7D);

  // ==================== Helper Methods ====================

  /// Get color scheme for light theme
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: lightPrimary,
    onPrimary: lightSurface,
    secondary: lightSecondary,
    onSecondary: lightSurface,
    tertiary: lightAccent,
    onTertiary: lightTextPrimary,
    error: lightError,
    onError: lightSurface,
    surface: lightSurface,
    onSurface: lightTextPrimary,
    surfaceContainerHighest: lightTextSecondary,
  );

  /// Get color scheme for dark theme
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: darkPrimary,
    onPrimary: darkSurface,
    secondary: darkSecondary,
    onSecondary: darkSurface,
    tertiary: darkAccent,
    onTertiary: darkTextPrimary,
    error: darkError,
    onError: darkSurface,
    surface: darkSurface,
    onSurface: darkTextPrimary,
    surfaceContainerHighest: darkTextSecondary,
  );
}
