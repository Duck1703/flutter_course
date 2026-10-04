# M21 BRIEF — Senior Dialog Layer & Back Handling

Milestone: **M21** | Author: Atlas | Date: Step-17 long run, day 1
Status requested: `BRIEF_READY` → Flux implementation.

Roadmap section: `project-context/MILESTONE_ROADMAP.md` —
"M21 — Senior dialog layer & back handling" (lines ~1236–1293).

---

## 0. Baseline (verified before writing)

- Learner app: `flutter analyze` clean, `flutter test` **147/147**,
  `flutter build web` PASS. Website `npm run build` **108 pages**.
- Senior: `main @ c8eb860`, `git status` clean — read-only.

---

## 1. SENIOR FIDELITY CHECK

### Senior target

Replace the interim `showDialog` route-based dialog scaffold with the
senior's **state-driven in-`Stack` dialog layer**: sealed
`GameDialogState` → `GameDialogLayer` → `AnimatedSwitcher` + blur
backdrop + `PopScope` choreography. Zero `showDialog` calls remain in
the game screen.

### Senior files/symbols (all inspected live at c8eb860)

| File | Symbols |
|------|---------|
| `lib/widgets/game/dialogs/game_dialog_layer.dart` | `GameDialogLayer` (191 LOC): `Positioned.fill` → `IgnorePointer(ignoring: dialog is GameDialogHidden)` → `AnimatedSwitcher(duration=reverseDuration=AppTokens.dialogMotionLong=300ms, switchInCurve: easeOutCubic, switchOutCurve: easeInCubic, transitionBuilder: _buildTransition)`; child key `ValueKey(dialog.runtimeType)` (Hidden → `ValueKey('game-dialog-hidden')`); `_canDismissFromBackdrop` = NOT `GameMoneyLadderDialog` AND NOT terminal; `_isTerminalDialog` = `GameEndedDialog \|\| GameVictoryDialog`; `_buildTransition` = `AnimatedBuilder` → `FadeTransition` + `Transform.translate` (slide offset `spacingMd`=16 for ladder, else `spacingSm`=12; `transformHitTests: false`); `MediaQuery.of(context).disableAnimations` → `Duration.zero`; `_DialogBackdrop` = `ClipRect` + `BackdropFilter(ImageFilter.blur(σ=16))` + `ColoredBox(dialogHazeScrim = transparent)` + `Stack(Positioned.fill(GestureDetector(behavior: HitTestBehavior.opaque, onTap: onDismiss)))` + `SafeArea(minimum vertical spacingLg=24)` + `Center(DesignFrame(child))`; `_dialogBody` exhaustive switch over 9 variants |
| `lib/screens/game_screen.dart` | `PopScope(canPop: false, onPopInvokedWithResult: (didPop,_) { if (!didPop) _handleRouteBack(); })`; `_handleRouteBack`: `GameDialogHidden`→`showConfirmExit()`; `GameMoneyLadderDialog`/terminal→return (ignore); else→`dismissDialog()`; `Stack` children order: background → SafeArea content → `GameDialogLayer` (top layer); `_afterExit` terminal animation-wait choreography (dismiss → await `dialogMotionLong` → action) — **excluded by roadmap (explain only)**; `GameShareResultEvent` → `share_plus` → M27 |
| `lib/widgets/game/dialogs/{game_confirm_dialogs,game_help_dialogs,game_result_dialogs,game_dialog_shell}.dart` | View widgets per variant; share button on result dialogs (→ FR-33/M27); `GameDialogShell` card visual depth (gradient border + sheen + `QzdsGameButton` + SVG) — **visual depth stays M28** |
| `lib/widgets/common/design_frame.dart` | `Center(ConstrainedBox(maxWidth: 375))` |
| `lib/core/app_design_tokens.dart` | `dialogMotionLong=300ms`, `dialogHazeBlurSigma=16`, `dialogHazeScrim=Color(0x00000000)` (transparent — blur alone dims), `screenDesignWidth=375`, `spacingSm=12`/`spacingMd=16`/`spacingLg=24` |
| `test/widgets/game_dialog_layer_test.dart` | 355-LOC test model: keyed fade transitions, reduced-motion immediate removal, outgoing-visible-during-exit, outside-tap rules, terminal/money-ladder blocking |
| `lib/data/game/game_session_state_data.dart` | `GameScreenUiEvent` = `{GameNavigateToMenuEvent, GameShareResultEvent}` ONLY — **no dialog events** |

