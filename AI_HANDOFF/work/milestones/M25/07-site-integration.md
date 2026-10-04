# M25 — SITE INTEGRATION EVIDENCE (Forge)

Milestone: M25 — Remote Profile Sync
Date: 2025-10-03 (local)
Recipe: mirrored M24 exactly, per `06-site-handoff.md`

## Result summary

| Item | Expected | Actual | Status |
|---|---|---|---|
| Pages built | 132 + 6 = 138 | **138** | PASS |
| Build | clean | `Complete!` in 9.42s | PASS |
| m25 routes | 6 | 6 (`/m25/` + 5 bài) | PASS |
| M26+ status | unchanged (PLANNED) | unchanged | PASS |

## Files touched

### New (6) — copied verbatim from `AI_HANDOFF/work/milestones/M25/lessons/`

- `web/src/content/docs/m25/index.md` (sidebar order 0, label `Tổng quan M25`)
- `web/src/content/docs/m25/01-app-user-data-va-schema.md`
- `web/src/content/docs/m25/02-merge-user-profile-for-sync.md`
- `web/src/content/docs/m25/03-sync-repository-impl.md`
- `web/src/content/docs/m25/04-main-di-va-game-vm.md`
- `web/src/content/docs/m25/05-sync-tests-va-tong-ket.md`

Verified byte-identical: `diff -r` lessons/ ↔ m25/ → no differences.
Frontmatter: **no adjustment needed** — all 6 files already carry
`title` + `description` + `sidebar.label` + `sidebar.order` matching
the site convention (identical shape to M24 files).

### Edited (4)

1. **`web/astro.config.mjs`** — sidebar entry appended after M24 inside
   the existing `Phase F — Chiều sâu senior` group:

   ```js
   {
     label: 'M25 · Đồng bộ hồ sơ',
     autogenerate: { directory: 'm25' },
   },
   ```

   Label decision: handoff default `M25 · Đồng bộ hồ sơ` used. The lesson
   index `sidebar.label` (`Tổng quan M25`) is the *page* label inside the
   group — same convention as M24 (index label `Tổng quan M24`, group
   label `M24 · Đăng nhập & Phiên`), so the handoff's milestone short-name
   is correct for the group label.

2. **`web/src/content/docs/roadmap.md`** — M25 row status flipped
   `PLANNED` → `AVAILABLE` (single span change; row text unchanged).
   M26–M29 remain `PLANNED`.

3. **`web/src/content/docs/state-progression.md`** — appended
   `### Bước 16 — Sync local ↔ remote: fetch → merge → upsert (M25)`
   immediately after Bước 15 table, before `## Hai stream trong cùng
   một VM`. Five-row table (Vấn đề / Cơ chế / Ai sở hữu / Hướng dữ
   liệu / Còn thiếu) per handoff text — problem: đối chiếu local ↔
   `public.users` không mất tiến trình; mechanism: `AppUserData` DTO +
   `mergeUserProfileForSync` + `UserProfileSyncRepositoryImpl`
   (`_isSyncing`, `maybeSingle`, `upsert(onConflict:'auth_uuid')`) +
   conditional DI; owner: `UserProfileSyncRepository` (+Disabled no-op);
   data-flow: sign-in / save kết quả → `syncUserProfile` → fetch →
   merge → save local → upsert → `ProfileSyncIdle`; remaining: DRE
   (M26), polish (M28), dialog layer (M29), `LIVE_PROFILE_SYNC:
   NOT_PERFORMED`.

4. **`web/src/content/docs/concepts.md`** — 5 rows added, all registry
   IDs verified present in `project-context/LEARNER_CONCEPT_REGISTRY.md`
   (lines 130–133, 146) and status TAUGHT:
   - *Kiến trúc* section (after M24 coordinator row): A-27 boundary DTO
     `AppUserData` → `/m25/01-app-user-data-va-schema/`; A-28 merge
     policy `mergeUserProfileForSync` → `/m25/02-merge-user-profile-for-sync/`;
     A-29 sync pipeline + `_isSyncing` → `/m25/03-sync-repository-impl/`;
     A-30 post-save best-effort `_syncSavedGameResult` →
     `/m25/04-main-di-va-game-vm/`.
   - *Backend (Supabase)* section (last row, same position as M23/M24
     backend rows): B-08 `upsert(onConflict:)` trên `public.users` →
     `Dạy ở` = `/m25/01-app-user-data-va-schema/` (payload+schema, per
     registry), `Củng cố ở` = `/m25/03-sync-repository-impl/` (the call).

## Build output tail (`cd web && npm run build`)

```
13:02:13   ├─ /m25/01-app-user-data-va-schema/index.html (+20ms)
13:02:13   ├─ /m25/03-sync-repository-impl/index.html (+12ms)
13:02:13   ├─ /m25/04-main-di-va-game-vm/index.html (+13ms)
13:02:13   ├─ /m25/02-merge-user-profile-for-sync/index.html (+10ms)
13:02:13   ├─ /m25/05-sync-tests-va-tong-ket/index.html (+13ms)
13:02:13   └─ /m25/index.html (+9ms)
13:02:13 ✓ Completed in 2.44s.
Failed to run pagefind via the npx wrapper: ... windows-x64 is not yet a supported architecture.   ← KNOWN BASELINE
[WARN] [@astrojs/sitemap] The Sitemap integration requires the `site` astro.config option. Skipping.   ← KNOWN BASELINE
[build] 138 page(s) built in 9.42s
[build] Complete!
```

Other warnings (pre-existing baseline, unrelated to M25):
`starlight-docs-loader` duplicate-heading-id warnings for
`roadmap`/`concepts`/`state-progression` — these fire on the docs'
own headings and were present before this milestone.

## Deviations from handoff

- **None material.** Note for the record:
  - Sidebar group label uses the handoff's `M25 · Đồng bộ hồ sơ`; the
    index `sidebar.label` is `Tổng quan M25` which is a *page* label,
    not a group label (M24 precedent identical).
  - B-08 row's `Củng cố ở` links `/m25/03-…/` (the `upsert` call site)
    while `Dạy ở` stays `/m25/01-…/` — matches registry wording
    "M25/01 (new — payload+schema) | call M25/03".
- No learner-app files touched. No senior files touched. No M26+
  pages created or status flipped. No lesson prose modified
  (`diff -r` byte-identical).

## Constraints check

| Constraint | Result |
|---|---|
| Lesson content verbatim | PASS — `diff -r` clean, frontmatter untouched |
| M26+ stays PLANNED / no M26+ pages | PASS |
| Page count 138 | PASS |
| Pagefind + sitemap warnings only | PASS (plus pre-existing dup-id baseline) |
| No learner-app / senior file edits | PASS |
