import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/app_design_tokens.dart';
import '../../core/onboarding_design_tokens.dart';
import '../../data/onboarding/onboarding_content_data.dart';
import '../../data/onboarding/onboarding_step_data.dart';
import '../../data/settings/supported_language_data.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_chip_row.dart';
import 'onboarding_game_button.dart';

class OnboardingStepActions extends StatelessWidget {
  final OnboardingStepState step;
  final VoidCallback onNextStep;
  final VoidCallback onSkipStep;
  final VoidCallback onEnableNotifications;
  final ValueChanged<SupportedLanguageData> onLanguageSelected;
  final VoidCallback onFinish;

  const OnboardingStepActions({
    super.key,
    required this.step,
    required this.onNextStep,
    required this.onSkipStep,
    required this.onEnableNotifications,
    required this.onLanguageSelected,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedSwitcher(
      duration: OnboardingTokens.motionLong,
      transitionBuilder: (child, animation) {
        final scale = Tween<double>(begin: 0.92, end: 1).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
      child: _buildActions(l10n),
    );
  }

  Widget _buildActions(AppLocalizations l10n) {
    return switch (step) {
      OnboardingWelcomeStep(:final selectedLanguageCode) => _WelcomeActions(
        key: ValueKey('onboarding-actions-welcome-$selectedLanguageCode'),
        selectedLanguageCode: selectedLanguageCode,
        onLanguageSelected: onLanguageSelected,
        onNextStep: onNextStep,
        l10n: l10n,
      ),
      OnboardingNotificationStep(:final isEnabled) => _NotificationActions(
        key: ValueKey('onboarding-actions-notification-$isEnabled'),
        step: step as OnboardingNotificationStep,
        l10n: l10n,
        onEnableNotifications: onEnableNotifications,
        onSkipStep: onSkipStep,
        onNextStep: onNextStep,
      ),
      OnboardingReadyStep() => _ReadyActions(
        key: const ValueKey('onboarding-actions-ready'),
        l10n: l10n,
        onFinish: onFinish,
      ),
    };
  }
}

class _WelcomeActions extends StatelessWidget {
  final String? selectedLanguageCode;
  final ValueChanged<SupportedLanguageData> onLanguageSelected;
  final VoidCallback onNextStep;
  final AppLocalizations l10n;

  const _WelcomeActions({
    super.key,
    required this.selectedLanguageCode,
    required this.onLanguageSelected,
    required this.onNextStep,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LanguageChipRow(
          selectedLanguageCode: selectedLanguageCode,
          onLanguageSelected: onLanguageSelected,
        ),
        const SizedBox(height: AppTokens.spacingMd),
        OnboardingGameButton(
          scale: QzdsButtonScale.large,
          text: l10n.nextButton,
          color: OnboardingTokens.purple500,
          textGlow: true,
          onTap: onNextStep,
        ),
      ],
    );
  }
}

class _NotificationActions extends StatelessWidget {
  final OnboardingNotificationStep step;
  final AppLocalizations l10n;
  final VoidCallback onEnableNotifications;
  final VoidCallback onSkipStep;
  final VoidCallback onNextStep;

  const _NotificationActions({
    super.key,
    required this.step,
    required this.l10n,
    required this.onEnableNotifications,
    required this.onSkipStep,
    required this.onNextStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ReminderPreviewRow(step: step, l10n: l10n),
        const SizedBox(height: AppTokens.spacingMd),
        if (step.isEnabled)
          OnboardingGameButton(
            scale: QzdsButtonScale.large,
            text: l10n.nextButton,
            color: OnboardingTokens.purple500,
            textGlow: true,
            onTap: onNextStep,
          )
        else ...[
          OnboardingGameButton(
            scale: QzdsButtonScale.large,
            text: l10n.enableNotificationsButton,
            color: OnboardingTokens.blue500,
            onTap: onEnableNotifications,
          ),
          const SizedBox(height: AppTokens.spacingXs),
          OnboardingGameButton(
            scale: QzdsButtonScale.large,
            text: l10n.maybeLaterButton,
            color: OnboardingTokens.grey600,
            onTap: onSkipStep,
          ),
        ],
      ],
    );
  }
}

/// Shows the reminder the player is being asked to allow, so the permission
/// prompt has a concrete reason attached to it.
class _ReminderPreviewRow extends StatelessWidget {
  final OnboardingNotificationStep step;
  final AppLocalizations l10n;

  const _ReminderPreviewRow({required this.step, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('onboarding-reminder-preview'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.qzdsSpacingSm,
        vertical: AppTokens.qzdsSpacingXs * 2,
      ),
      decoration: OnboardingTokens.infoTileDecoration,
      child: Row(
        children: [
          Container(
            width: OnboardingTokens.headerHeight - AppTokens.qzdsSpacingXs,
            height: OnboardingTokens.headerHeight - AppTokens.qzdsSpacingXs,
            padding: const EdgeInsets.all(AppTokens.qzdsSpacingXs * 2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTokens.settingsIconGradient,
            ),
            child: SvgPicture.asset(AppAssets.iconFilter),
          ),
          const SizedBox(width: AppTokens.qzdsSpacingSm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onboardingNotificationTimeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTokens.body4.copyWith(
                    color: OnboardingTokens.grey700,
                  ),
                ),
                Text(
                  l10n.onboardingNotificationTimeHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTokens.caption3.copyWith(
                    color: OnboardingTokens.grey400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.qzdsSpacingXs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.qzdsSpacingSm,
              vertical: AppTokens.qzdsSpacingXs,
            ),
            decoration: BoxDecoration(
              color: OnboardingTokens.yellow500,
              borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusMd),
            ),
            child: Text(
              step.formattedTime,
              style: AppTokens.body5.copyWith(color: AppTokens.white100),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyActions extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onFinish;

  const _ReadyActions({super.key, required this.l10n, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _ReadyFactChip(
                value: '$onboardingQuestionCount',
                label: l10n.onboardingReadyQuestionsLabel,
                valueColor: OnboardingTokens.purple600,
              ),
            ),
            const SizedBox(width: AppTokens.qzdsSpacingXs * 2),
            Expanded(
              child: _ReadyFactChip(
                value: '$onboardingLifelineCount',
                label: l10n.onboardingReadyLifelinesLabel,
                valueColor: OnboardingTokens.purple600,
              ),
            ),
            const SizedBox(width: AppTokens.qzdsSpacingXs * 2),
            Expanded(
              child: _ReadyFactChip(
                value: '↑',
                label: l10n.onboardingReadyLadderLabel,
                valueColor: OnboardingTokens.yellow600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.spacingMd),
        OnboardingGameButton(
          scale: QzdsButtonScale.large,
          text: l10n.getStartedButton,
          color: OnboardingTokens.accentGreen500,
          textGlow: true,
          onTap: onFinish,
        ),
      ],
    );
  }
}

class _ReadyFactChip extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _ReadyFactChip({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.qzdsSpacingSm,
        vertical: AppTokens.spacingSm,
      ),
      decoration: OnboardingTokens.infoTileDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTokens.numeric1.copyWith(color: valueColor),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTokens.caption3.copyWith(color: OnboardingTokens.grey400),
          ),
        ],
      ),
    );
  }
}
