# M24 — SITE HANDOFF (Atlas → Forge)

Milestone: M24 — Authentication
Content state: CONTENT_APPROVED (Argus content QA FAIL → remediated → REVERIFIED PASS)
Baseline: site 126 pages

## Approved lesson files (source of truth)

`AI_HANDOFF/work/milestones/M24/lessons/` → `web/src/content/docs/m24/`:

- `index.md` (sidebar order 0)
- `01-session-model.md`
- `02-supabase-auth-impl.md`
- `03-sync-seam-va-coordinator.md`
- `04-dialog-vms-va-menu.md`
- `05-auth-ui.md`

## Integration actions (mirror M23 recipe)

1. Copy the 6 files → `web/src/content/docs/m24/`.
2. `astro.config.mjs` — sidebar entry after M23:
   `M24 · Đăng nhập & Phiên` (use the lesson index `sidebar.label` if
   it differs) → `autogenerate: m24`.
3. `roadmap.md` — M24 row → `AVAILABLE`. M25+ stays `PLANNED`.
4. `state-progression.md` — append one legitimate architecture step:
   **Bước 15 — Auth session stream: guest ↔ authenticated (M24)** —
   problem: identity là state, không phải một màn đăng nhập;
   mechanism: sealed `AuthSessionData` + `authStateStream`
   (BehaviorSubject, M14 pattern) + `AuthActionResult` + conditional
   DI; owner: `AuthRepository` (+`DisabledAuthRepository`); data-flow:
   pill tap → `requestAuthAction` (guest→auth dialog / authed→sign-out)
   → dialog VM → coordinator → repo → session stream → menu re-render;
   remaining: real sync impl (M25), dialog layer (M29), DRE (M26).
5. `concepts.md` — M24 rows ONLY for taught concepts, using exact
   registry IDs from `LEARNER_CONCEPT_REGISTRY.md` (Lumen added
   D-43/D-44, A-25/A-26, B-03..B-07 — verify which are APPROVED vs
   INTRODUCED/awareness; awareness-only backend rows may belong in
   the Backend section like M23's). Link each to its `/m24/` lesson.

## Constraints

- No learner-app or senior files touched.
- No M25+ pages or status flips.
- `cd web && npm run build`; expected pages: 126 + 6 = **132**.
- Pagefind windows-x64 + sitemap `site` warnings = known baseline.
- Evidence → `AI_HANDOFF/work/milestones/M24/07-site-integration.md`.
