# M19 — ATLAS MILESTONE BRIEF

**Milestone:** Game v2 — structured VM, phases, timer, money ladder
**Stage:** `BRIEF_READY` → Flux may start on approval of this brief.

---

## SENIOR FIDELITY CHECK

### Senior target

Extract all game-session logic from `lib/screens/game_screen.dart`'s
`_GameScreenState` (629-line StatefulWidget) into a
`GameScreenViewModel extends ChangeNotifier` holding one immutable
session-state object; 6-phase `GamePhase` machine; VM-owned
`Timer.periodic` 30s countdown; real 15-level money ladder +
safe-haven `guaranteedAmount`; `buildGameScreenPresentation` pure
mapper producing `GameScreenData`; `AppNavigationController`
(GlobalKey + context-free dispatch); `PopScope` back → confirm-exit;
explanation-dialog flow; `GameQuizQuestionData` full shape + senior
question bank; portrait lock at bootstrap.

**NOT senior DRE** — roadmap explicitly defers DRE to M26 and
prescribes the intermediate "senior-style GameScreenViewModel
extends ChangeNotifier … GameState-lite without DRE". We adopt the
*single immutable state object + copyWith* option (senior's
`GameState` shape minus M20+/M22 fields), not field-soup.

### Senior files/symbols (inspected live, commit c8eb860)

| Symbol | Senior path | Notes |
|---|---|---|
| `GameScreenViewModel` | `lib/view_models/game/game_screen_view_model.dart` | extends `DreChangeNotifier` — learner keeps `ChangeNotifier` (DRE→M26); API: `startNewGame/submitAnswer/showMoneyLadder/showConfirmExit/dismissDialog/backToMenu/playAgain`, `screenData`, `dialogState`, `uiEvents` |
| `GameState` | `lib/view_models/game/dre/game_dre_state.dart` | immutable + copyWith + `clear*` flags + `flowToken` stale-guard |
| `GamePhase` (6) | `lib/data/game/game_session_state_data.dart:1-8` | `notStarted, playing, answeredPending, answeredRevealed, gameOver, victory` |
| `GameDialogState` (9) | same file L10-110 | M19 needs: Hidden, MoneyLadder, ConfirmExit, Explanation, Ended(earnedAmount), Victory(earnedAmount,affirmation). AudiencePoll/AIAssistant/WalkAway → M20 |
| `GameScreenUiEvent` | same file L112-124 | senior has NavigateToMenu + ShareResult; M19 lands NavigateToMenu only (share unassigned → new register row) |
| `GameScreenData` + models | `lib/data/game/game_screen_data.dart` | M19: money/question/answers/timer; `featureButtons` deferred to M20 |
| `buildGameScreenPresentation` | `lib/view_models/game/game_screen_presentation_mapper.dart` | pure top-level fn; A–D labels via `String.fromCharCode(65+i)` |
| `gameMoneyLadderLevels` | `lib/data/game/game_money_ladder_data.dart` | 15 levels; safe havens at L5 $20k, L10 $400k, L15 $1M; Easy/Medium/Hard difficulty labels |
| `formatGameMoney` | `lib/view_models/game/support/game_money_formatter.dart` | `$` + thousands commas |
| `buildGameMoneyLadderItems` | `lib/view_models/game/support/game_money_ladder_mapper.dart` | reversed list; `isCurrent`/`isSpecial` flags |
| `GameQuizQuestionData` | `lib/data/game/game_quiz_question_data.dart` | `id, question, options(List<String>), correctOption(String), category, language, difficulty, explanation{explainForTrueAnswer, explainForWrongAnswers, aiHintMessage}` |
| `gameSampleQuestions` | `lib/data/game/game_sample_{easy,medium,hard}_questions_data.dart` + combinator | 15 const questions, ordered to match ladder difficulties |
| Timer/effect flow | `view_models/game/bridge/game_screen_view_model_effects.dart` + `reducer/*_timer_flow.dart` | `Timer.periodic(1s)` in VM; tick no-op unless `playing`; timeout→`answeredPending`+empty selected+`flowToken++`; dialogs pause (cancel), dismiss resumes iff `playing`; `_answerRevealDelay`1500ms, `_explanationDelay`1000ms |
| `AppNavigationController` | `lib/navigation/app_navigation_controller.dart` | `GlobalKey<NavigatorState>`; `openGame()`/`goBack()`; wired `navigatorKey` on `MaterialApp`; exposed via Provider |
| `PopScope` + `_handleRouteBack` | `lib/screens/game_screen.dart` | `canPop:false`; hidden dialog→confirm-exit; terminal/ladder→ignore; else dismiss |
| Portrait lock | `lib/main.dart:24` | `await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])` after `ensureInitialized` |
| Result save | `bridge/…_result_persistence.dart` | VM-side repo save — **M22**, excluded |

