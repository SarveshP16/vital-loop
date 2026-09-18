import 'package:flutter/material.dart';

import '../../../core/notifications/reminder_time_calculator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/activity_icon_chip.dart';
import '../../activities/domain/activity.dart';

class ActivityListTile extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ActivityListTile({
    super.key,
    required this.activity,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.paletteFor(activity.colorIndex);
    return Dismissible(
      key: ValueKey(activity.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF7B2B2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.ink),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              ActivityIconChip(
                iconValue: activity.iconEmoji,
                background: palette.chip,
                iconColor: palette.chipIcon,
                size: 44,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${activity.activeWindow.start.format(context)}–${activity.activeWindow.end.format(context)}'
                      ' · ~${reminderCountFor(activity)}/day · ${activity.perReminderAmount} ${activity.unit} · goal ${activity.dailyGoal}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtleText),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.subtleText),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete activity?'),
        content: Text('This removes "${activity.name}" and its logged history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    return result ?? false;
  }
}
