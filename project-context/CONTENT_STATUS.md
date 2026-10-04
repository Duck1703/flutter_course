# Content Status

Canonical tracker of course content progress. Update at every milestone
completion. Status vocabulary:

- `PLANNED` — milestone defined in `MILESTONE_ROADMAP.md`, no content yet.
- `IMPLEMENTED_PENDING_SUPERVISOR` — learner code + lessons authored and
  internally verified; awaiting supervisor review.
- `SUPERVISOR_APPROVED` — supervisor accepted the step report.

## Milestone table

| Milestone | Status | Lessons | Learner code | Content QA | Supervisor |
|-----------|--------|---------|--------------|------------|------------|
| M01 | SUPERVISOR_APPROVED | 3 | `main.dart` (M01 state: `WelcomeScreen`) | PASSED (Step 03) | Step 03 PASS |
| M02 | SUPERVISOR_APPROVED | 4 | `screens/menu_screen.dart`, `core/menu_tokens.dart`, `main.dart` (theme+`MenuScreen`) | PASSED (Step 03) | Step 03 PASS |
| M03 | SUPERVISOR_APPROVED | 3 | `screens/menu_screen.dart` → `StatefulWidget` + `setState` | PASSED (Step 03) | Step 03 PASS |
| M04 | IMPLEMENTED_PENDING_SUPERVISOR | 4 | `data/profile/user_profile_data.dart`; `menu_screen.dart` model-backed; `test/user_profile_data_test.dart` (10) | PASSED (Step 04) | pending |
| M05 | IMPLEMENTED_PENDING_SUPERVISOR | 3 | `data/profile/demo_profile_loader.dart`; `main.dart` async; `menu_screen.dart` `FutureBuilder`+loading/error; `test/demo_profile_loader_test.dart` (+3) | PASSED (Step 04) | pending |
| M06 | IMPLEMENTED_PENDING_SUPERVISOR | 3 | `data/menu_session_ticker.dart`; `menu_screen.dart` `StreamBuilder` ticker card; `test/menu_session_ticker_test.dart` (+2) | PASSED (Step 04) | pending |
| M07 | IMPLEMENTED_PENDING_SUPERVISOR | 3 | `screens/game_screen.dart` (placeholder route); `menu_screen.dart` CTA → `Navigator.push(MaterialPageRoute)` | PASSED (Step 05) | pending |
| M08 | IMPLEMENTED_PENDING_SUPERVISOR | 4 | `data/game/quiz_question.dart`, `quiz_questions.dart` (4-câu bank); `game_screen.dart` mini-quiz select→submit→next; `test/quiz_questions_test.dart`; `test/widgets/game_screen_test.dart` (6 widget test) | PASSED (Step 05) | pending |
| M09 | IMPLEMENTED_PENDING_SUPERVISOR | 4 | `data/game/game_session_state.dart` (`GamePhase`/`GameEndReason`); `game_screen.dart` full session: `Timer.periodic` 15s, reveal, 3 endings, `AlertDialog`, `popUntil`; `game_screen_test.dart` (+5 = 11 widget test) | PASSED (Step 05) | pending |
| M10 | IMPLEMENTED_PENDING_SUPERVISOR | 4 | `data/game/game_result.dart`; `data/profile/profile_store.dart`; `user_profile_data.dart` (+toMap/fromMap/applyGameResult); `game_screen.dart` (route-result); `menu_screen.dart` (store + reset); `test/profile_store_test.dart`; user_profile_data_test (+8); game_screen_test updated | PASSED (Step 06) | pending |
| M11 | IMPLEMENTED_PENDING_SUPERVISOR | 3 | `view_models/menu/menu_view_model.dart` (`MenuViewModel`/`MenuLoadState`); `menu_screen.dart` → `ListenableBuilder` + manual VM ownership; `test/menu_view_model_test.dart` (7) | PASSED (Step 06) | pending |
| M12 | IMPLEMENTED_PENDING_SUPERVISOR | 3 | `provider` package; `core/app_dependency_scope.dart`; `main.dart` scope wiring; `menu_screen.dart` → `ChangeNotifierProvider` + `context.read`/`watch`; `test/menu_provider_scope_test.dart` (2) | PASSED (Step 06) | pending |
| M13 | IMPLEMENTED_PENDING_SUPERVISOR | 3 | `view_models/menu/menu_ui_event.dart` (new — plain event classes); `view_models/menu/menu_view_model.dart` (broadcast `_events`/`events`, `requestGame()`, snackbar emit on reset, `dispose` close); `screens/menu_screen.dart` (event bridge in `_MenuScreenViewState`: `didChangeDependencies` subscribe + `==` guard + `dispose` cancel + `unawaited`; `_onPlayTap` → `requestGame()`); `test/menu_view_model_test.dart` (+3); `test/menu_ui_events_test.dart` (new, 2) | PASSED (Step 08) | pending |
| M14 | IMPLEMENTED_PENDING_SUPERVISOR | 7 (Step-13: 4→7 restructure) | `repositories/{profile,settings,onboarding}/*.dart` (3 contract+impl pairs, rxdart `BehaviorSubject`/`ValueStream`); `data/settings/user_settings_data.dart` (new); `user_profile_data.dart` (+`totalEarnings`/`totalQuestionCount`, deep parse, `?avatarUrl`); `menu_view_model.dart` (contract dep, `.value` seed + ctor `listen`, `MenuLoadState` retired); `menu_screen.dart` (no load surface); `app_dependency_scope.dart` (`MultiProvider`); `main.dart` (3×`create()` + `loadUserSettings`); `pubspec.yaml` (+rxdart); `data/profile/profile_store.dart` DELETED; tests: 3 fakes in `test/helpers/`, 3 repo test files, rewritten VM/scope tests (69 total) | PASSED (Step 11) + beginner-remediated (Step 13) | pending |
| M15 | IMPLEMENTED_PENDING_SUPERVISOR | 5 | `view_models/menu/menu_screen_ui_event.dart` (renamed+sealed); `menu_view_model.dart` (type rename); `menu_screen.dart` (exhaustive `switch` bridge + `(:final message)` pattern); `data/game/game_session_state_data.dart` (renamed + `sealed GameDialogState` 3-variant; `GameEndReason` trimmed); `screens/game_screen.dart` (`_dialogState` field, `_finish(GameDialogState)`, `switch`-expr dialog content, wildcard color); `test/sealed_state_test.dart` (new, 5); `test/menu_screen_ui_events_test.dart` (renamed) — 74 tests total | PASSED (Step 14; impl QA + content QA round-2 + site QA all PASS; sequential replay 5/5) | pending |
| M16 | IMPLEMENTED_PENDING_SUPERVISOR | 5 | `data/settings/setting_item_data.dart` (sealed family); `data/settings/supported_language_data.dart`; `view_models/settings/{settings_ui_event,settings_view_model,settings_item_factory}.dart`; `widgets/menu/settings/{settings_dialog,notification_time_picker_dialog}.dart`; `menu_screen_ui_event.dart` (+`MenuSettingsRequested`); `menu_view_model.dart` (+`requestSettings`); `menu_screen.dart` (bridge + `_openSettings` + gear); `test/settings_view_model_test.dart` (7); `test/widgets/settings_dialog_test.dart` (5); `sealed_state_test.dart` +arm; `menu_view_model_test.dart` +1 — 87 tests total | PASSED (Step 15; impl re-verify + content QA r2 + re-verify r3 + site re-verify + replay 5/5) | pending |
| M17 | IMPLEMENTED_PENDING_SUPERVISOR | 5 | `l10n.yaml`; `pubspec.yaml` (+`generate: true`, `flutter_localizations`, `intl: any`); `lib/l10n/` (en+vi ARBs 48 keys + generated classes); `data/settings/user_settings_data.dart` (FR-26 `_supportedLanguageCode`); `main.dart` (StreamBuilder→`MaterialApp.locale`); `settings_item_factory.dart` + `settings_view_model.dart` (`localizedSettingItems`); `menu_screen.dart`/`settings_dialog.dart`/`notification_time_picker_dialog.dart`/`game_screen.dart` (l10n migration); `test/helpers/localized_test_app.dart`; `test/localization_switch_test.dart` (3) — 90 tests total | PASSED (Step 15; impl re-verify + content QA r4 + site QA + replay 5/5) | pending |
| M18 | IMPLEMENTED_PENDING_SUPERVISOR | 5 | `data/onboarding/onboarding_step_data.dart` + `onboarding_content_data.dart`; `view_models/onboarding/onboarding_view_model.dart` (senior-identical); `widgets/onboarding/onboarding_overlay_scope.dart` + `onboarding_overlay.dart`; `widgets/common/language_chip_row.dart` (promoted); `menu_screen.dart` (`Stack` + `Positioned.fill`); `app_{en,vi}.arb` (+16 senior keys, `nextButton`→`gameNextButton`); `game_screen.dart` call site; `main.dart`/`app_dependency_scope.dart` (repo DI); `test/onboarding_view_model_test.dart` (7) + `test/widgets/onboarding_overlay_test.dart` (5); 3 test hosts re-seeded — 102 tests total | PASSED (Step 15; impl QA + content QA r2 + site QA + replay 5/5) | pending |
| M19 | IMPLEMENTED_PENDING_SUPERVISOR | 6 | `data/game/` (6 files: session-state 6-phase `GamePhase` + sealed `GameDialogState`, screen-data, quiz-question-data full shape, money-ladder 15lv+safe havens, game-result `earnedAmount`, 45-question senior bank); `view_models/game/` (`game_screen_view_model.dart` ChangeNotifier + `flowToken` + 30s timer; `game_screen_presentation_mapper.dart`; `support/game_money_ladder_mapper.dart` + `game_money_formatter.dart`); `navigation/app_navigation_controller.dart`; `game_screen.dart` rewrite (provider + event bridge + `PopScope` + `showDialog` interim + dialog-back routing); `app_dependency_scope.dart`/`main.dart` (nav controller DI + portrait lock); `menu_screen.dart` (`_openGame` context-free); ARB key migration (9 senior keys, 17 dead removed); deleted `quiz_questions.dart`/`quiz_question_data.dart`; `pubspec.yaml` (+`fake_async` dev); tests: VM (17) + mapper (4) + bank (7) + sealed (5) + widget (10) — 126 tests total | PASSED (Step 16; impl QA r2 + content QA r2 + re-verify + site QA + replay 6/6) | pending |
| M20 | IMPLEMENTED_PENDING_SUPERVISOR | 5 | `data/game/game_session_state_data.dart` (+`GameAudiencePollItemData`, +`GameConfirmWalkAwayDialog`/`GameAudiencePollDialog`/`GameAIAssistantDialog` → sealed 9-variant 1:1 senior, +`visibleOptionTexts`/`audiencePercentiles`/`usedFeatureButtons`/`resolvedResult` + `clear*` flags, ctor drops `const` for unmodifiable wrappers); `data/game/game_screen_data.dart` (+`GameFeatureButtonType` 5-value enum, `GameFeatureButtonData` IconData DTO [FR-34], `audiencePercentile`+`copyWith` on `GameAnswerOptionData`, `featureButtons` on `GameScreenData`); `view_models/game/support/game_lifeline_helper.dart` (new — verbatim senior: deterministic 50:50, poll 68/52/42 + `_splitWrongAudience`, `buildGameAudiencePollItems`); `view_models/game/game_screen_presentation_mapper.dart` (+4 params, `_buildAnswers` reads `visibleOptionTexts`, `_answerState` empty-guard, `_buildFeatureButtons`+`_feature` verbatim, `canWalkAway` gating); `view_models/game/game_screen_view_model.dart` (`handleFeatureClick`+`_canUseFeature` double-guard, `_useFiftyFifty`, `_showAudiencePoll`+`_audiencePollItems`, `_showAIAssistant` 700ms simulated + `_onAIAssistantElapsed` token+`is!` stale guards, `_showConfirmWalkAway`/`confirmWalkAway` → victory+`resolvedResult{won:false}`, `resolvedResult` chốt in `_endGame`/victory/`backToMenu`, `buildGameResult` reads `resolvedResult ??`); `screens/game_screen.dart` (`_GameFeatureBar`/`_GameFeatureButton` data-driven bar [FR-34 flat visuals], `_AnswerOption` empty guard, `_GameDialogHost` snapshot→`ListenableBuilder` live-read, +3 dialog `_title`/`_content`/`_actions` arms, `_GameDialogAction.confirmWalkAway`, `_GameTopBar` `exitSemanticLabel`); `app_{en,vi}.arb` (+12 senior keys); tests: helper (5) + mapper (+2, assert mở 4-button+walkAway gating) + VM (+10: 2-use/50:50×2/poll×2/AI×2/walkAway×2) + sealed (9 arms) + widget (+4: bar/poll/AI/walkAway, `pumpGameScreen` pre-start) — 147 tests total | PASSED (Step 16; impl QA + content QA r2 + re-verify + site QA [stale-read reconciled] + replay 4/4) | pending |
| M21 | IMPLEMENTED_PENDING_SUPERVISOR | 5 | `widgets/game/game_dialog_layer.dart` (new — Positioned.fill→IgnorePointer→AnimatedSwitcher+ValueKey(runtimeType)→_DialogBackdrop→9 views); `widgets/game/game_dialog_views.dart` (new — 9 `Game*DialogView` callback-style + `_GameDialogCard`/`_ConfirmMessage`/`_EarnedContent`/`_DialogTextButton`); `screens/game_screen.dart` 1095→588 (PopScope+`_handleRouteBack`+`_afterExit`+`_terminalActionPending`, Stack mount, scaffold retired); `view_models/game/game_screen_view_model.dart` (10 `GameDialogRequested` emits removed); `data/game/game_session_state_data.dart` (`GameDialogRequested` deleted, uiEvent=nav-only); `core/menu_tokens.dart` (+3 dialog tokens); tests: `game_dialog_layer_test.dart` (new, 10) + `game_screen_test.dart` (finder/timing) + `game_screen_view_model_test.dart` (isEmpty) — 157 tests total | PASSED (Step 17; impl QA r2 + content QA r2+residuals + site QA + replay 5/5) | pending |
| M22 | IMPLEMENTED_PENDING_SUPERVISOR | 5 | `data/game/level_config.dart` (new — senior port: baseExp 30000, growth 5000, milestone map, JS-safe `maxExpRequirement`); `view_models/menu/menu_level_progress.dart` (new — `fromProfile`/`tier`/`ratio`/`formatted*`); `view_models/game/game_screen_view_model.dart` (ctor repo inject + `_emitWithSaveResult`/`_saveGameResult`/`_applyLevelProgression`/`_normalizedLevel`/`_syncSavedGameResult` stub); `data/game/game_session_state_data.dart` (`hasSavedResult`↔`resolvedResult`); `data/profile/user_profile_data.dart` (9-field surgery); `navigation/app_navigation_controller.dart` (`openGame`→void); `screens/game_screen.dart` + `menu_screen.dart` (bare transport + `_LevelCard` rewire); `view_models/menu/menu_view_model.dart` (`applyGameResult` deleted); `data/game/game_result.dart` DELETED; tests: `level_config_test` (7) + `menu_level_progress_test` (5) + vm `result persistence` group (8) − 9 scaffold — 168 total | PASSED (Step 17; impl QA + content QA r4 + site QA + replay 5/5: 157→164→169→168→168) | pending |
| M23 | IMPLEMENTED_PENDING_SUPERVISOR | 5 | `pubspec.yaml` (+`supabase_flutter: 2.14.2`); `core/supabase_environment.dart` (4 dart-defines); `services/supabase_client_service.dart` (conditional init → `SupabaseClient?`); `data/leaderboard/leaderboard_entry_data.dart` (entry + sealed 4-state + static fallback); `repositories/leaderboard/` (contract + `SupabaseLeaderboardRepository` query chain/`maybeSingle` + `DisabledLeaderboardRepository`); `view_models/leaderboard/leaderboard_dialog_view_model.dart` (`_requestId` guard, `isRefreshing`, `retry`, profile-backed fallback, FR-35 guest seam); `widgets/leaderboard/` (popup body + list + row); `widgets/menu/leaderboard/` (dialog + scope); `main.dart` + `app_dependency_scope.dart` (conditional DI); `menu_screen.dart` (`_LeaderboardEntry` tappable + bridge); `menu_view_model.dart` (+`requestLeaderboardDialog`); `menu_screen_ui_event.dart` (+`MenuLeaderboardRequested`); `supabase/student-setup/01-setup-database.sql` (verbatim); ARB +6 keys; tests: env (3) + repo (4) + VM (9) + widget (8) + menu-VM (1) — 193 total | PASSED (Step 18; impl QA + content QA r2 + site QA + replay 5/5: 168→171→171→175→184→193) | pending |
| M24 | IMPLEMENTED_PENDING_SUPERVISOR | 5 | `data/auth/auth_session_data.dart` (sealed guest/authenticated + `AuthActionResult`); `repositories/auth/` (contract + `DisabledAuthRepository` + `AuthRepositoryImpl` + barrel); `services/{google_auth_service,apple_auth_service}.dart` (Google v7 + Apple mapping); `data/profile/profile_sync_state_data.dart` + `repositories/profile/user_profile_sync_repository{,_contract}.dart` (FR-36 disabled seam → M25); `view_models/menu/menu_auth_action_coordinator.dart`; `view_models/menu/menu_auth_dialog_view_model.dart` + `menu_sign_out_dialog_view_model.dart`; `menu_view_model.dart` (auth seed/subscribe + `requestAuthAction`, `resetProfile`+menu snackbar emit-site retired — `MenuSnackBarRequested` class retained, zero emit sites, senior-parity); `menu_screen_ui_event.dart` (+`MenuAuthRequested`/`MenuSignOutRequested` learner transport → M29); `leaderboard_dialog_view_model.dart` + `menu_leaderboard_dialog_scope.dart` (FR-35 uid from auth stream); `widgets/menu/auth/` (6 files: auth dialog + sign-out dialog + scopes + loading overlay); `main.dart`/`app_dependency_scope.dart` (auth + sync DI); ARB (+`menuGuestName` + auth keys); tests: auth repo (8→+apple) + session + disabled + coordinator + dialog VMs + menu VM (+6) + leaderboard uid + widget — 224 total | PASSED (Step 18; impl QA + reverify r2 + content QA r2 + site QA + replay 5/5: 193→199→201→201→219→224) | pending |
| M25 | IMPLEMENTED_PENDING_SUPERVISOR | 5 | `data/profile/app_user_data.dart` (new — `AppUserData` 8-field boundary DTO + `mergeUserProfileForSync` + 5 private helpers, senior-verbatim); `repositories/profile/user_profile_sync_repository.dart` (+`UserProfileSyncRepositoryImpl`: `_isSyncing` guard, `maybeSingle` fetch, merge, local-save-first, `upsert(onConflict:'auth_uuid')`, `ProfileSyncFailed`+rethrow); `main.dart` (conditional sync DI ternary, third M23-pattern use); `game_screen_view_model.dart` (ctor +`authRepository`/`profileSyncRepository`, real `_syncSavedGameResult` — FR-36 converged); `game_screen.dart` create +2 reads; `supabase/student-setup/02-verify-database.sql` (byte-identical); doc updates (scope/coordinator/contract/state comments); tests: merge (7) + schema (2) + sync group (3) + call-site updates — 236 total | PASSED (Step 18; impl QA r2 + content QA r2 + site QA r2 + replay 5/5: 224→226→233→233→233→236) | pending |
| M26 | IMPLEMENTED_PENDING_SUPERVISOR | 6 | `core/dre/{dre,dre_change_notifier}.dart` (verbatim senior); `view_models/game/dre/` 5 files (`GameState` reusable immutable + `flowToken` in-state, 13 `GameAction`, 7 `GameEffect` [share deferred→M27], `GameSaveResult` op, contract); `view_models/game/reducer/` `game_reducer.dart` + 4 part flows (session/answer/feature/timer); `view_models/game/bridge/` 2 part files (effects dispatch + result persistence); `game_screen_view_model.dart` rewrite → `DreChangeNotifier<GameState,…>` (wrappers dispatch; `_handleEffect`→Timer/delayed/events; `executeAsyncOp`→`_saveGameResult` giữ M25 sync); `game_session_state_data.dart` (`GameSessionState` retired); UI call-sites đổi `vm.state`→type mới nhưng API giữ nguyên; tests: dre notifier (5) + reducer (10) + regression (3) — **254 total** | PASSED (Step 19; impl QA r1 PASS_WITH_FINDINGS [NITs pre-existing] + content QA r1 FAIL→r2 PASS + site QA PASS[REVERIFIED] + replay 6/6: 236→241→241→251→251→254, tree byte-identical) | pending |
| M27 | IMPLEMENTED_PENDING_SUPERVISOR | 6 | `services/local_notification_service.dart` (contract+impl verbatim: id 1001, `zonedSchedule`+`DateTimeComponents.time`+`inexactAllowWhileIdle`, timezone/UTC-fallback, platform-resolve, `!kIsWeb`); `view_models/settings/settings_notification_coordinator.dart` (verbatim schedule/cancel-trước persist-sau + best-effort rollback); `settings_app_version_loader.dart`; `settings_view_model.dart` (senior port: notificationService+loadAppVersion seam, `_hasNotificationPermission` AND-gate, `Future.wait`×3, `_toggleNotifications` 2 nhánh); `settings_ui_event.dart` (+permissionRequired); `settings_dialog.dart` (scope service + `v$appVersion` row); `main.dart`/`app_dependency_scope.dart` (unconditional impl + `Provider<Contract>.value`); `onboarding_overlay_scope.dart` (real `requestPermission` — simulated grant retired); share chain: `game_dre_{action,effect}.dart` + reducer arm + bridge arm + `GameShareResultEvent` + `shareResult` + `onShareResult`/`_DialogShareButton` (scaffold→M28) + `game_screen.dart` SharePlus+Clipboard; ARB +5 keys en/vi; `AndroidManifest.xml` +2 uses-permission +2 receivers; `test/helpers/fake_local_notification_service.dart`; settings VM test 7→12 — **259 total** | PASSED (Step 19; impl QA r1→remediated [manifest uses-permission MAJOR] + content QA r1 FAIL→r4 PASS + site QA F1-fixed [fc /b identical] + replay 6/6: 254→254→254→259→259→259→259, tree byte-identical) | pending |
| M28 | IMPLEMENTED_PENDING_SUPERVISOR | 6 | `core/app_design_tokens.dart` (318d verbatim: `QzdsButtonScale`, `screenDesignWidth=375`, `GoogleFonts.beVietnamPro` ramp, 2 export barrel) + `app_assets.dart` (subset 8 const) + `surface_glow_gradient.dart` + `widgets/common/design_frame.dart`; 2 dep (`flutter_svg ^2.3.0`, `google_fonts ^8.1.0`) + 2 asset-dir + 7 SVG + 1 PNG + 6 ARB semantics keys; chrome `qzds_game_button`/`glass_icon_button`/`game_screen_background`; `widgets/game/timer/` countdown (2 controller + `part` painter stadium) + `layout/game_screen_top_bar.dart`; `widgets/game/money/`×4 (trigger-motion/glitch/ladder CTA/dialog); `widgets/game/answers/`×3 + `questions/game_question_panel.dart` + `lifelines/game_audience_poll_row.dart` + `dialogs/`×5 (shell + 3 families + layer); `data/game/game_screen_data.dart` + mapper `icon`→`iconAsset`; `lifelines/game_feature_button{,_bar}` painter + `layout/game_screen_body.dart` + `screens/game_screen.dart` thin-shell; **deleted** old `game_dialog_layer.dart`/`game_dialog_views.dart`; tests: qzds(4)+timer(7)+money(6)+answers/question/dialog(13)+L06 hosts(+20) — **309 total** | PASSED (Step 19; impl QA r1 PASS_WITH_FINDINGS→remediated [VI-ARB truncation + 3 test omissions + bank comment] + content QA r1 PASS_WITH_FINDINGS→r2 PASS + site QA PASS_WITH_FINDINGS→remediated [index.mdx M28-in-progress + 30-file count + D-48 tag; diff 7/7 identical] + replay 6/6: 259→259→263→270→276→289→309, tree byte-identical) | pending |
| M29 | IMPLEMENTED_PENDING_SUPERVISOR | 7 | menu dialog layer: `menu_dialog_state.dart` (5-variant sealed) + `menu_screen_view_model.dart` (VM rename + `dialogState` + request/dismiss API) + `menu_dialog_layer.dart` + `menu_screen_view.dart` + `screens/menu_screen.dart` (PopScope, `_MenuScreenEventBridge`) + auth/sign-out/settings/leaderboard `*_dialog_scope.dart` `onDismiss`-form + `menu_screen_ui_event.dart` 2-variant; settings chrome verbatim ×12 (`iconAsset` FR-30); leaderboard verbatim ×6 + `entryFromRow` seam (FR-28 residual); onboarding verbatim ×8 + `onboarding_design_tokens.dart` (FR-32); `core/app_assets.dart` 45 consts + 50 files; `MenuTokens` retired; `app_dependency_scope`/`main.dart`/`app_navigation_controller` verbatim; `previews/` fixtures + 3 catalogs + `@Preview` dep; `docs/release-kit-walkthrough.md`; ARB parity 119 keys (+11/−5, sentence-case + `.toUpperCase()`); tests ported/replaced ×15 — **396 total** | PASSED (Step 20; impl QA PASS_WITH_FINDINGS→remediated [stale MenuViewModel refs, ARB metadata, pubspec comment, share-message naming] + content QA PASS_WITH_FINDINGS→remediated [register wording, FR-23 ref, ARB diff direction, concept IDs A-40/F-44] + site QA PASS_WITH_FINDINGS→remediated [concept-ID suffixes, index wording] + replay 8/8: 309→309→311→319→343→367→381→396 [−2 interim-version artifact, L07 exact], tree byte-identical + mutation check PASS [requestLeaderboardDialog→MenuDialogSettings caught]) | pending |
| M29 | PLANNED | — | — | — | — |

