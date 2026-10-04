# M19 — Site integration (Forge)

## Intake

`CONTENT_APPROVED` — `06-content-approval.md` on disk.

## Changes

| Change | Detail |
|---|---|
| Content | `AI_HANDOFF/…/M19/lessons/*.md` → `web/src/content/docs/m19/` — 7 files, byte-identical (md5 verified on index) |
| Sidebar | `astro.config.mjs`: new group `Phase F — Chiều sâu senior` + `M19 · Game VM có cấu trúc` autogenerate `m19` |
| Roadmap | `roadmap.md`: M19 PLANNED → AVAILABLE (Phase F table) |
| Homepage | `index.mdx`: "M01–M18" → "M01–M19"; "M19–M29" → "M20–M29" |
| Concepts | `concepts.md`: +7 rows — `copyWith`+`clear*`, `Duration`+`Timer.periodic` in VM, `FakeAsync`/`elapse` (Model & Dart); session state machine, presentation mapper, `flowToken` (Kiến trúc); `PopScope`, `AppNavigationController`+`navigatorKey` (Navigation & test) |
| Progression | `state-progression.md`: Bước 10 — VM-owned session state machine + presentation mapper (new architecture stage) |

## Verification

- `npm run build` — **102 pages** (95 + 7 `/m19/` routes, all emitted).
- Pagefind npx-wrapper failure = known Windows non-blocker
  (same as M16–M18).
- No future routes: M20+ untouched; roadmap M20+ stays PLANNED.
