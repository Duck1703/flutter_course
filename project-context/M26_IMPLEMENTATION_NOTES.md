# M26 Implementation Notes — DRE / senior async-state architecture

Converged the game ViewModel from the M19-era intermediate form
(direct-mutation `ChangeNotifier` + manual timer/delay/save plumbing)
to the senior's project-local **DRE** architecture, verbatim port.

## What DRE means in this repository

The senior repo never expands the acronym in prose. Source-defined
facts only (`lib/core/dre/`):

- `DreAction` / `DreEffect` / `DreAsyncOp` — empty
  `abstract interface class` markers (role labels, no members).
- `DreReducer<S, A, E, O>` — `DreResult reduce(S state, A action)`.
- `DreResult{state, effects, asyncOp?}` — next state + list of
  effect-data + at most ONE async operation per reduce.
- `DreChangeNotifier<S, A, E, O>` — ChangeNotifier that dispatches
  actions through the reducer, notifies only when state changed,
  emits effects on a broadcast stream, and fires `executeAsyncOp`
  `unawaited` with a post-reduce state snapshot. Errors route to
  overridable `onAsyncOpError`. Dispatch/effects no-op after dispose.

## Files (all verbatim senior, package renamed)

- `lib/core/dre/dre.dart`, `lib/core/dre/dre_change_notifier.dart`
- `lib/view_models/game/dre/` — `game_dre_state` (GameState +
  `flowToken` in-state + `hasSavedResult`), `game_dre_action`
  (13 variants), `game_dre_effect` (7 variants — share kept as
  boundary for M27), `game_dre_async_op` (`GameSaveResult`),
  `game_dre_contract` (typedefs)
- `lib/view_models/game/reducer/` — `game_reducer.dart` +
  `part` files `game_reducer_{session,answer,feature,timer}_flow.dart`
- `lib/view_models/game/bridge/` —
  `game_screen_view_model_effects.dart` (`_handleEffect` → real
  Timer/`Future.delayed`/`uiEvents`) +
  `game_screen_view_model_result_persistence.dart`
  (`executeAsyncOp(GameSaveResult)` → `_saveGameResult` + `_sync…`
  + `_applyLevelProgression`, all unchanged from M25)
- `game_screen_view_model.dart` — extends
  `DreChangeNotifier<GameState, GameAction, GameEffect, GameAsyncOp>`;
  public API preserved (`startNewGame`, `submitAnswer`,
  `handleFeatureClick`, `dismissDialog`, `backToMenu`, `playAgain`,
  `showMoneyLadder`, `showConfirmExit`, `showConfirmWalkAway`,
  `confirmWalkAway`); `screenData`/`dialogState`/`uiEvents` unchanged.
- `data/game/game_session_state_data.dart` — `GameSessionState`
  retired (field set lives on `GameState` under view_models/dre/).

## Preserved semantics (verified by tests)

- Save-once: `_withSaveResult` sets `hasSavedResult` in the SAME
  reduce that returns the op → terminal double-entry emits no second
  op. `questionCount = questionIndex + 1` read from post-reduce state.
- Stale guard: `flowToken` lives in `GameState`; every delay-creating
  transition increments it; `*Elapsed` actions carry the captured
  token and reduce to no-op when stale (senior
  `game_reducer_session_flow` token checks).
- Timer ownership moved to effect bridge: `GameStartTimer`/
  `GamePauseTimer`/`GameStopTimer`/`GameSchedule*` effects → real
  `Timer`/`Future.delayed` in VM; callbacks dispatch elapsed actions.
- UI untouched: `game_screen.dart` + widgets still read
  `screenData`/`dialogState`/`uiEvents`; zero call-site changes.

## Deferred (registered)

- `GameShareResultRequested` action + share effect arm exist in the
  DRE contract but the platform share (FR share boundary) is M27.
- FR-04's "DRE asyncOp form" clause → CONVERGED at M26.

## Numbers

- Tests: 236 → **254** (+5 dre notifier, +10 reducer, +3 regression).
- `flutter analyze` clean; `flutter build web` PASS; site 145 pages.
- Sequential replay `m26-replay`: 236→241→241→251→251→254,
  final tree byte-identical to production.
