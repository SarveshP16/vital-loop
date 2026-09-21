import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

/// Toggle chips for weekdays 1 (Monday) .. 7 (Sunday), matching
/// [DateTime.weekday].
class DayOfWeekSelector extends StatelessWidget {
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  const DayOfWeekSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final weekday = index + 1;
        final isSelected = selected.contains(weekday);
        return GestureDetector(
          onTap: () {
            final next = Set<int>.from(selected);
            isSelected ? next.remove(weekday) : next.add(weekday);
            onChanged(next);
          },
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? context.colors.navActive : context.colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.ink, width: 2),
            ),
            child: Text(
              _dayLabels[index],
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : context.colors.ink,
              ),
            ),
          ),
        );
      }),
    );
  }
}
