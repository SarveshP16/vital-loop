import 'package:flutter/material.dart';

/// Predefined units covering common health/activity goals. Kept as a closed
/// list (per the user's explicit request) rather than free text, so Stats
/// labels stay consistent.
const kPredefinedUnits = [
  'reps',
  'glasses',
  'ml',
  'cups',
  'minutes',
  'hours',
  'steps',
  'km',
  'sets',
  'pages',
  'times',
];

class UnitDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const UnitDropdown({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // Guard against a saved unit that predates this predefined list (or was
    // edited before this change) so the dropdown always has a valid value.
    final options = kPredefinedUnits.contains(value) ? kPredefinedUnits : [value, ...kPredefinedUnits];
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Unit'),
      items: [for (final unit in options) DropdownMenuItem(value: unit, child: Text(unit))],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
