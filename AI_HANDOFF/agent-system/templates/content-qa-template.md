# CONTENT QA — M{N}: ⟨name⟩

> Reviewer: Argus (`argus-course-qa-reviewer`) — independent, technical
> surface only. Learning quality is reviewed separately by the Pedagogy
> Reviewer (`05-pedagogy-review.md`) — do not read it before this verdict.
> Artifact under review: `04-content-draft.md` + `lessons/**` ⟨revision⟩
> Verdict: **PASS | FAIL | BLOCKED**

## Intake gate

| Required input | Present? |
|---|---|
| `01-brief.md` | ⟨Y/N⟩ |
| `02-*` with `IMPLEMENTATION_APPROVED` | ⟨Y/N⟩ |
| `04-content-draft.md` + all `lessons/*.md` | ⟨Y/N⟩ |
| Roadmap section + decisions | ⟨Y/N⟩ |
| On-disk learner app (for snippet diffs) | ⟨Y/N⟩ |

## Gates applied (Argus technical set: G1 G2 G3 G6 G7 G8 G9 G10 G11 G15 G24)

| Gate | Result | Evidence |
|------|--------|----------|
| G1 Roadmap compliance | ⟨…⟩ | ⟨…⟩ |
| G2 Prerequisite closure (milestone-level) | ⟨…⟩ | ⟨…⟩ |
| G3 Senior evidence | ⟨…⟩ | ⟨files opened⟩ |
| G6 Beginner followability | ⟨…⟩ | ⟨contract checklist⟩ |
| G7 First-appearance explanation | ⟨…⟩ | ⟨concept sweep results⟩ |
| G8 No hidden steps | ⟨…⟩ | ⟨steps↔diff delta⟩ |
| G9 Premature firewall | ⟨…⟩ | ⟨terms grepped⟩ |
| G10 Code↔lesson consistency | ⟨…⟩ | ⟨snippets spot-checked⟩ |
| G11 Android bridge correctness | ⟨…⟩ | ⟨bridge list⟩ |
| G15 State honesty | ⟨…⟩ | ⟨…⟩ |
| G24 Sequential executability | ⟨…⟩ | ⟨per-lesson checkpoint replay⟩ |

> **G17–G23 are NOT in this table.** Concept depth, learning prerequisite
> closure, mental-model quality, independent transfer, active learning,
> cognitive load, and template completeness are owned by the Pedagogy
> Reviewer — see `05-pedagogy-review.md`. This artifact must not assert
> them.

## Per-lesson structural check

| Lesson | 16 sections present? | Snippets match disk? | First-appearances explained? | Checkpoint reachable at this step? |
|--------|----------------------|----------------------|------------------------------|------------------------------------|
| `01-…` | ⟨Y/N — missing⟩ | ⟨Y/N⟩ | ⟨Y/N⟩ | ⟨Y/N⟩ |

## Findings

```text
ID:        QA-CONT-001
Severity:  BLOCKING | NON_BLOCKING
Artifact:  ⟨lesson file + section⟩
Evidence:  ⟨what was checked⟩
Why it fails: ⟨gate + reason⟩
Owner:     Lumen | Atlas (routing) | Flux (if defect is implementation)
Required fix: ⟨what PASS requires⟩
```

## Verdict rationale

⟨one paragraph — technical truth only, no learning-quality claims⟩

## Companion review status (mandatory)

```text
CONTENT_REVISION:             ⟨fingerprint — PEDAGOGY-REVIEW-CONTRACT §2⟩
PEDAGOGY_REVIEW_REQUIRED:     YES
PEDAGOGY_REVIEW_ARTIFACT:     ⟨05-pedagogy-review.md path or "pending">
CONTENT_TECHNICAL_QA:         PASS | FAIL | BLOCKED
```
