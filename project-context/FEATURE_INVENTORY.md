# Feature Inventory — Senior Application

Reconstructed from source evidence. Difficulty refers to a **Flutter
beginner** with Android experience. `Simplification` = recommended teaching
stance (TEACH_DIRECTLY / SIMPLIFY_FIRST / DELAY / EXPLAIN_ONLY_INITIALLY).

## F1 — App bootstrap & dependency scope

- **Purpose**: wire everything the app needs before first frame.
- **User-visible**: none directly; determines guest-vs-configured mode.
- **Entry**: `lib/main.dart` `main()` → `AIMillionaireApp`.
- **Key files**: `lib/main.dart`, `lib/core/app_dependency_scope.dart`,
  `lib/core/supabase_environment.dart`,
  `lib/services/supabase_client_service.dart`.
- **State**: `StreamBuilder` over `userSettingsStream` picks `locale`.
- **Data sources**: dart-defines env, `SharedPreferences` (settings).
- **Navigation**: installs `navigatorKey`; home `MenuScreen`.
- **Depends on**: all repositories/services.
- **Difficulty**: Medium — async `main`, `Provider`, `MaterialApp`.
- **Prerequisites**: async/await, WidgetsFlutterBinding, BuildContext,
  Provider basics, StreamBuilder, localization plumbing.
- **Teach**: SIMPLIFY_FIRST — start with a synchronous main + Provider of
  one repository; add async creation and dart-defines later.

## F2 — Menu hub screen

- **Purpose**: landing hub: profile header, stats, earnings, level
  progress, leaderboard entry, Start-Game CTA, settings gear.
- **User-visible**: avatar/level/username (guest: "0XFF"/"Guest"),
  VNĐ earnings, played/won/win-rate stats, EXP bar, buttons.
- **Entry**: `home: const MenuScreen()`.
- **Screens/widgets**: `lib/screens/menu_screen.dart`;
  `lib/widgets/menu/menu_screen_view.dart` (Stack + PopScope),
  `menu_screen_content.dart`, `profile/menu_profile_header.dart`,
  `profile/stats_card.dart`, `profile/earnings_card.dart`,
  `profile/level_progress_card.dart`, `gradient_cta_button.dart`,
  `leaderboard/leaderboard_entry_card.dart`, `common/game_screen_background.dart`,
  `common/design_frame.dart` (375px design frame).
- **VM/state**: `MenuScreenViewModel` (ChangeNotifier) subscribes to
  `userProfileStream` + `authStateStream`; `dialogState: MenuDialogState`
  sealed class drives `MenuDialogLayer`; `Stream<MenuScreenUiEvent>` for
  navigate/snackbar. `MenuLevelProgress` derives EXP/ratio/tier.
- **Data sources**: `UserProfileRepository`, `AuthRepository` (streams).
- **Navigation**: `MenuGameRequested` event → `AppNavigationController.openGame()`.
- **Depends on**: F1 scope, F3 profile persistence, dialogs F7–F10.
- **Difficulty**: Medium — first real Provider+stream VM.
- **Prerequisites**: StatelessWidget/StatefulWidget, Scaffold/Stack/Column,
  ChangeNotifier, context.read/watch, sealed classes, StreamSubscription
  lifecycle, SafeArea.
- **Teach**: SIMPLIFY_FIRST — static menu first, then stream-driven profile.

## F3 — Local profile & progression

- **Purpose**: persist guest profile: username, level, EXP, money won,
  games joined/won, question count, avatar URL.
- **User-visible**: values render on menu header/cards; level ring.
- **Entry**: repositories consumed by VMs; written by game result flow.
- **Key files**: `lib/repositories/profile/user_profile_repository.dart`
  (SharedPreferences JSON under `user_profile`, `BehaviorSubject`
  `ValueStream<UserProfileData>`), `lib/data/profile/user_profile_data.dart`
  (immutable model, `copyWith`, `fromMap`/`toMap`, equality, `formatVnd`,
  legacy-demo reset), `lib/data/game/level_config.dart` (XP thresholds,
  milestone multipliers 1–100), `lib/view_models/menu/menu_level_progress.dart`.
- **Difficulty**: Medium.
- **Prerequisites**: immutable models, JSON encode/decode, Futures,
  BehaviorSubject/ValueStream concept.
- **Teach**: TEACH_DIRECTLY after a plain SharedPreferences example —
  this is the friendliest repository pattern in the app.

## F4 — Game session (core gameplay)

