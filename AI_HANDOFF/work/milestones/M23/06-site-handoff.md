# M23 — SITE HANDOFF (Atlas → Forge)

Milestone: M23 — Supabase bootstrap & Leaderboard
Content state: CONTENT_APPROVED (Argus PASS + reverify PASS)
Baseline: site 120 pages

## Approved lesson files (source of truth)

`AI_HANDOFF/work/milestones/M23/lessons/` — copy verbatim to
`web/src/content/docs/m23/`:

- `index.md` (sidebar order 0)
- `01-supabase-va-dart-define.md`
- `02-init-co-dieu-kien.md`
- `03-leaderboard-repository.md`
- `04-viewmodel-va-stale-guard.md`
- `05-dialog-va-menu-row.md`

## Integration actions (mirror M22 recipe)

1. Copy the 6 files → `web/src/content/docs/m23/`.
2. `astro.config.mjs` — sidebar entry after M22:
   `M23 · Supabase & Bảng xếp hạng` → `autogenerate: m23`.
   (Use the actual lesson index `title`/`sidebar.label`.)
3. `roadmap.md` — M23 row → `AVAILABLE`. M24/M25/M26+ stay `PLANNED`.
   Never pre-publish future milestone pages.
4. `state-progression.md` — append one legitimate architecture row:
   **Bước 14 — Remote repository sau contract: local → remote impl
   (M23)** — problem: data source chuyển từ static/local sang remote
   mà UI không đổi; mechanism: contract + conditional DI
   (`client == null ? Disabled : Supabase`) + sealed popup states +
   stale guard; owner: `LeaderboardRepository` +
   `LeaderboardDialogViewModel`; data-flow: row tap → VM → repo →
   Supabase view → snapshot → states → UI; remaining: auth (M24),
   sync (M25), dialog layer (M29), visual parity (M28).
   Keep the table format M22 used.
5. `concepts.md` — add rows ONLY for concepts genuinely taught:
   - dart-define / `String.fromEnvironment` config (D-40 → m23/01)
   - Conditional remote client init (A-23 → m23/02)
   - Remote repository behind contract (A-24 → m23/03)
   - Query chain semantics select/order/limit/maybeSingle (B-01/02 →
     m23/03 — use the actual registry IDs Lumen assigned)
   - Stale-response guard `_requestId` (D-42 → m23/04)
   - `RefreshIndicator` (F-31/32 → m23/05 — actual IDs from registry)
   Read `project-context/LEARNER_CONCEPT_REGISTRY.md` for the exact
   IDs/labels Lumen registered — use those, don't invent.

## Constraints

- No learner-app or senior files touched.
- No M24+/future milestone pages or roadmap availability changes.
- Build: `cd web && npm run build`. Expected pages: 120 + 6 = **126**.
- Pagefind windows-x64 warning + sitemap `site` warning are known
  non-fatal baseline environment issues — record, don't fix.
- Evidence → `AI_HANDOFF/work/milestones/M23/07-site-integration.md`:
  file list, page count, build output, warnings.
