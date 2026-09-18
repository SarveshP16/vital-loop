import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/reminder_scheduler.dart';
import '../../../core/settings/office_days_provider.dart';
import '../../../core/settings/trip_provider.dart';
import 'activities_providers.dart';

/// Re-checks today's reminders against the current office-day/trip mute
/// state. Shared by both mute toggles' `onChanged` handlers so they don't
/// duplicate the same provider wiring.
Future<void> refreshMutedReminders(WidgetRef ref) async {
  final activities = ref.read(activitiesProvider);
  final logs = ref.read(dailyLogsProvider.notifier);
  final officeDays = ref.read(officeDaysProvider.notifier);
  final trip = ref.read(tripProvider.notifier);
  await ref.read(reminderSchedulerProvider).rescheduleToday(
        activities,
        logs.amountFor,
        (date) => officeDays.isOfficeDay(date) || trip.isTripDay(date),
      );
}
