# M18 — Onboarding overlay (first run)

State: `MILESTONE_COMPLETE`

## Ledger

- Atlas brief written — `01-brief.md` (senior source inspected:
  overlay_scope/overlay/step_actions/indicator/content/step_data/VM/
  repo, 16 senior ARB keys captured, LanguageChipRow promotion planned).
  Flux dispatched.
- Flux implementation done — `02-implementation-evidence.md`; analyze
  clean; 102/102 tests; gen-l10n + build web pass; register deltas:
  FR-32 new, FR-27 extended, FR-31 updated (pending Atlas write).
  Argus impl QA dispatched.
- Argus impl QA: **PASS** (1 MINOR test-gap → asserted + 7/7 rerun;
  1 NIT accepted under FR-32). `03-implementation-qa.md` written.
  Register: FR-32 OPEN, FR-27 extended, FR-31 updated.
  **Atlas: IMPLEMENTATION_APPROVED.**
- Lumen content authored — `04-content-draft.md` + index + 5 lessons.
  Registry D-32/F-26/A-17 TAUGHT; prereq graph M18 appended. ARB keys
  placed at L02 (before L04 call sites). Argus content QA dispatched.
- Argus content QA #1: **FAIL** (1 MAJOR — compressed skeleton used,
  non-droppable sections omitted undeclared; minors: missing
  hint/answer formatting, L03 exercise too revealing, index missing
  canonical synthesis, unlabeled non-compiling step, thin
  frontmatter).
- Lumen remediation: all 5 lessons + index rewritten to canonical
  Template V2 skeleton; folds declared in manifest; Tự làm exercises
  re-shaped with `<details>` hint/answer blocks; frontmatter
  `description`+`sidebar.label` added; L04 Bước 2 labelled
  non-compiling; index `Tổng kết milestone` 5-question synthesis
  added. Manifest drops declaration corrected to match reality.
  Argus content re-verify dispatched.
- Argus content QA #2: **PASS** (MINOR×2 registry-ID + MINOR format +
  NIT×2 wording — all remediated). Targeted re-verify on post-PASS
  mutations: **PASS**. `05-content-qa.md` written.
  **Atlas: CONTENT_APPROVED.**
- Forge site integration done — `06-site-handoff.md`,
  `07-site-integration.md`; 6 byte-identical routes; 95 pages;
  sidebar/roadmap/index/concepts/state-progression updated.
- Argus site QA: **PASS** (`08-site-qa.md`; 1 pre-existing roadmap
  phase-grouping observation flagged, out of scope).
- Sequential replay on M17-end clone: **5/5 checkpoints PASS**, zero
  defects — `09-sequential-replay.md`.
- Canonical sync: CURRENT_STATE, CONTENT_STATUS, register
  (FR-27/31/32), registry (D-32/F-26/A-17), prereq graph,
  `M18_IMPLEMENTATION_NOTES.md`, `11-m18-handoff-to-m19.md`.
- **Atlas final verdict: MILESTONE_COMPLETE** — `10-final-verdict.md`.
  Hard stop before M19 per run contract.
