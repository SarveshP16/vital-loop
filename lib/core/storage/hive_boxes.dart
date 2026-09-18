import 'package:hive_flutter/hive_flutter.dart';

/// Central Hive setup. No custom TypeAdapters — activities and logs are
/// stored as plain Maps/ints, which Hive supports natively.
class HiveBoxes {
  static const activities = 'activities';
  static const dailyLogs = 'daily_logs';
  static const settings = 'settings';

  static late Box<Map> activitiesBox;
  static late Box<int> dailyLogsBox;
  static late Box settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    activitiesBox = await Hive.openBox<Map>(activities);
    dailyLogsBox = await Hive.openBox<int>(dailyLogs);
    settingsBox = await Hive.openBox(settings);
  }
}
