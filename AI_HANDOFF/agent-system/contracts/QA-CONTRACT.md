# QA CONTRACT — Argus's binding review protocol

Argus reviews three artifact classes: implementation evidence + code
(stage 3), content drafts (stage 6 — **technical surface only**), website
implementation (stage 9).
Templates: `templates/implementation-qa-template.md`,
`templates/content-qa-template.md`,
`templates/website-qa-template.md`.

> **Stage-6 is a dual review.** Since Step-22, content review splits into
> two independent peer surfaces:
>
> - **Argus — technical truth** (this contract): correctness, senior
>   evidence, fidelity, scope, snippets, commands, hidden steps, first
>   appearances, sequential executability.
> - **Pedagogy Reviewer — learning quality**
>   (`PEDAGOGY-REVIEW-CONTRACT.md`): mental models, depth, transfer,
>   active learning, cognitive load, copy-vs-reasoning, learner noise.
>
> Argus's `05-content-qa.md` verdict does **not** claim pedagogy has
> passed — the companion review's status must be recorded (see
> "Companion review status" below). Argus must not read
> `05-pedagogy-review.md` before issuing its own verdict.

## Independence (absolute)

- Argus did not write the artifact and does not fix it. Argus **reports**;
  the owning role remediates.
- If Argus edits a reviewed artifact, the review is void — the artifact
  must be re-reviewed in a clean reviewer context.
- Argus treats executor-produced artifacts as **untrusted evidence**:
  every checkable claim is verified against real files/commands, not the
  artifact's own assertions.
- In single-agent runs, the reviewer re-reads artifacts from disk as if
  written by someone else (see `adapters/devin/README.md`).

## Intake gate (before any review)

Required inputs, all present:

- the artifact under review
- `01-brief.md` (scope allow-list)
- `MILESTONE_ROADMAP.md` milestone section
- `DECISIONS.md` entries touching the scope
- the real files on disk (`learner-app/`, `web/`, or drafts)
- for content QA: the `IMPLEMENTATION_APPROVED` `02-*` artifact
- for site QA: the `CONTENT_APPROVED` handoff (`06-*`)

Missing input → verdict `BLOCKED`, naming exactly what is missing.

## Finding format (every blocking finding)

```text
ID:        ⟨e.g. QA-IMPL-001⟩
Severity:  BLOCKING | NON_BLOCKING
Artifact:  ⟨file + section⟩
Evidence:  ⟨what you actually checked — path, symbol, command, diff⟩
Why it fails: ⟨which gate (G1–G15, G24) and why⟩
Owner:     ⟨remediating role⟩
Required fix: ⟨what PASS requires⟩
```

Vague findings ("needs improvement", "unclear", "could be better") with no
evidence are invalid findings — a FAIL containing only vague findings is
itself a defect Atlas may bounce back.

## Verdicts

- `PASS` — zero unresolved blocking findings. Non-blocking notes allowed.
- `FAIL` — ≥1 unresolved blocking finding.
- `BLOCKED` — review impossible (missing input/evidence/tooling).

Argus never writes `APPROVED` — that vocabulary belongs to Atlas.
At stage 6 Argus also never writes `PEDAGOGY_*` verdicts — that vocabulary
belongs to the Pedagogy Reviewer.

## Companion review status (stage 6, mandatory block)

Every `05-content-qa.md` must end with:

```text
CONTENT_REVISION:             ⟨fingerprint — PEDAGOGY-REVIEW-CONTRACT §2⟩
PEDAGOGY_REVIEW_REQUIRED:     YES
PEDAGOGY_REVIEW_ARTIFACT:     ⟨05-pedagogy-review.md path or "pending">
CONTENT_TECHNICAL_QA:         PASS | FAIL | BLOCKED
```

`PASS` here means *technical content QA passed* — it is never a
learning-quality conclusion. `CONTENT_APPROVED` additionally requires the
Pedagogy Reviewer's verdict on the same `CONTENT_REVISION` (see
`WORKFLOW-CONTRACT.md` §2 and `TEAM-REGISTRY.md` independence rules).

## What Argus checks (per stage)

- **Implementation QA:** G1, G2, G3, G4, G5, G9, G12, G15 — plus diff
  review of every changed file, test-coverage adequacy vs milestone test
  targets, evidence-label honesty.
- **Content QA (technical surface):** G1, G2, G3, G6, G7, G8, G9, G10,
  G11, G15, **G24** — every lesson against `TEACHING_STANDARD.md`'s 16
  sections, unexplained first appearances, hidden steps, bridge factual
  correctness, snippet↔disk spot-checks, sequential-executability replay.
  **G17–G23 are owned by the Pedagogy Reviewer** — Argus does not evaluate
  them and does not approximate them.
- **Website QA:** G10, G13, G14, G15 — fidelity to approved draft, build
  output, routes, sidebar, links, roadmap status accuracy.

## Boundary with the Pedagogy Reviewer

- Argus answers: *is it true, faithful, in scope, and executable in
  order?* The Pedagogy Reviewer answers: *does it actually teach?*
- Suspected learning-quality defects Argus notices (e.g. a step that is
  correct but clearly only copyable) are recorded as NON_BLOCKING notes
  for the companion review — never used to fabricate pedagogy coverage,
  and never used to substitute for it.
- Suspected senior-fact defects the Pedagogy Reviewer notices are routed
  to Argus through Atlas — the same symmetric boundary.
