import 'package:flutter/material.dart';

/// The daily time-of-day range reminders are allowed to fire in, shared by
/// every activity (kept simple for MVP rather than a per-activity window).
class ActiveWindow {
  final TimeOfDay start;
  final TimeOfDay end;

  const ActiveWindow({required this.start, required this.end});

  static const defaultWindow = ActiveWindow(
    start: TimeOfDay(hour: 8, minute: 0),
    end: TimeOfDay(hour: 22, minute: 0),
  );

  int get startMinutes => start.hour * 60 + start.minute;
  int get endMinutes => end.hour * 60 + end.minute;

  Map<String, dynamic> toMap() => {
        'startMinutes': startMinutes,
        'endMinutes': endMinutes,
      };

  factory ActiveWindow.fromMap(Map<dynamic, dynamic> map) => ActiveWindow(
        start: TimeOfDay(hour: (map['startMinutes'] as int) ~/ 60, minute: (map['startMinutes'] as int) % 60),
        end: TimeOfDay(hour: (map['endMinutes'] as int) ~/ 60, minute: (map['endMinutes'] as int) % 60),
      );
}
