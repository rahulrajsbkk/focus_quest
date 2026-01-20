import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get date => state;

  set date(DateTime date) {
    state = date;
  }
}
