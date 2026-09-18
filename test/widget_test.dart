// Widget smoke test for Home. Hive needs real (temp-dir) file I/O rather
// than a mock, which hangs `pumpAndSettle`/`tester.pump()` under the fake
// async clock unless the pump sequence runs inside `tester.runAsync` — see
// the fixedwise-app-hive-widget-test-gotcha memory for the full story.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:vital_loop/core/storage/hive_boxes.dart';
import 'package:vital_loop/features/home/home_screen.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('vital_loop_test');
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

  testWidgets('Home shows the seeded default activities', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomeScreen())),
      );
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();
    });

    expect(find.text('Vital Loop'), findsOneWidget);
    expect(find.text('Water'), findsOneWidget);
    expect(find.text('Push-ups'), findsOneWidget);
    expect(find.text('Squats'), findsOneWidget);
  });
}
