# PEDAGOGY REVIEW CONTRACT — Pedagogy Reviewer's binding protocol

The Pedagogy Reviewer reviews one artifact class: **learner-facing
educational content** (milestone `04-content-draft.md` + `lessons/**` at
stage 6; remediated lessons at any later content-remediation step).
Template: `templates/content-pedagogy-review-template.md`.
Skill: `skills/course-pedagogy-review/SKILL.md`.

This contract is the second half of content QA. Argus's contract
(`QA-CONTRACT.md`) covers technical truth; this contract covers
**learning quality**. Neither reviewer substitutes for the other.

## 1. Independence (absolute)

- The reviewer did not write the artifact and does not fix it.
- If the reviewer edits a reviewed artifact, the review is void —
  re-review in a clean reviewer context.
- The reviewer **must not see Argus's `05-content-qa.md`** (or any
  companion review) before its own verdict is frozen on disk. Whichever
  review runs second never receives the first reviewer's report as
  input. Both inspect the same immutable revision independently; only
  Atlas receives both outputs.
- Author claims are untrusted evidence. A `Mental model` heading, a
  `Tự làm` heading, a registry `TAUGHT` status, or a passing test count
  is not proof of the underlying learning quality — the reviewer inspects
  the actual prose and the actual prior lessons.

## 2. Intake gate (before any review)

Required inputs, all present:

- `01-brief.md` (scope + LEARNING DESIGN CHECK)
- `IMPLEMENTATION_APPROVED` `02-*` (for milestone runs; for remediation
  reviews, the remediation brief/delta instead)
- `04-content-draft.md` + all `lessons/**` at one revision
- the fixed learner profile (agent definition §Learner profile)
- `LEARNER_CONCEPT_REGISTRY.md`, `PREREQUISITE_GRAPH.md`,
  `CONTENT_STATUS.md` — for prior-teaching verification
- `BEGINNER_CONTENT_STANDARD.md`, `TEACHING_STANDARD.md`,
  `LESSON_TEMPLATE.md`

Missing input → `PEDAGOGY_BLOCKED`, naming exactly what is missing.

**Content-revision fingerprint (mandatory).** The review artifact must
record a deterministic fingerprint of the reviewed revision:

```text
CONTENT_REVISION = sha1 of the sorted list of `git hash-object <file>`
                   for 04-content-draft.md + every lessons/** file
```

Any byte change to any reviewed file produces a different fingerprint →
see §7 staleness.

## 3. The P1–P12 review model

Each dimension below lists: definition → evidence the reviewer must
inspect → common failures → blocking vs preference.

### P1 — Learner readiness

- **Definition:** does the lesson assume only knowledge the learner has
  actually been *taught* (not merely mentioned) at this point?
- **Evidence:** the lesson's `Bạn đã biết gì`/dependency claims resolved
  against the actual earlier lessons; `PREREQUISITE_GRAPH` edges; Dart
  semantics, lifecycle, async, testing APIs, Provider semantics used
  silently.
- **Failures:** registry says `INTRODUCED` but the concept was only named
  in a "cố ý chưa" section; Android analogy doing the work of an untaught
  Flutter concept.
- **Blocking:** a CORE concept depends on untaught knowledge →
  PEDAGOGICAL_BLOCKER. A single thin recall of a well-taught concept →
  FRICTION at most.

### P2 — Felt problem before solution

- **Definition:** does the learner feel the limitation in *their current
  app* before the API/pattern appears?
- **Evidence:** the lesson's motivation section; whether the problem is
  stated as the learner's problem or as "senior has X".
- **Failures:** "Today we add X because the senior project has X";
  solution-first ordering throughout.
- **Blocking:** an entire milestone taught as port-without-need →
  LEARNING_RISK. One lesson with thin motivation → FRICTION.

### P3 — Mental-model quality (never heading presence)

- **Definition:** does the model let the learner answer: what exists?
  who creates it? who owns it? who modifies it? who observes it? when
  does it execute? how long does it live? who disposes it? where do data
  and events flow? what changes? what explicitly does NOT happen? For
  architecture lessons: which responsibility sits in UI / ViewModel /
  repository / service / domain / platform?
