# Current State

Project: AI Millionaire — guided Flutter course
Phase: Step 29 — per-lesson AI Local project-alignment review layer —
COMPLETE (committed locally; awaiting human decision to push →
auto-deploy).
M01–M29 course complete; Steps 21–26A pedagogy audit/remediation chain
closed; release gate CLEARED (non-blocking editorial notes only);
accepted content integrated to `main` and pushed to `origin/main`.
Production: `https://flutter-opal.vercel.app` — canonical Vercel
project `flutter` (`prj_smy4y3CCRwMu66TTPDoZYoA7GKzc`), GitHub
`main` auto-deploy CONFIRMED (Step-28 push `1a38e5b` redeployed
automatically). Duplicate project `flutter_course`
(`prj_lcAhw4Ps0CMLYOxSsVsIJTeB5Mhy`) also auto-deploys same source —
cleanup recommended, not deleted. M30 not started.

## Completed

- Step 01: Senior source discovery — complete audit of
  `D:\vibe_coding\flutter\flutter-accelerator-ai` at commit `c8eb860`.
  Results: `SENIOR_SOURCE_AUDIT.md`, `FEATURE_INVENTORY.md`,
  `ARCHITECTURE_MAP.md`, `DEPENDENCY_GRAPH.md`,
  `FLUTTER_BEGINNER_GAPS.md`, `ANDROID_TO_FLUTTER_MAP.md`.
  Report: `D:\vibe_coding\flutter\report\STEP-01-SENIOR-SOURCE-DISCOVERY.md` (PASS).
- Step 02: Course architecture & milestone roadmap — designed.
  Created: `COURSE_ARCHITECTURE.md`, `TEACHING_STANDARD.md`,
  `MILESTONE_ROADMAP.md` (29 milestones, M01–M29, Phases A–G),
  `CURRICULUM_TRACEABILITY.md`, `LESSON_TEMPLATE.md`.
  Report: `D:\vibe_coding\flutter\report\STEP-02-COURSE-ARCHITECTURE-ROADMAP.md` (PASS).
- Step 03: First production vertical slice — SUPERVISOR APPROVED.
  - Static course website: `web/` — Astro 5.18.2 + Starlight 0.34.8,
    static-first, Vietnamese prose.
  - Learner app: `learner-app/` (package `ai_millionaire_course`,
    platforms android/ios/web).
  - M01 implemented (3 lessons): project anatomy, `main()`/`runApp`,
    widget tree, `MaterialApp`/`Scaffold`, Hot Reload/tooling.
  - M02 implemented (4 lessons): constraint model, tokens, `MenuScreen`
    static layout (header, level/earnings/leaderboard/stats, gradient CTA).
  - M03 implemented (3 lessons): `StatefulWidget`/`State`, `createState`,
    `setState`, rebuild model, `GestureDetector`, `VoidCallback`,
    `initState`/`dispose`, state ownership.
  - Canonical docs: `WEBSITE_ARCHITECTURE.md`, `CONTENT_STATUS.md` created.
  - Report: `STEP-03-WEBSITE-M01-M03-VERTICAL-SLICE.md` (PASS).
- Step 04: Data, Async & Streams foundation — implemented, pending
  supervisor review.
  - M04 implemented (4 lessons): `UserProfileData` immutable model
    (`final`/`const`, named params, `?`/`??`, `copyWith`, `==`/`hashCode`,
    `gainExp`, derived getters, `formatThousands`); menu now model-backed;
    play-tap grants +10 EXP so immutable updates are visible; FIRST unit
    tests (10 pure-Dart tests, `test/user_profile_data_test.dart`).
  - M05 implemented (3 lessons): `Future`/`async`/`await` mental model;
    `demo_profile_loader.dart` demo loader (900ms delay, `fail` flag);
    `Future<void> main() async` + `WidgetsFlutterBinding.ensureInitialized()`;
    stable `Future` in `initState` + `mounted` guard; `FutureBuilder<void>`
    with loading/error/retry states (13 tests total).
  - M06 implemented (3 lessons): `Stream` vs `Future`; `menuSessionTicker()`
    (`Stream.periodic`, 1s) + `StreamBuilder` live seconds card in menu;
    `listen`/`cancel`/single-vs-broadcast taught as labelled learning
    examples (15 tests total).
  - Website: 30 pages build cleanly; M04–M06 sidebar sections + roadmap
    statuses updated.
  - Canonical docs: `M04_M06_IMPLEMENTATION_NOTES.md` created; decisions
    D15–D17 recorded.
  - Report: `D:\vibe_coding\flutter\report\STEP-04-M04-M06-DATA-ASYNC-STREAMS.md`.
  - Learner app end-of-M06 state: `flutter analyze` clean, 15/15 tests,
    `flutter build web` pass. Still zero third-party packages.
- Step 05: Navigation, Mini-Quiz & Full Local Game — implemented, pending
  supervisor review.
  - M07 implemented (3 lessons): route-stack mental model;
    `screens/game_screen.dart` placeholder route; menu CTA →
    `Navigator.push(MaterialPageRoute)`; `AppBar` auto back + `pop`;
    senior `AppNavigationController` comparison.
  - M08 implemented (4 lessons): `QuizQuestion` immutable model +
    `quiz_questions.dart` 4-câu const bank in `data/game/`; `GameScreen`
    → `StatefulWidget` mini-quiz (select → submit → reveal → next, result
    panel); first widget tests (`test/widgets/game_screen_test.dart`,
    6 tests) + bank-integrity unit test (25 tests total at M08).
  - M09 implemented (4 lessons): `GamePhase` (3 values) + `GameEndReason`
    in `data/game/game_session_state.dart`; `Timer.periodic` 15s countdown
    owned by `State` (cancel/dispose rules); wrong-answer/timeout/victory
    endings; `AlertDialog` + `barrierDismissible: false`; CHƠI LẠI
    (`pop`+`_restart`) and VỀ MENU (`popUntil(isFirst)`); widget tests +5
    → 29 total; test-caught overflow fixed via `Expanded`+scrollable body.
  - Website: 44 pages build cleanly; sidebar Phase C group + roadmap
    statuses updated (M07–M09 AVAILABLE).
  - Canonical docs: `M07_M09_IMPLEMENTATION_NOTES.md` created; decision
    D18 recorded.
  - Report: `D:\vibe_coding\flutter\report\STEP-05-M07-M09-NAVIGATION-QUIZ-GAME.md`.
  - Learner app end-of-M09 state: `flutter analyze` clean, 29/29 tests,
    `flutter build web` pass. Still zero third-party packages.
