import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/profile/user_profile_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../repositories/settings/user_settings_repository.dart';
import '../../../services/local_notification_service.dart';
import '../../../view_models/settings/settings_ui_event.dart';
import '../../../view_models/settings/settings_view_model.dart';
import '../../common/design_frame.dart';
import '../menu_dialog_backdrop.dart';
import 'menu_settings_dialog.dart';
import 'notification_time_picker_dialog.dart';

class MenuSettingsDialogScope extends StatelessWidget {
  final VoidCallback onDismiss;
  final UserProfileData profile;
  final bool isAuthenticated;
  final VoidCallback? onAccountAction;

  const MenuSettingsDialogScope({
    super.key,
    required this.onDismiss,
    this.profile = const UserProfileData(),
    this.isAuthenticated = false,
    this.onAccountAction,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsViewModel>(
      create: (context) => SettingsViewModel(
        settingsRepository: context.read<UserSettingsRepository>(),
        notificationService: context.read<LocalNotificationService>(),
      ),
      child: _SettingsDialogEventBridge(
        onDismiss: onDismiss,
        profile: profile,
        isAuthenticated: isAuthenticated,
        onAccountAction: onAccountAction,
      ),
    );
  }
}

class _SettingsDialogEventBridge extends StatefulWidget {
  final VoidCallback onDismiss;
  final UserProfileData profile;
  final bool isAuthenticated;
  final VoidCallback? onAccountAction;

  const _SettingsDialogEventBridge({
    required this.onDismiss,
    required this.profile,
    required this.isAuthenticated,
    required this.onAccountAction,
  });

  @override
  State<_SettingsDialogEventBridge> createState() =>
      _SettingsDialogEventBridgeState();
}

class _SettingsDialogEventBridgeState
    extends State<_SettingsDialogEventBridge> {
  SettingsViewModel? _viewModel;
  StreamSubscription<SettingsUiEvent>? _eventSubscription;
  var _didLoadSettings = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachViewModel(context.read<SettingsViewModel>());
  }

  void _attachViewModel(SettingsViewModel viewModel) {
    if (_viewModel == viewModel) {
      return;
    }

    _eventSubscription?.cancel();
    _viewModel = viewModel;
    _eventSubscription = viewModel.events.listen(_handleUiEvent);

    if (!_didLoadSettings) {
      _didLoadSettings = true;
      unawaited(viewModel.loadSettings());
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _handleUiEvent(SettingsUiEvent event) {
    switch (event) {
      case SettingsDismissRequested():
        widget.onDismiss();
      case SettingsSnackBarRequested(:final message):
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_snackBarText(l10n, message))));
    }
  }

  String _snackBarText(AppLocalizations l10n, SettingsSnackBarMessage message) {
    return switch (message) {
      SettingsSnackBarMessage.loadFailed => l10n.settingsLoadErrorMessage,
      SettingsSnackBarMessage.updateFailed => l10n.settingsUpdateErrorMessage,
      SettingsSnackBarMessage.notificationTimeUpdateFailed =>
        l10n.settingsNotificationTimeUpdateErrorMessage,
      SettingsSnackBarMessage.notificationPermissionRequired =>
        l10n.settingsNotificationPermissionRequiredMessage,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MenuDialogBackdrop(
      onDismiss: widget.onDismiss,
      foregroundOverlay: const _SettingsTimePickerOverlay(),
      child: MenuSettingsDialog(
        profile: widget.profile,
        isAuthenticated: widget.isAuthenticated,
        onAccountAction: widget.onAccountAction,
      ),
    );
  }
}

class _SettingsTimePickerOverlay extends StatelessWidget {
  const _SettingsTimePickerOverlay();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();

    if (!viewModel.timePickerVisible) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      child: BackdropFilter(
        key: const ValueKey('settings-time-picker-backdrop-filter'),
        filter: ImageFilter.blur(
          sigmaX: AppTokens.dialogHazeBlurSigma,
          sigmaY: AppTokens.dialogHazeBlurSigma,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ModalBarrier(
              key: ValueKey('settings-time-picker-modal-barrier'),
              color: AppTokens.dialogHazeScrim,
              dismissible: false,
            ),
            SafeArea(
              minimum: const EdgeInsets.symmetric(
                vertical: AppTokens.spacingLg,
              ),
              child: Center(
                child: DesignFrame(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: NotificationTimePickerDialog(
                      currentHour: viewModel.timePickerHour,
                      currentMinute: viewModel.timePickerMinute,
                      onConfirm: viewModel.onNotificationTimeSelected,
                      onDismiss: viewModel.dismissTimePicker,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
