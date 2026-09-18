/// Formats [target] relative to [now] the way the mockup's "Next up" banner
/// does ("in 14 min").
String formatRelativeCountdown(DateTime target, DateTime now) {
  final diff = target.difference(now);
  if (diff.inMinutes < 1) return 'in <1 min';
  if (diff.inMinutes < 60) return 'in ${diff.inMinutes} min';
  if (diff.inHours < 24) {
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return minutes == 0 ? 'in ${hours}h' : 'in ${hours}h ${minutes}m';
  }
  const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final weekday = weekdayNames[target.weekday - 1];
  final hour12 = target.hour % 12 == 0 ? 12 : target.hour % 12;
  final minute = target.minute.toString().padLeft(2, '0');
  final period = target.hour < 12 ? 'AM' : 'PM';
  return '$weekday $hour12:$minute $period';
}