- Step 06: Persistence, State & DI — implemented, pending supervisor
  review.
  - M10 implemented (4 lessons): `shared_preferences` package;
    `ProfileStore` concrete storage over key `'user_profile'`;
    `UserProfileData.toMap`/defensive `fromMap`; `GameResult` model;
    `push<GameResult>`/`pop(result)` route-result flow (dialog now returns
    `_ResultAction`); `applyGameResult` progression policy on the model;
    menu applies result exactly once + persists; `ĐẶT LẠI HỒ SƠ` reset
    action. +14 tests (43 total).
  - M11 implemented (3 lessons): `MenuViewModel extends ChangeNotifier`
    + `MenuLoadState` enum; `_MenuScreenState` owns VM lifecycle
    (initState/`unawaited(load)`/dispose); `ListenableBuilder` replaces
    `FutureBuilder`; compare-before-notify guards; ephemeral state stays
    in `State`. +7 tests (50 total).
  - M12 implemented (3 lessons): `provider` package;
    `AppDependencyScope` (`Provider<ProfileStore>.value` — one honest
    dependency, no stubs); `MenuScreen` → `StatelessWidget` with
    `ChangeNotifierProvider(create: …read<ProfileStore>()..load())`
    auto-disposing the VM; `_MenuScreenView` uses `context.watch` in
    build / `context.read` in callback; constructor threading removed.
    +2 tests (52 total). `GameScreen` stays `setState` per scope rules.
  - Website: 57 pages build cleanly; sidebar Phase D group added;
    roadmap M10–M12 marked AVAILABLE.
  - Canonical docs: `M10_M12_IMPLEMENTATION_NOTES.md` created; decisions
    D19–D20 recorded.
  - Report: `D:\vibe_coding\flutter\report\STEP-06-M10-M12-PERSISTENCE-STATE-DI.md`.
  - Learner app end-of-M12 state: `flutter analyze` clean, 52/52 tests,
    `flutter build web` pass. Third-party packages: `shared_preferences`,
    `provider`.
- Step 07: **Agent Product v1.0** — built, pending supervisor review.
  - Canonical tool-neutral system at `AI_HANDOFF/agent-system/`:
    five roles (Atlas/Flux/Lumen/Argus/Forge), workflow contract,
    state machine, quality gates G1–G15, seven contracts, eight
    templates, `work/milestones/` production-area convention.
  - Adapters: `adapters/devin/` (single-agent role simulation +
    orchestrator prompt); `adapters/claude-code/` + `.claude/agents/` +
    `.claude/skills/` thin pointers + root `CLAUDE.md`.
  - Smoke test defined + executed in `AI_HANDOFF/work/smoke/MX/` —
    mechanics verified (rejection/approval routing, no self-approval,
    stage-order enforcement, zero production writes).
  - No learner-app, website, or M13 changes. Regression green.
  - Report: `D:\vibe_coding\flutter\report\STEP-07-AGENT-PRODUCT-V1.md`.
- Step 08: **M13 — One-shot UI events from the VM** — first production
  milestone executed through Agent Product v1; full stage chain on disk
  at `AI_HANDOFF/work/milestones/M13/` (00→08 + lessons/), two real
  remediation cycles preserved.
  - M13 implemented (3 lessons): `menu_ui_event.dart` (plain
    `abstract`/`final` event classes — sealed is M15);
    `MenuViewModel` broadcast `StreamController` + `events` getter +
    `requestGame()`/reset snackbar emit + `dispose` close;
    `_MenuScreenViewState` event bridge (`didChangeDependencies`
    subscribe, `==` re-subscribe guard, `dispose` cancel,
    `unawaited(_openGame())`); `_onPlayTap` → `requestGame()` (no
    direct navigation). +5 tests (57 total).
  - Website: 61 pages; sidebar "M13 · Event một-lần từ VM" in Phase D;
    roadmap M13 AVAILABLE.
  - Canonical docs: `M13_IMPLEMENTATION_NOTES.md` created; decision
    D22 recorded.
  - Report: `D:\vibe_coding\flutter\report\STEP-08-M13-AGENT-COMPANY-PRODUCTION.md`.
  - Learner app end-of-M13 state: `flutter analyze` clean, 57/57 tests,
    `flutter build web` pass. Third-party packages unchanged.
- Step 09: **M01–M13 strict senior-fidelity audit** — read-only audit of
  learner code + all 44 lessons + roadmap against senior source.
  Verdict: `PASS_WITH_REMEDIATION` (0 critical / 0 high / 5 medium /
  4 low; 1 surviving invented behavior — invented profile defaults;
  5 roadmap gaps; `ALL_SIMPLIFICATIONS_MAPPED_TO_CONVERGENCE = NO`).
  Artifacts: `AI_HANDOFF/work/audits/M01-M13-SENIOR-FIDELITY/`.
  Report: `STEP-09-M01-M13-STRICT-SENIOR-FIDELITY-AUDIT.md`.
- Step 10: **M01–M13 strict senior-fidelity remediation** — role-staged
  remediation of all Step-09 findings.
  - Code: learner defaults now equal senior (`'0XFF'`/zeros);
    `totalEarnings`+`totalQuestionCount` fields added; `ProfileStore
    .clear()`→`reset()` (write-default = senior `resetUserProfile`
    semantics); course-only menu scaffolds removed (sound toggle, tap
    counter, session ticker); dead `demo_profile_loader.dart` deleted;
    `MenuLoadState` marked temporary (expires M14).
  - Content: M03 false senior claim corrected (FD-01); M04/M05/M10/M11/
    M13 lessons updated; FD-09 snackbar emit-site nuance added.
  - Roadmap: M09 as-shipped annotation (FD-12); convergence owners
    assigned M14/M16/M19/M22/M23/M24/M29; new canonical
    `SENIOR_FIDELITY_REGISTER.md` (25 entries); gate G16 + brief
    template §5b added; decision D23 recorded.
  - Learner app post-remediation: `flutter analyze` clean, 52/52 tests
    (57 − 5 deleted scaffold tests), `flutter build web` pass.
  - Artifacts: `AI_HANDOFF/work/remediation/M01-M13-STRICT-FIDELITY/`.
  - Report: `STEP-10-M01-M13-STRICT-FIDELITY-REMEDIATION.md`.
