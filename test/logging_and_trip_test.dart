// Covers the daily-goal cap on logging and the "On trip" toggle un-muting
// today. Uses real temp-dir Hive boxes, same as widget_test.dart.
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:vital_loop/core/notifications/reminder_scheduler.dart';
import 'package:vital_loop/core/settings/trip_provider.dart';
import 'package:vital_loop/core/storage/hive_boxes.dart';
import 'package:vital_loop/features/activities/application/activities_providers.dart';

/// Swallows scheduling so tests don't hit the notifications platform channel.
class _NoopScheduler extends ReminderScheduler {
  @override
  Future<void> rescheduleToday(activities, loggedAmountFor, isMuted) async {}
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('vital_loop_test_log');
    Hive.init(tempDir.path);
    HiveBoxes.activitiesBox = await Hive.openBox<Map>(HiveBoxes.activities);
    HiveBoxes.dailyLogsBox = await Hive.openBox<int>(HiveBoxes.dailyLogs);
    HiveBoxes.settingsBox = await Hive.openBox(HiveBoxes.settings);
  });

  setUp(() async {
    await HiveBoxes.activitiesBox.clear();
    await HiveBoxes.dailyLogsBox.clear();
    await HiveBoxes.settingsBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [reminderSchedulerProvider.overrideWithValue(_NoopScheduler())],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('daily goal cap', () {
    test('logging never passes the goal and the last add is trimmed', () async {
      final container = makeContainer();
      final pushups = container
          .read(activitiesProvider)
          .firstWhere((a) => a.id == 'default-pushups'); // 10 per reminder, goal 100
      final logs = container.read(dailyLogsProvider.notifier);
      final today = DateTime.now();

      for (var i = 0; i < 15; i++) {
        await logs.addAmount(pushups.id, today, pushups.perReminderAmount);
      }
      expect(logs.amountFor(pushups.id, today), 100);

      // Persisted value matches too.
      expect(container.read(activitiesRepositoryProvider).getAmountFor(pushups.id, today), 100);
    });

    test('a non-multiple goal is trimmed to exactly the goal', () async {
      final container = makeContainer();
      final water = container.read(activitiesProvider).firstWhere((a) => a.id == 'default-water');
      await container.read(activitiesProvider.notifier).upsert(
            water.copyWith(perReminderAmount: 3, dailyGoal: 8),
          );
      final logs = container.read(dailyLogsProvider.notifier);
      final today = DateTime.now();

      for (var i = 0; i < 5; i++) {
        await logs.addAmount(water.id, today, 3);
      }
      expect(logs.amountFor(water.id, today), 8);
    });

    test('rapid double taps cannot slip past the cap', () async {
      final container = makeContainer();
      final logs = container.read(dailyLogsProvider.notifier);
      final today = DateTime.now();

      // Fired without awaiting in between, like fast taps on the + button.
      await Future.wait([
        for (var i = 0; i < 20; i++) logs.addAmount('default-pushups', today, 10),
      ]);
      expect(logs.amountFor('default-pushups', today), 100);
    });
  });

  group('on trip toggle', () {
    test('turning it off un-mutes today but keeps earlier trip days', () async {
      final container = makeContainer();
      final trip = container.read(tripProvider.notifier);
      final today = DateTime.now();
      final earlier = DateTime(today.year, today.month, today.day - 2);

      await trip.setEnabled(true);
      // Simulate a trip that started two days ago.
      await HiveBoxes.settingsBox.put('tripDays', ['${earlier.year}-'
          '${earlier.month.toString().padLeft(2, '0')}-'
          '${earlier.day.toString().padLeft(2, '0')}', ...container.read(tripProvider).days]);
      container.invalidate(tripProvider);
      final reloaded = container.read(tripProvider.notifier);
      expect(reloaded.isTripDay(today), isTrue);

      await reloaded.setEnabled(false);

      expect(reloaded.isTripDay(today), isFalse);
      expect(reloaded.isTripDay(earlier), isTrue);
      expect(container.read(tripProvider).enabled, isFalse);

      // Survives a restart (state rebuilt from Hive).
      container.invalidate(tripProvider);
      expect(container.read(tripProvider.notifier).isTripDay(today), isFalse);
    });

    test('a stale today left by an older build is ignored while switched off', () async {
      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      await HiveBoxes.settingsBox.put('onTripEnabled', false);
      await HiveBoxes.settingsBox.put('tripDays', [todayKey]);

      final container = makeContainer();
      expect(container.read(tripProvider.notifier).isTripDay(now), isFalse);
    });

    test('does not re-mute today after being switched off', () async {
      final container = makeContainer();
      final trip = container.read(tripProvider.notifier);

      await trip.setEnabled(true);
      await trip.setEnabled(false);
      await trip.markTodayIfOnTrip();

      expect(trip.isTripDay(DateTime.now()), isFalse);
    });
  });
}
