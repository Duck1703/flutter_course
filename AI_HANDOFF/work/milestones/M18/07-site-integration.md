# M18 — SITE INTEGRATION (Forge)

## What was integrated

- `web/src/content/docs/m18/` — 6 files copied from
  `AI_HANDOFF/work/milestones/M18/lessons/` (index + L01–L05).
  MD5-verified byte-identical, all 6 pairs.
- `web/astro.config.mjs` — sidebar entry under
  `Phase E — App local giàu tính năng`:
  `M18 · Onboarding overlay (lần đầu)` → autogenerate `m18`.
- `web/src/content/docs/roadmap.md` — M18 row PLANNED → AVAILABLE.
- `web/src/content/docs/index.mdx` — completion text "M01–M17"
  → "M01–M18"; in-progress range "M18–M29" → "M19–M29".
- `web/src/content/docs/concepts.md` — 3 new rows:
  - `Overlay trong Stack (không route)` (F-26) → Nền widget
  - `listEquals` + `List.unmodifiable` (D-32) → Model & Dart
  - `Overlay-scoped VM (tầng lifetime thứ tư)` (A-17) → Kiến trúc
- `web/src/content/docs/state-progression.md` — intro arc line +
  `Bước 9 — Overlay-scoped VM + cờ show-once (M18)` stage table
  (vấn đề/cơ chế/sở hữu/hướng dữ liệu/còn thiếu).

## Build evidence

`npm run build` — **95 pages built** (+6 vs M17's 89). Routes
emitted: `/m18/`, `/m18/01-vi-sao-overlay-khong-phai-route/`,
`/m18/02-step-state-sealed-onboarding/`,
`/m18/03-onboarding-view-model/`,
`/m18/04-overlay-scope-va-menu-stack/`,
`/m18/05-hoan-thien-tests-tu-lam/`.

Pagefind: failed on windows-x64 (unsupported binary) — known
non-blocking local caveat, same as M16/M17.

## Constraints honored

- No `/m19/` routes or references introduced.
- Canonical lessons untouched (read+md5 only).
- Senior repo untouched.
