enum StatsPeriod {
  daily,
  weekly,
  monthly;

  String get label => switch (this) {
        StatsPeriod.daily => 'Daily',
        StatsPeriod.weekly => 'Weekly',
        StatsPeriod.monthly => 'Monthly',
      };

  static StatsPeriod fromName(String name) =>
      StatsPeriod.values.firstWhere((p) => p.name == name, orElse: () => StatsPeriod.daily);
}
