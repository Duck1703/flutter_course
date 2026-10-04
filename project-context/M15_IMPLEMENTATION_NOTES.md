# M15 Implementation Notes — Sealed classes & state-driven UI

## What landed

| Surface | Before (M14) | After (M15) |
|---------|--------------|-------------|
| Menu event family | `abstract class MenuUiEvent` in `menu_ui_event.dart` | `sealed class MenuScreenUiEvent` in `menu_screen_ui_event.dart` — senior name + file |
| Event bridge | `if (event is A) … else if (event is B)` | `switch (event)` statement, `case MenuGameRequested():` / `case MenuSnackBarRequested(:final message):` — senior-identical |
| Game dialog state | `GameEndReason? _endReason` + `switch` on enum with `case null` | `GameDialogState _dialogState` sealed field; variants `GameDialogHidden` / `GameEndedDialog(reason)` / `GameVictoryDialog` |
| `GameEndReason` enum | `{wrongAnswer, timeout, victory}` | `{wrongAnswer, timeout}` — victory is its own sealed variant now |
| `_dialogTitle`/`_resultText` | `switch` statement on enum incl. `case null` | `switch` **expression** on sealed state, `(:final reason)` destructure + nested enum switch; `GameDialogHidden() => ''` required by exhaustiveness |
| Title color | ternary on enum | `switch` expression with wildcard `_` |
| `_finish` | `_finish(GameEndReason)` | `_finish(GameDialogState)` — caller passes the variant; `won:` = `dialog is GameVictoryDialog` |
| `_restart` | `_endReason = null` | `_dialogState = const GameDialogHidden()` |
| Files | `menu_ui_event.dart`, `game_session_state.dart`, `test/menu_ui_events_test.dart` | `menu_screen_ui_event.dart`, `game_session_state_data.dart`, `test/menu_screen_ui_events_test.dart` (senior parity naming) |

## Register outcomes

- **FR-15 → CONVERGED** at M15 (sealed event family + exhaustive switch, senior-identical).
- **FR-07 → PARTIAL**: sealed types landed; `showDialog`/`AlertDialog`
  mechanism retained → M21 owns in-`Stack` `GameDialogLayer`; payload
  `reason` vs senior `earnedAmount` → M19/M22.
- **FR-05 → PARTIAL**: sealed *dialog* types landed; `GamePhase` stays
  a 3-value enum (senior is also enum — 6 values, full machine M19).

## Deliberately NOT in M15

- `MenuDialogState` — learner menu has no dialogs; first consumer arrives
  with settings (M16) / dialog layer (M21).
- `GameScreenUiEvent` — no game VM yet (M19).
- `AnimatedSwitcher`, `ValueKey(runtimeType)`, `transitionKey`,
  `isVisible` — M21.
- Reducer / immutable-state `copyWith` return — M19.
- 6 more `GameDialogState` variants (ladder, confirms, explanation,
  lifelines) — land with their features (M19–M21).

## Tests

`test/sealed_state_test.dart` — 5 tests: event payload carriage;
exhaustive switch output over `MenuScreenUiEvent` and
`GameDialogState`; `is` discrimination on a base-typed reference.
Exhaustiveness proven live: deleting `GameDialogHidden()` case →
`non_exhaustive_switch_expression` (demonstrated + restored).

## Verification (end-of-M15, real output)

- `flutter analyze` → `No issues found!`
- `flutter test` → `+74: All tests passed!` (69 → 74)
- `flutter build web` → `√ Built build\web`
- Website `npm run build` → 77 pages (71 + 6 m15 routes)
- Sequential replay M14→M15 on scratch clone: 5/5 lessons PASS
- Senior repo: `main` @ `c8eb860`, `git status` clean — unchanged
