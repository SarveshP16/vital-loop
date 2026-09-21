import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:vital_loop/core/settings/theme_mode_provider.dart';
import 'package:vital_loop/core/storage/hive_boxes.dart';
import 'package:vital_loop/core/theme/app_colors.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('vital_loop_test_theme');
    Hive.init(tempDir.path);
    HiveBoxes.settingsBox = await Hive.openBox('settings_theme_test');
  });

  setUp(() => HiveBoxes.settingsBox.clear());

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('defaults to light, and the choice survives a restart', () async {
    var container = ProviderContainer();
    expect(container.read(themeModeProvider), ThemeMode.light);

    await container.read(themeModeProvider.notifier).setDark(true);
    expect(container.read(themeModeProvider), ThemeMode.dark);
    container.dispose();

    // A fresh container rebuilds the notifier from Hive, like a relaunch.
    container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(themeModeProvider), ThemeMode.dark);

    await container.read(themeModeProvider.notifier).setDark(false);
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('dark palette covers every activity colour the light one does', () {
    expect(AppColors.dark.activityPalettes.length, AppColors.light.activityPalettes.length);
    // Text on bright chips/buttons must stay dark in both themes.
    expect(AppColors.dark.onAccent, AppColors.light.onAccent);
    // ...while general text/borders flip to light-on-dark.
    expect(AppColors.dark.ink.computeLuminance(), greaterThan(0.5));
    expect(AppColors.dark.background.computeLuminance(), lessThan(0.1));
  });
}
