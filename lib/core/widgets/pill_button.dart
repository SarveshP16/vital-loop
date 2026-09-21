import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The rounded, black-bordered "+10" / "+" action button used on activity
/// cards. Deliberately not a Material [ElevatedButton] — flat fill, thick
/// border, no elevation, matching the mockup's sticker look.
class PillButton extends StatelessWidget {
  final String label;
  final Color color;
  /// Null disables the button (dimmed, no ripple).
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const PillButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.ink, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: context.colors.onAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
