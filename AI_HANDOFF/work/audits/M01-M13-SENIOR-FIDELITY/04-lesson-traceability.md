# 04 — Lesson-Level Traceability (Lumen)

44 lessons audited (all `web/src/content/docs/m01–m13/**/*.md` excluding
`index.md` files; index pages + `roadmap.md` audited by Forge in 08).

For each lesson: senior concept represented → senior evidence →
classification. Classification set: `DIRECT MATCH` ·
`VALID SIMPLIFICATION` · `DEVIATION` · `UNVERIFIED`.

## M01 — Flutter orientation & first run

| Lesson | Senior concept | Evidence | Classification |
|---|---|---|---|
| 01 flutter/dart/project | app anatomy, target platforms | senior `android/ ios/ web/` shells + `lib/` layout | VALID SIMPLIFICATION (platforms trimmed, stated) |
| 02 main/runApp/widget tree | `main()` → `runApp` → `MaterialApp` skeleton | `lib/main.dart`; lesson explicitly defers `theme`, `navigatorKey`, l10n, Supabase awaits ("senior cần vì khởi tạo Supabase/repositories") | VALID SIMPLIFICATION |
| 03 hot reload/tooling | analyze/test/build toolchain | senior `analysis_options.yaml`, same commands | DIRECT MATCH |

## M02 — Menu layout & tokens

| Lesson | Senior concept | Evidence | Classification |
|---|---|---|---|
| 01 constraints | layout model; Stack/Column/Expanded | `menu_screen_view.dart` Stack+Column+Expanded verified | DIRECT MATCH |
| 02 khung màn hình | header/content/CTA regions | `MenuScreenView` division — "giống hệt" claim verified accurate | DIRECT MATCH |
| 03 header & cards | card composition | `menu_profile_header.dart`, `level_progress_card.dart`, `earnings_card.dart`; visual simplifications labelled | VALID SIMPLIFICATION |
| 04 CTA + completion | `GradientCtaButton`, stats/leaderboard rows | `gradient_cta_button.dart`, `stats_card.dart`, `leaderboard_entry_card.dart`; lesson states hardcoded `'0'`/`'—'` are placeholders ("DO NOT ASSUME: số liệu… là dữ liệu thật — senior truyền từ game") | VALID SIMPLIFICATION |

## M03 — StatefulWidget & setState

| Lesson | Senior concept | Evidence | Classification |
|---|---|---|---|
| 01 stateless-vs-stateful | StatefulWidget for view-local state | **CLAIM DEFECT:** lesson says "menu của senior cũng là `StatefulWidget` với `_MenuScreenState` (giữ overlay/dialog state)". Actual senior: `MenuScreen extends StatelessWidget`; statefuls are `MenuScreenView` (holds only `_dialogDismissLocked`) and `_MenuScreenEventBridge`; `dialogState` lives in `MenuScreenViewModel` → **DEVIATION** (FD-01, MISLEADING_TEACHING, MEDIUM) |
| 02 setState & rebuild | `setState` mechanics | claim "senior gọi setState cho overlay/dialog local" verified (`MenuScreenView._setDialogDismissLocked`) | DIRECT MATCH |
| 03 lifecycle & ownership | initState/dispose, owner-disposes | senior VMs cancel subs in dispose; `State.dispose` rules correct | DIRECT MATCH |

## M04 — Immutable model

| Lesson | Senior concept | Evidence | Classification |
|---|---|---|---|
| 01 model & null safety | `UserProfileData` shape | senior file cited; missing fields (`totalEarnings`, `totalQuestionCount`, `fromMap`/`toMap`→M10, `LevelConfig` cap→M22) **explicitly listed**; `expForNextLevel` declared simplification | VALID SIMPLIFICATION |
| 02 copyWith & equality | copyWith/`==`/`hashCode` trio | senior impl identical pattern; lesson correctly explains senior relies on `!=` for `shouldNotify` in repo/VM | DIRECT MATCH |
| 03 nối model vào menu | model-backed UI | demo defaults honestly framed ("hồ sơ khách y hệt các con số menu đang hiển thị"); gainExp-on-tap labelled temp | VALID SIMPLIFICATION |
| 04 unit test đầu tiên | pure-Dart VM/model tests | mirrors senior `test/` conventions | DIRECT MATCH |

