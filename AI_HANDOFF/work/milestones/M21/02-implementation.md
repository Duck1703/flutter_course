# M21 — Implementation Evidence (Flux)

## Scope executed

Roadmap M21 — senior dialog layer & back handling: replaced the
interim `showDialog`-route dialog scaffold with the senior's
state-driven in-`Stack` `GameDialogLayer`; migrated all 9
`GameDialogState` variants; wired `PopScope` back choreography;
`AnimatedSwitcher` keyed transitions + blur backdrop + tap-outside
rules; reduced-motion honored. VM dialog semantics unchanged
(presentation-only milestone). No menu-dialog migration (M29), no
share button (FR-33/M27), no `GameDialogShell` visual depth (M28),
no DRE (M26).

## Senior source inspected (fresh, this milestone)

| File | Symbols ported |
|---|---|
| `lib/widgets/game/dialogs/game_dialog_layer.dart` (191 LOC) | `GameDialogLayer` structure **verbatim in spirit**: `Positioned.fill` → `IgnorePointer(ignoring: dialog is GameDialogHidden)` → `AnimatedSwitcher(duration=reverseDuration=300ms, switchInCurve: easeOutCubic, switchOutCurve: easeInCubic, transitionBuilder: _buildTransition)`; child = `SizedBox.expand(key: ValueKey(dialog.runtimeType))`, hidden = `SizedBox.expand(key: ValueKey('game-dialog-hidden'))`; `_canDismissFromBackdrop` (NOT money-ladder AND NOT terminal), `_isTerminalDialog` (Ended‖Victory); `_buildTransition` = `AnimatedBuilder`→`FadeTransition`+`Transform.translate(slideOffset: spacingMd for ladder else spacingSm, transformHitTests: false)`; `MediaQuery.disableAnimations` → `Duration.zero`; `_DialogBackdrop` = `ClipRect`+`BackdropFilter(ImageFilter.blur(σ16))`+`ColoredBox(scrim)`+`Stack[Positioned.fill(GestureDetector(HitTestBehavior.opaque, onTap:onDismiss)), SafeArea+Center+ConstrainedBox(designWidth)→child]`; exhaustive 9-arm `_dialogBody` switch |
| `lib/screens/game_screen.dart` | `PopScope(canPop:false, onPopInvokedWithResult:(didPop,_) { if(!didPop) _handleRouteBack(); })`; `_handleRouteBack` identical decision table (Hidden→`showConfirmExit`; ladder/terminal→ignore; else→`dismissDialog`); `Stack[background, SafeArea content, GameDialogLayer]` ordering; `_afterExit` + `_terminalActionPending` **implemented** (optional per roadmap — taken); `uiEvents` bridge retained for `GameNavigateToMenuEvent` only |
| `lib/widgets/game/dialogs/{game_confirm_dialogs,game_help_dialogs,game_result_dialogs}.dart` | Per-variant view structure — learner keeps M19–M20 dialog bodies re-shaped into `GameDialogShell`-style card + senior callback names (`onDismiss`/`onConfirm`/`onCancel`/`onPlayAgain`/`onBackToMenu`); no share button (M27); no `QzdsGameButton`/gradient chrome (M28) |
| `test/widgets/game_dialog_layer_test.dart` (355 LOC) | Test model ported: `_TestSurface` re-pump style (dialog = prop, not route); keyed fade; reduced-motion immediate removal; outgoing-lingers-during-exit; terminal/ladder animate-out; tap-outside rules; ĐÃ HIỂU dispatch. Added one learner-only extra: same-variant payload swap does NOT re-animate (`runtimeType` key). Visual-chrome cases (`QzdsGameButton` width/shadow, no-Scrollable fit) not ported — M28 scope |
| `lib/core/app_design_tokens.dart` → `MenuTokens` | `dialogMotionLong=300ms`, `dialogHazeBlurSigma=16`, `dialogHazeScrim=0x00000000` (transparent — verbatim), `designWidth=375`, `spacingSm/Md/Lg` reused |

## Files changed

