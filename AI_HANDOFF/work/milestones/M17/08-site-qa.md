# M17 — SITE QA (Argus)

**Verdict: PASS** — zero MAJOR/MINOR; 1 NIT (environmental stale-`read`
cache, not a content defect).

## Verified

- All 6 canonical↔web lesson pairs identical — parent closed the
  residual with md5 (all 6 `True`).
- `astro.config.mjs` Phase E: M17 entry after M16; no M18/M19.
- `roadmap.md`: M17 AVAILABLE; M18–M29 still PLANNED.
- `index.mdx`: "M01–M17" / "M18–M29 upcoming".
- `concepts.md`: +3 M17 rows, all link slugs resolve to real files.
- `state-progression.md`: ASCII line + Bước 8 table; M16 "Còn thiếu"
  no longer claims languageCode doesn't drive locale.
- `dist/m17/` routes present with real content (incl. F-15 points in
  lesson 03 HTML). No m18 routes. Build = 89 pages.
- No M18 leakage anywhere.
- All 5 web lessons: Vietnamese, front-matter + sidebar order intact.
