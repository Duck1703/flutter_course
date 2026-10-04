# M28 — Forge site handoff

## Integrated

- `web/src/content/docs/m28/` — 7 files (index + 6 lessons), copied
  post-content-QA remediated state.
- `astro.config.mjs` — `M28 · Visual parity & motion` autogenerate
  after M27 (same sidebar group).
- `roadmap.md` — M28 row → `status-available` AVAILABLE.
- `state-progression.md` — `### Bước 19 — Visual parity: token
  một-nguồn + painter/controller sở hữu motion (M28)` (5-row table)
  between Bước 18 and `## Hai stream`.
- `concepts.md` — +2 Kiến trúc rows (A-38 design tokens
  single-source, A-39 trigger-based animation as data), +1 Model &
  Dart row (D-48 `if-case`), new `## Animation & visual parity
  (M28)` section (6 rows: F-38..F-43).
- `index.mdx` — "M01–M27" → "M01–M28" hoàn thiện; "M28–M29" →
  "M29" đang biên soạn (site-QA F1 fix).

## Build

`npm run build` → **159 pages** (+7). Pagefind Windows-x64 binary
unavailable — known documented caveat; CI indexes.

## Byte-diff

`diff -q` — all 7 staged↔live pairs IDENTICAL (run twice: pre-fix
and post-remediation).
