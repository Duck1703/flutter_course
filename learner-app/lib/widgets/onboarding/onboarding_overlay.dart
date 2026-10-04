import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/app_design_tokens.dart';
import '../../core/onboarding_design_tokens.dart';
import '../../data/onboarding/onboarding_content_data.dart';
import '../../data/onboarding/onboarding_step_data.dart';
import '../../data/settings/supported_language_data.dart';
import '../../l10n/app_localizations.dart';
import '../common/design_frame.dart';
import 'onboarding_dialog_card.dart';
import 'onboarding_step_actions.dart';
import 'onboarding_step_indicator.dart';

class OnboardingOverlay extends StatelessWidget {
  final OnboardingStepState? step;
  final VoidCallback onNextStep;
  final VoidCallback onSkipStep;
  final VoidCallback onEnableNotifications;
  final ValueChanged<SupportedLanguageData> onLanguageSelected;
  final VoidCallback onFinish;
  final VoidCallback onSkipIntro;

  const OnboardingOverlay({
    super.key,
    required this.step,
    required this.onNextStep,
    required this.onSkipStep,
    required this.onEnableNotifications,
    required this.onLanguageSelected,
    required this.onFinish,
    required this.onSkipIntro,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedSwitcher(
        duration: OnboardingTokens.motionSlow,
        switchInCurve: Curves.linear,
        switchOutCurve: Curves.linear,
        child: step == null
            ? const SizedBox.shrink(key: ValueKey('onboarding-hidden'))
            : _OnboardingVisibleOverlay(
                key: const ValueKey('onboarding-visible'),
                step: step!,
                onNextStep: onNextStep,
                onSkipStep: onSkipStep,
                onEnableNotifications: onEnableNotifications,
                onLanguageSelected: onLanguageSelected,
                onFinish: onFinish,
                onSkipIntro: onSkipIntro,
              ),
      ),
    );
  }
}

class _OnboardingVisibleOverlay extends StatelessWidget {
  final OnboardingStepState step;
  final VoidCallback onNextStep;
  final VoidCallback onSkipStep;
  final VoidCallback onEnableNotifications;
  final ValueChanged<SupportedLanguageData> onLanguageSelected;
  final VoidCallback onFinish;
  final VoidCallback onSkipIntro;

  const _OnboardingVisibleOverlay({
    super.key,
    required this.step,
    required this.onNextStep,
    required this.onSkipStep,
    required this.onEnableNotifications,
    required this.onLanguageSelected,
    required this.onFinish,
    required this.onSkipIntro,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppTokens.dialogHazeBlurSigma,
          sigmaY: AppTokens.dialogHazeBlurSigma,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: ColoredBox(
            color: OnboardingTokens.hazeScrim,
            child: SafeArea(
              child: DesignFrame(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.spacingMd,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: _OnboardingContent(
                              step: step,
                              onNextStep: onNextStep,
                              onSkipStep: onSkipStep,
                              onEnableNotifications: onEnableNotifications,
                              onLanguageSelected: onLanguageSelected,
                              onFinish: onFinish,
                              onSkipIntro: onSkipIntro,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  final OnboardingStepState step;
  final VoidCallback onNextStep;
  final VoidCallback onSkipStep;
  final VoidCallback onEnableNotifications;
  final ValueChanged<SupportedLanguageData> onLanguageSelected;
  final VoidCallback onFinish;
  final VoidCallback onSkipIntro;

  const _OnboardingContent({
    required this.step,
    required this.onNextStep,
    required this.onSkipStep,
    required this.onEnableNotifications,
    required this.onLanguageSelected,
    required this.onFinish,
    required this.onSkipIntro,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: OnboardingTokens.motionEmphasis,
          child: OnboardingDialogCard(
            key: ValueKey('onboarding-card-${step.type}'),
            header: onboardingHeaderFor(step.type, l10n),
            description: onboardingDescriptionFor(step.type, l10n),
            actions: OnboardingStepActions(
              step: step,
              onNextStep: onNextStep,
              onSkipStep: onSkipStep,
              onEnableNotifications: onEnableNotifications,
              onLanguageSelected: onLanguageSelected,
              onFinish: onFinish,
            ),
          ),
        ),
        const SizedBox(height: AppTokens.spacingLg),
        OnboardingStepIndicator(currentStepType: step.type),
        if (step.type != OnboardingStepType.ready) ...[
          const SizedBox(height: AppTokens.spacingMd),
          _SkipIntroLink(
            label: l10n.onboardingSkipIntroButton,
            onTap: onSkipIntro,
          ),
        ],
        const SizedBox(height: AppTokens.spacingMd),
      ],
    );
  }
}

/// Escape hatch that finishes onboarding immediately. Shown on every step
/// except the last one, where the primary action already ends the flow.
class _SkipIntroLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SkipIntroLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        key: const ValueKey('onboarding-skip-intro'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTokens.spacingXs),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTokens.body4.copyWith(color: AppTokens.white65),
          ),
        ),
      ),
    );
  }
}
