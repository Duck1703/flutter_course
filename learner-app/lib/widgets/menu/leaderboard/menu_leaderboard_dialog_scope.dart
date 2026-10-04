import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../repositories/auth/auth_repository_contract.dart';
import '../../../repositories/leaderboard/leaderboard_repository_contract.dart';
import '../../../repositories/profile/user_profile_repository.dart';
import '../../../view_models/leaderboard/leaderboard_dialog_view_model.dart';
import '../menu_dialog_backdrop.dart';
import 'menu_leaderboard_dialog.dart';

class MenuLeaderboardDialogScope extends StatelessWidget {
  final VoidCallback onDismiss;

  const MenuLeaderboardDialogScope({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LeaderboardDialogViewModel>(
      create: (context) => LeaderboardDialogViewModel(
        leaderboardRepository: context.read<LeaderboardRepository>(),
        authRepository: context.read<AuthRepository>(),
        userProfileRepository: context.read<UserProfileRepository>(),
      ),
      child: _LeaderboardDialogBridge(onDismiss: onDismiss),
    );
  }
}

class _LeaderboardDialogBridge extends StatefulWidget {
  final VoidCallback onDismiss;

  const _LeaderboardDialogBridge({required this.onDismiss});

  @override
  State<_LeaderboardDialogBridge> createState() =>
      _LeaderboardDialogBridgeState();
}

class _LeaderboardDialogBridgeState extends State<_LeaderboardDialogBridge> {
  LeaderboardDialogViewModel? _viewModel;
  var _didLoadLeaderboard = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachViewModel(context.read<LeaderboardDialogViewModel>());
  }

  void _attachViewModel(LeaderboardDialogViewModel viewModel) {
    if (_viewModel == viewModel) {
      return;
    }

    _viewModel = viewModel;

    if (!_didLoadLeaderboard) {
      _didLoadLeaderboard = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(viewModel.loadLeaderboard());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LeaderboardDialogViewModel>();

    return MenuDialogBackdrop(
      onDismiss: widget.onDismiss,
      child: MenuLeaderboardDialog(
        state: viewModel.state,
        onRefresh: viewModel.refresh,
        onRetry: viewModel.retry,
      ),
    );
  }
}
