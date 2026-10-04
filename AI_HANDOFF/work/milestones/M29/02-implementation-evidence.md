# M29 — Implementation Evidence (Flux)

Milestone: **M29 — Senior-Alignment Sweep & Course Completion**
Role: Flux (implementation engineer)
Date: 2025 (session of record)
Baseline: M28-end — `flutter analyze` clean, **309/309** tests, `flutter build web` PASS
Final: `flutter analyze` clean, **396/396** tests, `flutter build web` PASS
(+87 tests net)

## Executive summary

M29 converged every remaining learner simplification to senior parity.
The dominant work was the **menu dialog layer** (FR-29): the menu side
of the app now uses the same state-driven pattern the game side has had
since M21 — a sealed `MenuDialogState` rendered in-Stack by
`MenuDialogLayer`, with `MenuScreenViewModel` dispatching dialog state
instead of one-off UI events. Around that center, the milestone ported
the full senior settings chrome (FR-30), leaderboard pipeline (FR-14
residuals), menu surface, onboarding visuals (FR-32), localization
conventions (FR-31), and retired every course-invented shim
(`MenuTokens`, route-transport `showXxxDialog` functions, interim event
classes, simplified widgets). `lib/` file tree is now a subset of
senior's (preview catalogs intentionally partial per brief), with zero
learner-only files.

## Lesson batches landed (each compiles + tests green at its boundary)

| Batch | Landed | Test count |
|-------|--------|-----------|
| L01 Foundation | 50 senior `assets/images` shipped, `app_assets.dart` verbatim — **45 consts**, byte-identical to senior (incl. ~10 consts for files senior ships without referencing, kept for byte-parity), `onboarding_design_tokens.dart` verbatim, +11 senior ARB keys / −2 dead keys, l10n regen | 309 → 309 |
| L02 Settings chrome | `setting_item_data.iconAsset` + `_SettingIconBadge`, `settings_dialog_shell`/`settings_card`/`settings_section`/`setting_switch_row`/`setting_time_picker_row`/`settings_account_row`/`menu_settings_dialog`/`menu_settings_dialog_scope`/`notification_time_picker_dialog`/`time_picker_wheels`/`wheel_picker` verbatim; old `settings_dialog.dart` monolith retired; senior `menu_settings_dialog_test` + `notification_time_picker_dialog_test` ported; FR-31 shared ARB values aligned to sentence-case + `.toUpperCase()` at render sites (31 value diffs → parity) | 309 → 313 |
| L03 Leaderboard pipeline | `leaderboard_entry_data` (+`avatarAsset`/`rankAsset`/`LeaderboardRowStyle`/`avatarUrl`), repository `_LeaderboardRecord`/`toEntry` pipeline + `_avatarAsset`/`_rankAsset`/`_rowStyle` mappers, `leaderboard_dialog_view_model` (snapshot model, pinned current-user row, refresh w/o moving pin), `leaderboard_list`/`leaderboard_popup_body`/`leaderboard_row`/`menu_leaderboard_dialog`/scope verbatim; `leaderboard_avatar_test` + `menu_leaderboard_dialog_test` ported; fake aligned | 313 → 321 |
| L04 Menu surface | `menu_profile_header`/`earnings_card`/`level_progress_card`/`stats_card` (profile_avatar_image already identical), `gradient_cta_button`, `menu_screen_content`, `screen_top_inset`/`screen_bottom_inset` verbatim; auth dialog chrome re-ported verbatim (`menu_auth_dialog`, `menu_auth_dialog_content`, `menu_sign_out_dialog`, `menu_loading_overlay`, `onboarding_overlay_scope` restoring inner StreamBuilder); `language_chip_row` re-ported verbatim (was MenuTokens adaptation); `onboarding_game_button` added (shared leaf); tests `menu_gradient_cta_button_test`/`menu_level_progress_card_test`/`menu_profile_avatar_test`/`menu_screen_content_layout_test` ported | 321 → 345 |
| L05 Dialog layer | `menu_dialog_state.dart` (sealed, 5 variants), `menu_dialog_layer.dart` (runtimeType-keyed AnimatedSwitcher), `menu_screen_view.dart` (PopScope + dismiss-lock + backdrop), `menu_screen_view_model.dart` (rename from `MenuViewModel`; `dialogState` surface replaces dialog events), `menu_screen.dart` verbatim (2-event bridge: `MenuGameRequested` + `MenuSnackBarRequested`), `menu_screen_ui_event.dart` verbatim (4 interim event classes retired), auth×2 scopes verbatim (route fns removed), `menu_view_model.dart` + old test retired; tests: `menu_dialog_layer_test` + `menu_screen_view_model_test` ported; `sealed_state_test` updated to senior 2-variant event family + new `MenuDialogState` group; `menu_provider_scope_test`/`menu_screen_ui_events_test` call-sites updated | 345 → 369 |
| L06 Onboarding | `onboarding_header_config`, `onboarding_content_data` (+`onboardingHeaderFor`), `onboarding_dialog_card`, `onboarding_step_actions`, `onboarding_step_indicator`, `onboarding_overlay` verbatim (BackdropFilter haze, AnimatedSwitcher, animated-width indicator, badge assets, `OnboardingGameButton` glow/scale); `menu_tokens.dart` DELETED (zero consumers); tests `onboarding_overlay_test`/`onboarding_overlay_scope_test`/`onboarding_app_test`/`onboarding_view_model_test` ported (incl. real-permission flow preserved from M27) | 369 → 383 |
| L07 Sweep | `main.dart` verbatim (senior theme `ColorScheme.fromSeed(seedColor: Colors.deepPurple)`, log prefix, bootstrap order), `app_dependency_scope.dart` verbatim, `app_navigation_controller.dart` verbatim (drops `goBack<T>([T? result])` superset — no callers used it), previews appendix (`preview_fixtures`/`preview_sample_data`/`preview_app_dependencies` + `common`/`menu`/`onboarding` catalogs — SDK `widget_previews`, brief-scoped subset), `docs/release-kit-walkthrough.md` (explains `scripts/kit`+`.release-kit`, NOT executed), remaining senior test gaps ported (`widget_test`, `apple_auth_service_test`, `surface_glow_gradient_test`, `dialog_shell_header_test`, `pill_button_glow_test`, `leaderboard_dialog_view_model_async_test` + harness, canonical `settings_view_model_test`/`leaderboard_dialog_view_model_test`/`supabase_auth_repository_test`/`user_settings_repository_test`/`menu_auth_dialog_view_model_test`/`game_screen_view_model_regression_test`), FR-31 closed (−3 dead learner-only ARB keys), stray `lib/build/` removed | 383 → 396 |

