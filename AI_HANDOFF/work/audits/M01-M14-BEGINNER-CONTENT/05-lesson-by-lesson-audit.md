# 05 — Lesson-by-Lesson Audit (all 48 lessons)

Legend — Theory depth: S(strong)/A(adequate)/T(thin). Balance: BALANCED /
CODE_HEAVY / etc. Verdict: STRONG / ADEQUATE / NEEDS_EXPANSION /
MAJOR_CONTENT_GAP. Findings reference `12-content-gap-register.md` IDs.

## M01 — Flutter/Dart & first app

| Route | Concepts introduced | Concepts assumed | Depth | Mental model | Examples | Project expl. | Exercise | Prereq closure | Balance | Verdict | Findings |
|-------|--------------------|------------------|-------|--------------|----------|---------------|----------|----------------|---------|---------|----------|
| m01/01-flutter-dart-va-project-dau-tien | what Flutter is, Dart, project shape | none | S | good (framework framing) | yes | yes | self-check | closed | BALANCED | STRONG | — |
| m01/02-main-runapp-va-cay-widget | Widget, 3-tree, BuildContext, runApp | none | S | excellent (3 trees) | yes | yes | predict+check | closed | BALANCED | STRONG | — |
| m01/03-chay-app-hot-reload-va-tooling | hot reload vs restart, tooling | M01/02 | A | good | yes | yes | self-check | closed | BALANCED | STRONG | — |

## M02 — Layout & menu skeleton

| Route | Concepts | Assumed | Depth | MM | Ex | Proj | Exe | Prereq | Balance | Verdict | Findings |
|-------|---------|---------|-------|----|----|------|-----|--------|---------|---------|----------|
| m02/01-mo-hinh-constraints | constraint model | M01 | S | excellent | yes | yes | predict | closed | BALANCED | STRONG | — |
| m02/02-khung-man-hinh-menu | Scaffold/AppBar layout, required | M01 | A | good | yes | yes | check | closed | BALANCED | STRONG | — |
| m02/03-header-va-cac-the | Row/Col/Expanded, tokens | M02/01 | A | good | yes | yes | check | closed | BALANCED | STRONG | — |
| m02/04-nut-cta-va-hoan-thien-menu | CTA button, spacing, scroll | M02 | A | good | yes | yes | check | closed | BALANCED | STRONG | — |

## M03 — StatefulWidget & setState

| Route | Concepts | Assumed | Depth | MM | Ex | Proj | Exe | Prereq | Balance | Verdict | Findings |
|-------|---------|---------|-------|----|----|------|-----|--------|---------|---------|----------|
| m03/01-stateless-va-stateful | Widget-vs-State split, createState, GestureDetector, VoidCallback | M01–M02 | S | excellent (ownership table) | yes | yes | predict | closed | BALANCED | STRONG | scaffold flag (F-05 low) |
| m03/02-setstate-va-rebuild | setState semantics, closure | M03/01 | S | excellent ("signal not mutate") | yes | yes | predict | closed | BALANCED | STRONG | F-05 |
| m03/03-lifecycle-callbacks-va-state-ownership | initState/dispose, debugPrint, ownership | M03/02 | S | good | yes | yes | check | closed | BALANCED | STRONG | F-05 |

## M04 — Model, null-safety, first test

| Route | Concepts | Assumed | Depth | MM | Ex | Proj | Exe | Prereq | Balance | Verdict | Findings |
|-------|---------|---------|-------|----|----|------|-----|--------|---------|---------|----------|
| m04/01-model-va-null-safety | class, `T?`, `!`, `??`, required | M02–M03 | S | good | yes | yes | check | closed | BALANCED | STRONG | — |
| m04/02-copywith-va-equality | copyWith, `==`/hashCode | M04/01 | S | good | yes | yes | check | closed | BALANCED | STRONG | — |
| m04/03-noi-model-vao-menu | render model in menu | M04 | A | good | yes | yes | check | closed | BALANCED | STRONG | — |
| m04/04-unit-test-dau-tien | test()/expect/group | M04 | S | good | yes | yes | write-test | closed | BALANCED | STRONG | — |

## M05 — Future/async

| Route | Concepts | Assumed | Depth | MM | Ex | Proj | Exe | Prereq | Balance | Verdict | Findings |
|-------|---------|---------|-------|----|----|------|-----|--------|---------|---------|----------|
| m05/01-future-async-await | Future≠T, await suspends, isolate model, delayed, throw, async test | M04 | S | excellent | yes (non-project) | yes | predict+check | closed | BALANCED | STRONG | — |
| m05/02-futurebuilder | FutureBuilder, stable Future, mounted | M05/01 | S | excellent (identity trap) | yes | yes | predict | closed | BALANCED | STRONG | — |
| m05/03-async-main | ensureInitialized, async main | M05 | S | good | yes | yes | check | closed | BALANCED | STRONG | — |

## M06 — Stream

