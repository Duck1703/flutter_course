# M21 IMPLEMENTATION NOTES — in-Stack dialog layer & back handling

## What changed (learner `learner-app/`)

### New files
- `lib/widgets/game/game_dialog_layer.dart` — senior-verbatim
  structure: `Positioned.fill` → `IgnorePointer(ignoring:
  dialog is GameDialogHidden)` → `AnimatedSwitcher(duration/
  reverseDuration=dialogMotionLong 300ms, easeOutCubic/easeInCubic,
  transitionBuilder: fade+slide, ladder slides spacingMd)` →
  `_layerChild` (`SizedBox.expand(key: ValueKey('game-dialog-hidden')`
  | `ValueKey(dialog.runtimeType)`) → `_DialogBackdrop`
  (`ClipRect`→`BackdropFilter(σ16)`→`ColoredBox(0x00000000 scrim)`→
  `Stack[Positioned.fill GestureDetector opaque onTap=conditional
  dismiss, SafeArea(min spacingLg)→Center→ConstrainedBox(375)→view]`).
  Policies: `_canDismissFromBackdrop` (ladder+terminal block),
  `_isTerminalDialog`. `disableAnimations` → `Duration.zero`.
- `lib/widgets/game/game_dialog_views.dart` — 9 `Game*DialogView`
  classes (senior names) porting the M19–M20 `_GameDialogHost`
  bodies verbatim into callback style (`onDismiss`/`onConfirm`/
  `onCancel`/`onPlayAgain`/`onBackToMenu`), wrapped in
  `_GameDialogCard` (Container card — simplified senior
  `GameDialogShell`, chrome deferred M28) + `_ConfirmMessage`,
  `_EarnedContent`, `_DialogTextButton` helpers.

### Rewritten
- `lib/screens/game_screen.dart` 1095→588 LOC — bridge now:
  `PopScope(canPop:false, onPopInvokedWithResult→_handleRouteBack)`
  wrapping `Scaffold` whose body is `Stack[gradient bg,
  SafeArea(Center(ConstrainedBox(375) Column[topBar, question,
  featureBar])), GameDialogLayer]`; `_afterExit` awaits
  `dialogMotionLong` after terminal dismiss before
  `backToMenu`/`playAgain`; `_terminalActionPending` double-tap
  guard; `_attachViewModel` keeps only the uiEvents subscription
  (no post-frame dialog recovery — layer reads state directly).
- `lib/view_models/game/game_screen_view_model.dart` — 10
  `emitEvent(GameDialogRequested)` sites removed (all callers already
  `copyWith(dialogState:)`); `_emitEvent` kept for navigation.
- `lib/data/game/game_session_state_data.dart` —
  `GameDialogRequested` deleted; `GameScreenUiEvent` = sealed with
  `GameNavigateToMenuEvent` sole member.
- `lib/core/menu_tokens.dart` — +`dialogMotionLong` (300ms),
  `dialogHazeBlurSigma` (16), `dialogHazeScrim` (transparent),
  reusing `designWidth` (375).

### Deleted (retired scaffold)
`_GameDialogHost`, `_GameDialogAction` enum, `_showCurrentDialog()`,
`_dialogOpen` flag + post-pop re-route block, route-era post-frame
recovery.

### Tests
- New `test/widgets/game_dialog_layer_test.dart` — 10 tests ported
  from senior's 11 (QzdsGameButton/visual-shell cases deferred M28):
  keyed fade + backdrop key, reduced-motion instant, dismiss-lingers,
  ended/ladder animate-out, tap-outside ×3 rules, ĐÃ HIỂU dismiss,
  same-variant-no-reanimate.
- `test/widgets/game_screen_test.dart` — AlertDialog scope →
  `GameConfirmWalkAwayDialogView` descendant; dismiss pumps 300→400
  (`AnimatedSwitcher` reverse starts one frame after swap-build —
  boundary pump leaves outgoing child one extra frame).
- `test/game_screen_view_model_test.dart` — `GameDialogRequested`
  assertion → `expect(events, isEmpty)` after `startNewGame`.

### Verified framework mechanics
- `Navigator.pop` (imperative) bypasses `PopScope` — veto applies
  only to route-pop disposition (system back / `maybePop`).
  `goBack()` in `GameNavigateToMenuEvent` handler pops fine.
- `AnimatedSwitcher` outgoing child lives until reverse-duration
  completes (~one frame past the nominal boundary in tests).

## Senior parity snapshot (read-only, main@c8eb860)

- `senior/lib/widgets/game/dialogs/game_dialog_layer.dart` —
  structure mirrored 1:1 (same ordering, same policies, same
  transition builder incl. ladder slide distance).
- `senior/lib/screens/game_screen.dart` — `PopScope` +
  `_handleRouteBack` + `_afterExit` identical in behavior.
- Senior extras intentionally not ported: `onShare` on terminal
  views → M27 (FR-33); `GameDialogShell` chrome → M28 (FR-32/FR-34);
  `MenuDialogLayer` → M29 (FR-29).

## Register outcome

FR-16 CONVERGED (game scope) · FR-07 CONVERGED · FR-29 re-pointed
M29 · FR-33 newly registered (PLANNED → M27).
FR-01/FR-03/FR-04 stay ACTIVE_TEMPORARY → M22.

## Test counts

147 (M20) → **157** (+10 layer tests). `flutter analyze` clean,
`flutter build web` PASS, site 114 pages.
