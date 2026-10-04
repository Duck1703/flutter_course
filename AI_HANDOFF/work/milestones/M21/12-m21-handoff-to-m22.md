# M21 → M22 HANDOFF

## M21 verdict

`MILESTONE_COMPLETE` — `11-final-verdict.md`.

## Architecture after M21

- `GameDialogState` (9 variants) is pure VM state; rendered by
  `GameDialogLayer` as the last `Stack` child of `game_screen.dart`.
- Layer: `Positioned.fill` → `IgnorePointer(ignoring: Hidden)` →
  `AnimatedSwitcher(300ms, easeOut/InCubic)` keyed `ValueKey(runtimeType)`
  → `_DialogBackdrop` (ClipRect→BackdropFilter σ16→transparent scrim
  →opaque GestureDetector→SafeArea→Center→ConstrainedBox 375) →
  per-variant `Game*DialogView` with senior-named callbacks.
- Back: `PopScope(canPop:false, onPopInvokedWithResult)` →
  `_handleRouteBack` — Hidden→`showConfirmExit`, Ladder/Ended/
  Victory→ignore, others→`dismissDialog`. Imperative `Navigator.pop`
  bypasses PopScope (verified in framework source).
- Terminal actions (`_handleBackToMenu`/`_handlePlayAgain`) run through
  `_afterExit`: dismiss → wait `dialogMotionLong` (or zero when
  `disableAnimations`) → `backToMenu`/`playAgain` —
  `_terminalActionPending` guards double-taps.
- `GameScreenUiEvent` family = `GameNavigateToMenuEvent` only.

## What M22 must touch (handed off intact)

- `backToMenu()`/`playAgain()`/`_endGame`/victory paths still build a
  `GameResult` carried by `goBack(result)` — the M10 route transport.
  Senior instead emits `GameSaveResult`/`hasSavedResult` at four end
  paths (victory, gameOver, walkAway, backToMenu) — idempotent.
- `resolvedResult` (M20 interim carrier, `won`/`earned` chốt at
  transition) is the current payload source — M22 replaces it with
  VM-side persistence; `applyGameResult` currently lives on
  `UserProfileData` (model-side) rather than the VM/repo boundary.
- Menu observes `userProfileStream` — sink already exists; M22 moves
  the *producer* (save boundary) to VM, keeping apply-once semantics.
- Terminal dialog callbacks (`onBackToMenu`/`onPlayAgain`) are the
  natural senior save boundary — verify against senior reducer before
  wiring.

## Counts at handoff

- Tests: **157/157** · analyze clean · `flutter build web` PASS.
- Site: **114 pages**, `/m21/` live; `/m22/` must NOT exist until M22
  content approval.
- Register after M21: FR-16/FR-07 CONVERGED; FR-01/FR-03/FR-04
  ACTIVE_TEMPORARY → **M22**; FR-29 →M29; FR-32/FR-34 →M28;
  FR-33 PLANNED →M27.

## M22_READY: YES

No unresolved M21 dialog/back defects; all M22 inputs (dialogState
machine, terminal-action boundary, repository stream) verified in
place.
