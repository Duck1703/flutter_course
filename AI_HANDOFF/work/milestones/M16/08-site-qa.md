# M16 — SITE QA (Argus, independent)

## Round 1 — FAIL (stale-read artifact + 1 real MINOR)

- Argus read canonical lessons via stale `read` cache → reported 4/6
  files "drifted" from web copies. Parent proved `diff` + `md5sum`
  byte-identical for all 6; canonical files DO contain remediations.
- Real MINOR: `state-progression.md` ASCII chain ended at M15 — fixed
  (added `Dialog-scoped VM (M16)` line) → rebuild 83 pages.

## Re-verify — PASS

Fresh Argus re-verify (grep-verified disk reads):
- canonical lessons 02/03/05 contain all remediation markers;
- `state-progression.md` diagram + Bước 7 present and accurate;
- emitted `dist/m16/` = index + 5 lessons; sidebar `M16 · Settings
  persist` under `Phase E`; prev/next m15↔m16 both directions;
- `roadmap.md` M16 AVAILABLE / M17+ PLANNED; `index.mdx` M01–M16;
- zero `/m17` links anywhere in dist; all 10 `/m16/` concept links resolve.

## Post-PASS mutations → REVERIFIED

- `menu_screen.dart` orphaned comment + lesson `super.subtitle` nit
  fixes (post content-PASS) → micro Argus mutation re-verify: PASS.
- Lesson F-13/F-14 sequencing fixes (L03/L04/L05 + web mirrors) →
  Argus content re-verify r3: FAIL on one residual (L04 run-command)
  → guarded → physical replay PROVES sequence (82/82 at L04,
  87/87+build at L05).

`npm run build` → **83 pages** (77 + 6 m16 routes).
M16_SITE_QA: PASS
