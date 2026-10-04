# M17 — SITE HANDOFF (Atlas → Forge)

Approved content: `lessons/` (index.md + 01–05) — Argus content QA
PASS (r4) after full remediation + physical sequential replay.

## Forge scope

1. Copy `lessons/*.md` → `web/src/content/docs/m17/` byte-identical.
2. `astro.config.mjs` — Phase E group gains
   `{ label: 'M17 · Localization (en/vi)', autogenerate: { directory: 'm17' } }`.
3. `roadmap.md` — M17 row → done/published (match M16 entry style).
4. `index.mdx` — homepage milestone claim M17.
5. `concepts.md` — add D-31, F-25, A-16 rows (registry is source).
6. `state-progression.md` — add M17 stage line: app-root
   StreamBuilder drives `MaterialApp.locale` from settings stream —
   "locale = derived state"; FR-26 closed.
7. `npm run build` — expect 83 + 6 = **89 pages**; Pagefind Windows
   failure is the known non-blocking caveat iff Astro build succeeds.
8. Route checks: 6 M17 routes emitted; M16→M17 prev/next links; no
   M18 routes; concepts links resolve.

## Conventions to preserve

- Lesson front-matter `sidebar.order` drives ordering (index=0).
- Canonical/web copies must stay byte-identical (M16 stale-read
  anomaly: verify via `fc`/`diff`/checksum, not `read`).
