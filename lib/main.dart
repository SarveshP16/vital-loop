import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notifications/notification_service.dart';
import 'core/notifications/reminder_scheduler.dart';
import 'core/router/app_router.dart';
import 'core/settings/office_days_provider.dart';
import 'core/settings/settings_repository.dart';
import 'core/settings/theme_mode_provider.dart';
import 'core/settings/trip_provider.dart';
import 'core/storage/hive_boxes.dart';
import 'core/theme/app_theme.dart';
import 'features/activities/application/activities_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBoxes.init();
  await NotificationService.init();

  final container = ProviderContainer();
  // Reading this here (before runApp) seeds the mockup's default activities
  // on first launch, so the very first scheduling pass below has them.
  final activities = container.read(activitiesProvider);

  final settings = SettingsRepository();
  if (!settings.getPermissionsRequested()) {
    await NotificationService.requestPermissions();
    await settings.setPermissionsRequested();
  }
  final logs = container.read(dailyLogsProvider.notifier);
  final officeDays = container.read(officeDaysProvider.notifier);
  final trip = container.read(tripProvider.notifier);
  await trip.markTodayIfOnTrip();
  await container.read(reminderSchedulerProvider).rescheduleToday(
        activities,
        logs.amountFor,
        (date) => officeDays.isOfficeDay(date) || trip.isTripDay(date),
      );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const VitalLoopApp(),
    ),
  );
}

class VitalLoopApp extends ConsumerStatefulWidget {
  const VitalLoopApp({super.key});

  @override
  ConsumerState<VitalLoopApp> createState() => _VitalLoopAppState();
}

class _VitalLoopAppState extends ConsumerState<VitalLoopApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reminders are only ever scheduled for "today" (see ReminderScheduler),
    // so resuming after midnight needs a fresh pass to schedule the new day.
    if (state == AppLifecycleState.resumed) {
      final activities = ref.read(activitiesProvider);
      final logs = ref.read(dailyLogsProvider.notifier);
      final officeDays = ref.read(officeDaysProvider.notifier);
      final trip = ref.read(tripProvider.notifier);
      trip.markTodayIfOnTrip().then((_) {
        ref.read(reminderSchedulerProvider).rescheduleToday(
              activities,
              logs.amountFor,
              (date) => officeDays.isOfficeDay(date) || trip.isTripDay(date),
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vital Loop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: appRouter,
      // Status/navigation bar icons follow the app theme, not the phone's —
      // otherwise dark icons vanish into the dark background.
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final icons = isDark ? Brightness.light : Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: icons,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: icons,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
