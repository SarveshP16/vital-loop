import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => SettingsRepository());
