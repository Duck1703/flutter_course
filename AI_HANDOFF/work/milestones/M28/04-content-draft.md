# M28 — CONTENT DRAFT MANIFEST (Lumen)

## Intake gate

`IMPLEMENTATION_APPROVED` confirmed — `01-brief.md` +
`02-implementation-evidence.md` + `03-implementation-qa.md` on
disk. Learner app verified on disk (final authoritative state):
`flutter analyze` clean, `flutter test` **309/309**,
`flutter build web` PASS, senior unchanged (`main@c8eb860`,
read-only). Implementation history noted honestly: initial
M28 evidence recorded `297/297`; Argus remediation ported
`game_dialog_money_row_test` + `game_screen_result_flow_test`
+ full `game_dialog_layer_test` → final `309/309`. Lessons use
**309** (not the stale 297) throughout.

**`REAL_DEVICE_VISUAL_CHECK: NOT_PERFORMED`** and
**`REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED`** (inherited from
M27 convention) — all visual verification carried by widget
tests + `build web`; stated verbatim in index + L06 + below.
Never claimed performed.

**Brief-vs-disk discrepancy resolved:** brief lesson-plan text
mentions a "390pt design-width scaling convention"; on-disk
`AppTokens.screenDesignWidth` = **375** (`app_design_tokens.
dart:55`) and `DesignFrame` uses it verbatim. Disk wins — all
lessons teach 375; the 390 phrase is recorded here as a
brief-wording gap, not an implementation bug.

## Lessons authored (6 + index) — `AI_HANDOFF/work/milestones/M28/lessons/`

| File | Concepts (brief registry) | Exercise |
|---|---|---|
| `index.md` | milestone map + deferred table + synthesis 5-câu + FR-31/FR-32-phần-game/FR-34 closure | — |
| `01-nen-mong-tokens-assets.md` | **A-38** design tokens single-source (architecture, CORE) — `AppTokens` 318d verbatim + `AppAssets` subset-8 + `surfaceGlow`/`FillBoxGradientTransform`/`headerSheen` + `DesignFrame`(375) + pubspec 2dep/2asset-dir + 6 ARB key; LIGHT: `GoogleFonts` runtime-fetch, `withValues`, `Matrix4` cascade | Tự làm **PRODUCE** `MyAssets` subset-shape + `describeIcon`; Thử nghiệm PREDICT xoá asset-dir (suite xanh / runtime `Unable to load asset`) |
| `02-chrome-chung-pill-kinh-nen.md` | **F-42** `SvgPicture.asset` + `ColorFilter.mode(…, BlendMode.srcIn)` (NORMAL); **D-48** `if (x case final y?)` null-extract (NORMAL); A-38/F-28 reinforcement (tokens, `Semantics`/`ExcludeSemantics`, `HitTestBehavior.opaque`); `QzdsButtonScale` = size-preset **không phải** press-animation (brief-wording corrected) | Tự làm **PREDICT** bỏ `ExcludeSemantics` (test xanh nhưng semantics-tree nhiễu); Thử nghiệm PREDICT `srcIn`→`srcOver` |
| `03-custompainter-animationcontroller-dong-ho.md` | **F-38** `AnimationController`+`vsync`/`TickerProviderStateMixin`/bounds/`repeat(reverse)`/`dispose` (CORE); **F-39** `CustomPainter`+`Canvas`/`Paint`/`Path`/`computeMetrics`/`extractPath`/`shouldRepaint` (CORE); **F-40** `didUpdateWidget` sync prop→controller, animate-vs-snap (NORMAL); D-45 reuse (`part of`); `@visibleForTesting` (chưa có registry row); parity: pulse **không** honor `disableAnimations` | Tự làm **DEBUG** bỏ `..value=0` trước `forward()` → smooth-test đỏ tại 24.5/30 assert; Thử nghiệm PREDICT `repeat()`-không-reverse → pulse "giật" (test xanh — visual-only) |
| `04-trigger-motion-so-tien-nhay.md` | **A-39** trigger-based animation `animationTrigger >` int-gate (architecture, NORMAL); F-40/F-38 reinforcement (SingleTicker + didUpdateWidget gate); F-30 reuse (`MediaQuery.disableAnimations → Duration.zero` — **honored** ở đây); F-29/F-42 reuse (`AnimatedBuilder`, `ShaderMask`+`srcIn`); LIGHT: `forward(from:)`, `Curve.transform`, `TextButton.styleFrom`+`shrinkWrap`+`WidgetStatePropertyAll`, `LayoutBuilder`/`FittedBox`, `_AmountTemplate`/`_intAmount`/`_formatGrouped` | Tự làm **DEBUG** bỏ `duration > Duration.zero` khỏi gate (test xanh nhưng contract lệch — "xanh ≠ đúng hợp đồng"); Thử nghiệm PREDICT `>`→`!=` → `'…trigger resets'` đỏ |
| `05-be-mat-game-va-lop-dialog.md` | **F-41** implicit-animation family (`AnimatedOpacity`/`Scale`/`Container`/`DefaultTextStyle`/`TweenAnimationBuilder`) + `CurvedAnimation`/`Interval` stagger (NORMAL); **F-43** semantics-nâng `liveRegion`/`value`/`onTap` + `getSemantics`/`matchesSemantics` test-API (LIGHT); D-48 reuse (dual if-case `iconAsset`/`icon`); F-38/A-39 reuse (`questionIndex` làm trigger); D-37/F-29/F-30 reuse (runtimeType keys, `AnimatedSwitcher`, `BackdropFilter`, `IgnorePointer`, reduce-motion-zero); `.toUpperCase()` parity | Tự làm **PREDICT** bỏ `min(…,0.4)` cap → `Interval` vượt 1.0 cho ô-thứ-5+ (opacity-0-vĩnh-viễn); Thử nghiệm PREDICT bỏ `state` khỏi `ValueKey` → blink không re-arm |
| `06-hoi-tu-iconasset-atomic-swap.md` | **0 new concepts** — atomic DTO migration là A-38/F-42 áp-dụng; `Listenable.merge` + `ui.Gradient.linear` + `AnnotatedRegion<SystemUiOverlayStyle>` (LIGHT); scaffold-retirement (`_DialogShareButton`/`_GameTopBar`/`_GameFeatureButton`/layer+views cũ); `_afterExit` `dialogMotionLong`-wait + `_terminalActionPending`; `GameScreen(viewModel:)` ctor bỏ → `MultiProvider`-inject | Tự làm **PRODUCE** scratch-test `walkAway`→red-gradient (assert qua public contract — constants, không mở private); Thử nghiệm PREDICT giữ-hai-field song song (analyze xanh nhưng hai-nguồn-sự-thật) |

