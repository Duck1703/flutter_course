import '../../core/app_assets.dart';
import '../../core/onboarding_design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../game/game_sample_questions_data.dart';
import 'onboarding_header_config.dart';
import 'onboarding_step_data.dart';

/// Questions a full round serves, read from the shipped question bank so the
/// onboarding promise cannot drift from the game.
int get onboardingQuestionCount => gameSampleQuestions.length;

/// Help lifelines available in a round: 50:50, audience poll, and AI assistant.
/// Walk away and exit are controls, not lifelines.
const onboardingLifelineCount = 3;

OnboardingHeaderConfig onboardingHeaderFor(
  OnboardingStepType type,
  AppLocalizations l10n,
) {
  return switch (type) {
    OnboardingStepType.welcome => OnboardingHeaderConfig(
      title: l10n.onboardingWelcomeTitle,
      color: OnboardingTokens.purple500,
      badgeGradient: OnboardingTokens.badgeGradient(
        OnboardingTokens.purple500,
        OnboardingTokens.purple700,
      ),
      badgeAsset: AppAssets.iconGameSparkle,
    ),
    OnboardingStepType.notification => OnboardingHeaderConfig(
      title: l10n.onboardingNotificationTitle,
      color: OnboardingTokens.yellow500,
      badgeGradient: OnboardingTokens.badgeGradient(
        OnboardingTokens.yellow500,
        OnboardingTokens.yellow600,
      ),
      badgeAsset: AppAssets.iconBellNotification,
    ),
    OnboardingStepType.ready => OnboardingHeaderConfig(
      title: l10n.onboardingReadyTitle,
      color: OnboardingTokens.accentGreen500,
      badgeGradient: OnboardingTokens.badgeGradient(
        OnboardingTokens.accentGreen500,
        OnboardingTokens.accentGreen700,
      ),
      badgeAsset: AppAssets.iconGameTrophy,
    ),
  };
}

String onboardingDescriptionFor(
  OnboardingStepType type,
  AppLocalizations l10n,
) {
  return switch (type) {
    OnboardingStepType.welcome => l10n.onboardingWelcomeDescription,
    OnboardingStepType.notification => l10n.onboardingNotificationDescription,
    OnboardingStepType.ready => l10n.onboardingReadyDescription,
  };
}
