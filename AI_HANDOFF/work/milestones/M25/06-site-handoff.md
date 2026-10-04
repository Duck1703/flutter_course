# M25 — SITE HANDOFF (Atlas → Forge)

Milestone: M25 — Remote Profile Sync
Content state: CONTENT_APPROVED (Argus content QA PASS_WITH_FINDINGS →
remediated → APPROVED)
Baseline: site 132 pages

## Approved lesson files (source of truth)

`AI_HANDOFF/work/milestones/M25/lessons/` → `web/src/content/docs/m25/`:

- `index.md` (sidebar order 0)
- `01-app-user-data-va-schema.md`
- `02-merge-user-profile-for-sync.md`
- `03-sync-repository-impl.md`
- `04-main-di-va-game-vm.md`
- `05-sync-tests-va-tong-ket.md`

NOTE: index file is named `index.md` (same convention as M21–M24 — not
`00-index.md`); declared in the content ledger.

## Integration actions (mirror M24 recipe)

1. Copy the 6 files → `web/src/content/docs/m25/`.
2. `astro.config.mjs` — sidebar entry after M24:
   `M25 · Đồng bộ hồ sơ` (use the lesson index `sidebar.label` if it
   differs) → `autogenerate: m25`.
3. `roadmap.md` — M25 row → `AVAILABLE`. M26+ stays `PLANNED`.
4. `state-progression.md` — append one legitimate architecture step:
   **Bước 16 — Sync local ↔ remote: fetch → merge → upsert (M25)** —
   problem: local profile phải đối chiếu với row `public.users` mà
   không mất tiến trình nào; mechanism: `AppUserData` boundary DTO +
   `mergeUserProfileForSync` (leader=level/exp, totals=max, session
   identity thắng, `gamesWon` local-only, demo-normalize) +
   `UserProfileSyncRepositoryImpl` (`_isSyncing` guard, `maybeSingle`,
   `upsert(onConflict:'auth_uuid')`) + conditional DI; owner:
   `UserProfileSyncRepository` (+Disabled no-op khi unconfigured);
   data-flow: sign-in thành công / save kết quả ván →
   `syncUserProfile(session)` → fetch → merge → save local → upsert
   remote → `ProfileSyncIdle`; remaining: DRE async op (M26),
   visual polish (M28), dialog layer (M29).
5. `concepts.md` — M25 rows ONLY for taught concepts, using exact
   registry IDs from `LEARNER_CONCEPT_REGISTRY.md` (Lumen added
   A-27 boundary DTO, A-28 merge/conflict policy, A-29 sync pipeline +
   `_isSyncing`, A-30 post-save best-effort sync, B-08
   `upsert(onConflict:)` + `public.users` write model — Backend section
   like M23's backend rows). Link each to its `/m25/` lesson.

## Constraints

- No learner-app or senior files touched.
- No M26+ pages or status flips.
- `cd web && npm run build`; expected pages: 132 + 6 = **138**.
- Pagefind windows-x64 + sitemap `site` warnings = known baseline.
- Evidence → `AI_HANDOFF/work/milestones/M25/07-site-integration.md`.
