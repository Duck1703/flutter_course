# M16 — SITE INTEGRATION EVIDENCE (Forge)

Scope: approved M16 content only (`06-site-handoff.md`).

## Changes

- `web/src/content/docs/m16/` — index + 5 lessons copied
  byte-identical from `work/milestones/M16/lessons/`.
- `astro.config.mjs` — new sidebar group "Phase E — App local giàu
  tính năng" with `M16 · Settings persist` autogenerate (Phase E per
  roadmap grouping M16–M18).
- `roadmap.md` — M16 row PLANNED → AVAILABLE.
- `index.mdx` — progress claim "M01–M16" / "M17–M29 đang biên soạn".
- `concepts.md` — +10 rows: Switch, HitTestBehavior.opaque,
  ListWheelScrollView+controller (widget); enum dispatch key,
  collection-if, padLeft, late (Dart); persist loop, dialog-scoped VM
  (architecture); ensureVisible (test). All link to /m16/ lessons.
- `state-progression.md` — new "Bước 7 — Dialog-scoped VM + persist
  loop (M16)" table + Còn thiếu noting FR-16/29→M21, locale→M17.

## Verification

- `npm run build` → **83 pages built** (was 77; +6 = m16 index + 5
  lessons). Pagefind Windows-x64 warning = known caveat, non-blocking
  (same as all prior milestones). Sitemap `site` option warning =
  pre-existing.
- No /m17+ links introduced.

Pending Argus site QA for emitted-page checks (sidebar, prev/next,
concept links, roadmap statuses).
