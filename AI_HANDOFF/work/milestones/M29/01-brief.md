# M29 Brief — Senior Alignment Pass & Course Completion (Phase G)

## Roadmap scope (MILESTONE_ROADMAP.md §Phase G)

Menu dialog layer parity (sealed `MenuDialogState` + in-Stack
`MenuDialogLayer`), event-bridge form, file/folder conventions,
`AppDependencyScope` parity, docs/consistency review, optional
preview catalog (2–3 widgets), release-kit walkthrough (explained,
not executed), final feature checklist, **fidelity sweep: every
`ACTIVE_TEMPORARY` row → `CONVERGED` or `REMOVED`**.

## Register scope — the 4 remaining ACTIVE_TEMPORARY rows

| FR | Content | Resolution path |
|----|---------|-----------------|
| FR-29 | Settings entry dispatch → `showDialog` events | `MenuDialogState` + `MenuDialogLayer` + scope conversion |
| FR-30 | `SettingItemData.icon` `IconData` | → `iconAsset` + `_SettingIconBadge` + full settings chrome port |
| FR-31 | l10n gap | +11 senior keys, retire 5 learner-only, verify literals=parity → close |
| FR-32 | Onboarding visuals | `OnboardingTokens`/card/button/indicator/actions/overlay port |

Residuals folded in: FR-16 (menu-side dialog mechanism),
FR-14-note (leaderboard entry card + row asset pipeline),
FR-28-residual (`_SettingsAccountRow` auth chrome),
`MenuTokens`→`AppTokens` retirement (course-invented, no senior
counterpart), full asset parity, `menu_view_model.dart`→
`menu_screen_view_model.dart` convention rename, theme seed.

## SENIOR EVIDENCE (verified on disk)

### W1 — Menu dialog layer (FR-29)

- `lib/view_models/menu/menu_dialog_state.dart` (57d) — sealed
  `MenuDialogState`; `None/Leaderboard/Settings/Auth/SignOut`;
  `isVisible`; `transitionKey => runtimeType`. No Hidden variant.
- `lib/widgets/menu/menu_dialog_layer.dart` — `SizedBox.expand` →
  `AnimatedSwitcher` (fade, `dialogMotionLong`) → exhaustive
  switch → 4 scopes keyed `ValueKey(transitionKey)`. Ctor:
  `dialogState, onDismiss, onDismissLockChanged?, profile,
  isAuthenticated, onAccountAction?`.
- `lib/widgets/menu/menu_dialog_backdrop.dart` — `ClipRect` +
  `BackdropFilter` (`dialogHazeBlurSigma`) + opaque dismiss-tap +
  haze scrim + `SafeArea`/`Center`/`DesignFrame` +
  `foregroundOverlay` slot.
- `lib/widgets/menu/menu_screen_view.dart` — `PopScope(canPop:
  !dialogState.isVisible)` + `_dialogDismissLocked` + Stack:
  background → Column → `Positioned.fill(MenuDialogLayer)` →
  `Positioned.fill(OnboardingOverlayScope)`.
- 4 scopes (`menu_{settings,leaderboard}_dialog_scope`,
  `menu_{auth,sign_out}_dialog_scope`) — `ChangeNotifierProvider
  (create: ctx.read repos)` → private event-bridge stateful →
  `MenuDialogBackdrop` + view; settings scope: time-picker as
  `foregroundOverlay` (`_SettingsTimePickerOverlay`); sign-out:
  `isLoading`→`onDismissLockChanged` + dismiss disabled.
- `MenuScreenViewModel` — `_dialogState` +
  `requestLeaderboardDialog/requestSettingsDialog/
  requestAuthAction/dismissCurrentDialog/_setDialogState`
  (equality guard).
- `MenuScreenUiEvent` — senior has **2 variants only**
  (Game/SnackBar); learner's 4 `*Requested` dialog events retire.
- `_MenuScreenEventBridge` — senior separate widget (subscribe in
  `didChangeDependencies`, `==` guard, dispose cancel).

### W2 — Menu surface decomposition (folder/file convention)

Senior `widgets/menu/` = 20 files; learner inlines everything in
`screens/menu_screen.dart` (`_ProfileHeader`…`_PlayButton`).
Port: `menu_screen_content.dart`, `menu_screen_view.dart`,
`gradient_cta_button.dart`, `screen_top_inset.dart`,
`screen_bottom_inset.dart`, `leaderboard/leaderboard_entry_card
.dart` (SVG trophy + gradient + `menuLeaderboardEntrySubtitle`),
`profile/{menu_profile_header,earnings_card,level_progress_card,
profile_avatar_image,stats_card}.dart` (+ menuLevel* keys).
Then `MenuTokens` retirement (delete `core/menu_tokens.dart` —
zero senior counterpart) + `MenuViewModel`→`MenuScreenViewModel`
rename (file+class, compile-forced) + theme → senior
`ColorScheme.fromSeed(seedColor: Colors.deepPurple)` (light —
replaces learner dark seed; visual-verify via tests).

