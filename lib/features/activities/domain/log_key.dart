import '../../../core/utils/date_keys.dart';

String buildLogKey(String activityId, DateTime date) => '$activityId|${dayKey(date)}';

String activityIdFromLogKey(String key) => key.split('|').first;
