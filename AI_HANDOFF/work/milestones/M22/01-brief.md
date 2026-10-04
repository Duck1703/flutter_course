# M22 BRIEF — Result Persistence & Level Progression

Milestone: **M22** | Author: Atlas | Date: Step-17 long run, day 2
Status requested: `BRIEF_READY` → Flux implementation.

Roadmap section: `project-context/MILESTONE_ROADMAP.md` —
"M22 — Result persistence & level progression" (lines ~1297–1340).

---

## 0. Baseline (verified before writing)

- Learner app: `flutter analyze` clean, `flutter test` **157/157**,
  `flutter build web` PASS. Website `npm run build` **114 pages**.
- Senior: `main @ c8eb860`, `git status` clean — read-only.
- M21 closed at `MILESTONE_COMPLETE`; all M21 artifacts on disk.

---

## 1. SENIOR FIDELITY CHECK

### Senior target

Result persistence lives **inside the game VM's async boundary**, not in
route transport: each of the 4 terminal transitions emits a
`GameSaveResult` async op exactly once (guarded by
`GameState.hasSavedResult`); the VM's `_saveGameResult` applies profile
mutations (money, EXP→level via `LevelConfig`, stats) and saves through
`UserProfileRepository`; the menu rebuilds off the repository stream —
no result is ever returned through `Navigator.pop`.

### Senior files/symbols (all inspected live at c8eb860)

| File | Symbols |
|------|---------|
| `lib/view_models/game/dre/game_dre_async_op.dart` | `GameSaveResult extends GameAsyncOp` — payload `{earnedAmount:int, isWin:bool, questionCount:int}` |
| `lib/view_models/game/dre/game_dre_state.dart` | `GameState.hasSavedResult:bool` — idempotence flag, `copyWith`ed |
| `lib/view_models/game/reducer/game_reducer_session_flow.dart` | `_withSaveResult(state,{earnedAmount,isWin,effects})`: if `hasSavedResult` → state+effects only; else `hasSavedResult:true` + `asyncOp: GameSaveResult(earnedAmount, isWin, questionCount: state.questionIndex + 1)` |
| same file | 4 call sites — `_loadNextQuestionOrVictory` nhánh victory: `earnedAmount=moneyEarned, isWin=true`; `_endGame`: `earnedAmount=guaranteedAmount, isWin=false`; `_confirmWalkAway`: `earnedAmount=_walkAwayAmount(state), isWin=false`; `_backToMenu`: `earnedAmount=_walkAwayAmount(state), isWin=false` |
| `lib/view_models/game/reducer/game_reducer.dart` | `_walkAwayAmount(state) = calculateGameWalkAwayAmount(guaranteedAmount, moneyEarned)` |
| `lib/view_models/game/bridge/game_screen_view_model_result_persistence.dart` | `_saveGameResult(GameSaveResult)`: `loadUserProfile()` → `nextMoneyWon = totalMoneyWon + earnedAmount` → `_applyLevelProgression(profile, gainedExp: earnedAmount)` → `copyWith(totalEarnings: formatVnd(nextMoneyWon), totalMoneyWon: nextMoneyWon, gamesJoined+1, gamesWon + (isWin?1:0), totalQuestionCount + questionCount)` → `saveUserProfile` → `_syncSavedGameResult()`; whole body in try/catch → `debugPrint` |
| same | `_syncSavedGameResult()`: loads auth state → syncs via `profileSyncRepository` ONLY if authenticated; guests skip; failures caught+logged. **M25 scope — learner keeps a documented stub** (roadmap: "keep a stub branch `if authed`") |
| same | `_applyLevelProgression({profile, gainedExp})`: `level = _normalizedLevel(profile.level)`; `exp = currentExp + gainedExp`; `while (level < maxLevel && exp >= getExpRequiredForLevel(level)) { exp -= required; level++; }`; cap at `maxLevel` → `profile.copyWith(level, currentExp: exp)` |
| same | `_normalizedLevel(int)` = `clamp(minLevel, maxLevel)` |
| `lib/data/game/level_config.dart` | `baseExp=30000`, `growthPerLevel=5000`, `minLevel=1`, `maxLevel=100`; `milestoneMultipliers={5:1.5,10:1.5,15:1.5,20:3,30:2,40:3,50:2,60:3,70:2,80:2,90:4,100:5}`; `getExpRequiredForLevel(level)` = `(baseExp + growthPerLevel*level) * multiplier(level+1)` (0 below min); `getCumulativeExpForLevel`, `getMilestoneMultiplier`, `isMilestoneLevel`, `isMajorMilestone`, `maxExpRequirement` |
| `lib/view_models/menu/menu_level_progress.dart` | `MenuLevelProgress.fromProfile(profile)` — derived view: `level`, `currentExp`, `requiredExp`, `nextLevel`, `remainingExp`, `ratio` (clamped 0..1), `isMaxLevel`, `tier` (`MenuLevelTier.base/milestone/major`), `formattedCurrentExp`/`formattedRequiredExp`/`formattedRemainingExp` via `formatThousands` |
| `lib/data/profile/user_profile_data.dart` | 9 fields: `username, level, totalEarnings(String), currentExp, totalQuestionCount, totalMoneyWon, gamesJoined, gamesWon, avatarUrl` — **NO `expForNextLevel`, NO `expPercent`, NO `gainExp`, NO `applyGameResult`**; `formatVnd`/`formatThousands` statics |
| `lib/widgets/menu/profile/level_progress_card.dart` | `LevelProgressCard` — glass card + `_LevelDial` ring + experience bar + `menuExpToNextLevel`/`menuMaxLevelReached`. **Visual depth (ring dial, glow, tier gradients) = M28 scope; M22 adopts the data (`MenuLevelProgress`) + keeps learner's simple bar** |
| `lib/screens/game_screen.dart` | `GameScreenViewModel(userProfileRepository: context.read<UserProfileRepository>(), authRepository:…, profileSyncRepository:…)..startNewGame()` |
| `test/level_config_test.dart` | 7 tests: zero-below-min, base calc (L1=35000), milestone (L4→75000), major milestone (L19→375000), max cap (L100/L101=maxExpRequirement), cumulative sum, multiplier helpers |
| `test/widgets/menu_level_progress_card_test.dart` + `test/widgets/game_screen_result_flow_test.dart` | progression-view tests + end-to-end save-flow widget tests |

