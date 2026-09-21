import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/hive_boxes.dart';
import '../utils/date_keys.dart';

/// "On trip" mode — works like [OfficeDaysNotifier] (mutes reminders,
/// excludes days from Stats/streak) but does NOT auto-disable the next day;
/// the user must switch it off manually. Modelled as a persistent `enabled`
/// flag plus a growing history of dates it covered, rather than a single
/// on/off date: every time [markTodayIfOnTrip] runs (called alongside the
/// app's existing "refresh today" hooks — startup, resume, log, activity
/// edit) while `enabled` is true, today's date gets added to that history.
/// So a 4-day trip naturally accumulates 4 muted dates for Stats purposes.
/// Turning it off stops the history growing and un-mutes *today* (today's
/// date is removed) — earlier trip days stay excluded from Stats forever,
/// exactly like office days do.
class TripNotifier extends Notifier<({bool enabled, Set<String> days})> {
  @override
  ({bool enabled, Set<String> days}) build() {
    final enabled = HiveBoxes.settingsBox.get('onTripEnabled', defaultValue: false) as bool;
    final stored = HiveBoxes.settingsBox.get('tripDays', defaultValue: <dynamic>[]) as List;
    final days = stored.cast<String>().toSet();
    // Older builds left today's date behind when the switch was turned off,
    // so a switched-off trip could still mute today. Today is never a trip
    // day while the switch is off.
    if (!enabled) days.remove(dayKey(DateTime.now()));
    return (enabled: enabled, days: days);
  }

  bool get isEnabled => state.enabled;

  bool isTripDay(DateTime date) => state.days.contains(dayKey(date));

  Future<void> setEnabled(bool value) async {
    final todayKey = dayKey(DateTime.now());
    // Turning it off also drops today from the history — otherwise today
    // still counts as a trip day (Home keeps its "On trip" banner, reminders
    // stay muted, Stats keep excluding it) until midnight. Earlier days of
    // the trip stay recorded.
    final days = value ? {...state.days, todayKey} : ({...state.days}..remove(todayKey));
    state = (enabled: value, days: days);
    await HiveBoxes.settingsBox.put('onTripEnabled', value);
    await HiveBoxes.settingsBox.put('tripDays', days.toList());
  }

  Future<void> markTodayIfOnTrip() async {
    if (!state.enabled) return;
    final key = dayKey(DateTime.now());
    if (state.days.contains(key)) return;
    final days = {...state.days, key};
    state = (enabled: state.enabled, days: days);
    await HiveBoxes.settingsBox.put('tripDays', days.toList());
  }
}

final tripProvider = NotifierProvider<TripNotifier, ({bool enabled, Set<String> days})>(
  TripNotifier.new,
);
