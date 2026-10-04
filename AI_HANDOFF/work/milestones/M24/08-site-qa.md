# M24 — SITE QA (Argus, independent)

Scope: verify `07-site-integration.md` claims against the live `web/`
tree, the approved lessons, and `LEARNER_CONCEPT_REGISTRY.md`.
Read-only review; only this file was written.

## Checks performed

### 1. Lesson files byte-identical — PASS

`cmp` on all 6 files
`AI_HANDOFF/work/milestones/M24/lessons/` vs
`web/src/content/docs/m24/`:

```
IDENTICAL: index.md
IDENTICAL: 01-session-model.md
IDENTICAL: 02-supabase-auth-impl.md
IDENTICAL: 03-sync-seam-va-coordinator.md
IDENTICAL: 04-dialog-vms-va-menu.md
IDENTICAL: 05-auth-ui.md
```

### 2. Sidebar — PASS

`web/astro.config.mjs:149-150`:
`{ label: 'M24 · Đăng nhập & Phiên', autogenerate: { directory: 'm24' } }`
immediately after M23 (145-146), inside "Phase F — Chiều sâu senior"
(126). Rendered `dist/m24/index.html` shows the label in sidebar nav.

### 3. Roadmap — PASS

Source `web/src/content/docs/roadmap.md:66` — M24 `status-available`;
M25–M29 `status-planned` (67-70, 76). Rendered
`dist/roadmap/index.html` per-row regex: M23/M24 `available`,
M25–M29 `planned`. Only M24 flipped.

### 4. State progression — PASS

`web/src/content/docs/state-progression.md:182-190` — Bước 15 appended
after Bước 14 (M23), same 5-row table (Vấn đề giải quyết / Cơ chế /
Ai sở hữu / Hướng dữ liệu / Còn thiếu). Content matches handoff §4:
sealed `AuthSessionData` (guest chính danh), `authStateStream`
BehaviorSubject seeded (M14 pattern), `AuthActionResult` value-type,
conditional DI `DisabledAuthRepository`/`AuthRepositoryImpl`,
`MenuAuthActionCoordinator` chain `signIn*→loadAuthState→guard→
syncUserProfile` / `signOut→resetUserProfile`, data-flow pill tap →
`requestAuthAction` → dialog VM → coordinator → repo → stream →
re-render; remaining → M25/M26/M29, `LIVE_AUTH_FLOW: NOT_PERFORMED`.
Rendered `dist/state-progression/index.html` contains the Bước 15
heading.

### 5. Concepts — PASS (9 rows, all real registry IDs)

Cross-checked against
`project-context/LEARNER_CONCEPT_REGISTRY.md` — every claimed ID
exists, label/description matches, and the concepts.md lesson link
matches the registry "taught at" column:

| concepts.md line | Registry ID | Link | Registry taught-at | Match |
|---|---|---|---|---|
| 70 (Model & Dart) | D-43 sealed union identity | `/m24/01-session-model/` | M24/01 | OK |
| 71 (Model & Dart) | D-44 `AuthActionResult` | `/m24/01-session-model/` | M24/01 | OK |
| 130 (Kiến trúc) | A-25 auth session stream | `/m24/01-session-model/` | M24/01 | OK |
| 131 (Kiến trúc) | A-26 action coordinator | `/m24/03-sync-seam-va-coordinator/` | M24/03 | OK |
| 141 (Backend) | B-03 `signInWithIdToken` | `/m24/02-supabase-auth-impl/` | M24/02 | OK |
| 142 (Backend) | B-04 `google_sign_in` v7 | `/m24/02-supabase-auth-impl/` | M24/02 | OK |
| 143 (Backend) | B-05 `onAuthStateChange`+seed | `/m24/02-supabase-auth-impl/` | M24/02 | OK |
| 144 (Backend) | B-06 auth≠authorization≠profile | `/m24/01-session-model/` | M24/01 | OK — marked "(awareness)", registry LIGHT/INTRODUCED |
| 145 (Backend) | B-07 SHA-256 nonce OIDC | `/m24/02-supabase-auth-impl/` | M24/02 appendix | OK — marked "(awareness)", registry LIGHT/INTRODUCED |

No invented IDs. Awareness rows correctly flagged and placed in the
Backend (Supabase) section per registry grouping.

### 6. Build — PASS (132 pages)

`cd web && npm run build` re-run by Argus:

- `[build] 132 page(s) built` — 126 baseline + 6 = 132, matches.
- All six `/m24/` routes emitted; `dist/m24/` on disk contains
  `index.html` + 5 lesson dirs each with `index.html`.
- Warnings: only the two known baselines — pagefind windows-x64
  unsupported platform, and `@astrojs/sitemap` missing `site` option.
  The 3 transient `starlight-docs-loader` duplicate-id warnings noted
  in the evidence (first build only) did **not** recur on this rebuild.

### 7. Frontmatter / links / m25+ — PASS

- All 6 m24 files have valid YAML frontmatter (`title`, `description`,
  `sidebar.label`, `sidebar.order` 0–5).
- m24 docs contain exactly 5 markdown links — all `/m24/<slug>/` to
  real lesson slugs; zero other links (cross-milestone refs are
  plain-text).
- `web/src/content/docs/` contains m01–m24 only; **no m25+ dirs**.

### 8. Leakage — PASS

Web-source mtime footprint after 11:55 is exactly the 10 claimed files
(6 m24 docs + `astro.config.mjs` + `roadmap.md` +
`state-progression.md` + `concepts.md`). `learner-app/lib|test|
pubspec` last touched 11:51 (implementation phase, pre-site window).
Senior repo `../flutter-accelerator-ai` (read-only): **0** files
modified in the site-integration window.

## Verdict

```
ARGUS_M24_SITE_QA: PASS
FILES_IDENTICAL: YES
SIDEBAR: PASS
ROADMAP_STATUS: PASS
STATE_PROGRESSION: PASS
CONCEPTS: PASS(9)
BUILD: PASS(pages=132)
NEW_WARNINGS: none
NO_M25_LEAK: YES
BLOCKERS: none
```

## Notes (non-blocking)

- Evidence claimed a first-build transient duplicate-id warning set;
  verified absent on clean rebuild — consistent with M23 pattern.
- concepts.md rows carry no visible registry-ID column (house style);
  mapping above was verified by content match, not ID display.
