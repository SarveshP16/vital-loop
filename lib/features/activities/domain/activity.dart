import '../../../core/notifications/active_window.dart';
import 'stats_period.dart';

/// A recurring goal/reminder the user wants nudges for (water, push-ups, ...).
///
/// [iconEmoji] is the glyph shown in the colored icon chip — either a real
/// emoji the user typed, or a Material icon codepoint string for the built-in
/// seeded activities (see `default_activities.dart`).
///
/// There's no explicit "remind every N hours" field: how many reminders fire
/// each day is derived from [dailyGoal] / [perReminderAmount] (see
/// `reminder_time_calculator.dart`'s `reminderCountFor`), spaced evenly
/// across [activeWindow].
class Activity {
  final String id;
  final String iconEmoji;
  final String name;
  final String unit;
  final int perReminderAmount;
  final int dailyGoal;
  final ActiveWindow activeWindow;
  final StatsPeriod statsPeriod;

  /// 1 (Monday) .. 7 (Sunday), matching [DateTime.weekday].
  final Set<int> remindDays;
  final int colorIndex;
  final int sortOrder;

  const Activity({
    required this.id,
    required this.iconEmoji,
    required this.name,
    required this.unit,
    required this.perReminderAmount,
    required this.dailyGoal,
    required this.activeWindow,
    required this.statsPeriod,
    required this.remindDays,
    required this.colorIndex,
    required this.sortOrder,
  });

  Activity copyWith({
    String? iconEmoji,
    String? name,
    String? unit,
    int? perReminderAmount,
    int? dailyGoal,
    ActiveWindow? activeWindow,
    StatsPeriod? statsPeriod,
    Set<int>? remindDays,
    int? colorIndex,
    int? sortOrder,
  }) {
    return Activity(
      id: id,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      perReminderAmount: perReminderAmount ?? this.perReminderAmount,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      activeWindow: activeWindow ?? this.activeWindow,
      statsPeriod: statsPeriod ?? this.statsPeriod,
      remindDays: remindDays ?? this.remindDays,
      colorIndex: colorIndex ?? this.colorIndex,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'iconEmoji': iconEmoji,
        'name': name,
        'unit': unit,
        'perReminderAmount': perReminderAmount,
        'dailyGoal': dailyGoal,
        'activeWindow': activeWindow.toMap(),
        'statsPeriod': statsPeriod.name,
        'remindDays': remindDays.toList(),
        'colorIndex': colorIndex,
        'sortOrder': sortOrder,
      };

  factory Activity.fromMap(Map<dynamic, dynamic> map) => Activity(
        id: map['id'] as String,
        iconEmoji: map['iconEmoji'] as String,
        name: map['name'] as String,
        unit: map['unit'] as String,
        perReminderAmount: map['perReminderAmount'] as int,
        dailyGoal: map['dailyGoal'] as int,
        activeWindow: ActiveWindow.fromMap(Map<String, dynamic>.from(map['activeWindow'] as Map)),
        statsPeriod: StatsPeriod.fromName(map['statsPeriod'] as String),
        remindDays: (map['remindDays'] as List).cast<int>().toSet(),
        colorIndex: map['colorIndex'] as int,
        sortOrder: map['sortOrder'] as int,
      );
}
