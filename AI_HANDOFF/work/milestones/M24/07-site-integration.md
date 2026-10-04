# M24 — SITE INTEGRATION (Forge)

Handoff: `AI_HANDOFF/work/milestones/M24/06-site-handoff.md`
Baseline: site 126 pages (post-M23) → expected 132.

## Actions

1. Copied 6 approved lesson files → `web/src/content/docs/m24/`
   (byte-identical, verified with `cmp`):
   - `index.md` (sidebar order 0, label "Tổng quan M24")
   - `01-session-model.md`
   - `02-supabase-auth-impl.md`
   - `03-sync-seam-va-coordinator.md`
   - `04-dialog-vms-va-menu.md`
   - `05-auth-ui.md`
2. `web/astro.config.mjs` — sidebar entry after M23 in
   "Phase F — Chiều sâu senior":
   `{ label: 'M24 · Đăng nhập & Phiên', autogenerate: { directory: 'm24' } }`.
3. `web/src/content/docs/roadmap.md` — M24 row status
   `PLANNED` → `AVAILABLE` (one-line change). M25–M29 remain
   `PLANNED` — verified in rendered output.
4. `web/src/content/docs/state-progression.md` — appended
   **Bước 15 — Auth session stream: guest ↔ authenticated (M24)**
   after Bước 14 (M23), same 5-row table format
   (Vấn đề giải quyết / Cơ chế / Ai sở hữu / Hướng dữ liệu /
   Còn thiếu). Content per handoff §4: sealed `AuthSessionData`
   (guest variant chính danh) + `authStateStream` BehaviorSubject
   seeded (M14 pattern) + `AuthActionResult` result value-type +
   conditional DI `DisabledAuthRepository`/`AuthRepositoryImpl`;
   owner `AuthRepository` + `MenuAuthActionCoordinator`
   (+dialog-scoped VMs); data-flow pill tap → `requestAuthAction`
   → dialog VM → coordinator → repo → session stream → re-render;
   remaining → M25 (sync impl), M26 (DRE), M29 (dialog layer),
   `LIVE_AUTH_FLOW: NOT_PERFORMED`.
5. `web/src/content/docs/concepts.md` — +9 rows across 3 existing
   sections, using exact registry IDs/labels from
   `project-context/LEARNER_CONCEPT_REGISTRY.md`:
   - Model & Dart: `sealed` union cho identity `AuthSessionData`
     (D-43 → `/m24/01-session-model/`); `AuthActionResult` result
     value-type (D-44 → `/m24/01-session-model/`)
   - Kiến trúc: Auth session stream
     (A-25 → `/m24/01-session-model/`); Action coordinator +
     contract-trước-impl-sau
     (A-26 → `/m24/03-sync-seam-va-coordinator/`)
   - Backend (Supabase) — section created at M23, all five B-*
     rows appended there per registry grouping:
     `signInWithIdToken` two-leg flow (B-03 → m24/02);
     `google_sign_in` v7 API (B-04 → m24/02);
     `onAuthStateChange` + `currentUser` seed (B-05 → m24/02);
     auth ≠ authorization ≠ profile (B-06, LIGHT/awareness →
     m24/01); SHA-256 nonce OIDC Apple appendix
     (B-07, LIGHT/awareness → m24/02).

## Build evidence

Command: `cd web && npm run build` (astro build, Starlight /
Astro 5).

Key output lines (first build):

```
├─ /m24/01-session-model/index.html (+19ms)
├─ /m24/02-supabase-auth-impl/index.html (+10ms)
├─ /m24/03-sync-seam-va-coordinator/index.html (+16ms)
├─ /m24/05-auth-ui/index.html (+16ms)
├─ /m24/04-dialog-vms-va-menu/index.html (+20ms)
└─ /m24/index.html (+19ms)
✓ Completed in 2.19s.
[build] 132 page(s) built in 8.24s
[build] Complete!
```

- Page count: 126 (baseline) + 6 = **132** — matches handoff.
- `dist/m24/` contains `index.html` + all 5 lesson dirs each with
  `index.html`. Rendered `dist/m24/index.html` shows sidebar label
  "M24 · Đăng nhập & Phiên".
- `dist/roadmap/index.html`: M24 = `status-available`,
  M25–M29 = `status-planned` (unchanged, verified per-row).
- `dist/state-progression/index.html`: "Bước 15 — Auth session
  stream: guest ↔ authenticated (M24)" present.
- `dist/concepts/index.html`: all 9 new rows rendered across
  Model & Dart / Kiến trúc / Backend (Supabase).

## Warnings

- `Failed to run pagefind via the npx wrapper … platform
  windows-x64 is not yet a supported architecture` — known
  non-fatal baseline environment issue (search index not built
  locally).
- `[WARN] [@astrojs/sitemap] The Sitemap integration requires the
  \`site\` astro.config option. Skipping.` — known non-fatal
  baseline issue.
- First build only: 3× `[WARN] [starlight-docs-loader] Duplicate
  id "roadmap"/"state-progression"/"concepts" … Later items with
  the same id will overwrite earlier ones.` — transient
  content-layer store collision on the files edited this session
  (same pattern as M23). Rebuild with zero file changes: warnings
  gone, 132 pages, only the two baseline warnings remain.
  Rendered output verified to carry the new content. No action
  needed; recorded for transparency.

## Constraints check

- No learner-app or senior files touched.
- No M25+ milestone pages created; no roadmap availability changes
  beyond M24.
- Lesson files copied verbatim (all 6 `cmp` byte-identical).

## Notes for QA

- M24 frontmatter `sidebar.order` = 0 (index) / 1–5 (lessons),
  matching M23 convention; autogenerate picks order from
  frontmatter.
- Cross-links inside lessons use absolute `/m24/<slug>/` paths —
  all six routes confirmed in build output and on disk under
  `dist/m24/`.
- concepts.md "Backend (Supabase)" section now carries B-01–B-07;
  M25 should append its sync/`public.users` rows there.
- Two awareness-only rows (B-06, B-07) placed in Backend section
  per handoff §5 / registry grouping; all five B-* M24 concepts
  live in that section.
