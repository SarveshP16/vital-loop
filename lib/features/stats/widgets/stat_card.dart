import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/activity_icon_chip.dart';
import '../../../core/widgets/hard_shadow_box.dart';
import '../../activities/domain/activity.dart';
import '../../activities/domain/stats_period.dart';

class StatCard extends StatelessWidget {
  final Activity activity;
  final int total;

  const StatCard({super.key, required this.activity, required this.total});

  String get _label => switch (activity.statsPeriod) {
        StatsPeriod.daily => 'Daily ${activity.name}',
        StatsPeriod.weekly => 'Total ${activity.name} (Weekly)',
        StatsPeriod.monthly => 'Total ${activity.name} (Monthly)',
      };

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.paletteFor(activity.colorIndex);
    return HardShadowBox(
      color: palette.background,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          ActivityIconChip(
            iconValue: activity.iconEmoji,
            background: palette.chip,
            iconColor: palette.chipIcon,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total ${activity.unit}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
