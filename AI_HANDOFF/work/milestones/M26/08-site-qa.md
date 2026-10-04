# M26 — Site QA (Argus)

## Round 1 — PASS_WITH_FINDINGS (0 blocking)

- Sidebar: `M26 · Kiến trúc DRE` autogenerate group after M25; no
  M27–M29 entries.
- Site files vs `AI_HANDOFF/.../lessons/`: content-verified
  (subagent's `read` served stale snapshots; live grep proved
  parity). Parent byte-diff: **all 7 files IDENTICAL**
  (`filecmp.cmp` shallow=False).
- `roadmap.md`: M26 AVAILABLE; M27/M28/M29 PLANNED.
- `state-progression.md`: Bước 17 DRE row, 5-row format.
- `concepts.md`: 6 new rows, correct sections, valid `/m26/` links.
- Markdown integrity: 8 `:::` pairs, 13 `<details>`, clean
  frontmatter, consistent tables.
- Built output: `dist/m26/` 7 pages; prev/next chain complete
  (m25/05 → m26 → 01–06); zero `/m29/` URLs; no raw markdown leaks.
- No M27/M28 implementation leakage (share/notification mentions are
  deferral-only).

## Post-QA change (REVERIFIED)

- `index.mdx` stale copy fixed: "M01–M20 … M21–M29" →
  "M01–M26 … M27–M29" (pre-existing staleness, not M26-introduced;
  fixed as site-integration correctness). Rebuilt: 145 pages PASS.
- Status: **REVERIFIED** (targeted rebuild + diff; single-file copy
  change, no new content surface).

## Verdict: PASS