## Lesson routes (M01–M09)

| Route | File | Main concept |
|-------|------|--------------|
| `/m01/` | `m01/index.md` | Milestone overview |
| `/m01/01-flutter-dart-va-project-dau-tien/` | `m01/01-flutter-dart-va-project-dau-tien.md` | Flutter/Dart roles, `flutter create`, project anatomy, pubspec |
| `/m01/02-main-runapp-va-cay-widget/` | `m01/02-main-runapp-va-cay-widget.md` | `main()`/`runApp`, widget tree, `StatelessWidget`, `BuildContext`, `MaterialApp`/`Scaffold` |
| `/m01/03-chay-app-hot-reload-va-tooling/` | `m01/03-chay-app-hot-reload-va-tooling.md` | `flutter run`, Hot Reload vs Hot Restart vs full restart, `flutter analyze` habit |
| `/m02/` | `m02/index.md` | Milestone overview |
| `/m02/01-mo-hinh-constraints/` | `m02/01-mo-hinh-constraints.md` | Constraints down → sizes up → parent positions; `Column`, `mainAxisSize`, `crossAxisAlignment` |
| `/m02/02-khung-man-hinh-menu/` | `m02/02-khung-man-hinh-menu.md` | `screens/`+`core/` layout, `MenuTokens` (`static const`, `._()`), `SafeArea`, `ConstrainedBox`, gradient `Container`/`BoxDecoration`, `Expanded` |
| `/m02/03-header-va-cac-the/` | `m02/03-header-va-cac-the.md` | `Row`, `Expanded`/`Spacer`, `Icon`, `final`+`required` params, `Border.all`, `BoxShape.circle`, `_LevelCard`, `_EarningsCard` |
| `/m02/04-nut-cta-va-hoan-thien-menu/` | `m02/04-nut-cta-va-hoan-thien-menu.md` | `_LeaderboardEntry`, `_StatsRow`+`_StatTile` (3× `Expanded`), `double.infinity`, gradient CTA, full-file review |
| `/m03/` | `m03/index.md` | Milestone overview |
| `/m03/01-stateless-va-stateful/` | `m03/01-stateless-va-stateful.md` | Widget vs `State`, `createState`, `setState` first use, `GestureDetector`, `VoidCallback`, `$var`, ternary |
| `/m03/02-setstate-va-rebuild/` | `m03/02-setstate-va-rebuild.md` | `setState` = mark dirty + schedule build; diff mental model; `debugPrint`; classic mistakes |
| `/m03/03-lifecycle-callbacks-va-state-ownership/` | `m03/03-lifecycle-callbacks-va-state-ownership.md` | `initState`/`dispose` (+`super` order), data-down-events-up, state ownership rule |
| `/m04/` | `m04/index.md` | Milestone overview |
| `/m04/01-model-va-null-safety/` | `m04/01-model-va-null-safety.md` | Class vs primitives, `final`/`const`, named params/`required`, `?`/`??`/`!`, `Type` vs `Type?` |
| `/m04/02-copywith-va-equality/` | `m04/02-copywith-va-equality.md` | Immutable update mental model, `copyWith`, `==`/`hashCode`, `identical`, `Object.hash`, `gainExp`, derived getters |
| `/m04/03-noi-model-vao-menu/` | `m04/03-noi-model-vao-menu.md` | Pass model through widget params, `_profile` in `State`, `gainExp` on tap, defaults == old hard-coded values |
| `/m04/04-unit-test-dau-tien/` | `m04/04-unit-test-dau-tien.md` | `flutter_test`, `group`/`test`/`expect`, `isNot(sameObject)`, `throwsA`, `expectLater`, first test habit |
| `/m05/` | `m05/index.md` | Milestone overview |
| `/m05/01-future-async-await/` | `m05/01-future-async-await.md` | Sync→async gap, `Future<T>`, event loop, `async`/`await`, `then`/`catchError`, `Future.delayed`, `try/catch`, `unawaited` |
| `/m05/02-futurebuilder/` | `m05/02-futurebuilder.md` | `FutureBuilder`, `AsyncSnapshot`, `connectionState`, stable Future in `State` (never in `build`), loading/error/retry, `mounted` guard |
| `/m05/03-async-main/` | `m05/03-async-main.md` | `Future<void> main() async`, `WidgetsFlutterBinding.ensureInitialized()`, senior bootstrap shape, why binding before `runApp` |
| `/m06/` | `m06/index.md` | Milestone overview |
| `/m06/01-stream-la-gi/` | `m06/01-stream-la-gi.md` | `Stream<T>` = values over time vs `Future`, `Stream.periodic`, `listen`/`StreamSubscription`, `cancel`, async*/`yield` concept |
| `/m06/02-streambuilder-trong-menu/` | `m06/02-streambuilder-trong-menu.md` | `StreamBuilder`, `initialData`, stable stream field, live session-seconds card, snapshot-driven UI |
| `/m06/03-listen-cancel-streamcontroller/` | `m06/03-listen-cancel-streamcontroller.md` | Manual `listen`/`cancel` example (labelled not-in-app), single-subscription vs broadcast, `StreamController`, why disposal matters |
| `/m07/` | `m07/index.md` | Milestone overview |
| `/m07/01-route-stack-va-push/` | `m07/01-route-stack-va-push.md` | Route stack mental model, `Navigator.of(context).push`, `MaterialPageRoute`, anonymous routes |
| `/m07/02-game-screen-va-pop/` | `m07/02-game-screen-va-pop.md` | `GameScreen` placeholder, `AppBar` + auto back button, `Navigator.pop`, return-to-menu |
| `/m07/03-senior-navigation-checkpoint/` | `m07/03-senior-navigation-checkpoint.md` | Senior `AppNavigationController`/`navigatorKey` comparison, `push` returns `Future`, scope checkpoint |
| `/m08/` | `m08/index.md` | Milestone overview |
| `/m08/01-quiz-question-model/` | `m08/01-quiz-question-model.md` | `QuizQuestion` immutable model, `options`/`correctIndex`, const question bank in `data/game/` |
| `/m08/02-quiz-state-va-enum/` | `m08/02-quiz-state-va-enum.md` | `GameScreen` → `StatefulWidget`, `_selectedIndex` `int?`, `_AnswerVisualState` enum, lock-after-submit |
| `/m08/03-render-options-va-flow/` | `m08/03-render-options-va-flow.md` | Collection-`for`/`...` in list literal, `String.fromCharCode`, select→submit→next flow, result panel |
| `/m08/04-widget-test-dau-tien/` | `m08/04-widget-test-dau-tien.md` | `testWidgets`, `WidgetTester`, `pumpWidget`, `MaterialApp` wrapper, `find`, `tap`, `pump`, `expect` |
| `/m09/` | `m09/index.md` | Milestone overview |
| `/m09/01-game-phase-va-timer/` | `m09/01-game-phase-va-timer.md` | `GamePhase`/`GameEndReason` enums in `data/game/`, `Timer.periodic`, cancel/dispose ownership rules |
| `/m09/02-phase-flow/` | `m09/02-phase-flow.md` | Phase machine transitions, `_submitAnswer`/`_advanceAfterReveal`/`_finish`/`_restart`, phase guards |
| `/m09/03-showdialog-va-popuntil/` | `m09/03-showdialog-va-popuntil.md` | `showDialog`/`AlertDialog`/`barrierDismissible`, dialog-as-route, `switch` on enum, `popUntil(isFirst)` |
| `/m09/04-test-game-session/` | `m09/04-test-game-session.md` | `pump(Duration)` fake-clock timer test, dialog/route assertions, `unmount` cleanup, real overflow found by test |
| `/m10/` | `m10/index.md` | Milestone overview |
| `/m10/01-sharedpreferences-va-profile-store/` | `m10/01-sharedpreferences-va-profile-store.md` | Plugin + platform channel, `getInstance`, `getString`/`setString`/`remove`, concrete `ProfileStore` |
| `/m10/02-json-tomap-frommap/` | `m10/02-json-tomap-frommap.md` | `jsonEncode`/`jsonDecode`, `Map<String, Object?>`, `toMap`, defensive `fromMap` (`is int`/`is String`), `FormatException` |
| `/m10/03-game-result-qua-pop/` | `m10/03-game-result-qua-pop.md` | `push<T>`/`pop(result)` route-result, `showDialog<_ResultAction>` returns action, `GameResult` packaging, apply-once |
| `/m10/04-ap-ket-qua-va-reset/` | `m10/04-ap-ket-qua-va-reset.md` | `applyGameResult` on model, persist-after-apply, reset action, `setMockInitialValues` tests |
| `/m11/` | `m11/index.md` | Milestone overview |
| `/m11/01-vi-sao-setstate-khong-scale/` | `m11/01-vi-sao-setstate-khong-scale.md` | setState limits, `ChangeNotifier` mental model, `MenuViewModel` extraction, field+getter |
| `/m11/02-notifylisteners-va-listenablebuilder/` | `m11/02-notifylisteners-va-listenablebuilder.md` | `notifyListeners` no-diff, `ListenableBuilder`, `switch` expression on `MenuLoadState`, FutureBuilder retirement |
| `/m11/03-so-huu-vm-va-test/` | `m11/03-so-huu-vm-va-test.md` | Manual VM ownership (initState/dispose), `unawaited`, pure-Dart VM tests, notify counting, test double via subclass |
| `/m12/` | `m12/index.md` | Milestone overview |
| `/m12/01-inheritedwidget-va-lookup/` | `m12/01-inheritedwidget-va-lookup.md` | Tree lookup mental model, `Provider<T>`, `.value` vs `create:`, `AppDependencyScope`, single-dep scope |
| `/m12/02-read-vs-watch/` | `m12/02-read-vs-watch.md` | `context.read` vs `context.watch`, callback-vs-build rule, ProviderNotFoundException, `didChangeDependencies` |
| `/m12/03-changenotifierprovider-va-scope/` | `m12/03-changenotifierprovider-va-scope.md` | `ChangeNotifierProvider(create:)` auto-dispose, screen-level scope, `..load()` kick-off, scope-wrapped widget tests |
| `/m13/` | `m13/index.md` | Milestone overview |
| `/m13/01-event-khong-phai-state/` | `m13/01-event-khong-phai-state.md` | Event vs state semantics, `MenuUiEvent` classes, `StreamController.broadcast`, `requestGame()` |
| `/m13/02-event-bridge-trong-state/` | `m13/02-event-bridge-trong-state.md` | `StreamSubscription`, `didChangeDependencies` subscribe, `==` re-subscribe guard, `dispose` cancel, `unawaited` |
| `/m13/03-snackbar-event-va-test/` | `m13/03-snackbar-event-va-test.md` | `ScaffoldMessenger` from bridge, VM event tests, widget SnackBar test |
| `/m14/` | `m14/index.md` | Milestone overview |
| `/m14/01-vi-sao-profilestore-chua-du/` | `m14/01-vi-sao-profilestore-chua-du.md` | Storage vs repository boundary, `abstract interface class`, `implements`, `create()` async factory, explicit `profile_store.dart` deletion |
| `/m14/02-rxdart-behavior-subject-valuestream/` | `m14/02-rxdart-behavior-subject-valuestream.md` | `rxdart`, `BehaviorSubject.seeded`, `ValueStream`, `.value` vs `.stream`, replay, `isClosed`+equality guards, `dispose` |
| `/m14/03-ba-repository-va-multiprovider/` | `m14/03-ba-repository-va-multiprovider.md` | 3 repos table, `MultiProvider`, contract-keyed `Provider<Contract>.value`, `main()` bootstrap + `loadUserSettings`, `UserProfileData` parity (`?avatarUrl`, `_moneyFromDisplay`, demo purge), fakes |
| `/m14/04-menuviewmodel-noi-vao-stream/` | `m14/04-menuviewmodel-noi-vao-stream.md` | Ctor `.value`+`listen`, `_handleUserProfile` guards, writers-no-set-state, state stream ≠ event stream, `MenuLoadState` retirement, stream-propagation tests |

