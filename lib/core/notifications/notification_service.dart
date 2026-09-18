import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around `flutter_local_notifications`.
///
/// Two Android manifest gotchas this app must not repeat (hit before on
/// Pulse and FixedWise): `flutter_local_notifications` does NOT self-register
/// `ScheduledNotificationReceiver`/`ScheduledNotificationBootReceiver` via
/// manifest merging, so both must be declared explicitly in
/// AndroidManifest.xml, and `AndroidScheduleMode.inexactAllowWhileIdle` can
/// silently never fire once Android freezes the app — always schedule
/// `exactAllowWhileIdle`, which needs `SCHEDULE_EXACT_ALARM` declared plus a
/// one-time user grant.
class NotificationService {
  NotificationService._();

  static const channelId = 'vital_loop_reminders';
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Falls back to tz.local's default (UTC) if the platform lookup fails;
      // reminders would then fire at the wrong wall-clock time but not crash.
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: initSettings);

    const channel = AndroidNotificationChannel(
      channelId,
      'Activity reminders',
      description: 'Nudges to drink water, move, and hit your daily goals',
      importance: Importance.high,
    );
    await _android?.createNotificationChannel(channel);

    _initialized = true;
  }

  static AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  static Future<void> requestPermissions() async {
    await _android?.requestNotificationsPermission();
    await _android?.requestExactAlarmsPermission();
  }

  static Future<bool> canScheduleExact() async {
    return await _android?.canScheduleExactNotifications() ?? false;
  }

  static Future<void> requestExactAlarmPermission() async {
    await _android?.requestExactAlarmsPermission();
  }

  /// Schedules a single one-off notification at [time]. Does nothing if
  /// [time] is already in the past (the reminder scheduler only ever passes
  /// still-upcoming times, but this is a safe no-op either way).
  static Future<void> scheduleOnce({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final scheduledDate = tz.TZDateTime.from(time, tz.local);
    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: scheduledDate,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Activity reminders',
          channelDescription: 'Nudges to drink water, move, and hit your daily goals',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancel(int id) => _plugin.cancel(id: id);

  static Future<void> cancelAll() => _plugin.cancelAll();
}
