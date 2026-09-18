import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/hard_shadow_box.dart';

/// Replaces [NextUpBanner] on Home whenever reminders are muted for today
/// (office day or on trip) — shared shell for both banners so they only
/// differ by emoji/title/message.
class MutedDayBanner extends StatelessWidget {
  final String emoji;
  final String title;
  final String message;

  const MutedDayBanner({super.key, required this.emoji, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return HardShadowBox(
      color: const Color(0xFFFBE3C4),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.subtleText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