| Route | Concepts | Assumed | Depth | MM | Ex | Proj | Exe | Prereq | Balance | Verdict | Findings |
|-------|---------|---------|-------|----|----|------|-----|--------|---------|---------|----------|
| m06/01-stream-la-gi | Stream≠Future, lazy, periodic, take, first, emitsInOrder | M05 | S | excellent | yes (counter) | yes | predict | closed | BALANCED | STRONG | — |
| m06/02-streambuilder-trong-menu | StreamBuilder, initialData, stable stream | M06/01 | S | good | yes | yes | check | closed | BALANCED | STRONG | ticker scaffold F-05 |
| m06/03-listen-cancel-streamcontroller | listen/cancel, StreamController, broadcast, dispose | M06/02 | S | excellent (ownership) | yes | yes | predict | closed | BALANCED | STRONG | — |

## M07 — Navigation

| Route | Concepts | Assumed | Depth | MM | Ex | Proj | Exe | Prereq | Balance | Verdict | Findings |
|-------|---------|---------|-------|----|----|------|-----|--------|---------|---------|----------|
| m07/01-route-stack-va-push | stack model, Navigator.of upward search, MaterialPageRoute | M03 | S | excellent | yes | yes | predict | closed | BALANCED | STRONG | — |
| m07/02-game-screen-va-pop | pop, AppBar back, route lifecycle | M07/01 | S | good | yes | yes | check | closed | BALANCED | STRONG | — |
| m07/03-senior-navigation-checkpoint | GlobalKey, senior nav controller, why-primitive-first | M07 | A | good | — | yes | check | closed | BALANCED | STRONG | — |

## M08 — Quiz model & first widget tests

| Route | Concepts | Assumed | Depth | MM | Ex | Proj | Exe | Prereq | Balance | Verdict | Findings |
|-------|---------|---------|-------|----|----|------|-----|--------|---------|---------|----------|
| m08/01-quiz-question-model | immutable QuizQuestion, const bank, correctIndex | M04 | S | good | yes | yes | check | closed | BALANCED | STRONG | — |
| m08/02-quiz-state-va-enum | quiz state fields, `_AnswerVisualState` enum | M03–M04 | S | good | yes | yes | predict | closed | BALANCED | STRONG | — |
| m08/03-render-options-va-flow | collection-for, spread, state-derived UI, `onTap:null` | M08/02 | S | good | yes | yes | check | closed | BALANCED | STRONG | — |
| m08/04-widget-test-dau-tien | pumpWidget/pump/tap/finders, virtual time, cleanup | M08 | S | good | yes | yes | write-test | closed | BALANCED | STRONG | — |

## M09 — Phase machine, Timer, dialog

| Route | Concepts | Assumed | Depth | MM | Ex | Proj | Exe | Prereq | Balance | Verdict | Findings |
|-------|---------|---------|-------|----|----|------|-----|--------|---------|---------|----------|
| m09/01-game-phase-va-timer | GamePhase, GameEndReason, Timer.periodic ownership | M08 | S | good | yes | yes | predict | closed | BALANCED | STRONG | — |
| m09/02-phase-flow | transition table (answering/revealing/finished) | M09/01 | S | good | yes | yes | predict | closed | BALANCED | STRONG | — |
| m09/03-showdialog-va-popuntil | showDialog-as-route, AlertDialog, barrierDismissible, popUntil, switch stmt | M09/02 | A→S | good | yes | yes | check | closed | BALANCED | STRONG | F-01 stale "M14" ref; switch table-only |
| m09/04-test-game-session | widget test of session, pump durations | M09 | A | good | yes | yes | write-test | closed | BALANCED | STRONG | — |

## M10 — SharedPreferences, JSON, result flow

| Route | Concepts | Assumed | Depth | MM | Ex | Proj | Exe | Prereq | Balance | Verdict | Findings |
|-------|---------|---------|-------|----|----|------|-----|--------|---------|---------|----------|
| m10/01-sharedpreferences-va-profile-store | SharedPreferences, store class, async disk | M05 | S | good | yes | yes | check | closed | BALANCED | STRONG | F-02 stale `clear` in checkpoint |
| m10/02-json-tomap-frommap | `Map<String,Object?>`, jsonEncode/Decode, **factory ctor** | M04,M05 | A | good | yes | yes | check | **BROKEN claim** | BALANCED | ADEQUATE | F-04 factory never taught; false prereq claim |
| m10/03-game-result-qua-pop | route-result `Future<T?>`, pop(result) | M07,M05 | S | good | yes | yes | check | closed | BALANCED | STRONG | — |
| m10/04-ap-ket-qua-va-reset | apply result, reset, mounted after await | M10 | A | good | yes | yes | check | closed | BALANCED | STRONG | — |

## M11 — ChangeNotifier & ViewModel

