import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/relative_time.dart';
import '../../../core/widgets/activity_icon_chip.dart';
import '../../../core/widgets/hard_shadow_box.dart';
import '../../activities/application/derived_providers.dart';

class NextUpBanner extends StatelessWidget {
  final NextUpInfo info;

  const NextUpBanner({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final activity = info.activity;
    return HardShadowBox(
      color: AppColors.nextUpBackground,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const ActivityIconChip(
            iconValue: 'icon:clock',
            background: AppColors.nextUpChip,
            iconColor: Colors.white,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT UP',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.nextUpLabel,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${activity.name} · ${activity.perReminderAmount} ${activity.unit}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formatRelativeCountdown(info.time, DateTime.now()),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtleText,
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