## Per-lesson files touched (create / update / delete — exact paths)

### L01 — nền móng (+0 → 259)

**Update:**
- `pubspec.yaml` — add `flutter_svg: ^2.3.0` + `google_fonts: ^8.1.0`
  (deps block) + `assets: [assets/images/icons/,
  assets/images/backgrounds/]` (flutter block).
- `lib/l10n/app_en.arb` — +6 keys `optionSemanticLabel`,
  `selectedStateLabel`, `correctStateLabel`,
  `incorrectStateLabel`, `prizeAmountSemanticLabel`,
  `timeRemainingSemanticLabel` (+ 3 `@` placeholder blocks).
- `lib/l10n/app_vi.arb` — +6 keys (no `@` blocks).
- `lib/l10n/app_localizations.dart` + `app_localizations_en.dart`
  + `app_localizations_vi.dart` — regenerate via `flutter gen-l10n`.

**Create:**
- `assets/images/icons/game-audience.svg`, `game-back.svg`,
  `game-fifty-fifty.svg`, `game-lightning.svg`, `game-money.svg`,
  `game-sparkle.svg`, `game-trophy.svg` (copy verbatim senior).
- `assets/images/backgrounds/menu-background.png` (copy).
- `lib/core/app_assets.dart` (subset 8 const).
- `lib/core/surface_glow_gradient.dart` (verbatim 72d).
- `lib/core/app_design_tokens.dart` (verbatim 318d).
- `lib/widgets/common/design_frame.dart` (verbatim 20d).

**Delete:** none. **Tests:** none → 259.

### L02 — chrome chung (+4 → 263)

**Create:**
- `lib/widgets/common/qzds_game_button.dart` (verbatim 145d).
- `lib/widgets/common/glass_icon_button.dart` (verbatim 53d).
- `lib/widgets/common/game_screen_background.dart` (verbatim 28d).
- `test/widgets/qzds_game_button_test.dart` (verbatim, 4 case).

**Update/Delete:** none.

### L03 — CustomPainter + controller (+7 → 270)

**Create:**
- `lib/widgets/game/timer/game_countdown_timer.dart` (verbatim
  185d, `part` host).
- `lib/widgets/game/timer/game_countdown_timer_progress_painter.dart`
  (verbatim 73d, `part of`).
- `lib/widgets/game/layout/game_screen_top_bar.dart` (verbatim 47d).
- `test/widgets/game_countdown_timer_test.dart` (verbatim, 7 case:
  6 `testWidgets` + 1 `test`).

### L04 — trigger motion (+6 → 276)

**Create:**
- `lib/widgets/game/money/game_money_amount_motion.dart`
  (verbatim 196d).
- `lib/widgets/game/money/game_money_amount.dart` (verbatim 98d).
- `lib/widgets/game/money/game_money_ladder_cta_button.dart`
  (verbatim 109d).
- `lib/widgets/game/money/game_money_ladder_dialog.dart`
  (verbatim 209d).
- `test/widgets/game_money_amount_test.dart` (verbatim, 6 case).

### L05 — bề mặt + lớp dialog (+13 → 289)

**Create:**
- `lib/widgets/game/answers/game_answer_option_colors.dart` (45d).
- `lib/widgets/game/answers/game_answer_option.dart` (193d).
- `lib/widgets/game/answers/game_answer_option_list.dart` (95d).
- `lib/widgets/game/questions/game_question_panel.dart` (151d).
- `lib/widgets/game/lifelines/game_audience_poll_row.dart` (46d).
- `lib/widgets/game/dialogs/game_dialog_shell.dart` (221d).
- `lib/widgets/game/dialogs/game_result_dialogs.dart` (156d).
- `lib/widgets/game/dialogs/game_help_dialogs.dart` (223d).
- `lib/widgets/game/dialogs/game_confirm_dialogs.dart` (134d).
- `lib/widgets/game/dialogs/game_dialog_layer.dart` (191d —
  **new path** `dialogs/`; old `widgets/game/game_dialog_layer.
  dart` untouched until L06).
- `test/widgets/game_answer_option_test.dart` (4).
- `test/widgets/game_answer_option_reveal_blink_test.dart` (3).
- `test/widgets/game_question_panel_test.dart` (1).
- `test/widgets/game_dialog_money_row_test.dart` (4).

**Update (rewrite-in-place):**
- `test/widgets/game_dialog_layer_test.dart` — replace M27
  VI-variant (10 case, simplified visual asserts) with senior
  11-case version targeting the new `dialogs/` path. Net +1.

### L06 — hội tụ atomic (+20 → 309)

**Create:**
- `lib/widgets/game/lifelines/game_feature_button.dart` (211d).
- `lib/widgets/game/lifelines/game_feature_button_bar.dart` (44d).
- `lib/widgets/game/layout/game_screen_body.dart` (63d).
- `test/widgets/game_feature_button_test.dart` (5).
- `test/widgets/game_screen_flow_test.dart` (7).
- `test/widgets/game_screen_result_flow_test.dart` (8).
- `test/widgets/game_screen_test_helpers.dart` (non-test
  helpers: `pumpGame`/`dismissMoneyLadder`/`answerState`/
  `answerOption` + fakes wiring).

**Update:**
- `lib/data/game/game_screen_data.dart` — `GameFeatureButtonData.
  icon: IconData` → `iconAsset: String`; file loses its only
  `import 'package:flutter/material.dart'` (no imports at all).
- `lib/view_models/game/game_screen_presentation_mapper.dart` —
  drop `import material`, add `import '../../core/app_assets.
  dart'`; `_feature` emits `AppAssets.iconGame*` and sets
  `iconAsset:`.
- `lib/screens/game_screen.dart` — rewrite 629d scaffold →
  201d senior verbatim.
- `test/game_screen_view_model_test.dart` — 2 sites
  `icon: IconData(0)` → `iconAsset: 'test/icon.svg'` (lines
  ~607, ~783); drop `import material` (net 0 tests, 36→36).
- `test/menu_screen_ui_events_test.dart` — `'Thang tiền
  thưởng'` → `'THANG TIỀN THƯỞNG'` (uppercase title; net 0, 7→7).
- `test/widgets/game_screen_test.dart` — rewrite to
  `pumpGame`-shape (net 0, 14→14).

**Delete:**
- `lib/widgets/game/game_dialog_layer.dart` (old, 239d).
- `lib/widgets/game/game_dialog_views.dart` (old, 726d —
  includes `_DialogShareButton` M27 scaffold).