## M05 — Future & async bootstrap

| Lesson | Senior concept | Evidence | Classification |
|---|---|---|---|
| 01 Future/async/await | Future semantics | senior `main` awaits described accurately | DIRECT MATCH |
| 02 FutureBuilder | async gating UI | `onboarding_overlay_scope.dart` `FutureBuilder<bool>` + `snapshot.data ?? …` verified; demo loader labelled temporary (M10/M14) | VALID SIMPLIFICATION |
| 03 async main | `Future<void> main() async` + `ensureInitialized` | senior main verified; awaits deferred explicitly | VALID SIMPLIFICATION |

## M06 — Streams

| Lesson | Senior concept | Evidence | Classification |
|---|---|---|---|
| 01 stream là gì | Stream vs Future; cold/hot | senior `ValueStream` cited as M14 target | DIRECT MATCH |
| 02 StreamBuilder trong menu | StreamBuilder consumption | senior `initialData: stream.value` claim verified vs `onboarding_overlay_scope.dart`; ticker labelled teaching source | VALID SIMPLIFICATION |
| 03 listen/cancel/StreamController | manual subscription lifecycle | senior VMs subscribe-in-ctor/cancel-in-dispose verified; broadcast-no-buffer claim verified | DIRECT MATCH |

## M07 — Navigation primitives

| Lesson | Senior concept | Evidence | Classification |
|---|---|---|---|
| 01 route stack & push | `Navigator.push(MaterialPageRoute)` | senior controller wraps same primitive; "app senior không bao giờ quá hai route" accurate | DIRECT MATCH |
| 02 GameScreen & pop | pushed route + back | senior uses `GameScreenTopBar` + `PopScope`+confirm-exit — deferred, lesson says M21 | VALID SIMPLIFICATION |
| 03 senior-navigation-checkpoint | `AppNavigationController` deep-read | quotes real file; `navigatorKey`/`canPop`/void-route claims all verified; explicit "M19 sẽ đưa pattern này vào" | DIRECT MATCH |

## M08 — Quiz model & rendering

| Lesson | Senior concept | Evidence | Classification |
|---|---|---|---|
| 01 QuizQuestion model | `GameQuizQuestionData` | subset labelled; missing fields named; "thêm trường cho giống senior là phạm quy tắc" | VALID SIMPLIFICATION |
| 02 quiz state & enum | `GamePhase`/`GameDialogState` enums→sealed | senior 6-phase enum quoted verbatim; sealed→M15 stated | VALID SIMPLIFICATION |
| 03 render options & flow | answer list rendering | senior `game_answer_option*.dart` cited accurately | DIRECT MATCH |
| 04 widget test đầu tiên | `testWidgets` convention | senior widget tests exist (verified dir) | DIRECT MATCH |

## M09 — Game session loop

| Lesson | Senior concept | Evidence | Classification |
|---|---|---|---|
| 01 GamePhase & Timer | phase enum + countdown | 6-vs-3 phases + **30s-vs-15s** both stated verbatim; `Timer.periodic` is senior's real mechanism | VALID SIMPLIFICATION |
| 02 phase flow | phase machine transitions | "senior có tầng đó (reducer/MVI)" directionally correct (M26); money ladder noted as senior-only | DIRECT MATCH |
| 03 showDialog & popUntil | end-of-game dialog + multi-pop | lesson states senior uses overlay dialogs (not routes); `popUntil` honestly described as learner-scale choice | VALID SIMPLIFICATION |
| 04 test game session | game-flow widget tests | senior test conventions cited | DIRECT MATCH |

## M10 — Persistence & result flow