### Current learner form

- **Transport:** `GameResult{questionsAnswered, correctAnswers, won,
  earnedAmount}` built by VM (`resolvedResult` state field +
  `buildGameResult()`), `Navigator.pop(result)` via
  `AppNavigationController.openGame<GameResult>()`,
  `MenuScreen._openGame()` awaits it, `MenuViewModel.applyGameResult()`
  saves — **menu owns persistence** (FR-04 scaffold).
- **Progression:** `UserProfileData.applyGameResult` → `gainExp(
  correctAnswers * expPerCorrectAnswer(=50))` — wrong basis (senior:
  `earnedAmount`) — and a learner-only **1.5× cap-growth** curve on
  `expForNextLevel` (FR-01, FR-03 scaffolds).
- **No duplicate-save guard** (route pop happens once; flag unneeded
  so far — `hasSavedResult` comment already reserved in state file).
- `UserProfileData` extra members: `expForNextLevel` field (default
  35000, serialized in `toMap`/`fromMap`), `expPercent`, `gainExp`,
  `expPerCorrectAnswer`, `applyGameResult`. `winRateDisplay` and
  `formatVnd`/`formatThousands` already senior-shaped → keep.
- Menu exp UI (`menu_screen.dart` ~360–415): `profileLevel` ("CẤP
  {level}") + `menuExpProgress("{exp} / {maxExp} EXP")` + two-`Expanded`
  flex bar driven by `expPercent` ints.
- `GameScreenViewModel` ctor takes only `{questions}` — no repository
  dependency; `game_screen.dart` provides `GameScreenViewModel()`.
- `FakeUserProfileRepository` (test/helpers) already exposes
  `saveCallCount`/`loadCallCount`/`value` — reusable.

### Fidelity rows owned by M22

| Row | Item | Action |
|-----|------|--------|
| FR-01 | `expForNextLevel` stored field | **CONVERGE** — drop field; cap derives from `LevelConfig` |
| FR-03 | EXP basis `correctAnswers*50` + 1.5× curve | **CONVERGE** — EXP = `earnedAmount`; milestone-multiplier table |
| FR-04 | Route-result transport / menu-side save | **CONVERGE** — VM-side save once; transport retired |
| FR-19 note | `expPercent` display getter | retire with FR-01 (menu uses `MenuLevelProgress.ratio`) |

Note: senior ctor also requires `authRepository` + `profileSyncRepository`
— learner defers both to M24/M25 (registered under FR-04 note / auth
rows). The stub `_syncSavedGameResult` carries a `// M25` marker.

---

## 2. IMPLEMENTATION SCOPE (Flux)

### A. New files (senior ports, verbatim where legal)

1. `lib/data/game/level_config.dart` — verbatim port (constants, table,
   `getExpRequiredForLevel`, `getCumulativeExpForLevel`,
   `getMilestoneMultiplier`, `isMilestoneLevel`, `isMajorMilestone`,
   `maxExpRequirement`). Vietnamese doc comments explaining the table.
2. `lib/view_models/menu/menu_level_progress.dart` — verbatim port
   (`MenuLevelTier` + `MenuLevelProgress.fromProfile` + ratio/formatted
   getters). Uses `UserProfileData.formatThousands`.

### B. `GameSessionState` + VM — the save boundary

3. `game_session_state_data.dart`: add `hasSavedResult` (default false,
   `copyWith`ed, reset in `initial`); **remove** `resolvedResult` field
   + its `GameResult` import.
4. `game_screen_view_model.dart`:
   - ctor: `required this.userProfileRepository` (+ keep
     `questions`); field type `UserProfileRepository`.
   - new private `_withSaveResult`-equivalent: the 4 terminal
     transitions gain a guarded save call. Learner has no DRE queue, so
     the equivalent is a VM helper: at each terminal `copyWith`, if
     `!_state.hasSavedResult` → set `hasSavedResult: true` in the same
     transition + `unawaited(_saveGameResult(earnedAmount:…, isWin:…,
     questionCount: _state.questionIndex + 1))` — payload per senior
     table (victory=`moneyEarned`/true; gameOver=`guaranteedAmount`/
     false; walkAway=`_walkAwayAmount`/false; backToMenu=
     `_walkAwayAmount`/false). `questionCount` reads the PRE-transition
     `questionIndex + 1` — same as senior (`state.questionIndex` before
     copyWith).
   - port `_saveGameResult`, `_applyLevelProgression`, `_normalizedLevel`
     verbatim into the VM file (learner keeps single-VM-file
     convention; if the VM exceeds ~700 LOC a bridge file is
     acceptable — judge at implementation).
   - `_syncSavedGameResult()` — documented no-op stub (`// M25:` comment),
     invoked after `saveUserProfile` inside the same try block —
     preserves senior call shape.
   - retire `buildGameResult()` + `GameResult` constructions at the 4
     sites + `import game_result.dart`.
5. `user_profile_data.dart`: drop `expForNextLevel` (ctor param,
   `toMap`/`fromMap`, `copyWith`, doc), `expPercent`, `gainExp`,
   `expPerCorrectAnswer`, `applyGameResult`, `GameResult` import. Keep
   `winRateDisplay`, `formatVnd`, `formatThousands`. Old persisted maps
   containing `expForNextLevel` are tolerated by `fromMap` (ignore key).
   Check `profile_store.dart` for any field reference.

### C. Transport retirement

6. `game_result.dart` — **delete file**.
7. `app_navigation_controller.dart`: `openGame()` → `Future<void>`
   (`_push` untyped / `MaterialPageRoute<void>`).
8. `game_screen.dart`: `goBack()` without arg; VM provision
   `GameScreenViewModel(userProfileRepository: context.read<
   UserProfileRepository>())..startNewGame()`.
9. `menu_screen.dart`: `_openGame()` → `await _navigation.openGame();`
   (no result, no `applyGameResult` call). Menu already rebuilds on the
   repository `ValueStream` — the senior "stream is truth" flow.
10. `menu_view_model.dart`: delete `applyGameResult` (+ `GameResult`
    import).

### D. Menu progression UI

11. `menu_screen.dart` exp block: `MenuLevelProgress.fromProfile(
    profile)` — `menuExpProgress` key fed `formattedCurrentExp` /
    `formattedRequiredExp` (values are Strings now — update ARB
    placeholder types if the analyzer requires); flex bar →
    `(progress.ratio * 100).round()` / complement, guard `0`/`100`
    edges; `profileLevel` stays. Do NOT add the senior
    `menuExpToNextLevel`/`menuMaxLevelReached`/`LevelProgressCard`
    visuals — M28. Keep `winRateDisplay` row as-is.

### E. Tests

12. `test/level_config_test.dart` — port senior's 7 tests verbatim
    (package `ai_millionaire_course`).
13. `test/menu_level_progress_test.dart` — new: fromProfile mapping,
    ratio clamp [0,1], `isMaxLevel`, tier boundaries, formatted getters
    (dot grouping), remaining/nextLevel.
14. `test/game_screen_view_model_test.dart` — update all ctor sites to
    inject `FakeUserProfileRepository`; replace `buildGameResult` group
    with save-flow tests:
    - victory saves once (`earnedAmount=moneyEarned`, `isWin=true`,
      `questionCount`=reached index+1);
    - wrong-answer game over saves `guaranteedAmount`, `isWin=false`;
    - `confirmWalkAway` saves `_walkAwayAmount`, `isWin=false`;
    - `backToMenu` twice → still one save (`hasSavedResult`);
    - playAgain → new session resets flag (second save fires);
    - profile deltas: moneyWon/earnings/gamesJoined/gamesWon/
      totalQuestionCount; EXP = earnedAmount; level rollover at
      threshold boundary; cap at 100.
15. `test/user_profile_data_test.dart` — remove `applyGameResult`/
    `gainExp`/`expForNextLevel` tests; keep ctor/serialization/winRate/
    format tests (update ctor sites dropping the field).
16. `test/widgets/game_screen_test.dart` + `menu_*` tests — inject repo
    into `GameScreenViewModel(questions:…)` ctor sites; update
    `openGame` expectations (no result); menu progress assertions now
    read `MenuLevelProgress`.
17. `test/menu_view_model_test.dart` — remove `applyGameResult` group.

### Out of scope (explicit)

- No `AuthRepository`/`UserProfileSyncRepository` ctor params (M24/M25).
- No real remote sync — stub only.
- No `LevelProgressCard` glass/dial visual port (M28) — menu keeps its
  current bar, data-driven by `MenuLevelProgress`.
- No DRE/async-op machinery (M26) — the save is a guarded `unawaited`
  VM call, documented as the M26 convergence point.

---

## 3. EXPECTED DELTA

- `flutter analyze` clean; `flutter test` all green — expected count
  lands ~160–170 (scaffold tests retire, ~20 new land). Record the real
  number; never a silent drop below what the retired-test math explains.
- `flutter build web` PASS; zero references to `GameResult`,
  `expForNextLevel`, `gainExp`, `applyGameResult`, `buildGameResult`,
  `resolvedResult`, `expPercent` in `lib/` (comments documenting
  convergence history may keep the terms with milestone tags).
- `hasSavedResult` present on `GameSessionState`; `unawaited(
  _saveGameResult…)` at exactly the 4 senior boundary sites.

---

## 4. CONTENT PLAN (Lumen) — 5 lessons, V2 template, Vietnamese

| # | Lesson | Checkpoint |
|---|--------|-----------|
| L01 | Kết quả là ghi-DB, không phải route-pop — save ownership trong VM, `hasSavedResult` idempotence, stream→menu | analyze clean |
| L02 | `LevelConfig` — bảng milestone-multiplier + `while` loop thăng cấp + port + unit tests | suite +11 |
| L03 | `MenuLevelProgress` + phẫu thuật `UserProfileData` + menu rewire | suite +N, analyze clean |
| L04 | VM-side save: repo injection, `_saveGameResult`, 4 guarded call-sites, xoá `GameResult` transport | suite +N |
| L05 | Regression tổng + parity + boundary M23 | full suite green |

Registry additions (proposed): **A-22** (VM-side async save boundary +
`hasSavedResult` idempotence), **D-38** (`LevelConfig` config-table
progression), **D-39** (`MenuLevelProgress` derived view-model). Verify
next free IDs before writing.

---

## 5. RISKS / WATCH-OUTS

- **Save timing vs navigation:** `backToMenu` pops immediately while the
  save runs fire-and-forget — same as senior. Tests must `await` a
  microtask/`pump` before asserting `saveCallCount`.
- **`questionCount` off-by-one:** `questionIndex + 1` = questions
  REACHED (not answered correctly). Document clearly in lessons.
- **Walk-away amount:** `_walkAwayAmount` (guaranteed-aware) — NOT raw
  `moneyEarned`. Reuse `calculateGameWalkAwayAmount`.
- **`fromMap` back-compat:** old stored JSON has `expForNextLevel` —
  ignore silently.
- **Ctor churn:** ~15 test ctor sites + provider site need
  `userProfileRepository:` — one mechanical pass.
- **`Expanded(flex:0)`:** ratio 0 → renders nothing; verify no layout
  exception in widget test.
- Vietnamese text in files must pass Windows encoding — author via
  script files, not inline heredocs.

---

## 6. GATE CHECKLIST

- [ ] Flux implementation → `02-implementation.md`
- [ ] Argus impl QA `PASS` → `03`
- [ ] Atlas `IMPLEMENTATION_APPROVED`
- [ ] Lumen 5 lessons + registry/graph → `04`
- [ ] Argus content QA `PASS` → `05`
- [ ] Atlas `CONTENT_APPROVED` → `06`
- [ ] Forge site integration + build → `07`
- [ ] Argus site QA `PASS` → `08`
- [ ] Atlas `SITE_APPROVED` → `09`
- [ ] Sequential replay from M21 clone → `10`
- [ ] Final verdict + canonical sync → `11`
- [ ] Handoff → `12`; **hard stop before M23**
