# Decisions Log

Only decisions actually established are recorded. New entries append at the
bottom with a date.

## D01 — 2026-10-01 — Senior source is immutable reference evidence
`D:\vibe_coding\flutter\flutter-accelerator-ai` is read-only. It is never
edited, formatted, upgraded, or committed to. Audits are performed by
static inspection.

## D02 — 2026-10-01 — Progressive reconstruction, no bulk copy
The learner project rebuilds the senior application's functionality
feature-by-feature. Senior source informs the target; it is not copied
wholesale.

## D03 — 2026-10-01 — Repository context is canonical, not AI memory
`project-context/` inside the course workspace is the durable memory. AI
conversation history is never required to continue the project. The project
must stay portable across Devin, Claude Code, Cursor, WorkBuddy, and other
agentic environments.

## D04 — 2026-10-01 — Beginner-level Flutter assumption
Curriculum and explanations assume a learner who knows programming,
Android/Kotlin, and Compose, but is a beginner in Dart and Flutter. Flutter
concepts are always introduced properly.

## D05 — 2026-10-01 — Android experience is a bridge, not a substitute
Android/Compose analogies may accelerate understanding, but differences
must be called out explicitly and misleading analogies documented
(`ANDROID_TO_FLUTTER_MAP.md`).

## D06 — 2026-10-01 — Curriculum not finalized before senior-source audit
No milestones, lesson sequences, or course roadmap may be defined before
the senior repository audit (this phase) is complete and reviewed.