## Fidelity register rows resolved

- **FR-29 → CONVERGED**: `MenuDialogState` sealed family + in-Stack
  `MenuDialogLayer` + keyed `AnimatedSwitcher` + dialog-scoped VMs +
  PopScope + dismiss-lock. **Zero `showDialog`** in `lib/` (verified
  by grep — only a comment mention remains).
- **FR-30 → CONVERGED**: `SettingItemData.iconAsset` +
  `_SettingIconBadge` SVG badges; full settings chrome verbatim.
- **FR-31 → CONVERGED**: ARB now holds senior's full key set + 1
  documented product-name diff (`appTitle` = "AI Millionaire");
  31 shared-value diffs aligned to sentence-case convention
  (`.toUpperCase()` at widgets); 3 dead learner-only keys removed;
  zero senior-only keys missing.
- **FR-32 → CONVERGED**: full onboarding visual stack ported;
  scope's documented simplification (dropped inner StreamBuilder)
  restored; all 26 senior onboarding tests pass verbatim.
- **FR-28 residual → CONVERGED**: `_SettingsAccountRow` ported with
  auth chrome (account pill + loading overlay + sign-out dismiss-lock).
- **FR-14/FR-16 residuals → CONVERGED**: leaderboard entry card +
  asset pipeline, menu-side dialog mechanism, popup body/row parity.
- **`MenuTokens` → REMOVED**: course-invented shim; `AppTokens` is the
  single token source (file deleted after last consumer ported).

## Documented learner deviations retained (not ACTIVE_TEMPORARY)

| File | Deviation | Reason |
|------|-----------|--------|
| `level_config.dart` | `maxExpRequirement = 9007199254740991` (2⁵³−1) vs senior int64 max | dart2js cannot represent int64 max; web target. In-file documented; EXP never approaches either bound. |
| `leaderboard_repository.dart` | `@visibleForTesting static entryFromRow` seam | exposes private `_LeaderboardRecord` mapper for defensive-parse coverage; same seam category as M26/M28. Logic inside verbatim. |
| `game_session_state_data.dart` | `final class` variants (senior: `class`) | learner sealed-state convention, semantically stricter; structure 1:1. |
| `user_profile_data.dart` | member ordering + VI doc comments | logic-identical. |
| `appTitle` l10n value | "AI Millionaire" | learner product rename (documented convention). |
| `lib/previews/` | 6 of 12 senior catalogs ported | brief-scoped appendix subset. |
| `lib/l10n/app_localizations*.dart` | generated | reflects learner ARB (product rename only). |

Remaining comment-only diffs across ~10 data/test files: VI doc blocks
preserved per course convention on files whose logic is verbatim.

## Structure audit result

- `lib/` dirs: identical to senior (stray generated `lib/build/` removed).
- `lib/` files: **zero learner-only files**; missing only the 6
  intentionally-unported preview catalogs.
- `test/`: all senior test files present; learner retains extra course
  tests (`sealed_state_test`, `localization_switch_test`,
  `menu_provider_scope_test`, `repositories/*`, `helpers/` fakes —
  course-added coverage, not senior-mirrored).
- Zero `showDialog`, zero `MenuTokens` references remain.

## Known non-blocking warnings

- `flutter build web`: MaterialIcons tree-shake font warning + wasm
  dry-run notice — pre-existing, same as M26–M28.
- `33 packages have newer versions incompatible` — pub outdated notice,
  not an error.

## Caveats carried (unchanged, course-level documented)

- `REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED`
- `REAL_DEVICE_VISUAL_CHECK: NOT_PERFORMED`
- `LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED`
- `LIVE_AUTH_FLOW: NOT_PERFORMED`
- `LIVE_PROFILE_SYNC: NOT_PERFORMED`
- Release-kit `scripts/kit` is explained in
  `learner-app/docs/release-kit-walkthrough.md`, not executed; the
  learner app intentionally does not vendor it.
