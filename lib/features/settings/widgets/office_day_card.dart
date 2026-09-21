import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/office_days_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../activities/application/reminder_refresh.dart';

/// One-day mute switch: today only, resets itself tomorrow (see
/// [OfficeDaysNotifier] for why no separate reset job is needed).
class OfficeDayCard extends ConsumerWidget {
  const OfficeDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(officeDaysProvider);
    final officeDays = ref.read(officeDaysProvider.notifier);
    final today = DateTime.now();
    final isOn = officeDays.isOfficeDay(today);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                Text('Office day', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Mutes all reminders and excludes today from Stats. '
                  'Turns itself off again tomorrow.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.subtleText),
                ),
              ],
            ),
          ),
          Switch(
            value: isOn,
            onChanged: (value) async {
              await officeDays.setOfficeDay(today, value);
              await refreshMutedReminders(ref);
            },
          ),
        ],
      ),
    );
  }
}