## Lesson decomposition rationale

- **M01 = 3 lessons**: orientation/anatomy → entry point + widget tree →
  run/reload/tooling. Three coherent concept bundles, each independently
  verifiable.
- **M02 = 4 lessons**: constraint model alone is lesson 1 (heaviest new
  mental model); skeleton + design tokens is lesson 2; card building is
  lesson 3; remaining rows + CTA + full-file review is lesson 4.
- **M03 = 3 lessons**: Widget/State split + first interactivity (1),
  `setState` mechanics + rebuild experiments (2), lifecycle + ownership (3).
- **M04 = 4 lessons**: model motivation + Dart class/null safety (1),
  immutability + `copyWith` + equality (2), wiring model → menu (3),
  first unit test (4).
- **M05 = 3 lessons**: `Future`/`async`/`await` mental model + demo loader
  (1), `FutureBuilder` + loading/error states + stable-Future rule (2),
  async `main()` bootstrap shape (3).
- **M06 = 3 lessons**: Stream mental model (1), `StreamBuilder` in menu +
  stable stream rule (2), manual `listen`/`cancel`/`StreamController` +
  broadcast as learning example (3).
- **M07 = 3 lessons**: route-stack model + `push`/`MaterialPageRoute` (1),
  placeholder `GameScreen` + auto back/`pop` (2), senior navigation
  comparison + `push`-returns-`Future` awareness (3).
