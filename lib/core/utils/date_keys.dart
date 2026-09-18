/// Formats a [DateTime] as a `yyyy-MM-dd` key, ignoring time-of-day.
String dayKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime startOfWeek(DateTime date) {
  // Monday-first week. Calendar-field subtraction (not Duration) so this
  // stays exact across DST transitions.
  final offset = date.weekday - DateTime.monday;
  return DateTime(date.year, date.month, date.day - offset);
}

DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

int daysInMonth(DateTime date) => DateTime(date.year, date.month + 1, 0).day;