- **Purpose**: 15-question timed quiz: money ladder intro, 30s per
  question, select→pending→reveal→explanation, wrong answer ends game,
  safe-haven guarantee, victory at Q15.
- **User-visible**: question panel, 4 animated answer options, countdown
  ring/pill, money amount animation, dialogs per phase.
- **Entry**: `GameScreen` pushed via `openGame()`; `..startNewGame()`.
- **Screens/widgets**: `lib/screens/game_screen.dart`;
  `widgets/game/layout/{game_screen_body,game_screen_top_bar}.dart`,
  `questions/game_question_panel.dart`,
  `answers/{game_answer_option,game_answer_option_list,...}.dart`,
  `timer/game_countdown_timer.dart` + `..._progress_painter.dart`
  (CustomPainter, TickerProvider),
  `money/{game_money_amount,game_money_amount_motion,game_money_ladder_cta_button,game_money_ladder_dialog}.dart`,
  `dialogs/{game_dialog_layer,game_confirm_dialogs,game_help_dialogs,game_result_dialogs,game_dialog_shell}.dart`.
- **VM/state**: `GameScreenViewModel extends DreChangeNotifier` —
  `GameAction` → `GameReducer` (pure, split into `game_reducer.dart` +
  `_answer_flow`/`_feature_flow`/`_session_flow`/`_timer_flow` parts) →
  `GameState.copyWith` + `GameEffect`s + `GameAsyncOp`. Effects handled in
  `bridge/game_screen_view_model_effects.dart` (Timer.periodic ticks,
  `Future.delayed` reveal/explanation/AI, navigate/share events).
  `GameSaveResult` op → `bridge/..._result_persistence.dart` → profile
  repo + conditional sync. `screenData` = presentation mapper output
  (`game_screen_presentation_mapper.dart`). `flowToken` guards stale
  delayed callbacks.
- **Data sources**: `gameSampleQuestions` (15 const items),
  `gameMoneyLadderLevels`, `UserProfileRepository`,
  `UserProfileSyncRepository` (if authed).
- **Navigation**: `GameNavigateToMenu` effect → UI event → `goBack()`;
  `PopScope(canPop:false)` → confirm-exit.
- **Depends on**: F3.
- **Difficulty**: **Hard** — the most advanced code in the app (custom
  reducer framework, sealed actions/effects, part files, timers, tokens).
- **Prerequisites**: everything in F1–F3 plus Timer, Future.delayed,
  sealed-class pattern matching, reducer/MVI concepts, StreamController.
- **Teach**: SIMPLIFY_FIRST — rebuild the game as a plain ChangeNotifier
  with setState-style milestones first; introduce DRE only after the
  simpler version works. EXPLAIN_ONLY_INITIALLY for `flowToken` and part-of
  organization.

## F5 — Lifelines / feature buttons

- **Purpose**: 50:50 (hide two wrong options), Ask the Audience (percentile
  dialog), Ask AI (loading→hint dialog), Walk Away, Exit Game.
- **User-visible**: bottom icon bar; single-use buttons disable.
- **Key files**: `widgets/game/lifelines/{game_feature_button,game_feature_button_bar,game_audience_poll_row}.dart`;
  reducer `_feature_flow.dart`; `support/game_lifeline_helper.dart`
  (`applyGameFiftyFifty`, `buildGameAudiencePoll` with difficulty-based
  percentages);
  `data/game/game_session_state_data.dart` dialog classes.
- **State**: `usedFeatureButtons` set, `audiencePercentiles`,
  `GameAudiencePollDialog`/`GameAIAssistantDialog` in `dialogState`.
- **Depends on**: F4.
- **Difficulty**: Medium-High (inherits F4 machinery; helpers are easy).
- **Teach**: SIMPLIFY_FIRST with the simplified game; TEACH_DIRECTLY the
  helper functions (pure Dart) early as exercises.

## F6 — Result dialogs & sharing

- **Purpose**: explanation after each answer; ended/victory dialogs with
  play-again/back-to-menu/share.
- **User-visible**: dialogs with blur backdrop; share sheet; snackbar copy
  fallback.
- **Key files**: `widgets/game/dialogs/*`, `screens/game_screen.dart`
  `_handleUiEvent` (share_plus `SharePlus.instance.share`,
  `Clipboard` fallback), `AppLocalizations` share strings.
- **State**: `GameDialogState` variants; terminal dialogs block dismiss.
- **Depends on**: F4.
- **Difficulty**: Medium.
- **Teach**: TEACH_DIRECTLY after dialogs concept; DELAY share_plus detail.

