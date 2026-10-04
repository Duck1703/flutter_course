# M28 → M29 handoff

## What M28 delivered (game-surface visual parity)

- `AppTokens` (318d verbatim) + `AppAssets` (subset 8 const,
  ~58 remaining → M29) + `surfaceGlow`/`headerSheen` +
  `DesignFrame` (375 design width).
- `flutter_svg ^2.3.0` + `google_fonts ^8.1.0`; 7 SVG + 1 PNG
  (menu-background byte-identical to senior).
- Chrome: `QzdsGameButton`, `GlassIconButton`,
  `GameScreenBackground`.
- Timer: 2 `AnimationController` + `part` painter (stadium,
  computeMetrics/extractPath) + critical pulse ≤0.2.
- Money: `animationTrigger`-gated motion + glitch + ladder
  CTA/dialog (`_LadderItem` private, NOT `GameDialogMoneyRow`).
- Surface: answers×3, question panel, audience poll, full
  dialog subsystem (shell + 3 families + layer, `ValueKey
  (runtimeType)` + `BackdropFilter` + dismiss rules).
- Atomic swap: `GameFeatureButtonData.icon`→`iconAsset`;
  feature-button painter/ripple; `GameScreen` thin-shell;
  old monolith `game_dialog_layer.dart`/`game_dialog_views.dart`
  deleted.
- 6 new ARB semantics keys en/vi.
- 259 → 309 tests; analyze clean; site 159 pages.

## Deliberate deferrals → M29 (recorded in register)

- **FR-30**: `SettingItemData.icon`→`iconAsset` +
  `_SettingIconBadge` (settings-dialog icons).
- **FR-28 residual**: `_SettingsAccountRow` chrome.
- **FR-32 residual**: onboarding visuals — `OnboardingTokens`,
  `BackdropFilter` scrim, `AnimatedSwitcher` indicator,
  `OnboardingGameButton` glow/scale, header config per step.
- **FR-31 residual**: quiz-bank/repo-message literals (ARB gap
  narrowed by 6 keys, not closed).
- `MenuTokens` → `AppTokens` migration for menu/settings widgets.
- `MenuDialogLayer` (in-Stack menu dialogs, sealed
  `MenuDialogState`) — senior menu-dialog transport parity.
- `AppDependencyScope` parity + folder/file convention audit.
- Full senior asset parity (~58 `AppAssets` consts + files).
- Optional: widget-preview catalog; release-kit walkthrough.

## Parity notes M29 must not "fix"

- Timer critical pulse + feature-button sheen/ripple do NOT
  honor `MediaQuery.disableAnimations` — verbatim senior
  behavior, documented in L03/L06.
- `QzdsButtonScale` is a size preset, not press-scale.
- `_LadderItem` is private to `game_money_ladder_dialog.dart`;
  `GameDialogMoneyRow` belongs to the dialog shell
  (confirm/result dialogs only).
- `AppAssets` subset is deliberate — do not add consts without
  shipping the asset.

## NOT_PERFORMED flags

- `REAL_DEVICE_VISUAL_CHECK` — no device run; verification
  carried by 309 tests + `flutter build web`.
- `REAL_DEVICE_PLATFORM_CHECK` (M27 carry-over).
- `LIVE_SUPABASE_CONNECTIVITY` / `LIVE_AUTH_FLOW` /
  `LIVE_PROFILE_SYNC` (M23–M25 carry-over, no credentials).
