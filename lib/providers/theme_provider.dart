import 'package:flutter/material.dart';
import 'package:flutter_quest/core/services/preference_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme mode preference key for storage
const String _themeModeKey = 'theme_mode';

/// Theme mode state
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Extension to convert AppThemeMode to ThemeMode
extension AppThemeModeExtension on AppThemeMode {
  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Theme notifier using Riverpod's Notifier
class ThemeNotifier extends Notifier<AppThemeMode> {
  late final PreferenceStorageService _storage;

  @override
  AppThemeMode build() {
    _storage = PreferenceStorageService();
    // Load theme asynchronously after initialization (fire-and-forget)
    // ignore: discarded_futures, intentional async initialization
    _loadTheme();
    return AppThemeMode.system;
  }

  /// Load theme preference from storage
  Future<void> _loadTheme() async {
    try {
      final savedMode = await _storage.getString(_themeModeKey);
      if (savedMode != null) {
        state = AppThemeMode.values.firstWhere(
          (m) => m.name == savedMode,
          orElse: () => AppThemeMode.system,
        );
      }
    } on Exception {
      // If loading fails, use system default
      state = AppThemeMode.system;
    }
  }

  /// Get current mode
  AppThemeMode get mode => state;

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newMode = state == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    await setTheme(newMode);
  }

  /// Set theme mode
  Future<void> setTheme(AppThemeMode mode) async {
    try {
      await _storage.setString(_themeModeKey, mode.name);
      state = mode;
    } on Exception {
      // If saving fails, still update state
      state = mode;
    }
  }

  /// Set theme to system default
  Future<void> setSystemTheme() async {
    await setTheme(AppThemeMode.system);
  }
}

/// Theme provider using NotifierProvider for proper reactivity
final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(
  ThemeNotifier.new,
);

/// Helper provider to get ThemeMode from AppThemeMode
final themeModeProvider = Provider<ThemeMode>((ref) {
  final appThemeMode = ref.watch(themeProvider);
  return appThemeMode.toThemeMode();
});
