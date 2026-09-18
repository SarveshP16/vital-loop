import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/icon_lookup.dart';

/// The colored rounded-square icon badge used throughout the app — renders
/// either a built-in Material icon (seeded activities) or a user-typed
/// emoji glyph.
class ActivityIconChip extends StatelessWidget {
  final String iconValue;
  final Color background;
  final Color iconColor;
  final double size;

  const ActivityIconChip({
    super.key,
    required this.iconValue,
    required this.background,
    this.iconColor = Colors.black,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final builtInIcon = resolveBuiltInIcon(iconValue);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      alignment: Alignment.center,
      child: builtInIcon != null
          ? Icon(builtInIcon, color: iconColor, size: size * 0.5)
          : Text(iconValue, style: TextStyle(fontSize: size * 0.48)),
    );
  }
}
