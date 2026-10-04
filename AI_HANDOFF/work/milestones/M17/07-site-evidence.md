# M17 — SITE INTEGRATION EVIDENCE (Forge)

## Changes

| File | Change |
|---|---|
| `web/src/content/docs/m17/` (6 files) | byte-identical copies of approved `lessons/` (diff-verified per file) |
| `web/astro.config.mjs` | Phase E gains `M17 · Localization (en/vi)` → `autogenerate: m17` |
| `web/src/content/docs/roadmap.md` | M17 status PLANNED → AVAILABLE |
| `web/src/content/docs/index.mdx` | "M01–M16" → "M01–M17"; "M17–M29" → "M18–M29" |
| `web/src/content/docs/concepts.md` | +3 rows: `MaterialApp.locale`/delegates (Nền widget), `.arb`+`@key` (Model & Dart), Locale=derived-state + UI-owns-strings (Kiến trúc) |
| `web/src/content/docs/state-progression.md` | +M17 ASCII line; +Bước 8 table; M16 "Còn thiếu" no longer lists languageCode→locale (now done) |

## Build + route checks

- `npm run build` → **89 pages** (83 + 6). All 6 M17 routes emitted:
  `/m17/`, `01-vi-sao-l10n-gen`, `02-arb-gen-l10n-setup`,
  `03-materialapp-locale-streambuilder`, `04-di-chuyen-chu-sang-l10n`,
  `05-synthesis-tests-tu-lam`.
- M16 index + L05 link out to `/m17/` routes (prev/next nav verified
  in dist HTML). No m18/m19 routes.
- Pagefind npx wrapper fails on windows-x64 — known non-blocking
  caveat (Astro build itself succeeds; same as M16).
- Homepage is splash-style (no sidebar markup) — `m17` absent from
  `dist/index.html` nav is consistent with m16 also absent; the
  "M01–M17" copy claim is present.
- "Duplicate id" warnings for concepts/state-progression/roadmap
  are pre-existing content-loader notices (files predate M17).