- Step 11: **M14 — Repository contracts & rxdart BehaviorSubject** —
  first production milestone executed under the permanent G16 gate;
  full artifact chain at `AI_HANDOFF/work/milestones/M14/` (00→08 +
  lessons/), all gates single-cycle PASS.
  - M14 implemented (4 lessons): `abstract interface class` contracts
    + impls for `UserProfileRepository`, `UserSettingsRepository`,
    `OnboardingRepository` (SharedPreferences-backed, senior file
    layout); `rxdart: ^0.28.0`; `BehaviorSubject.seeded` +
    `ValueStream` + `.value` + `isClosed`/equality emit guards +
    `dispose`; `MenuViewModel` seeds `.value` + subscribes in ctor
    (`MenuLoadState`/`load()`/`_MenuLoading`/`_MenuErrorState`
    retired); `AppDependencyScope` → `MultiProvider` keyed on
    contracts; `main()` 3×`create()` + `loadUserSettings()`;
    `UserProfileData` senior field set (`totalEarnings`,
    `totalQuestionCount`) + deep parse (`?avatarUrl`,
    `_moneyFromDisplay`, legacy-demo purge); `ProfileStore` deleted;
    3 `Fake*Repository` in `test/helpers/`.
  - Register: FR-08/FR-09/FR-19 → CONVERGED; FR-26 opened
    (`languageCode` whitelist → M17); FR-04 half-landed (stream
    propagation real; transport → M19/M22).
  - Website: 66 pages; sidebar "M14 · Repository & BehaviorSubject";
    roadmap M14 AVAILABLE.
  - Canonical docs: `M14_IMPLEMENTATION_NOTES.md` created; register
    updated; no new durable decision needed (existing gates covered).
  - Report: `D:\vibe_coding\flutter\report\STEP-11-M14-REPOSITORY-RXDART.md`.
  - Learner app end-of-M14 state: `flutter analyze` clean, 69/69
    tests (52 → 69), `flutter build web` pass. Third-party packages:
    `shared_preferences`, `provider`, `rxdart`.
- Step 12: **M01–M14 beginner-content audit** — 48 lessons / 76
  concepts audited; verdict NEEDS_SYSTEMATIC_ENRICHMENT (0 critical /
  3 high / 4 medium / 5 low; M14 too dense, zero independent
  exercises, no pedagogy gates).
  Report: `STEP-12-M01-M14-BEGINNER-CONTENT-CURRICULUM-AUDIT.md`.
- Step 13: **M01–M14 beginner-content remediation + governance** —
  all 12 findings disposed; permanent pedagogy governance installed.
  - New canonical controls: `LEARNER_CONCEPT_REGISTRY.md`
    (per-concept taught/used/exercise/status), `PREREQUISITE_GRAPH.md`,
    `CONTENT_GAP_REGISTER.md` (12 rows, all RESOLVED*),
    `BEGINNER_CONTENT_STANDARD.md` (LIGHT/NORMAL/CORE_CONCEPT),
    `LESSON_TEMPLATE.md` → V2, gates **G17–G24** in QUALITY-GATES
    (concept depth, prerequisite closure, mental model, independent
    transfer, active learning, cognitive load, template completeness,
    sequential executability); Lumen/Argus/Atlas protocols + brief
    `LEARNING DESIGN CHECK` updated.
  - Content: `factory` taught at first use (m10/02); scaffold
    markers at introduction (m03/01, m06/01); `Tự làm` exercises
    every milestone; 5-question synthesis checkpoints on all 14
    milestone indexes.
  - **M14 restructured 4→7 lessons** (motivation → contract →
    stream-state model → impl → repo repetition/parity → DI bridge →
    VM migration+deletion), isolated examples before production
    code, `Tự làm` per lesson.
  - New reference pages `/concepts/` + `/state-progression/` in
    sidebar; site builds 71 pages.
  - **M14 sequential replay 7/7 PASS** on a physical M13-state clone.
  - Independent Argus re-audit: 13/13 checks PASS; 7 residual items
    surfaced and fixed in the same cycle (FAIL→fix→PASS preserved).
  - Learner app: **unchanged** (content-only task; analyze clean,
    69/69, build web pass re-verified). Senior source unchanged.
  - Artifacts: `AI_HANDOFF/work/remediation/M01-M14-BEGINNER-CONTENT/`.
  - Report: `STEP-13-M01-M14-BEGINNER-CONTENT-REMEDIATION.md`
    (verdict BEGINNER_CONTENT_READY).
- Step 14: **M15 — Sealed classes & state-driven UI** — first
  production milestone under dual governance (G16 + G17–G24); full
  artifact chain at `AI_HANDOFF/work/milestones/M15/` (00→08 + lessons
  + sequential replay), one real content-QA FAIL→remediate→PASS cycle.
  - M15 implemented (5 lessons): `sealed class MenuScreenUiEvent`
    (renamed `menu_ui_event.dart`→`menu_screen_ui_event.dart`,
    `abstract`→`sealed`); `_handleUiEvent` `is`-chain → exhaustive
    `switch` statement + object pattern `(:final message)`;
    `sealed class GameDialogState` (`GameDialogHidden` /
    `GameEndedDialog(reason)` / `GameVictoryDialog`) in renamed
    `game_session_state_data.dart`; `game_screen` `_dialogState` field
    drives dialog via `switch` expressions (+`(:final reason)` +
    wildcard `_`); `GameEndReason` trimmed {wrongAnswer, timeout};
    `showDialog` mechanism kept (M21). +5 tests (74 total).
  - Register: **FR-15 → CONVERGED**; FR-07 partial (sealed types
    landed; in-Stack layer M21); FR-05 partial (dialog-state half;
    6-phase machine M19). No unregistered deviations.
  - Pedagogy: concept registry rows D-26/27/28 + A-14 added;
    prerequisite graph extended; isolated PaymentState/ConnectionState
    examples; 3 production exercises (PRODUCE×2 + DEBUG) + PREDICT.
  - Website: 77 pages; sidebar "M15 · Sealed & state-driven UI";
    roadmap M15 AVAILABLE; concepts + state-progression Bước 6.
  - Sequential replay 5/5 PASS on a physical M14-state clone.
  - Learner app end-of-M15: `flutter analyze` clean, **74/74** tests,
    `flutter build web` pass. Packages unchanged.
  - Report: `D:\vibe_coding\flutter\report\STEP-14-M15-SEALED-STATE-DRIVEN-UI.md`.

- Step 15 (in run): **M16 — Settings (persisted preferences)** —
  full artifact chain at `AI_HANDOFF/work/milestones/M16/` (00→11 +
  lessons); impl QA re-verify PASS; content QA FAIL→remediate→PASS;
  site QA stale-read artifact disproved→re-verify PASS; sequential
  replay 5/5 PASS catching two real executability defects (F-13/F-14).
  - M16 implemented (5 lessons): gear icon → `MenuSettingsRequested`
    event → `showSettingsDialog` hosting dialog-scoped
    `SettingsViewModel` (ChangeNotifierProvider inside dialog subtree);
    sealed `SettingItemData` (switch/time-picker) via
    `buildSettingItems` factory + collection-`if`; `Switch` controlled
    rows (row-level tap, opaque); language chips persist `languageCode`;
    `NotificationTimePicker` stateful panel (ListWheelScrollView +
    FixedExtentScrollController, state-owned temp selection) rendered
    by `timePickerVisible` content-swap; sealed `SettingsUiEvent`
    (dismiss/snackbar); `_SettingsAccountRow` display-only.
    +13 tests (87 total).
  - Register: **FR-27/28/29/30 OPEN** (notification permission→M27,
    account auth→M22+/M27, MenuDialogSettings entry→M21, gear asset);
    FR-26 stays ACTIVE → **M17** (whitelist guard deliberately NOT
    applied at M16).
  - Pedagogy: D-30 `late final` + M16 concept rows; persist-loop and
    dialog-scope mental models; Tự làm `SettingInfoItemData` variant.
  - Website: 83 pages; sidebar "M16 · Settings persist" (Phase E);
    roadmap M16 AVAILABLE; concepts +10 rows; state-progression Bước 7.
  - Learner app end-of-M16: `flutter analyze` clean, **87/87** tests,
    `flutter build web` pass. Packages unchanged.