- **Evidence:** quote the model prose; test it against those questions.
- **Failures:** `TOO_ABSTRACT`, `TOO_TECHNICAL`, `AMBIGUOUS`,
  `TERM_DENSITY`, `MISSING_INTUITION`, `DEFINITION_WITHOUT_EXPLANATION`,
  `EXAMPLE_WITHOUT_MODEL`, `MODEL_WITHOUT_LIMITS`,
  `ANDROID_ANALOGY_OVERREACH`.
- **Blocking:** a CORE concept has no usable model or a misleading one →
  PEDAGOGICAL_BLOCKER / LEARNING_RISK. Terminology density with adequate
  explanation → FRICTION (terminology itself is not a defect).

### P4 — Explanation and terminology clarity

- **Definition:** is the learner-facing prose comprehensible to *this*
  learner — precise terms, Vietnamese register, no unexplained jargon?
- **Evidence:** sampled paragraphs; terminology the lesson uses without
  introducing; Vietnamese orthography consistency.
- **Failures:** internal pipeline jargon in learner text (also P11);
  systematic nonstandard orthography that impedes reading.
- **Blocking:** prose the learner cannot parse → LEARNING_RISK. Style
  preference → NOTE only. This dimension is not copy-editing.

### P5 — Cognitive load

- **Definition:** realistic simultaneous mental burden — count KNOWN
  models reused, NEW models introduced, and NEW→NEW dependency chains.
  One named architecture concept (e.g. "DRE") may internally carry many
  new mechanisms (marker interfaces, generic bounds, reducer, effects,
  async op, post-reduce snapshot, integration, disposal) — count them
  separately.
- **Evidence:** explicit KNOWN/NEW/chain enumeration per lesson; compare
  against the ≤3-major-concepts guideline (G22) and the brief's split
  decision.
- **Failures:** 5–6 new mechanisms in one page with no staging; a
  dependency chain where understanding B requires not-yet-taught C.
- **Blocking:** overload that makes the CORE concept unlearnable as
  written → LEARNING_RISK. High-but-organized load → FRICTION +
  split recommendation.

### P6 — Theory-to-code bridge

- **Definition:** can the learner point at production code and say "this
  line exists because of the concept I just learned"?
- **Evidence:** the chain problem → mental model → isolated/simple
  example (where warranted) → project implementation → observable result.
- **Failures:** correct theory + correct code + no connective tissue;
  concepts explained abstractly then never visibly used.
- **Blocking:** the CORE concept's production code is unexplained →
  LEARNING_RISK.

### P7 — Copy-vs-reasoning (explicit instrument)

- **Definition:** for every substantial implementation step, what must
  the learner reason about or produce **before** seeing the answer?
- **Evidence (per large step — the PORT ledger):**
  `PORT_VOLUME` (estimated new/ported lines) ·
  `DERIVATION_BEFORE_ANSWER` (YES/NO — does the learner predict the
  API/structure/transition first?) ·
  `LEARNER_PRODUCED_UNAIDED` (what, if anything) ·
  senior code treated as EVIDENCE or ASSIGNMENT.
- **Triggers to inspect:** `verbatim`, `port`, `port nguyên file`,
  `copy`, `replace entire file`, large final-file dumps.
- **Failures:** a >150-line file revealed-then-pasted with no derivation
  (unless explicitly non-learning infrastructure kept out of the core
  learning path); the primary learner activity across a milestone is
  transcription.
- **Blocking:** the milestone's CORE learning happens only by copying →
  LEARNING_RISK. Individual justified ports (labeled, peripheral) →
  NOTE. Verbatim senior code is **not** a defect per se — the missing
  derivation-before-answer is.

### P8 — Scaffold fading

- **Definition:** two axes — within-lesson (explanation → guided →
  independent) and across-course (guidance recedes as milestones
  advance; temporary scaffolds retire explicitly).
- **Evidence:** exercise types across the milestone map
  (RECOGNIZE→PREDICT→MODIFY→PRODUCE→DEBUG→DERIVE); scaffold labels and
  their convergence points; whether a late milestone reverts to pure
  transcription.
