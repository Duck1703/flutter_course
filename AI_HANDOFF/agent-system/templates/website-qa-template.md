# WEBSITE QA — M{N}: ⟨name⟩

> Reviewer: Argus (`argus-course-qa-reviewer`) — independent
> Artifact under review: `web/**` diff + Forge integration report
> Verdict: **PASS | FAIL | BLOCKED**

## Intake gate

| Required input | Present? |
|---|---|
| `CONTENT_APPROVED` recorded | ⟨Y/N⟩ |
| `06-site-handoff.md` | ⟨Y/N⟩ |
| Forge integration report | ⟨Y/N⟩ |
| `web/` diff on disk | ⟨Y/N⟩ |

## Gates applied (stage-9 set: G10 G13 G14 G15)

| Gate | Result | Evidence |
|------|--------|----------|
| G10 Code↔lesson consistency (post-integration) | ⟨…⟩ | ⟨spot-checks⟩ |
| G13 Website fidelity vs approved draft | ⟨…⟩ | ⟨per-route check⟩ |
| G14 Link/navigation integrity | ⟨…⟩ | ⟨build output, routes⟩ |
| G15 State honesty | ⟨…⟩ | ⟨report claims vs reality⟩ |

## Build verification

```text
$ npm run build → ⟨pages count, exit code, warnings named⟩
```

## Route checklist

| Handoff route | Built? | Fidelity vs draft |
|---------------|--------|-------------------|
| `/m{N}/` | ⟨Y/N⟩ | ⟨Y/N + note⟩ |

## Findings

```text
ID:        QA-SITE-001
Severity:  BLOCKING | NON_BLOCKING
Artifact:  ⟨file/route⟩
Evidence:  ⟨what was checked⟩
Why it fails: ⟨gate + reason⟩
Owner:     Forge | Atlas (if content-level)
Required fix: ⟨what PASS requires⟩
```

## Verdict rationale

⟨one paragraph⟩
