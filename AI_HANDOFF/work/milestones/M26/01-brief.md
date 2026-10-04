# M26 — Atlas Milestone Brief

**Milestone**: M26 — Senior architecture: DRE refactor of the game
**Owner gates**: G16 Senior Fidelity; G17–G24 content gates; implementation QA;
content QA; site QA; sequential replay; post-PASS mutation check.

## SENIOR FIDELITY CHECK

### Senior target

`GameScreenViewModel` is a `DreChangeNotifier<GameState, GameAction,
GameEffect, GameAsyncOp>`. Every game transition is produced by the pure
`GameReducer`; timers, delayed callbacks, navigation and persistence are
effects/async-ops bridged back into the VM part files.

### Senior paths/symbols (all verified on disk at `c8eb860`)

- `lib/core/dre/dre.dart` (22 lines): `DreAction`, `DreEffect`,
  `DreAsyncOp` (empty `abstract interface class` markers),
  `DreReducer<S,A extends DreAction,E extends DreEffect,O extends
  DreAsyncOp>` with `DreResult<S,E,O> reduce(S state, A action)`, and
  `final class DreResult{state, effects: List<E> = const [], asyncOp: O?}`.
- `lib/core/dre/dre_change_notifier.dart` (75 lines):
  `abstract class DreChangeNotifier<S,A,E,O> extends ChangeNotifier` —
  ctor `{required reducer, required S initialState}`; `state` getter;
  broadcast `effects` stream; `@protected dispatch(A)` =
  reduce → swap state → `notifyListeners()` **only if** `prev != next`
  → add each effect → `unawaited(_executeAsyncOp(asyncOp, _state))`;
  `@protected Future<void> executeAsyncOp(O, S)` abstract;
  `@protected onAsyncOpError` no-op hook (called only when not disposed);
  `dispose()` sets `_isDisposed`, closes effects.
- `lib/view_models/game/dre/game_dre_action.dart` (74): `sealed class
  GameAction` + 14 `final class` variants — `GameStarted`,
  `GameDialogDismissed`, `GameAnswerSubmitted(answerText)`,
  `GameAnswerRevealElapsed(flowToken)`, `GameExplanationElapsed(flowToken)`,
  `GameFeatureSelected(type)`, `GameMoneyLadderRequested`,
  `GameConfirmExitRequested`, `GameConfirmWalkAwayRequested`,
  `GameWalkAwayConfirmed`, `GameTimerTicked`,
  `GameAIAssistantElapsed(flowToken)`, `GameBackToMenuRequested`,
  `GameShareRequested(text)`.
- `lib/view_models/game/dre/game_dre_effect.dart` (45): `sealed class
  GameEffect` + 8 variants — `GameStartTimer`, `GamePauseTimer`,
  `GameStopTimer`, `GameScheduleAnswerReveal(flowToken)`,
  `GameScheduleExplanation(flowToken)`,
  `GameScheduleAIAssistant(flowToken)`, `GameNavigateToMenu`,
  `GameShareResult(text)`.
- `lib/view_models/game/dre/game_dre_async_op.dart` (17): `sealed class
  GameAsyncOp` + `GameSaveResult{earnedAmount, isWin, questionCount}`.
- `lib/view_models/game/dre/game_dre_state.dart` (95): `class GameState`
  — the session model (13 fields incl. `flowToken`,
  `moneyAnimationTrigger`, `hasSavedResult`, unmodifiable
  `visibleOptionTexts`/`audiencePercentiles`/`usedFeatureButtons`),
  `GameState.initial`, `copyWith` + `clear*` flags.
- `lib/view_models/game/dre/game_dre_contract.dart` (4): barrel exporting
  the four files above.