- **Failures:** M20+ lessons still structured "copy exact code, then
  understand it"; an unlabeled scaffold teaching false architecture;
  scaffold introduced but never retired.
- **Blocking:** course-wide regression from production to transcription
  with no derive-first steps → LEARNING_RISK.

### P9 — Active learning and transfer

- **Definition:** does the learner *do* something that requires the CORE
  concept without the answer visible — and could they transfer it outside
  the Millionaire app?
- **Evidence (per exercise — the difficulty ledger):** classify
  `RECOGNIZE | PREDICT | MODIFY | PRODUCE | DEBUG | DERIVE`; what the
  learner must produce unaided; whether the exercise tests the CORE
  concept; transfer potential to another domain.
- **Failures:** exercise = "rename text"/"change color" for a CORE
  concept; `Tự làm` counted but trivially answered from the prose above;
  milestone-level regression (PRODUCE/DEBUG earlier → copy+predict now).
- **Blocking:** a CORE concept milestone with zero production exercise →
  LEARNING_RISK. Weak-but-present exercise → FRICTION. For CORE concepts
  marked `MASTERED_EXPECTATION`: repeated same-project use supports
  `SAME_CONTEXT_MASTERY_SUPPORTED`; report `TRANSFER_MASTERY_UNPROVEN`
  unless at least a lightweight different-domain prompt exists — do not
  demand a whole Todo-app exercise.

### P10 — Misconception risk

- **Definition:** will the learner form a false model that *works* in
  this code but breaks understanding elsewhere?
- **Evidence:** each Android/Compose analogy checked for its stated
  limits; the dangerous-equivalence list (`Widget`=`Composable`,
  `BuildContext`=`Context`, `ChangeNotifier`=`ViewModel`, `Future`=
  coroutine, `Stream`=`Flow`, `Provider`=DI framework, `BehaviorSubject`=
  `StateFlow`, `remember`=persistence, `repository`=database, DRE=
  general Flutter architecture, local rollback=remote transaction
  rollback); project-specific choices presented as universal Flutter.
- **Failures:** an analogy with no `IMPORTANT DIFFERENCE`/limits line;
  "senior does X" phrased as "Flutter does X".
- **Blocking:** a false-equivalence taught without boundaries on a CORE
  concept → PEDAGOGICAL_BLOCKER. Thin limits on a peripheral analogy →
  FRICTION.

### P11 — Learner-facing governance noise

- **Definition:** internal bookkeeping that only helps the agent system
  occupying learner bandwidth.
- **Evidence:** count `A-xx`, `D-xx`, `F-xx`, `FR-xx`, `G-xx` tokens,
  test-count arithmetic (`→ 251/251`), audit vocabulary, and convergence
  IDs in learner prose/front-matter/`title:`/`description:`.
- **Failures:** prerequisite tables listing registry IDs the learner
  cannot decode; noise density rising exactly where content difficulty
  rises.
- **Blocking:** noise at a level that materially impedes comprehension →
  LEARNING_RISK. Scattered IDs → FRICTION/NOTE. Traceability IDs in
  internal docs are fine — this instrument is learner-facing only.

### P12 — Learning-outcome truth

- **Definition:** does the stated objective describe a capability the
  learner could actually have after this lesson — EXPLAIN / PREDICT /
  MODIFY / PRODUCE / DEBUG / DERIVE at the level appropriate for the
  milestone?
- **Evidence:** lesson objectives ↔ what the learner is actually asked to
  do; "file added"/"tests green" outcomes are not mastery.
- **Failures:** objective claims production while activity only supports
  recognition; mastery claimed on recall questions.
- **Blocking:** objective/activity mismatch on the CORE concept →
  LEARNING_RISK. Overstated minor objectives → FRICTION.

## 4. Finding format (every finding)

