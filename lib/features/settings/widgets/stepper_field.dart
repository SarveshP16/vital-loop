import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A labeled +/- numeric stepper row (interval hours, per-reminder amount,
/// daily goal all use this).
class StepperField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final String? suffix;
  final ValueChanged<int> onChanged;

  const StepperField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
    this.step = 1,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        _StepButton(icon: Icons.remove, onTap: value > min ? () => onChanged(value - step) : null),
        SizedBox(
          width: 56,
          child: Text(
            suffix == null ? '$value' : '$value $suffix',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        _StepButton(icon: Icons.add, onTap: value < max ? () => onChanged(value + step) : null),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: disabled ? const Color(0xFFF0EBE0) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.ink, width: 2),
          ),
          child: Icon(icon, size: 18, color: disabled ? AppColors.subtleText : AppColors.ink),
        ),
      ),
    );
  }
}
