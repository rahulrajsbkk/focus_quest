import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for providing haptic feedback across the app.
///
/// Uses Flutter's built-in HapticFeedback for cross-platform compatibility.
class HapticService {
  factory HapticService() {
    return _instance;
  }

  HapticService._internal();

  static final HapticService _instance = HapticService._internal();

  /// Trigger a basic vibration (medium impact).
  Future<void> vibrate() async {
    try {
      await HapticFeedback.mediumImpact();
    } on PlatformException catch (e) {
      debugPrint('HapticService: Failed to vibrate: $e');
    }
  }

  /// Trigger a light haptic impact.
  Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } on PlatformException catch (e) {
      debugPrint('HapticService: Failed to provide light impact: $e');
    }
  }

  /// Trigger a medium haptic impact.
  Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } on PlatformException catch (e) {
      debugPrint('HapticService: Failed to provide medium impact: $e');
    }
  }

  /// Trigger a heavy haptic impact.
  Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } on PlatformException catch (e) {
      debugPrint('HapticService: Failed to provide heavy impact: $e');
    }
  }

  /// Trigger a selection click haptic.
  Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } on PlatformException catch (e) {
      debugPrint('HapticService: Failed to provide selection click: $e');
    }
  }
}