- `lib/view_models/game/reducer/game_reducer.dart` (94): `class GameReducer
  implements DreReducer<...>`; `{questions, timePerQuestion}` ctor;
  `reduce` = exhaustive `switch` over all 14 actions delegating to part
  files; `_result` helper; `_walkAwayAmount`, `_moneyLadderItems`,
  `_audiencePollItems` helpers. `part` directives:
  `game_reducer_answer_flow.dart` (86), `game_reducer_feature_flow.dart`
  (161), `game_reducer_session_flow.dart` (148), `game_reducer_timer_flow.dart`
  (27) — all `extension _GameReducer*Flow on GameReducer`.
- `lib/view_models/game/game_screen_view_model.dart` (152): thin dispatch
  wrappers; `part 'bridge/game_screen_view_model_effects.dart'` (63 —
  `_handleEffect` switch, `_startTimer`/`_pauseTimer`/`_stopTimer`,
  `_scheduleAnswerReveal`/`_scheduleExplanation`/`_scheduleAIAssistant`
  with `_isDisposed` guard re-dispatching `*Elapsed` actions) and
  `part 'bridge/game_screen_view_model_result_persistence.dart'` (74 —
  `_saveGameResult`, `_syncSavedGameResult`, `_applyLevelProgression`,
  `_normalizedLevel`).
- `test/core/dre/dre_change_notifier_test.dart` (184): 5 tests — state+
  notify, effects-without-state-change, asyncOp receives post-reduce
  snapshot, unchanged state no notify, dispatch-after-dispose ignored.
- `test/view_models/game/game_reducer_test.dart` (199): 10 reducer tests
  covering start/dismiss intro/submit-outside-playing/reveal correct+wrong/
  explanation-dismiss advance+terminal-save/50:50/audience+AI effects/
  timer-at-zero.
- `test/view_models/game/game_screen_view_model_regression_test.dart`
  (100): 3 VM regression tests — submit-ignored-while-intro, stale AI
  result ignored after dismiss, terminal save once across repeated menu
  actions.

### DRE EVIDENCE NOTE

**The repository never expands the acronym "DRE".** `dre.dart` and
`dre_change_notifier.dart` contain zero doc comments; no file names,
comments or docs define what the letters stand for. It is a
project-specific pattern name, not a port of Redux/MVI/Elm — do NOT
invent the expansion in lessons, briefs or comments. What source proves:

- **Reducer role**: pure `(state, action) → {state, effects, asyncOp}`
  transition table; owns *all* game-state mutation and declares *what
  must happen* without doing it.
- **ChangeNotifier integration**: `DreChangeNotifier.dispatch` executes
  the reduce, diffs state identity (`!=` → `notifyListeners`), fans
  effects out over a broadcast stream, and fires the async op
  `unawaited` — the VM stays a `ChangeNotifier`, the UI contract
  (`ListenableBuilder`) does not change.
- **asyncOp**: at most ONE per reduce; receives the *post-reduce* state
  snapshot; errors route to overridable `onAsyncOpError` (senior game
  does not override — `_saveGameResult` self-handles with try/catch).
  It is a fire-and-forget boundary, NOT a loading/rollback framework.
- **Stale protection**: `flowToken` lives IN `GameState` and increments
  at every delay-producing transition; `*Elapsed` actions carry the
  token captured at schedule time and the reducer no-ops when it no
  longer matches — a stale callback is a no-op action, not an exception.
- **Rollback**: none exists. `_saveGameResult` failure is logged and
  swallowed — no previous-state restore, no retry.

### Current learner form

`GameScreenViewModel extends ChangeNotifier` (733 lines): owns
`GameSessionState`, direct `_emit(copyWith)` transitions inside public
methods, inline `_stopTimer`/`_schedule`/`_startTimer` calls, manual
`flowToken`, `_emitWithSaveResult` → `unawaited(_saveGameResult)`,
`_isDisposed` guards. Public API already senior-named. Two subtle
divergences the migration removes:

1. `_onRevealElapsed`/`_onExplanationElapsed` guard only `phase`, not
   `flowToken` — a stale delay can act on a newer flow. Senior reducer
   checks `flowToken != state.flowToken` first.
