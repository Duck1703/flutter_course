# QUALITY GATES — Flutter Course Agent Product v1.0

The reusable gate catalogue. Every gate names its PASS condition, FAIL
examples, owner (who must satisfy it), and evidence required. Reviewers
apply these gates at the matching QA stage; authors satisfy them before
handing off. **Review ownership is split at stage 6** (Step-22): Argus
owns technical truth; the Pedagogy Reviewer owns learning quality.

Gate → stage mapping:

| Stage | Gates enforced |
|-------|----------------|
| Implementation QA (Argus on Flux) | G1 G2 G3 G4 G5 G9 G12 G15 |
| Content QA — technical (Argus on Lumen) | G1 G2 G3 G6 G7 G8 G9 G10 G11 G15 **G24** |
| Content QA — learning quality (Pedagogy Reviewer on Lumen) | **G17 G18 G19 G20 G21 G22 G23** |
| Website QA (Argus on Forge) | G10 G13 G14 G15 G24 |
| Final verdict (Atlas) | all gates' verdicts present + PASSed |

Reviewer ownership summary (author → reviewer → approver):

| Gate | Author | Primary reviewer | Approver |
|------|--------|------------------|----------|
| G1–G15 technical gates | owning author per gate | Argus | Atlas |
| G17–G23 pedagogy gates | Lumen | **Pedagogy Reviewer** | Atlas |
| G24 sequential executability | Lumen (ordering) | Argus | Atlas |
| G16 senior fidelity | all (register discipline) | Argus | Atlas |

> Gates G17–G24 (added at Step-13 beginner-content remediation) make
> **beginner learning quality a co-equal approval dimension with senior
> fidelity**. A milestone cannot PASS fidelity and fail learning. Canonical
> definitions live in `project-context/BEGINNER_CONTENT_STANDARD.md`,
> `LEARNER_CONCEPT_REGISTRY.md`, `PREREQUISITE_GRAPH.md`, and
> `CONTENT_GAP_REGISTER.md` — those files are inputs to these gates.
> Since Step-22, G17–G23 are evaluated exclusively by the Pedagogy
> Reviewer through `contracts/PEDAGOGY-REVIEW-CONTRACT.md` (P1–P12);
> G24 remains with Argus as executable-replay truth.

---

## G1 — Roadmap compliance

- **PASS:** every learner-visible change traces to the milestone's section
  in `MILESTONE_ROADMAP.md` or the Atlas brief; nothing outside it.
- **FAIL examples:** a repository interface appears in an M10 deliverable
  (M14 owns it); extra feature "while we're here"; lesson count/content
  ignoring the brief's allow-list.
- **Owner:** all authors. **Evidence:** brief allow-list ↔ file/diff map
  in the artifact.

## G2 — Prerequisite closure

- **PASS:** everything the milestone uses was taught or introduced in this
  or a prior milestone per `DEPENDENCY_GRAPH.md`; no silent reliance on
  untaught concepts.
- **FAIL examples:** `context.read` used in M11 content (taught M12);
  lesson assumes learner knows `Listenable` before M11.
- **Owner:** Flux (implementation deps), Lumen (lesson deps).
  **Evidence:** prerequisite list per artifact; first-appearance table.

## G3 — Senior evidence accuracy

- **PASS:** every senior claim carries path + symbol and is verified
  against the actual file; labels match `SENIOR-EVIDENCE-CONTRACT.md`
  classes (`DIRECT_EVIDENCE` / `INFERENCE` / `TEACHING_SIMPLIFICATION` /
  `UNVERIFIED`).
- **FAIL examples:** citing `user_profile_repository.dart` for a pattern
  it doesn't contain; a claim labeled DIRECT_EVIDENCE that is inference;
  fabricated line numbers.
- **Owner:** Flux (primary), Lumen (in lessons), Argus (verification).
  **Evidence:** opened-file citations in artifacts; no `file:line`
  fabrication required or allowed.

## G4 — Implementation correctness

- **PASS:** learner code compiles, behaves as the milestone's
  completion criteria require, and matches the evidence artifact's claims.
- **FAIL examples:** apply-once logic that double-applies; a notifier
  never disposed; code differing from what the evidence describes.
