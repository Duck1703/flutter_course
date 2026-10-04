# M26 — Site Handoff (Atlas → Forge)

## Content payload

`AI_HANDOFF/work/milestones/M26/lessons/` → `web/src/content/docs/m26/`:

- `index.md` — M26 overview + lesson map (checkpoints 236→254)
- `01-vi-sao-mutation-tay-dat-gioi-han.md` — problem + DRE intro
- `02-core-dre-primitives.md` — `core/dre` port (+5 tests → 241)
- `03-game-state-actions-effects.md` — game DRE contract files (+0 → 241)
- `04-game-reducer.md` — `GameReducer` + 4 part files (+10 → 251)
- `05-vm-migration-va-bridges.md` — VM rewrite + bridges (+0 → 251)
- `06-regression-va-tong-ket.md` — regression tests + recap (+3 → 254)

## Integration requirements

- Route `/m26/` with the 6 lesson pages; sidebar order 0–6.
- Roadmap page: M26 → available (M01–M26 available; M27+ planned).
- State-progression page: M26 IS a genuine architecture transition
  (manual-mutation VM → DRE dispatch/reducer/effects/asyncOp) — add a
  row ONLY if the page's established row format fits; do not invent a
  new section type.
- No `/m29/`; no M27/M28 routes yet.
- Concepts cited (D-45/D-46/F-33/F-34/A-31/A-32) — registry sync lands
  with final verdict; if the site has a concepts index, add links only
  after registry rows exist.

## Verification expected by site QA

`npm run build` (was 138 pages → expect +7 = 145), route spot-checks,
sidebar/prev-next sanity, no malformed markdown/tables, no future
milestone pages, lesson links resolve.
