import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_session_state_data.dart';
import '../../../l10n/app_localizations.dart';
import 'game_dialog_shell.dart';
import '../lifelines/game_audience_poll_row.dart';

const double _thinkingSpinnerSize = 32;
const double _thinkingSpinnerStroke = 4;

class GameExplanationDialogView extends StatelessWidget {
  final GameExplanationDialog data;
  final VoidCallback onDismiss;

  const GameExplanationDialogView({
    super.key,
    required this.data,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GameDialogShell(
      title: l10n.aiExplanationsTitle,
      headerColor: const Color(0xFF0036F9),
      iconAsset: AppAssets.iconGameSparkle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.question, style: AppTokens.qzdsSubtitle2),
          const SizedBox(height: AppTokens.spacingSm),
          Row(
            children: [
              const Icon(Icons.bolt, color: AppTokens.green500),
              const SizedBox(width: AppTokens.spacingXs),
              Expanded(
                child: Text(
                  data.correctAnswer,
                  style: AppTokens.qzdsBody1.copyWith(color: Colors.black),
                ),
              ),
            ],
          ),
          const Divider(height: AppTokens.spacingLg),
          Text(
            data.explanation,
            style: AppTokens.qzdsCaption1.copyWith(color: Colors.black),
          ),
          const SizedBox(height: AppTokens.spacingMd),
          GameDialogButton(
            text: l10n.understandButton.toUpperCase(),
            color: AppTokens.qzdsPurple500,
            icon: Icons.check_circle,
            onTap: onDismiss,
            textGlow: true,
          ),
        ],
      ),
    );
  }
}

class GameAIAssistantDialogView extends StatelessWidget {
  final GameAIAssistantDialog data;
  final VoidCallback onDismiss;

  const GameAIAssistantDialogView({
    super.key,
    required this.data,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GameDialogShell(
      title: l10n.aiAssistantTitle,
      headerColor: const Color(0xFF0036F9),
      iconAsset: AppAssets.iconGameSparkle,
      child: data.isLoading
          ? _LoadingBody()
          : _AIAssistantBody(data: data, onDismiss: onDismiss),
    );
  }
}

class GameAudiencePollDialogView extends StatelessWidget {
  final GameAudiencePollDialog data;
  final VoidCallback onDismiss;

  const GameAudiencePollDialogView({
    super.key,
    required this.data,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GameDialogShell(
      title: l10n.audienceHelpTitle,
      headerColor: const Color(0xFF0036F9),
      iconAsset: AppAssets.iconGameAudience,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in data.items) AudiencePollRow(item: item),
          const SizedBox(height: AppTokens.spacingMd),
          GameDialogButton(
            text: l10n.understandButton.toUpperCase(),
            color: AppTokens.qzdsPurple500,
            icon: Icons.check_circle,
            onTap: onDismiss,
          ),
        ],
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: _thinkingSpinnerSize,
            height: _thinkingSpinnerSize,
            child: CircularProgressIndicator(
              color: AppTokens.qzdsPurple500,
              strokeWidth: _thinkingSpinnerStroke,
            ),
          ),
          const SizedBox(height: AppTokens.spacingMd),
          Text(l10n.aiThinkingMessage),
        ],
      ),
    );
  }
}

class _AIAssistantBody extends StatelessWidget {
  final GameAIAssistantDialog data;
  final VoidCallback onDismiss;

  const _AIAssistantBody({required this.data, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      key: const ValueKey('ai-assistant-result'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacingLg,
            vertical: AppTokens.spacingSm,
          ),
          decoration: BoxDecoration(
            color: AppTokens.green500.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.task_alt,
                size: AppTokens.qzdsIconSm,
                color: AppTokens.green400,
              ),
              const SizedBox(width: AppTokens.spacingXs),
              Flexible(
                child: Text(
                  data.selectedAnswer,
                  textAlign: TextAlign.center,
                  style: AppTokens.qzdsSubtitle2.copyWith(
                    color: AppTokens.green400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.spacingSm),
        Text(
          '${data.confidencePercentage}%',
          style: AppTokens.headline5.copyWith(
            color: const Color(0xFF325DFA),
            fontSize: 32,
          ),
        ),
        Text(
          data.explanation,
          textAlign: TextAlign.center,
          style: AppTokens.qzdsCaption1.copyWith(color: Colors.black),
        ),
        const SizedBox(height: AppTokens.spacingMd),
        GameDialogButton(
          text: l10n.understandButton.toUpperCase(),
          color: AppTokens.qzdsPurple500,
          icon: Icons.check_circle,
          onTap: onDismiss,
          textGlow: true,
        ),
      ],
    );
  }
}
