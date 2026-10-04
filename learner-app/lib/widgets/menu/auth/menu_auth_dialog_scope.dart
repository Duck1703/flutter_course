import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../repositories/auth/auth_repository_contract.dart';
import '../../../repositories/profile/user_profile_repository.dart';
import '../../../repositories/profile/user_profile_sync_repository_contract.dart';
import '../../../view_models/menu/menu_auth_dialog_view_model.dart';
import '../menu_dialog_backdrop.dart';
import 'menu_auth_dialog.dart';
import 'menu_loading_overlay.dart';

class MenuAuthDialogScope extends StatelessWidget {
  final VoidCallback onDismiss;

  const MenuAuthDialogScope({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MenuAuthDialogViewModel>(
      create: (context) => MenuAuthDialogViewModel(
        authRepository: context.read<AuthRepository>(),
        userProfileRepository: context.read<UserProfileRepository>(),
        profileSyncRepository: context.read<UserProfileSyncRepository>(),
      ),
      child: _MenuAuthDialogBridge(onDismiss: onDismiss),
    );
  }
}

class _MenuAuthDialogBridge extends StatefulWidget {
  final VoidCallback onDismiss;

  const _MenuAuthDialogBridge({required this.onDismiss});

  @override
  State<_MenuAuthDialogBridge> createState() => _MenuAuthDialogBridgeState();
}

class _MenuAuthDialogBridgeState extends State<_MenuAuthDialogBridge> {
  MenuAuthDialogViewModel? _viewModel;
  StreamSubscription<MenuAuthDialogUiEvent>? _eventSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachViewModel(context.read<MenuAuthDialogViewModel>());
  }

  void _attachViewModel(MenuAuthDialogViewModel viewModel) {
    if (_viewModel == viewModel) {
      return;
    }

    _eventSubscription?.cancel();
    _viewModel = viewModel;
    _eventSubscription = viewModel.events.listen(_handleUiEvent);
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _handleUiEvent(MenuAuthDialogUiEvent event) {
    switch (event) {
      case MenuAuthDialogDismissRequested():
        widget.onDismiss();
      case MenuAuthDialogSnackBarRequested(:final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MenuAuthDialogViewModel>();

    return MenuDialogBackdrop(
      onDismiss: widget.onDismiss,
      foregroundOverlay: viewModel.isLoading
          ? const MenuLoadingOverlay()
          : null,
      child: const MenuAuthDialog(),
    );
  }
}