2. `dismissDialog` early-returns on `GameDialogHidden`; senior reduces
   through the default branch (state-units differ → one extra notify —
   verbatim port accepted).

### Senior target form

Verbatim port of every senior file listed above, minus share plumbing
(`GameShareRequested` action, `GameShareResult` effect,
`GameShareResultEvent` ui-event, `shareResult` method) which is
M27/FR-33 scope — **13 actions, 7 effects, 1 async op**.

`GameSessionState` → renamed `GameState` and moved to
`view_models/game/dre/game_dre_state.dart` (senior layout);
`game_session_state_data.dart` keeps `GamePhase` + `GameDialogState` +
`GameScreenUiEvent` only (matches senior file contents exactly).

### Fidelity rows owned

| Row | Action |
|---|---|
| FR-04 (evidence trail) | Note updated — "DRE asyncOp form lands M26" resolves: `_emitWithSaveResult` → `_withSaveResult` + `GameSaveResult` asyncOp. Row stays CONVERGED-at-M22; M26 evidence appended. |
| Register gap (new) | Add **FR-37** "Game VM architecture form" recording the deliberate M19–M25 intermediate (`ChangeNotifier`+manual guards) → CONVERGED at M26 (`DreChangeNotifier`+`GameReducer`+`asyncOp`). |

### Rows intentionally remaining active

FR-27/FR-28-residual/FR-33 (M27), FR-14-residual/FR-30/FR-28-visual/
FR-32/FR-34 (M28), FR-29/FR-31-residual (M29). Untouched.

### Permitted simplifications

- Share plumbing excluded (explicitly M27-owned; recorded in brief +
  status so reviewers do not flag "missing switch arm").
- `GameSessionState`→`GameState` rename is fidelity-positive (senior
  name), not a simplification.

### Forbidden alternatives

- Do NOT invent a "DRE" acronym expansion.
- Do NOT port Redux/MVI/Elm middleware, stores, or effect-runner
  abstractions senior does not have.
- Do NOT keep behavior-level mutation helpers in the VM body (all
  transitions must come from the reducer).
- Do NOT move `GamePhase`/`GameDialogState`/`GameScreenUiEvent` into
  `dre/` — senior keeps them in `game_session_state_data.dart`.
- Do NOT change `GameScreenData`/mapper/screen widgets — UI contract
  frozen.
- Do NOT implement M27 share/notifications or M28 visuals.

## LEARNING DESIGN CHECK

### New Dart concepts

- `part`/`part of` file splitting + private `extension` on a class
  across parts (senior reducer + VM bridges) — **CORE** (D-45).
  `part`/`part of` itself was introduced at M24 (auth dialog files);
  new at M26 is private `extension` inside part files.
- `abstract interface class` marker interfaces + generic bounded types
  `DreReducer<S,A extends DreAction,E extends DreEffect,O extends
  DreAsyncOp>` — **CORE** (D-46).
- `@protected` member annotation — **LIGHT**.
- `unawaited` on async ops — reinforcement (D-17 used at M22; first
  appearance in an infrastructure class here).

### New Flutter concepts

- Effects-as-data: reducer returns `List<GameEffect>` consumed by a
  broadcast stream bridge → timers/navigation (F-33).
- Async-op boundary: single `DreResult.asyncOp` executed with
  post-reduce snapshot, errors → `onAsyncOpError` (F-34).

### New architecture concepts

- Reducer pattern in *this* codebase only: state+action→next-state+effects;
  what belongs in reducer (transitions, guards, scoring) vs VM (timers,
  futures, repositories, stream plumbing) vs repository (persistence) vs
  UI (render+notify taps) — **CORE** (A-31).
- Token-based stale-callback invalidation *as data* (flowToken in state,
  not VM field) — **CORE** (A-32, extends D-42/A-29).

### Prerequisites (all taught)

