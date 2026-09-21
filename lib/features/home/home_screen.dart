import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/office_days_provider.dart';
import '../../core/settings/trip_provider.dart';
import '../../core/theme/app_colors.dart';
import '../activities/application/activities_providers.dart';
import '../activities/application/derived_providers.dart';
import 'widgets/grid_activity_card.dart';
import 'widgets/muted_day_banner.dart';
import 'widgets/next_up_banner.dart';
import 'widgets/streak_pill.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);
    final nextUp = ref.watch(nextUpProvider);
    final streak = ref.watch(streakProvider);
    ref.watch(dailyLogsProvider); // subscribe to log changes so +amount taps rebuild this screen
    final logs = ref.read(dailyLogsProvider.notifier);
    final today = DateTime.now();
    ref.watch(officeDaysProvider);
    ref.watch(tripProvider);
    final isOnTrip = ref.read(tripProvider.notifier).isTripDay(today);
    final isOfficeDay = !isOnTrip && ref.read(officeDaysProvider.notifier).isOfficeDay(today);

    return SafeArea(
      child: activities.isEmpty
          ? const _EmptyHome()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vital Loop',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: context.colors.titlePurple,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    StreakPill(streak: streak),
                  ],
                ),
                const SizedBox(height: 20),
                if (isOnTrip) ...[
                  const MutedDayBanner(
                    emoji: '🧳',
                    title: 'On trip',
                    message: 'Reminders are muted and today won\'t count toward Stats.',
                  ),
                  const SizedBox(height: 20),
                ] else if (isOfficeDay) ...[
                  const MutedDayBanner(
                    emoji: '🏢',
                    title: 'Office day',
                    message: 'Reminders are muted and today won\'t count toward Stats.',
                  ),
                  const SizedBox(height: 20),
                ] else if (nextUp != null) ...[
                  NextUpBanner(info: nextUp),
                  const SizedBox(height: 20),
                ],
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return GridActivityCard(
                      activity: activity,
                      loggedAmount: logs.amountFor(activity.id, today),
                      onAdd: () => ref
                          .read(dailyLogsProvider.notifier)
                          .addAmount(activity.id, today, activity.perReminderAmount),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No activities yet.\nAdd one from Settings to get started.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: context.colors.subtleText),
        ),
      ),
    );
  }
}
