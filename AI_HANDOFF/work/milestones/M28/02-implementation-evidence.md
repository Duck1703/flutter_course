# M28 Implementation Evidence — Visual Parity / Senior UI Polish

**Stage:** Flux (implementation)
**Baseline:** M27-end = 259 tests, analyze clean, senior `c8eb860`.
**Result:** 309/309 tests pass (post-QA remediation: +12 tests), `flutter analyze` clean, `flutter build
web` PASS. 36/36 verbatim-port files byte-identical to senior after package
rename (`ai_millionaire` → `ai_millionaire_course`).

## What was built

### New dependencies (`pubspec.yaml`)

```yaml
flutter_svg: ^2.3.0      # senior pin verbatim
google_fonts: ^8.1.0     # senior pin verbatim
```

Assets section added (subset):

```yaml
assets:
  - assets/images/icons/
  - assets/images/backgrounds/
```

### Asset subset shipped (7 SVG + 1 PNG, copied verbatim from senior)

`assets/images/icons/`: `game-audience.svg`, `game-back.svg`,
`game-fifty-fifty.svg`, `game-lightning.svg`, `game-money.svg`,
`game-sparkle.svg`, `game-trophy.svg`.
`assets/images/backgrounds/menu-background.png`.

`lib/core/app_assets.dart` is a **documented subset port** — declares
only constants for shipped assets (8 paths). Remaining senior constants
(avatars, decorations, leaderboard, settings icons) arrive with their
widgets at M29 — no dangling references.

### Core infra — verbatim ports

| File | Purpose |
|------|---------|
| `lib/core/app_design_tokens.dart` | `AppTokens` (spacing/radii/motion/colors/typography via `GoogleFonts.beVietnamPro`/`robotoMono`/interTight + all gradients) + `QzdsButtonScale`; exports `app_assets.dart` + `surface_glow_gradient.dart` |
| `lib/core/app_assets.dart` | subset (above) |
| `lib/core/surface_glow_gradient.dart` | `SurfaceGlow` helper |
| `lib/widgets/common/design_frame.dart` | `DesignFrame` width-375 cap (`screenDesignWidth=375`) |
| `lib/widgets/common/qzds_game_button.dart` | gradient + sheen + glow button (`QzdsButtonScale` = size preset) |
| `lib/widgets/common/glass_icon_button.dart` | glass circle icon button (SVG + semantics) |
| `lib/widgets/common/game_screen_background.dart` | menuBackground cover + dark gradient overlay |

### Game-surface widgets — verbatim ports (19 files)

- `timer/`: `GameCountdownTimer` (progress tween 1s + critical pulse
  450ms `repeat(reverse)` at progress ≤ 0.2, warning tier ≤ 0.4,
  `Semantics` label) + `game_countdown_timer_progress_painter.dart`
  (`_PillProgressPainter` stadium `Path`, gradient stroke, exposed via
  testing helper).
- `money/`: `GameMoneyAmount` (yellow pill + `GameMoneyAmountMotion`
  trigger-increment numeric count + glitch layers, 260ms,
  `MediaQuery.disableAnimations` → `Duration.zero`) +
  `GameMoneyLadderDialog` + `GameMoneyLadderCtaButton`.
- `lifelines/`: `GameFeatureButton` (`_GameFeatureButtonPainter` rotating
  gradient + ripple, SVG icon, press `AnimatedScale`, disabled opacity,
  localized `Semantics` labels) + `GameFeatureButtonBar` +
  `GameAudiencePollRow`.
- `answers/`: `GameAnswerOption` + `GameAnswerOptionColors` +
  `GameAnswerOptionList` (reveal-blink suppressed under reduced motion).
- `questions/game_question_panel.dart` (gradient panel + lightning SVG
  counter badge `n/15`).
- `dialogs/`: `GameDialogShell` (backdrop-blur scrim, token chrome,
  `MediaQuery.disableAnimations` transitions) + `GameResultDialogs` +
  `GameHelpDialogs` + `GameConfirmDialogs` + `GameDialogButton` /
  `GameDialogMoneyRow` (inside shell file) + converged
  `game_dialog_layer.dart` (191 lines — `AnimatedSwitcher` keyed on
  `runtimeType`, backdrop-dismiss rules, slide+fade transition).
- `layout/`: `GameScreenTopBar` (`GlassIconButton` exit + countdown) +
  `GameScreenBody` (money + question + answers composition).

### Converged files

- `lib/screens/game_screen.dart` — 629 → 201 lines, byte-identical to
  senior: thin `const GameScreen()` shell, `ChangeNotifierProvider`
  self-provisioning, `_GameScreenEventBridge` private bridge.
- `lib/data/game/game_screen_data.dart` — `GameFeatureButtonData.icon`
  `IconData` → `iconAsset` `String` (FR-34 CONVERGED); file now
  structurally identical to senior (113 code lines each).
- `lib/view_models/game/game_screen_presentation_mapper.dart` — feature
  buttons emit `AppAssets.iconGameFiftyFifty/Audience/Sparkle/Trophy`;
  `material.dart` import replaced by `app_assets.dart`.
