# M28 Atlas Brief — Polish: animations, CustomPainter, design tokens

**Roadmap source:** `project-context/MILESTONE_ROADMAP.md` §M28.
**Gate entered from:** M27 = `MILESTONE_COMPLETE` (259 tests, site 152 pages, senior `c8eb860` clean).

## Learner outcome (roadmap verbatim)

Implicit transitions; `AnimationController` choreography; timer pulse;
money motion; button sheen; `CustomPainter` progress ring; consolidate
`AppTokens`/`AppAssets`; SVG usage where applicable.

## Visible project result (roadmap verbatim)

- Countdown ring painted and pulses under 20%.
- Money amount animates on change.
- Dialogs/buttons gain gradient, sheen, and glow styling.
- Selected asset set swaps to SVG.

## Senior evidence (read-only source `../flutter-accelerator-ai`, HEAD `c8eb860`)

### Core infra to port (verbatim, package rename `ai_millionaire_course`)

| File | Lines | Notes |
|------|-------|-------|
| `lib/core/app_design_tokens.dart` | 318 | `AppTokens`, `QzdsButtonScale`, GoogleFonts type ramp, all gradients; exports `app_assets.dart` + `surface_glow_gradient.dart` |
| `lib/core/app_assets.dart` | 73 | **Subset port** — only constants for assets actually shipped by M28 (see asset list) |
| `lib/core/surface_glow_gradient.dart` | 72 | Gradient helper |
| `lib/widgets/common/design_frame.dart` | 20 | Screen design width scale |
| `lib/widgets/common/qzds_game_button.dart` | 145 | Gradient + sheen + glow press-scale button |
| `lib/widgets/common/glass_icon_button.dart` | 53 | Back-button glass chrome |
| `lib/widgets/common/game_screen_background.dart` | 28 | `menuBackground` image cover + gradient overlay |

### Game-surface widgets to port (verbatim)

| File | Lines |
|------|-------|
| `lib/widgets/game/timer/game_countdown_timer.dart` | 185 |
| `lib/widgets/game/timer/game_countdown_timer_progress_painter.dart` | 73 |
| `lib/widgets/game/money/game_money_amount.dart` | 98 |
| `lib/widgets/game/money/game_money_amount_motion.dart` | 196 |
| `lib/widgets/game/money/game_money_ladder_cta_button.dart` | 109 |
| `lib/widgets/game/money/game_money_ladder_dialog.dart` | 209 |
| `lib/widgets/game/lifelines/game_feature_button.dart` | 211 |
| `lib/widgets/game/lifelines/game_feature_button_bar.dart` | 44 |
| `lib/widgets/game/lifelines/game_audience_poll_row.dart` | 46 |
| `lib/widgets/game/answers/game_answer_option.dart` | 193 |
| `lib/widgets/game/answers/game_answer_option_colors.dart` | 45 |
| `lib/widgets/game/answers/game_answer_option_list.dart` | 95 |
| `lib/widgets/game/questions/game_question_panel.dart` | 151 |
| `lib/widgets/game/dialogs/game_dialog_shell.dart` | 221 |
| `lib/widgets/game/dialogs/game_result_dialogs.dart` | 156 |
| `lib/widgets/game/dialogs/game_help_dialogs.dart` | 223 |
| `lib/widgets/game/dialogs/game_confirm_dialogs.dart` | 134 |
| `lib/widgets/game/layout/game_screen_top_bar.dart` | 47 |
| `lib/widgets/game/layout/game_screen_body.dart` | 63 |

### Converge existing files