### W3 — Settings chrome (FR-30 + FR-28 residual)

- `setting_item_data.dart`: `IconData icon`→`String iconAsset`
  (sealed family shape identical).
- `settings_item_factory.dart`: `AppAssets.icon{Speaker,Music,
  Vibration,BellNotification,Filter}`; `notificationTimeText:
  l10n.notificationTimeSetting` (key already in learner).
- Port verbatim: `settings_dialog_shell.dart` (173d),
  `settings_section.dart`, `setting_switch_row.dart` (`_Setting
  IconBadge` gradient badge + SvgPicture), `setting_time_picker
  _row.dart`, `settings_card.dart` (sections + `v$appVersion` +
  QzdsGameButton done), `menu_settings_dialog.dart`,
  `settings_account_row.dart` (auth action button), `time_picker
  _wheels.dart` + `wheel_picker.dart` (senior picker files —
  learner's `notification_time_picker_dialog.dart` stays? check
  per-file), `menu_settings_dialog_scope.dart` (with
  `_SettingsTimePickerOverlay`).
- Retire monolith `settings_dialog.dart` (461d) + learner
  `settings_dialog_test.dart` → port senior
  `menu_settings_dialog_test.dart` + `notification_time_picker
  _dialog_test.dart`.
- New l10n: `settingsIconSemanticLabel`, `closeButton`,
  `saveButton`, `hourPickerSemanticLabel`,
  `minutePickerSemanticLabel`, `languageSetting`.

### W4 — Onboarding visuals (FR-32)

- Port verbatim: `core/onboarding_design_tokens.dart` (84d),
  `data/onboarding/onboarding_header_config.dart`,
  `widgets/onboarding/{onboarding_dialog_card,
  onboarding_game_button,onboarding_step_indicator,
  onboarding_step_actions}.dart`.
- Adapt: `onboarding_content_data.dart` → `onboardingHeaderFor`
  (config vs plain strings); `onboarding_overlay.dart` → senior
  4-class restructure (`BackdropFilter` blur16 + haze scrim +
  `AnimatedSwitcher` 500ms + card-keyed 400ms + indicator below
  card + skip hidden on ready); `onboarding_overlay_scope.dart`
  → restore senior `FutureBuilder`→`StreamBuilder`→Provider chain
  verbatim (documented learner divergence now closes).
- Assets: `bell-notification.svg`, `filter.svg`.
- Tests: port `onboarding_overlay_scope_test.dart` (201d);
  update `onboarding_overlay_test.dart`; `onboarding_app_test`
  optional.

### W5 — Leaderboard asset pipeline (FR-14 residual)

- `leaderboard_entry_data.dart`: +`avatarAsset`, `rankAsset`,
  `style` (`LeaderboardRowStyle{first,second,third,glass,
  currentUser}`); static entries carry asset paths.
- Port `leaderboard_avatar.dart` (170d) + update
  `leaderboard_row.dart` (rank SVG badge + score-coin + row
  style gradients), `leaderboard_list.dart`,
  `leaderboard_popup_body.dart` if senior differs.
- VM static entries (`avatarTauHuDiChill` + `leaderboardRank
  Current` for "bạn" row).
- Assets: `leaderboard/` dir (score-coin.png, 4 medal SVGs,
  7 avatar PNGs, current-user-accent.png), `avatars/avatar.png`,
  `icons/{trophy,gear,level-rank}.svg`, `decorations/coin-large
  +coin-small.svg`.
- Port `leaderboard_avatar_test.dart`.

### W6 — l10n parity close (FR-31)

- ADD 11 senior keys: `closeButton`, `hourPickerSemanticLabel`,
  `languageSetting`, `menuExpToNextLevel`, `menuExperienceLabel`,
  `menuLeaderboardEntrySubtitle`, `menuLevelShort`,
  `menuMaxLevelReached`, `minutePickerSemanticLabel`,
  `saveButton`, `settingsIconSemanticLabel` (+ vi.arb values
  verbatim).
- RETIRE learner-only: `questionCounter`, `gameRoomTitle` (dead —
  zero usages); `leaderboardSubtitle`→`menuLeaderboardEntry
  Subtitle` (entry card); `menuExpProgress`→`menuExpToNextLevel`
  (level card); `notificationTimeTitle`→`notificationTimeSetting`
  (already exists).
- Casing check: keys baking 'START GAME'-style presentation
  casing → sentence-case + `.toUpperCase()` at widget layer
  (senior convention) where senior key exists.
- **Verify & close**: quiz-bank literals + repo messages are
  parity-true (senior hardcodes identical English literals —
  verified), so FR-31 closes as full-ARB-parity.

### W7 — Structure & appendix