- Step 15 (cont.): **M17 — Localization (en/vi)** — full artifact chain
  at `AI_HANDOFF/work/milestones/M17/` (00→11 + lessons); impl QA
  re-verify PASS; content QA 3-cycle remediation + r4 PASS; site QA
  PASS (md5 byte-identity); sequential replay 5/5 PASS catching F-15.
  - M17 implemented (5 lessons): `l10n.yaml` + `generate: true` +
    `flutter_localizations` + `intl: any`; 48-key en/vi ARBs (31
    senior-shared keys, senior values incl. em-dash); generated
    `AppLocalizations` committed under `lib/l10n/`; app-root
    `StreamBuilder` (`initialData: settingsStream.value`) →
    `_selectedLocaleFor` → `MaterialApp.locale`; FR-26 converged —
    `_supportedLanguageCode` whitelist via
    `SupportedLanguageData.isSupportedCode`; UI owns `l10n` reads and
    passes strings into context-free VM/factory
    (`localizedSettingItems`); `test/helpers/localized_test_app.dart`
    + `locale: vi` pins on existing hosts; menu/settings/game chrome
    localized (quiz-bank + repo errors + onboarding excluded).
    +3 tests (90 total).
  - Register: **FR-26 → CONVERGED at M17**; **FR-31 OPEN**
    (learner l10n coverage delta — quiz-bank, repo error strings,
    onboarding — SIMPLIFIED / ACTIVE_TEMPORARY).
  - Pedagogy: D-31 (`.arb`/`@key` placeholders), F-25
    (`MaterialApp.locale`/delegates/gen-l10n), A-16 (locale = derived
    state at app-root; UI-owns-strings); Tự làm exercises per lesson.
  - Website: 89 pages; sidebar "M17 · Localization (en/vi)" (Phase E);
    roadmap M17 AVAILABLE; concepts +3 rows; state-progression Bước 8.
  - Learner app end-of-M17: `flutter analyze` clean, **90/90** tests,
    `flutter gen-l10n` + `flutter build web` pass. New package:
    `flutter_localizations` (sdk) — first locale-driven rebuild wired.
- Step 15 (cont.): **M18 — Onboarding overlay (first run)** — full
  artifact chain at `AI_HANDOFF/work/milestones/M18/` (00→11 +
  lessons); impl QA PASS (1 MINOR fixed); content QA r1 FAIL
  (skeleton) → rewrite → r2 PASS + targeted re-verify PASS; site QA
  PASS; sequential replay 5/5 PASS zero defects.
  - M18 implemented (5 lessons): sealed `OnboardingStepState`
    (welcome/notification/ready, `stepOrder`, equality) + content
    data; `OnboardingViewModel` **senior-identical** — step queue,
    `listEquals` + `List.unmodifiable`, `_languageSelectionInProgress`
    guard, repo-stream self-clear; `OnboardingOverlayScope` —
    `FutureBuilder` gate on `loadOnboardingCompleted` +
    overlay-scoped `ChangeNotifierProvider` (4th lifetime tier);
    overlay UI (scrim + opaque absorber + per-step actions +
    indicator); menu body wrapped in `Stack` with
    `Positioned.fill`; `LanguageChipRow` promoted to
    `widgets/common/` (senior path); 16 senior ARB keys +
    `gameNextButton` rename to resolve collision; 3 test hosts
    re-seeded `onboarding_completed: true`.
    +12 tests (102 total).
  - Register: **FR-32 OPEN** (onboarding visual/gating depth → M28);
    **FR-27 extended** (simulated grant → M27); **FR-31 updated**
    (onboarding keys landed).
  - Pedagogy: D-32 (`listEquals`/`List.unmodifiable`), F-26
    (in-`Stack` overlay gating — visibility=state), A-17
    (overlay-scoped VM, fourth lifetime tier).
  - Website: 95 pages; sidebar "M18 · Onboarding overlay (lần đầu)";
    roadmap M18 AVAILABLE; concepts +3 rows; state-progression
    Bước 9.
  - Learner app end-of-M18: `flutter analyze` clean, **102/102**
    tests, `flutter build web` pass.
- Step 16 (cont.): **M19 — Structured Game Architecture /
  GameViewModel convergence** — full artifact chain at
  `AI_HANDOFF/work/milestones/M19/` (00→12 + lessons); impl QA r1 FAIL
  (1 MAJOR dialog-route back bypass + 2 MINORs) → remediated →
  re-verify PASS; content QA r1 FAIL (3 MAJORs) → fixed → r2 PASS +
  targeted re-verify PASS; site QA PASS; sequential replay 6/6 PASS.
  - M19 implemented (6 lessons): verbatim senior data layer
    (`game_session_state_data` 6-phase `GamePhase` + 6-variant sealed
    `GameDialogState` + immutable `copyWith`; `game_screen_data`;
    `game_quiz_question_data` full shape; `game_money_ladder_data`
    15 levels + safe havens; `game_result`; 45-question senior bank);
    `GameScreenViewModel extends ChangeNotifier` (senior semantics —
    30s `Timer.periodic`, pause/resume around dialogs, 1500ms reveal +
    1000ms explanation delays, monotonic `flowToken`, verbatim
    walk-away, `GameResult.earnedAmount` payload) — **intermediate
    architecture**: `ChangeNotifier`+`copyWith`, DRE deferred →M26;
    pure `GameScreenPresentationMapper` + ladder mapper + money
    formatter; `AppNavigationController` + `navigatorKey` on
    `MaterialApp` (context-free `openGame`/`goBack`); screen rewrite —
    provider scope + stateful event bridge + `PopScope` + `showDialog`
    interim layer (in-Stack `GameDialogLayer` →M21) + dialog-route
    back routing matching senior; portrait lock in `main()`; ARB key
    migration (9 senior dialog keys; 17 dead keys removed); old
    `quiz_questions.dart`/`quiz_question_data.dart` deleted.
    +24 tests (126 total).
  - Register: **FR-05, FR-06, FR-10, FR-13, FR-17, FR-18 CONVERGED**;
    **FR-03/FR-04/FR-07 advanced** (ladder payload landed; EXP basis +
    VM-side save →M22; in-Stack layer + lifeline variants →M21/M20).
  - Pedagogy: D-33 (finite state machine), D-34 (`copyWith`/immutable
    update), F-27 (VM owns timer/lifecycle), F-28 (`PopScope`), A-18
    (structured session state → mapper → `GameScreenData`), A-19
    (context-free navigation via `navigatorKey`).
  - Website: 102 pages; sidebar "M19 · Kiến trúc game có cấu trúc"
    (Phase F); roadmap M19 AVAILABLE; concepts +6 rows;
    state-progression Bước 10.
  - Learner app end-of-M19: `flutter analyze` clean, **126/126**
    tests, `flutter build web` pass. New dev-dep: `fake_async`.

