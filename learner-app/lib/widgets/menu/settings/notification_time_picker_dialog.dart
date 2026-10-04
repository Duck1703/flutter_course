import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/qzds_game_button.dart';
import 'settings_dialog_shell.dart';
import 'time_picker_wheels.dart';

class NotificationTimePickerDialog extends StatefulWidget {
  final int currentHour;
  final int currentMinute;
  final void Function(int hour, int minute) onConfirm;
  final VoidCallback onDismiss;

  const NotificationTimePickerDialog({
    super.key,
    required this.currentHour,
    required this.currentMinute,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  State<NotificationTimePickerDialog> createState() =>
      _NotificationTimePickerDialogState();
}

class _NotificationTimePickerDialogState
    extends State<NotificationTimePickerDialog> {
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.currentHour;
    _selectedMinute = widget.currentMinute;
  }

  @override
  void didUpdateWidget(covariant NotificationTimePickerDialog oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentHour != widget.currentHour ||
        oldWidget.currentMinute != widget.currentMinute) {
      _selectedHour = widget.currentHour;
      _selectedMinute = widget.currentMinute;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDialogShell(
      key: const ValueKey('notification-time-picker-dialog'),
      headerText: l10n.notificationTimeSetting,
      iconAsset: AppAssets.iconBellNotification,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TimePickerWheels(
            currentHour: _selectedHour,
            currentMinute: _selectedMinute,
            onHourChanged: (hour) => setState(() => _selectedHour = hour),
            onMinuteChanged: (minute) {
              setState(() => _selectedMinute = minute);
            },
          ),
          const SizedBox(height: AppTokens.qzdsSpacingSm),
          Row(
            children: [
              Expanded(
                child: QzdsGameButton(
                  text: l10n.cancelButton,
                  color: AppTokens.red500,
                  icon: Icons.close,
                  onTap: widget.onDismiss,
                ),
              ),
              const SizedBox(width: AppTokens.spacingXs),
              Expanded(
                child: QzdsGameButton(
                  text: l10n.confirmButton,
                  color: AppTokens.purple800,
                  icon: Icons.check_circle,
                  textGlow: true,
                  onTap: () => widget.onConfirm(_selectedHour, _selectedMinute),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
