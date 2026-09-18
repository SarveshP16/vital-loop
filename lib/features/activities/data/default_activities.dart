import '../../../core/notifications/active_window.dart';
import '../domain/activity.dart';
import '../domain/stats_period.dart';

const _allDays = {1, 2, 3, 4, 5, 6, 7};
const _defaultWindow = ActiveWindow.defaultWindow; // 08:00–22:00

/// Seeded on first launch so Home matches the mockup out of the box.
/// Fully editable/deletable afterwards like any other activity.
List<Activity> defaultActivities() => [
      const Activity(
        id: 'default-water',
        iconEmoji: 'icon:water_drop',
        name: 'Water',
        unit: 'glasses',
        perReminderAmount: 1,
        dailyGoal: 8,
        activeWindow: _defaultWindow,
        statsPeriod: StatsPeriod.daily,
        remindDays: _allDays,
        colorIndex: 0,
        sortOrder: 0,
      ),
      const Activity(
        id: 'default-pushups',
        iconEmoji: 'icon:fitness_center',
        name: 'Push-ups',
        unit: 'reps',
        perReminderAmount: 10,
        dailyGoal: 100,
        activeWindow: _defaultWindow,
        statsPeriod: StatsPeriod.monthly,
        remindDays: _allDays,
        colorIndex: 1,
        sortOrder: 1,
      ),
      const Activity(
        id: 'default-squats',
        iconEmoji: 'icon:monitor_heart',
        name: 'Squats',
        unit: 'reps',
        perReminderAmount: 10,
        dailyGoal: 100,
        activeWindow: _defaultWindow,
        statsPeriod: StatsPeriod.monthly,
        remindDays: _allDays,
        colorIndex: 2,
        sortOrder: 2,
      ),
    ];
