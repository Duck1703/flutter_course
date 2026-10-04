# IMPLEMENTATION EVIDENCE — M15: Sealed classes & state-driven UI

> Produced by: Flux (`flux-flutter-implementation-engineer`)
> Status: `IMPLEMENTATION_QA` — awaiting Argus
> Basis: `01-brief.md` allow-list + real senior source inspection

---

## 1. Senior source actually inspected (this run, on disk)

| Topic | Path + symbol | What it demonstrates |
|-------|---------------|----------------------|
| Sealed event family | `flutter-accelerator-ai/lib/view_models/menu/menu_screen_ui_event.dart` — `sealed class MenuScreenUiEvent` + `final class MenuGameRequested`, `final class MenuSnackBarRequested { final String message; }` | M15 event target shape — name, `sealed` + `final class` variant pairing, payload on the subclass |
| Event dispatch | `flutter-accelerator-ai/lib/screens/menu_screen.dart::_handleUiEvent` — `switch (event) { case MenuGameRequested(): …; case MenuSnackBarRequested(:final message): … }` | switch **statement** + object pattern `(:final message)` on a sealed type |
| Menu dialog state | `flutter-accelerator-ai/lib/view_models/menu/menu_dialog_state.dart` — `sealed class MenuDialogState`, 5 `final class` variants, `isVisible`, `transitionKey => runtimeType` | Senior sealed-state pattern (EVIDENCE ONLY — learner has no menu dialogs yet) |
| Game dialog state | `flutter-accelerator-ai/lib/data/game/game_session_state_data.dart` — `sealed class GameDialogState` + 9 variants | M15 dialog-state target (learner keeps a 3-variant subset) |
| State→widget switch | `flutter-accelerator-ai/lib/widgets/game/dialogs/game_dialog_layer.dart::_dialogBody` (~lines 102–149) | `switch (dialog)` expression rendering variants; `ValueKey(dialog.runtimeType)` |
| Game phase | same file — `enum GamePhase` (6 values) | CONFIRMED: senior phase is an **enum**, not sealed — M19 owns the machine |
| Dialog instantiation | `flutter-accelerator-ai/lib/view_models/game/reducer/game_reducer_session_flow.dart` — reducer constructs `GameVictoryDialog`/`GameEndedDialog` with payloads | variants carry payloads; writing state is the reducers' job (M19) |

## 2. Diff summary (learner-app)

| File | Change |
|------|--------|
| `lib/view_models/menu/menu_ui_event.dart` → `menu_screen_ui_event.dart` | Renamed to senior filename; `abstract class MenuUiEvent` → `sealed class MenuScreenUiEvent` (senior name); doc updated — M13→M15 evolution + FR-15 convergence |
| `lib/view_models/menu/menu_view_model.dart` | Import + `StreamController<MenuScreenUiEvent>` / `Stream<MenuScreenUiEvent>` type rename |
| `lib/screens/menu_screen.dart::_handleUiEvent` | `if (event is A) … else if (event is B)` → exhaustive `switch` statement with object pattern `MenuSnackBarRequested(:final message)` — senior-identical shape |
| `lib/data/game/game_session_state.dart` → `game_session_state_data.dart` | Renamed to senior filename; added `sealed class GameDialogState` + `final class GameDialogHidden`, `GameEndedDialog({required GameEndReason reason})`, `GameVictoryDialog`; `GameEndReason` enum trimmed `{wrongAnswer, timeout}` (victory now its own variant, matching senior split) |
| `lib/screens/game_screen.dart` | `GameEndReason? _endReason` → `GameDialogState _dialogState = const GameDialogHidden()`; `_finish(GameDialogState)` takes the variant; `won:` → `dialog is GameVictoryDialog`; `_dialogTitle`/`_resultText` → `switch` expressions with `(:final reason)` payload destructuring + inner enum switch; title color → `switch` with wildcard `_`; `showDialog` mechanism unchanged (M21 owns in-Stack layer) |
| `test/sealed_state_test.dart` | NEW — 5 tests: payload carriage, exhaustive `switch` over both hierarchies, `is` on sealed type |
| `test/menu_view_model_test.dart` | Import rename only |

