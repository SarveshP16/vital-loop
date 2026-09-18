import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/hive_boxes.dart';
import '../utils/date_keys.dart';

/// Dates (as `yyyy-MM-dd` keys) the user has marked an "office day" —
/// reminders are muted and the date is excluded from Stats/streak for that
/// day only. Storing a history (not just a single "is it on right now" flag)
/// is what makes it "automatically disable next day": the toggle just
/// reflects whether *today's* key is in the set, so a fresh day is off by
/// default with no cron/reset job needed, while past office days are still
/// remembered for accurate historical stats.
class OfficeDaysNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final stored = HiveBoxes.settingsBox.get('officeDays', defaultValue: <dynamic>[]) as List;
    return stored.cast<String>().toSet();
  }

  bool isOfficeDay(DateTime date) => state.contains(dayKey(date));

  Future<void> setOfficeDay(DateTime date, bool value) async {
    final key = dayKey(date);
    final next = Set<String>.from(state);
    value ? next.add(key) : next.remove(key);
    state = next;
    await HiveBoxes.settingsBox.put('officeDays', next.toList());
  }
}

final officeDaysProvider = NotifierProvider<OfficeDaysNotifier, Set<String>>(
  OfficeDaysNotifier.new,
);
