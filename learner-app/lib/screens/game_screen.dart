import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_design_tokens.dart';
import '../data/game/game_session_state_data.dart';
import '../l10n/app_localizations.dart';
import '../navigation/app_navigation_controller.dart';
import '../repositories/auth/auth_repository_contract.dart';
import '../repositories/profile/user_profile_repository.dart';
import '../repositories/profile/user_profile_sync_repository_contract.dart';
import '../view_models/game/game_screen_view_model.dart';
import '../widgets/common/game_screen_background.dart';
import '../widgets/game/dialogs/game_dialog_layer.dart';
import '../widgets/game/lifelines/game_feature_button_bar.dart';
import '../widgets/game/layout/game_screen_body.dart';
import '../widgets/game/layout/game_screen_top_bar.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameScreenViewModel>(
      create: (context) => GameScreenViewModel(
        userProfileRepository: context.read<UserProfileRepository>(),
        authRepository: context.read<AuthRepository>(),
        profileSyncRepository: context.read<UserProfileSyncRepository>(),
      )..startNewGame(),
      child: const _GameScreenEventBridge(),
    );
  }
}

class _GameScreenEventBridge extends StatefulWidget {
  const _GameScreenEventBridge();

  @override
  State<_GameScreenEventBridge> createState() => _GameScreenEventBridgeState();
}

class _GameScreenEventBridgeState extends State<_GameScreenEventBridge> {
  late AppNavigationController _navigationController;
  GameScreenViewModel? _viewModel;
  StreamSubscription<GameScreenUiEvent>? _uiEventSubscription;
  var _terminalActionPending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigationController = context.read<AppNavigationController>();
    _attachViewModel(context.read<GameScreenViewModel>());
  }

  void _attachViewModel(GameScreenViewModel viewModel) {
    if (_viewModel == viewModel) return;
    _uiEventSubscription?.cancel();
    _viewModel = viewModel;
    _uiEventSubscription = viewModel.uiEvents.listen(_handleUiEvent);
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameScreenViewModel>();
    final data = viewModel.screenData;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _handleRouteBack();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              const Positioned.fill(child: GameScreenBackground()),
              SafeArea(
                child: Column(
                  children: [
                    GameScreenTopBar(
                      timer: data.timer,
                      onBackTap: viewModel.showConfirmExit,
                    ),
                    Expanded(
                      child: GameScreenBody(
                        data: data,
                        answers: data.answers,
                        onMoneyAmountTap: viewModel.showMoneyLadder,
                        onAnswerTap: viewModel.submitAnswer,
                      ),
                    ),
                    GameFeatureButtonBar(
                      buttons: data.featureButtons,
                      onPressed: viewModel.handleFeatureClick,
                    ),
                  ],
                ),
              ),
              GameDialogLayer(
                dialog: viewModel.dialogState,
                onDismiss: viewModel.dismissDialog,
                onConfirmWalkAway: viewModel.confirmWalkAway,
                onBackToMenu: _handleBackToMenu,
                onPlayAgain: _handlePlayAgain,
                onShareResult: viewModel.shareResult,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRouteBack() {
    final viewModel = _viewModel;
    if (viewModel == null) return;

    if (viewModel.dialogState is GameDialogHidden) {
      viewModel.showConfirmExit();
      return;
    }

    if (viewModel.dialogState is GameMoneyLadderDialog ||
        _isTerminalDialog(viewModel.dialogState)) {
      return;
    }

    viewModel.dismissDialog();
  }

  bool _isTerminalDialog(GameDialogState dialog) =>
      dialog is GameEndedDialog || dialog is GameVictoryDialog;

  void _handleBackToMenu() => unawaited(_afterExit((vm) => vm.backToMenu()));
  void _handlePlayAgain() => unawaited(_afterExit((vm) => vm.playAgain()));

  Future<void> _afterExit(
    void Function(GameScreenViewModel viewModel) action,
  ) async {
    if (_terminalActionPending) return;
    final viewModel = _viewModel;
    if (viewModel == null) return;

    _terminalActionPending = true;
    try {
      if (_isTerminalDialog(viewModel.dialogState)) {
        viewModel.dismissDialog();
        final duration = MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : AppTokens.dialogMotionLong;
        if (duration > Duration.zero) await Future<void>.delayed(duration);
      }
      if (!mounted || _viewModel == null) return;
      action(_viewModel!);
    } finally {
      _terminalActionPending = false;
    }
  }

  Future<void> _handleUiEvent(GameScreenUiEvent event) async {
    if (!mounted) return;

    switch (event) {
      case GameNavigateToMenuEvent():
        _navigationController.goBack();
      case GameShareResultEvent():
        final box = context.findRenderObject() as RenderBox?;
        try {
          await SharePlus.instance.share(
            ShareParams(
              text: event.text,
              sharePositionOrigin: box == null
                  ? null
                  : box.localToGlobal(Offset.zero) & box.size,
            ),
          );
        } catch (_) {
          await Clipboard.setData(ClipboardData(text: event.text));
          if (!mounted) return;
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.resultCopiedSnackBar),
              duration: const Duration(seconds: 2),
            ),
          );
        }
    }
  }
}