### Current learner form

- `lib/screens/game_screen.dart` (~1095 LOC): `_GameDialogHost`
  (`AlertDialog` inside `showDialog` route, `ListenableBuilder`
  live-read), `_showCurrentDialog` + `_dialogOpen` guard +
  `GameDialogRequested` uiEvent (learner-only, 10 emit sites (corrected post-impl: `_onAIAssistantElapsed` only copyWith, never emitted)) +
  `_GameDialogAction` enum + post-pop re-routing logic;
  `PopScope(canPop:false)` + `_handleRouteBack` already mirrors senior
  decision table but back presses POP THE DIALOG ROUTE first and the
  bridge repairs state afterwards (`null` action path).
- `test/widgets/game_screen_test.dart` (14 tests) asserts dialogs by
  text; 300ms pump comments say "pop anim".
- No `GameDialogLayer`, no `Stack` overlay on game screen, no
  `AnimatedSwitcher`/`BackdropFilter`/`IgnorePointer` usage anywhere
  in `lib/`.

### Senior target form

- `GameDialogState` (9 variants — already 1:1 since M20) rendered by an
  in-tree `GameDialogLayer` inside the screen's `Stack`; NO dialog
  routes; NO `GameDialogRequested` event; back handled purely by
  `PopScope`→`_handleRouteBack`→VM (`dismissDialog`/`showConfirmExit`
  already verbatim); tap-outside dismiss per senior's
  `_canDismissFromBackdrop` rules (new behavior vs `barrierDismissible:false`);
  transitions animate via keyed `AnimatedSwitcher`, honoring
  `MediaQuery.disableAnimations`.

### Register entries owned

| FR | Before | M21 change | Final status |
|----|--------|-----------|--------------|
| **FR-16** Dialog mechanism | ACTIVE_TEMPORARY — `showDialog`/`AlertDialog` for game results | Game dialogs → in-`Stack` `GameDialogLayer`; menu dialogs keep `showDialog` (senior `MenuDialogLayer` → M29 per roadmap) | **PARTIAL-CONVERGED**: game side done; menu side intentionally deferred (row stays ACTIVE with M29 note) |
| **FR-07** Game end UX | ACTIVE_TEMPORARY — 9-variant sealed parity landed M20, mechanism pending | in-`Stack` layer lands; senior back rules verbatim | **CONVERGED at M21** for game scope (dialog set + layer + back rules; share button on result dialogs belongs to FR-33/M27) |

### New register entry (durable decision — recorded now, synced at verdict)

| FR | Created | Reason |
|----|---------|--------|
| **FR-33** `GameShareResultEvent` / `shareResult` / share buttons on `GameEnded`+`GameVictory` | M21 formalizes the row that prior notes reserved | Senior result dialogs render a `shareResult` button → `vm.shareResult` → `GameShareResultEvent` → `share_plus` + clipboard fallback (`game_screen.dart` `_handleUiEvent`). Roadmap assigns `share_plus` to **M27** (platform extras). Learner result dialogs keep 2-button actions (menu/play-again) until M27. Owner: M27. Status: PLANNED |

### Expected closures

- `showDialog`/`AlertDialog`/`_GameDialogHost`/`_showCurrentDialog`/
  `_dialogOpen`/`_GameDialogAction`/`GameDialogRequested` — all retired
  from game surface.
- Back semantics become identical to senior (PopScope sees every back;
  no route to pop silently).

### Remaining active rows after M21

FR-01/FR-02 (EXP curve → M22), FR-03/FR-04 (result policy/transport →
M22), FR-16 partial (menu side → M29), FR-32/FR-34 (visual → M28),
FR-33 (share → M27), DRE → M26.

### Permitted simplifications (documented deviations)