## D07 — 2026-10-01 — External supervisor reports
Every substantial task ends with a self-contained Markdown report in
`D:\vibe_coding\flutter\report\` named `STEP-XX-SHORT-NAME.md`, plus a row
appended to `report/REPORT_INDEX.md`. Reports must be reviewable without
filesystem access — they carry their own evidence.

## D08 — 2026-10-01 — Audit findings recorded (informational, not a design choice)
Verified during Step 01: the senior app uses provider-based DI
(`AppDependencyScope`), plain `ChangeNotifier` VMs plus a project-local DRE
reducer for the game, imperative two-route navigation, SharedPreferences
persistence, and optional Supabase. These are **evidence**, not learner
architecture decisions — learner-side architecture is decided in the
curriculum phase.

## D09 — 2026-10-01 — Roadmap structure & teaching policy (Step 02)
The course is organized as **29 milestones (M01–M29)** across seven phases:
A orientation, B small-app foundation, C core local loop, D state
architecture, E richer local app, F senior-feature depth, G senior
alignment. Governed by `COURSE_ARCHITECTURE.md`; lesson contracts in
`TEACHING_STANDARD.md` and `LESSON_TEMPLATE.md`; feature/concept mapping
in `CURRICULUM_TRACEABILITY.md`.

Milestone count was derived — not chosen — from `DEPENDENCY_GRAPH.md` and
`FEATURE_INVENTORY.md` under two rules: one coherent conceptual jump per
milestone, and no milestone may require an untaught concept.

Senior complexity is reached through documented simplification ladders
(e.g., setState → ChangeNotifier+Provider → DRE; `showDialog` → sealed
state-driven in-Stack layer; raw prefs → repository contract +
`BehaviorSubject` → sync). The learner meets each abstraction only after
feeling the problem it solves. Advanced items are deliberately late or
appendix: DRE (M26), in-Stack dialog layers (M21/M29), Supabase/auth
(M23–M25; Apple = appendix), notifications (M27), stale-async guards
(M23–M26), CustomPainter/animation depth (M28), release kit (M29
appendix), widget previews (M29 optional tooling). This resolves the D06
"pending curriculum" point — architecture is designed, pending only
supervisor approval.

Milestone generation must follow `MILESTONE_ROADMAP.md` and the teaching
contracts; any resequencing during lesson writing requires a new entry
here plus an update to `CURRICULUM_TRACEABILITY.md`.

## D10 — 2026-10-01 — Course website: Astro + Starlight, static-first (Step 03)
The course website lives in `web/` and uses **Astro 5 + @astrojs/starlight**
with Markdown/MDX content collections, npm, and static output — no backend,
auth, CMS, analytics, or API routes. Rationale: docs-shaped content,
zero-infrastructure deployability, and file-based content keeps the project
portable (D03). Full policy in `WEBSITE_ARCHITECTURE.md`.

## D11 — 2026-10-01 — Learner app location and package (Step 03)
The learner Flutter project lives in `learner-app/` with package name
`ai_millionaire_course`, platforms `android`, `ios`, `web`. Through M03 it
uses **only Flutter/Dart SDK functionality — zero third-party packages**
(counter template and its sample widget test removed; testing arrives at
M04). The on-disk app always represents the *end of the latest implemented
milestone* (currently end-of-M03); per-milestone states live in lesson
content, not in git history.

## D12 — 2026-10-01 — Website customization minimalism (Step 03)
Starlight-native features (asides, cards, sidebar autogenerate) plus a
single `src/styles/custom.css` are the only customization layers. No custom
component framework; recurring lesson blocks stay heading/aside conventions
per `LESSON_TEMPLATE.md`. Learning clarity over visual effects.

## D13 — 2026-10-01 — Language policy (Step 03)
All learner-facing prose is Vietnamese; official API/tool names and code
identifiers remain English (`StatefulWidget`, `setState`, `flutter run`…).
Natural technical Vietnamese, not literal translation.

## D14 — 2026-10-01 — Code ↔ lesson consistency policy (Step 03)
Every code block shown in lessons must either (a) match the verified on-disk
learner app exactly, or (b) be clearly labelled as an intermediate/diff step
of a checkpoint already verified at the time it existed. Lesson code is never
authored independently of a compiled state. QA audits each milestone before
its step report may claim PASS.

## D15 — 2026-10-01 — Learner profile model shape (Step 04, M04)
The learner's profile model is `UserProfileData` at
`lib/data/profile/user_profile_data.dart` — same name and path as the senior
model (senior-parity target), but intentionally reduced to the 8 fields the
menu displays (`username`, `level`, `currentExp`, `expForNextLevel`,
`totalMoneyWon`, `gamesJoined`, `gamesWon`, nullable `avatarUrl`). Constructor
defaults equal the M03 hard-coded menu values so the UI is visually identical
after the model rewire. Hand-written `copyWith`/`==`/`hashCode` — no codegen
packages (equatable/freezed) — per the teaching contract; `expForNextLevel`
stays a field until `LevelConfig` parity in M22. The play-tap interaction
doubles as a "practice round" granting +10 EXP so immutable updates are
observable before real game results exist.

## D16 — 2026-10-01 — Demo async loader & FutureBuilder<void> policy (Step 04, M05)
Async teaching uses `loadDemoProfile({fail, delay})` in
`lib/data/profile/demo_profile_loader.dart` — an explicitly-labelled demo
loader, not a repository (no contract until M14). `MenuScreen` holds a stable
`late Future<void> _profileLoadFuture` (assigned in `initState`, re-assigned
on retry) feeding `FutureBuilder<void>` for load lifecycle; the loaded value
lands in the `_profile` state field via `mounted`-guarded `setState` so later
mutations (`gainExp`) stay coherent. Errors propagate through the Future (no
try/catch) → `snapshot.hasError`. `Future<void> main() async` +
`WidgetsFlutterBinding.ensureInitialized()` adopted as the senior bootstrap
shape even before any pre-`runApp` await exists.

## D17 — 2026-10-01 — Educational stream policy (Step 04, M06)
The first stream is `menuSessionTicker()` (`Stream.periodic`, 1s) rendered by
`StreamBuilder` in a "session elapsed" card — a value that naturally changes
over time without inventing game-timer architecture early (M09). Streams are
stable `final` fields in `State` (never created in `build` — same rule as
M05's stable Future). `listen`/`StreamSubscription`/`cancel`/`StreamController`
+`.broadcast()` are taught as clearly-labelled learning examples only; the app
itself uses `StreamBuilder`. rxdart `BehaviorSubject`/`ValueStream` stay
deferred to M14 as planned.

## D18 — 2026-10-02 — M07–M09 local session simplifications (Step 05)
- **Navigation (M07):** plain imperative `Navigator.push/pop` with anonymous
  `MaterialPageRoute`s — no `GoRouter`, no named routes, no `navigatorKey`
  wrapper. Senior's `AppNavigationController` is presented as comparison
  evidence, not copied. `popUntil((r) => r.isFirst)` is the "back to menu"
  primitive — chosen over two sequential `pop()` calls because the second
  synchronous pop can land on the still-exiting dialog route.
- **Quiz model (M08):** `QuizQuestion` = `question`/`options`/`correctIndex`
  + `isCorrect` — no `Difficulty` enum yet (senior has one; arrives when the
  bank needs it).
- **Session phases (M09):** `GamePhase` reduced to 3 values
  (`answering`/`revealing`/`finished`) vs senior's 6; `GameEndReason`
  (`wrongAnswer`/`timeout`/`victory`) carries the terminal cause. Both live
  in `lib/data/game/game_session_state.dart` mirroring senior's placement.
- **Timer:** `Timer.periodic(1s)` owned by `_GameScreenState`, **15 s per
  question** (senior uses 30 s — same mechanism, smaller constant for faster
  testing/exploration). Ownership rules taught explicitly: cancel before
  restart, cancel on `dispose`, guard callback by phase.
- **Endings:** standard `showDialog`/`AlertDialog` + `barrierDismissible:
  false`; senior's state-driven in-Stack dialog layer stays deferred to M21.
  A wrong answer ends the session (senior money-ladder/lifeline behaviour
  deferred — no ladder UI exists yet).
- **State ownership:** all session state stays widget-local `setState` —
  the file's ~580-line complexity is intentionally left as the motivation
  for M11+ `ChangeNotifier`/VM extraction. No persistence, no repository,
  no `ChangeNotifier` introduced.
- **Layout fix (found by widget test):** `_QuizBody` body column switched
  from `Spacer`-pinned to `Expanded` + `SingleChildScrollView` with a pinned
  footer after the victory-path test exposed a real 7px overflow.

## D19 — 2026-10-05 — M10 persistence choices (Step 06)

- **Storage class name:** `ProfileStore` (roadmap's learner-scope wording),
  not `LocalProfileStorage`/`ProfileRepository`. Deliberately a *concrete*
  class — no interface, no stream. Senior's `UserProfileRepository`
  contract + `BehaviorSubject` is M14; introducing either early would be
  premature abstraction. File: `lib/data/profile/profile_store.dart`.
- **Same storage key as senior:** `'user_profile'`, same
  `getString → jsonDecode → is Map → fromMap` + `FormatException → default`
  fallbacks, same `StateError` on failed `setString`. Differences: senior
  also handles legacy `totalEarnings` string (`_moneyFromDisplay` +
  `int.tryParse`) and a legacy-demo reset — learner skips both (no legacy
  data exists); roadmap-listed `int.tryParse` therefore not needed.
- **Result carriage:** `GameResult` value type in `data/game/` returned via
  `Navigator.pop(result)` + `push<GameResult>` — menu is the single place
  that applies results to the profile (apply-once = one push completes
  once). The M09 `popUntil(isFirst)` path is replaced by a
  `showDialog<_ResultAction>` → await action → `pop(result)` sequence:
  `popUntil` cannot carry a result, and the sequential pop pair is now
  properly `await`-separated (the original double-pop hazard).
- **Progression policy (documented simplified):** `gamesJoined + 1`,
  `gamesWon + (won ? 1 : 0)` — identical to senior
  `_saveGameResult`; money `= correctAnswers * moneyPerCorrectAnswer`
  (flat 50.000đ — senior uses the 15-rung money ladder, deferred to
  M20/M22); EXP `= correctAnswers * expPerCorrectAnswer` (50 — senior
  grants `earnedAmount` as EXP which would overflow the learner's
  flat-ladder caps instantly).
- **`_answeredCount`** counts *submitted* answers (incremented in
  `_submitAnswer`) — a timed-out in-progress question is not "answered".
- **Demo loader kept:** `demo_profile_loader.dart` remains as the M05
  teaching artifact (still covered by its own test) though app code no
  longer imports it after M10.
- **Reset action:** `ProfileStore.clear()` (`prefs.remove`) + profile reset
  to defaults — `remove` vs `setString('')` taught explicitly.

## D20 — 2026-10-05 — M11–M12 state/DI scope choices (Step 06)

- **VM extraction is menu-only.** `MenuViewModel` holds `_profile` +
  `_loadState` (`MenuLoadState { loading, ready, failed }` enum replacing
  `FutureBuilder` snapshot — plain enum, NOT sealed; sealed is M15).
  Ephemeral UI state (`_soundOn`, `_playTapCount`, `_sessionTicker`) stays
  in the widget `State` deliberately — the lesson teaches the boundary
  rule, not maximal extraction.
- **compare-before-notify:** `_setLoadState` guards no-op transitions;
  `resetProfile` notifies only when profile actually changed — mirrors
  senior `_handleUserProfile`'s `!=` check (roadmap bridge).
- **`GameScreen` stays `setState`** — per user instruction and roadmap
  ("game screen may keep setState until M19"). No `GameViewModel`.
- **M12 scope is deliberately small:** `AppDependencyScope` exposes exactly
  one app-level dependency (`Provider<ProfileStore>.value` — object created
  in `main()`). The roadmap row mentions settings store/navigation
  controller "matching senior" — those are **omitted as dummy dependencies**
  per the step brief ("small and honest"). No `MultiProvider` yet (single
  entry); no `Provider(create:)` at app level for store (owned by `main`,
  so `.value`); no navigation controller (menu navigates directly; senior's
  controller handles deeplinks/dialogs the learner app lacks).
- **Screen-level VM pattern mirrors senior verbatim:**
  `MenuScreen` = `StatelessWidget` → `ChangeNotifierProvider(create:
  (context) => MenuViewModel(store: context.read<ProfileStore>())..load())`
  → private `_MenuScreenView` StatefulWidget with ephemeral state +
  `context.watch` in `build` / `context.read` in `_onPlayTap`.
  `unawaited` import removed (load kicks off via cascade in `create:`).

## D21 — 2026-10-05 — Agent Product v1.0 operating model (Step 07)

- **Canonical process home:** `AI_HANDOFF/agent-system/` is the permanent
  tool-neutral definition of roles, workflow, gates, contracts, and
  templates. It is canonical for **process**; `project-context/` remains
  canonical for **state**. No canonical state is copied into the agent
  system (the Android reference's `AI_HANDOFF/canonical/` duplication was
  identified and deliberately not replicated).
- **Five roles, not four:** the Flutter course adds **Flux**
  (implementation engineer) because — unlike the Android reference, where
  the human owns the learner app — here the AI implements
  `learner-app/`; implementation therefore needs its own QA gate before
  content authoring may start.
- **Author ≠ approver, structurally:** Flux/Lumen/Forge write
  deliverables; Argus issues `PASS`/`FAIL`/`BLOCKED` only; only Atlas
  issues `*_APPROVED`/`MILESTONE_COMPLETE`, and only with the matching
  Argus `PASS` artifact on disk. No role approves its own output; Argus
  never fixes what it reviews.
- **Adapter separation:** `.claude/` and `agent-system/adapters/**` are
  thin pointers, never knowledge copies (the Android project's triplicated
  skill trees — `AI_HANDOFF/agent-system/skills` + `.agents/skills` +
  `.claude/skills` — are the documented drift failure to avoid).
- **Milestone work area:** `AI_HANDOFF/work/milestones/M{N}/` numbered
  artifacts (`00-status` … `08-final-verdict` + `lessons/`) are temporary
  production state; they never override `project-context/` and are never
  deleted after completion.
- **Single-agent honesty:** on single-executor runtimes (Devin), role
  independence is *simulated* via stage boundaries + on-disk artifacts +
  fresh re-reads; reports must state the simulation rather than claim
  real independence.
- **Report contract:** the existing `report/STEP-XX-*` + `REPORT_INDEX.md`
  pattern is preserved as the supervisor interface (the Android project's
  `review/M{N}/` bundle mechanism was not ported — this project's
  supervision model differs).
- **Versioning:** `v1.0` declared in `agent-system/README.md` +
  `AGENT_PRODUCT.md`; no semantic-release infrastructure.

## D22 — 2026-10-05 — M13 scope interpretation: game-side events deferred (Step 08)

**Context.** `MILESTONE_ROADMAP.md` M13's "Learner implementation scope"
line mentions a "game VM navigate-back event", but `GameScreen` has no
ViewModel by design (D20 keeps it `setState` until M19), and all three
M13 completion criteria are menu-side.

**Decision.** M13 implements only the menu-side event channel
(`MenuUiEvent` + broadcast controller on `MenuViewModel` + bridge in
`_MenuScreenViewState` + navigation/snackbar consumers). A one-event
`GameViewModel` is premature structure; the game navigate-back event
lands when `GameScreen` gets its real VM at **M19**. Recorded in
`AI_HANDOFF/work/milestones/M13/01-brief.md` §5 and `00-status.md`;
this decision file is the durable pointer so M14–M19 planning does not
re-litigate it.

**Also recorded under this milestone:** `unawaited` is exercised at its
natural site (`_handleUiEvent` → `unawaited(_openGame())`) per the M13
roadmap Dart line — surfaced by implementation QA (QA-IMPL-001), not a
new decision.

## D23 — 2026-10-07 — Permanent senior-fidelity rule & Step-10 remediation outcomes (Step 10)

**Rule (permanent, binding on all future milestones).** The senior app is
product truth: the course may explain progressively but may not creatively
substitute different product behavior, business rules, architecture
destination, state ownership, data flow, or feature semantics. Beginner
scaffolding is allowed only when clearly labelled temporary, the senior
form is shown, the difference is stated, an exact convergence milestone
exists, and it cannot be mistaken for final senior behavior. Enforced by
`project-context/SENIOR_FIDELITY_REGISTER.md` (every deviation = one row
with `Introduced` + exact `Converges at`) and quality gate **G16 —
Senior fidelity & convergence** (`AI_HANDOFF/agent-system/QUALITY-GATES.md`);
Atlas milestone briefs must include a SENIOR FIDELITY CHECK section
(`templates/milestone-brief-template.md` §5b).

**Step-10 remediation outcomes (supersessions — earlier decisions are
preserved as history, not erased):**

- **Supersedes D15 defaults:** `UserProfileData` constructor defaults now
  equal **senior defaults** (`'0XFF'`, level 1, EXP 0, `expForNextLevel`
  35000 = `LevelConfig` level-1 cap hardcode, `totalEarnings` `'0 VNĐ'`,
  `totalQuestionCount` 0 — fields added) instead of the M03 display values
  (`'Khách'`/120/400). `expForNextLevel` remains a registered field until
  M22 (FR-01). The +10 EXP practice-tap payoff was removed with the tap
  counter (FR-21).
- **Supersedes D19 reset:** `ProfileStore.clear()` (key removal) replaced
  by `reset()` = `save(const UserProfileData())` — identical semantics to
  senior `resetUserProfile()` (FR-24, CONVERGED). Demo loader deleted
  (FR-23, supersedes D19 "Demo loader kept").
- **Supersedes D17 ticker & D20 ephemeral-state scope:** M03–M06 menu
  scaffolds removed at remediation (sound toggle FR-20 → real persisted
  switch at M16; tap counter FR-21; session ticker FR-22 → real streams
  at M14). `MenuLoadState` documented as temporary (FR-08 → M14).
- **Roadmap convergence owners assigned:** portrait lock → M19 (FR-17);
  `GameQuizQuestionData` full shape → M19 (FR-10); M09 as-shipped scope
  annotation added (money ladder/reveal delay/explanation dialog → M19,
  guaranteed amount → M20); reset button retirement → M24 (FR-11);
  menu snackbar emit-site → M24 (FR-12); leaderboard tap → M23 (FR-14).
- **FD-10 documented as senior-source concern** (FR-25): senior drops the
  `openGame()` Future without `unawaited`; learner's explicit `unawaited`
  is kept and flagged — not a learner defect, never "fixed" senior-side.

## D24 — Step-13 — Permanent beginner-learning governance (Step 13)

**Rule (permanent, binding on all milestones from M15 onward).**
Beginner-learning quality and senior fidelity are **equal approval
dimensions**: a milestone cannot PASS one while failing the other.
Correct code + correct senior mapping is necessary but not sufficient.

Canonical instruments (created Step-13, all canonical):

- `LEARNER_CONCEPT_REGISTRY.md` — every meaningful concept gets a row:
  first taught, first code, prereqs, depth, reinforcement, exercise,
  status (PLANNED→INTRODUCED→TAUGHT→REINFORCED→MASTERED_EXPECTATION).
  Prevents code-before-theory.
- `PREREQUISITE_GRAPH.md` — the real course dependency chains; a
  lesson's `Bạn đã biết gì` claims must resolve to TAUGHT nodes.
- `CONTENT_GAP_REGISTER.md` — pedagogical gap ledger; no blocking gap
  may silently disappear (RESOLVED needs QA evidence).
- `BEGINNER_CONTENT_STANDARD.md` — LIGHT/NORMAL/CORE_CONCEPT depth
  levels; CORE_CONCEPT carries the full requirement set.
- `LESSON_TEMPLATE.md` V2 — flexible-but-binding structure; merged
  sections must be recorded as intentional.
- `QUALITY-GATES.md` **G17–G24** — concept depth, prerequisite
  closure, mental model, independent transfer, active learning,
  cognitive load, template completeness, sequential executability;
  each defines PASS/FAIL/evidence/owner/stage and Argus may FAIL on
  any of them.
- Lumen protocol: must read registry+graph before writing, assign
  depth per concept, provide isolated examples for CORE_CONCEPTs,
  include independent production, refuse overloaded lessons.
- Argus protocol: must verify learner-understanding (can explain /
  can transfer / sequentially executable / load acceptable /
  exercise exists) — not just correctness+fidelity.
- Atlas brief template: mandatory **LEARNING DESIGN CHECK** section
  beside SENIOR FIDELITY CHECK.
- Every milestone must carry ≥1 independent-production activity and a
  synthesis checkpoint; teaching scaffolds are marked at introduction
  with a named convergence milestone.

Smoke-tested (artifact `11-governance-smoke-test.md`): a deliberately
shallow hypothetical lesson fails G17/G19/G20/G21/G23; a corrected
one passes — gates discriminate.
