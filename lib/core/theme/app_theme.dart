import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navActive,
        brightness: Brightness.light,
      ),
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
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
    );
  }
}
