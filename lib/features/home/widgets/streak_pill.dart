import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StreakPill extends StatelessWidget {
  final int streak;

  const StreakPill({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.streakBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: AppColors.streakForeground, size: 20),
          const SizedBox(width: 6),
          Text(
            '$streak',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.streakForeground,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
