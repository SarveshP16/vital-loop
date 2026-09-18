import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/activities/domain/activity.dart';
import '../utils/date_keys.dart';
import 'notification_service.dart';
import 'reminder_time_calculator.dart';

/// Schedules only *today's* remaining reminders for each activity — never a
/// repeating/evergreen alarm — because how many are left depends on today's
/// logged progress, which changes live. Call [rescheduleToday] again after
/// any log, and after any activity add/edit/delete; each call cancels
/// today's previously-scheduled ids for every activity first, so a goal
/// crossed mid-day cleanly drops the rest of today's reminders instead of
/// firing them anyway.
///
/// This intentionally only ever schedules for "today": tomorrow's progress
/// is unknown yet, so tomorrow's reminders get scheduled fresh next time the
/// app is opened on that day (the same "checked at app launch, not a true
/// background schedule" trade-off used for FixedWise's auto-backup).
class ReminderScheduler {
  Future<void> rescheduleToday(
    List<Activity> activities,
    int Function(String activityId, DateTime date) loggedAmountFor,
    bool Function(DateTime date) isMuted,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final muted = isMuted(today);

    for (final activity in activities) {
      final slots = reminderCountFor(activity);
      for (var slot = 0; slot < slots; slot++) {
        await NotificationService.cancel(_stableId(activity.id, today, slot));
      }

      // Office day / on trip: every activity's reminders stay cancelled for
      // today — never rescheduled — regardless of progress.
      if (muted) continue;

      if (loggedAmountFor(activity.id, today) >= activity.dailyGoal) continue;

      final occurrences = occurrencesOnDay(activity, today);
      for (var slot = 0; slot < occurrences.length; slot++) {
        final time = occurrences[slot];
        if (!time.isAfter(now)) continue;
        await NotificationService.scheduleOnce(
          id: _stableId(activity.id, today, slot),
          title: '${activity.name} time!',
          body: 'Time for ${activity.perReminderAmount} ${activity.unit} of ${activity.name}.',
          time: time,
        );
      }
    }
  }

  static int _stableId(String activityId, DateTime day, int slot) {
    return Object.hash(activityId, dayKey(day), slot) & 0x7FFFFFFF;
  }
}

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) => ReminderScheduler());