- Step 16 (cont.): **M20 — Lifelines & feature buttons (50:50 /
  hỏi khán giả / hỏi AI / walk-away / thoát)** — full artifact
  chain at `AI_HANDOFF/work/milestones/M20/` (00→11 + lessons); impl
  QA PASS (1 MINOR + 3 NITs remediated); content QA r1 FAIL
  (sealed-variant staging broke exhaustive switches) → staging
  redesigned (variants land with their UI lessons) → r2 PASS +
  targeted re-verify PASS; site QA r1 flagged stale-read FAIL →
  md5-verified identical → PASS; sequential replay 4/4 PASS on
  physical M19 clone.
  - M20 implemented (5 lessons): verbatim senior lifeline layer —
    `game_lifeline_helper` (deterministic 50:50 keep
    correct+first-wrong; poll 68/52/42 + `_splitWrongAudience`
    50/32/remainder); state + `visibleOptionTexts` /
    `audiencePercentiles` / `usedFeatureButtons` (Set.unmodifiable)
    / `resolvedResult` + `clear*` flags; 3 new sealed variants →
    **9-variant `GameDialogState` matching senior 1:1**; mapper +
    4 params + `_buildFeatureButtons` (aiAssistant always,
    walkAway only `canWalkAway`, `exitGame` NOT in bar); VM
    `handleFeatureClick`→`_canUseFeature`→mutation + simulated AI
    (`_aiAssistantDelay` 700ms, `isLoading`→result in ONE dialog
    via `_GameDialogHost` live-read `ListenableBuilder`, token +
    `is!` stale-result guards) + walk-away → `victory` phase with
    `resolvedResult{won:false, earned:walkAwayAmount}`; screen
    `_GameFeatureBar` data-driven + `_AnswerOption` empty-slot
    guard; 12 senior ARB keys. +21 tests (147 total).
  - Register: **FR-07 advanced** (lifeline variants landed); FR-33
    stays reserved (GameShareResultEvent unassigned); **FR-34 OPEN**
    (lifeline visual depth — senior SVG/CustomPainter → M28); DRE
    stays →M26; in-Stack `GameDialogLayer` stays →M21; VM-side
    result save (`GameSaveResult`/`hasSavedResult`) stays →M22 —
    `resolvedResult` is the interim carrier.
  - Pedagogy: D-35 (`Set<T>` immutable state), D-36 (`firstWhere`/
    map-comprehension/`List.generate`/`String.fromCharCode`), F-28
    (`LinearProgressIndicator`/`AnimatedOpacity`/`Semantics`/
    `IconData`-as-DTO). A-20 reinforced.
  - Website: 108 pages; sidebar "M20 · Lifelines & nút feature"
    (Phase F); roadmap M20 AVAILABLE; concepts +9 rows;
    state-progression Bước 11.
  - Learner app end-of-M20: `flutter analyze` clean, **147/147**
    tests, `flutter build web` pass.

- Step 17: **M21 — Senior Dialog Layer / Back Handling convergence**
  — full artifact chain at `AI_HANDOFF/work/milestones/M21/`
  (00→12 + lessons); impl QA PASS→REVERIFIED-PASS (comment/timing
  remediation); content QA r1 FAIL (4 blockers: wrong dialog text /
  AI ctor params / fabricated delete-symbols / wrong finder literal)
  → remediated → REVERIFIED-PASS + residual minors; site QA PASS
  (114 pages, firewall clean); sequential replay 5/5 PASS on
  physical M20 clone (147→150→153→153→157).
  - M21 implemented (5 lessons): senior in-`Stack` dialog layer —
    `GameDialogLayer` (`Positioned.fill`→`IgnorePointer(Hidden)`→
    `AnimatedSwitcher` 300ms easeOut/InCubic keyed
    `ValueKey(runtimeType)` → `_DialogBackdrop` ClipRect/
    BackdropFilter σ16/transparent scrim/opaque tap/ConstrainedBox
    375 → 9 `Game*DialogView` callback views); `PopScope
    (canPop:false, onPopInvokedWithResult)` → `_handleRouteBack`
    (Hidden→confirm-exit, Ladder/Ended/Victory→ignore, else dismiss);
    `_afterExit` exit-motion choreography + `_terminalActionPending`;
    `GameDialogRequested`/`_GameDialogHost`/`_showCurrentDialog`/
    `_dialogOpen` retired — `GameScreenUiEvent` = navigation only;
    `MenuTokens` +3 dialog tokens; `MediaQuery.disableAnimations`
    honored. +10 layer tests (157 total).
  - Register: **FR-16 CONVERGED (game scope)**, **FR-07 CONVERGED**;
    FR-29 re-pointed →M29 (menu dialogs); **FR-33 registered**
    (share → M27); FR-01/FR-03/FR-04 stay →M22; FR-32/FR-34 →M28.
  - Pedagogy: **A-21** (in-tree dialog layer — CORE), **D-37**
    (`ValueKey(runtimeType)` key-identity — CORE), **F-29**
    (`AnimatedSwitcher` — CORE), **F-30** (backdrop/IgnorePointer/
    opaque composition — NORMAL). F-26/F-27 reinforced.
  - Website: 114 pages; sidebar "M21 · Dialog layer kiểu senior"
    (Phase F); roadmap M21 AVAILABLE; concepts +5 rows;
    state-progression Bước 12.
  - Learner app end-of-M21: `flutter analyze` clean, **157/157**
    tests, `flutter build web` pass.
  - Replay found+fixed one lesson defect (pre-staged
    `disableAnimations` param → `unused_element_parameter` at L02
    checkpoint; param moved to L03 step).