- **Owner:** Flux. **Evidence:** test output, analyze output, diff.

## G5 — Runnable learner transition

- **PASS:** a learner at the end-of-previous-milestone state can reach the
  new state by following the lessons; every intermediate step compiles.
- **FAIL examples:** a step needs a file created three steps later; a
  snippet doesn't compile; "restart the app" without saying how.
- **Owner:** Lumen (steps), Flux (starting-state truth).
  **Evidence:** step-by-step compile points; `Run and observe` sections
  reproducible on the stated starting state.

## G6 — Beginner followability

- **PASS:** satisfies `BEGINNER-FOLLOWABILITY-CONTRACT.md` — every step
  says WHERE to edit, no unexplained syntax, no hidden files/commands,
  visible checkable result.
- **FAIL examples:** "add the store" without the file path; a step a
  senior dev could infer but a beginner cannot.
- **Owner:** Lumen. **Evidence:** the contract checklist applied per
  lesson.

## G7 — First-appearance explanation

- **PASS:** every Dart/Flutter concept's **first course appearance** is
  named, explained (role, syntax, why now), and linked as canonical;
  later uses name-check the original.
- **FAIL examples:** `StreamController.broadcast` appears in M13 code
  with no explanation; `extension` used before its intro milestone.
- **Owner:** Lumen; Argus hunts unexplained first appearances.
  **Evidence:** first-appearance table in `04-content-draft.md`.

## G8 — No hidden steps

- **PASS:** every action the learner must perform is in a step — files,
  edits, commands, pubspec changes, IDE actions, restarts.
- **FAIL examples:** `flutter pub add` result shown without the command;
  a test file expected but never created in any step.
- **Owner:** Lumen. **Evidence:** diff between lesson steps and actual
  learner-app diff = zero unexplained deltas.

## G9 — Premature-teaching firewall

- **PASS:** no future-milestone concept appears as an implementation
  dependency; naming a future concept inside "What we deliberately have
  not added yet" / "Senior project connection" is allowed.
- **FAIL examples:** `sealed class` in M13 code (M15 owns it); `rxdart`
  import in M10; `ProxyProvider` anywhere before its milestone.
- **Owner:** Flux (code), Lumen (content), Argus (enforcement).
  **Evidence:** grep-level audit listed in the artifact (terms scanned).

## G10 — Code ↔ lesson consistency

- **PASS:** lesson code matches the on-disk learner app **at that
  milestone** verbatim (or is explicitly labelled as intermediate
  simplification); superseded patterns are documented as evolution.
- **FAIL examples:** lesson shows `ListenableBuilder` while the app uses
  `watch` (unlabelled); snippet drifted after a late code change.
- **Owner:** Lumen + Forge (presentation must not alter code semantics);
  Argus spot-diffs. **Evidence:** snippet↔disk spot-check list.

## G11 — Android bridge correctness

- **PASS:** every bridge uses `SIMILARITY` / `IMPORTANT DIFFERENCE` /
  `DO NOT ASSUME`; no false equivalence.
- **FAIL examples:** "Widget is just Composable"; "`ChangeNotifier` is
  Android `ViewModel`"; "`BuildContext` is `Context`"; "`Future` is a
  coroutine"; "`Stream` is exactly `Flow`" — each missing the DIFFERENCE
  line is a defect.
- **Owner:** Lumen; Argus checks bridge claims against real semantics.
  **Evidence:** bridge sections per lesson.

## G12 — Test/build verification

- **PASS:** `flutter analyze` clean, `flutter test` green (count stated),
  `flutter build web` passes, per-milestone test targets exist; commands
  and counts recorded in evidence.
- **FAIL examples:** "tests pass" without output; skipping a known
  failing test; a milestone test target absent.
- **Owner:** Flux. **Evidence:** copied command outputs in
  `02-implementation-evidence.md`.

## G13 — Website fidelity

- **PASS:** site renders the APPROVED draft faithfully — same scope, same
  code semantics, same teaching order; presentation may change, meaning
  may not.
- **FAIL examples:** a callout softening a warning into a tip; dropped
  step; code reformatted into non-compiling form.
- **Owner:** Forge; Argus compares site output to approved draft.
  **Evidence:** per-route fidelity checklist in `07-site-qa.md`.

