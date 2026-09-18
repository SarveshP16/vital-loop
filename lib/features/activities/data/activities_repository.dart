import '../../../core/storage/hive_boxes.dart';
import '../../../core/utils/date_keys.dart';
import '../domain/activity.dart';
import '../domain/log_key.dart';

/// Reads/writes [Activity]s and their daily progress logs from Hive.
class ActivitiesRepository {
  List<Activity> getAll() {
    final activities = HiveBoxes.activitiesBox.values.map(Activity.fromMap).toList();
    activities.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return activities;
  }

  Future<void> save(Activity activity) async {
    await HiveBoxes.activitiesBox.put(activity.id, activity.toMap());
  }

  Future<void> delete(String activityId) async {
    await HiveBoxes.activitiesBox.delete(activityId);
    final keysToRemove = HiveBoxes.dailyLogsBox.keys
        .where((k) => (k as String).startsWith('$activityId|'))
        .toList();
    await HiveBoxes.dailyLogsBox.deleteAll(keysToRemove);
  }

  int nextSortOrder() {
    final activities = HiveBoxes.activitiesBox.values;
    if (activities.isEmpty) return 0;
    return activities.map((m) => m['sortOrder'] as int).reduce((a, b) => a > b ? a : b) + 1;
  }

  int getAmountFor(String activityId, DateTime date) {
    return HiveBoxes.dailyLogsBox.get(buildLogKey(activityId, date)) ?? 0;
  }

  Future<int> addAmount(String activityId, DateTime date, int amount) async {
    final key = buildLogKey(activityId, date);
    final newValue = (HiveBoxes.dailyLogsBox.get(key) ?? 0) + amount;
    await HiveBoxes.dailyLogsBox.put(key, newValue);
    return newValue;
  }

  /// Sum of logged amounts for [activityId] across [start]..[end] inclusive.
  int sumRange(String activityId, DateTime start, DateTime end) {
    var total = 0;
    var cursor = startOfDay(start);
    final last = startOfDay(end);
    while (!cursor.isAfter(last)) {
      total += getAmountFor(activityId, cursor);
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }
    return total;
  }

  /// Whether [activityId]'s daily goal was fully met on [date]. Days the
  /// activity wasn't scheduled to remind on don't count against a streak.
  bool metGoalOn(Activity activity, DateTime date) {
    if (!activity.remindDays.contains(date.weekday)) return true;
    return getAmountFor(activity.id, date) >= activity.dailyGoal;
  }
}