- `MenuViewModel`→`MenuScreenViewModel` + file rename (senior
  convention).
- Event bridge → senior `_MenuScreenEventBridge` widget form
  (separate widget, cached `_navigationController`).
- `AppDependencyScope` — agent-verified PARITY (same 8
  `Provider.value`, order irrelevant); record, no change.
- `previews/` appendix: port `preview_fixtures.dart` +
  `preview_app_dependencies.dart` + 2–3 preview files
  (menu/settings/onboarding — natural for ported widgets);
  `package:flutter/widget_previews.dart` ships in Flutter
  3.41.9 SDK (verified on disk).
- Release-kit walkthrough: `learner-app/docs/release-kit-
  walkthrough.md` explaining `scripts/kit` + `.release-kit`
  concepts (NOT executed).
- Final feature checklist vs `FEATURE_INVENTORY.md` (artifact).
- `CURRICULUM_TRACEABILITY.md` status review.
- Assets: copy ALL 50 senior `assets/images` files (42 have
  consts; 8 dead-in-senior ship for byte-parity: app-launcher
  + 7 rank-N-badge) — `app_assets.dart` verbatim all 42 consts.

## Lesson plan (executable order)

| # | Scope | Files | Tests |
|---|-------|-------|-------|
| L01 | Foundation: full assets + `AppAssets` verbatim + `OnboardingTokens` + l10n +11/–2 dead keys + regen | pubspec assets (already dirs), `app_assets.dart`, `onboarding_design_tokens.dart`, ARB×2 | +0 → 309 |
| L02 | Settings chrome: iconAsset swap + shell/section/rows/card/dialog/account_row + picker files + factory | `setting_item_data`, factory, 8 settings files + retire monolith | +N (menu_settings + picker tests) |
| L03 | Leaderboard pipeline: DTO asset fields + avatar + row/list/popup + entry card + VM entries | `leaderboard_*`, `leaderboard_entry_card` | +N |
| L04 | Menu surface: profile×5 + gradient_cta + insets×2 + `menu_screen_content` + `MenuTokens` delete + level keys | `profile/*`, `gradient_cta`, `screen_*_inset`, `menu_screen_content`, `menu_tokens` ✕ | +N |
| L05 | Dialog layer: state + backdrop + layer + VM dialogState + `MenuScreenViewModel` rename + 4 scopes + view + PopScope + 2-event bridge + delete showDialog fns | `menu_dialog_*`, `menu_screen_view`, scopes×4, VM, ui_event, menu_screen | +N (layer test + rewrites) |
| L06 | Onboarding: header config + content adapt + card/button/indicator/actions + overlay restructure + scope chain | `onboarding_*` ×6 + scope + content | +N (scope test + overlay update) |
| L07 | Sweep: theme, event-bridge form, previews appendix, release-kit doc, feature checklist, FR-31 close, traceability | main theme, `previews/*`, `docs/`, artifacts | +N |

Exact checkpoint counts land in `02-implementation-evidence.md`
(lesson test inventory verified on disk per batch).

## Risks / decisions

- **Biggest surface to date** (~50+ ported files + 50 assets +
  ~12 test files). Mitigate with W-ordering: leaf widgets before
  compositions, scopes before layer, layer before view.
- `MenuScreenViewModel` rename is compile-forced and mechanical;
  land in L05 alongside VM changes.
- Theme seed change (dark→light senior) alters Material defaults —
  custom-painted UI is token-driven; widget tests verify.
- `MenuTokens` deletion gated on zero remaining `import
  'menu_tokens.dart'` / `MenuTokens.` references.
- Old `showXxxDialog` fns + `settings_dialog.dart` monolith +
  `_LeaderboardEntry`-style private widgets all retire — verify
  no import stragglers before deletion.
- Sign-out dismiss-lock (`onDismissLockChanged`) is senior-only
  behavior to preserve exactly (PopScope + backdrop-dismiss off
  while loading).
- Settings scope `foregroundOverlay` picker is the nested-overlay
  pattern — preserve verbatim incl. second `ModalBarrier`.
- `previews/` is appendix-grade: port fixtures + 2–3 catalogs,
  don't port all 63 @Previews.
- `REAL_DEVICE_*`/`LIVE_*` flags remain NOT_PERFORMED — course-
  level documented, doesn't block completion.

## Acceptance

- `flutter analyze` clean; `flutter test` all-pass; `flutter
  build web` PASS.
- Zero `showDialog` call-sites in menu flow; dialogs state-driven.
- `lib/` mirrors senior conventions (menu decomposed, no private
  mega-widgets in screens).
- ARB keys: senior superset + learner-only removed.
- `SENIOR_FIDELITY_REGISTER`: zero `ACTIVE_TEMPORARY` rows.
- Feature checklist artifact: all CORE features observable.
- Sequential replay reproduces every lesson checkpoint.