## F7 — Onboarding overlay (first run)

- **Purpose**: 3-step first-run overlay: welcome+language select,
  notification permission, ready; persists completion; skippable.
- **User-visible**: dimmed overlay card with steps, dots, actions.
- **Entry**: rendered inside `MenuScreenView` stack —
  `OnboardingOverlayScope` gates on `loadOnboardingCompleted()` via
  `FutureBuilder`+`StreamBuilder`, creates `OnboardingViewModel` only when
  incomplete.
- **Key files**: `widgets/onboarding/onboarding_overlay_scope.dart`,
  `onboarding_overlay.dart`, `onboarding_dialog_card.dart`,
  `onboarding_step_actions.dart`, `onboarding_step_indicator.dart`,
  `view_models/onboarding/onboarding_view_model.dart`,
  `data/onboarding/onboarding_step_data.dart` (sealed `OnboardingStepState`),
  `onboarding_content_data.dart` (l10n-driven copy),
  `repositories/onboarding/onboarding_repository.dart`.
- **State**: `_steps` list in ChangeNotifier; completion stream; language
  write-through to `UserSettingsRepository`.
- **Data sources**: SharedPreferences flag; `LocalNotificationService`
  permission request.
- **Difficulty**: Medium-High — nested Future/StreamBuilder gating is
  subtle.
- **Teach**: SIMPLIFY_FIRST — plain "show once" flag; the permission
  handshake is DELAY.

## F8 — Settings dialog

- **Purpose**: sound/music/haptic switches, notifications toggle + wheel
  time picker, language chips, account row, app version.
- **User-visible**: glass dialog card, switches, Cupertino-like wheels.
- **Entry**: `MenuScreenViewModel.requestSettingsDialog` →
  `MenuDialogSettings` → `MenuSettingsDialogScope` creates
  `SettingsViewModel` → `loadSettings()` (settings + permission +
  `package_info_plus` version via `Future.wait`).
- **Key files**: `widgets/menu/settings/*` (shell, card, sections,
  `setting_switch_row`, `setting_time_picker_row`,
  `notification_time_picker_dialog`, `wheel_picker` — ScrollController +
  setState), `view_models/settings/settings_view_model.dart`,
  `settings_item_factory.dart` (builds `SettingItemData` list),
  `settings_notification_coordinator.dart` (schedule/save with rollback),
  `settings_app_version_loader.dart`,
  `data/settings/{user_settings_data,setting_item_data,supported_language_data}.dart`.
- **State**: VM fields + `userSettingsStream` subscription; snackbar events
  via `SettingsUiEvent`; language flows to `MaterialApp.locale` via the
  main.dart StreamBuilder (live locale switch).
- **Difficulty**: Medium-High — real platform permission flow.
- **Teach**: SIMPLIFY_FIRST — settings persistence + switches first;
  notification scheduling and rollback logic DELAY.

## F9 — Auth dialog (Google/Apple/email) + sign-out

- **Purpose**: optional account layer: social sign-in, email sign-in/up,
  guest continue; sign-out confirm with profile reset.
- **User-visible**: auth dialog, loading overlay, snackbar results;
  sign-out dialog.
- **Entry**: `requestAuthAction` → `MenuDialogAuth` or `MenuDialogSignOut`
  depending on session → `*DialogScope` creates
  `MenuAuthDialogViewModel`/`MenuSignOutDialogViewModel`.
- **Key files**: `view_models/menu/menu_auth_dialog_view_model.dart`,
  `menu_sign_out_dialog_view_model.dart`,
  `menu_auth_action_coordinator.dart` (sign-in → session check →
  `profileSyncRepository.syncUserProfile`; sign-out → `resetUserProfile`),
  `repositories/auth/{auth_repository_contract,supabase_auth_repository,disabled_auth_repository}.dart`,
  `services/{google_auth_service,apple_auth_service}.dart`,
  `data/auth/auth_session_data.dart` (sealed guest/authenticated),
  `widgets/menu/auth/*`.
- **State**: `isLoading`, `Stream<...UiEvent>` dismiss/snackbar; auth
  stream propagates to menu.
- **Data sources**: Supabase Auth (`signInWithIdToken`,
  `signInWithPassword`, `signUp`, `onAuthStateChange`), Google v7
  `authenticate`, Apple credential with `sha256` nonce.