### Current learner form

`lib/screens/game_screen.dart` `_GameScreenState` owns: `_phase`
(3-value), `_questionIndex`, `_selectedIndex` (int), `_correctCount`,
`_answeredCount`, `_dialogState` (3-variant sealed), `_secondsLeft`
(int, 15s), `_timer`; `_selectAnswer/_submitAnswer/_advanceAfterReveal
/_finish/_restart`; `showDialog<_ResultAction>`; `Navigator.pop
(result)`. `QuizQuestion`{q,options,correctIndex} × 4 Vietnamese
hardcoded. Menu `push<GameResult>` → `applyGameResult` (M10).

### Senior target form (learner, M19-intermediate)

- `GameScreenViewModel extends ChangeNotifier` in
  `lib/view_models/game/game_screen_view_model.dart` — methods map
  1:1 to senior's dispatch wrappers (minus lifelines/share/asyncOp);
  owns `GameSessionState` (copyWith), `Timer?`, `_isDisposed`,
  `_events` broadcast `GameScreenUiEvent`; delayed flows via
  `Future.delayed` + `state.flowToken` guards.
- `GameSessionState` immutable in
  `lib/data/game/game_session_state_data.dart` (register-evidence
  file): `phase, questionIndex, moneyEarned, guaranteedAmount,
  moneyAnimationTrigger, remainingTime(Duration), selectedAnswer
  (String?), dialogState, flowToken` + `initial()` factory +
  copyWith w/ `clearSelectedAnswer`. **Excluded until M20/M22:**
  `visibleOptionTexts`, `audiencePercentiles`, `usedFeatureButtons`,
  `hasSavedResult`.
- `GameScreenUiEvent` sealed: `GameNavigateToMenuEvent` +
  `GameDialogRequested` (learner scaffold — state→`showDialog`
  bridge until M21; recorded under FR-16).
- `GameScreenData` presentation family (no `featureButtons` yet)
  + `buildGameScreenPresentation` mapper — senior paths/names.
- `gameMoneyLadderLevels` + `formatGameMoney` +
  `buildGameMoneyLadderItems` — verbatim.
- `GameQuizQuestionData` + `gameSampleQuestions` bank — verbatim
  senior content (English; FR-31 residual keeps quiz unlocalized);
  `quiz_question*.dart` deleted; `onboarding_content_data.dart`
  swaps `quizQuestions`→`gameSampleQuestions` (count becomes 15).
- `AppNavigationController` — verbatim except `openGame()` returns
  `Future<GameResult?>` (transport kept → FR-04 partial).
- `PopScope` + confirm-exit; portrait lock; menu `_openGame` →
  `navController.openGame()`; `Navigator.pop(context, result)` kept
  for game→menu result (until M22).
- `GameResult` gains `earnedAmount`; `questionsAnswered` adopts
  senior semantics `questionIndex+1` (attempted, not submitted).
  `applyGameResult` uses `earnedAmount` for money; EXP stays
  count-based → M22.

### Register entries owned (matrix)

