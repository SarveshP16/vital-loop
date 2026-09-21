import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/trip_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../activities/application/reminder_refresh.dart';

/// Multi-day mute switch — same effect as [OfficeDayCard] (mutes reminders,
/// excludes days from Stats/streak) but does NOT auto-disable; the user
/// turns it off manually once the trip is over.
class TripCard extends ConsumerWidget {
  const TripCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider);
    final tripNotifier = ref.read(tripProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.ink, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('On trip', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Mutes all reminders and excludes days from Stats until '
                  'you turn this off — it does not disable itself.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.subtleText),
                ),
              ],
            ),
          ),
          Switch(
            value: trip.enabled,
            onChanged: (value) async {
              await tripNotifier.setEnabled(value);
              await refreshMutedReminders(ref);
            },
          ),
        ],
      ),
    );
  }
}
