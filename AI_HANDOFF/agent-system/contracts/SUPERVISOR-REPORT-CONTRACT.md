# SUPERVISOR REPORT CONTRACT — Atlas → THE HUMAN / supervising ChatGPT

Reports live in `D:\vibe_coding\flutter\report\STEP-XX-NAME.md` and must
be **fully self-contained** — the supervisor has no filesystem access.
After writing, append one row to `report/REPORT_INDEX.md` (never delete
old rows).

## Required structure (milestone reports)

```markdown
# STEP XX — ⟨milestone range + theme⟩

## Verdict                    PASS | PARTIAL | BLOCKED
## Objective                  what was in scope, what was excluded
## Inputs Read                canonical files + senior evidence inspected
## Starting Regression        baseline before any change
## M{N} Summary               per milestone: lessons table + app changes
                              + senior evidence + gate results
## Final Learner App State    honest end-state description
## Lesson Routes              all routes, verified in dist/
## Android Bridge Audit       bridge-format compliance
## Senior Evidence Audit      every citation listed, path+symbol only
## Premature Concept Audit    explicit scan results (list terms checked)
## Code ↔ Lesson Consistency  how consistency was verified
## Website Verification       build output, page count, known warnings
## Flutter Verification       gate table (analyze/test/build per milestone)
## Runtime Verification       what was/wasn't run — no fabrication
## Visual QA                  performed or NOT_PERFORMED_*
## Regression Results         earlier milestones still coherent
## Canonical Files Created / Modified
## Website Files              touched paths
## Learner App Files           touched paths
## Senior Source Check         path, branch, HEAD, git status, changed?
## Scope Check                 YES/NO list including explicit negatives
## Unverified Items            honest list
## Blockers                   NONE or list
## Recommended Next Phase      exactly one recommendation
## Final Machine-Readable Summary   ```text KEY: VALUE block```
```

## Rules

- **Evidence before verdict.** The report cites actual command output
  (counts, not just "passed") and actual paths.
- **Scope check includes negatives** — "M13 implemented: NO" is a
  meaningful assertion, not filler.
- **Honest limitations.** Unverified items are listed, never hidden. A
  report that hides a skipped check fails G15.
- **Machine-readable block is literal.** `KEY: YES|NO` lines, no prose
  inside the fenced block.
- **Reports are artifacts, not authority.** Findings that must persist
  are mirrored into `project-context/` by Atlas — a report alone does
  not change canonical state.
- One milestone (or one bounded task) per report. Never batch silently.
