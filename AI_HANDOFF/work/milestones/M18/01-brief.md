# ATLAS BRIEF — M18: Onboarding overlay (first run)

## SENIOR FIDELITY CHECK

**Senior target:** first-run onboarding rendered as an in-`Stack`
overlay inside the menu screen — not a route. Sealed
`OnboardingStepState` (welcome / notification / ready) drives step
content; `OnboardingViewModel` holds a `List<OnboardingStepState>`,
`currentStep = _steps.first`, advances via `removeAt(0)`, persists
completion via `OnboardingRepository.setOnboardingCompleted()`.
`OnboardingOverlayScope` gates render: `didChangeDependencies`
identical-guards the repo and starts `loadOnboardingCompleted()`;
a `FutureBuilder` waits for the load, then a `StreamBuilder` on
`onboardingCompletedStream` keeps hiding the overlay after completion.
While incomplete it hosts a `ChangeNotifierProvider<OnboardingViewModel>`
(overlay-scoped VM — third lifetime tier after app/screen/dialog).
Welcome step carries language chips that write `languageCode` through
`UserSettingsRepository` (locale flips live via M17 wiring);
`_languageSelectionInProgress` flag guards re-entrancy.
Notification step offers "enable / maybe later": senior calls
`LocalNotificationService.requestPermission()` then
`onNotificationPermissionResult(granted)` — granted=true sets
`isEnabled` + auto-advances, granted=false stays (isEnabled=false).

**Senior files/symbols:**
- `lib/widgets/onboarding/onboarding_overlay_scope.dart` — gating
  chain + scoped VM + `_requestNotificationPermission` service call
- `lib/widgets/onboarding/onboarding_overlay.dart` —
  `AnimatedSwitcher` hidden↔visible; `BackdropFilter` blur + haze
  scrim + opaque tap absorber; scrollable centered card
- `onboarding_step_actions.dart` / `onboarding_step_indicator.dart` /
  `onboarding_dialog_card.dart` / `onboarding_game_button.dart`
- `lib/view_models/onboarding/onboarding_view_model.dart` — step-list
  model, `listEquals` guard, `List.unmodifiable`, `_isDisposed`,
  `_completedSubscription` clears steps on external completion,
  `skipIntro`, `selectLanguage`, `onNotificationPermissionResult`
- `lib/data/onboarding/onboarding_step_data.dart` — sealed family +
  `stepOrder` const + `formattedTime`/`copyWith`/`==`
- `lib/data/onboarding/onboarding_content_data.dart` —
  `onboardingHeaderFor`/`onboardingDescriptionFor` (l10n + tokens +
  badge assets), `onboardingQuestionCount` from game bank,
  `onboardingLifelineCount = 3`
- `lib/widgets/menu/menu_screen_view.dart` — `Positioned.fill(child:
  OnboardingOverlayScope())` inside the menu `Stack`
- `lib/widgets/common/language_chip_row.dart` — shared chip row used
  by settings AND onboarding welcome
- Senior ARB keys (16): `onboardingWelcomeTitle`,
  `onboardingWelcomeDescription`, `onboardingNotificationTitle`,
  `onboardingNotificationDescription`, `onboardingNotificationTimeLabel`,
  `onboardingNotificationTimeHint`, `onboardingReadyTitle`,
  `onboardingReadyDescription`, `onboardingReadyQuestionsLabel`,
  `onboardingReadyLifelinesLabel`, `onboardingReadyLadderLabel`,
  `onboardingSkipIntroButton`, `nextButton`, `maybeLaterButton`,
  `enableNotificationsButton`, `getStartedButton` (en+vi values
  captured verbatim from senior ARB)

**Current learner state:** `OnboardingRepository` contract+impl
identical-to-senior (M14) + `FakeOnboardingRepository`; repo already
in `MultiProvider` and `main()` `create()`s it; `SupportedLanguageData`
senior-identical; l10n infra live (M17); private `_LanguageChipRow`
inside `settings_dialog.dart`; `menu_screen.dart` Scaffold has no
Stack; no onboarding dirs under `lib/`.

**Senior target state after M18:** fresh install → 3-step overlay over
menu; completion/skip persists `'onboarding_completed'` → never shows
again; language picked in welcome flips app locale live; notification
step records choice (real permission → M27); menu becomes the
senior-pattern host: content + `Positioned.fill` overlay in `Stack`.

## LEARNING DESIGN CHECK

**New concepts (≤3/lesson):** D-32 `listEquals` + `List.unmodifiable`
step-list model; F-26 in-`Stack` overlay gating (`Stack`/`Positioned.
fill`/scrim absorbs taps — visibility = state, not route); A-17
overlay-scoped VM (4th lifetime tier: app→screen→dialog→overlay) +
guarded async flow (`_languageSelectionInProgress`).
Registry additions before lessons ship; prereq edges: M18 ← M14 (repo),
M15 (sealed), M16 (language persist), M17 (l10n wiring).

**Lesson split (5):**
1. `01-vi-sao-overlay-khong-phai-route` — why overlay ≠ route;
   visibility-as-state mental model (Android bridge: Compose box
   overlay).