1. **Dialog visual shell** — learner keeps its existing
   `AlertDialog`-shaped bodies (title/message/buttons) as the layer's
   children; senior's `GameDialogShell` gradient/sheen/`QzdsGameButton`/
   SVG icons stay M28 (consistent with FR-32/FR-34 policy). Structure
   (Stack layer, backdrop, dismiss rules, transitions) is senior-true;
   card chrome is not.
2. **`_afterExit` terminal choreography** — roadmap explicitly excludes
   ("EXPLAIN then optionally implement"). Flux MAY implement it
   (senior-true, ~15 LOC): dismiss terminal dialog → await
   `dialogMotionLong` (or zero when `disableAnimations`) → run
   `backToMenu`/`playAgain`. If implemented, record in evidence; if
   not, lesson documents senior's reason.
3. **Backdrop scrim color** — senior's `dialogHazeScrim` is
   transparent; learner may add a light `Colors.black26` scrim ON TOP
   of blur for readability OR keep verbatim transparent. Verbatim is
   preferred; if added, record as cosmetic delta in evidence.
4. **Menu dialogs** stay `showDialog` — roadmap assigns menu layer to
   M29.

### Forbidden alternatives

- No `Overlay`/`OverlayEntry`-based dialogs — senior uses in-`Stack`,
  not `Overlay`.
- No third-party dialog package.
- Do NOT add share buttons (M27/FR-33).
- Do NOT convert menu dialogs (M29).
- Do NOT introduce DRE machinery (M26) — `dialogState` stays a plain
  state field on the existing `ChangeNotifier` VM.
- Do NOT change VM dialog semantics (pause/resume, guards, phases) —
  they are already senior-verbatim; M21 changes PRESENTATION only.
- No new lint rules, no file moves outside scope.

---

## 2. LEARNING DESIGN CHECK

### New Dart concepts

- `ValueKey(Type)` — `ValueKey(dialog.runtimeType)` identity by type.
- Transition-builder function signature `(child, animation) → Widget`.
- `dart:ui` `ImageFilter.blur` (awareness-level: "lives in dart:ui").

### New Flutter concepts

- `AnimatedSwitcher` (duration/reverseDuration/curves/
  `transitionBuilder`, child-key identity drives swap).
- `FadeTransition` + `Transform.translate` + `AnimatedBuilder`.
- `BackdropFilter` + `ClipRect` (why clip needed).
- `IgnorePointer` (interaction gating without removing widget).
- `GestureDetector(behavior: HitTestBehavior.opaque)` (invisible area
  still hit-testable).
- `MediaQuery.of(context).disableAnimations` (a11y/reduced motion).
- `PopScope(canPop:onPopInvokedWithResult:)` full form (M19 used a
  minimal form — now the full signature + why `didPop` check).
- `Stack`+`Positioned.fill` as screen overlay layer (reinforces M18).

### New architecture concepts (CORE)

- **In-tree dialog layer vs dialog route** — ownership (VM state vs
  Navigator stack), rendering (siblings in Stack vs pushed route),
  lifetime (widget tree vs route), back behavior (PopScope decides vs
  route pops first), state relationship (dialog = pure projection of
  `dialogState`; no event needed to "open" it — REMOVE
  `GameDialogRequested` as proof).
- **Transition identity** — why `ValueKey(runtimeType)` swaps
  AnimatedSwitcher children; same-type mutations (AI loading→result)
  do NOT re-animate; what a key is NOT.
- **Dismiss policy as a function of state** — `_canDismissFromBackdrop`
  + `_isTerminalDialog` as pure functions over the sealed state.

### Prerequisites (all taught)

M15 sealed classes + exhaustive switch; M18 `Stack`/`Positioned.fill`
overlay; M19 `PopScope` basic form + event bridge + 6-phase machine;
M20 dialog variants + live-read dialog body. `MediaQuery` basics
appeared earlier (responsive layout lessons).

### Registry entries (new)

| ID | Concept | Depth | Home |
|----|---------|-------|------|
| D-37 | `ValueKey(runtimeType)` / key-driven widget identity for `AnimatedSwitcher` | CORE | M21/03 |
| F-29 | `AnimatedSwitcher` + `transitionBuilder` + `FadeTransition` + `Transform.translate` | CORE | M21/03 |
| F-30 | `BackdropFilter`+`ClipRect` + `IgnorePointer` + `HitTestBehavior.opaque` + `MediaQuery.disableAnimations` | NORMAL | M21/02 |
| A-21 | in-tree dialog layer (state → layer) vs dialog routes | CORE | M21/01 |