| File | Change |
|---|---|
| `lib/widgets/game/game_dialog_layer.dart` | **NEW** (215 LOC) — senior layer port |
| `lib/widgets/game/game_dialog_views.dart` | **NEW** (670 LOC) — 9 per-variant views + `_GameDialogCard` shell + `_ConfirmMessage`/`_EarnedContent`/`_DialogTextButton` |
| `lib/screens/game_screen.dart` | Rewritten 1095→588 LOC (269-LOC bridge + restored presentation widgets): `GameScreen`→`ChangeNotifierProvider`+`_GameScreenEventBridge`; bridge subscribes `uiEvents` (nav event only), owns `_terminalActionPending`/`_afterExit`; body `Stack[bg, SafeArea content, GameDialogLayer]`; `PopScope` + `_handleRouteBack`; `_GameDialogHost`/`_showCurrentDialog`/`_dialogOpen`/`_GameDialogAction`/post-pop re-routing **deleted** |
| `lib/view_models/game/game_screen_view_model.dart` | Removed all 10 `GameDialogRequested` emissions (dialog opens are pure state changes now) |
| `lib/data/game/game_session_state_data.dart` | `GameDialogRequested` class + stale comments removed; doc updated (`hasSavedResult` still M22) |
| `lib/core/menu_tokens.dart` | +`dialogMotionLong`/`dialogHazeBlurSigma`/`dialogHazeScrim` (verbatim values) |
| `test/game_screen_view_model_test.dart` | `startNewGame` no longer asserts `GameDialogRequested` event — asserts `uiEvents` empty |
| `test/widgets/game_screen_test.dart` | dismiss pumps 300→400ms (AnimatedSwitcher reverse starts one frame late — boundary `pump(300)` still saw outgoing child); `AlertDialog` finder → `GameConfirmWalkAwayDialogView` scope; comments updated (no more "pop anim"/"dialog route") |
| `test/widgets/game_dialog_layer_test.dart` | **NEW** — 10 tests ported/adapted from senior model |

## Verification

| Check | Result |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test` | **157/157 PASS** (147 pre-M21 + 10 layer tests) |
| `flutter build web` | **PASS** |
| `showDialog` in game surface | **0 call sites** (only menu settings dialog — FR-16→M29, and doc comments) |
| `GameDialogRequested` | **0 references** (retired; doc comment in state file notes it) |
| `GameDialogLayer` in screen `Stack` | Present, last child (topmost) |
| All 9 variants rendered | Exhaustive switch arms, no fallback |
| Back without dialog → confirm-exit | `PopScope`→`_handleRouteBack`→`showConfirmExit` |
| Back on ladder/terminal → ignored | `_handleRouteBack` early-returns |
| Back on confirm/explanation/poll/AI | `dismissDialog()` |
| Tap-outside dismiss | confirm-exit/AI/poll/explanation yes; ladder/terminal no |
| Terminal actions wait for animate-out | `_afterExit` + `_terminalActionPending` |
| Reduced-motion | `disableAnimations` → `Duration.zero` swap |

## Issues found & fixed during implementation

1. **Screen rewrite truncated widget classes** — first pass deleted
   `_GameTopBar`/`_QuestionPanel`/`_GameFeatureBar` etc. Restored from
   the M20-end-state clone; file now complete at 588 LOC.
2. **`GameDialogRequested` emission count off-by-one** — a nested emit
   under a conditional was at 6-space indent; patch adjusted for
   substring counting (10 real sites removed).
3. **Actions `Row` overflow (128px)** — `AlertDialog`'s old
   `OverflowBar` flexibly wrapped buttons; the plain `Row` overflowed
   the card. Fixed with `Flexible` wrappers — verified by the
   confirm-exit test.
4. **Dismiss assert at exact 300ms boundary flaky** — `AnimatedSwitcher`
   reverse starts one frame after the swap build; `pump(300)` still
   saw the outgoing child. Tests now pump 400ms on dismiss paths —
   senior's own tests use full `dialogMotionLong` after a *widget
   swap* where timing differs; documented in test comments.
5. **`AlertDialog` finder obsolete** — walk-away test re-scoped to
   `GameConfirmWalkAwayDialogView` (M21 has no route dialogs).

## Permitted simplifications used (per brief)

1. Card chrome = existing body shapes inside `_GameDialogCard` (title
   bar + scroll body + actions row), not `GameDialogShell`
   gradient/sheen/SVG — FR-32/FR-34 → M28.
2. `_afterExit` implemented (roadmap optional) — senior-true.
3. Scrim kept verbatim transparent (`0x00000000`); blur alone dims —
   identical to senior token value.
4. Menu settings dialog unchanged (`showDialog`) — M29 scope.
5. `MenuTokens.spacingLg` stays 24 (learner-wide token scale) vs
   senior `spacingLg`=20 — cosmetic token-scale delta, recorded for
   M28 visual pass (Argus minor).

## Not done (explicitly out of scope)

- `GameShareResultEvent` / share buttons — FR-33 → M27.
- `hasSavedResult` / result persistence — M22.
- Menu `MenuDialogLayer` — M29.
- `GameDialogShell` visual depth — M28.
- DRE — M26.

## Gate self-check

- G16: every mechanism traced to senior file/symbol; deltas listed
  above; no invented behavior.
- Test semantics: behavior tests only (dialog state → rendered
  widget, dismiss rules, transitions, back routing) — no "class
  exists" asserts.
