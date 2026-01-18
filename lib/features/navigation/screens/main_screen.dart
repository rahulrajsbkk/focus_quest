import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_quest/core/services/haptic_service.dart';
import 'package:focus_quest/core/theme/app_colors.dart';
import 'package:focus_quest/features/tasks/providers/quest_provider.dart';
import 'package:focus_quest/features/tasks/screens/home_screen.dart';
import 'package:focus_quest/features/tasks/widgets/add_quest_sheet.dart';
import 'package:focus_quest/models/quest.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PlaceholderScreen(title: 'Calendar'),
    const HomeScreen(), // Dummy for center button
    const PlaceholderScreen(title: 'Timer'),
    const PlaceholderScreen(title: 'Profile'),
  ];

  void _onItemTapped(int index) {
    if (index == 2) return; // Dedicated for FAB
    setState(() {
      _selectedIndex = index;
    });
    unawaited(HapticService().selectionClick());
  }

  Future<void> _showAddQuestSheet() async {
    final result = await showModalBottomSheet<Quest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddQuestSheet(),
    );

    if (result != null) {
      await ref.read(questListProvider.notifier).addQuest(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined),
              _buildNavItem(
                1,
                Icons.calendar_today_rounded,
                Icons.calendar_today_outlined,
              ),
              _buildCenterButton(theme),
              _buildNavItem(3, Icons.timer_rounded, Icons.timer_outlined),
              _buildNavItem(
                4,
                Icons.person_rounded,
                Icons.person_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton(ThemeData theme) {
    return GestureDetector(
      onTap: () async {
        await HapticService().lightImpact();
        await _showAddQuestSheet();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData selectedIcon,
    IconData unselectedIcon,
  ) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final color = isSelected
        ? (theme.brightness == Brightness.light
              ? AppColors.lightHighlight
              : AppColors.darkHighlight)
        : theme.colorScheme.onSurface.withValues(alpha: 0.4);

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              title == 'Timer'
                  ? Icons.timer_outlined
                  : Icons.person_outline_rounded,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Coming Soon: $title',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