## G14 — Link/navigation integrity

- **PASS:** all routes build; sidebar entries resolve; prev/next ordering
  correct; no broken internal links; `roadmap.md` statuses accurate.
- **FAIL examples:** sidebar entry pointing at a missing slug; milestone
  marked AVAILABLE without pages; dead cross-references.
- **Owner:** Forge. **Evidence:** `npm run build` output + route list.

## G15 — Canonical-state honesty

- **PASS:** artifacts and reports state what is true — real test counts,
  real versions, explicit `UNVERIFIED`/`NOT VERIFIED` where applicable;
  workflow state and `CURRENT_STATE.md` agree.
- **FAIL examples:** claiming browser QA that didn't run; marking a
  milestone complete in state files before the final verdict; hiding a
  skipped check.
- **Owner:** everyone; Argus audits, Atlas accountable.
  **Evidence:** statements traceable to commands/files.

## G16 — Senior fidelity & convergence

> Added at Step-10 strict-fidelity remediation. Backed by the canonical
> register: `project-context/SENIOR_FIDELITY_REGISTER.md`.

- **PASS:**
  - every senior-parity claim in lessons/artifacts is grounded in cited
    senior source (file + symbol);
  - every implementation deviation from senior is classified and present
    in `SENIOR_FIDELITY_REGISTER.md`;
  - every temporary simplification has an `Introduced` value and an
    exact `Converges at` milestone — "later"/"M14+" without a terminal
    owner is a FAIL;
  - zero unregistered course-only product behavior in the learner app;
  - milestone brief contains a completed SENIOR FIDELITY CHECK section;
  - lessons label learner-vs-senior differences and never present a
    temporary scaffold as senior product behavior.
- **FAIL examples:** lesson claims learner pattern IS the senior pattern;
  invented defaults/feature values presented as product truth; a scaffold
  with no register entry or no convergence owner; register entry closed
  without the convergence milestone actually shipping; surviving dead
  teaching code presented as current source.
- **Owner:** Argus (may FAIL any stage on this gate); Atlas enforces via
  brief + final verdict; Flux opens entries in implementation evidence;
  Lumen labels them in lessons.
  **Evidence:** `SENIOR_FIDELITY_REGISTER.md` row + senior file:symbol
  citation + convergence milestone named in `MILESTONE_ROADMAP.md`.

## G17 — Beginner concept depth

> Added at Step-13. Backed by `BEGINNER_CONTENT_STANDARD.md` (depth levels).

- **PASS:** every concept in the lesson is taught to at least its registered
  depth (LIGHT/NORMAL/CORE_CONCEPT). A CORE_CONCEPT's first-teaching lesson
  covers the standard's items 1–11 (definition → purpose → mental model →
  syntax → runtime → lifecycle → when/when-not → isolated example → senior
  application → mistakes).
- **FAIL examples:** "`StatefulWidget` là widget có state" and nothing else;
  definition + snippet + Android analogy as the entire treatment; a
  CORE_CONCEPT's first appearance inside production code with no isolated
  example.
- **Owner:** Lumen writes; **Pedagogy Reviewer** judges depth against the
  standard, not the presence of keywords. **Evidence:** registry depth
  column ↔ lesson sections.

## G18 — Prerequisite closure (learning)

> Extends G2 from milestone-level to concept-level.

- **PASS:** every concept the lesson *uses* has a teaching node at or before
  it in `PREREQUISITE_GRAPH.md`; every "Bạn đã biết gì" claim resolves to a
  real earlier lesson that actually taught it (a mention in
  "cố ý chưa làm" does not count as taught).
- **FAIL examples:** claiming `factory`/`async*` was covered when it was
  only listed as deferred; using `pumpEventQueue` before any lesson explains
  it; assuming M12 `Provider` knowledge covers `MultiProvider`-by-contract.
- **Owner:** Lumen (declares), **Pedagogy Reviewer** (verifies each claim
  against the actual earlier lesson — taught, not merely named).
  **Evidence:** per-claim resolution to `CONCEPT_REGISTRY` rows + the
  earlier lesson text.

## G19 — Mental model present

- **PASS:** every CORE_CONCEPT in the lesson has an explicit mental-model
  section (the simplest accurate picture, plus its limits) — not merely a
  definition.
