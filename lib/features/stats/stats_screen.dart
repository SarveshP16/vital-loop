import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../activities/application/activities_providers.dart';
import '../activities/application/derived_providers.dart';
import 'widgets/stat_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);
    final now = DateTime.now();

    return SafeArea(
      child: activities.isEmpty
          ? Center(
              child: Text(
                'Add an activity to see your stats.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: context.colors.subtleText),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Text(
                  'Stats',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: context.colors.titlePurple,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 20),
                for (final activity in activities) ...[
                  StatCard(activity: activity, total: periodTotalFor(ref, activity, now)),
                  const SizedBox(height: 16),
                ],
              ],
            ),
    );
  }
}
