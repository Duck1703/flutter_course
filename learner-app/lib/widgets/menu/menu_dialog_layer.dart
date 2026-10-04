import 'package:flutter/material.dart';
import '../../core/app_design_tokens.dart';
import '../../data/profile/user_profile_data.dart';
import '../../view_models/menu/menu_dialog_state.dart';
import 'auth/menu_auth_dialog_scope.dart';
import 'auth/menu_sign_out_dialog_scope.dart';
import 'leaderboard/menu_leaderboard_dialog_scope.dart';
import 'settings/menu_settings_dialog_scope.dart';

class MenuDialogLayer extends StatelessWidget {
  final MenuDialogState dialogState;
  final VoidCallback onDismiss;
  final ValueChanged<bool>? onDismissLockChanged;
  final UserProfileData profile;
  final bool isAuthenticated;

  /// Opens the sign-in or sign-out dialog from the settings account row.
  final VoidCallback? onAccountAction;

  const MenuDialogLayer({
    super.key,
    required this.dialogState,
    required this.onDismiss,
    this.onDismissLockChanged,
    this.profile = const UserProfileData(),
    this.isAuthenticated = false,
    this.onAccountAction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedSwitcher(
        duration: AppTokens.dialogMotionLong,
        reverseDuration: AppTokens.dialogMotionLong,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.linear,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _buildDialog(dialogState),
      ),
    );
  }

  Widget _buildDialog(MenuDialogState state) {
    return switch (state) {
      MenuDialogNone() => const SizedBox.shrink(
        key: ValueKey('menu-dialog-none'),
      ),
      MenuDialogLeaderboard() => MenuLeaderboardDialogScope(
        key: ValueKey(state.transitionKey),
        onDismiss: onDismiss,
      ),
      MenuDialogSettings() => MenuSettingsDialogScope(
        key: ValueKey(state.transitionKey),
        onDismiss: onDismiss,
        profile: profile,
        isAuthenticated: isAuthenticated,
        onAccountAction: onAccountAction,
      ),
      MenuDialogAuth() => MenuAuthDialogScope(
        key: ValueKey(state.transitionKey),
        onDismiss: onDismiss,
      ),
      MenuDialogSignOut() => MenuSignOutDialogScope(
        key: ValueKey(state.transitionKey),
        onDismiss: onDismiss,
        onDismissLockChanged: onDismissLockChanged ?? (_) {},
      ),
    };
  }
}
