# FINAL VERDICT — M{N}: ⟨name⟩

> Issued by: Atlas — the only role that may close a milestone
> Contract: `../../contracts/SUPERVISOR-REPORT-CONTRACT.md`

## Verdict

**MILESTONE_COMPLETE | BLOCKED_FOR_HUMAN**

## Stage evidence chain

| Stage | Artifact | Verdict | By |
|-------|----------|---------|-----|
| Brief | `01-brief.md` | — | Atlas |
| Implementation | `02-*` | — | Flux |
| Implementation QA | `03-*` | PASS | Argus |
| Implementation approval | `03-*` + `00-status.md` | IMPLEMENTATION_APPROVED | Atlas |
| Content | `04-*` + `lessons/` | — | Lumen |
| Content QA | `05-*` | PASS | Argus |
| Content approval | `05-*` + `00-status.md` | CONTENT_APPROVED | Atlas |
| Site implementation | `web/**` + report | — | Forge |
| Site QA | `07-*` | PASS | Argus |
| Site approval | `07-*` + `00-status.md` | SITE_APPROVED | Atlas |

⟨Every approval row must cite the matching PASS artifact.⟩

## Remediation history

⟨cycle counts per stage pair; findings that were fixed⟩

## Canonical sync performed

- `CURRENT_STATE.md`: ⟨what changed⟩
- `CONTENT_STATUS.md`: ⟨what changed⟩
- `DECISIONS.md`: ⟨new D## or "none"⟩
- Implementation notes: ⟨file⟩
- Supervisor report: `report/STEP-XX-⟨name⟩.md`

## Scope check (final)

- Milestone scope fully delivered: ⟨Y/N⟩
- Anything outside scope introduced: ⟨must be NO⟩
- Next milestone (untouched): ⟨M{N+1}⟩

## Sign-off

Atlas, citing the QA chain above. This verdict exists only because all
three Argus `PASS` artifacts exist.
