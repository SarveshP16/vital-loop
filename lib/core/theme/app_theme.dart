import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light, AppColors.light);
  static ThemeData get dark => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.navActive,
        brightness: brightness,
      ),
      extensions: [colors],
    );

    final headingFont = GoogleFonts.baloo2TextTheme(base.textTheme);
    final bodyFont = GoogleFonts.nunitoTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: bodyFont.copyWith(
        displayLarge: headingFont.displayLarge,
        displayMedium: headingFont.displayMedium,
        displaySmall: headingFont.displaySmall,
        headlineLarge: headingFont.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
        headlineMedium: headingFont.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        headlineSmall: headingFont.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: headingFont.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.ink,
        elevation: 0,
      ),
    );
  }
}