**Atomic boundary:** DTO + mapper + screen + vm-test +
screen-test + deletes all land in L06; `analyze` is red
*between* step-1 and step-4 by design (compile-forced
migration map) and green at lesson end. Declared in lesson.

## Concept → brief registry entry mapping

| Brief entry / first-appearance | Lesson | Registry row used |
|---|---|---|
| design tokens single-source (`AppTokens`/`AppAssets`/`surfaceGlow`/`DesignFrame`) | L01 (+reinforced L02–L06) | **A-38** (new, CORE) |
| `SvgPicture.asset` + `ColorFilter.mode(BlendMode.srcIn)` | L02 (+reinforced L05 question-panel/shell/poll, L06 lifeline) | **F-42** (new, NORMAL) |
| `if (expr case final x?)` null-extract | L02 (+reinforced L05 shell dual-case) | **D-48** (new, NORMAL) |
| `AnimationController` + `vsync`/`TickerProvider(Single)`/bounds/`repeat(reverse)`/`forward(from)`/`stop/reset`/`dispose` | L03 (+reinforced L04 SingleTicker, L05 answer-list, L06 feature×2) | **F-38** (new, CORE) |
| `CustomPainter` + `Canvas`/`Paint`/`Path`/`computeMetrics`/`extractPath`/`shouldRepaint` | L03 (+reinforced L06 feature painter) | **F-39** (new, CORE) |
| `didUpdateWidget` prop→controller sync / animate-vs-snap | L03 (+reinforced L04 gate, L05 questionIndex, L06 gradient sync) | **F-40** (new, NORMAL) |
| trigger-based animation (`animationTrigger >`) | L04 (+reinforced L05 `questionIndex`) | **A-39** (new, NORMAL) |
| implicit-animation family + `Interval`/`CurvedAnimation` stagger | L05 (first formal treatment; `AnimatedDefaultTextStyle` previewed L03) | **F-41** (new, NORMAL) |
| semantics nâng (`liveRegion`/`value`/`onTap`) + `getSemantics`/`matchesSemantics` | L05 | **F-43** (new, LIGHT) |
| `IconData` → `String iconAsset` DTO migration (atomic) | L06 | no new row — application of A-38 + F-42 |
| `MediaQuery.disableAnimations` | L04/L05/L06 (reuse; honored at money/reveal-blink/layer/afterExit — **not** at pulse/feature-sheen by parity) | F-30 reuse (M21-owned) |
| `BackdropFilter`/`ImageFiltered` blur, `IgnorePointer`, `AnimatedSwitcher` keyed `runtimeType` | L05 | F-29/F-30 + D-37 reuse (M21-owned) |
| `part`/`part of`, `@visibleForTesting` seam | L03 | D-45 reuse (M24-owned); `@visibleForTesting` chưa có registry row |
| `Curves.*`/`switchInCurve`/`AnimatedBuilder`/`FadeTransition`/`ScaleTransition` | L03–L06 | F-29 reuse (M21-owned) |

**Skipped F-IDs note:** F-36/F-37 were consumed by M27
(`flutter_local_notifications`/`package_info_plus`); F-38–F-43
are the M28 allocation. D-48 is the next free Dart row.
A-38/A-39 are the next free Architecture rows. No B-family
rows (backend-only) touched.

## Depth assignments

- CORE: **A-38** (L01), **F-38** (L03), **F-39** (L03).
- NORMAL: **D-48** (L02), **F-42** (L02), **F-40** (L03),
  **A-39** (L04), **F-41** (L05).
- LIGHT/awareness: **F-43** (L05), `Listenable.merge` (L06),
  `ui.Gradient.linear` (L06), `AnnotatedRegion` (L06),
  `Matrix4`/`withValues` (L01), `TextButton.styleFrom`+
  `shrinkWrap`+`WidgetStatePropertyAll` (L04), `LinearProgress
  Indicator.borderRadius` (L05), `FittedBox`/`LayoutBuilder`/
  `FractionallySizedBox`/`IntrinsicHeight` (L04/L05),
  `MaterialTapTargetSize.shrinkWrap` (L04),
  `excludeFromSemantics` on `SvgPicture` (L06).
- ≤3 new concepts per lesson (excluding LIGHT/reinforcement):
  L01=1 (A-38), L02=2 (F-42+D-48), L03=3 (F-38+F-39+F-40),
  L04=1 (A-39), L05=2 (F-41+F-43), L06=0.

## Registry / graph notes (for post-authoring step)

- `LEARNER_CONCEPT_REGISTRY.md` (not authored here): rows
  needed → **A-38, A-39** (Architecture), **D-48** (Dart),
  **F-38, F-39, F-40, F-41, F-42, F-43** (Flutter/Framework).
  Reinforcement touches: A-11, A-13, A-20, A-21, A-24(contrast),
  A-31/A-33, D-26/D-27, D-30, D-31, D-33, D-36, D-37,
  D-45, F-04/F-05, F-12, F-14, F-21, F-22, F-23, F-25, F-26,
  F-27, F-28, F-29, F-30, F-35.
- `PREREQUISITE_GRAPH.md`: M28 section to append (A-38 →
  L01→L02–L06; F-42+D-48 → L02→L05/L06; F-38+F-39+F-40 →
  L03→L04/L05/L06; A-39 → L04→L05; F-41+F-43 → L05; atomic
  synthesis → L06; feeds M29 dialog transport + settings/
  leaderboard visual).
- `SENIOR_FIDELITY_REGISTER.md`: **FR-31 → CONVERGED**
  (AppTokens + countdown), **FR-32 (phần game) → CONVERGED**
  (game surfaces + dialog subsystem — menu/settings/onboarding
  visuals remain M29), **FR-34 → CONVERGED** (lifeline SVG +
  painter + iconAsset pipeline). FR-28-visual/FR-29/FR-30
  remain deferred to M29.
- Registry/graph edits are outside this handoff's write scope —
  listed for the update step (same convention as M27).

## Incremental implementation (step sizes)