2. `02-step-state-sealed-onboarding` — sealed `OnboardingStepState`
   family + `stepOrder` + content data file.
3. `03-onboarding-view-model` — step-list VM: `listEquals`,
   `List.unmodifiable`, guarded async, stream-clear. **CORE.**
4. `04-overlay-scope-va-menu-stack` — scope widget + gating
   (simplified vs senior chain, explicit) + `Positioned.fill` in menu.
5. `05-hoan-thien-tests-tu-lam` — ARB onboarding keys + language
   select wiring + widget tests + regression + Tự làm.

## REQUIRED IMPLEMENTATION (Flux)

- `lib/data/onboarding/onboarding_step_data.dart` — **senior-identical**
  sealed family (3 types, `stepOrder`, `formattedTime`, `copyWith`,
  value equality).
- `lib/data/onboarding/onboarding_content_data.dart` — title/
  description per step via l10n (learner-simple: strings only, no
  token/badge `OnboardingHeaderConfig`); `onboardingQuestionCount`
  from `quizQuestions` bank; `onboardingLifelineCount = 3`.
- `lib/view_models/onboarding/onboarding_view_model.dart` —
  **senior-identical** VM (step list, `listEquals`, `List.unmodifiable`,
  `_completedSubscription`, `skipIntro`, `selectLanguage`,
  `onNotificationPermissionResult`, `_isDisposed`, `dispose`).
- `lib/widgets/common/language_chip_row.dart` — promote shared
  `LanguageChipRow` (senior file location); settings dialog switches
  to it; onboarding welcome reuses it (learner-styled chip internals
  OK — file placement is the convergence point).
- `lib/widgets/onboarding/onboarding_overlay_scope.dart` — scope:
  StatefulWidget, `didChangeDependencies` identical-guard + kick
  `loadOnboardingCompleted()`; build = `FutureBuilder` gate →
  `ChangeNotifierProvider<OnboardingViewModel>` → connector.
  **Simplification:** VM's own stream subscription replaces senior's
  inner `StreamBuilder` (roadmap: exact chain EXPLAIN_ONLY).
- `lib/widgets/onboarding/onboarding_overlay.dart` — scrim
  `ColoredBox` + opaque `GestureDetector` tap-absorber + centered
  scrollable card + step indicator dots (static) + per-step actions.
  **Simplifications vs senior:** no `BackdropFilter`, no
  `AnimatedSwitcher`, no `OnboardingTokens` gradients/badges, no
  `OnboardingGameButton` — plain `FilledButton`/`TextButton` + learner
  `MenuTokens` colors.
- `menu_screen.dart` — `Scaffold` body wrapped in `Stack` +
  `Positioned.fill(child: OnboardingOverlayScope())`.
- Notification step: **no real permission request** — "Bật thông báo"
  calls `viewModel.onNotificationPermissionResult(true)` (simulated
  grant → enabled + advance); "Để sau" → `skipStep`. Documented as
  FR-27 extension (same M27 convergence).
- ARB: add the 16 senior onboarding keys to BOTH `app_en.arb` +
  `app_vi.arb` with senior values verbatim → 64 keys; `flutter gen-l10n`.

## TESTS REQUIRED

- `test/onboarding_view_model_test.dart`: seeded steps from settings;
  `nextStep`/`skipStep` advance; last step → `setOnboardingCompleted`;
  `skipIntro` persists + clears; `selectLanguage` writes settings +
  updates welcome step; re-entrant `selectLanguage` guarded;
  `onNotificationPermissionResult(true)` enables+advances / (false)
  stays; external stream `true` clears steps.
- `test/widgets/onboarding_overlay_test.dart`: fresh (not completed)
  → overlay renders welcome; complete → flag persisted + overlay
  hides; completed repo → no overlay; step advance widget flow.
- Existing suite must stay green (`locale: vi` hosts via
  `localized_test_app.dart`).

## REGISTER DISPOSITION

- FR-27: extend description — onboarding "enable notifications" also
  simulated (no `LocalNotificationService`); M27 unchanged.
- FR-31: update — onboarding keys landed (16 keys); remaining delta =
  quiz-bank + repo errors + casing convention only.
- **New FR-32**: onboarding visual simplification (no BackdropFilter/
  AnimatedSwitcher/OnboardingTokens/badges/GameButton; indicator
  static) → M28 visual-parity pass; `ACTIVE_TEMPORARY`.
- `OnboardingOverlayScope` gating simplification (VM stream sub
  replaces inner StreamBuilder) → fold into FR-32 description.

## OUT OF SCOPE

Real notification permission, `LocalNotificationService`, onboarding
replay-after-reset linkage (senior has none either), quiz-bank l10n,
PopScope/back-button semantics (senior doesn't gate back either —
overlay absorbs taps only), M19 game refactor.

## ACCEPTANCE

`flutter analyze` clean; `flutter test` green (new +3 VM tests,
+3–4 widget tests); `flutter build web` pass; `flutter gen-l10n`
regenerates 64-key localizations; fresh-install→overlay→complete→
hidden proven by widget test; senior repo unchanged.
