# M27 — Site QA (Argus)

## Round 1 — PASS_WITH_FINDINGS

- Sidebar/roadmap/state-progression/concepts/front-matter/link
  checks all PASS; 15 `/m27/` links resolve; 152 pages built.
- **F1** `index.mdx:41` stale "M01–M26 hoàn thiện" → fixed to
  M01–M27 / M28–M29; rebuilt green.
- Byte-diff delegated to parent: `fc /b` all 7 pairs IDENTICAL.
- Observation (non-defect): state-progression ASCII diagram stops
  at M19 — consistent with existing style (M20–M26 never added).

## Verdict: PASS (F1 remediated, byte-diff confirmed)
