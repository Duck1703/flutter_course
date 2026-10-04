# WORKFLOW CONTRACT — Flutter Course Agent Product v1.0

> **Status: BINDING** for every milestone run under the Agent Product.
> Maintained by: Atlas. First binding milestone: M13.
>
> This contract records **process**, not state. For live course state,
> `project-context/CURRENT_STATE.md` is canonical and wins any conflict.
>
> Precedence — operating rules: this file → `TEAM-REGISTRY.md` →
> `contracts/*` → `skills/*` → active Atlas brief.
> Precedence — project state: `project-context/**` → everything else.

## 0. The two-state rule

- **Workflow state** (`AI_HANDOFF/work/milestones/M{N}/00-status.md`):
  temporary production ledger. Which stage is active, which artifacts
  exist, which verdicts were issued. Lives and dies with the milestone run.
- **Course state** (`project-context/CURRENT_STATE.md` +
  `CONTENT_STATUS.md`): canonical progress. Updated **only by Atlas**,
  **only at final verdict** (or a documented human-directed correction).
  Workflow state must never pose as course state.

## 1. Stage order (mandatory, no skipping)

| # | Stage | Owner | Mandatory artifact | Entry criteria | Exit criteria |
|---|-------|-------|--------------------|----------------|---------------|
| 0 | Milestone selection | Atlas | — | `CURRENT_STATE.md` names the milestone; supervisor authorized this run | Exactly one milestone selected; scope read from `MILESTONE_ROADMAP.md` |
| 1 | Brief | Atlas | `01-brief.md` | Stage 0 done | Brief complete per `templates/milestone-brief-template.md`; state = `BRIEF_READY` |
| 2 | Implementation | Flux | `02-implementation-evidence.md` + `learner-app/**` changes | `BRIEF_READY` | Evidence artifact complete; `flutter analyze` clean; `flutter test` green; `flutter build web` passes |
| 3 | Implementation QA | Argus | `03-implementation-qa.md` | Stage 2 artifact exists | Verdict `PASS` → 4; `FAIL` → back to 2; `BLOCKED` → Atlas |
| 4 | Implementation approval | Atlas | verdict recorded in `03-*` + `00-status.md` | Argus `PASS` | `IMPLEMENTATION_APPROVED`; state = `IMPLEMENTATION_APPROVED` |
| 5 | Content authoring | Lumen | `04-content-draft.md` + `lessons/*.md` | `IMPLEMENTATION_APPROVED` | Draft complete per `CONTENT-HANDOFF-CONTRACT.md` |
| 6 | Content review (dual, independent) | Argus **and** Pedagogy Reviewer | `05-content-qa.md` **and** `05-pedagogy-review.md` — same `CONTENT_REVISION` | Stage 5 artifacts exist | Argus `PASS` **and** Pedagogy `PEDAGOGY_PASS`/`PEDAGOGY_PASS_WITH_NOTES` → 7; either `FAIL`/`PEDAGOGY_REVISION_REQUIRED` → back to 5; `BLOCKED`/`PEDAGOGY_BLOCKED` → Atlas |
| 7 | Content approval | Atlas | verdict recorded; state = `CONTENT_APPROVED` | Both stage-6 reviews PASS on the **same revision fingerprint** | `CONTENT_APPROVED` issued |
| 8 | Site implementation | Forge | `web/**` changes + report section | `CONTENT_APPROVED` + `06-site-handoff.md` exists (Atlas issues handoff from approved draft) | `npm run build` passes; routes/sidebar integrated |
| 9 | Website QA | Argus | `07-site-qa.md` | Stage 8 done | `PASS` → 10; `FAIL` → back to 8; `BLOCKED` → Atlas |
| 10 | Site approval | Atlas | verdict recorded; state = `SITE_APPROVED` | Argus `PASS` | `SITE_APPROVED` issued |
| 11 | Final verdict + canonical sync | Atlas | `08-final-verdict.md`; `CURRENT_STATE.md`/`CONTENT_STATUS.md`/`DECISIONS.md` (if needed); `M{N}_*_IMPLEMENTATION_NOTES.md`; supervisor report in `report/` | `SITE_APPROVED` | `MILESTONE_COMPLETE`; report written; `REPORT_INDEX.md` row appended; **stop** |

`06-site-handoff.md` is produced by **Atlas** between stages 7 and 8 (it is
the approved-content→website contract), not by Lumen or Forge.

