import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/notifications/active_window.dart';
import '../../core/notifications/reminder_time_calculator.dart';
import '../../core/theme/app_colors.dart';
import '../activities/application/activities_providers.dart';
import '../activities/domain/activity.dart';
import '../activities/domain/stats_period.dart';
import 'widgets/active_window_picker.dart';
import 'widgets/day_of_week_selector.dart';
import 'widgets/emoji_icon_field.dart';
import 'widgets/stepper_field.dart';
import 'widgets/unit_dropdown.dart';

const _allDays = {1, 2, 3, 4, 5, 6, 7};
const _uuid = Uuid();

class AddEditActivityScreen extends ConsumerStatefulWidget {
  final Activity? existing;

  const AddEditActivityScreen({super.key, this.existing});

  @override
  ConsumerState<AddEditActivityScreen> createState() => _AddEditActivityScreenState();
}

class _AddEditActivityScreenState extends ConsumerState<AddEditActivityScreen> {
  late final TextEditingController _nameController;
  late String _iconEmoji;
  late String _unit;
  late int _perReminderAmount;
  late int _dailyGoal;
  late ActiveWindow _activeWindow;
  late StatsPeriod _statsPeriod;
  late Set<int> _remindDays;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _iconEmoji = existing?.iconEmoji ?? '🎯';
    _unit = existing?.unit ?? kPredefinedUnits.first;
    _perReminderAmount = existing?.perReminderAmount ?? 10;
    _dailyGoal = existing?.dailyGoal ?? 100;
    _activeWindow = existing?.activeWindow ?? ActiveWindow.defaultWindow;
    _statsPeriod = existing?.statsPeriod ?? StatsPeriod.daily;
    _remindDays = Set<int>.from(existing?.remindDays ?? _allDays);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// A throwaway [Activity] built from the current form fields, just to
  /// reuse the real scheduling math for the live "≈N reminders/day" summary.
  Activity get _draftActivity => Activity(
        id: 'draft',
        iconEmoji: _iconEmoji,
        name: _nameController.text,
        unit: _unit,
        perReminderAmount: _perReminderAmount,
        dailyGoal: _dailyGoal,
        activeWindow: _activeWindow,
        statsPeriod: _statsPeriod,
        remindDays: _remindDays,
        colorIndex: 0,
        sortOrder: 0,
      );

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the activity a name first.')),
      );
      return;
    }
    final repo = ref.read(activitiesRepositoryProvider);
    final existing = widget.existing;

    final activity = Activity(
      id: existing?.id ?? _uuid.v4(),
      iconEmoji: _iconEmoji,
      name: name,
      unit: _unit,
      perReminderAmount: _perReminderAmount,
      dailyGoal: _dailyGoal,
      activeWindow: _activeWindow,
      statsPeriod: _statsPeriod,
      remindDays: _remindDays,
      colorIndex: existing?.colorIndex ?? repo.getAll().length,
      sortOrder: existing?.sortOrder ?? repo.nextSortOrder(),
    );

    await ref.read(activitiesProvider.notifier).upsert(activity);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit activity' : 'New activity'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('Icon', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          EmojiIconField(value: _iconEmoji, onChanged: (v) => setState(() => _iconEmoji = v)),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Stretch'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          UnitDropdown(value: _unit, onChanged: (v) => setState(() => _unit = v)),
          const SizedBox(height: 20),
          StepperField(
            label: 'Amount per reminder',
            value: _perReminderAmount,
            min: 1,
            max: 500,
            onChanged: (v) => setState(() => _perReminderAmount = v),
          ),
          const SizedBox(height: 12),
          StepperField(
            label: 'Daily goal',
            value: _dailyGoal,
            min: 1,
            max: 5000,
            step: _dailyGoal >= 20 ? 10 : 1,
            onChanged: (v) => setState(() => _dailyGoal = v),
          ),
          const SizedBox(height: 20),
          Text('Active hours', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Reminders are spread evenly across this window each remind day, '
            'and stop for the day once the goal is met.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtleText),
          ),
          const SizedBox(height: 10),
          ActiveWindowPicker(window: _activeWindow, onChanged: (v) => setState(() => _activeWindow = v)),
          const SizedBox(height: 10),
          _ReminderSummary(activity: _draftActivity),
          const SizedBox(height: 20),
          Text('Show stats as', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          SegmentedButton<StatsPeriod>(
            segments: StatsPeriod.values
                .map((p) => ButtonSegment(value: p, label: Text(p.label)))
                .toList(),
            selected: {_statsPeriod},
            onSelectionChanged: (s) => setState(() => _statsPeriod = s.first),
          ),
          const SizedBox(height: 20),
          Text('Remind on', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          DayOfWeekSelector(selected: _remindDays, onChanged: (v) => setState(() => _remindDays = v)),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.navActive,
            ),
            child: Text(_isEditing ? 'Save changes' : 'Add activity'),
          ),
        ],
      ),
    );
  }
}

class _ReminderSummary extends StatelessWidget {
  final Activity activity;

  const _ReminderSummary({required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.activeWindow.endMinutes <= activity.activeWindow.startMinutes) {
      return Text(
        'Pick an end time after the start time.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.streakForeground),
      );
    }
    final count = reminderCountFor(activity);
    final totalMinutes = activity.activeWindow.endMinutes - activity.activeWindow.startMinutes;
    final stepMinutes = count <= 1 ? totalMinutes : (totalMinutes / count).round();
    final hours = stepMinutes ~/ 60;
    final minutes = stepMinutes % 60;
    final spacing = hours == 0
        ? '$minutes min'
        : (minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.nextUpBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Text(
        '≈$count reminder${count == 1 ? '' : 's'}/day, about every $spacing',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