| Lesson | Senior concept | Evidence | Classification |
|---|---|---|---|
| 01 SharedPreferences & ProfileStore | profile persistence | same `'user_profile'` key + `StateError`-on-false verified; interface+`BehaviorSubject` diff stated → M14 | DIRECT MATCH |
| 02 JSON toMap/fromMap | JSON serialization + defensive parse | senior helper pattern verified; deeper guards (`>=0`, nonempty, `_moneyFromDisplay`, legacy-purge) not yet introduced | DIRECT MATCH (senior-depth nuance → FD-04 LOW part) |
| 03 GameResult qua pop() | route-result mechanism | **explicitly states senior does NOT use route-result**; cites `…_result_persistence.dart`; maps M12/M14 convergence | VALID SIMPLIFICATION |
| 04 áp kết quả & reset | result policy + reset | `_saveGameResult` 3-step shape verified (`load → apply → save`); flat ladder labelled temp → M20/M22; **reset button not framed as senior-UI** (senior resets via sign-out — lesson omits this) → contributes FD-02/FD-09 | VALID SIMPLIFICATION (labelling partial) |

## M11 — ChangeNotifier & VM extraction

| Lesson | Senior concept | Evidence | Classification |
|---|---|---|---|
| 01 vì sao setState không scale | VM extraction rationale; `MenuLoadState` | "senior làm đúng [compare-before-notify]" verified (`shouldNotify`); `MenuLoadState` is a course vehicle — senior has none (stream-seeded) | DIRECT MATCH (own rationale) / contributes FD-06 |
| 02 notifyListeners & ListenableBuilder | `ChangeNotifier` mechanics | "senior không gọi ListenableBuilder trực tiếp — đi thẳng qua context.watch" verified | DIRECT MATCH |
| 03 sở hữu VM & test | VM ownership/dispose | senior VM `StreamController` ownership claim verified | DIRECT MATCH |

## M12 — Provider & DI scope

| Lesson | Senior concept | Evidence | Classification |
|---|---|---|---|
| 01 InheritedWidget & lookup | provider mechanism | senior `MultiProvider`×8 verified verbatim | DIRECT MATCH |
| 02 read vs watch | `context.read`/`watch` split | senior usage verified (bridge reads, build watches) | DIRECT MATCH |
| 03 ChangeNotifierProvider & scope | screen-scoped VM provider | senior `MenuScreen→ChangeNotifierProvider(create:read repos..loadUserProfile())` shape verified identical | DIRECT MATCH |

## M13 — UI events (deep audit)

| Lesson | Senior concept | Evidence | Classification |
|---|---|---|---|
| 01 event không phải state | event≠state semantics | sealed-vs-abstract diff labelled →M15; "senior cho cùng lý do [broadcast]" verified | DIRECT MATCH |
| 02 event bridge trong State | `_MenuScreenEventBridge` lifecycle | subscribes in `didChangeDependencies`, `==` guard, cancel-old, dispose-cancel — all verified identical; **structural diff honestly recorded**: senior bridge = dedicated widget + nav controller; learner = inside `_MenuScreenView` + direct push (D20; M19/M29) | DIRECT MATCH |
| 03 snackbar event & test | `MenuSnackBarRequested` handling | handler code verified identical to senior's `ScaffoldMessenger` branch; **omission**: doesn't note senior never emits this event from `MenuScreenViewModel` (dialog VMs emit own types) → FD-09 LOW | VALID SIMPLIFICATION |

## Counts

```
TOTAL LESSONS:          44
DIRECT MATCH:           25
VALID SIMPLIFICATION:   18
DEVIATION:               1  (m03/01 → FD-01)
UNVERIFIED:              0
```

## Danger-phrase scan result

Grepped all lessons for `giống hệt` / `y hệt` / `y chang` / `senior cũng làm` /
`chính là cách senior` / `đúng như senior` / `1:1`. ~57 hits reviewed in
context. Findings:

- **No** instance claims learner code equals senior where it doesn't.
- Most hits are learner-internal comparisons ("y hệt M03") or verified
  accurate senior claims (`MaterialPageRoute<void>` y hệt; `StateError` y
  hệt; `MenuScreenView` division giống hệt).
- The single false-parity claim is m03/01 (FD-01).

## Android/Compose analogy audit

Sampled every milestone's bridge block. Pattern is consistently correct:
SIMILARITY/IMPORTANT DIFFERENCE/DO NOT ASSUME trio. Verified non-distorting
examples: `Stream`≠`Flow` cold/hot caveat (m06/01); `pop(result)`≈
`setResult+finish` with "kết quả đi theo route pop" diff (m10/03);
broadcast≈SharedFlow with manual-cancel caveat (m13 index). No analogy
steers away from the senior implementation — all point *toward* it.