- **FAIL examples:** replay semantics of `BehaviorSubject` taught as a
  bullet list with no "holds latest value" picture; a lesson whose only
  model is the code itself.
- **Owner:** Lumen; **Pedagogy Reviewer** rejects "keyword coverage
  disguised as teaching" and heading-presence-as-model. **Evidence:**
  quoted model prose tested against the model questions
  (`PEDAGOGY-REVIEW-CONTRACT` P3).

## G20 — Independent transfer

- **PASS:** each CORE_CONCEPT has a tiny **isolated** example (runnable
  without the Millionaire app context) before or beside its production use;
  the milestone contains ≥1 activity where the learner produces something
  not spelled out (exercise, deliberate bug, completion task).
- **FAIL examples:** `BehaviorSubject` first seen only as
  `_userProfileSubject` inside a repo impl; all 48 lessons read→copy→run
  with zero learner production.
- **Owner:** Lumen (writes), **Pedagogy Reviewer** (verifies the example
  is genuinely isolated and the exercise genuinely requires production —
  difficulty-ledger instrument, contract P9).
  **Evidence:** isolated-example block + exercise block per milestone.

## G21 — Active learning

- **PASS:** every milestone contains ≥1 `Tự làm` production task with
  hint-before-solution presentation, and the milestone index carries the
  "Tổng kết milestone" synthesis questions; difficulty progresses
  RECOGNIZE→PREDICT→MODIFY→PRODUCE→DEBUG.
- **FAIL examples:** comprehension Q&A only; exercise = "change text A→B";
  solution shown before the task.
- **Owner:** Lumen; **Pedagogy Reviewer** classifies production tasks by
  level (RECOGNIZE→…→DERIVE) per milestone — heading presence is not
  counted. **Evidence:** exercise blocks + index synthesis sections +
  difficulty ledger.

## G22 — Lesson cognitive load

- **PASS:** ≤3 major new concepts per lesson; anything above carries an
  explicit Atlas split decision in the brief's LEARNING DESIGN CHECK.
- **FAIL examples:** one page introducing `abstract interface class` +
  `implements` + `BehaviorSubject` + `MultiProvider` + model parity + fakes.
- **Owner:** Atlas (split decision), Lumen (decomposition),
  **Pedagogy Reviewer** (evaluates KNOWN/NEW models + NEW→NEW chains per
  page — not raw concept-ID counts). **Evidence:** concept-load table per
  lesson in `05-pedagogy-review.md` + concept-count in
  `04-content-draft.md`.

## G23 — Template completeness

- **PASS:** the lesson contains all `LESSON_TEMPLATE.md` V2 sections required
  for its declared depth level; dropped sections name their reason.
- **FAIL examples:** a CORE_CONCEPT lesson missing mental-model, mistakes,
  or exercise sections; silent section loss vs the shipped M01–M13 norm.
- **Owner:** Lumen; **Pedagogy Reviewer** judges completeness against the
  declared depth level and named drop-reasons (Argus's per-lesson
  structural presence check remains an input, not the judgement).
  **Evidence:** section checklist in `04-content-draft.md` +
  pedagogy review P12 rows.

## G24 — Sequential executability

- **PASS:** a learner applying lessons strictly in order reaches every
  stated checkpoint; each checkpoint's claims (e.g. `flutter analyze`
  clean) are true of the code state *at that point in the sequence*.
- **FAIL examples:** "delete `profile_store.dart`, analyze is clean" while
  `menu_view_model.dart` still imports it until a later lesson; a step
  referencing a file created three pages later.
- **Owner:** Lumen (ordering), Argus (replays the sequence, not just the
  final state). **Evidence:** per-lesson checkpoint replay notes in the
  content-QA artifact (or a dedicated sequential-replay record).

---

## Finding severity

| Severity | Meaning | Effect |
|----------|---------|--------|
| BLOCKING | Wrong teaching, wrong code, scope violation, hidden step, unverifiable claim presented as fact, self-approval, security issue | Must be fixed; stage cannot pass |
| NON_BLOCKING | Cosmetic issues, wording, minor style, optional improvements | Recorded; does not hold the stage |

`SECURITY` findings are never downgraded to non-blocking.
