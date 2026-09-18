import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The mockup's signature look: thick black border, fully rounded corners,
/// and a solid (non-blurred) offset shadow instead of a soft Material one.
class HardShadowBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final double borderWidth;
  final Offset shadowOffset;
  final EdgeInsetsGeometry? padding;

  const HardShadowBox({
    super.key,
    required this.child,
    required this.color,
    this.radius = 28,
    this.borderWidth = 2.5,
    this.shadowOffset = const Offset(5, 5),
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink,
            offset: shadowOffset,
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
          border: Border.all(color: AppColors.ink, width: borderWidth),
        ),
        child: child,
      ),
    );
  }
}
