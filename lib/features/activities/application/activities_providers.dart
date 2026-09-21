import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/reminder_scheduler.dart';
import '../../../core/settings/office_days_provider.dart';
import '../../../core/settings/trip_provider.dart';
import '../../../core/storage/hive_boxes.dart';
import '../../../core/utils/date_keys.dart';
import '../data/activities_repository.dart';
import '../data/default_activities.dart';
import '../domain/activity.dart';
import '../domain/log_key.dart';

final activitiesRepositoryProvider = Provider<ActivitiesRepository>((ref) {
  return ActivitiesRepository();
});

/// The live list of activities, seeding the mockup's defaults on first run.
class ActivitiesNotifier extends Notifier<List<Activity>> {
  @override
  List<Activity> build() {
    final repo = ref.read(activitiesRepositoryProvider);
    var activities = repo.getAll();
    if (activities.isEmpty && !HiveBoxes.settingsBox.containsKey('seeded')) {
      for (final activity in defaultActivities()) {
        repo.save(activity);
      }
      HiveBoxes.settingsBox.put('seeded', true);
      activities = repo.getAll();
    }
    return activities;
  }

  Future<void> upsert(Activity activity) async {
    await ref.read(activitiesRepositoryProvider).save(activity);
    state = ref.read(activitiesRepositoryProvider).getAll();
    await _rescheduleToday();
  }

  Future<void> remove(String activityId) async {
    await ref.read(activitiesRepositoryProvider).delete(activityId);
    state = ref.read(activitiesRepositoryProvider).getAll();
    await _rescheduleToday();
  }

  Future<void> _rescheduleToday() async {
    final logs = ref.read(dailyLogsProvider.notifier);
    final officeDays = ref.read(officeDaysProvider.notifier);
    final trip = ref.read(tripProvider.notifier);
    await trip.markTodayIfOnTrip();
    await ref.read(reminderSchedulerProvider).rescheduleToday(
          state,
          logs.amountFor,
          (date) => officeDays.isOfficeDay(date) || trip.isTripDay(date),
        );
  }
}

final activitiesProvider = NotifierProvider<ActivitiesNotifier, List<Activity>>(
  ActivitiesNotifier.new,
);

/// In-memory mirror of the daily-logs Hive box, keyed the same way, so
/// widgets reactively rebuild the instant an amount is logged.
class DailyLogsNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() {
    return {
      for (final key in HiveBoxes.dailyLogsBox.keys)
        key as String: HiveBoxes.dailyLogsBox.get(key) ?? 0,
    };
  }

  int amountFor(String activityId, DateTime date) {
    return state[buildLogKey(activityId, date)] ?? 0;
  }

  int sumRange(String activityId, DateTime start, DateTime end) {
    var total = 0;
    var cursor = startOfDay(start);
    final last = startOfDay(end);
    while (!cursor.isAfter(last)) {
      total += amountFor(activityId, cursor);
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }
    return total;
  }

  /// Adds [amount] to [activityId]'s total for [date], never letting the
  /// total pass that activity's `dailyGoal` (a final +10 on 95/100 logs only
  /// 5). Does nothing once the goal is already met.
  Future<void> addAmount(String activityId, DateTime date, int amount) async {
    final key = buildLogKey(activityId, date);
    final current = amountFor(activityId, date);
    var newValue = current + amount;
    for (final activity in ref.read(activitiesProvider)) {
      if (activity.id == activityId && newValue > activity.dailyGoal) {
        newValue = activity.dailyGoal;
      }
    }
    if (newValue <= current) return;

    // State is updated before the awaited Hive write so a rapid second tap
    // already sees this total and can't slip past the cap.
    state = {...state, key: newValue};
    await ref.read(activitiesRepositoryProvider).setAmount(activityId, date, newValue);

    // Re-check today's reminders — if this log just met the daily goal, the
    // rest of today's already-scheduled reminders for this activity should
    // be cancelled rather than firing anyway.
    final activities = ref.read(activitiesProvider);
    final officeDays = ref.read(officeDaysProvider.notifier);
    final trip = ref.read(tripProvider.notifier);
    await ref.read(reminderSchedulerProvider).rescheduleToday(
          activities,
          amountFor,
          (date) => officeDays.isOfficeDay(date) || trip.isTripDay(date),
        );
  }
}

final dailyLogsProvider = NotifierProvider<DailyLogsNotifier, Map<String, int>>(
  DailyLogsNotifier.new,
);
