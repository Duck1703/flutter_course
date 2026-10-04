import 'package:ai_millionaire_course/data/onboarding/onboarding_step_data.dart';
import 'package:ai_millionaire_course/data/settings/supported_language_data.dart';
import 'package:ai_millionaire_course/widgets/onboarding/onboarding_overlay.dart';
import 'package:ai_millionaire_course/widgets/onboarding/onboarding_step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('welcome step merges greeting and language choice', (
    tester,
  ) async {
    SupportedLanguageData? selectedLanguage;
    var advanced = 0;

    await tester.pumpWidget(
      _TestApp(
        step: const OnboardingWelcomeStep(),
        onLanguageSelected: (language) => selectedLanguage = language,
        onNextStep: () => advanced++,
      ),
    );
    await tester.pump();

    expect(find.text('WELCOME TO AI QUIZ!'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Tiếng Việt'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
    expect(find.byType(OnboardingStepIndicator), findsOneWidget);

    await tester.tap(find.text('Tiếng Việt'));
    await tester.pump();

    expect(selectedLanguage, SupportedLanguageData.vietnamese);

    await tester.tap(find.text('NEXT'));
    await tester.pump();

    expect(advanced, 1);
  });

  testWidgets('skip intro link shows before the last step', (tester) async {
    var skipped = 0;

    await tester.pumpWidget(
      _TestApp(
        step: const OnboardingWelcomeStep(),
        onSkipIntro: () => skipped++,
      ),
    );
    await tester.pump();

    expect(find.text('Skip intro'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('onboarding-skip-intro')));
    await tester.pump();

    expect(skipped, 1);

    await tester.pumpWidget(const _TestApp(step: OnboardingReadyStep()));
    await tester.pumpAndSettle();

    expect(find.text('Skip intro'), findsNothing);
  });

  testWidgets('onboarding overlay renders notification actions', (
    tester,
  ) async {
    var enabledNotifications = false;

    await tester.pumpWidget(
      _TestApp(
        step: const OnboardingNotificationStep(hour: 20, minute: 0),
        onEnableNotifications: () => enabledNotifications = true,
      ),
    );
    await tester.pump();

    expect(find.text('YOUR DAILY REMINDER'), findsOneWidget);
    expect(find.text('Daily reminder time'), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);
    expect(find.text('ENABLE NOTIFICATIONS'), findsOneWidget);
    expect(find.text('MAYBE LATER'), findsOneWidget);

    await tester.tap(find.text('ENABLE NOTIFICATIONS'));
    await tester.pump();

    expect(enabledNotifications, isTrue);
  });

  testWidgets('onboarding overlay renders ready action', (tester) async {
    var finished = false;

    await tester.pumpWidget(
      _TestApp(
        step: const OnboardingReadyStep(),
        onFinish: () => finished = true,
      ),
    );
    await tester.pump();

    expect(find.text("YOU'RE ALL SET!"), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('questions'), findsOneWidget);
    expect(find.text('lifelines'), findsOneWidget);
    expect(find.text('prize ladder'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);

    await tester.tap(find.text('GET STARTED'));
    await tester.pump();

    expect(finished, isTrue);
  });

  testWidgets('onboarding overlay hides when step is null', (tester) async {
    await tester.pumpWidget(const _TestApp());
    await tester.pump();

    expect(find.text('WELCOME TO AI QUIZ!'), findsNothing);
    expect(find.byType(OnboardingStepIndicator), findsNothing);
  });

  testWidgets('hidden onboarding overlay does not block taps behind it', (
    tester,
  ) async {
    var backgroundTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  key: const ValueKey('background-tap-target'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => backgroundTaps++,
                ),
              ),
              const Positioned.fill(child: _TestOverlayOnly()),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('background-tap-target')));
    await tester.pump();

    expect(backgroundTaps, 1);
  });
}

class _TestApp extends StatelessWidget {
  final OnboardingStepState? step;
  final VoidCallback? onNextStep;
  final VoidCallback? onEnableNotifications;
  final ValueChanged<SupportedLanguageData>? onLanguageSelected;
  final VoidCallback? onFinish;
  final VoidCallback? onSkipIntro;

  const _TestApp({
    this.step,
    this.onNextStep,
    this.onEnableNotifications,
    this.onLanguageSelected,
    this.onFinish,
    this.onSkipIntro,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: OnboardingOverlay(
          step: step,
          onNextStep: onNextStep ?? () {},
          onSkipStep: () {},
          onEnableNotifications: onEnableNotifications ?? () {},
          onLanguageSelected: onLanguageSelected ?? (_) {},
          onFinish: onFinish ?? () {},
          onSkipIntro: onSkipIntro ?? () {},
        ),
      ),
    );
  }
}

class _TestOverlayOnly extends StatelessWidget {
  const _TestOverlayOnly();

  @override
  Widget build(BuildContext context) {
    return OnboardingOverlay(
      step: null,
      onNextStep: () {},
      onSkipStep: () {},
      onEnableNotifications: () {},
      onLanguageSelected: (_) {},
      onFinish: () {},
      onSkipIntro: () {},
    );
  }
}