- **M08 = 4 lessons**: `QuizQuestion` model + const bank (1), screen state
  + `_AnswerVisualState` enum (2), options render + submit/next flow (3),
  first widget tests (4).
- **M09 = 4 lessons**: `GamePhase`/`GameEndReason` + `Timer.periodic`
  ownership (1), phase-machine transitions for all handlers (2),
  `showDialog`/`popUntil` result dialog (3), timer/dialog/route widget
  tests incl. a real overflow fix caught by test (4).
- **M10 = 4 lessons**: plugin + `ProfileStore` concrete storage (1),
  `jsonEncode`/`jsonDecode` + defensive `fromMap` (2), `GameResult` +
  route-result via `pop(result)` + dialog-action refactor (3), apply-once
  + persist + reset + `setMockInitialValues` tests (4).
- **M11 = 3 lessons**: why `setState` doesn't scale + `ChangeNotifier`
  extraction (1), `notifyListeners`/`ListenableBuilder` + enum state
  switch (2), manual VM ownership lifecycle + pure-Dart VM tests (3).
- **M12 = 3 lessons**: tree lookup/`InheritedWidget` concept +
  `Provider.value` vs `create:` + `AppDependencyScope` (1),
  `read`/`watch` discipline (2), `ChangeNotifierProvider` auto-dispose +
  screen scope + provider-wrapped tests (3).
