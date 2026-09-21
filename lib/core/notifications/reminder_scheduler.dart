import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/activities/domain/activity.dart';
import '../utils/date_keys.dart';
import 'notification_service.dart';
import 'reminder_time_calculator.dart';

/// Schedules only *today's* remaining reminders for each activity — never a
/// repeating/evergreen alarm — because how many are left depends on today's
/// logged progress, which changes live. Call [rescheduleToday] again after
/// any log, and after any activity add/edit/delete; each call cancels
/// *every* pending/shown reminder first and then schedules from scratch, so
/// a goal crossed mid-day cleanly drops the rest of today's reminders, and an
/// edited or deleted activity can't leave stale alarms behind (cancelling by
/// "the ids the current activity would use" missed those and produced
/// duplicate notifications).
///
/// This intentionally only ever schedules for "today": tomorrow's progress
/// is unknown yet, so tomorrow's reminders get scheduled fresh next time the
/// app is opened on that day (the same "checked at app launch, not a true
/// background schedule" trade-off used for FixedWise's auto-backup).
class ReminderScheduler {
  /// Runs are chained so overlapping triggers (launch + resume, a log tap
  /// during a settings change, ...) can't interleave their cancel/schedule
  /// steps; the last one queued always sees the latest state and wins.
  Future<void> _queue = Future.value();

  Future<void> rescheduleToday(
    List<Activity> activities,
    int Function(String activityId, DateTime date) loggedAmountFor,
    bool Function(DateTime date) isMuted,
  ) {
    final run = _queue.then((_) => _reschedule(activities, loggedAmountFor, isMuted));
    _queue = run.catchError((Object _) {});
    return run;
  }

  Future<void> _reschedule(
    List<Activity> activities,
    int Function(String activityId, DateTime date) loggedAmountFor,
    bool Function(DateTime date) isMuted,
  ) async {
    await NotificationService.cancelAll();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Office day / on trip: every activity's reminders stay cancelled for
    // today — never rescheduled — regardless of progress.
    if (isMuted(today)) return;

    for (final activity in activities) {
      if (loggedAmountFor(activity.id, today) >= activity.dailyGoal) continue;

      final occurrences = occurrencesOnDay(activity, today);
      final window = activity.activeWindow;
      final windowEnd = DateTime(today.year, today.month, today.day, 0, window.endMinutes);

      for (var slot = 0; slot < occurrences.length; slot++) {
        final time = occurrences[slot];
        if (!time.isAfter(now)) continue;

        // Each reminder expires when the activity's next one is due (the last
        // one at the window's close), so an unacknowledged reminder is
        // replaced by the newer one instead of stacking up in the shade.
        final expiry = slot + 1 < occurrences.length ? occurrences[slot + 1] : windowEnd;

        await NotificationService.scheduleOnce(
          id: _stableId(activity.id, today, slot),
          title: '${activity.name} time!',
          body: 'Time for ${activity.perReminderAmount} ${activity.unit} of ${activity.name}.',
          time: time,
          timeoutAfter: expiry.isAfter(time) ? expiry.difference(time) : null,
        );
      }
    }
  }

  /// FNV-1a over the slot's identity. Deliberately not `Object.hash`/
  /// `hashCode`, which Dart doesn't promise to keep stable across builds.
  static int _stableId(String activityId, DateTime day, int slot) {
    var hash = 0x811c9dc5;
    for (final unit in '$activityId|${dayKey(day)}|$slot'.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xFFFFFFFF;
    }
    return hash & 0x7FFFFFFF;
  }
}

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) => ReminderScheduler());