| Lesson | Steps | Justification |
|---|---|---|
| L01 | 8 (pubspec, assets copy, app_assets, surface_glow, tokens, design_frame, ARB ×2 + regen, verify) | nền-móng compile-độc-lập; assets/tokens land trước mọi consumer |
| L02 | 5 (3 lib + 1 test + verify) | 3 file common độc-lập; test verbatim 4-case |
| L03 | 5 (timer + painter-part + topbar + test + verify) | hai file `part`-liên-kết phải land cùng; top-bar là consumer đầu tiên (compile-forced nếu tách) |
| L04 | 6 (motion + amount + cta + ladder + test + verify) | 4 file money một cụm: cta/ladder chỉ đọc AppTokens + formatter đã-có; test gắn `GameMoneyAmount` |
| L05 | 5 cụm (answers 3 + question/poll 2 + shell/families/layer 5 + 5 test + verify) | layer mới switch trên views → views phải tồn tại cùng bài; file-count cao nhưng verbatim + concept-nhẹ |
| L06 | 7 (DTO+mapper, feature×2, body, screen rewrite, deletes + 2 test-updates, test rewrite+helpers+3 files, verify) | **atomic**: `iconAsset` phá old-screen/vm-test/mapper cùng lúc — không trạng-thái-nửa-chừng compile được; deletes sau rewrite |

Largest single paste: `game_money_amount_motion.dart` (196d) /
`game_dialog_shell.dart` (221d) / `game_feature_button.dart`
(211d) — verbatim senior, declared; broken into explained
regions in-lesson (not pasted wholesale; ≤~20-line excerpts
quoted).

## Code-explanation coverage

- Every new construct in every quoted block has an explanation
  line or a Dart/Flutter-table row: `vsync`/`TickerProvider`/
  `lowerBound/upperBound`/`repeat(reverse)`/`forward(from:)`/
  `addListener`; `Canvas.drawPath`/`Paint`/`Path.computeMetrics
  ().extractPath`/`createShader`; `if (x case final y?)`;
  `SvgPicture.asset`/`ColorFilter.mode`/`BlendMode.srcIn`;
  `Tween(begin,end).animate(controller)`; `CurvedAnimation`+
  `Interval`; `TweenAnimationBuilder` keyed-re-arm;
  `AnimatedBuilder`/`ScaleTransition`/`FadeTransition`/`Animated
  Opacity`/`AnimatedScale`/`AnimatedContainer`/`AnimatedDefault
  TextStyle`; `ShaderMask`; `Transform.translate`/`scale`;
  `BackdropFilter`/`ImageFilter.blur`; `IgnorePointer`;
  `MediaQuery.of(context).disableAnimations`/`MediaQueryData`;
  `Listenable.merge`; `ui.Gradient.linear`; `AnnotatedRegion`;
  `withValues(alpha:)`; `Matrix4.identity()` cascade;
  `Semantics(liveRegion/value/onTap)` + `ExcludeSemantics` +
  `excludeFromSemantics`; `TextButton.styleFrom`/`WidgetState
  PropertyAll`/`MaterialTapTargetSize.shrinkWrap`; `FittedBox(
  scaleDown)`/`LayoutBuilder`; `toUpperCase()`; `ValueKey(
  dialog.runtimeType)`/`ValueKey<Type>`; `LinearProgressIndicator.
  borderRadius`; `_AmountTemplate`/`_intAmount`/`_formatGrouped`;
  `SharePlus`/`Clipboard`/`RenderBox & size` (M27 reuse).
- ARB: 6 keys shown verbatim en+vi; `@` placeholder metadata
  shown on en, omitted on vi (template-locale inheritance).

## Android bridges

| Lesson | Bridge | False-equivalence check |
|---|---|---|
| L01 | `AppTokens` ≈ `dimens.xml`+`Color.kt` theme object; `assets:` ≈ `res/` | 3-line ✓ — token là *code* (static const, không qualifier); `GoogleFonts` runtime-fetch ≠ bundled `res/font`; `assets:` dir ≠ `R.` type-safe |
| L02 | `SvgPicture`+`colorFilter` ≈ `painterResource`+`ColorFilter.tint`; `ExcludeSemantics` ≈ `contentDescription` | 3-line ✓ — `srcIn` đè mọi pixel (file đã fill-trắng); `ExcludeSemantics` xoá subtree ≠ `clearAndSetSemantics` ghi-đè |
| L03 | `CustomPainter` ≈ Compose `Canvas`; `AnimationController` ≈ `Animatable`/`InfiniteTransition`; `PathMetric` ≈ `PathMeasure` | 3-line ✓ — Flutter controller *mình sở hữu* + `dispose` tay (không `remember`); `didUpdateWidget` không có tương đương Compose trực tiếp; `extractPath` theo độ-dài-cung |
| L04 | `animationTrigger` ≈ `LaunchedEffect(key)`/`animateIntAsState`; `disableAnimations` ≈ `animator_duration_scale` | 3-line ✓ — trigger là *data trong DTO* (unidirectional — reducer biết "vừa transition"), widget chỉ `>`-gate; `disableAnimations` là flag đọc-tay, không tự scale |
| L05 | `TweenAnimationBuilder`/`AnimatedContainer` ≈ `animate*AsState`/`updateTransition`; `Interval` ≈ keyframes-delay; `liveRegion` ≈ `accessibilityLiveRegion` | 3-line ✓ — re-arm bằng `ValueKey` chứa-state ≠ `LaunchedEffect(state)`; `liveRegion` chỉ fire khi semantics-node *đổi*; `AnimatedContainer` duration gate tay |
| L06 | `icon`→`iconAsset` ≈ `ImageVector`→`@DrawableRes`; `Listenable.merge` ≈ `derivedStateOf` hai nguồn | 3-line ✓ — `String` path không type-safe (không `R.`); `TickerProviderStateMixin`×2 + `dispose` tay ≠ `rememberCoroutineScope`; feature-button cố ý không đọc `disableAnimations` |

## Senior evidence references (lesson → actual file:line)

