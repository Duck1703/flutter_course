import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_session_state_data.dart';
import '../../../l10n/app_localizations.dart';
import 'game_dialog_shell.dart';

class GameConfirmExitDialogView extends StatelessWidget {
  final GameConfirmExitDialog data;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const GameConfirmExitDialogView({
    super.key,
    required this.data,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GameDialogShell(
      title: l10n.exitGameTitle,
      headerColor: AppTokens.qzdsYellow500,
      icon: Icons.exit_to_app,
      child: _ConfirmBody(
        message: l10n.exitGameMessage,
        amount: data.guaranteedAmount,
        primaryText: l10n.exitGameButton.toUpperCase(),
        primaryColor: AppTokens.red500,
        primaryIcon: Icons.exit_to_app,
        secondaryText: l10n.continuePlayingButton.toUpperCase(),
        secondaryColor: AppTokens.green500,
        secondaryIcon: Icons.play_arrow,
        onPrimary: onConfirm,
        onSecondary: onCancel,
      ),
    );
  }
}

class GameConfirmWalkAwayDialogView extends StatelessWidget {
  final GameConfirmWalkAwayDialog data;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const GameConfirmWalkAwayDialogView({
    super.key,
    required this.data,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GameDialogShell(
      title: l10n.walkAwayTitle,
      headerColor: AppTokens.qzdsYellow500,
      icon: Icons.front_hand,
      child: _ConfirmBody(
        message: l10n.walkAwayMessage,
        amount: data.currentAmount,
        primaryText: l10n.confirmWalkAwayButton.toUpperCase(),
        primaryColor: AppTokens.red700,
        primaryIcon: Icons.front_hand,
        secondaryText: l10n.keepPlayingButton.toUpperCase(),
        secondaryColor: AppTokens.green700,
        secondaryIcon: Icons.play_arrow,
        onPrimary: onConfirm,
        onSecondary: onCancel,
      ),
    );
  }
}

class _ConfirmBody extends StatelessWidget {
  final String message;
  final String amount;
  final String primaryText;
  final Color primaryColor;
  final IconData primaryIcon;
  final String secondaryText;
  final Color secondaryColor;
  final IconData secondaryIcon;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  const _ConfirmBody({
    required this.message,
    required this.amount,
    required this.primaryText,
    required this.primaryColor,
    required this.primaryIcon,
    required this.secondaryText,
    required this.secondaryColor,
    required this.secondaryIcon,
    required this.onPrimary,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTokens.qzdsBody1.copyWith(color: AppTokens.qzdsBlack600),
        ),
        const SizedBox(height: AppTokens.spacingXs),
        GameDialogMoneyRow(amount: amount),
        const SizedBox(height: AppTokens.spacingMd),
        GameDialogButton(
          text: primaryText,
          color: primaryColor,
          icon: primaryIcon,
          onTap: onPrimary,
        ),
        const SizedBox(height: AppTokens.spacingXs),
        GameDialogButton(
          text: secondaryText,
          color: secondaryColor,
          icon: secondaryIcon,
          onTap: onSecondary,
        ),
      ],
    );
  }
}
