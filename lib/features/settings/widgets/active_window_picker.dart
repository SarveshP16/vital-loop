import 'package:flutter/material.dart';

import '../../../core/notifications/active_window.dart';
import '../../../core/theme/app_colors.dart';

/// A pair of time pickers for one activity's own active-hours window —
/// reminders for that activity are spread evenly across this range each
/// remind day (see `reminder_time_calculator.dart`).
class ActiveWindowPicker extends StatelessWidget {
  final ActiveWindow window;
  final ValueChanged<ActiveWindow> onChanged;

  const ActiveWindowPicker({super.key, required this.window, required this.onChanged});

  Future<void> _pickTime(BuildContext context, {required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? window.start : window.end,
    );
    if (picked == null) return;
    onChanged(ActiveWindow(
      start: isStart ? picked : window.start,
      end: isStart ? window.end : picked,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeButton(
            label: 'From',
            time: window.start,
            onTap: () => _pickTime(context, isStart: true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TimeButton(
            label: 'To',
            time: window.end,
            onTap: () => _pickTime(context, isStart: false),
          ),
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeButton({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtleText)),
            Text(
              time.format(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
