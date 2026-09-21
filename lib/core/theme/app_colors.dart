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

/// The app's colour tokens, registered on [ThemeData.extensions] so they swap
/// with light/dark mode. Read them with `context.colors`.
///
/// A few tokens exist purely because one hard-coded colour can't serve both
/// themes: [ink] is the *foreground* colour (text, borders — dark in light
/// mode, light in dark mode), so text/icons that sit on the bright, fixed
/// accent colours (chips, action buttons) use [onAccent] instead, and the
/// hard offset shadow is its own [shadow] token.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color ink;
  final Color onAccent;
  final Color shadow;
  final Color surface;
  final Color surfaceDisabled;

  final Color titlePurple;

  final Color streakBackground;
  final Color streakForeground;

  final Color nextUpBackground;
  final Color nextUpChip;
  final Color nextUpLabel;
  final Color subtleText;

  final Color warningBackground;
  final Color deleteBackground;

  final Color navBackground;
  final Color navActive;
  final Color navInactive;
  final Color navDivider;

  /// Cycled through by an activity's `colorIndex`, in the mockup's order:
  /// Water (blue), Push-ups (orange), Squats (green), then extras.
  final List<ActivityPalette> activityPalettes;

  const AppColors({
    required this.background,
    required this.ink,
    required this.onAccent,
    required this.shadow,
    required this.surface,
    required this.surfaceDisabled,
    required this.titlePurple,
    required this.streakBackground,
    required this.streakForeground,
    required this.nextUpBackground,
    required this.nextUpChip,
    required this.nextUpLabel,
    required this.subtleText,
    required this.warningBackground,
    required this.deleteBackground,
    required this.navBackground,
    required this.navActive,
    required this.navInactive,
    required this.navDivider,
    required this.activityPalettes,
  });

  static const light = AppColors(
    background: Color(0xFFFCF2E4),
    ink: Color(0xFF1A1A1A),
    onAccent: Color(0xFF1A1A1A),
    shadow: Color(0xFF1A1A1A),
    surface: Colors.white,
    surfaceDisabled: Color(0xFFF0EBE0),
    titlePurple: Color(0xFFC2B2F0),
    streakBackground: Color(0xFFFAD7E2),
    streakForeground: Color(0xFFC81E56),
    nextUpBackground: Color(0xFFE4DEFB),
    nextUpChip: Color(0xFFB7A6EA),
    nextUpLabel: Color(0xFF7C5CFC),
    subtleText: Color(0xFF767676),
    warningBackground: Color(0xFFFBE3C4),
    deleteBackground: Color(0xFFF7B2B2),
    navBackground: Color(0xFFFFFBF5),
    navActive: Color(0xFF8C6FF5),
    navInactive: Color(0xFF9C9C9C),
    navDivider: Color(0xFFECE3D4),
    activityPalettes: [
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
    ],
  );

  /// Same hues as [light] but with deep tinted card backgrounds; the bright
  /// chip/button accents are kept so each activity stays recognisable.
  static const dark = AppColors(
    background: Color(0xFF15121B),
    ink: Color(0xFFF3EEE6),
    onAccent: Color(0xFF1A1A1A),
    shadow: Color(0xFF000000),
    surface: Color(0xFF221E2C),
    surfaceDisabled: Color(0xFF2B2736),
    titlePurple: Color(0xFFC2B2F0),
    streakBackground: Color(0xFF4A2233),
    streakForeground: Color(0xFFFF6B9A),
    nextUpBackground: Color(0xFF2E2848),
    nextUpChip: Color(0xFFB7A6EA),
    nextUpLabel: Color(0xFFB3A0FF),
    subtleText: Color(0xFFA9A4B3),
    warningBackground: Color(0xFF4A3520),
    deleteBackground: Color(0xFF6B2C2C),
    navBackground: Color(0xFF1C1825),
    navActive: Color(0xFF8C6FF5),
    navInactive: Color(0xFF8A8694),
    navDivider: Color(0xFF2E2A3A),
    activityPalettes: [
      ActivityPalette(
        background: Color(0xFF1F3550),
        chip: Color(0xFF4F93EC),
        button: Color(0xFF57E0C9),
        chipIcon: Colors.white,
      ),
      ActivityPalette(
        background: Color(0xFF4A3520),
        chip: Color(0xFFF2A93C),
        button: Color(0xFF57E0C9),
      ),
      ActivityPalette(
        background: Color(0xFF1E4232),
        chip: Color(0xFF55D68C),
        button: Color(0xFFF2A93C),
      ),
      ActivityPalette(
        background: Color(0xFF33294F),
        chip: Color(0xFF9B86F0),
        button: Color(0xFF57E0C9),
        chipIcon: Colors.white,
      ),
      ActivityPalette(
        background: Color(0xFF4A2535),
        chip: Color(0xFFF17FA0),
        button: Color(0xFF57E0C9),
      ),
      ActivityPalette(
        background: Color(0xFF1D4240),
        chip: Color(0xFF43BBAE),
        button: Color(0xFFF2A93C),
        chipIcon: Colors.white,
      ),
    ],
  );

  /// Falls back to [light] when no theme has registered the extension (e.g. a
  /// bare `MaterialApp` in a widget test).
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  ActivityPalette paletteFor(int colorIndex) =>
      activityPalettes[colorIndex % activityPalettes.length];

  @override
  AppColors copyWith() => this;

  // Both sets are fixed; Flutter's short theme cross-fade just snaps at the
  // halfway point rather than blending every token.
  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => AppColors.of(this);
}