(IDs provisional — verify against `LEARNER_CONCEPT_REGISTRY.md` at
authoring time; use next free numbers if occupied.)

### Mental models

- "Dialog is not a place you navigate to — it's a widget that exists
  when state says so." (M15 planted this; M21 makes it literal.)
- "Back is a question the UI asks the VM, not a door the route opens."
- "A key is an identity claim: same key = same widget slot, no
  transition; new key = swap."

### Isolated example (CORE concept A-21/F-29)

`OverlayPlayground`-style micro-example: sealed `OverlayState{
hidden, confirm, done}` → `Stack[content, AnimatedSwitcher layer]`
in ~40 lines, unrelated domain kept tiny. Then map to 9-variant game
dialogs.

### Independent exercises

- PRODUCE: add a new overlay variant end-to-end (e.g. a `pausedDialog`
  stub) — state + layer arm + dismiss rule.
- DEBUG: wrong-`ValueKey` reuse (same key on different content → no
  transition) and/or back-swallows-dialog bug (`IgnorePointer`
  removed → taps leak through).
- PREDICT: given `disableAnimations=true` + terminal dialog + system
  back, predict the exact widget-tree outcome.

### Cognitive load / lesson split

5 lessons (do NOT compress variants+Stack+back+transitions into one):
1. `01` — why `showDialog` stops scaling; in-tree layer mental model
   (CORE A-21 home; isolated example).
2. `02` — `GameDialogLayer` skeleton: `Positioned.fill`, backdrop
   (blur/scrim/tap-outside), `IgnorePointer`, dismiss rules; bodies
   reused verbatim from `_GameDialogHost` (F-30).
3. `03` — `AnimatedSwitcher` + `ValueKey(runtimeType)` + transitions +
   `disableAnimations` (CORE F-29/D-37; the AI loading→result
   same-key case as the teaching gold).
4. `04` — back choreography: full `PopScope`, `_handleRouteBack`
   senior table, retire `showDialog` machinery +
   `GameDialogRequested`; optional `_afterExit` explanation.
5. `05` — tests (layer unit/widget tests modeled on senior's 355-LOC
   file) + regression + synthesis.

### Sequential checkpoint strategy

- L02 end: layer exists alongside (screen still uses scaffold) OR
  layer swapped in with backdrop only — must compile + tests pass.
- L03 end: AnimatedSwitcher wired — tests updated.
- L04 end: `showDialog` fully gone; back rules senior-true.
- L05: regression-only.
- Every checkpoint: `flutter analyze` + `flutter test` run, counts
  recorded in lesson. Staging must keep exhaustive switches
  compiling at each step.

### Exercises must test architecture, not rename/copy. Per-template
`Thử nghiệm`/`Tự làm` sections in every lesson.

---

## 3. Scope boundary (hard)

M21 = **presentation/back/dialog convergence only**. No result
persistence changes (M22), no DRE (M26), no share (M27), no menu
dialog layer (M29), no visual shell parity (M28). Do NOT persist
progression merely because dialogs expose results.

## 4. Done =

- [ ] `lib/widgets/game/game_dialog_layer.dart` (or equivalent learner
      path) exists; `game_screen.dart` has zero `showDialog`.
- [ ] All 9 `GameDialogState` variants render in-Stack; dismiss rules
      match senior; `IgnorePointer` gates when hidden.
- [ ] Back: hidden→confirm-exit; ladder/terminal→ignored;
      else→dismiss. No route pop of dialogs anywhere.
- [ ] `GameDialogRequested` + bridge scaffold removed; `uiEvents`
      family = `{GameNavigateToMenuEvent}` only.
- [ ] `AnimatedSwitcher` transitions + `disableAnimations` honored.
- [ ] `flutter analyze` clean; `flutter test` green (new layer tests
      included); `flutter build web` pass.
- [ ] Register: FR-16 updated, FR-07 updated, FR-33 row created
      (owner M27).