| Lesson | Learner-app citation | Evidence class |
|---|---|---|
| L01 | `pubspec.yaml` `flutter_svg`/`google_fonts` (deps block, ~62–63) + `assets:` 2-dir (~93–96) · `lib/core/app_design_tokens.dart` (`export` 4–5, `QzdsButtonScale` 13, `motionMedium` 52/`dialogMotionLong` 54/`screenDesignWidth` 55, `GoogleFonts.beVietnamPro` 95+) · `lib/core/app_assets.dart` (8 const, 1–19) · `lib/core/surface_glow_gradient.dart` (`FillBoxGradientTransform` 10–37, `surfaceGlow` 48–60, `headerSheen` 68–72) · `lib/widgets/common/design_frame.dart` (4–18) · `lib/l10n/app_en.arb` (94–108) + `app_vi.arb` (87–92) | DIRECT_EVIDENCE (verbatim-port; app_assets = declared subset) |
| L02 | `lib/widgets/common/qzds_game_button.dart` (`if (icon case …)` 39, `Semantics` 118–121, `surfaceGlow` 137, `ExcludeSemantics` 34) · `lib/widgets/common/glass_icon_button.dart` (`SvgPicture.asset`+`colorFilter srcIn` 38–46, `Semantics` 19–21) · `lib/widgets/common/game_screen_background.dart` (`ColoredBox`/`menuBackgroundGradient`/`Opacity(0.6)`/`Image.asset` 8–26) · `test/widgets/qzds_game_button_test.dart` (16/35/61/81) | DIRECT_EVIDENCE (verbatim) |
| L03 | `lib/widgets/game/timer/game_countdown_timer.dart` (`part` 8, two controllers 45–56, `_isCritical` 58, `didUpdateWidget` 68–71, `dispose` 75–78, `CustomPaint(foregroundPainter)` 85–90, `AnimatedDefaultTextStyle` 102, `ScaleTransition`+`_criticalPulseKey` 119–125, `_syncPulse` 129–139, `_syncProgress` 141–163, `_timerColor`/`_borderColors` 179–185) · `…_progress_painter.dart` (`paint` 8–30, `shouldRepaint` 31–34, `buildGameCountdownTimerProgressPath` 37–64, `debug…Progress` 66–73) · `lib/widgets/game/layout/game_screen_top_bar.dart` (`DesignFrame` 24, `GlassIconButton`+`iconGameBack` 33–38, timer center) · `test/widgets/game_countdown_timer_test.dart` (7 cases 11–130, `_paintProgress` 185–189) | DIRECT_EVIDENCE (verbatim) |
| L04 | `lib/widgets/game/money/game_money_amount.dart` (`disableAnimations→Duration.zero` 16–18, `Semantics(prizeAmountSemanticLabel)` 20–22, `_MoneyPill`+glow 42–77, `animationTrigger` 74) · `game_money_amount_motion.dart` (SingleTicker 21–36, gate `>`+`duration>zero` 39–55, `_motionDuration` 260ms 57–59, `AnimatedBuilder`+`easeOutCubic.transform` 67–83, `_glitchLayers` 89–104, `_displayAmount` 105–110, `_AmountTemplate`/`_intAmount`/`_formatGrouped` 120–152, `ShaderMask`/`Transform` 173–189, `dispose` 113) · `game_money_ladder_cta_button.dart` (`TextButton.styleFrom`+`shrinkWrap`+`WidgetStatePropertyAll` 40–52) · `game_money_ladder_dialog.dart` (`LayoutBuilder`/`FittedBox` 30–36, `moneyLadderTitle.toUpperCase()` 83, `_LadderItem` rows (private)) · `test/widgets/game_money_amount_test.dart` (6 cases; `MediaQueryData(disableAnimations:)` 143) | DIRECT_EVIDENCE (verbatim) |
| L05 | `answers/game_answer_option.dart` (`Semantics(liveRegion/value)` 29–36, `TweenAnimationBuilder` key 41–47, `_answerRevealBlinkDuration` 11, `_blinkOpacity` 131–139, `AnimatedContainer` gated 74–78, `_showsAudienceBadge` 126) · `game_answer_option_colors.dart` (`fromState`) · `game_answer_option_list.dart` (`SingleTicker` 26–32, `forward(from:0)` on `questionIndex` 43, `Interval(min(i*0.1,0.4),1)` 59–61, Opacity/translate/scale 70–86) · `questions/game_question_panel.dart` (`AnimatedSwitcher`+key 80–83, lightning `yellow600 srcIn` 144–148, badge `${display}/${total}`) · `lifelines/game_audience_poll_row.dart` (`LinearProgressIndicator`+`borderRadius`) · `dialogs/game_dialog_shell.dart` (`toUpperCase` 186, `headerSheen` 178, dual if-case 197–213, `GameDialogButton`→`QzdsGameButton` 90–98, `GameDialogMoneyRow._coinGutter` 112) · `dialogs/game_result_dialogs.dart` (`iconGameTrophy` 62, share `toUpperCase` 124) · `dialogs/game_help_dialogs.dart` (sparkle/audience icons, `AudiencePollRow`) · `dialogs/game_confirm_dialogs.dart` (`primary/secondary.toUpperCase()`) · `dialogs/game_dialog_layer.dart` (`motionDuration` 36–38, `IgnorePointer` 41–42, `ValueKey(runtimeType)` 93, `_buildTransition` ladder-slide 64–76, `switch` 9-nhánh 102–149, `_DialogBackdrop` blur+`DesignFrame` 162–188, `_canDismissFromBackdrop` 54–60) · tests: `game_answer_option_test` (4), `game_answer_option_reveal_blink_test` (3), `game_question_panel_test` (1), `game_dialog_money_row_test` (4), `game_dialog_layer_test` (11, new-path) | DIRECT_EVIDENCE (verbatim) |
| L06 | `lifelines/game_feature_button.dart` (2 controllers 29–41, `_syncGradientAnimation` 149–158, `Listenable.merge` 86–88, `SvgPicture.asset(iconAsset)` 103–108, `_semanticLabel` 123–131, `_gradientColors` 133–147, painter 162–211) · `lifelines/game_feature_button_bar.dart` (`DesignFrame`+Row 20–39) · `layout/game_screen_body.dart` (`LayoutBuilder`/`SingleChildScrollView`/`DesignFrame`/Column 25–58) · `lib/screens/game_screen.dart` (`ChangeNotifierProvider` 27–34, `AnnotatedRegion` 76, `Stack` 4-lớp 85–119, `_handleRouteBack` 125–139, `_afterExit` 148–169, `_handleUiEvent` share 171–194) · `lib/data/game/game_screen_data.dart` (`iconAsset` ~114–117, no imports) · `lib/view_models/game/game_screen_presentation_mapper.dart` (`import app_assets` 1, `AppAssets.iconGame*` 91–117, `_feature` 129–138) · deletes: `lib/widgets/game/game_dialog_layer.dart` (old), `game_dialog_views.dart` (old) · tests: `game_screen_test_helpers.dart` (`pumpGame`/`MultiProvider`/`MediaQuery` 21–60, `dismissMoneyLadder` 62–66, `answerState` 68–80), `game_screen_test` (14), `game_screen_flow_test` (7), `game_screen_result_flow_test` (8), `game_feature_button_test` (5), `game_screen_view_model_test` (iconAsset ~606/~782, drop material ~13), `menu_screen_ui_events_test` (line ~84 HOA) | DIRECT_EVIDENCE (verbatim ports + converged files; deletes verified) |