- `lib/l10n/app_en.arb` / `app_vi.arb` — +6 keys verbatim senior:
  `optionSemanticLabel` (placeholders `{label}`,`{answer}`),
  `selectedStateLabel`, `correctStateLabel`, `incorrectStateLabel`,
  `prizeAmountSemanticLabel` (`{amount}`), `timeRemainingSemanticLabel`
  (`{time}`); `gen-l10n` regenerated.

### Retired learner files

- `lib/widgets/game/game_dialog_views.dart` (726-line monolith) —
  replaced by senior's 3 family files + shell.
- `lib/widgets/game/game_dialog_layer.dart` (239-line learner layer) —
  replaced by senior `dialogs/game_dialog_layer.dart`.
- `_DialogShareButton` scaffold — inside result dialogs → senior
  `GameDialogButton(shareColor)` path.

### Tests

- Ported verbatim (12 files): `game_screen_test_helpers`,
  `game_screen_flow_test` (7), `game_countdown_timer_test` (7),
  `game_feature_button_test` (5), `game_money_amount_test` (6),
  `game_answer_option_test` (4), `game_answer_option_reveal_blink_test`
  (3), `game_question_panel_test` (1), `qzds_game_button_test` (4),
  `game_dialog_layer_test` (11 — replaces learner's 10-test VI variant;
  adds money-ladder fit/all-levels, action-button width/shadow,
  compact-height scenarios), `game_dialog_money_row_test` (4),
  `game_screen_result_flow_test` (8 — play-again sync, exit-motion,
  rapid-tap guard, reduced-motion).
- Not ported (target M29-deferred widgets): senior
  `dialog_shell_header_test` (needs `SettingsDialogShell` — FR-30),
  `pill_button_glow_test` (needs `OnboardingGameButton` — FR-32),
  menu/onboarding/settings test files whose widgets ship at M29.
- `test/widgets/game_screen_test.dart` — rewritten: `GameScreen` no
  longer takes `viewModel:`; host = `MultiProvider` fakes +
  `localizedTestApp(vi)` + `const GameScreen()`; real bank
  (`gameSampleQuestions`, 15 questions) via `answerOption` predicate +
  `ensureVisible` (senior scroll layout puts later options below the
  800×600 test viewport); uppercase dialog assertions; unique learner
  coverage kept (victory 15-Q, walk-away + save-once, timeout,
  menu→game→THOÁT, VI strings).
- `game_dialog_layer_test.dart` — REPLACED by senior-verbatim
  11-test file (post-QA: learner's 10-test VI variant retired; the 3
  missing senior scenarios are ported). VI dialog coverage persists in
  `game_screen_test.dart`.
- `menu_screen_ui_events_test.dart` — `THANG TIỀN THƯỞNG` assertion.
- `game_screen_view_model_test.dart` — `icon: IconData(0)` →
  `iconAsset: 'test/icon.svg'` (2 sites); unused material import
  dropped.

## Behavior notes / deliberate parity choices

1. **No `disableAnimations` on timer pulse / feature-button sheen /
   ripple** — senior does not honor it there; ported verbatim (per
   brief rule 2). Reduced-motion IS honored exactly where senior does:
   money motion duration→0, answer blink suppression, dialog
   `AnimatedSwitcher` duration→0.
2. **GoogleFonts runtime fetch** — `GoogleFonts.beVietnamPro` fetches
   at runtime like senior; web build embeds fallback; behavior is
   senior-identical.
3. **Money amount mid-animation text** — `GameMoneyAmountMotion`
   interpolates digits; assertions must target post-settle state
   (senior tests do the same).
4. **`GameDialogButton` uppercase** — views call `.toUpperCase()` on
   l10n labels (senior verbatim); VI titles render uppercase.
5. **Feature-button `semanticLabel` data field** — emitted by mapper
   (English strings) but widget renders localized
   `l10n.*SemanticLabel` — senior verbatim.
6. **REAL_DEVICE_VISUAL_CHECK: NOT_PERFORMED** — web/test verification
   only; painter/motion verified via widget tests, not on-device.

## Register deltas for canonical sync (Atlas stage)

- FR-34 → `CONVERGED` (iconAsset pipeline + GameFeatureButton).
- Game-side dialog chrome + timer/motion/token rows → `CONVERGED`
  (exact FR ids to be fixed at sync: FR-04 visual clauses, FR-33 game
  dialog shell).
- FR-30, FR-32, FR-28-residual → retarget M29 (register update).
- `MenuTokens` → `AppTokens` migration for menu widgets → M29 (noted).

## Verification numbers

| Check | Result |
|-------|--------|
| `flutter pub get` | 6 deps changed — OK |
| `flutter analyze` | clean |
| `flutter test` | **309/309** (+50 net vs 259) |
| `flutter build web` | PASS (50.7s; CupertinoIcons font warning = pre-existing) |
| Ported-file parity | **36/36 verbatim-port files byte-identical** after pkg rename |
| Senior repo | clean at `c8eb860` (re-checked post-impl) |
