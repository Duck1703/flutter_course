# M18 — IMPLEMENTATION EVIDENCE (Flux)

## Files added

| File | Shape |
|---|---|
| `lib/data/onboarding/onboarding_step_data.dart` | **senior-identical**: sealed `OnboardingStepState` + `OnboardingStepType{welcome,notification,ready}` + `stepOrder`; `OnboardingWelcomeStep{selectedLanguageCode}`; `OnboardingNotificationStep{isEnabled,hour,minute}` + `formattedTime` + `copyWith`; `OnboardingReadyStep`; value `==`/`hashCode` on all |
| `lib/data/onboarding/onboarding_content_data.dart` | simplified: `onboardingTitleFor`/`onboardingDescriptionFor` (l10n strings only — no `OnboardingHeaderConfig`/tokens/badges, FR-32); `onboardingQuestionCount` from `quizQuestions`; `onboardingLifelineCount = 3` |
| `lib/view_models/onboarding/onboarding_view_model.dart` | **senior-identical** logic: step list, `currentStep=_steps.first`, `loadOnboarding`, `nextStep`/`skipStep`→`_advanceStep` (removeAt(0), empty→persist), `selectLanguage` (+`_languageSelectionInProgress` guard), `skipIntro`, `onNotificationPermissionResult`, `_completedSubscription`→`_handleCompletionChanged`, `listEquals`+`List.unmodifiable`, `_isDisposed`, `dispose` |
| `lib/widgets/common/language_chip_row.dart` | **promoted shared widget** at senior's file location; learner chip styling (MenuTokens) |
| `lib/widgets/onboarding/onboarding_overlay_scope.dart` | scope: `didChangeDependencies` identical-guard + `loadOnboardingCompleted()` kick; `FutureBuilder` gate → `ChangeNotifierProvider<OnboardingViewModel>..loadOnboarding()` → connector |
| `lib/widgets/onboarding/onboarding_overlay.dart` | scrim + opaque tap absorber + centered scrollable card + 3-dot indicator + per-step actions (`FilledButton`/`TextButton`) |
| `test/onboarding_view_model_test.dart` | 7 tests — seed/advance/persist/skipIntro/selectLanguage/permission-result/stream-clear |
| `test/widgets/onboarding_overlay_test.dart` | 5 tests — fresh→welcome over menu; 3-step walk→persist+hide; skip→persist+hide; completed→hidden; language chip→settings persist |

## Files modified

- `menu_screen.dart` — `Stack` wraps body; `Positioned.fill(child:
  OnboardingOverlayScope())` (senior `menu_screen_view.dart` pattern).
- `settings_dialog.dart` — `_LanguageChipRow` removed; shared
  `LanguageChipRow` imported (call-site unchanged).
- `game_screen.dart` — `l10n.nextButton` → `l10n.gameNextButton`
  (key collision: senior's `nextButton` belongs to onboarding).
- `app_en.arb`/`app_vi.arb` — +15 senior onboarding keys verbatim →
  **64 keys each**; `nextButton` now carries senior value
  ("Next"/"Tiếp tục"); learner's old game key renamed
  `gameNextButton` ("NEXT"/"TIẾP") so the game button text is
  unchanged. Generated files regenerated via `flutter gen-l10n`.
- 3 test files — `setMockInitialValues` gains
  `'onboarding_completed': true` (menu tests run post-onboarding;
  overlay's opaque scrim otherwise absorbs taps).

## Deliberate simplifications (registered)

- **FR-32 (new)**: no `BackdropFilter`/`AnimatedSwitcher`/
  `OnboardingTokens` gradients/badges/`OnboardingGameButton`; static
  dots; scope drops senior's inner `StreamBuilder` (VM's own stream
  subscription covers it). Converges at M28 visual-parity pass.
- **FR-27 (extended)**: "Bật thông báo" →
  `viewModel.onNotificationPermissionResult(true)` (simulated grant —
  no `LocalNotificationService`); same M27 convergence target.
- **FR-31 (updated)**: onboarding l10n landed; remaining delta =
  quiz-bank + repo errors + casing convention.

## Gate verification

- `flutter analyze`: **clean**.
- `flutter test`: **102/102** (90 → +7 VM +5 widget).
- `flutter gen-l10n`: exit 0; 64-key classes regenerated.
- `flutter build web`: ✓.
- Senior repo `main@c8eb860`: unchanged (verified `git status`).
- Onboarding repo impl: **untouched** (already senior-identical M14).
