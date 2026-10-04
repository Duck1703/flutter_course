# M25 — Website QA (Argus)

## Verdict: `FAIL` → remediated → reverify `PASS` → SITE_APPROVED

## Findings

| # | Severity | Finding | Resolution |
|---|----------|---------|------------|
| F1 | HIGH (rendering defect) | `state-progression.md:194-200` Bước 16 rows written with doubled leading pipes (`|| | |`) → rendered as literal raw text, not a table | Atlas removed the extra `|` on the 6 offending lines; rebuilt → `dist/state-progression/index.html` now contains 17 `<table>`s and `mergeUserProfileForSync`/`onConflict`/`public.users` render **inside** the B16 table (preceding heading verified) |
| F2 | LOW (pre-existing) | `index.mdx:41` "đã hoàn thiện M01–M20" stale through M25 | Accepted pre-existing staleness (was stale since M21; not M25 regression) — noted for a future copy pass |
| F3 | LOW (doc accuracy) | `07-site-integration.md` cited duplicate-heading warnings that didn't fire in clean build | Noted; true baseline = pagefind windows-x64 + sitemap `site` only |

## Argus PASS items (independent run)

- `npm run build` → **138 pages**, exit 0; only baseline warnings.
- `diff -r` lessons ↔ `docs/m25/` → **byte-identical** (6/6).
- Sidebar: M25 after M24 in Phase-F group, `autogenerate: m25`,
  label `M25 · Đồng bộ hồ sơ`; no other mutations.
- `roadmap.md`: M01–M25 `AVAILABLE`, M26–M29 `PLANNED`; legend intact.
- `concepts.md`: exactly 5 rows (A-27..A-30 + B-08), registry IDs exact,
  links resolve.
- No M26+ dirs/hrefs/status flips.
- Spot-render: all 6 `/m25/` dist pages contain real markers
  (`mergeUserProfileForSync` 20–49×/page, `auth_uuid`, `AppUserData`,
  `_isSyncing`).
- Scope: only `astro.config.mjs`, `roadmap.md`, `state-progression.md`,
  `concepts.md`, `m25/*` touched; zero learner-app/senior/project-context
  outside `M25/` artifacts.

## SITE_APPROVED — Atlas (post-F1 remediation)