- **M14 = 4 lessons**: why a concrete store isn't the app boundary +
  `abstract interface class`/`implements` + explicit deletion (1),
  rxdart `BehaviorSubject`/`ValueStream`/`.value`/replay/guards (2),
  the three repos + `MultiProvider` + bootstrap + model parity +
  fakes (3), `MenuViewModel` stream subscription + `MenuLoadState`
  retirement + state-vs-event streams (4).

## QA notes

- Step 03 QA pass: all code snippets cross-checked against the verified
  on-disk M03 learner app (see Step 03 report, "Code ↔ Lesson Consistency").
- Intermediate (M01/M02) code states are shown as lesson *steps*; only final
  on-disk code exists per milestone — documented as intentional.
- Step 04 QA pass: all M04–M06 snippets cross-checked against the verified
  on-disk end-of-M06 learner app; lesson code that shows intermediate states
  is labelled as the state at that milestone (D14).
- Step 05 QA pass: all M07–M09 snippets cross-checked against the verified
  on-disk end-of-M09 learner app (29 tests: 18 unit + 11 widget).
  M08 lessons intentionally describe the `Spacer`-pinned body; M09 lesson 4
  documents the `Expanded`+`SingleChildScrollView` fix as the evolution the
  widget test forced (real overflow). `Timer` is `dart:async`, not a
  Stream — stated explicitly in lesson text.
