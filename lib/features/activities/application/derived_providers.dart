import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/reminder_time_calculator.dart';
import '../../../core/settings/office_days_provider.dart';
import '../../../core/settings/trip_provider.dart';
import '../../../core/utils/date_keys.dart';
import '../domain/activity.dart';
import '../domain/stats_period.dart';
import 'activities_providers.dart';

class NextUpInfo {
  final Activity activity;
  final DateTime time;
  const NextUpInfo({required this.activity, required this.time});
}

/// The single soonest upcoming reminder across every activity, for Home's
/// "Next up" banner. A muted day (office day or on trip) counts as "already
/// done" for that date, so it's skipped just like a day whose goal was
/// already met — the banner never promises a reminder the scheduler has
/// actually muted.
final nextUpProvider = Provider<NextUpInfo?>((ref) {
  final activities = ref.watch(activitiesProvider);
  ref.watch(dailyLogsProvider);
  ref.watch(officeDaysProvider);
  ref.watch(tripProvider);
  final logs = ref.read(dailyLogsProvider.notifier);
  final officeDays = ref.read(officeDaysProvider.notifier);
  final trip = ref.read(tripProvider.notifier);
  final now = DateTime.now();

  bool isMuted(DateTime date) => officeDays.isOfficeDay(date) || trip.isTripDay(date);

  NextUpInfo? best;
  for (final activity in activities) {
    final occurrence = nextOccurrence(activity, now, (date) {
      if (isMuted(date)) return activity.dailyGoal;
      return logs.amountFor(activity.id, date);
    });
    if (occurrence == null) continue;
    if (best == null || occurrence.isBefore(best.time)) {
      best = NextUpInfo(activity: activity, time: occurrence);
    }
  }
  return best;
});

/// Consecutive days (ending today or yesterday) where every activity
/// scheduled to remind that weekday had its daily goal fully met. A muted
/// day (office day or on trip) never breaks the streak, the same way a
/// non-remind day doesn't.
final streakProvider = Provider<int>((ref) {
  final activities = ref.watch(activitiesProvider);
  ref.watch(dailyLogsProvider);
  ref.watch(officeDaysProvider);
  ref.watch(tripProvider);
  if (activities.isEmpty) return 0;
  final logs = ref.read(dailyLogsProvider.notifier);
  final officeDays = ref.read(officeDaysProvider.notifier);
  final trip = ref.read(tripProvider.notifier);

  bool allMetOn(DateTime date) {
    if (officeDays.isOfficeDay(date) || trip.isTripDay(date)) return true;
    return activities.every((a) {
      if (!a.remindDays.contains(date.weekday)) return true;
      return logs.amountFor(a.id, date) >= a.dailyGoal;
    });
  }

  final today = DateTime.now();
  var streak = allMetOn(today) ? 1 : 0;
  var cursor = DateTime(today.year, today.month, today.day - 1);
  var safety = 0;
  while (allMetOn(cursor) && safety < 3650) {
    streak++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    safety++;
  }
  return streak;
});

/// The real logged total for [activity] over its own chosen stats period, as
/// of [now] — muted days (office day or on trip) are excluded entirely from
/// the sum, not counted as zero-but-present.
int periodTotalFor(WidgetRef ref, Activity activity, DateTime now) {
  ref.watch(dailyLogsProvider);
  ref.watch(officeDaysProvider);
  ref.watch(tripProvider);
  final logs = ref.read(dailyLogsProvider.notifier);
  final officeDays = ref.read(officeDaysProvider.notifier);
  final trip = ref.read(tripProvider.notifier);

  bool isMuted(DateTime date) => officeDays.isOfficeDay(date) || trip.isTripDay(date);

  int sumExcludingMutedDays(DateTime start, DateTime end) {
    var total = 0;
    var cursor = startOfDay(start);
    final last = startOfDay(end);
    while (!cursor.isAfter(last)) {
      if (!isMuted(cursor)) {
        total += logs.amountFor(activity.id, cursor);
      }
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }
    return total;
  }

  return switch (activity.statsPeriod) {
    StatsPeriod.daily => isMuted(now) ? 0 : logs.amountFor(activity.id, now),
    StatsPeriod.weekly => sumExcludingMutedDays(startOfWeek(now), now),
    StatsPeriod.monthly => sumExcludingMutedDays(startOfMonth(now), now),
  };
}