## Exercises & checks

| Lesson | Type | Task | Verifiability |
|---|---|---|---|
| L01 | **PRODUCE** + PREDICT | `MyAssets` subset-shape + `describeIcon`; xoá asset-dir → suite xanh/runtime-đỏ | DartPad-runnable (solution `<details>`); asset outcome reasoned (no suite coverage yet — declared) |
| L02 | PREDICT ×2 | bỏ `ExcludeSemantics` (test xanh, semantics nhiễu); `srcIn`→`srcOver` | vs shipped test + semantics-tree reasoning |
| L03 | **DEBUG** + PREDICT | bỏ `..value=0` trước `forward()` → smooth-test đỏ tại `closeTo(24.5/30)`; `repeat()`-không-reverse → pulse giật | **verified against shipped test semantics** (`_paintProgress` reads `_animatedProgress` — stuck at `end` without re-arm); visual-only second part declared |
| L04 | **DEBUG** + PREDICT | bỏ `duration > zero` khỏi gate → test vẫn xanh nhưng contract lệch (xanh≠đúng); `>`→`!=` → `'…trigger resets'` đỏ (glitch-layer found) | verified against shipped suite semantics |
| L05 | PREDICT ×2 | bỏ `min(…,0.4)` → `Interval(≥1)` opacity-0-vĩnh-viễn; bỏ `state` khỏi `ValueKey` → blink không re-arm | vs shipped code; second is reasoned (senior key contract) |
| L06 | **PRODUCE** + PREDICT | scratch-test `walkAway`→red-gradient qua public contract (constants, không mở private); giữ-hai-field song song (analyze xanh nhưng hai-nguồn-sự-thật) | runnable vs shipped `AppTokens`/`_gradientColors`; second is reasoning |

Spread: PRODUCE ×2 (L01, L06), DEBUG ×2 (L03, L04 — verified
against shipped suite), PREDICT/trace ×6. Requirement ≥1
PRODUCE-or-DEBUG satisfied.

## Common mistakes covered

- L01: assets-indent/scope; port-hết-`AppAssets`-sớm (dangling);
  quên `gen-l10n`; bundle-font "cho chắc"; tưởng `390`=375.
- L02: bỏ `colorFilter` vì "icon đã trắng" (mất chỗ tint);
  `ExcludeSemantics` sai chỗ; `deferToChild` thay `opaque`;
  nhầm `QzdsButtonScale` với animation (nó là size-preset);
  `Image.asset` trước `assets:` dir.
- L03: quên `dispose()` (ticker-leak); `SingleTicker` cho hai
  controller (assert); `shouldRepaint` true-mặc-định; `Tween`
  begin-từ-target thay `_animatedProgress`; snap-khi-nên-tween.
- L04: animate theo `amount`-đổi; `!=`/`>=` thay `>` (reset
  animate nhầm); assert midpoint chính-xác (brittle); quên
  `_controller.value = 1` nhánh-else; gate `initState`-only.
- L05: xoá file-cũ sớm (screen-cũ còn import); đảo `icon`/
  `iconAsset` if-case; quên `transformHitTests: false`;
  `liveRegion` không gate idle; assert tiêu-đề-VI-thường.
- L06: giữ-hai-field song song (hai-nguồn-sự-thật); quên bỏ
  `import material`; giữ views-cũ "phòng-khi"; `const GameScreen`
  với fake-VM-cũ (ctor mất); assert case-sai; nghĩ
  `Listenable.merge` dispose giùm.

## Deliberate parity facts (explicitly taught — NOT bugs)