- Step 17 continued: **M22 — Result Persistence / Profile
  Progression convergence** — full artifact chain at
  `AI_HANDOFF/work/milestones/M22/` (00→10 + lessons); impl QA PASS
  (5 minors dispositioned — incl. unclamped label + web-int64
  sentinel → JS max-safe-int); content QA r1 FAIL (4 blockers:
  fabricated `_finalVictory`, stale `_diag_test.dart`, 2×`dart test`,
  missing index tail) → remediated → r4 REVERIFIED-PASS; site QA
  PASS (120 pages); sequential replay 5/5 on physical M21 clone
  (157→164→169→168→168 — non-monotonic dip = scaffold tests dying
  with scaffold, taught in lessons).
  - M22 implemented (5 lessons): VM-side result save — ctor injects
    `UserProfileRepository`; `_emitWithSaveResult` at 4 terminal
    transitions (victory/gameOver/walkAway/backToMenu) guarded by
    `GameSessionState.hasSavedResult` (senior `_withSaveResult`
    semantics); `_saveGameResult`/`_applyLevelProgression`/
    `_normalizedLevel` ported verbatim from
    `bridge/game_screen_view_model_result_persistence.dart`;
    `_syncSavedGameResult` = M25 `debugPrint` stub; `LevelConfig`
    ported (baseExp 30000, growth 5000, milestone multipliers,
    JS-safe `maxExpRequirement`); `MenuLevelProgress.fromProfile`
    derived view; `_LevelCard` rewired to `progress`.
  - Retired: `GameResult`/`game_result.dart`, `resolvedResult`,
    `buildGameResult`, `MenuViewModel.applyGameResult`,
    `expForNextLevel` field, `gainExp`, `expPerCorrectAnswer`,
    `expPercent` getter. `openGame`→`Future<void>`; bare `goBack`;
    `_openGame` result-less.
  - Register: **FR-01, FR-02, FR-03, FR-04 CONVERGED at M22**;
    FR-19 residual note updated (`expPercent` retired).
  - Pedagogy: **A-22** (VM-side async save boundary — CORE), **D-38**
    (`LevelConfig` config-table — NORMAL), **D-39** (derived
    view-model `fromProfile` — NORMAL).
  - Website: 120 pages; sidebar "M22 · Lưu kết quả & lên cấp";
    roadmap M22 AVAILABLE; concepts +3 rows; state-progression
    Bước 13.
  - Learner app end-of-M22: `flutter analyze` clean, **168/168**
    tests, `flutter build web` pass.
  - Content QA caught + fixed: fabricated senior symbol
    (`_finalVictory` → real call site `_loadNextQuestionOrVictory`
    victory branch) in 4 places incl. shipped comment; stale
    `_diag_test.dart` breaking analyze; DEBUG exercise rewritten to
    observable bug (emit-without-flag → 3 red tests verbatim).

## Pending

- Supervisor + human review of Step 04–Step 15 reports.
- Step-16 long run COMPLETE: **M19 + M20 both MILESTONE_COMPLETE**.
- Step-17 long run COMPLETE: **M21 + M22 both MILESTONE_COMPLETE**.
  Hard stop honored before M23.
- Step-18 long run COMPLETE: **M23 + M24 + M25 MILESTONE_COMPLETE**
  (M23: Supabase bootstrap + leaderboard, 168→193, site 126,
  `LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED`.
  M24: authentication — sealed session + disabled/Supabase/Google/Apple
  repos + auth/sign-out dialogs + FR-11/12/28/35 converged, 193→224,
  site 132, `LIVE_AUTH_FLOW: NOT_PERFORMED`.
  M25: remote profile sync — AppUserData + mergeUserProfileForSync +
  UserProfileSyncRepositoryImpl upsert(onConflict:auth_uuid) +
  _syncSavedGameResult, FR-36 converged, 224→236, site 138,
  `LIVE_PROFILE_SYNC: NOT_PERFORMED`).
- Step-19 long run COMPLETE: **M26 + M27 + M28 MILESTONE_COMPLETE**
  (M26: DRE refactor — `core/dre` primitives + `DreChangeNotifier`,
  `GameState`/13 actions/7 effects/`GameSaveResult` op,
  `GameReducer` + 4 part files verbatim senior, VM rewrite +
  2 bridge parts, `GameSessionState` retired, UI call-sites
  unchanged; share effect kept as M27 boundary. FR-04 DRE-asyncOp
  clause converged. 236→254, site 145. Replay 6/6 byte-identical.
  M27: platform extras — `LocalNotificationService` verbatim +
  `SettingsNotificationCoordinator` + permission-as-state AND-gate +
  `v$appVersion` + onboarding real `requestPermission` (simulated
  grant retired) + full share chain `GameShareRequested`→effect→
  `SharePlus`/`sharePositionOrigin`→`Clipboard` fallback +
  manifest 2 uses-permission + 2 receivers. FR-27 + FR-33
  converged; FR-28 version-text converged. 254→259, site 152.
  Replay 6/6 byte-identical. `REAL_DEVICE_PLATFORM_CHECK:
  NOT_PERFORMED`.
  M28: visual parity — `AppTokens`/`AppAssets`/`surfaceGlow`/
  `DesignFrame` + `flutter_svg`/`google_fonts` + 8 assets;
  `QzdsGameButton`/`GlassIconButton`/`GameScreenBackground`;
  countdown timer `AnimationController`×2 + `CustomPainter`
  stadium + critical pulse; money trigger-motion + glitch +
  ladder dialog; answers/question/audience-poll + full dialog
  subsystem (shell + 3 families + layer `runtimeType`-keyed
  `AnimatedSwitcher` + `BackdropFilter`); atomic swap
  `GameFeatureButtonData.icon`→`iconAsset` + feature-button
  painter + `GameScreen` thin-shell + old monolith deleted.
  FR-34 converged; FR-32 game-surface part converged
  (onboarding visuals → M29); FR-30/FR-28-residual/FR-31
  residuals → M29. 259→309, site 159. Replay 6/6
  byte-identical. `REAL_DEVICE_VISUAL_CHECK: NOT_PERFORMED`).
- Website deployment — no existing configuration (verified Step 27:
  no `vercel.json`/CI/`site` URL); Vercel static deploy of `web/` is
  the documented target; release content ready for manual or connected
  deployment.
- Visual QA (browser screenshot) still not performed; build/route/content
  sanity verified via HTTP + markup checks.

## Blocked

- None.

## Environment

