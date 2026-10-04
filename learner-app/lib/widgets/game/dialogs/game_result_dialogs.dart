import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_session_state_data.dart';
import '../../../l10n/app_localizations.dart';
import 'game_dialog_shell.dart';

class GameEndedDialogView extends StatelessWidget {
  final GameEndedDialog data;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToMenu;
  final VoidCallback onShare;

  const GameEndedDialogView({
    super.key,
    required this.data,
    required this.onPlayAgain,
    required this.onBackToMenu,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _ResultShell(
      title: l10n.gameOverTitle,
      headerColor: AppTokens.red500,
      headerIcon: Icons.sports_score,
      subtitle: l10n.youEarnedLabel,
      amount: data.earnedAmount,
      shareColor: const Color(0xFF325DFA),
      playColor: AppTokens.green500,
      onPlayAgain: onPlayAgain,
      onBackToMenu: onBackToMenu,
      onShare: onShare,
    );
  }
}

class GameVictoryDialogView extends StatelessWidget {
  final GameVictoryDialog data;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToMenu;
  final VoidCallback onShare;

  const GameVictoryDialogView({
    super.key,
    required this.data,
    required this.onPlayAgain,
    required this.onBackToMenu,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _ResultShell(
      title: l10n.congratulationsTitle,
      headerColor: AppTokens.green500,
      headerIconAsset: AppAssets.iconGameTrophy,
      subtitle: data.affirmationMessage,
      amount: data.earnedAmount,
      shareColor: AppTokens.green500,
      playColor: const Color(0xFF325DFA),
      onPlayAgain: onPlayAgain,
      onBackToMenu: onBackToMenu,
      onShare: onShare,
    );
  }
}

class _ResultShell extends StatelessWidget {
  final String title;
  final Color headerColor;
  final IconData? headerIcon;
  final String? headerIconAsset;
  final String subtitle;
  final String amount;
  final Color shareColor;
  final Color playColor;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToMenu;
  final VoidCallback onShare;

  const _ResultShell({
    required this.title,
    required this.headerColor,
    this.headerIcon,
    this.headerIconAsset,
    required this.subtitle,
    required this.amount,
    required this.shareColor,
    required this.playColor,
    required this.onPlayAgain,
    required this.onBackToMenu,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GameDialogShell(
      title: title,
      headerColor: headerColor,
      icon: headerIcon,
      iconAsset: headerIconAsset,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTokens.qzdsSubtitle2.copyWith(
              color: AppTokens.qzdsBlack600,
            ),
          ),
          const SizedBox(height: AppTokens.spacingSm),
          GameDialogMoneyRow(amount: amount),
          const SizedBox(height: AppTokens.spacingMd),
          GameDialogButton(
            text: l10n.shareResultButton.toUpperCase(),
            color: shareColor,
            icon: Icons.share,
            onTap: onShare,
          ),
          const SizedBox(height: AppTokens.spacingXs),
          Row(
            children: [
              Expanded(
                child: GameDialogButton(
                  text: l10n.menuButton.toUpperCase(),
                  color: AppTokens.qzdsPurple500.withValues(alpha: 0.7),
                  icon: Icons.home,
                  onTap: onBackToMenu,
                ),
              ),
              const SizedBox(width: AppTokens.spacingXs),
              Expanded(
                child: GameDialogButton(
                  text: l10n.playAgainButton.toUpperCase(),
                  color: playColor,
                  icon: Icons.replay,
                  onTap: onPlayAgain,
                  textGlow: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
