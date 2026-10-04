# M18 — SITE HANDOFF (Atlas → Forge)

## Status

`CONTENT_APPROVED` — `05-content-qa.md` PASS + targeted re-verify
PASS on post-PASS mutations.

## Deliverables

- Canonical lessons: `AI_HANDOFF/work/milestones/M18/lessons/` —
  `index.md` + 5 lesson files (01–05), byte-identical copies required
  at `web/src/content/docs/m18/`.
- Frontmatter on every file carries `title`, `description`,
  `sidebar.label`, `sidebar.order` — autogenerate-compatible.

## Integration steps

1. `web/src/content/docs/m18/` — copy all 6 canonical `.md` files.
2. `web/astro.config.mjs` — add sidebar entry under
   `Phase E — App local giàu tính năng`, after M17:
   `label: 'M18 · Onboarding overlay (lần đầu)'`,
   `autogenerate: { directory: 'm18' }`.
3. `web/src/content/docs/roadmap.md` — M18 row PLANNED → AVAILABLE.
4. `web/src/content/docs/index.mdx` — update the M18–M29
   in-progress text to reflect M18 available.
5. `web/src/content/docs/concepts.md` — add rows:
   - `listEquals` + `List.unmodifiable` (D-32) → M18/03
   - overlay-in-Stack gating (F-26: `Positioned.fill`,
     `HitTestBehavior.opaque`, visibility=state) → M18/01, M18/04
   - overlay-scoped ViewModel (A-17, tầng lifetime thứ tư) → M18/03,
     M18/04
   - update `used-next` columns that now point at M18 (late/late
     final, `.arb`, vòng lặp persist, locale-derived-state rows).
6. `web/src/content/docs/state-progression.md` — add M18 stage
   (onboarding flag + 3-step overlay + notification pref stub,
   deferral note FR-27/FR-32).

## Verify

- `npm run build` from `web/` — all 6 `/m18/...` routes emitted.
- MD5 hash each canonical/web pair — byte-identical.
- No `/m19/` content introduced.
- Pagefind Windows binary failure = known non-blocking caveat.
