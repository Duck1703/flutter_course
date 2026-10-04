# M21 — CONTENT DRAFT MANIFEST (Lumen)

## Intake gate

`IMPLEMENTATION_APPROVED` confirmed — `04-implementation-approval.md`
on disk after Argus impl QA PASS + remediation (spacingLg token note,
stale test comments, evidence LOC claim). Learner app verified:
`flutter analyze` clean, `flutter test` **157/157**, `flutter build
web` pass. Senior unchanged (`main@c8eb860`).

## Lessons authored (5 + index)

| File | Concepts | Exercise |
|---|---|---|
| `index.md` | milestone map + checkpoint arithmetic + deferred list | — |
| `01-dialog-la-state-khong-phai-route.md` | **A-21** in-tree dialog layer (CORE home): ownership/lifetime/back/testing deltas vs route; route-vs-layer contrast table; senior `GameDialogLayer` evidence | comprehension checkpoint only (no code — mental-model lesson) |
| `02-game-dialog-layer.md` | **F-30** `ClipRect`+`BackdropFilter(σ16)`+`ColoredBox` scrim+`GestureDetector(opaque)`+`IgnorePointer`; skeleton layer `Positioned.fill`→backdrop→view; 9 views ported verbatim; 3 layer tests | Tự làm MODIFY: tap-card-no-dismiss + flip `_canDismissFromBackdrop` |
| `03-animated-switcher-va-keyed-transitions.md` | **D-37** `ValueKey(runtimeType)` key-identity (CORE); **F-29** `AnimatedSwitcher`+fade/slide+`AnimatedBuilder`+`transformHitTests:false`; `disableAnimations`→`Duration.zero`; +3 transition tests | Tự làm DEBUG: same-key-everywhere bug |
| `04-popscope-va-back-handling.md` | `PopScope` veto semantics (imperative pop bypasses); `_handleRouteBack` 3-branch table; `_afterExit` exit-motion choreography; retire `GameDialogRequested`+host+route scaffold; test-timing 300→400 | Tự làm DEBUG: missing `Hidden` back-branch |
| `05-tests-regression-tu-lam.md` | 4 remaining parity tests (terminal/ladder animate-out, terminal tap-lock, same-variant-in-place); full regression; M22 boundary | **PRODUCE**: 10th variant end-to-end on branch (no-merge) |

## Registry / graph updates (done before QA)

- `LEARNER_CONCEPT_REGISTRY.md`: +**A-21** (CORE, M21/01), +**D-37**
  (CORE, M21/03), +**F-29** (CORE, M21/03), +**F-30** (NORMAL, M21/02)
  — all TAUGHT.
- `PREREQUISITE_GRAPH.md`: M21 section appended (edges F-26/F-27 +
  M19 `dialogState` + D-37/F-29/F-30 → L02→L03→L04→L05; feeds
  M22/M26/M28/M29).
- `SENIOR_FIDELITY_REGISTER.md`: M21 rows processed in Flux stage
  (FR-16 route→in-tree, FR-07 → 9-variant in-Stack parity,
  FR-33 share confirmed M27); Lumen adds no new rows.

## Depth assignments (per brief Learning Design Check)

- CORE: A-21 (L01 — isolated mental-model lesson, no code),
  D-37 (L03 — key-identity + wrong-key DEBUG), F-29 (L03 —
  AnimatedSwitcher mechanics + 3 behavior tests).
- NORMAL: F-30 (L02 — effect widgets, no architecture claim).
- Reuse: A-14 render-by-state, A-05 event-vs-state, A-18 machine,
  A-19 nav controller, A-20 mapper, D-27 type patterns, D-33
  Duration/timer, D-34 copyWith, D-35 Set, D-36 comprehensions,
  F-23 `HitTestBehavior.opaque`, F-25/D-31 l10n (19 existing keys —
  zero new ARB), F-26 overlay gating, F-27 PopScope, F-28
  AnimatedOpacity.

≤3 major new concepts per page: L01=1 (A-21), L02=1 (F-30 — views
are verbatim port, not new concept), L03=2 (D-37+F-29 — the two
halves of one mechanism), L04=1 (PopScope semantics; _handleRouteBack
is A-21 application), L05=0 new.

## Checkpoint arithmetic (honest, from M20 final 147)

| Lesson end | Count | Delta |
|---|---|---|
| L01 | **147** | no code — mental model |
| L02 | **150** | +3 layer tests (tap rules ×2, ĐÃ HIỂU) |
| L03 | **153** | +3 transition tests (keyed-fade, reduced-motion, dismiss-lingers) |
| L04 | **153** | edits only: VM test `GameDialogRequested`→`isEmpty`; widget test finder `AlertDialog`→`GameConfirmWalkAwayDialogView`; dismiss pumps 300→400 |
| L05 | **157** | +4 parity tests (ended animate-out, ladder animate-out, terminal tap-lock, same-variant-no-reanimate) |

## Sequential-staging notes (G24 honesty)

- **L02 deliberately ships the layer WITHOUT `AnimatedSwitcher`** —
  skeleton swap (Hidden→`SizedBox.shrink`, variant→backdrop+view).
  Layer is unmounted; tests are standalone. Documented in lesson.
- **L02 views land before mount** — `game_screen.dart` unchanged at
  L02 end; lessons state "layer tested in isolation, mounted in L04".
- **L04 is an atomic cut**: one step retires `GameDialogRequested` +
  host + route calls while mounting the layer. Learner is told to
  run the suite immediately after; no intermediate broken state
  survives past the step.