| ID | Current learner | Senior | M19 responsibility | Final status |
|---|---|---|---|---|
| FR-03 | flat 50k/correct EXP+money | ladder earnedAmount; EXP=amount (M22) | money ladder + `earnedAmount` into GameResult/profile apply | PARTIAL (EXP basis stays M22) |
| FR-04 | `Navigator.pop(result)` transport + direct push | nav controller + VM-side save (M22) | `AppNavigationController` + `navigatorKey` + `openGame` | PARTIAL (pop-result stays M22) |
| FR-05 | 3-phase enum | 6-phase machine | full 6-phase + transition rules in VM | **CONVERGED** |
| FR-06 | 15s | 30s `timePerQuestion` | 30s + VM-owned timer | **CONVERGED** |
| FR-07 | 3-variant dialogs, no payload | 9 variants in-Stack, `earnedAmount` | +MoneyLadder/ConfirmExit/Explanation variants; ended/victory gain `earnedAmount`(+affirmation); mechanism showDialog→M21 | PARTIAL |
| FR-10 | `QuizQuestion` subset | full `GameQuizQuestionData` | replace model + bank call sites | **CONVERGED** |
| FR-13 | direct `Navigator.push` | `AppNavigationController` | controller + wiring (menu openGame; game back via event→`Navigator.pop(result)` transport) | **CONVERGED** (transport residue lives under FR-04) |
| FR-17 | no lock | `setPreferredOrientations` | portrait lock in `main()` | **CONVERGED** |
| FR-18 | 4 learner questions | senior `gameSampleQuestions` | adopt verbatim bank | **CONVERGED** |
| NEW FR-33 | — | `GameShareResultEvent` + SharePlus + share buttons on terminal dialogs | not implemented anywhere | OPEN — share feature unassigned; flag for M21+ |

Remaining active (untouched): FR-01/02 (M22), FR-11/12 (M24),
FR-14 (M23), FR-16 (M21), FR-27 (M27), FR-28 (M22+/M27),
FR-29 (M21), FR-30 (M24), FR-31 (multi), FR-32 (M28).

### Permitted simplifications

- ChangeNotifier VM instead of `DreChangeNotifier`+`GameReducer`
  (DRE → M26; prescribed by roadmap).
- Dialogs still `showDialog` (FR-16 → M21); `GameDialogRequested`
  event bridges state→route.
- `openGame()` returns `Future<GameResult?>` (FR-04 residue).
- Leaner UI widgets (no gradient/motion polish — visual parity M28).
- `GameEndReason` retired (senior doesn't distinguish end reasons —
  timeout & wrong both show `GameEndedDialog(earnedAmount)`).

### Forbidden alternatives

No Bloc/Cubit/Riverpod/Redux/GetX; no custom state-machine library;
no route/dialog redesign beyond scope; no lifelines (M20); no
VM-side persistence (M22); no DRE types (M26); no in-Stack dialog
layer (M21); no invented senior behaviors.

---

## LEARNING DESIGN CHECK

### New Dart concepts

- `Duration` arithmetic + `Timer.periodic` field ownership in a VM
  (CORE — first VM-owned timer).
- Immutable session-state object + `copyWith` w/ `clear*` flag
  pattern (CORE — first multi-field state struct).
- `flowToken` staleness guard for delayed async (NORMAL).
- `int?`→text-keyed selection (`String? selectedAnswer`) — identity
  by value not index (LIGHT).

### New Flutter concepts

- `GameScreenData` presentation-mapper pattern — VM getter building
  a view-model DTO (CORE).
- `PopScope(canPop: false, onPopInvokedWithResult:)` (NORMAL).
- `AppNavigationController` + `navigatorKey` context-free nav
  (NORMAL).
- `SystemChrome.setPreferredOrientations` (LIGHT).
- `ValueKey` re-fire animation trigger awareness (LIGHT).

### New architecture concepts

- State machine as *the* session model: finite phases, guarded
  transitions, "why booleans rot" (CORE).
- Effect-like side-effects inside a plain ChangeNotifier: timers,
  delays, event emission — pre-DRE mental model (CORE).
- Fourth→fifth lifetime tier: screen-scoped `GameScreenViewModel`
  via `ChangeNotifierProvider(create:)` on the route (reinforce
  A-15/A-17 pattern).

