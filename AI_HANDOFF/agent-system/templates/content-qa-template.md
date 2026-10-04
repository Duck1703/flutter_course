# CONTENT QA — M{N}: ⟨name⟩

> Reviewer: Argus (`argus-course-qa-reviewer`) — independent
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

## Gates applied (stage-6 set: G1 G2 G3 G6 G7 G8 G9 G10 G11 G15)

| Gate | Result | Evidence |
|------|--------|----------|
| G1 Roadmap compliance | ⟨…⟩ | ⟨…⟩ |
| G2 Prerequisite closure | ⟨…⟩ | ⟨…⟩ |
| G3 Senior evidence | ⟨…⟩ | ⟨files opened⟩ |
| G6 Beginner followability | ⟨…⟩ | ⟨contract checklist⟩ |
| G7 First-appearance explanation | ⟨…⟩ | ⟨concept sweep results⟩ |
| G8 No hidden steps | ⟨…⟩ | ⟨steps↔diff delta⟩ |
| G9 Premature firewall | ⟨…⟩ | ⟨terms grepped⟩ |
| G10 Code↔lesson consistency | ⟨…⟩ | ⟨snippets spot-checked⟩ |
| G11 Android bridge correctness | ⟨…⟩ | ⟨bridge list⟩ |
| G15 State honesty | ⟨…⟩ | ⟨…⟩ |

## Per-lesson structural check

| Lesson | 16 sections present? | Snippets match disk? | First-appearances explained? |
|--------|----------------------|----------------------|------------------------------|
| `01-…` | ⟨Y/N — missing⟩ | ⟨Y/N⟩ | ⟨Y/N⟩ |

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

⟨one paragraph⟩
