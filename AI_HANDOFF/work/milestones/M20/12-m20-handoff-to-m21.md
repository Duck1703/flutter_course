# M20 → M21 HANDOFF (long-run terminator — M21 NOT started)

## M20 verdict

**MILESTONE_COMPLETE** — see `11-final-verdict.md`.

## Architecture after M20

```
GameScreen (provider scope + stateful event bridge + PopScope)
   │  user intent: tap / back / dialog actions / feature taps
   ▼
GameScreenViewModel extends ChangeNotifier
   │  owns: 6-phase GamePhase machine · 30s Timer.periodic
   │        (pause/resume on dialogs only) · delayed reveal/
   │        explain flows · flowToken staleness · uiEvents stream
   │        · lifelines: handleFeatureClick → _canUseFeature
   │          (phase + usedFeatureButtons single-use) → mutation
   │        · simulated AI 700ms (loading→result in ONE dialog,
   │          token + `is!` stale guards)
   │        · walk-away → victory + resolvedResult{won:false}
   │        · resolvedResult end-state carrier (→M22)
   │        · GameSessionState (immutable, copyWith + clear* flags)
   │        · sealed GameDialogState — 9 variants, 1:1 senior
   ▼
GameScreenPresentationMapper (pure)
   │  state + bank + visibleOptionTexts + audiencePercentiles +
   │  usedFeatureButtons + canWalkAway → GameScreenData
   │  (_buildAnswers reads visibleOptionTexts; _buildFeatureButtons
   │   derives isEnabled; exitGame NOT in bar)
   ▼
GameScreen renders screenData (context.watch)
   │  _GameFeatureBar (data-driven, FR-34 flat icons — SVG/
   │   CustomPainter → M28)
   │  dialogs: showDialog scaffold via _GameDialogHost
   │   (ListenableBuilder live-read — dialog body follows VM
   │    dialogState every notifyListeners)
   ▼
AppNavigationController (GlobalKey<NavigatorState>)
   │  context-free openGame/goBack; exit = vm.exitGame → goBack
```

## What M21 inherits (concrete deltas)

- **In-`Stack` `GameDialogLayer`** (senior
  `widgets/game/game_dialog_layer.dart`): replace the `showDialog`
  scaffold — `GameScreen` becomes `Stack` + `Positioned.fill`
  overlay layer rendering `vm.dialogState` directly; timer
  pause/resume already handled by VM on emit; `PopScope`/`canPop`
  semantics must be preserved (dialog open → pop dismisses dialog,
  not route). ALL 9 variants move into the layer unchanged.
- `_GameDialogHost`/`_dialogTitle`/`_dialogContent`/`_dialogActions`
  machinery is the migration surface — content/action mapping is
  already centralized there.
- Keep: `resolvedResult` interim carrier until M22 (VM-side
  `GameSaveResult` + `hasSavedResult`); DRE stays →M26.

## Registered deviations state at M20 close

| FR | State |
|----|-------|
| FR-03/FR-04 | ACTIVE_TEMPORARY → M22 (EXP basis, VM-side save) |
| FR-07 | ACTIVE_TEMPORARY → M21 (9-variant parity DONE; mechanism `showDialog`) |
| FR-32 | OPEN → M28 (onboarding visual/gating depth) |
| FR-33 | reserved — `GameShareResultEvent` unassigned |
| FR-34 | OPEN → M28 (lifeline IconData flat visuals vs SVG/CustomPainter) |

## Green state to preserve

`flutter analyze` clean · `flutter test` **147/147** ·
`flutter build web` pass · site **108 pages**.

## Senior baseline

`D:\vibe_coding\flutter\flutter-accelerator-ai` — `main @ c8eb860`,
clean, unchanged through M20.

## Gate

M21 must not begin until this handoff is recorded (done) and a new
explicit run request is issued. **Run ended at M20 per contract.**
