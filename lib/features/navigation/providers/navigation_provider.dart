import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier for managing app navigation state
class NavigationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Sets the current navigation index.
  // ignore: use_setters_to_change_properties
  void setIndex(int index) {
    state = index;
  }
}

/// Provider for app navigation state
final navigationProvider = NotifierProvider<NavigationNotifier, int>(
  NavigationNotifier.new,
);
