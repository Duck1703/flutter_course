import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../core/onboarding_design_tokens.dart';
import '../data/onboarding/onboarding_content_data.dart';
import '../data/onboarding/onboarding_step_data.dart';
import '../l10n/app_localizations.dart';
import '../widgets/onboarding/onboarding_dialog_card.dart';
import '../widgets/onboarding/onboarding_game_button.dart';
import '../widgets/onboarding/onboarding_overlay.dart';
import '../widgets/onboarding/onboarding_step_actions.dart';
import '../widgets/onboarding/onboarding_step_indicator.dart';
import 'preview_fixtures.dart';

@Preview(
  name: 'Onboarding dialog card',
  group: 'Onboarding',
  size: Size(390, 420),
  wrapper: previewGameApp,
)
Widget onboardingDialogCardPreview() {
  return Builder(
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return OnboardingDialogCard(
        header: onboardingHeaderFor(OnboardingStepType.welcome, l10n),
        description: onboardingDescriptionFor(OnboardingStepType.welcome, l10n),
        actions: OnboardingStepActions(
          step: const OnboardingWelcomeStep(selectedLanguageCode: 'vi'),
          onNextStep: previewNoop,
          onSkipStep: previewNoop,
          onEnableNotifications: previewNoop,
          onLanguageSelected: previewLanguageTap,
          onFinish: previewNoop,
        ),
      );
    },
  );
}

@Preview(
  name: 'Onboarding game button',
  group: 'Onboarding',
  size: Size(360, 120),
  wrapper: previewGameApp,
)
Widget onboardingGameButtonPreview() {
  return OnboardingGameButton(
    text: 'Get started',
    color: OnboardingTokens.accentGreen500,
    textGlow: true,
    onTap: previewNoop,
  );
}

@Preview(
  name: 'Step actions notification',
  group: 'Onboarding',
  size: Size(360, 180),
  wrapper: previewGameApp,
)
Widget onboardingStepActionsPreview() {
  return OnboardingStepActions(
    step: const OnboardingNotificationStep(hour: 20, minute: 0),
    onNextStep: previewNoop,
    onSkipStep: previewNoop,
    onEnableNotifications: previewNoop,
    onLanguageSelected: previewLanguageTap,
    onFinish: previewNoop,
  );
}

@Preview(
  name: 'Step indicator',
  group: 'Onboarding',
  size: Size(220, 80),
  wrapper: previewGameApp,
)
Widget onboardingStepIndicatorPreview() {
  return const OnboardingStepIndicator(
    currentStepType: OnboardingStepType.notification,
  );
}

@Preview(
  name: 'Onboarding overlay',
  group: 'Onboarding',
  size: Size(390, 760),
  wrapper: previewLayerApp,
)
Widget onboardingOverlayPreview() {
  return OnboardingOverlay(
    step: const OnboardingReadyStep(),
    onNextStep: previewNoop,
    onSkipStep: previewNoop,
    onEnableNotifications: previewNoop,
    onLanguageSelected: previewLanguageTap,
    onFinish: previewNoop,
    onSkipIntro: previewNoop,
  );
}
