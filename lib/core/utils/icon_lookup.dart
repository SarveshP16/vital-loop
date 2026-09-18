import 'package:flutter/material.dart';

/// Built-in seeded activities store an `icon:<key>` token instead of an
/// emoji glyph so their chip renders a crisp Material icon like the mockup.
/// User-added activities just store a real emoji character.
const Map<String, IconData> kBuiltInIcons = {
  'water_drop': Icons.water_drop,
  'fitness_center': Icons.fitness_center,
  'monitor_heart': Icons.monitor_heart,
  'clock': Icons.access_time_filled,
};

bool isBuiltInIconToken(String value) => value.startsWith('icon:');

IconData? resolveBuiltInIcon(String value) {
  if (!isBuiltInIconToken(value)) return null;
  return kBuiltInIcons[value.substring('icon:'.length)];
}
