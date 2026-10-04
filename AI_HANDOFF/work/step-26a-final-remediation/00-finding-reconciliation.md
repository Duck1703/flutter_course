# STEP 26A — FINDING RECONCILIATION

Authority: `D:\vibe_coding\flutter\report\STEP-26-PEDAGOGY-FINDINGS-REGISTER.md`
(hash `4de04fa262b82c73`), cross-checked against the master report
(`1e16967f7a3273da`) and Phase-A frozen findings.

## 12-vs-13 ambiguity — RESOLVED

The register contains **exactly 12 LEARNING_RISK sections**, IDs
F26-R-02 through F26-R-13 inclusive. There is no F26-R-01 and no R-14.
The master report's narrative "13 learning risks" (and the "12-vs-13"
count in FINDINGS_SUMMARY) was an off-by-one in the summary prose —
the register's own `### F26-R-NN` headings are the authoritative
inventory and they number 12.

**Canonical totals:**
- BLOCKER_COUNT_CANONICAL=1 (F26-B-01)
- LEARNING_RISK_COUNT_CANONICAL=12 (F26-R-02..R-13)
- Total release-blocking finding IDs = 13
- TARGETED_PLAN_ROWS=14 (rows 1–13 map 1:1 to the 13 IDs; row 14 is the
  FRICTION-level noise/debris/index repair group)
- ALL_BLOCKERS_MAPPED=YES
- ALL_RISKS_MAPPED=YES
- UNMAPPED_FINDINGS=NONE

## Mapping — finding ID → plan row → site → group

| Finding | Sev | Site | Plan row | Group |
|---------|-----|------|----------|-------|
| F26-B-01 | BLOCKER | m12/02 | 1 | C |
| F26-R-02 | RISK | m04/04 | 2 | B |
| F26-R-03 | RISK | m08/04 | 3 | B |
| F26-R-04 | RISK | m09/04 | 4 | B |
| F26-R-05 | RISK | m10/04 | 5 | B |
| F26-R-06 | RISK | m11/03 | 6 | B |
| F26-R-07 | RISK | m14/02 | 7 | D |
| F26-R-08 | RISK | m20/01 | 8 | D |
| F26-R-09 | RISK | m02/02 | 9 | A |
| F26-R-10 | RISK | m02/03 | 10 | A |
| F26-R-11 | RISK | m03/03 | 11 | A |
| F26-R-12 | RISK | m28/05 | 12 | E |
| F26-R-13 | RISK | m29/04 | 13 | E |
| (FRICTION group) | FRICTION | m27/03, m27/05, m27/06, m29/02, m29/index, m04/index + listed debris | 14 | F |

## Register rulings applied

- **Capstone (m29/07)**: Step-26 register classes it as F26-F-41 FRICTION
  ("underpowered" but self-contained and honest). NOT release-blocking →
  left for post-release backlog. No capstone redesign in 26A.
- **CORE example gaps**: non-blocking per register (friction-level) →
  residual notes only; no automatic backfill.
- **Soft prerequisite leaks** (firstWhere, fold, late final, PopScope…):
  FRICTION → out of scope EXCEPT `NavigatorObserver` in m08/04, which is
  inside plan row 3 (F26-R-03) → resolved there by removing the
  untaught observer requirement.