- **Difficulty**: Hard — OAuth flows + config surface.
- **Teach**: DELAY real providers; TEACH_DIRECTLY the contract +
  DisabledAuthRepository + sealed session model early; run the full flow
  only when backend setup is in scope.

## F10 — Leaderboard dialog

- **Purpose**: top-10 ranked list + pinned current-user row; loading/
  empty/error/refresh states.
- **User-visible**: popup with ranked rows, medals, refresh.
- **Entry**: leaderboard card → `MenuDialogLeaderboard` →
  `MenuLeaderboardDialogScope` creates `LeaderboardDialogViewModel` →
  `loadLeaderboard()`.
- **Key files**: `view_models/leaderboard/leaderboard_dialog_view_model.dart`
  (`_requestId` stale-response guard, `LeaderboardPopupState` sealed
  variants, profile-backed current row),
  `repositories/leaderboard/{leaderboard_repository_contract,leaderboard_repository}.dart`
  (Supabase view query vs static fallback),
  `widgets/menu/leaderboard/*`, `widgets/leaderboard/*`.
- **Data sources**: `public.leaderboard` security_barrier view.
- **Difficulty**: Medium — first real remote read.
- **Teach**: TEACH_DIRECTLY with the disabled/static repository first;
  Supabase read as a later step.

## F11 — Local notifications

- **Purpose**: daily quiz reminder at user-chosen time.
- **User-visible**: OS permission prompt (onboarding/settings), scheduled
  daily notification.
- **Key files**: `services/local_notification_service.dart`
  (`flutter_local_notifications` `zonedSchedule`, `timezone`/
  `flutter_timezone`, per-platform permission queries, `kIsWeb` guard),
  `settings_notification_coordinator.dart` (rollback on save failure),
  Android manifest receivers.
- **Difficulty**: Advanced platform concern.
- **Teach**: DELAY (platform permission + tz + scheduling), or
  EXPLAIN_ONLY_INITIALLY.

## F12 — Design system & assets

- **Purpose**: consistent game-show look: gradients, glass buttons,
  blur dialogs, SVG icons, 375px design frame.
- **Key files**: `core/app_design_tokens.dart` (`AppTokens`: spacing,
  radii, colors, motion durations, `QzdsButtonScale`, google_fonts styles),
  `core/onboarding_design_tokens.dart`, `core/surface_glow_gradient.dart`,
  `core/app_assets.dart` (~45 asset path constants),
  `widgets/common/*` (`design_frame`, `game_screen_background`,
  `glass_icon_button`, `qzds_game_button`, `language_chip_row`),
  `assets/images/**` (PNG+SVG).
- **Difficulty**: Low-Medium.
- **Teach**: TEACH_DIRECTLY — tokens/constants are a great early win;
  CustomPainter and blur/glow effects DELAY.

## F13 — Localization (en/vi)

- **Purpose**: runtime-switchable English/Vietnamese chrome strings.
- **Key files**: `l10n.yaml`, `lib/l10n/app_en.arb`, `app_vi.arb`,
  generated `app_localizations*.dart`, `main.dart` locale wiring,
  `supported_language_data.dart`, `language_chip_row.dart`.
- **Difficulty**: Medium.
- **Teach**: SIMPLIFY_FIRST — ship one language first, add ARB + gen-l10n
  as its own lesson.

## F14 — Widget previews

- **Purpose**: dev-time `@Preview` catalog for all public widgets with fake
  deps (`lib/previews/*`, `flutter/widget_previews.dart`; validation:
  `flutter widget-preview start --no-pub --headless`).
- **Difficulty**: Advanced tooling.
- **Teach**: DELAY / EXPLAIN_ONLY_INITIALLY.

## F15 — Release tooling & platform config

- **Purpose**: reproducible builds via vendored `scripts/kit`, dart-define
  contract (`.release-kit/project.env`), signing env vars, iOS
  `AuthCredentials.xcconfig`, Android manifest receivers/signing gates.
- **Difficulty**: Senior DevOps detail.
- **Teach**: EXPLAIN_ONLY_INITIALLY — learners need only
  `flutter run`/`flutter test` early; kit stays a reference appendix.

## Dependency wiring summary

```
Menu ──► Game (push)            [routes: only these two]
Menu ──► dialogs (in-Stack): leaderboard, settings, auth, sign-out
Menu ──► onboarding overlay (in-Stack, first run)
Game ──► dialogs (in-Stack): ladder, explanation, poll, AI, confirm, result
All VMs ──► repository contracts ──► SharedPreferences or Supabase
```
