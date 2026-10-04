# TEAM SMOKE TEST — Agent Product v1.0

A **non-production** dry-run that verifies workflow mechanics end to end.
It uses a hypothetical documentation-only milestone (`MX`) that touches
**no** learner-app code, **no** website content, and **no** canonical
state. It validates the machine, not the course.

**Safety invariants (must remain true):**

- `learner-app/**`, `web/**`, `project-context/**` — untouched
- No `AVAILABLE` flips; no `DECISIONS.md` entries; no milestone state
  changes
- All artifacts live under `AI_HANDOFF/work/smoke/MX/` (never
  `work/milestones/` — smoke runs are not milestones)
- The harness may be deleted afterward, or kept as the record that v1.0
  was exercised

## Scenario

Hypothetical milestone **MX — "Add a docs README section explaining where
to find the roadmap"**. Purely documentation-shaped so the artifact chain
can be exercised without real course work. The run intentionally injects
two defects to verify remediation routing.

## Procedure

| Step | Role hat | Action | Artifact | Proves |
|------|----------|--------|----------|--------|
| 1 | Atlas | Create `AI_HANDOFF/work/smoke/MX/`, write `00-status.md` (state `MILESTONE_PLANNED`), write `01-brief.md` from the template — scope: "a README note"; explicitly exclude code/site changes | `00-status.md`, `01-brief.md` | Brief mechanics + scope allow-list |
| 2 | Flux | Write `02-implementation-evidence.md` describing a *hypothetical* docs-only change — label everything `IMPLEMENTATION DECISION`/`NOT VERIFIED` honestly; **inject defect A**: claim a verification command was run that was not | `02-*` | Evidence contract + honest labeling |
| 3 | Argus | Review `02-*`: catch defect A (a `VERIFIED` claim with no output = G12/G15 violation) → `FAIL` with a formatted finding | `03-*` v1 | Argus catches unverified claims; FAIL routing works |
| 4 | Flux | Remediate: correct the label to `NOT VERIFIED`, resubmit | `02-*` r2 | Remediation loop |
| 5 | Argus | Re-review → `PASS` (record the remediation) | `03-*` v2 | Re-QA path |
| 6 | Atlas | Issue `IMPLEMENTATION_APPROVED` — **first verify the negative**: attempt the transition with a FAIL artifact → must be refused by the contract | `00-status.md` log | "no approval without PASS" enforcement |
| 7 | Lumen | Write `04-content-draft.md` + one toy `lessons/index.md` skeleton describing the docs change; **inject defect B**: one unexplained first-appearance term | `04-*`, `lessons/` | Draft contract |
| 8 | Argus | Content QA (technical) → catch defect B (G7 violation) → `FAIL` | `05-content-qa.md` v1 | First-appearance gate works |
| 8b | Pedagogy Reviewer | Independent review of the same `CONTENT_REVISION` — **blind** (must not read `05-content-qa.md` first); catch defect C: injected lesson whose only "teaching" is a pasted snippet with no mental model (P3/P7 violation) → `PEDAGOGY_REVISION_REQUIRED` | `05-pedagogy-review.md` v1 | Pedagogy instruments work; blindness recorded |
| 9 | Lumen | Remediate both findings → resubmit new revision; **both** reviewers re-review the new fingerprint; Argus `PASS`, Pedagogy `PEDAGOGY_PASS` | `05-*` v2 (both) | Same-revision + staleness loop closes |
| 10 | Atlas | `CONTENT_APPROVED` — **first verify the negative**: attempt approval while only Argus PASS exists → refused (dual-PASS rule); write `06-site-handoff.md` | `06-*` | Dual-PASS approval + handoff mechanics |
| 11 | Forge | Write integration report **without touching `web/`** — the smoke test simulates the site stage (documented; real site integration is out of smoke scope) | report section | Handoff consumption, boundary respect |
| 12 | Argus | Site QA on the simulated integration → `PASS` (noting simulation scope) | `07-*` | Stage-9 mechanics |
| 13 | Atlas | `SITE_APPROVED` → write `08-final-verdict.md` → **verify no canonical state was touched** | `08-*` | Final verdict chain + isolation |

## Pass criteria

- [ ] Every artifact exists on disk in order (01→08 + status ledger)
- [ ] Defect A caught at implementation QA (not by Atlas, not by luck)
- [ ] Defect B caught at Argus content QA; defect C caught at Pedagogy Review
- [ ] `IMPLEMENTATION_APPROVED` was refused while only FAIL existed
- [ ] `CONTENT_APPROVED` was refused while only the Argus PASS existed (dual-PASS rule)
- [ ] Both stage-6 reviews name the same `CONTENT_REVISION` fingerprint
- [ ] The second reviewer did not read the first's artifact before its verdict
- [ ] Lumen never started before `IMPLEMENTATION_APPROVED`
- [ ] Forge consumed only approved material
- [ ] Zero writes outside `AI_HANDOFF/work/smoke/MX/`
- [ ] `00-status.md` shows a legal transition chain per `STATE-MACHINE.md`
- [ ] Final verdict cites all required PASS artifacts

## Failure handling

A failed smoke check = an Agent Product defect, not a course defect. Fix
the canonical system (contracts/agent defs/machine), re-run the smoke
chain in a fresh `MX-r2/` dir, and record the fix in the verdict report.

## Explicitly out of scope

- Real M13 production work — never smoke-test with real scope
- Native subagent dispatch validation (runtime-specific; the adapter
  READMEs describe the models honestly)
- Website file writes (simulated; G13/G14 get real coverage on the first
  real milestone run)
