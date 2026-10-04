# M27 — Forge site handoff

## Integrated

- `web/src/content/docs/m27/` — 7 files (index + 6 lessons), copied
  post-content-QA round-4 state.
- `astro.config.mjs` — `M27 · Platform extras` autogenerate after M26
  (same sidebar group).
- `roadmap.md` — M27 row → `status-available` AVAILABLE.
- `state-progression.md` — `### Bước 18 — Platform boundary` (5-row
  table) between Bước 17 and `## Hai stream`.
- `concepts.md` — +3 Kiến trúc rows (A-35/36/37 equivalents) + new
  `## Platform` section (6 rows: kIsWeb/resolve, FLN/zonedSchedule,
  timezone/flutter_timezone, share_plus/Clipboard, package_info_plus,
  runtime permission).
- `index.mdx` — "M01–M26" → "M01–M27" hoàn thiện; "M27–M29" →
  "M28–M29" đang biên soạn (site-QA F1 fix).

## Build

`npm run build` → **152 pages** (+7). Pagefind Windows-x64 binary
unavailable — known documented caveat; CI indexes.

## Byte-diff

`fc /b` — all 7 staged↔live pairs IDENTICAL.