- Senior source: `D:\vibe_coding\flutter\flutter-accelerator-ai` (READ-ONLY)
- Course workspace: `D:\vibe_coding\flutter\flutter-course-accelerator-ai`
- Canonical context: `project-context/` (this folder)
- Reports: `D:\vibe_coding\flutter\report\`
- Toolchain verified: Flutter 3.41.9 stable, Dart 3.11.5, Node v22.23.2,
  npm 10.9.8, Android SDK 36.1.0, Chrome. No Visual Studio (Windows desktop
  target unavailable; web + Android are the verification paths).
- Known web caveat: `pagefind` search indexer lacks a windows-x64 npm binary
  → search index skipped during local builds (site works; indexing works on
  CI/deploy). Rollup optional-dep npm bug required one manual
  `@rollup/rollup-win32-x64-msvc` devDependency pin (documented in
  `WEBSITE_ARCHITECTURE.md`).

- Step-20 M29 final sweep COMPLETE: **M29 MILESTONE_COMPLETE** —
  menu dialog layer (`MenuDialogState` 5-variant sealed +
  `MenuScreenViewModel` + in-`Stack` `MenuDialogLayer` + `PopScope`),
  `MenuScreenUiEvent` giảm 2-variant senior; settings chrome verbatim
  (`iconAsset` FR-30); leaderboard visual/data parity (FR-28
  residual); onboarding visual parity verbatim (FR-32); full 50-asset
  parity + `AppAssets` 45 consts; ARB key parity + casing convention
  (FR-31); `MenuTokens` retired→`AppTokens`/`OnboardingTokens`;
  `AppDependencyScope`/`main.dart`/nav-controller verbatim; preview
  appendix (fixtures + 3 catalogs; 6 senior catalogs documented
  absent); release-kit walkthrough doc; folder audit = learner `lib/`
  ⊆ senior (zero learner-only production files). 309→396 tests, site
  167 pages. Replay 8/8 checkpoints green, tree byte-identical.
  Mutation check PASS (`requestLeaderboardDialog`→`MenuDialogSettings`
  caught by VM test). **Fidelity register: zero `ACTIVE_TEMPORARY`
  rows** — FR-29/30/31/32 all CONVERGED. Deliberate documented
  exceptions only: package name, `level_config` int64→JS-safe max,
  `entryFromRow` `@visibleForTesting` seam, 6 preview catalogs absent,
  `appTitle` product rename, `REAL_DEVICE_*`/`LIVE_*` NOT_PERFORMED.
- **Course M01–M29 COMPLETE.** All gates passed per milestone:
  Atlas brief → Flux impl → Argus impl QA → IMPLEMENTATION_APPROVED →
  Lumen content → Argus content QA → CONTENT_APPROVED → Forge site →
  Argus site QA → SITE_APPROVED → sequential replay → final
  regression → post-PASS mutation check → canonical sync.

- Step 21: **Independent pedagogy + senior-fidelity audit** —
  external audit of all 132 lessons. Verdict
  `NOT_RELEASE_READY_PEDAGOGY`; senior fidelity `PASS`; copy/port
  dependence risk MEDIUM. Ratings: 58 STRONG / 65 ACCEPTABLE /
  9 NEEDS_ENRICHMENT / 0 REWRITE. Findings: 0 critical, 4 high,
  5 medium, 3 low. Principal defect: M01–M13 independent practice —
  13/44 lessons had `## Tự làm`; no isolated runnable examples before
  M14. Reports: `report/STEP-21-FINAL-PEDAGOGY-SENIOR-FIDELITY-AUDIT.md`,
  `STEP-21-LESSON-PEDAGOGY-HEATMAP.md`,
  `STEP-21-PEDAGOGY-FINDINGS-REGISTER.md`.
- Step 22: **Pedagogy-QA governance hardening** — independent
  Pedagogy Reviewer role + `course-pedagogy-review` skill +
  `PEDAGOGY-REVIEW-CONTRACT.md`; dual technical+pedagogy review on the
  same immutable `CONTENT_REVISION` required by Atlas; both reviews
  invalidated by learner-facing edits; gates G17–G23 assigned to
  Pedagogy Reviewer, G24 stays with Argus. Commit `97e85ed` on `main`.
  Report: `report/STEP-22-PEDAGOGY-QA-SYSTEM-HARDENING.md`.
- Step 23: **M01–M13 pedagogy enrichment** — COMPLETE. Additive
  remediation only: 33 lesson files edited; `## Tự làm` coverage
  13/44 → **44/44**; 20 lessons now carry `## Ví dụ độc lập`
  runnable examples (DartPad-friendly, zero new deps). Exercise levels:
  PREDICT-dominant, PRODUCE/MODIFY at M02–M06, DEBUG at M04/M10.
  Three prereq/answer-key drifts caught and fixed (M03 `${}` leak,
  M09 dialog wiring, M10 `_ResultAction` contract). Per-milestone
  dual review + Atlas verdict + 167-page build ×13 — all PASS.
  Evidence: `AI_HANDOFF/work/step-23-pedagogy-remediation/m01–m13/`.
  Regression: analyze clean, **396/396 tests**, learner app zero diff,
  M14–M29 untouched, no M30.
  Report: `report/STEP-23-M01-M13-V2-PEDAGOGY-ENRICHMENT.md`.
  Step-23A closeout verification: **PASS** — `flutter build web` PASS
  (real run), CORE isolated-example denominator 34/34 COVERED (0
  missing), edited-file arithmetic reconciled (34, report typo
  corrected), 13/13 original exercises accounted, 44/44 `Tự làm`
  independently verified, zero leaks, senior/app/M14+ untouched.
  Report: `report/STEP-23A-CLOSEOUT-VERIFICATION.md`.
- Step 24: **M16–M22 targeted pedagogy remediation** — COMPLETE on
  branch `remediation/step24-m16-m22-pedagogy` from Step-23 checkpoint
  `529a544`. All 36 lessons audited; 35 lesson files + 7 indexes
  modified. Interventions: `## Tự làm` added to m16/02–04, m17/02–04,
  m19/02, m19/05 (PRODUCE/DEBUG/DERIVE-level tasks, including the
  m16/05→m17/04 cross-lesson `'Phiên bản'` migration); m20/02
  DERIVE-first lifeline rule tables before verbatim helpers; m20/03
  three `Giai đoạn` phase boundaries (no route split); m19/04 three
  `Điểm nghỉ` pause points; m22/04 explicit save-once mental model
  wired to its planted-bug exercise. Technical fix: `GamePhase.answered`
  → `answeredRevealed` prose reference. ~260 learner-facing internal-ID
  tokens removed across the band (M23–M29 untouched). Per-milestone
  dual review (Argus + Pedagogy Reviewer) on same `CONTENT_REVISION`
  + Atlas approval ×7 — all PASS. Regression: analyze clean,
  **396/396 tests**, `flutter build web` PASS, site build 167 pages,
  learner app zero diff, M01–M15/M23–M29 untouched, senior untouched,
  no M30.
  Report: `report/STEP-24-M16-M22-TARGETED-PEDAGOGY-REMEDIATION.md`.
