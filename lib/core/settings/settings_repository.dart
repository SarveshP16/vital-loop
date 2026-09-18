import '../storage/hive_boxes.dart';

/// Small app-wide settings that aren't tied to any one activity.
class SettingsRepository {
  bool getPermissionsRequested() =>
      HiveBoxes.settingsBox.get('permissionsRequested', defaultValue: false) as bool;

  Future<void> setPermissionsRequested() async {
    await HiveBoxes.settingsBox.put('permissionsRequested', true);
  }
}