## 3. Senior ↔ learner correspondence (per hierarchy)

| Senior | Learner | Fidelity |
|--------|---------|----------|
| `sealed class MenuScreenUiEvent` + 2 `final class` | **identical** name + shape + sealed/final pairing | `DIRECT_EVIDENCE` |
| `_handleUiEvent` switch statement + `(:final message)` | identical shape | `DIRECT_EVIDENCE` |
| `sealed class GameDialogState` (9 variants) | `sealed class GameDialogState` (3 variants: Hidden/Ended/Victory) | `TEACHING_SIMPLIFICATION` — subset matches real learner UX; ladder/confirm/explanation/lifeline variants land with their features (M19–M21) |
| `GameEndedDialog(earnedAmount)` | `GameEndedDialog(reason)` | `TEACHING_SIMPLIFICATION` — no money ladder until M19; `reason` payload preserves learner UX semantics |
| `GamePhase` enum (6 values) | `GamePhase` enum (3 values) — **unchanged** | `ACTIVE_TEMPORARY` — FR-05 machine expansion is M19 |
| `GameDialogLayer` in-Stack + `ValueKey(runtimeType)` | `showDialog` route kept; sealed state picks *content* | `TEACHING_SIMPLIFICATION` → M21 |

## 4. Fidelity register processing

| Row | BEFORE | M15 CHANGE | SENIOR TARGET | STATUS |
|-----|--------|-----------|---------------|--------|
| FR-15 event dispatch | `abstract class` + `is`-chain | `sealed class MenuScreenUiEvent` + exhaustive `switch` | `MenuScreenUiEvent` sealed + switch | **CONVERGED** (pending Argus) |
| FR-07 game end UX | `GameEndReason` enum + 1 AlertDialog | sealed `GameDialogState` (3 variants) drives dialog content; `showDialog` kept | sealed state + in-Stack `GameDialogLayer` | **PARTIAL** — sealed types converged; layer is M21 |
| FR-05 game phases | `GamePhase{answering,revealing,finished}` | unchanged (senior is enum; sealed *dialog* types landed) | 6-phase machine | **ACTIVE_TEMPORARY** — M19 |

## 5. Command evidence (real output)

| Command | Result |
|---------|--------|
| `flutter analyze` (baseline, pre-M15) | `No issues found!` |
| `flutter test` (baseline) | `+69: All tests passed!` |
| `flutter build web` (baseline) | `√ Built build\web` (33.8s) |
| `flutter analyze` (post-impl) | `No issues found! (ran in 1.8s)` |
| `flutter test` (post-impl) | `+74: All tests passed!` (69 + 5 new sealed tests) |
| `flutter build web` (post-impl) | `√ Built build\web` (36.6s) |
| Exhaustiveness demo | Removed `GameDialogHidden()` case → `error - The type 'GameDialogState' isn't exhaustively matched by the switch cases … non_exhaustive_switch_expression` → case restored, analyze clean again |

## 6. Out of scope — not touched

- No `MenuDialogState`/`GameScreenUiEvent` in learner (no consumers yet — M16/M19/M21)
- No `AnimatedSwitcher`/`ValueKey(runtimeType)`/backdrop blur (M21)
- No `GamePhase` expansion, no reducer/VM for game (M19)
- No package changes
- Senior repo: read-only, `git status` clean — HEAD unchanged (verified below)

## 7. Known learner simplifications (registered)

| Simplification | Register row | Converges |
|----------------|--------------|-----------|
| 3-variant `GameDialogState` | FR-07 | M21 (full variant set + layer) |
| `reason` payload vs `earnedAmount` | FR-07 | M19/M22 |
| `showDialog` mechanism | FR-07 | M21 |

No unregistered deviations introduced.