- Step 06 QA pass: all M10–M12 snippets cross-checked against the verified
  on-disk end-of-M12 learner app (52 tests). M10 lesson 3 intentionally
  teaches the dialog→`_ResultAction` refactor as the fix for "popUntil
  can't carry a result" — supersedes the M09 `popUntil` ending path with
  a documented reason. `ProfileStore` is named per roadmap; it is a
  concrete class (repository contract is M14, `rxdart` deferred). M12
  scope is a single `Provider.value` — no `MultiProvider`, no stub
  dependencies (D20). `GameScreen` keeps `setState` until M19 per scope
  rules.
- Step 08 QA pass (first Agent Company v1 production run): M13 snippets
  verified verbatim against the on-disk end-of-M13 learner app (57
  tests). Two remediation cycles preserved in
  `AI_HANDOFF/work/milestones/M13/`: QA-IMPL-001 (`unawaited` absent at
  its roadmap-listed site → added) and QA-CONTENT-001 (false SnackBar
  prerequisite claim → SnackBar/`ScaffoldMessenger` now taught as
  first appearances). `MenuUiEvent` stays `abstract`+`final`, not
  `sealed` (M15); bridge lives inside `_MenuScreenViewState` rather
  than a wrapper widget (declared simplification); navigation
  controller still deferred (D20).
- Step 11 QA pass (M14, first milestone under permanent G16): all M14
  snippets verified verbatim against the on-disk end-of-M14 learner app
  (69 tests). `ProfileStore`/`MenuLoadState`/`_MenuLoading`/
  `_MenuErrorState` retired with explicit lesson instructions (no
  hidden deletion). Register: FR-08/FR-09/FR-19 → CONVERGED; FR-26
  opened (`languageCode` whitelist → M17). `expForNextLevel` remains
  FR-01 → M22. No M15+ leakage.
