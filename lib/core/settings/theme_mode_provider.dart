import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/hive_boxes.dart';

/// Light/dark choice, remembered across launches. Defaults to light (the
/// app's original look) until the user flips the toggle in Settings.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'darkMode';

  @override
  ThemeMode build() {
    final dark = HiveBoxes.settingsBox.get(_key, defaultValue: false) as bool;
    return dark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setDark(bool value) async {
    state = value ? ThemeMode.dark : ThemeMode.light;
    await HiveBoxes.settingsBox.put(_key, value);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
