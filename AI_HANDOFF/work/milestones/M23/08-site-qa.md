# M23 — SITE QA (Argus, independent review)

Reviewed: `07-site-integration.md` claims vs live site state.
Review date: 2026-10-03 (build re-run 10:32 local).
Scope: `web/` only — read-only verification, no fixes applied.

## 1. Lesson files byte-identical

`cmp` run on all 6 pairs (`AI_HANDOFF/work/milestones/M23/lessons/` vs
`web/src/content/docs/m23/`):

- `index.md` — IDENTICAL
- `01-supabase-va-dart-define.md` — IDENTICAL
- `02-init-co-dieu-kien.md` — IDENTICAL
- `03-leaderboard-repository.md` — IDENTICAL
- `04-viewmodel-va-stale-guard.md` — IDENTICAL
- `05-dialog-va-menu-row.md` — IDENTICAL

No post-approval edits. All 6 carry valid Starlight frontmatter
(`title`, `description`, `sidebar.order` 0–5, `sidebar.label`).

## 2. Sidebar (`astro.config.mjs`)

Entry present at lines 144–147 inside "Phase F — Chiều sâu senior",
immediately after M22, before `]` closing the phase:

```js
{ label: 'M23 · Supabase & Bảng xếp hạng', autogenerate: { directory: 'm23' } }
```

Label matches handoff; rendered `dist/m23/index.html` sidebar shows the
same label. PASS.

## 3. Roadmap status

`roadmap.md` line 65: M23 = `status-available` (AVAILABLE).
M24, M25, M26, M27, M28 (Phase F) and M29 (Phase G) = `status-planned`.
Confirmed in rendered `dist/roadmap/index.html` — no pre-publish. PASS.

## 4. State progression

`state-progression.md` lines 172–180: **Bước 14 — Remote repository sau
contract: local → remote impl (M23)** appended after Bước 13 (M22), same
5-row table format (Vấn đề giải quyết / Cơ chế / Ai sở hữu / Hướng dữ
liệu / Còn thiếu). Content technically accurate and matches registry:

- conditional DI `client == null ? DisabledLeaderboardRepository :
  SupabaseLeaderboardRepository` — correctly tagged A-24;
- contract `LeaderboardRepository` — correctly tagged A-23;
- sealed `LeaderboardPopupState` + `isRefreshing`, `_requestId` stale
  guard (D-42) — matches lessons 03/04;
- owners `main()` (impl choice, app-scope) + `LeaderboardDialogViewModel`
  (dialog-scope) + repo (query chain/row mapping) — matches lessons;
- data flow row tap → `MenuLeaderboardRequested` →
  `showLeaderboardDialog` → VM `load()` → repo → `public.leaderboard`
  view → `LeaderboardSnapshot` → states → UI — matches lesson 05;
- remaining → M24/M25/M26/M28/M29 (adds M26 DRE beyond handoff minimum;
  consistent with registry D-42 "Reinforced: M26 (DRE cancel)").

The top summary diagram was not extended — consistent with prior
milestones (it already ended at M19/Bước 10; Bước 11–13 likewise absent).
PASS.

## 5. Concepts (`concepts.md`)

9 new rows verified against `project-context/LEARNER_CONCEPT_REGISTRY.md`
— every registered M23 concept is present, none invented, none filler:

| concepts.md row | Registry ID | Registry "First taught" | Link target |
|---|---|---|---|
| `RefreshIndicator.adaptive` + `AlwaysScrollableScrollPhysics` | F-32 | M23/05 | `/m23/05-dialog-va-menu-row/` ✓ |
| `String.fromEnvironment` / `--dart-define` | D-40 | M23/01 | `/m23/01-supabase-va-dart-define/` ✓ |
| Remote repository impl sau contract | A-23 | M23/02–03 | `/m23/02-init-co-dieu-kien/` + `/m23/03-leaderboard-repository/` ✓ |
| Conditional DI theo config | A-24 | M23/02 | `/m23/02-init-co-dieu-kien/` ✓ |
| `_requestId` monotonic stale guard | D-42 | M23/04 | `/m23/04-viewmodel-va-stale-guard/` ✓ |
| RLS / anon-key security boundary | B-01 | M23/01 | `/m23/01-supabase-va-dart-define/` ✓ |
| View-vs-table read model | B-02 | M23/01 | `/m23/01-supabase-va-dart-define/` ✓ |
| `Supabase.initialize` + `SupabaseClient` | F-31 | M23/02 | `/m23/02-init-co-dieu-kien/` ✓ |
| Query chain `select`/`order`/`limit`/`eq` + `maybeSingle` | D-41 | M23/03 | `/m23/03-leaderboard-repository/` ✓ |

New `## Backend (Supabase)` section placed between "Kiến trúc" and
"Navigation & test" — mirrors registry grouping. All link slugs resolve
to real files. "Củng cố ở" cells naming M24/M25/M28 are plain text, not
links. PASS — but see Finding F1 (evidence miscounts this as 8 rows).

## 6. Build

`cd web && npm run build` (re-run by Argus):

```
/m23/01-supabase-va-dart-define/index.html
/m23/02-init-co-dieu-kien/index.html
/m23/03-leaderboard-repository/index.html
/m23/05-dialog-va-menu-row/index.html
/m23/index.html
/m23/04-viewmodel-va-stale-guard/index.html
[build] 126 page(s) built
[build] Complete!
```

- Page count: **126** (120 baseline + 6) — matches handoff exactly.
- All 6 `/m23/` routes in build output; `dist/m23/` verified.
- Warnings: pagefind `windows-x64` unsupported (known baseline) +
  `@astrojs/sitemap` missing `site` (known baseline). The transient
  starlight-docs-loader duplicate-id warnings from the integrator's
  first build did **not** recur — clean rebuild confirms them gone.
- No new warnings.

## 7. Links / no M24+ leak

- `docs/` contains dirs `m01`–`m23` only — no m24–m29 directories.
- Grep `\(/m2[4-9]` across `web/src` — zero matches.
- Internal links inside `m23/` files: only `index.md` table, 5 links,
  all resolve to the 5 real lesson slugs.
- `concepts.md` M23 rows link only to real `/m23/` slugs (verified
  against rendered `dist/concepts/index.html` anchors/hrefs).

## 8. No leak into learner-app / senior

- Site-integration window established by mtimes: 10:28:54–10:31:01
  (copies + config edits + evidence file).
- `learner-app/` (excluding build/.dart_tool/.idea/windows): zero files
  modified after 10:00 — last app changes 09:40–09:47, i.e. the M23
  content-dev phase, ~40 min before integration began.
- Senior repo `../flutter-accelerator-ai`: zero files modified after
  10:00 today.

No site-integration edits leaked outside `web/`. PASS.

## Findings

- **F1 (minor, non-blocking):** `07-site-integration.md` §5 says "+8 rows
  across 4 existing sections + 1 new section" — actual is **9 rows across
  3 existing sections** (Nền widget ×1, Model & Dart ×1, Kiến trúc ×3)
  **+ 1 new section** (Backend ×4). The published content itself is
  correct and complete; only the evidence tally is off by one row/section.
- **F2 (informational):** Bước 14's "Còn thiếu" adds M26 (DRE replacing
  `_requestId` guard) beyond the handoff's M24/M25/M28/M29 list —
  accurate per registry D-42, not a defect.

```
ARGUS_M23_SITE_QA: PASS_WITH_FINDINGS
FILES_IDENTICAL: YES
SIDEBAR: PASS
ROADMAP_STATUS: PASS
STATE_PROGRESSION: PASS
CONCEPTS: PASS(9 rows)
BUILD: PASS(pages=126)
NEW_WARNINGS: none
NO_M24_LEAK: YES
BLOCKERS: none
```