```text
ID:              PED-001
Level:           NOTE | FRICTION | LEARNING_RISK | PEDAGOGICAL_BLOCKER
Lesson:          ⟨file + section⟩
Concept:         ⟨concept or "—">
Evidence:        ⟨what was observed — quote/location/port-ledger row⟩
Learner risk:    ⟨what the learner fails to learn or mislearns⟩
Why pedagogical: ⟨why this is a learning defect, not a preference⟩
Required outcome:⟨what the learner must be able to do/explain after fix⟩
Remediation class: ENRICH | RESTRUCTURE | SPLIT | REMOVE_NOISE |
                 CLARIFY_MODEL | ADD_TRANSFER | ADD_DERIVATION |
                 GOVERNANCE_ONLY
Owner:           Lumen | Atlas (routing)
```

The reviewer names the required learning outcome, not the rewritten
lesson. Example allowed wording: *"Before revealing the 317-line
implementation, the learner should derive the repository's required
public API."* Forbidden: supplying the rewrite itself.

## 5. Verdicts

- `PEDAGOGY_PASS` — zero unresolved findings above NOTE.
- `PEDAGOGY_PASS_WITH_NOTES` — findings limited to NOTE or minor
  FRICTION. Allowed for `CONTENT_APPROVED` only per the Atlas rule
  (`WORKFLOW-CONTRACT.md` §2).
- `PEDAGOGY_REVISION_REQUIRED` — ≥1 unresolved LEARNING_RISK or
  PEDAGOGICAL_BLOCKER. `CONTENT_APPROVED` is forbidden until resolved.
- `PEDAGOGY_BLOCKED` — review impossible (missing input/revision
  uncertainty). Not a failure of the content.

The reviewer never writes `APPROVED`. Vague findings ("unclear", "could
be deeper") without evidence and a named missing outcome are invalid —
Atlas may bounce them back.

## 6. What this review is NOT

- Not technical/senior verification (Argus: file/symbol claims, snippet
  truth, commands, sequential replay, fidelity, scope).
- Not a copy-edit pass — style preference is NOTE at most.
- Not gated by structural metrics: word count, file size, heading counts
  are evidence *signals*, never verdicts. A short lesson can be
  excellent; a long lesson can be shallow.
- Not dependent on senior detail to excuse gaps — senior source may only
  be opened for project-specific-vs-general framing checks (then routed
  to Argus if the underlying fact needs verification).

## 7. Same-revision / staleness rule

- Both content reviews must apply to the **same** `CONTENT_REVISION`
  fingerprint.
- If Lumen modifies any reviewed learner-facing file after either
  review, the prior fingerprint is stale: the changed content requires
  **new** Argus review + **new** Pedagogy review on the new revision.
  No reviewer may carry a verdict forward from an older fingerprint.
- The review artifact records `CONTENT_REVISION`; Atlas verifies that
  both review artifacts name the same fingerprint of the revision being
  approved.

## 8. Handoff to Atlas

`05-pedagogy-review.md` lands in the milestone directory beside
`05-content-qa.md`. Atlas reconciles the two independently-produced
verdicts:

- technical `PASS` + `PEDAGOGY_PASS` (same revision) → eligible for
  `CONTENT_APPROVED`;
- technical `PASS` + `PEDAGOGY_PASS_WITH_NOTES` (same revision,
  notes/friction only) → eligible per `WORKFLOW-CONTRACT.md` §2;
- any `FAIL`/`PEDAGOGY_REVISION_REQUIRED` → remediation loop to Lumen;
- `BLOCKED`/`PEDAGOGY_BLOCKED` → Atlas resolves the missing input;
- reviewer-vs-Atlas disagreement on a PEDAGOGICAL_BLOCKER →
  `BLOCKED_FOR_HUMAN` — Atlas may not unilaterally override it.

## 9. Remediation-review mode (Step 23+ enrichment)

For content-remediation work outside milestone production, the intake
delta is:

```text
CURRENT LESSON(S)      ⟨paths at revision R0⟩
PREVIOUS LEARNER KNOWLEDGE ⟨registry/graph state assumed⟩
REMEDIATION DELTA      ⟨what the remediation claims to fix — findings IDs⟩
REVIEWED REVISION      R1 fingerprint
```

The reviewer judges R1 against the same P1–P12 model plus: did the delta
actually deliver the findings' required outcomes, and did it avoid
regressing other dimensions? No milestone production re-run is required.
