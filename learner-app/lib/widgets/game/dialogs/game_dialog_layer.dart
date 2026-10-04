import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_session_state_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/design_frame.dart';
import 'game_confirm_dialogs.dart';
import 'game_help_dialogs.dart';
import 'game_result_dialogs.dart';
import '../money/game_money_ladder_dialog.dart';

class GameDialogLayer extends StatelessWidget {
  final GameDialogState dialog;
  final VoidCallback onDismiss;
  final VoidCallback onConfirmWalkAway;
  final VoidCallback onBackToMenu;
  final VoidCallback onPlayAgain;
  final ValueChanged<String> onShareResult;

  const GameDialogLayer({
    super.key,
    required this.dialog,
    required this.onDismiss,
    required this.onConfirmWalkAway,
    required this.onBackToMenu,
    required this.onPlayAgain,
    required this.onShareResult,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canDismissFromBackdrop = _canDismissFromBackdrop(dialog);
    final motionDuration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : AppTokens.dialogMotionLong;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: dialog is GameDialogHidden,
        child: AnimatedSwitcher(
          duration: motionDuration,
          reverseDuration: motionDuration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: _buildTransition,
          child: _layerChild(context, l10n, canDismissFromBackdrop),
        ),
      ),
    );
  }

  bool _canDismissFromBackdrop(GameDialogState dialog) {
    return dialog is! GameMoneyLadderDialog && !_isTerminalDialog(dialog);
  }

  bool _isTerminalDialog(GameDialogState dialog) {
    return dialog is GameEndedDialog || dialog is GameVictoryDialog;
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    final slideOffset = child.key == const ValueKey<Type>(GameMoneyLadderDialog)
        ? AppTokens.spacingMd
        : AppTokens.spacingSm;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final progress = animation.value.clamp(0, 1).toDouble();

        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0, slideOffset * (1 - progress)),
            transformHitTests: false,
            child: child,
          ),
        );
      },
    );
  }

  Widget _layerChild(
    BuildContext context,
    AppLocalizations l10n,
    bool canDismiss,
  ) {
    return dialog is GameDialogHidden
        ? const SizedBox.expand(key: ValueKey('game-dialog-hidden'))
        : SizedBox.expand(
            key: ValueKey(dialog.runtimeType),
            child: _DialogBackdrop(
              onDismiss: canDismiss ? onDismiss : () {},
              child: _dialogBody(context, l10n),
            ),
          );
  }

  Widget _dialogBody(BuildContext context, AppLocalizations l10n) {
    return switch (dialog) {
      GameDialogHidden() => const SizedBox.shrink(),
      GameMoneyLadderDialog() => GameMoneyLadderDialogView(
        data: dialog as GameMoneyLadderDialog,
        onDismiss: onDismiss,
      ),
      GameConfirmExitDialog() => GameConfirmExitDialogView(
        data: dialog as GameConfirmExitDialog,
        onConfirm: onBackToMenu,
        onCancel: onDismiss,
      ),
      GameConfirmWalkAwayDialog() => GameConfirmWalkAwayDialogView(
        data: dialog as GameConfirmWalkAwayDialog,
        onConfirm: onConfirmWalkAway,
        onCancel: onDismiss,
      ),
      GameExplanationDialog() => GameExplanationDialogView(
        data: dialog as GameExplanationDialog,
        onDismiss: onDismiss,
      ),
      GameAudiencePollDialog() => GameAudiencePollDialogView(
        data: dialog as GameAudiencePollDialog,
        onDismiss: onDismiss,
      ),
      GameAIAssistantDialog() => GameAIAssistantDialogView(
        data: dialog as GameAIAssistantDialog,
        onDismiss: onDismiss,
      ),
      GameEndedDialog() => GameEndedDialogView(
        data: dialog as GameEndedDialog,
        onPlayAgain: onPlayAgain,
        onBackToMenu: onBackToMenu,
        onShare: () => onShareResult(
          l10n.shareResultMessage((dialog as GameEndedDialog).earnedAmount),
        ),
      ),
      GameVictoryDialog() => GameVictoryDialogView(
        data: dialog as GameVictoryDialog,
        onPlayAgain: onPlayAgain,
        onBackToMenu: onBackToMenu,
        onShare: () => onShareResult(
          l10n.shareVictoryResultMessage(
            (dialog as GameVictoryDialog).earnedAmount,
            (dialog as GameVictoryDialog).affirmationMessage,
          ),
        ),
      ),
    };
  }
}

class _DialogBackdrop extends StatelessWidget {
  final Widget child;
  final VoidCallback onDismiss;

  const _DialogBackdrop({required this.child, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        key: const ValueKey('game-dialog-backdrop-filter'),
        filter: ImageFilter.blur(
          sigmaX: AppTokens.dialogHazeBlurSigma,
          sigmaY: AppTokens.dialogHazeBlurSigma,
        ),
        child: ColoredBox(
          color: AppTokens.dialogHazeScrim,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDismiss,
                ),
              ),
              SafeArea(
                minimum: const EdgeInsets.symmetric(
                  vertical: AppTokens.spacingLg,
                ),
                child: Center(child: DesignFrame(child: child)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
