import 'package:flutter/material.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/theme/app_colors.dart';

/// Reminders need Android's exact-alarm permission or they silently never
/// fire (see notification-manifest-gotcha) — this row surfaces that state
/// and lets the user (re-)grant it without hunting through OS Settings.
class NotificationPermissionCard extends StatefulWidget {
  const NotificationPermissionCard({super.key});

  @override
  State<NotificationPermissionCard> createState() => _NotificationPermissionCardState();
}

class _NotificationPermissionCardState extends State<NotificationPermissionCard> with WidgetsBindingObserver {
  bool? _canScheduleExact;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final canSchedule = await NotificationService.canScheduleExact();
    if (mounted) setState(() => _canScheduleExact = canSchedule);
  }

  @override
  Widget build(BuildContext context) {
    if (_canScheduleExact == null || _canScheduleExact == true) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE3C4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_off_outlined, color: AppColors.ink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reminders need one more permission', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'Allow exact alarms so nudges arrive on time.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtleText),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await NotificationService.requestExactAlarmPermission();
              _refresh();
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
}
