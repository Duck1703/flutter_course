# 07 — Architecture Convergence Audit (Atlas)

For every major subsystem: current learner form → senior form → intermediate
difference → planned convergence → risk. Source: `MILESTONE_ROADMAP.md`
M14–M29 + `CURRICULUM_TRACEABILITY.md` + decisions D18/D20/D22 + impl notes.

## Subsystem progression map

### BOOTSTRAP (`main.dart`)

| | |
|---|---|
| Current learner | async main → `ensureInitialized` → `ProfileStore` → `AppDependencyScope` → `MaterialApp(home: MenuScreen)` |
| Senior | ensureInitialized → **portrait lock** → Supabase env+init → create 8 deps → `AppDependencyScope` → `MaterialApp(navigatorKey, l10n delegates, locale-from-settings-stream)` |
| Intermediate diff | 7 deps, nav key, l10n, Supabase, orientation all missing |
| Planned convergence | M14 repos · M16 settings · M17 l10n+locale stream · M19 navigatorKey · M23 Supabase · M29 audit |
| RISK | **portrait lock has no owner** (FD-07 LOW); otherwise complete |

### DEPENDENCY INJECTION

| | |
|---|---|
| Current learner | `AppDependencyScope` → single `Provider<ProfileStore>.value` |
| Senior | `MultiProvider` × 8, all `Provider.value` (deps created in `main`) |
| Diff | count + interfaces (`ProfileStore` concrete vs `UserProfileRepository` contract) |
| Convergence | M14 contract+repo entries; M16 settings repo; M19 nav controller; M23–M25 auth/leaderboard/sync; M27 notification svc |
| RISK | none — direction correct and same `.value` style as senior |

### PROFILE / PERSISTENCE

| | |
|---|---|
| Current learner | concrete `ProfileStore` (load/save/clear); VM calls it imperatively; `loadState` UI |
| Senior | `abstract interface class UserProfileRepository` + `BehaviorSubject<UserProfileData>.seeded` `ValueStream`; VM subscribes; `resetUserProfile` = write-default |
| Diff | no contract, no stream, imperative load/apply/reset methods; `clear()` removes key vs senior write-default |
| Convergence | **M14 explicitly**: refactor ProfileStore→repository contract+impl, BehaviorSubject, VM subscribes, fakes for tests |
| RISK | field-set parity (`totalQuestionCount`, `totalEarnings`, drop `expForNextLevel`, defaults) not explicitly in M14 scope text → FD-04; `clear` vs write-default semantic → FD-05 |

### STATE MANAGEMENT (menu)

| | |
|---|---|
| Current learner | `MenuViewModel` owns `_profile`+`MenuLoadState`; methods `load/applyGameResult/resetProfile` |
| Senior | `MenuScreenViewModel` subscribes to `userProfileStream`+`authStateStream`; state arrives via streams; `loadUserProfile()` kicks repos; dialog state + compare-before-notify |
| Diff | pull-model vs push-model; invented `MenuLoadState`; no auth stream/dialog state yet |
| Convergence | M14 stream subscription (loadState collapses — implicit); M15/M16/M24 dialog+auth state; M29 menu dialog layer |
| RISK | `MenuLoadState`/`failed` UI becomes unnecessary at M14 — removal implicit only → FD-06 |

### STATE MANAGEMENT (game)

| | |
|---|---|
| Current learner | `StatefulWidget` setState, `GamePhase`(3)+`GameEndReason`, `Timer.periodic` |
| Senior | `DreChangeNotifier<GameState,GameAction,GameEffect,GameAsyncOp>` + pure reducer + effects + async ops + token guards |
| Diff | entirely different control plane (deliberate) |
| Convergence | M19 structured VM (`GamePhase` parity, timer, ladder, presentation mapper) → M20 lifelines → M21 dialog layer → M22 persistence → **M26 DRE refactor** |
| RISK | none — graduated path is the roadmap's core design; M19 scope explicitly lists `AppNavigationController` parity + `PopScope` |

### NAVIGATION

| | |
|---|---|
| Current learner | direct `Navigator.push/pop`; `pop(result)` route-result; free back |
| Senior | `AppNavigationController` (`navigatorKey`, `openGame`, guarded `goBack`); game `PopScope(canPop:false)`+confirm-exit; `GameNavigateToMenuEvent`→`goBack()` |
| Diff | no controller, no PopScope, results via route pop not repo write |
| Convergence | M19 controller parity + PopScope intro; M21 full back-handling; M22 save-in-VM removes route-result |
| RISK | none — m07/03 lesson literally reads the senior controller file |