- Step 25: **M23–M29 derive-first + late pedagogy remediation** —
  COMPLETE on `remediation/step25-m23-m29-derive-first`, checkpoint
  `9323e57`. Derive-first prompts landed at m23/02, m24/02, m25/03,
  m26/03, m27/03, m28/01, m29/01/04/05/06; m26/04 five-phase load map;
  m28/06 A/B/C structure; ~1,106 prose registry-ID tokens removed;
  ~3,450 hyphenation normalizations. Per-milestone dual review + Atlas
  approval — all PASS. Regression: analyze clean, 396/396 tests,
  `flutter build web` PASS, site 167 pages, learner app unchanged.
  Evidence: `AI_HANDOFF/work/step-25-pedagogy-remediation/`.
- Step 26: **Independent full-course pedagogy re-audit** — COMPLETE
  (read-only audit of `9323e57`, content revision `48f8f30f9cc62a22`;
  artifacts committed inside `79249c6`). Verdict
  `NOT_RELEASE_READY_PEDAGOGY`: 1 PEDAGOGICAL_BLOCKER (m12/02) + 12
  LEARNING_RISK + ~56 FRICTION + ~35 NOTE. Ratings 67/52/12/1.
  Reports: `report/STEP-26-FINAL-FULL-COURSE-REAUDIT.md`,
  `STEP-26-PEDAGOGY-FINDINGS-REGISTER.md`, `STEP-26-LESSON-PEDAGOGY-HEATMAP.md`.
- Step 26A: **Targeted final remediation** — COMPLETE on
  `remediation/step26a-final-release-blockers`, checkpoint `79249c6`,
  frozen CONTENT_REVISION `3c62ec07839270` (EOL-invariant fingerprint
  `a9ab104c665a0605`). All 14 Step-26 plan items resolved; 3
  remediation-discovered M12 defects fixed (m12/01 context.read step +
  widget-test `AppDependencyScope` seam, m12/03 lazy/eager); ~50
  broken tables repaired; governance vocabulary removed from learner
  prose. Argus PASS + Pedagogy `PEDAGOGY_PASS_WITH_NOTES` on the same
  frozen revision. Regression: analyze clean, 396/396, build web PASS,
  167 pages. Learner app zero diff; senior untouched; no M30.
  Report: `report/STEP-26A-TARGETED-FINAL-REMEDIATION.md`.
- Step 27: **Release closeout** — Step-26A gate independently
  re-verified from repository+report evidence (blockers 0, risks 0,
  both reviews PASS on the same frozen revision); content freeze
  reproduced; `main` fast-forwarded `97e85ed`→`79249c6`; full
  regression green on main; `origin/main` synced. Deployment: no
  existing configuration — Vercel static deploy of `web/` remains the
  documented future target (`WEBSITE_ARCHITECTURE.md`); content ready
  for manual or connected deployment. Artifacts:
  `AI_HANDOFF/work/step-27-release-closeout/`.
  Report: `report/STEP-27-RELEASE-CLOSEOUT.md`.
- Deployment hotfix (unnumbered): `676c448` removed the direct
  Windows-only `@rollup/rollup-win32-x64-msvc` devDependency that broke
  Vercel Linux builds (`EBADPLATFORM`). Build PASS, 167 pages.
- Step 28: **Production verification + Vercel canonicalization** —
  COMPLETE. Production `flutter-opal.vercel.app` verified live
  (real-browser smoke M01/M12/M21/M26/M29 + nav + mobile 375px +
  desktop 1440px + Pagefind search functional); production bytes
  byte-identical to local build of accepted main; no internal
  artifacts/local paths/secrets exposed. Metadata commit `1a38e5b`
  set `site:` (canonical URL + sitemap now emitted, 166 URLs) and
  added `robots.txt`/`favicon.svg`. Git auto-deploy CONFIRMED on both
  projects; canonical = `flutter` + `flutter-opal.vercel.app`;
  `flutter_course` = duplicate (cleanup recommended, deferred).
  `VERCEL_TOKEN` cannot read either project (different scope) — API
  fields recorded from human-supplied deployment metadata.
  Regression after change: analyze clean, 396/396 tests, build web
  PASS, Astro 167 pages. Artifacts:
  `AI_HANDOFF/work/step-28-production-verification/`.
  Report: `report/STEP-28-PRODUCTION-VERIFICATION-VERCEL-CANONICALIZATION.md`.
- Step 29: **Per-lesson AI Local project-alignment review layer** —
  COMPLETE on `main`-checkout (pending push decision). All 132 lesson
  pages carry a trailing `## 🤖 AI Local — Kiểm tra project sau bài
  này` section: 119 copy-ready Vietnamese reviewer prompts
  (read-only contract, per-lesson EXPECTED STATE + INVARIANTS,
  ahead/behind/diverged classification, fixed OUTPUT ending
  `FILES_MODIFIED_BY_REVIEW: NONE`) + 13 NO_REVIEW honesty notes;
  classification 73 DELTA / 36 INTEGRATION / 10 MILESTONE_GATE /
  13 NO_REVIEW (`registry.json/.md`). Mechanical validators
  `validate_sections.py` + `audit_sections.py`: 0 failures/0 findings
  (coverage, duplicates, placeholders, output contract, future-leakage,
  generic-prompt, no-review reason, solution-leak). Frozen revision
  `CONTENT_REVISION 36301c0f4b6f4835` reviewed twice: full review on
  `c8a1d5f8461b3c02` (Argus PASS + Pedagogy
  `PEDAGOGY_PASS_WITH_NOTES`) then delta review on the PED-001
  intro-fix revision (Argus PASS + Pedagogy
  `PEDAGOGY_PASS_WITH_NOTES` — PED-001 resolved; PED-002..006 notes
  stand). Regression: learner-app analyze clean, **396/396 tests**,
  `flutter build web` PASS, Astro 167 pages/166 indexed, learner-app
  zero diff, senior untouched. Site preview QA: section renders with
  copy button; 375px/1440px inherit Starlight; ~20% index-word share
  accepted trade-off. Artifacts:
  `AI_HANDOFF/work/step-29-ai-local-review/` (incl.
  `reviews/05-content-qa.md`, `reviews/05-pedagogy-review.md`).
  Report: `report/STEP-29-AI-LOCAL-ALIGNMENT-REVIEW-LAYER.md`.

## Next recommended task
Course M01–M29 `RELEASE_READY_WITH_NOTES` + Step-29 AI Local layer
COMPLETE locally. Recommended: push the Step-29 checkpoint commit to
`main` → Vercel auto-deploy (human authorization required), then
production observation + learner feedback baseline (the deferred
original Step-29 recommendation). Optional deferred cleanup:
duplicate Vercel project `flutter_course` (see step-28 artifact 09).
Post-release editorial polish backlog remains at
`AI_HANDOFF/work/step-27-release-closeout/post-release-editorial-backlog.md`.
M30 does not exist on the roadmap.