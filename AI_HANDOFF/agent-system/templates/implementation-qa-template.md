# IMPLEMENTATION QA — M{N}: ⟨name⟩

> Reviewer: Argus (`argus-course-qa-reviewer`) — independent
> Artifact under review: `02-implementation-evidence.md` ⟨revision⟩ +
> `learner-app/` diff
> Verdict: **PASS | FAIL | BLOCKED**

## Intake gate

| Required input | Present? |
|---|---|
| `01-brief.md` | ⟨Y/N⟩ |
| `02-implementation-evidence.md` | ⟨Y/N⟩ |
| Roadmap M{N} section + decisions | ⟨Y/N⟩ |
| Learner-app diff on disk | ⟨Y/N⟩ |

⟨If any N → verdict is BLOCKED; name what is missing and stop.⟩

## Gates applied (stage-3 set: G1 G2 G3 G4 G5 G9 G12 G15)

| Gate | Result | Evidence |
|------|--------|----------|
| G1 Roadmap compliance | PASS/FAIL/NOT_RUN | ⟨what was compared⟩ |
| G2 Prerequisite closure | ⟨…⟩ | ⟨…⟩ |
| G3 Senior evidence | ⟨…⟩ | ⟨files opened⟩ |
| G4 Implementation correctness | ⟨…⟩ | ⟨diff review⟩ |
| G5 Runnable transition | ⟨…⟩ | ⟨…⟩ |
| G9 Premature-concept firewall | ⟨…⟩ | ⟨terms grepped⟩ |
| G12 Test/build verification | ⟨…⟩ | ⟨commands re-run/inspected⟩ |
| G15 State honesty | ⟨…⟩ | ⟨…⟩ |

## Findings

```text
ID:        QA-IMPL-001
Severity:  BLOCKING | NON_BLOCKING
Artifact:  ⟨file + section⟩
Evidence:  ⟨path / symbol / command / diff⟩
Why it fails: ⟨gate + reason⟩
Owner:     Flux | Atlas
Required fix: ⟨what PASS requires⟩
```

⟨repeat per finding; "no findings" must still list the checks performed⟩

## Commands re-run by Argus

⟨list + outcomes, or "inspected recorded output only" — honest⟩

## Verdict rationale

⟨one paragraph tying verdict to findings⟩
