# MILESTONE BRIEF — M15: Sealed classes & state-driven UI

> Produced by: Atlas (`atlas-flutter-course-architect`)
> Basis: `MILESTONE_ROADMAP.md` §M15 + `CURRENT_STATE.md` (post Step-13) +
> `SENIOR_FIDELITY_REGISTER.md` + `LEARNER_CONCEPT_REGISTRY.md`
> State on creation: `BRIEF_READY`

---

## 1. Scope (hard boundaries)

**This milestone does only:** Introduce Dart `sealed class` +
exhaustive `switch` (statement + expression + object patterns) by
(a) converging the M13 event family to senior's sealed
`MenuScreenUiEvent`, and (b) introducing a learner-scoped sealed
`GameDialogState` hierarchy driving the existing end-of-game dialog —
replacing the `GameEndReason` enum + `is`-chain/`if`-driven content.

**This milestone does not do:**
- Full `GamePhase` 6-value machine or reducer — **M19** owns it
  (senior `GamePhase` is an enum; sealing the *dialog* state is the
  M15 part of FR-05's note, the machine is M19).
- In-`Stack` `GameDialogLayer`/`MenuDialogLayer`, `AnimatedSwitcher`,
  backdrop blur — **M21**. Learner keeps `showDialog`/`AlertDialog`.
- `MenuDialogState` in learner code — no menu dialogs exist yet
  (settings M16, leaderboard M23, auth M24). It is **senior evidence
  only** this milestone; the pattern is taught through the game
  dialog. Creating it now = 5 dead variants, an invented surface.
- `GameScreenUiEvent` (senior) — game has no VM until M19.
- Any M16–M29 feature work.
- `ValueKey(state.runtimeType)`/`transitionKey`/`isVisible` — taught
  as senior evidence only (`runtimeType` awareness); not used in
  learner code (no AnimatedSwitcher until M21).

**Absolutely forbidden:**
- introducing future-milestone concepts as dependencies
- inventing a "better" sealed hierarchy than senior's
- touching files outside the allow-list below

**Write allow-list (Flux):**
- `lib/view_models/menu/menu_screen_ui_event.dart` (rename of
  `menu_ui_event.dart`)
- `lib/view_models/menu/menu_view_model.dart` (import/type rename)
- `lib/screens/menu_screen.dart` (event bridge → exhaustive switch)
- `lib/data/game/game_session_state_data.dart` (rename of
  `game_session_state.dart` + add `GameDialogState` hierarchy)
- `lib/screens/game_screen.dart` (sealed dialog state drive)
- `lib/data/game/game_result.dart` (only if strictly needed)
- `test/**` (updates + new sealed-state tests)
- `pubspec.yaml` — no changes expected

## 2. Roadmap contract

| Field | Value |
|-------|-------|
| Learner outcome | Model "one of several states carrying data" with Dart `sealed class` + exhaustive `switch` expressions/patterns; refactor event + dialog state to sealed hierarchies |
| Visible project result | Sealed `MenuScreenUiEvent` + exhaustive switch in bridge; sealed `GameDialogState`-lite drives result dialog content; deleting a `case` produces a compile error (demonstrated) |
| Prerequisites (must be closed) | M13 events (exists ✓), M14 repos ✓ |
| Dart introduced | `sealed class`, `switch` expression, object pattern `Type(:final field)`, exhaustiveness, `runtimeType` (awareness only) |
| Flutter introduced | Render by `switch(state)` over sealed variants |
| Test targets | Sealed-variant behavior tests; existing suite must stay green |
| Completion criteria | All dialog/event variants sealed; `switch` exhaustive; deleting a `case` = compile error (shown) |

## 3. Starting state (verified, not remembered)

- End-of-M14 learner app on disk: `MenuUiEvent` = `abstract class` +
  2 `final class` subclasses in `menu_ui_event.dart`; `_handleUiEvent`
  uses `if (event is …) else if` chain; `GameEndReason` enum
  {wrongAnswer, timeout, victory} + `GamePhase{answering,revealing,
  finished}`; dialog = imperative `showDialog` + `_ResultAction` enum;
  `MenuViewModel` on repository stream (post-M14).
- Test count entering: **69 green**, `flutter analyze` clean.
- Baseline `flutter build web`: in progress at brief time.

## 4. Senior evidence to inspect

| Topic | Path + symbol | What it demonstrates |
|-------|---------------|----------------------|
| Sealed events | `lib/view_models/menu/menu_screen_ui_event.dart` — `sealed class MenuScreenUiEvent`, `final class MenuGameRequested`, `MenuSnackBarRequested(message)` | M15 event target shape |
| Event dispatch | `lib/screens/menu_screen.dart` — `_handleUiEvent` lines 67–76 | exhaustive `switch` statement + object pattern `(:final message)` |
| Menu dialog state | `lib/view_models/menu/menu_dialog_state.dart` — `sealed class MenuDialogState`, 5 `final class` variants, `isVisible`, `transitionKey` | senior pattern (evidence only — no learner menu dialogs yet) |
| Game dialog state | `lib/data/game/game_session_state_data.dart` — `sealed class GameDialogState` + 9 variants | M15 dialog-state target (learner subset) |
| State→widget switch | `lib/widgets/game/dialogs/game_dialog_layer.dart:102-149` | `switch(dialog)` expression over sealed variants |
| Game phase | same file — `enum GamePhase` (6 values) | senior phase is an *enum* — M19 owns the machine |
| Reducer usage | `lib/view_models/game/reducer/game_reducer_session_flow.dart` | dialogState written into immutable state (M19 evidence) |

**Known unknowns** (must not be invented): `earnedAmount` payloads
(money ladder M19), `affirmationMessage`, full dialog-variant set
(lifelines/explanation/AI → M20–M21), `MenuDialogState` consumers.

## 5. Simplification guidance

| Senior approach | Learner approach | Label |
|-----------------|------------------|-------|
| `GameDialogState` 9 variants | learner 3: `GameDialogHidden`, `GameEndedDialog(reason)`, `GameVictoryDialog` — variants grounded in real learner UX | `TEACHING_SIMPLIFICATION` |
| `GameEndedDialog(earnedAmount)` | `GameEndedDialog(reason)` — reason payload until money ladder (M19) + progression (M22) | `TEACHING_SIMPLIFICATION` |
| In-`Stack` `GameDialogLayer` | keep `showDialog`; sealed state picks *content* | `TEACHING_SIMPLIFICATION` → M21 |
| `transitionKey`/`runtimeType`/`isVisible` | taught as evidence, not implemented | awareness only → M21 |

## 5b. SENIOR FIDELITY CHECK (mandatory — gate G16)

| Field | Value |
|-------|-------|
| Senior source target | `MenuScreenUiEvent` sealed events; `GameDialogState` sealed dialog state |
| Files/symbols | `view_models/menu/menu_screen_ui_event.dart`; `screens/menu_screen.dart::_handleUiEvent`; `data/game/game_session_state_data.dart::GameDialogState`; `widgets/game/dialogs/game_dialog_layer.dart::_dialogBody`; `view_models/menu/menu_dialog_state.dart` (evidence) |
| Current learner difference | `abstract class MenuUiEvent` + `is`-chain; `GameEndReason` enum + `if`-style content picks inside one `AlertDialog` |
| Permitted simplifications | learner `GameDialogState` subset (3 of 9 variants); `reason` payload not `earnedAmount`; `showDialog` mechanism kept (→M21) |
| Fidelity-register entries opened | NONE |
| Entries expected to close | **FR-15 → CONVERGED.** FR-05 → PARTIAL (sealed dialog types land; 6-phase machine stays M19 — keep ACTIVE_TEMPORARY). FR-07 → PARTIAL (sealed state landed; in-Stack layer M21 — keep ACTIVE_TEMPORARY with updated current-form) |
| Forbidden alternatives | Do NOT keep a parallel `GameEndReason`-only design; do NOT introduce `MenuDialogState`/`GameScreenUiEvent`/`GamePhase` 6-value enum as dead types; do NOT add `AnimatedSwitcher`/in-Stack layer |

## 5c. LEARNING DESIGN CHECK (mandatory — Step-13; gates G17–G24)

| Field | Value |
|-------|-------|
| New Dart concepts | `sealed class` (CORE_CONCEPT); `switch` expression + object pattern `Type(:final field)` (CORE_CONCEPT); exhaustiveness/compiler refusal (CORE_CONCEPT — taught inside sealed+switch); `runtimeType` (LIGHT, awareness) |
| New Flutter concepts | state-driven rendering via `switch(state)` (CORE_CONCEPT) |
| New architecture concepts | UI state vs UI event — reinforced distinction (CORE, reinforcement of A-05); finite-state-over-booleans reasoning (NORMAL) |
| Prerequisites | class/extends/`abstract`/`final class` (D-04, D-22 TAUGHT M13/01 ✓); `switch` statement (D-14 TAUGHT M09 ✓); enum (D-06 TAUGHT M08 ✓); UI events (A-05 TAUGHT M13 ✓); Provider/ChangeNotifier (F-15/17 ✓); `is` checks (D-13 ✓) |
| Concepts being reinforced | D-14 switch → expression+patterns; D-22 class modifiers; A-05 event-vs-state; A-02 ownership |
| Registry nodes required | NEW: `sealed class` (D-26), switch-expression+object-pattern (D-27), state-driven UI (A-14); reinforced rows updated |
| Independent exercise plan | m15 lesson on sealed: learner defines `sealed ConnectionState{Offline, Connecting(retries), Online}` + writes exhaustive handler (PRODUCE); PREDICT exercise: delete a `case` — what does the compiler do? (verify); DEBUG: a switch missing a variant |
| Cognitive-load risk | Highest at "sealed + exhaustive switch + object patterns" — split across lessons so no page teaches >2 majors |
| Lesson split decision | 5 lessons (Lumen may adjust ±1): 01 problem/why-finite-state; 02 sealed class; 03 exhaustive switch + patterns; 04 state-vs-event + seal the event bridge; 05 GameDialogState + state-driven dialog content + tests |
| Sequential checkpoint strategy | L01–03 theory+tiny examples (analyze clean throughout); L04 seals events only — compiles green (switch replaces is-chain atomically); L05 adds dialog state + refactors builder — compiles green; tests green each page |

## 6. Lesson-count guidance

4–6 lessons. Each new CORE_CONCEPT gets: mental model → isolated
example → Android bridge → senior evidence → project application →
mistakes → exercise.

## 7. Done criteria (stage 2 exit)

- [ ] `flutter analyze` clean
- [ ] `flutter test` green: ~69 + new sealed-state tests
- [ ] `flutter build web` passes
- [ ] `02-implementation-evidence.md` complete per contract
- [ ] `switch` exhaustive; delete-a-case → compile error demonstrated
- [ ] FR-15 closed in register; FR-05/FR-07 rows updated to post-M15 form

## 8. Next step

```text
NEXT STEP (INTERNAL)
  Who: Flux
  Input: this brief + STATE: BRIEF_READY
  Output: learner-app changes + 02-implementation-evidence.md
```
