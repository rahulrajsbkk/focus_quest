import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quest/core/services/haptic_service.dart';
import 'package:flutter_quest/core/theme/app_theme.dart';
import 'package:flutter_quest/core/widgets/theme_switcher.dart';
import 'package:flutter_quest/l10n/app_localizations.dart';
import 'package:flutter_quest/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'FocusQuest',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FocusQuest'),
          actions: const [
            ThemeSwitcherButton(),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to FocusQuest',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 32),
              const ThemeSwitcher(),
              const SizedBox(height: 32),
              FloatingActionButton(
                onPressed: () async {
                  // Sample usage of HapticService
                  await HapticService().selectionClick();
                },
                child: const Icon(Icons.touch_app),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