- `lib/widgets/game/dialogs/game_dialog_layer.dart` — learner 239 → senior
  191 lines (same ctor shape; `_dialogBody` switch targets the 4 new
  view families; learner `game_dialog_views.dart` (726 lines, monolith)
  is **retired** — replaced by senior's family-split files).
- `lib/screens/game_screen.dart` — learner 629 → senior 201 lines (thin
  shell; top bar/body move into `layout/` widgets).
- `lib/data/game/game_screen_data.dart` — `GameFeatureButtonData.icon`
  `IconData` → `iconAsset` `String` (FR-34); enum already identical.
- `lib/view_models/game/game_screen_presentation_mapper.dart` — emit
  `AppAssets` icon paths (`iconGameFiftyFifty`, `iconGameAudience`,
  `iconGameSparkle`, `iconGameTrophy`).

### Dependency + asset changes

- `pubspec.yaml`: add `flutter_svg` (senior `^2.3.0`), `google_fonts`
  (senior `^8.1.0`); add `assets:` section with `assets/images/` and
  `assets/images/icons/` + `assets/images/backgrounds/`.
- Asset subset (only what ported widgets/mapper reference):
  - `assets/images/icons/game-audience.svg`
  - `assets/images/icons/game-back.svg`
  - `assets/images/icons/game-fifty-fifty.svg`
  - `assets/images/icons/game-lightning.svg`
  - `assets/images/icons/game-money.svg`
  - `assets/images/icons/game-sparkle.svg`
  - `assets/images/icons/game-trophy.svg`
  - `assets/images/backgrounds/menu-background.png`
- `lib/l10n/app_en.arb` / `app_vi.arb`: add 6 missing keys verbatim from
  senior — `optionSemanticLabel`, `selectedStateLabel`,
  `correctStateLabel`, `incorrectStateLabel`, `prizeAmountSemanticLabel`,
  `timeRemainingSemanticLabel`.

### Tests to port (package rename)

Senior files: `game_countdown_timer_test`, `game_feature_button_test`,
`game_money_amount_test`, `game_answer_option_test`,
`game_answer_option_reveal_blink_test`, `game_question_panel_test`,
`dialog_shell_header_test`, `qzds_game_button_test`,
`pill_button_glow_test`, `game_screen_test_helpers.dart` (if absent in
learner). Existing learner tests (`game_screen_test`,
`game_dialog_layer_test`, `game_screen_flow_test`, `widget_test`) must be
updated for the new widget tree.

### Scaffold retirements this milestone owns

- `_DialogShareButton` → `GameDialogButton` (shareColor) — inside
  `game_result_dialogs.dart`.
- Flat `_GameTopBar` timer/money rendering → `GameCountdownTimer` +
  `GameMoneyAmount`.
- Flat `IconData` lifeline buttons → `GameFeatureButton` + `iconAsset`
  (FR-34 → `CONVERGED`).

## Explicit exclusions (roadmap + Atlas scope bound)

Defer to **M29 final alignment sweep** (register retarget; documented
`ACTIVE_TEMPORARY` until then):

- **FR-32** onboarding visuals (`OnboardingTokens`, `BackdropFilter`
  scrim, `AnimatedSwitcher`, animated-width indicator,
  `OnboardingGameButton`, header config, nested `StreamBuilder` gate) —
  ~500-line own surface; out of M28's game-surface scope.
- **FR-30** `SettingItemData.iconAsset` + `_SettingIconBadge` + settings
  icon SVGs — menu/settings surface, not game surface.
- **FR-28 residual** `_SettingsAccountRow` → `SettingsAccountRow` chrome —
  same reason.
- `MenuTokens` → `AppTokens` migration for existing menu widgets — M29
  file/folder-convention pass.
- Full senior asset parity (avatars, leaderboard medals, decorations,
  settings/menu icons beyond the game subset) — roadmap: "subset
  acceptable".
- `menu_gradient_cta_button`, `language_chip_row`, settings wheel
  widgets — menu/settings surface.
- `flutter_launcher_icons` config — out of scope.
- FR-31 l10n key superset expansion — M29/audit.
- Animated-list choreography; deep performance profiling (roadmap
  verbatim exclusions).

## Fidelity rows this milestone touches

- **FR-34** `GameFeatureButtonData.iconAsset` + `GameFeatureButton` painter/sheen/SVG → `CONVERGED`.
- **FR-33 (dialog chrome)** game dialog visual parity (shell, blur scrim,
  gradient buttons, `GameDialogMoneyRow`) → `CONVERGED` for game dialogs;
  menu dialog transport stays M29 (separate row).
- **FR-04** residual visual clauses (timer painter, money motion,
  gradients, SVG icons) → `CONVERGED` for game surface.
- New/updated rows as Argus QA finds.

## Implementation rules (binding)

1. **Verbatim ports** — senior file content is copied 1:1, changing only
   `package:` import names to `ai_millionaire_course`. Learner-authored
   VI doc comments may be added above ported members where the teaching
   standard requires, without altering behavior.
2. **No behavior invention** — if senior has no `disableAnimations`
   honoring on a widget (timer pulse, feature-button sheen), do NOT add
   it. Deliberate divergences get an FR row + implementation note.
3. **Reduced-motion honesty** — `MediaQuery.disableAnimations` exactly
   where senior has it (money motion duration→zero, answer blink
   suppression, dialog transitions).
4. **Asset subset is final for M28** — `AppAssets` declares only shipped
   paths; unshipped constants are added by later milestones when their
   widgets port. No dangling asset references.
5. **GoogleFonts** — port verbatim (`GoogleFonts.beVietnamPro` in token
   file). Runtime-fetch behavior is senior-identical; note in evidence.
6. **No golden tests** — focused widget assertions: painter path/
   progress, controller lifecycle, reduced-motion, button press-scale,
   dialog shell chrome, money animation trigger.

## Success criteria

- `flutter analyze` clean.
- `flutter test` all passing (expected: 259 + ported widget tests +
  updated existing).
- `flutter build web` passes.
- Game screen renders: painted countdown pill + pulse, animated money
  amount, SVG lifeline buttons with sheen, shell-wrapped dialogs.
- `replay tree == production tree` after sequential replay.
- Senior repo clean at `c8eb860`.
- `SENIOR_FIDELITY_REGISTER` rows FR-34/game-side FR-33/FR-04-visual →
  `CONVERGED`; FR-30/FR-32/FR-28-residual retarget → M29.

## Lesson plan sketch (Lumen stage)

~6 lessons, Template V2, ≤3 CORE concepts each:
- L01: `AppTokens`/`AppAssets`/`SurfaceGlow` + `DesignFrame` + pubspec
  deps/assets (concepts: design tokens, asset constants).
- L02: `QzdsGameButton` + `GlassIconButton` + `GameScreenBackground`
  (concepts: `AnimationController`, `vsync`, `CurvedAnimation` sheen,
  press-scale).
- L03: `GameCountdownTimer` + `_PillProgressPainter` (concepts:
  `CustomPainter`, `Canvas`/`Paint`/`Path`, `shouldRepaint`, two
  controllers: progress tween + critical pulse).
- L04: `GameMoneyAmount` + `GameMoneyAmountMotion` (concepts:
  `AnimatedBuilder`, trigger-based animation, `MediaQuery.
  disableAnimations`, amount parsing).
- L05: `GameFeatureButton` + bar + `iconAsset` data/mapper change +
  answer/question/dialog surfaces + `game_screen.dart` converge
  (concepts: `SvgPicture.asset`, reduced-motion blink suppression,
  shell pattern).
- L06: ARB keys + test ports + full regression (concepts: widget-test
  pump/pumpAndSettle with controllers, painter finding).

Exact split is Lumen's; checkpoint boundaries must be testable.

## Stage order

Flux → Argus impl QA → Atlas approve → Lumen → Argus content QA →
Atlas approve → Forge → Argus site QA → Atlas approve → replay →
final regression + integrity → canonical sync → verdict. Hard stop.
