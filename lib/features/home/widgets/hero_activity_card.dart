import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/activity_icon_chip.dart';
import '../../../core/widgets/hard_shadow_box.dart';
import '../../activities/domain/activity.dart';

/// The full-width "Water" style card: icon + name + a round add button up
/// top, a progress bar and "X of Y unit" caption below. Shown for the first
/// activity in the list; every other activity uses [GridActivityCard].
class HeroActivityCard extends StatelessWidget {
  final Activity activity;
  final int loggedAmount;
  final VoidCallback onAdd;

  const HeroActivityCard({
    super.key,
    required this.activity,
    required this.loggedAmount,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.paletteFor(activity.colorIndex);
    final progress = activity.dailyGoal <= 0
        ? 0.0
        : (loggedAmount / activity.dailyGoal).clamp(0.0, 1.0);

    return HardShadowBox(
      color: palette.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ActivityIconChip(
                iconValue: activity.iconEmoji,
                background: palette.chip,
                iconColor: palette.chipIcon,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  activity.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.ink,
                      ),
                ),
              ),
              _AddCircleButton(color: palette.button, onTap: onAdd),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(color: palette.chip),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$loggedAmount of ${activity.dailyGoal} ${activity.unit}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.subtleText,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _AddCircleButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _AddCircleButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.ink, width: 2),
          ),
          child: const Icon(Icons.add, color: AppColors.ink, size: 26),
        ),
      ),
    );
  }
}