| Route | Concepts | Assumed | Depth | MM | Ex | Proj | Exe | Prereq | Balance | Verdict | Findings |
|-------|---------|---------|-------|----|----|------|-----|--------|---------|---------|----------|
| m11/01-vi-sao-setstate-khong-scale | why setState fails, VM boundary, load-state enum | M03,M05 | S | excellent (problem-first) | yes | yes | predict | closed | BALANCED | STRONG | — |
| m11/02-notifylisteners-va-listenablebuilder | ChangeNotifier, notifyListeners, ListenableBuilder, switch expr, tear-off | M11/01 | S | excellent | yes | yes | predict | closed | BALANCED | STRONG | — |
| m11/03-so-huu-vm-va-test | VM lifecycle, dispose, unawaited, pure-Dart VM tests, notify-count | M11/02 | S | good | yes | yes | write-test | closed | BALANCED | STRONG | — |

## M12 — Provider

| Route | Concepts | Assumed | Depth | MM | Ex | Proj | Exe | Prereq | Balance | Verdict | Findings |
|-------|---------|---------|-------|----|----|------|-----|--------|---------|---------|----------|
| m12/01-inheritedwidget-va-lookup | constructor-threading problem, InheritedWidget, Provider.value | M11 | S | excellent | yes | yes | predict | closed | BALANCED | STRONG | — |
| m12/02-read-vs-watch | read vs watch, where each is legal, cascade `..` | M12/01 | S | excellent | yes | yes | predict | closed | BALANCED | STRONG | — |
| m12/03-changenotifierprovider-va-scope | ChangeNotifierProvider, Provider-managed disposal, app vs screen scope | M12/02 | S | excellent | yes | yes | check | closed | BALANCED | STRONG | — |

## M13 — Events & bridge

| Route | Concepts | Assumed | Depth | MM | Ex | Proj | Exe | Prereq | Balance | Verdict | Findings |
|-------|---------|---------|-------|----|----|------|-----|--------|---------|---------|----------|
| m13/01-event-khong-phai-state | event≠state, MenuUiEvent, broadcast controller, abstract+final class | M06,M11 | S | excellent | yes | yes | predict | **1 false claim** | BALANCED | STRONG | F-03 (`async*`/`yield` claim) |
| m13/02-event-bridge-trong-state | didChangeDependencies subscribe site, guard, unawaited, SnackBar/Messenger | M13/01,M12 | S | excellent (3-step contract) | yes | yes | predict | closed | BALANCED | STRONG | — |
| m13/03-snackbar-event-va-test | stream.first in tests, ensureVisible, broadcast no-replay proof, scaffold retirement | M13/02 | S | good | yes | yes | write-test | closed | BALANCED | STRONG | — |

## M14 — Repository, RxDart, MultiProvider, stream-driven VM

| Route | Concepts | Assumed | Depth | MM | Ex | Proj | Exe | Prereq | Balance | Verdict | Findings |
|-------|---------|---------|-------|----|----|------|-----|--------|---------|---------|----------|
| m14/01-vi-sao-profilestore-chua-du | repo boundary, abstract interface class, implements, private ctor, static create, file deletion | M10–M13 | **A→T** | partial (no named MM section) | project-only | yes | self-check | closed but **checkpoint impossible** | **TOO_CODE_HEAVY** | NEEDS_EXPANSION | F-06, F-07 |
| m14/02-rxdart-behavior-subject-valuestream | rxdart, BehaviorSubject.seeded, .value, ValueStream, replay, isClosed, close | M06,M13/01 | **A→T** | partial (no MM section) | one test snippet | yes | self-check | `pumpEventQueue` used pre-explanation | TOO_CODE_HEAVY | NEEDS_EXPANSION | F-07, F-08, F-09 |
| m14/03-ba-repository-va-multiprovider | 2 more repos, MultiProvider-by-contract, async bootstrap, model parity (`?element`, `_moneyFromDisplay`, legacy purge), fakes | M14/02 | **T** | weak | none non-project | yes | self-check | closed | **TOO_CODE_HEAVY / OVERLOADED** | NEEDS_EXPANSION (worst) | F-07, F-08, F-10 |
| m14/04-menuviewmodel-noi-vao-stream | .value+listen in ctor, state-vs-event stream table, retire MenuLoadState, propagation tests | M14/03 | A | good (explicit contrast table) | test snippets | yes | self-check | closed | BALANCED-lean-code | NEEDS_EXPANSION (minor) | F-07, F-09 |

## Roll-up

- STRONG: 44 lessons
- ADEQUATE: 1 (m10/02)
- NEEDS_EXPANSION: 3–4 (all of M14; /04 borderline-minor)
- MAJOR_CONTENT_GAP: 0

**Pattern:** the audit **does not** support "the whole course is code-first".
It supports: (a) one milestone (M14) where depth collapsed under concept
density; (b) a systematic absence of independent-production exercises across
all lessons; (c) a handful of concrete defects (stale refs, false prerequisite
claims, an impossible mid-milestone checkpoint). The human's directional
concern is confirmed but its shape is narrower than "course is shallow".
