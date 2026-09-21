import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/app_version_provider.dart';
import '../../core/theme/app_colors.dart';
import '../activities/application/activities_providers.dart';
import '../activities/domain/activity.dart';
import 'add_edit_activity_screen.dart';
import 'widgets/activity_list_tile.dart';
import 'widgets/notification_permission_card.dart';
import 'widgets/office_day_card.dart';
import 'widgets/theme_toggle_button.dart';
import 'widgets/trip_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _openAddEdit(BuildContext context, {Activity? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditActivityScreen(existing: existing)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);
    final version = ref.watch(appVersionProvider).value;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: context.colors.titlePurple,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const ThemeToggleButton(),
            ],
          ),
          const SizedBox(height: 20),
          const NotificationPermissionCard(),
          const OfficeDayCard(),
          const TripCard(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Activities', style: Theme.of(context).textTheme.titleLarge),
              FilledButton.tonalIcon(
                onPressed: () => _openAddEdit(context),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final activity in activities)
            ActivityListTile(
              activity: activity,
              onTap: () => _openAddEdit(context, existing: activity),
              onDelete: () => ref.read(activitiesProvider.notifier).remove(activity.id),
            ),
          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No activities yet — tap Add to create your first reminder.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.subtleText),
              ),
            ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              version == null ? 'Vital Loop' : 'Vital Loop v$version',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.subtleText),
            ),
          ),
        ],
      ),
    );
  }
}
