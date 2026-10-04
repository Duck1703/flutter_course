# M21 — SITE INTEGRATION (Forge)

## Actions

- `web/src/content/docs/m21/` ← 6 files copied verbatim from
  `AI_HANDOFF/work/milestones/M21/lessons/` (index + L01–L05).
- `astro.config.mjs` — sidebar entry after M20:
  `M21 · Dialog layer kiểu senior` → `autogenerate: m21`.
- `roadmap.md` — M21 row `PLANNED` → `AVAILABLE`.
- `concepts.md` — +5 rows:
  - Architecture: "Dialog = state trong `Stack` (in-tree layer)"
    (A-21) → M21/01+02, reinforcement M28/M29.
  - Flutter: `AnimatedSwitcher`+`transitionBuilder` (F-29),
    `ValueKey(runtimeType)` (D-37), `BackdropFilter`+`ClipRect`+
    `IgnorePointer`+`opaque` (F-30), `MediaQuery.disableAnimations`.
  - `PopScope` row's "Củng cố ở" now links M21/04.
- `state-progression.md` — **Bước 12** appended: in-`Stack` dialog
  layer + PopScope choreography (mechanism, ownership, data flow,
  remaining debt table citing FR-32/33/34 + M22/M26/M29).

## Build verification

- `npm run build` → **114 pages** (108 baseline + 6 M21).
- All 6 `/m21/` routes emitted: index + 5 lesson pages.
- Known non-fatal warnings unchanged: pagefind platform
  (windows-x64 unsupported arch), sitemap `site` option — both
  pre-existing since earlier milestones, build completes.
- No `/m22/` or `/m23/` routes created — forward firewall intact.

## Intentionally not touched

- `/concepts/` rows only added for genuinely-taught M21 concepts;
  PopScope row updated in place (reinforcement link), not duplicated.
- `state-progression.md` got exactly one new step — the UI-state
  presentation layer is a real architecture progression (route →
  in-tree), not an artificial row.
- Senior repo untouched; learner app untouched by Forge.