### Prerequisites

M05 (Future), M06 (streams), M08 (widget tests), M09 (timer/phases
lite), M11 (ChangeNotifier), M12 (Provider), M13 (UI events),
M14 (repos/subscriptions), M15 (sealed + patterns), M16 (dialog
scope), M17 (l10n), M18 (overlay gating + `listEquals` discipline).
All TAUGHT in registry.

### Registry nodes (new)

- D-33: `Duration` + `Timer.periodic` owned by a VM (tick→state,
  cancel on dispose/dialog) — CORE.
- D-34: `copyWith` + `clear*` flags on multi-field immutable state —
  CORE (extends D-05 copyWith).
- F-27: `PopScope` back interception (canPop + onPopInvokedWithResult)
  — NORMAL.
- A-18: VM-owned session state machine (phase + transitions + event
  boundary; pre-DRE) — CORE.
- A-19: `AppNavigationController` + `navigatorKey` context-free nav —
  NORMAL.
- A-20: presentation-mapper `screenData` (state→DTO) — NORMAL.

### Depth

3 CORE (state machine, immutable session state, VM timer/async
ownership), 3 NORMAL, 2 LIGHT.

### Mental models

1. "The game IS the state machine" — phases + allowed transitions
   drawn before code.
2. "Widget forwards intent; VM owns decisions" — every old
   `_GameScreenState` method gets a VM home.
3. "Delayed flows need a token" — stale-async as a correctness
   problem, not a bug fix.

### Isolated examples

- Tiny order-state machine (OrderPhase: idle→paid→shipped, invalid
  transitions impossible) before `GamePhase`.
- Mini `Notifier` holding `Duration` + `Timer` before the full VM.

### Independent exercises

- PRODUCE: add a transition (e.g. `pause` extension or new dialog
  variant) or write transition tests — learner-authored.
- DEBUG: remove `flowToken` guard → stale reveal overwrite.
- PREDICT: timer-after-dispose / double-submit behavior.

### Cognitive load

Max 3 major concepts/lesson. Heavy split required — 6 lessons.

### Lesson split (proposed)

1. Why the widget can't own this + state-machine mental model
   (theory; isolated order-machine example).
2. Data foundation: `GamePhase`×6, `GameSessionState`, extended
   `GameDialogState`, `GameScreenUiEvent`, money ladder, question
   model + bank swap, l10n keys.
3. `GameScreenData` + `buildGameScreenPresentation` (pure mapper).
4. `GameScreenViewModel` — methods, timer, flowToken delays,
   explanation flow, transitions (CORE).
5. Screen migration — provider scope, event bridge, dialog
   bridging, `PopScope`, nav controller, portrait lock, menu rewiring.
6. Tests + regression + exercises + synthesis.

### Sequential checkpoint strategy

L01 none (theory); L02 data compiles standalone (delete old model
+ bank, fix 3 consumers incl. onboarding content + tests) →
analyze-clean; L03 mapper + unit test; L04 VM + focused VM tests;
L05 screen wiring + widget tests → analyze + suite; L06 full
regression + `build web`.

---

## Scope guardrails (Flux)

- No `GameFeatureButton*`, lifelines, `visibleOptionTexts`,
  `audiencePercentiles`, `usedFeatureButtons`, walk-away/AI/poll
  dialogs → M20.
- No `hasSavedResult`, VM-side repo save, `AuthRepository`/
  `UserProfileSyncRepository` deps → M22.
- No in-`Stack` `GameDialogLayer`, `AnimatedSwitcher`, backdrop
  rules → M21 (keep `showDialog` + event bridge).
- No `GameShareResultEvent`/SharePlus → FR-33 open row.
- No `_terminalActionPending`/`_afterExit` choreography → M21
  (terminal actions may dismiss+pop directly).
- Keep MenuScreen result application unchanged.

## Verification bar

`flutter analyze` clean; `flutter test` all pass (existing game
tests rewritten to M19 semantics; new VM/mapper/ladder unit tests);
`flutter build web`; senior diff clean at c8eb860.
