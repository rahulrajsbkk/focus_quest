# 🎨 Theme System Documentation

## Overview

The FocusQuest theme system provides a comprehensive, ADHD-friendly color palette and theme configuration for both light and dark modes. The theme is designed with principles that reduce visual stress and cognitive load.

## Design Principles

### ADHD-Friendly Design

- **No pure black** (`#000000`) or **pure white** (`#FFFFFF`)
- **Soft pastels** and muted tones
- **Low contrast** for reduced visual stress
- **Rounded surfaces** (12-16px border radius)
- **Soft shadows** only (low elevation)
- **No harsh borders** or high-contrast edges

### Color Philosophy

- **Calm greens** and warm neutrals
- **Muted tones** throughout
- **Consistent color language** across light and dark themes

## File Structure

```
lib/core/theme/
├── app_colors.dart      # Color palette definitions
├── app_theme.dart       # ThemeData configurations
└── theme.md            # This documentation

lib/providers/
└── theme_provider.dart  # Riverpod state management & persistence
```

## Color Palette

### Light Theme

| Purpose        | Color                   | Hex Code  |
| -------------- | ----------------------- | --------- |
| Background     | Warm cream / soft beige | `#F5F1E8` |
| Primary        | Muted green             | `#7A9E7E` |
| Secondary      | Soft teal               | `#6B9A9A` |
| Surface        | Off-white               | `#FAF8F3` |
| Text Primary   | Charcoal                | `#2C2C2C` |
| Text Secondary | Muted gray              | `#6B6B6B` |
| Accent         | Soft yellow             | `#E8D5A3` |
| Success        | Calm green              | `#7A9E7E` |
| Warning        | Soft orange             | `#D4A574` |
| Error          | Muted red               | `#C97D7D` |

### Dark Theme

| Purpose        | Color                  | Hex Code  |
| -------------- | ---------------------- | --------- |
| Background     | Deep olive / warm dark | `#1E2A1F` |
| Primary        | Muted mint             | `#7A9E7E` |
| Secondary      | Soft teal              | `#6B9A9A` |
| Surface        | Dark gray-green        | `#2A352B` |
| Text Primary   | Warm off-white         | `#E8E5DF` |
| Text Secondary | Soft gray              | `#9A9A9A` |
| Accent         | Desaturated yellow     | `#B8A67A` |
| Success        | Calm green             | `#7A9E7E` |
| Warning        | Soft orange            | `#D4A574` |
| Error          | Muted red              | `#C97D7D` |

## Usage

### Basic Usage

The theme is automatically applied through the `ThemeProvider` in `main.dart`:

```dart
import 'package:flutter_quest/core/theme/app_theme.dart';
import 'package:flutter_quest/providers/theme_provider.dart';

// In your widget:
final themeMode = ref.watch(themeModeProvider);

MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: themeMode,
  // ...
)
```

### Accessing Theme Colors

```dart
// In a widget:
final colorScheme = Theme.of(context).colorScheme;

// Use colors:
Container(
  color: colorScheme.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: colorScheme.onPrimary),
  ),
)
```

### Direct Color Access

```dart
import 'package:flutter_quest/core/theme/app_colors.dart';

Container(
  color: AppColors.lightPrimary,
  // or
  color: AppColors.darkPrimary,
)
```

### Toggling Theme

```dart
import 'package:flutter_quest/providers/theme_provider.dart';

// Toggle between light and dark
ref.read(themeProvider.notifier).toggleTheme();

// Set specific theme
ref.read(themeProvider.notifier).setTheme(AppThemeMode.light);
ref.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
ref.read(themeProvider.notifier).setTheme(AppThemeMode.system);
```

## Theme Components

### Border Radius

- **Default**: `12.0px` - Used for buttons, inputs, and general UI elements
- **Large**: `16.0px` - Used for cards and containers
- **Small**: `8.0px` - Used for chips and small elements

### Shadows

All shadows use low opacity (0.05-0.3) to maintain the soft, ADHD-friendly aesthetic:

- Cards: `elevation: 2` with `opacity: 0.05`
- Buttons: `elevation: 2` with `opacity: 0.1`
- Dialogs: `elevation: 8` with `opacity: 0.1`

### Typography

The theme includes a comprehensive text theme with:

- Display styles (32px, 28px, 24px)
- Headline styles (20px)
- Title styles (18px, 16px)
- Body styles (16px, 14px, 12px)
- Label styles (14px)

All text colors respect the theme's contrast requirements.

## State Management

The theme system uses **Riverpod** for state management:

### Provider Structure

```dart
// Theme state provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(...);

// Theme mode provider (convenience)
final themeModeProvider = Provider<ThemeMode>(...);
```

### Persistence

Theme preferences are persisted using **Sembast** (via `PreferenceStorageService`):

- Theme mode is saved automatically when changed
- Theme preference survives app restarts
- Storage key: `theme_mode`

### Theme Modes

The app supports three theme modes:

- `AppThemeMode.light` - Always light theme
- `AppThemeMode.dark` - Always dark theme
- `AppThemeMode.system` - Follows system preference (default)

## Customization

### Adding New Colors

1. Add color constants to `app_colors.dart`:

```dart
static const Color lightNewColor = Color(0xFF...);
static const Color darkNewColor = Color(0xFF...);
```

2. Update `ColorScheme` in `app_colors.dart` if needed

3. Use the color in your widgets or add to `app_theme.dart` component themes

### Modifying Component Themes

Edit `app_theme.dart` to customize component themes:

```dart
// Example: Customize button theme
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    // Your customizations
  ),
),
```

## Testing

### Manual Testing

1. **Toggle Theme**: Use `themeProvider.notifier.toggleTheme()`
2. **Restart App**: Verify theme persists after restart
3. **System Theme**: Set to system mode and verify it follows device settings

### Test Checklist

- [ ] Theme toggles correctly between light and dark
- [ ] Theme persists after app restart
- [ ] System theme follows device preference
- [ ] All UI components respect theme colors
- [ ] No pure black or white colors appear
- [ ] Borders and shadows are soft and low-contrast
- [ ] Text is readable in both themes

## Best Practices

1. **Always use theme colors** - Don't hardcode colors, use `Theme.of(context).colorScheme`
2. **Respect theme mode** - Don't force light/dark, use the provider
3. **Test both themes** - Ensure UI works in both light and dark modes
4. **Maintain consistency** - Use the defined color palette, don't introduce new colors without updating the palette
5. **Follow border radius** - Use `AppTheme.borderRadius` constants for consistency

## Related Documentation

- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter Theme Documentation](https://docs.flutter.dev/cookbook/design/themes)
- [Sembast Documentation](https://pub.dev/packages/sembast)

## Architecture Notes

The theme system follows the project's local-first architecture:

- **State Management**: Riverpod (compile-time safe)
- **Persistence**: Sembast (local-first, offline-capable)
- **Separation of Concerns**: Colors, Theme, and Provider are separate files

This ensures the theme system is:

- ✅ Testable
- ✅ Maintainable
- ✅ Consistent with project architecture
- ✅ Offline-capable