1. **Pulse timer + feature-button sheen/ripple/gradient do
   *not* honor `MediaQuery.disableAnimations`** — senior code
   bỏ qua flag ở hai chỗ này; port verbatim giữ nguyên. L03
   (Hiểu-code #1) + L06 (Hiểu-code/bridge) + index deferred
   table all state this verbatim.
2. **Reduce-motion honored exactly where senior does** — ba
   (bốn) chỗ: money-motion `duration → Duration.zero` (L04);
   answer reveal-blink suppressed + `AnimatedContainer`/layer
   `Duration.zero` (L05); `_afterExit` terminal-wait → zero
   (L06). Nothing else gates.
3. **`AppAssets` is intentionally only the 8 shipped paths**
   (L01) — ~58 remaining senior constants land M29 *with* their
   widgets to avoid dangling asset refs.
4. **`GoogleFonts` runtime-fetch is senior-identical** — fonts
   not bundled; first-offline-render falls back to system font
   (parity, not a gap to fix).
5. **Money motion renders interpolated digits mid-flight** —
   tests assert *settled* (`pumpAndSettle`) or *not-endpoints*
   at midpoint, never exact mid-values (L04 Hiểu-code #2).
6. **Dialog titles/buttons uppercased by the views** —
   `.toUpperCase()` in shell/result/confirm views; VI tests
   must assert HOA (`THANG TIỀN THƯỞNG`, `XÁC NHẬN DỪNG`,
   `MENU`, `GAME OVER`, `MONEY LADDER`, `UNDERSTAND`) — L05
   Lỗi-#5 + L06 vm/ui-test diffs.
7. **`GameFeatureButtonData.semanticLabel` exists but widget
   renders localized labels** — mapper emits the field; widget
   `_semanticLabel(l10n)` switches on `type` (L06 Hiểu-code #3).
8. **`widget.duration` on `GameMoneyAmountMotion` is a
   zero/non-zero gate** — actual duration normalizes to 260ms
   (L04 Hiểu-code #1).

## Scaffold register

| Scaffold | Introduced | Retired/Converged | Status |
|---|---|---|---|
| `_DialogShareButton` (M27 — `ElevatedButton` phẳng trong `game_dialog_views.dart`) | M27 L05 | **L06** — replaced by real `GameDialogButton` (wraps `QzdsGameButton` + `shareColor`); old file deleted | retired at M28 |
| `_GameTopBar`/`_GameFeatureButton`/`_GameAnswerButton` (M20 inline screen scaffolds — `Icon(data.icon)`, `AnimatedOpacity`, container-trơn) | M20 | **L06** — replaced by `GameScreenTopBar`/`GameFeatureButton`/`GameAnswerOption` verbatim | retired at M28 |
| old `game_dialog_layer.dart` + `game_dialog_views.dart` monolith | M20/M21 | **L06** — replaced by `dialogs/` subsystem (layer + shell + 3 families) | deleted at M28 |
| `MenuTokens` (M14 self-made token set) | M14 | **M29** — still live for menu/settings/onboarding until `AppTokens` migration there | still active |
| `SettingItemData.icon: IconData` | M16 | **M29** (FR-30) — `SvgPicture` pipeline sẵn | still active |

No *new* teaching scaffolds introduced in M28 — every widget
is verbatim senior; the only scaffolding activity is
*retirement* of prior ones (declared in L05 "Ta cố ý chưa
thêm" + L06 "Hiểu code #5").

## Known-gap register

| Gap | Where declared | Disposition |
|---|---|---|
| `REAL_DEVICE_VISUAL_CHECK: NOT_PERFORMED` | index deferred-table + L06 Chạy-và-quan-sát + this register | recorded; verification weight carried by widget tests + `build web` |
| `REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` (M27-inherited) | index + L06 + this register | recorded (share-sheet/notification not exercised on device in this pipeline) |
| brief "390pt" vs disk `screenDesignWidth = 375` | index + L01 Hiểu-code #3 + Intake gate above | disk authoritative; brief wording noted |
| `game_dialog_shell_header_test.dart` + `game_pill_button_glow_test.dart` (senior has, learner doesn't port) | index deferred-table + L05 "Ta cố ý chưa thêm" | declared — header/glow behavior covered indirectly via `game_dialog_layer_test` + `game_screen_test` |
| `GoogleFonts` offline-first-render falls back to system font | L01 (Lỗi #5, deferred table) | parity senior — không bundle font |
| Pulse/feature-sheen không honor `disableAnimations` | L03/L06 + index + parity-facts #1 | deliberate parity — verbatim senior |
| `GameFeatureButtonData.semanticLabel` field unused-by-widget | L06 Hiểu-code #3 | parity senior — field is data, widget self-derives label |
| `game_screen_test` rewrite loses 0 net tests (14→14) but changes shape | L06 + checkpoint arithmetic | declared — VI-case names → EN senior names; coverage equal-or-better via flow/result_flow companions |
| `game_dialog_layer_test` replaced VI-10 with senior-11 | L05 + checkpoint arithmetic | declared — 3 senior visual cases now covered that M27 deferred |

## Intentionally delayed concepts

| Deferred | Owner |
|---|---|
| `MenuTokens`→`AppTokens` migration (menu/onboarding/settings/leaderboard) | **M29** (FR-32 phần còn lại) |
| `AppAssets` ~58 remaining constants + asset files | **M29** (subset policy — land with widgets) |
| `SettingItemData.icon`→`iconAsset` | **M29** (FR-30) |
| `SettingsDialogShell`/`OnboardingGameButton`/`MenuDialogBackdrop`/`LevelProgressCard`/account-row auth visual | **M29** (FR-28-visual/FR-30/FR-32) |
| `MenuDialogLayer` + `MenuDialogSettings/Auth/SignOut` transport | **M29** (FR-29) |
| `game_dialog_shell_header_test`/`game_pill_button_glow_test` | — declared gap (covered indirectly) |
| Bundled font assets | — parity senior (runtime fetch) |
| `disableAnimations` on pulse/feature-sheen | — deliberate parity (not a deferral) |
| Responsive beyond fixed 375 frame / multi-size layouts | — senior doesn't; single design-width is the design decision |
| `ImageFiltered` (vs `BackdropFilter`) | — senior uses `BackdropFilter` on the layer; `ImageFiltered` noted as sibling API, not shipped |

## Completion criteria

Per-lesson binary checkpoints (each file's `Checkpoint hoàn
thành`):

- L01: 2 pins + 2 asset-dir + 8 files (7 SVG + 1 PNG) + 4 lib
  files + 6 ARB keys + regen; analyze clean; **259/259** (+0).
- L02: 3 common widgets verbatim + qzds test 4-case; analyze
  clean; **263/263** (+4).
- L03: timer + painter-part + top-bar verbatim; 2 controllers
  disposed; stadium-path; test 7-case; **270/270** (+7).
- L04: 4 money files verbatim; `>`-gate + `Duration.zero`;
  260ms-normalize; test 6-case; **276/276** (+6).
- L05: 10 lib + 5 test (4+3+1+4+11) verbatim; layer mới ở
  `dialogs/` path (old file untouched); **289/289** (+13).
- L06: `iconAsset` DTO + mapper `AppAssets`; lifeline×2 + body
  + screen-201d verbatim; 2 old files deleted; 5 test-files
  +2 test-updates; analyze clean; **309/309** (+20); `build
  web` PASS.

Milestone-level: analyze clean; **309/309** (259+0+4+7+6+13+20);
`flutter build web` PASS; FR-31/FR-32-game/FR-34 CONVERGED;
both `NOT_PERFORMED` honesty lines stated verbatim.

## Checkpoint arithmetic (honest, from M27 final 259)

| Lesson end | Count | Delta | Test files touched |
|---|---|---|---|
| L01 | **259** | +0 | none (deps/assets/tokens/ARB only — no consumer) |
| L02 | **263** | +4 | `test/widgets/qzds_game_button_test.dart` (new, 4) |
| L03 | **270** | +7 | `test/widgets/game_countdown_timer_test.dart` (new, 7) |
| L04 | **276** | +6 | `test/widgets/game_money_amount_test.dart` (new, 6) |
| L05 | **289** | +13 | new: `game_answer_option_test` (4), `game_answer_option_reveal_blink_test` (3), `game_question_panel_test` (1), `game_dialog_money_row_test` (4); replace: `game_dialog_layer_test` 10→11 (+1) |
| L06 | **309** | +20 | new: `game_feature_button_test` (5), `game_screen_flow_test` (7), `game_screen_result_flow_test` (8); rewrite: `game_screen_test` 14→14 (+0), `game_screen_test_helpers` (+0 non-test); update: `game_screen_view_model_test` 36→36 (+0 iconAsset), `menu_screen_ui_events_test` 7→7 (+0 HOA) |

Cross-checked vs disk counts (`grep -c 'testWidgets(|test('`):
old suite files all still present; new files +49 + layer +1 =
+50 → 259+50 = **309** ✓ matches `02-implementation-evidence.md`
(final) + `03-implementation-qa.md` PASS. The `297` figure in
initial evidence is pre-Argus; lessons/manifest use 309.

## Per-lesson checkpoint commands (all credential-free)

- L01: `flutter pub get`, `flutter gen-l10n` (or `pub get` —
  `generate: true`), `flutter analyze`, `flutter test` (259)
- L02: `flutter analyze`, `flutter test
  test/widgets/qzds_game_button_test.dart` (4), `flutter test` (263)
- L03: `flutter analyze`, `flutter test
  test/widgets/game_countdown_timer_test.dart` (7),
  `flutter test` (270)
- L04: `flutter analyze`, `flutter test
  test/widgets/game_money_amount_test.dart` (6),
  `flutter test` (276)
- L05: `flutter analyze`, `flutter test
  test/widgets/game_answer_option_test.dart
  test/widgets/game_answer_option_reveal_blink_test.dart
  test/widgets/game_question_panel_test.dart
  test/widgets/game_dialog_money_row_test.dart
  test/widgets/game_dialog_layer_test.dart` (19),
  `flutter test` (289)
- L06: `flutter analyze`, `flutter test` (309),
  `flutter build web` (PASS)

## Remote-runtime honesty (hard requirement)

- `REAL_DEVICE_VISUAL_CHECK: NOT_PERFORMED` + `REAL_DEVICE_
  PLATFORM_CHECK: NOT_PERFORMED` appear verbatim in index
  (deferred table), L06 (Chạy-và-quan-sát + Hiểu-code),
  and this manifest. No lesson claims device/emulator visual
  verification.
- Reduce-motion tested via `MediaQueryData(disableAnimations:)`
  seam (L04/L05/L06) — no OS-setting required.
- GoogleFonts runtime fetch described accurately (network on
  first render; system-font fallback — parity senior).

## Declared deviations from template / plan

- Template-V2 spine kept on all six lessons + index (Mục tiêu →
  Checkpoint hoàn thành); index follows M27 overview shape.
- **Lesson-boundary divergence from the brief's internal
  sketch:** the task plan placed `GameFeatureButton`/lifeline
  widgets and the dialog-layer in L05 with "data/mapper in L06".
  On disk, `GameFeatureButton` reads `data.iconAsset` — it
  *cannot compile* against the M27 `icon: IconData` DTO. So
  lifeline files moved to **L06** (with the atomic DTO swap)
  and `dialogs/game_dialog_layer.dart` + its test landed in
  **L05** (the dialog-subsystem cluster: shell + 3 families +
  layer is self-contained once money-ladder exists at L04).
  Both lesson files + this manifest declare the boundary fix;
  total file-set per milestone unchanged.
- `QzdsGameButton` contains **no** press-scale animation —
  `QzdsButtonScale` is a size-preset enum; any brief wording
  implying press-scale animation is corrected in L02
  (Hiểu-code #1 + Lỗi #4).
- `screenDesignWidth` is **375**, not 390 (intake note).
- `game_dialog_layer_test` replaced (VI-10 → senior-11) rather
  than extended — declared; VI coverage persists via
  `game_screen_test` (14 VI/EN-mixed cases) + flow files.
- `game_screen_test` rewrite is 14→14 (net-0) — the +20 delta
  comes from feature-button(5) + flow(7) + result-flow(8).
- `game_money_ladder_dialog.dart` lands L04 (support file)
  though its caller (`GameDialogLayer` switch) lands L05 —
  compile-clean because the view file only needs `AppTokens`
  + `formatGameMoney` + l10n (all present); declared in L04
  "Ta cố ý chưa thêm".
- `_DialogShareButton` M27 scaffold retires at L06 by file
  deletion (not gradual) — it's inside `game_dialog_views.dart`
  which is deleted wholesale once `GameScreen` rewires.
- `GameFeatureButtonData.semanticLabel` retained-but-unrendered
  taught as parity (not simplified away).

## Verification before handoff

- Every quoted symbol verified against learner disk via
  grep/sed (a stale-read issue was encountered — the file
  *read* tool served pre-write content for
  `game_screen_data.dart` (phantom `import material` + 155 vs
  153 lines) and stale `02-implementation-evidence.md` test
  section — worked around by verifying **all** evidence with
  shell `cat`/`sed`/`grep`/`diff`; lessons quote only
  shell-verified content).
- 30 `lib/` ported files confirmed `diff -w`-empty vs senior
  modulo `ai_millionaire_course`↔`ai_millionaire` rename +
  CRLF (0-diff list verified per-file via shell loop).
  Non-verbatim learner files: `app_assets.dart` (subset —
  19 vs 73 lines), `game_screen_data.dart` (converged, VI
  docs, no imports, 153d), `game_screen_presentation_mapper.
  dart` (senior code + VI comments), ARB/test files.
- Diffs confirmed old(M27)→new(M28): `game_screen_presentation
  _mapper_test` **identical** (asserts types/isEnabled, never
  icons — survives iconAsset unchanged); `game_screen_view
  _model_test` 3-line diff (drop material import + icon→
  iconAsset ×2); `menu_screen_ui_events_test` 1-line diff
  (`Thang tiền thưởng`→`THANG TIỀN THƯỞNG`);
  `game_dialog_layer_test` 10→11 replace; `game_screen_test`
  14→14 rewrite; ARB +6 keys en/vi.
- Pre-M28 grep confirms first-appearances: no
  `AnimationController`/`TickerProvider`/`CurvedAnimation`/
  `Interval`/`TweenAnimationBuilder`/`AnimatedContainer`/
  `AnimatedScale`/`AnimatedDefaultTextStyle`/`CustomPainter`/
  `SvgPicture`/`Listenable.merge`/`AnnotatedRegion`/`if (…
  case …)` in M27 `lib/` (pre-M28 motion = `Curves.*` in
  `switchInCurve`/`sizeCurve` + `AnimatedOpacity` scaffold +
  `IgnorePointer`/`BackdropFilter`/`AnimatedSwitcher` in old
  layer — all cited as M21-reuse).
- ARB: `correctStateLabel` vi = `"Đúng"` (Argus-fixed; L01
  notes the `"Đú"` truncation history).
- Test counts counted on disk: new files 4+7+6+4+3+1+4+5+7+8
  = 49, layer-test +1 → +50 → 309.
- Line numbers cited in evidence table pulled via `grep -n`
  on current disk state.
- No `dart test`/`dart analyze` anywhere — all `flutter`.
- Allowed write scope respected: only `M28/04-content-draft.md`
  + `M28/lessons/*`; `web/` and `learner-app/` untouched.
- Not run during authoring: `flutter test`/`analyze`/`build`
  were *not* executed by the author — all counts derive from
  on-disk test-function enumeration + implementation evidence;
  physical replay is a later stage.

## Blocking issues

None. All required evidence was verifiable on disk; the only
surprise was the stale-read tool behavior (documented above)
and the brief's `390pt`/lifeline-placement wording, both
resolved to disk-authoritative content with declared
deviations.
