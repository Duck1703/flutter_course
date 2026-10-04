# SITE HANDOFF — M15

> Produced by: Atlas — issued only after CONTENT_APPROVED.
> To: Forge (`forge-course-website-engineer`)
> Input: `lessons/` (index + 5 lessons, CONTENT_APPROVED)

## Task

Integrate the M15 lesson set into `web/` preserving content semantics
exactly.

## Sources → destinations

| Artifact (M15/lessons/) | Destination |
|--------------------------|-------------|
| `index.md` | `web/src/content/docs/m15/index.md` |
| `01-vi-sao-state-dong.md` | `web/src/content/docs/m15/01-vi-sao-state-dong.md` |
| `02-sealed-class.md` | `web/src/content/docs/m15/02-sealed-class.md` |
| `03-switch-kiet-hop-pattern.md` | `web/src/content/docs/m15/03-switch-kiet-hop-pattern.md` |
| `04-seal-event-bridge.md` | `web/src/content/docs/m15/04-seal-event-bridge.md` |
| `05-gamedialogstate-state-driven-ui.md` | `web/src/content/docs/m15/05-gamedialogstate-state-driven-ui.md` |

Sidebar: milestone dirs autogenerate — copying the folder adds
`/m15/` + its 5 lesson routes automatically (established M14 pattern;
verify `m14/` → `m15/` ordering).

## Required edits beyond the copy

- `web/src/content/docs/index.mdx` (or the roadmap/status page) —
  mark M15 AVAILABLE. Do NOT touch M16 (stays PLANNED).
- `web/src/content/docs/concepts.md` (concept index) — add:
  `sealed class` → M15/02; exhaustive switch/object patterns/`_` →
  M15/03; state-driven UI → M15/01+05; `runtimeType` (awareness) →
  M15/03; UI-state-vs-UI-event reinforcement → M15/04.
- `web/src/content/docs/state-progression.md` (if it exists) — add
  one row only if it genuinely advances the architecture story:
  "repository stream → **sealed state-driven rendering**" is a real
  new stage. Update.
- prev/next links should follow automatically; verify lesson front
  matter `sidebar.order` drives ordering.

## Forbidden

- No M16 content, no M16 routes, no content rewording.
- No new dependencies; keep frontmatter intact.
- Visual regression beyond the new routes.

## Verify

- `cd web && npm run build` — must pass; count pages grew by ≥6.
- Confirm `/m15/` + 5 lesson routes exist in build output.