- A-18 6-phase state machine (M19); A-20 mapper (M19); A-21 in-tree
  dialog layer (M21); A-22 VM-side save boundary (M22); D-42/A-29
  request-id/re-entrancy guards (M23/M25); D-26/D-27 sealed+switch
  (M15); D-34 copyWith+clear* (M19); D-37 ValueKey identity (M21).

### Concept registry changes

Add D-45 (`part`/`part of` + part-file private extensions),
D-46 (marker interfaces + generic bounds), F-33 (effects stream→bridge),
F-34 (async-op boundary + post-reduce snapshot), A-31 (project-local
reducer), A-32 (flowToken-as-state stale guard). Update rows that
referenced M26 as "reused-in" (D-36, D-42, A-18, A-22, A-29, F-29)
only if their milestone-usage columns require it — no re-teach needed.

### Depth levels

A-31 CORE; A-32 CORE; D-45 CORE (first `part`/`part of` usage in
project); D-46 CORE; F-33 NORMAL; F-34 NORMAL.

### Required mental models

- "Reducer trả về kết quả, không làm việc": pure input/output vs
  side-effect ownership.
- "Effect là ý định, bridge là hành động": data describing a timer vs
  the `Timer` itself.
- "Token trong state": stale = mismatched data, not caught exception.

### Isolated examples

- Counter reducer (`CounterState`, `Increment`/`Decrement`/`ScheduleReset`
  effect) before the game port — shows state→reduce→next-state+effect.
- Stale-download example (`DownloadState`, two clicks, A-finish-late) to
  motivate token-as-state.

### Independent exercises (≥1 PRODUCE + ≥1 DEBUG/PREDICT)

- PRODUCE: write a tiny reducer transition + test (milestone exercise:
  add `GameTimerTicked`-when-not-playing no-op test).
- DEBUG: planted stale-flowToken scenario — diagnose why a late reveal
  corrupts the next question when token check is removed.

### Reinforcement concepts

Sealed unions (M15), switch-exhaustive dispatch (M15), copyWith/clear*
(M19), idempotence flag `hasSavedResult` (M22), `_isDisposed` lifecycle
(M13/M19).

### Cognitive-load assessment

Largest architectural milestone since M19. Split into 6 lessons to keep
≤3 major concepts per lesson and each checkpoint independently runnable.

### Lesson split (6 lessons)

| # | Title | Scope | Checkpoint tests |
|---|---|---|---|
| 01 | Vì sao "VM mutation tay" đã đạt giới hạn | Problem + what DRE is (no acronym expansion) + before/after diagram; isolated counter reducer | 236 (no code change) |
| 02 | `core/dre` — contract + `DreChangeNotifier` | Port `dre.dart` + `dre_change_notifier.dart` + `dre_change_notifier_test.dart` | +5 → 241 |
| 03 | `GameState` + actions + effects | `dre/game_dre_*.dart` (state, action, effect, async op, contract); `GameSessionState`→`GameState` move+rename | compile; 241 |
| 04 | `GameReducer` — pure transition table | `reducer/game_reducer.dart` + 4 part files (13 actions/7 effects, no share); `game_reducer_test.dart` | +10 → 251 |
| 05 | VM migration + bridges | Rewrite `game_screen_view_model.dart` to `DreChangeNotifier` + 2 bridge part files; update `_onRevealElapsed` token guard to reducer | 251 (behavior-preserving) |
| 06 | Regression + regression-test port | Port `game_screen_view_model_regression_test.dart` (3) + full sweep | +3 → 254 |

### Sequential checkpoint strategy

Start = physical M25 end state (236 tests). Each lesson ends green:
236 → 241 → 241 → 251 → 251 → 254. Final tree must equal production M26.

## Acceptance

G16 PASS; G17–G24 PASS; impl QA PASS; content QA PASS; site QA PASS;
sequential replay PASS; regression PASS; post-PASS mutation
CLEAN/REVERIFIED; senior unchanged → `M26 = MILESTONE_COMPLETE` →
canonical sync → M27 may start.
