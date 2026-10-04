# M18 Implementation Notes — Onboarding overlay (first run)

## What landed (learner-app)

- `lib/data/onboarding/onboarding_step_data.dart`: sealed
  `OnboardingStepState` family — `OnboardingWelcomeStep`
  (`selectedLanguageCode`), `OnboardingNotificationStep`
  (`isEnabled`/`hour`/`minute` + `formattedTime`),
  `OnboardingReadyStep`; `OnboardingStepType` + `static const
  stepOrder`; value `==`/`hashCode` + `copyWith`. Senior-identical.
- `lib/data/onboarding/onboarding_content_data.dart`:
  `onboardingQuestionCount` (derived from question bank),
  `onboardingLifelineCount`, localized title/description helpers
  (UI passes `AppLocalizations` strings — context-free per A-16).
- `lib/repositories/onboarding/onboarding_repository.dart` (from
  M14, now first consumer): `onboarding_completed` SharedPreferences
  key, `BehaviorSubject<bool>.seeded(false)`,
  `loadOnboardingCompleted`, `setOnboardingCompleted`,
  `ValueStream<bool>`.
- `lib/view_models/onboarding/onboarding_view_model.dart`:
  **senior-identical** — `_steps` queue (`currentStep =
  _steps.first`), `loadOnboarding` seeds welcome/notification from
  persisted settings, `nextStep`/`skipStep` = `removeAt(0)` →
  persist on exhaustion, `skipIntro`, `selectLanguage` with
  `_languageSelectionInProgress` guard,
  `onNotificationPermissionResult`, `_completedSubscription` stream
  self-clear, `_isDisposed` guard, `listEquals` +
  `List.unmodifiable` emit discipline.
- `lib/widgets/onboarding/onboarding_overlay_scope.dart`: gate —
  `didChangeDependencies` + `identical()`-guarded
  `loadOnboardingCompleted()` Future → `FutureBuilder` →
  `SizedBox.shrink` until done / if completed → else
  `ChangeNotifierProvider<OnboardingViewModel>` (overlay-scoped,
  4th lifetime tier) + `..loadOnboarding()`. FR-27: enable button
  calls `onNotificationPermissionResult(true)` — simulated grant.
- `lib/widgets/onboarding/onboarding_overlay.dart`: `ColoredBox`
  scrim + `GestureDetector(behavior: opaque)` tap absorber +
  centered scrollable card + static dot indicator over `stepOrder`
  + per-step action widgets + skip button.
- `lib/widgets/common/language_chip_row.dart`: `_LanguageChipRow`
  promoted to public `LanguageChipRow` at the senior file path;
  `settings_dialog.dart` updated to consume it.
- `lib/screens/menu_screen.dart`: body wrapped in `Stack` +
  `Positioned.fill(child: OnboardingOverlayScope())` — senior host
  pattern (`menu_screen_view.dart:95`).
- `lib/l10n/app_{en,vi}.arb`: +16 senior-verbatim onboarding keys;
  game-screen `nextButton` renamed `gameNextButton` (call site in
  `game_screen.dart`) to resolve key collision — **64 keys each**.
- `lib/main.dart` + `lib/core/app_dependency_scope.dart`:
  `OnboardingRepositoryImpl` constructed and exposed via
  `Provider<OnboardingRepository>.value`.
- Tests: `test/onboarding_view_model_test.dart` (7 — incl.
  persisted hour/minute seeding assertion added post-QA);
  `test/widgets/onboarding_overlay_test.dart` (5); test hosts
  re-seeded `{'onboarding_completed': true}`:
  `menu_screen_ui_events_test.dart` (1), `menu_provider_scope_test.dart`
  (2), `game_screen_test.dart` (1). **102/102**.

## Register deltas

- **FR-32 OPEN** — onboarding visual/gating depth (no
  `BackdropFilter`/`AnimatedSwitcher`/badge/`OnboardingGameButton`/
  header-config; scope drops inner `StreamBuilder`) → M28 parity.
- **FR-27 extended** — onboarding grant simulated
  (`onNotificationPermissionResult(true)`); real permission +
  scheduling → M27.
- **FR-31 updated** — 16 onboarding keys landed; remaining
  quiz-bank/repo strings + casing convention.

## Lessons (canonical)

`AI_HANDOFF/work/milestones/M18/lessons/` — index + 5 (L03 CORE:
step-queue VM). Site copies at `web/src/content/docs/m18/`
byte-identical (md5-verified).

## Verification

`flutter analyze` clean; `flutter test` **102/102**;
`flutter build web` pass; `npm run build` — **95 pages** (+6 routes).
Sequential replay on M17-end clone: 5/5 checkpoints PASS, zero
defects. Senior repo unchanged at `c8eb860`.
