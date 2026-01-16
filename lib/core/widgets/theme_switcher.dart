import 'package:flutter/material.dart';
import 'package:flutter_quest/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that allows users to toggle between light and dark themes.
///
/// This widget provides a simple switch/button interface to change the app theme.
/// It can be used in settings screens or app bars.
class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({
    super.key,
    this.showLabel = true,
    this.iconSize = 24.0,
  });

  /// Whether to show a label next to the switch
  final bool showLabel;

  /// Size of the theme icon
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(themeProvider);
    final isDark = appThemeMode == AppThemeMode.dark;

    return InkWell(
      onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              size: iconSize,
            ),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Text(
                isDark ? 'Dark' : 'Light',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(width: 8),
            Switch(
              value: isDark,
              onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact theme switcher button (icon only).
///
/// Useful for app bars or compact spaces.
class ThemeSwitcherButton extends ConsumerWidget {
  const ThemeSwitcherButton({
    super.key,
    this.iconSize = 24.0,
  });

  /// Size of the theme icon
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(themeProvider);
    final isDark = appThemeMode == AppThemeMode.dark;

    return IconButton(
      icon: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
        size: iconSize,
      ),
      tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
      onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
    );
  }
}