### EVENTS (M13 deep)

| | |
|---|---|
| Current learner | `MenuUiEvent` abstract + `MenuGameRequested` + `MenuSnackBarRequested(message)`; broadcast controller; bridge inside `_MenuScreenView` |
| Senior | `sealed MenuScreenUiEvent` + same two events; broadcast controller on VM; dedicated `_MenuScreenEventBridge` widget; emits `MenuGameRequested` only (snackbar emitted by dialog VMs, own types) |
| Diff | sealed (M15) · bridge host (D20, M29) · dispatch target = direct push vs nav controller (M19) · snackbar emit site is course-invented (FD-09) |
| Convergence | M15 seal events; M19 nav controller; M24 dialog-scoped events; M29 bridge-form parity |
| RISK | low — mechanism identical, all diffs mapped |

### STREAMS

| | |
|---|---|
| Current learner | `Stream.periodic` ticker (demo), broadcast event streams, `StreamBuilder` |
| Senior | `BehaviorSubject`/`ValueStream` everywhere (repos), `StreamBuilder` at onboarding/locale, VM subscriptions |
| Convergence | M14 rxdart `ValueStream`+`.value`+`isClosed` — explicit |
| RISK | none |

### DIALOGS

| | |
|---|---|
| Current learner | `showDialog`+`AlertDialog` (game result only); no menu dialogs |
| Senior | sealed `GameDialogState`/`MenuDialogState` → in-Stack layers with `AnimatedSwitcher`, blur backdrop, `PopScope` choreography, dismiss-lock |
| Convergence | M15 sealed states → M21 game layer → M29 menu layer — explicit |
| RISK | none |

### MENU FEATURES

| | |
|---|---|
| Current learner | +sound toggle, +tap counter, +session ticker, +reset button (all labelled scaffolds); −settings tap, −account tap, −leaderboard dialog tap, −dialog layer, −onboarding overlay |
| Senior | header w/ account+settings; LevelProgressCard, EarningsCard, tappable LeaderboardEntryCard, StatsCard, CTA, dialog layer, onboarding overlay |
| Convergence | M16 settings (real persisted sound switch), M18 onboarding, M23 leaderboard dialog, M24 auth, M29 parity pass |
| RISK | **removal of the four scaffolds is never explicitly scheduled** → FD-02 MEDIUM |

### QUESTIONS / GAME DATA

| | |
|---|---|
| Current learner | `QuizQuestion{question,options,correctIndex}`, 4 const questions |
| Senior | `GameQuizQuestionData{id,question,options,correctOption:String,category,language,difficulty,explanation{...}}`, `gameSampleQuestions` bank, `gameMoneyLadderLevels` |
| Convergence | M19 ladder+mapper; M20 explanation/poll/AI data; full question shape never explicitly listed (FD-11 LOW) |
| RISK | low |

## Convergence completeness check

Every labelled simplification traced to ≥1 explicit roadmap milestone **except**:

| Simplification | Gap | Severity |
|---|---|---|
| Portrait orientation lock | acknowledged "wired later" (M01 note), no owning milestone | LOW (FD-07) |
| Menu scaffolds removal (sound toggle, tap counter, ticker, reset) | implicit M16/M24/M29 catch-alls only | MEDIUM (FD-02) |
| `MenuLoadState` + loading/error UI | implicit removal at M14 | MEDIUM (FD-06) |
| `UserProfileData` field/defaults parity | implicit via M14+M22 | MEDIUM (FD-04) |
| `GameQuizQuestionData` full shape | implicit via M19/M20 | LOW (FD-11) |
| `clear()`→write-default reset semantics | implicit via M14 | LOW (FD-05) |
| `demo_profile_loader` removal from lib/ | none | LOW (FD-03) |
| M09 roadmap scope items unshipped | roadmap text unamended; impl notes + D18 record reality | MEDIUM (FD-12) |

**Verdict input:** roadmap does return every major subsystem to senior form;
gaps are *explicitness* gaps, not direction gaps. No subsystem terminates at
a course-only design.