## 2. Verdict vocabulary

| Issuer | Values | Meaning |
|--------|--------|---------|
| Argus | `PASS` | Zero unresolved blocking findings. Notes allowed (non-blocking). |
| Argus | `FAIL` | ≥1 unresolved blocking finding; artifact returns to owner. |
| Argus | `BLOCKED` | Cannot review (missing input, missing evidence, tooling). Not a failure of the artifact. |
| Pedagogy Reviewer | `PEDAGOGY_PASS` | No unresolved learning findings above NOTE. |
| Pedagogy Reviewer | `PEDAGOGY_PASS_WITH_NOTES` | Findings limited to NOTE / minor FRICTION — approvable at Atlas's recorded judgement. |
| Pedagogy Reviewer | `PEDAGOGY_REVISION_REQUIRED` | ≥1 unresolved LEARNING_RISK or PEDAGOGICAL_BLOCKER; content returns to Lumen. |
| Pedagogy Reviewer | `PEDAGOGY_BLOCKED` | Cannot review (missing input/revision). Not a failure of the content. |
| Atlas | `IMPLEMENTATION_APPROVED` / `CONTENT_APPROVED` / `SITE_APPROVED` | Stage approved — **only** after the required review `PASS` verdicts. |
| Atlas | `CHANGES_REQUIRED` | Atlas accepts a FAIL routing or adds requirements; returns artifact to owner. |
| Atlas | `MILESTONE_COMPLETE` | Final verdict. Requires all three `*_APPROVED`. |
| Any | `BLOCKED_FOR_HUMAN` | A human gate (§7) was hit. Work stops. |

**`PASS`/`PEDAGOGY_PASS` (QA) is never `APPROVED`.** Reviewers validate;
Atlas approves. Atlas may not issue an `*_APPROVED` without the required
review artifacts present in the milestone directory.

**`CONTENT_APPROVED` requires BOTH stage-6 reviews on the same
`CONTENT_REVISION` fingerprint** (`PEDAGOGY-REVIEW-CONTRACT` §2/§7):

- Argus technical `PASS`, **and**
- Pedagogy `PEDAGOGY_PASS`, or `PEDAGOGY_PASS_WITH_NOTES` whose findings
  contain no LEARNING_RISK / PEDAGOGICAL_BLOCKER.

If either reviewer requires revision, `CONTENT_APPROVED` is forbidden.
Any edit to a reviewed learner-facing file after a review makes that
review **stale** — both reviewers re-review the new revision; no verdict
carries forward across fingerprints. Atlas may not override an unresolved
`PEDAGOGICAL_BLOCKER` without a recorded human decision (§7).

## 3. Remediation routing

| Finding | Route |
|---|---|
| Flux implementation technically wrong | Argus `FAIL` → Flux remediates → re-QA (stage 2→3) |
| Implementation violates milestone scope | Argus `FAIL` → Atlas reassesses brief; scope fix → brief revision noted in `01-brief.md` (dated addendum) or Flux remediation |
| Flux evidence claims `VERIFIED` without commands | Argus `FAIL` → Flux runs commands, corrects labels |
| Lumen explanation incorrect | Argus `FAIL` → Lumen remediates → re-QA (stage 5→6) |
| Lesson teaches poorly (weak model, copy-without-derivation, noise, overload, weak exercise) | Pedagogy `PEDAGOGY_REVISION_REQUIRED` → Lumen remediates per finding's remediation class → **both** reviewers re-review the new revision |
| Pedagogy finding actually an implementation/scope defect | Pedagogy `PEDAGOGY_REVISION_REQUIRED` → Atlas decides ownership (Flux/Lumen/brief) |
| Lumen must explain code that is itself too advanced | Argus `FAIL` → **Atlas decides** whether the defect belongs to Flux (simplify implementation) or Lumen (add micro-introduction + roadmap note) |
| Hidden step / unexplained first appearance | Argus `FAIL` → Lumen |
| Lesson shows code not in learner state | Argus `FAIL` → Lumen (or Flux if evidence artifact drifted) |
| Forge breaks layout/build/links | Argus `FAIL` → Forge remediates → re-QA (stage 8→9) |
| Forge finds content contradiction | Forge **must not** rewrite it → return to Atlas → Atlas routes to Lumen or issues a corrected handoff |
| Argus vs Atlas material disagreement, unresolved after one exchange | `BLOCKED_FOR_HUMAN` |
| Senior source contradicts canonical decisions | `BLOCKED_FOR_HUMAN` |

