import 'package:flutter/material.dart';

class ActivityPalette {
  final Color background;
  final Color chip;
  final Color button;
  final Color chipIcon;

  const ActivityPalette({
    required this.background,
    required this.chip,
    required this.button,
    this.chipIcon = Colors.black,
  });
}

class AppColors {
  AppColors._();

  static const background = Color(0xFFFCF2E4);
  static const ink = Color(0xFF1A1A1A);

  static const titlePurple = Color(0xFFC2B2F0);

  static const streakBackground = Color(0xFFFAD7E2);
  static const streakForeground = Color(0xFFC81E56);

  static const nextUpBackground = Color(0xFFE4DEFB);
  static const nextUpChip = Color(0xFFB7A6EA);
  static const nextUpLabel = Color(0xFF7C5CFC);
  static const subtleText = Color(0xFF767676);

  static const navBackground = Color(0xFFFFFBF5);
  static const navActive = Color(0xFF8C6FF5);
  static const navInactive = Color(0xFF9C9C9C);
  static const navDivider = Color(0xFFECE3D4);

  /// Cycled through by an activity's `colorIndex`, in the mockup's order:
  /// Water (blue), Push-ups (orange), Squats (green), then extras.
  static const List<ActivityPalette> activityPalettes = [
    ActivityPalette(
      background: Color(0xFFCFE6FB),
      chip: Color(0xFF4F93EC),
      button: Color(0xFF57E0C9),
      chipIcon: Colors.white,
    ),
    ActivityPalette(
      background: Color(0xFFFBE3C4),
      chip: Color(0xFFF2A93C),
      button: Color(0xFF57E0C9),
    ),
    ActivityPalette(
      background: Color(0xFFC9F3DA),
      chip: Color(0xFF55D68C),
      button: Color(0xFFF2A93C),
    ),
    ActivityPalette(
      background: Color(0xFFE4DEFB),
      chip: Color(0xFF9B86F0),
      button: Color(0xFF57E0C9),
      chipIcon: Colors.white,
    ),
    ActivityPalette(
      background: Color(0xFFFBD9E6),
      chip: Color(0xFFF17FA0),
      button: Color(0xFF57E0C9),
    ),
    ActivityPalette(
      background: Color(0xFFCDEDEA),
      chip: Color(0xFF43BBAE),
      button: Color(0xFFF2A93C),
      chipIcon: Colors.white,
    ),
  ];

  static ActivityPalette paletteFor(int colorIndex) =>
      activityPalettes[colorIndex % activityPalettes.length];
}
