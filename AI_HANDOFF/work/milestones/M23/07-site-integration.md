# M23 — SITE INTEGRATION (Forge)

Handoff: `AI_HANDOFF/work/milestones/M23/06-site-handoff.md`
Baseline: site 120 pages (post-M22) → expected 126.

## Actions

1. Copied 6 approved lesson files → `web/src/content/docs/m23/`
   (byte-identical, verified with `cmp`):
   - `index.md` (sidebar order 0, label "Tổng quan M23")
   - `01-supabase-va-dart-define.md`
   - `02-init-co-dieu-kien.md`
   - `03-leaderboard-repository.md`
   - `04-viewmodel-va-stale-guard.md`
   - `05-dialog-va-menu-row.md`
2. `web/astro.config.mjs` — sidebar entry after M22 in
   "Phase F — Chiều sâu senior":
   `{ label: 'M23 · Supabase & Bảng xếp hạng', autogenerate: { directory: 'm23' } }`.
3. `web/src/content/docs/roadmap.md` — M23 row status
   `PLANNED` → `AVAILABLE` (one-line change). M24–M29 remain
   `PLANNED` — verified in rendered output.
4. `web/src/content/docs/state-progression.md` — appended
   **Bước 14 — Remote repository sau contract: local → remote impl
   (M23)** after Bước 13 (M22), same 5-row table format
   (Vấn đề giải quyết / Cơ chế / Ai sở hữu / Hướng dữ liệu /
   Còn thiếu). Content per handoff §4: conditional DI
   (`client == null ? Disabled : Supabase`), sealed popup states,
   `_requestId` stale guard; owners `LeaderboardRepository` +
   `LeaderboardDialogViewModel`; remaining → M24/M25/M26/M28/M29.
5. `web/src/content/docs/concepts.md` — +8 rows across 4 existing
   sections + 1 new section, using exact registry IDs/labels from
   `project-context/LEARNER_CONCEPT_REGISTRY.md`:
   - Nền widget: `RefreshIndicator.adaptive` +
     `AlwaysScrollableScrollPhysics` (F-32 → `/m23/05-dialog-va-menu-row/`)
   - Model & Dart: `String.fromEnvironment` / `--dart-define`
     (D-40 → `/m23/01-supabase-va-dart-define/`)
   - Kiến trúc: Remote repository impl sau contract
     (A-23 → `/m23/02-init-co-dieu-kien/` + `/m23/03-leaderboard-repository/`);
     Conditional DI theo config (A-24 → `/m23/02-init-co-dieu-kien/`);
     `_requestId` monotonic stale guard
     (D-42 → `/m23/04-viewmodel-va-stale-guard/`)
   - **New `## Backend (Supabase)` section** (mirrors registry
     grouping; placed between "Kiến trúc" and "Navigation & test"):
     RLS / anon-key security boundary (B-01 → m23/01);
     View-vs-table read model (B-02 → m23/01);
     `Supabase.initialize` + `SupabaseClient` (F-31 → m23/02);
     Query chain `select`/`order`/`limit`/`eq` + `maybeSingle`
     (D-41 → m23/03).

## Build evidence

Command: `cd web && npm run build` (astro build, Starlight 0.34 /
Astro 5).

Key output lines (first build):

```
├─ /m23/01-supabase-va-dart-define/index.html (+15ms)
├─ /m23/02-init-co-dieu-kien/index.html (+10ms)
├─ /m23/03-leaderboard-repository/index.html (+13ms)
├─ /m23/05-dialog-va-menu-row/index.html (+8ms)
├─ /m23/index.html (+7ms)
└─ /m23/04-viewmodel-va-stale-guard/index.html (+12ms)
✓ Completed in 1.75s.
[build] 126 page(s) built in 6.46s
[build] Complete!
```

- Page count: 120 (baseline) + 6 = **126** — matches handoff.
- `dist/m23/` contains `index.html` + all 5 lesson dirs each with
  `index.html`. Rendered `dist/m23/index.html` shows sidebar label
  "M23 · Supabase & Bảng xếp hạng".
- `dist/roadmap/index.html`: M23 = `status-available`, M24–M29 =
  `status-planned` (unchanged).
- `dist/state-progression/index.html`: "Bước 14 — Remote
  repository sau contract: local → remote impl (M23)" present.
- `dist/concepts/index.html`: new "Backend (Supabase)" section
  rendered.

## Warnings

- `Failed to run pagefind via the npx wrapper … platform
  windows-x64 is not yet a supported architecture` — known
  non-fatal baseline environment issue (search index not built
  locally).
- `[WARN] [@astrojs/sitemap] The Sitemap integration requires the
  \`site\` astro.config option. Skipping.` — known non-fatal
  baseline issue.
- First build only: 3× `[WARN] [starlight-docs-loader] Duplicate
  id "concepts"/"roadmap"/"state-progression" … Later items with
  the same id will overwrite earlier ones.` — transient
  content-layer store collision on the files edited this session.
  Rebuild with zero file changes: warnings gone, 126 pages, only
  the two baseline warnings remain. Rendered output verified to
  carry the new content. No action needed; recorded for
  transparency.

## Constraints check

- No learner-app or senior files touched.
- No M24+ milestone pages created; no roadmap availability changes
  beyond M23.
- Lesson files copied verbatim (all 6 `cmp` byte-identical).

## Notes for QA

- M23 frontmatter `sidebar.order` = 0 (index) / 1–5 (lessons),
  matching M22 convention; autogenerate picks order from
  frontmatter.
- Cross-links inside lessons use absolute `/m23/<slug>/` paths —
  all six routes confirmed in build output.
- concepts.md "Backend (Supabase)" is a new section (first backend
  concepts on the site); M24/M25 should append rows there.
