import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/activity_icon_chip.dart';
import '../../../core/widgets/hard_shadow_box.dart';
import '../../../core/widgets/pill_button.dart';
import '../../activities/domain/activity.dart';

/// The square "Push-ups" / "Squats" style card used for every activity
/// after the first (see [HeroActivityCard]).
class GridActivityCard extends StatelessWidget {
  final Activity activity;
  final int loggedAmount;
  final VoidCallback onAdd;

  const GridActivityCard({
    super.key,
    required this.activity,
    required this.loggedAmount,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.paletteFor(activity.colorIndex);
    return HardShadowBox(
      color: palette.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ActivityIconChip(
            iconValue: activity.iconEmoji,
            background: palette.chip,
            iconColor: palette.chipIcon,
          ),
          const SizedBox(height: 12),
          Text(
            activity.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$loggedAmount',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                TextSpan(
                  text: '/${activity.dailyGoal}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.subtleText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PillButton(
            label: '+${activity.perReminderAmount}',
            color: palette.button,
            onTap: onAdd,
          ),
        ],
      ),
    );
  }
}
