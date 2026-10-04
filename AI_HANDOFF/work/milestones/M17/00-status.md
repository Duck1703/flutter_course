# M17 — Localization (en/vi) — status ledger

State: `MILESTONE_COMPLETE`

## Ledger

- INIT — milestone dir created after M16 reached MILESTONE_COMPLETE
  (`M16/11-m16-handoff-to-m17.md`: prereqs YES).
- Atlas brief `01-brief.md` written (SENIOR FIDELITY + LEARNING DESIGN
  sections both present).
- Flux implementation complete — `02-implementation-evidence.md`
  written. Parent-verified: `flutter gen-l10n` OK, `flutter analyze`
  clean, `flutter test` 90/90, `flutter build web` √. FR-26 converged
  (whitelist `isSupportedCode`). Argus implementation QA dispatched.
- Argus impl QA: PASS (4 MINOR + 2 NIT, all remediated; fresh
  post-PASS re-verify on mutated ARB/dialog/pubspec/evidence/register
  → PASS, zero findings). `03-implementation-qa.md` written.
- **Atlas: IMPLEMENTATION_APPROVED** — FR-26 register status flipped
  to CONVERGED_M17; FR-31 row opened (l10n coverage delta).
- Lumen content authored — `04-content-draft.md` + 5 lessons +
  index in `lessons/`. Registry: D-31/F-25/A-16 added TAUGHT;
  prereq graph M17 section appended. Argus content QA dispatched.
- Argus content QA: r1 FAIL (4M+10m) → remediated → r2 FAIL (1M) →
  remediated → r3 FAIL (F-15 stale-write) → re-applied → r4 **PASS**.
  Physical sequential replay on M16-end clone: all checkpoints green
  (87/87→87→87→87→90/90 + web build). `05-content-qa.md` written;
  gap F-15 registered RESOLVED.
- **Atlas: CONTENT_APPROVED** — proceeding to Forge site integration.
- Forge site integration done — 6 lessons byte-identical in
  `web/src/content/docs/m17/`, sidebar/roadmap/index/concepts/
  state-progression updated, build = 89 pages, routes verified.
  `07-site-evidence.md` written. Argus site QA dispatched.
- Argus site QA: **PASS** (0 findings; md5 byte-identity proven).
  `08-site-qa.md` written. **Atlas: SITE_APPROVED.**
- Atlas final verdict: **MILESTONE_COMPLETE** (`10-final-verdict.md`,
  `09-sequential-replay.md`, `11-m17-handoff-to-m18.md`). Canonical
  synced: CURRENT_STATE, CONTENT_STATUS, M17_IMPLEMENTATION_NOTES,
  register FR-26 CONVERGED + FR-31 OPEN. 90/90 tests; 89 site pages;
  senior c8eb860 unchanged.
