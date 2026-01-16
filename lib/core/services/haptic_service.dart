import 'package:flutter_vibrate/flutter_vibrate.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();

  factory HapticService() {
    return _instance;
  }

  HapticService._internal();

  Future<void> vibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    if (canVibrate) {
      Vibrate.vibrate();
    }
  }

  Future<void> lightImpact() async {
    bool canVibrate = await Vibrate.canVibrate;
    if (canVibrate) {
      Vibrate.feedback(FeedbackType.light);
    }
  }

  Future<void> mediumImpact() async {
    bool canVibrate = await Vibrate.canVibrate;
    if (canVibrate) {
      Vibrate.feedback(FeedbackType.medium);
    }
  }

  Future<void> heavyImpact() async {
    bool canVibrate = await Vibrate.canVibrate;
    if (canVibrate) {
      Vibrate.feedback(FeedbackType.heavy);
    }
  }

  Future<void> selectionClick() async {
    bool canVibrate = await Vibrate.canVibrate;
    if (canVibrate) {
      Vibrate.feedback(FeedbackType.selection);
    }
  }
}