Max remediation cycles per stage-pair: **3**. Third consecutive `FAIL`
escalates to Atlas for root-cause reassessment (brief defect, wrong
sequencing, or a human gate).

## 4. Mandatory artifact chain

```
AI_HANDOFF/work/milestones/M{N}/
├── 00-status.md                     stage ledger (updated at every transition)
├── 01-brief.md                      Atlas
├── 02-implementation-evidence.md    Flux
├── 03-implementation-qa.md          Argus
├── 04-content-draft.md              Lumen (index + coverage manifest)
├── lessons/                         Lumen (draft lesson files)
│   ├── index.md                     milestone overview draft
│   └── NN-slug.md                   one file per lesson
├── 05-content-qa.md                 Argus (technical review)
├── 05-pedagogy-review.md            Pedagogy Reviewer (learning-quality review)
├── 06-site-handoff.md               Atlas (from approved draft)
├── 07-site-qa.md                    Argus
├── 08-final-verdict.md              Atlas
└── notes/                           optional scratch (never authority)
```

Missing required artifact at a gate = `BLOCKED` (Argus) or stage does not
advance (Atlas). Empty stub artifacts do not count.

## 5. Canonical state update rules

Atlas, at stage 11 only:

1. `CURRENT_STATE.md` — phase line, completed-milestone entry, pending
   list, next recommended task.
2. `CONTENT_STATUS.md` — milestone row → `IMPLEMENTED_PENDING_SUPERVISOR`;
   route table; decomposition rationale; QA note.
3. `DECISIONS.md` — append new `D##` entries **only** for real, durable
   decisions made during the run. Never renumber. Never edit history —
   supersede with a dated note.
4. `M{N}_M{n+2}_IMPLEMENTATION_NOTES.md` (or per-milestone notes file) —
   the durable handoff for the next step.
5. `report/STEP-XX-*.md` per `SUPERVISOR-REPORT-CONTRACT.md` + one row in
   `report/REPORT_INDEX.md`.
6. `web/src/content/docs/roadmap.md` status flip (AVAILABLE) is part of
   Forge's site stage, not a separate canonical edit.

Between milestones: `AI_HANDOFF/work/milestones/M{N}/` remains on disk as
the audit trail. It is never deleted, never "cleaned".

## 6. What stays forbidden for every role

- Modify the senior repo `flutter-accelerator-ai/` or the Android
  reference repo — read-only, no builds, no `pub get`, no commits there.
- Push, merge, publish, deploy — human authorization required, always.
- Commit secrets, keys, env files, credentials.
- Bulk-format / renormalize the repository.
- Write learner-facing claims that require access to the senior repo.
- Introduce a future-milestone concept as an implementation dependency
  without Atlas (and where required, human) approval — naming it in
  "not yet" / "senior connection" sections is allowed.
- Claim runtime observation that didn't happen. `VERIFIED` requires
  command output; static source reading yields `SOURCE EVIDENCE` only.

## 7. Human gates — stop conditions

The workflow stops with `BLOCKED_FOR_HUMAN` when ANY is true:

1. Roadmap intent needs changing (reorder, split, merge milestones).
2. Senior source contradicts canonical decisions.
3. A future concept must be introduced **early** as a dependency.
4. An architecture choice materially deviates from the senior target.
5. Public-facing teaching philosophy changes.
6. A dependency with major architectural impact is proposed.
7. Argus and Atlas cannot resolve a material disagreement — or Atlas
   disagrees with an unresolved `PEDAGOGICAL_BLOCKER` (no override without
   a recorded human decision).
8. Required source evidence is missing/insufficient.
9. `BLOCKED` persists after Atlas remediation attempt.
10. Anything irreversible (force-push, history rewrite, deletion) seems
    necessary.

Routine defects, QA failures, and remediation loops do **not** interrupt
the human.

## 8. Single-agent execution note

When the runtime provides one executor (e.g., Devin): roles are adopted
sequentially — one role hat per stage, artifacts written to disk between
stages, reviewer re-reads the artifact fresh. Argus must treat prior
executor output as untrusted evidence and verify against real files.
The stage-6 dual review runs as **two sequential hats on the same
revision**: whichever review runs second must not read the first
reviewer's artifact until its own verdict is frozen on disk.
This simulated separation is documented in `adapters/devin/README.md` and
is a **recorded limitation**, not a license to skip either review.
