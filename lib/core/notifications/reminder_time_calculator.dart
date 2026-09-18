import '../../features/activities/domain/activity.dart';

/// How many reminders [activity] needs per day, derived from its daily goal
/// and per-reminder amount rather than a user-set interval — e.g. a 100
/// daily goal at 10 per reminder needs 10 reminders. Always at least 1.
int reminderCountFor(Activity activity) {
  if (activity.perReminderAmount <= 0 || activity.dailyGoal <= 0) return 1;
  final count = (activity.dailyGoal / activity.perReminderAmount).ceil();
  return count.clamp(1, 96);
}

/// [activity]'s reminders on the calendar day [date], evenly spaced across
/// its active window starting at the window's open time. Wall-clock times
/// are built via the `DateTime(y, m, d, h, min)` constructor (never
/// `Duration` arithmetic) so a DST transition on [date] can't shift them.
List<DateTime> occurrencesOnDay(Activity activity, DateTime date) {
  if (!activity.remindDays.contains(date.weekday)) return [];
  final window = activity.activeWindow;
  final totalMinutes = window.endMinutes - window.startMinutes;
  if (totalMinutes <= 0) return [];

  final count = reminderCountFor(activity);
  final step = totalMinutes / count;
  return List.generate(count, (i) {
    final minutesOfDay = window.startMinutes + (step * i).round();
    return DateTime(date.year, date.month, date.day, minutesOfDay ~/ 60, minutesOfDay % 60);
  });
}

/// The next occurrence strictly after [now], searching up to two weeks out
/// and skipping any day [loggedAmountOn] reports as already at/over the
/// daily goal (so a finished day shows no further "next up" reminders).
DateTime? nextOccurrence(
  Activity activity,
  DateTime now,
  int Function(DateTime date) loggedAmountOn,
) {
  for (var i = 0; i < 14; i++) {
    final day = DateTime(now.year, now.month, now.day + i);
    if (loggedAmountOn(day) >= activity.dailyGoal) continue;
    for (final occurrence in occurrencesOnDay(activity, day)) {
      if (occurrence.isAfter(now)) return occurrence;
    }
  }
  return null;
}
