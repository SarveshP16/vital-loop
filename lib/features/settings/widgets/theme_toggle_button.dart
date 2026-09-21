import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/theme_mode_provider.dart';
import '../../../core/theme/app_colors.dart';

/// Round sticker-style light/dark switch for the Settings header. Shows the
/// icon of the mode a tap will switch *to* (sun while dark, moon while light).
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Semantics(
      button: true,
      label: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      child: Tooltip(
        message: isDark ? 'Light mode' : 'Dark mode',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => ref.read(themeModeProvider.notifier).setDark(!isDark),
            customBorder: const CircleBorder(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.ink, width: 2),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: context.colors.ink,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
