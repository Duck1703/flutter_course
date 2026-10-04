import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../repositories/auth/auth_repository_contract.dart';
import '../../../repositories/profile/user_profile_repository.dart';
import '../../../repositories/profile/user_profile_sync_repository_contract.dart';
import '../../../view_models/menu/menu_sign_out_dialog_view_model.dart';
import '../menu_dialog_backdrop.dart';
import 'menu_loading_overlay.dart';
import 'menu_sign_out_dialog.dart';

class MenuSignOutDialogScope extends StatelessWidget {
  final VoidCallback onDismiss;
  final ValueChanged<bool> onDismissLockChanged;

  const MenuSignOutDialogScope({
    super.key,
    required this.onDismiss,
    required this.onDismissLockChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MenuSignOutDialogViewModel>(
      create: (context) => MenuSignOutDialogViewModel(
        authRepository: context.read<AuthRepository>(),
        userProfileRepository: context.read<UserProfileRepository>(),
        profileSyncRepository: context.read<UserProfileSyncRepository>(),
      ),
      child: _MenuSignOutDialogBridge(
        onDismiss: onDismiss,
        onDismissLockChanged: onDismissLockChanged,
      ),
    );
  }
}

class _MenuSignOutDialogBridge extends StatefulWidget {
  final VoidCallback onDismiss;
  final ValueChanged<bool> onDismissLockChanged;

  const _MenuSignOutDialogBridge({
    required this.onDismiss,
    required this.onDismissLockChanged,
  });

  @override
  State<_MenuSignOutDialogBridge> createState() =>
      _MenuSignOutDialogBridgeState();
}

class _MenuSignOutDialogBridgeState extends State<_MenuSignOutDialogBridge> {
  MenuSignOutDialogViewModel? _viewModel;
  StreamSubscription<MenuSignOutDialogUiEvent>? _eventSubscription;
  var _dismissLocked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachViewModel(context.read<MenuSignOutDialogViewModel>());
  }

  void _attachViewModel(MenuSignOutDialogViewModel viewModel) {
    if (_viewModel == viewModel) {
      return;
    }

    _eventSubscription?.cancel();
    _viewModel?.removeListener(_handleViewModelChanged);
    _viewModel = viewModel;
    _dismissLocked = viewModel.isLoading;
    widget.onDismissLockChanged(_dismissLocked);
    viewModel.addListener(_handleViewModelChanged);
    _eventSubscription = viewModel.events.listen(_handleUiEvent);
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _viewModel?.removeListener(_handleViewModelChanged);
    super.dispose();
  }

  void _handleViewModelChanged() {
    final isLoading = _viewModel?.isLoading ?? false;

    if (_dismissLocked == isLoading) {
      return;
    }

    _dismissLocked = isLoading;
    widget.onDismissLockChanged(isLoading);
  }

  void _handleUiEvent(MenuSignOutDialogUiEvent event) {
    switch (event) {
      case MenuSignOutDialogDismissRequested():
        _dismissLocked = false;
        widget.onDismissLockChanged(false);
        widget.onDismiss();
      case MenuSignOutDialogSnackBarRequested(:final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MenuSignOutDialogViewModel>();

    return MenuDialogBackdrop(
      onDismiss: viewModel.isLoading ? () {} : widget.onDismiss,
      foregroundOverlay: viewModel.isLoading
          ? const MenuLoadingOverlay()
          : null,
      child: MenuSignOutDialog(
        onSignOut: () => unawaited(viewModel.signOut()),
        onCancel: viewModel.isLoading ? null : widget.onDismiss,
      ),
    );
  }
}