- **L04 test-timing fix is taught as a bug-class**, not silently
  patched: `AnimatedSwitcher` reverse controller starts one frame
  after swap-build → `pump(300)` lands on the boundary → dismiss
  waits become 400ms. Assertions unchanged.
- `tester.view.physicalSize`/`tapAt(Offset(8,8))`/`disableAnimations`
  MediaQuery are new test mechanics — each explained at first use.

## Declared section merges/drops (template V2)

- L01 is a mental-model lesson (no production code) — its
  checkpoint is comprehension + grep verification; standard
  sections kept.
- L02 defers the full `_dialogBody` exhaustive-switch explanation
  partially to a mapping table (9 rows) because all 9 views share
  one shape; two views quoted in full, rest specified row-by-row.
  Full file exists in repo for cross-check — lesson says so.
- No lesson drops the Checkpoint/Thử nghiệm/Tự làm blocks.

## Scaffolding declarations

| Item | Status | Owner |
|---|---|---|
| `GameNavigateToMenuEvent` + `goBack(GameResult)` transport | interim — VM-side `GameSaveResult` replaces it | **M22** |
| `_GameDialogCard` plain card (no gradient/sheen/SVG/`QzdsGameButton`) | learner-simplified shell | **M28** (FR-32/FR-34) |
| `onShareResult` absent on terminal views | senior-only param not ported | **M27** (FR-33) |
| Menu settings `showDialog` | route retained — different surface | **M29** |
| `MenuTokens.spacingLg`=24 vs senior 20 | cosmetic token delta | M28 |
| DRE/reducer | untouched | M26 |

Every lesson L02–L05 carries a "Ta cố ý chưa thêm" block listing
the same deferred items.

## Senior evidence references used

- `senior/lib/widgets/game/dialogs/game_dialog_layer.dart` —
  `Positioned.fill`/`IgnorePointer(Hidden)`/`AnimatedSwitcher`
  (300ms, easeOut/InCubic)/`ValueKey(runtimeType)`/`_DialogBackdrop`
  (ClipRect→BackdropFilter σ16→ColoredBox→Stack[opaque GD,
  SafeArea→Center→ConstrainedBox(375)])/`_canDismissFromBackdrop`/
  `_isTerminalDialog`/`_buildTransition` (ladder slides spacingMd).
- `senior/lib/screens/game_screen.dart` — `Stack[..., GameDialogLayer]`,
  `PopScope(canPop:false, onPopInvokedWithResult)`, `_handleRouteBack`,
  `_afterExit` (await motion before `backToMenu`/`playAgain`).
- `senior/test/widgets/game_dialog_layer_test.dart` — 11-test model;
  learner ports 10 (QzdsGameButton/ListView-internals skipped, M28).
- Flutter framework: `Navigator.pop` bypasses `PopScope`
  (`popDisposition` gates maybePop/system back only) — taught in
  L04 PREDICT with the verified mechanics.

## Content-author self-check

- [x] Vietnamese throughout; Android bridges in SIMILARITY /
  IMPORTANT DIFFERENCE / DO NOT ASSUME format (L01 route-vs-tree,
  L02 BackdropFilter/opaque, L03 AnimatedSwitcher-vs-AnimatedContent,
  L04 PopScope-vs-BackHandler).
- [x] No unimplemented code taught — every snippet matches
  `02-implementation.md` evidence + actual files (verified against
  `game_screen.dart` bridge, `game_dialog_layer.dart`, views ctor
  signatures, state ctors).
- [x] Scaffolding never presented as senior final — interim
  `resolvedResult` transport explicitly marked M22.
- [x] ≥1 PRODUCE (L05 10th-variant) + ≥1 DEBUG/PREDICT per milestone
  requirement (PREDICT ×3, DEBUG ×2, MODIFY ×1).
- [x] Every lesson ends with a runnable/assertable checkpoint; test
  counts match real suite arithmetic (147→150→153→153→157).
- [x] No false equations: `showDialog`-route vs in-tree contrasted
  without "Widget=Composable"/"Future=coroutine" claims.
- [x] G24: each lesson's code compiles at its checkpoint (L02/03
  layer unmounted; L04 atomic cut documented).

## Contract coverage — remaining sections

- New-concept first-appearance table: `BackdropFilter`/`ClipRect`/
  `IgnorePointer`/`opaque` at L02; `AnimatedSwitcher`/`ValueKey(Type)`/
  `AnimatedBuilder`/`FadeTransition`/`Transform.translate`/
  `disableAnimations` at L03; `PopScope`/`onPopInvokedWithResult`/
  imperative-pop-bypass at L04.
- Prerequisite references: every lesson lists "Bạn đã biết gì" with
  milestone IDs matching the registry.
- Incremental implementation details: exact file paths + add/replace
  wording on every step.
- Code-explanation coverage: every new construct gets a "Chi tiết
  quan trọng" bullet block.
- Exercise progression: recognition (L01 checks) → prediction
  (L02–L04 PREDICTs) → modification (L02 MODIFY) → debugging
  (L03/L04 DEBUG) → production (L05 PRODUCE).

## Notes for QA

- L02 is long (~820 lines) because it carries the full views-file
  port; the lesson explicitly permits cross-checking `_GameDialogHost`
  in-repo. Argus should verify no *new* construct sneaks in without
  explanation (all views reuse M19–M20 code).
- L04's claim "imperative `Navigator.pop` bypasses `PopScope`" was
  verified against installed Flutter framework source
  (`popDisposition` consulted only for route-pop disposition) —
  included in impl evidence.
- Test-count arithmetic: 147+3+3+0+4=157 matches impl QA.
- `index.md` links use `/m21/<slug>/` matching M20 site convention;
  filenames match slugs exactly.
