# Step 28 · 10 — Production Closeout

## Final state

- `main` = `origin/main` = `1a38e5b86685cec514d60ce388f33e8d4423e189` (hotfix `676c448` + metadata `1a38e5b`)
- Production `https://flutter-opal.vercel.app` serves `1a38e5b` — auto-deployed by project `flutter` within ~2.5 min of push
- Canonical: project `flutter` (`prj_smy4y3CCRwMu66TTPDoZYoA7GKzc`), domain `flutter-opal.vercel.app`, repo `Duck1703/flutter_course`, branch `main`, build output = Astro static `dist/` of `web/` (proved by byte-identical output shape; root-dir field not API-readable under token scope)
- Git auto-deploy CONFIRMED on BOTH projects empirically (push → new production on both public domains)
- Duplicate `flutter_course` documented; deletion deferred (human action)

## Post-change regression (mandated)

| Gate | Result |
|---|---|
| `flutter analyze` | PASS — no issues |
| `flutter test` | PASS — 396/396 |
| `flutter build web` | PASS |
| `web/` `npm run build` | PASS — 167 pages + sitemap |
| `git diff --check` | clean |

## Post-deploy production verification (on 1a38e5b)

- `/` 200, `/m12/02/` 200, canonical populated per-page, `robots.txt` 200, `sitemap-index.xml` 200 → `sitemap-0.xml` 166 URLs, `favicon.svg` 200
- Real-browser console/network re-sweep: **0 errors, 0 failures** (favicon 404 resolved)

## Integrity

LEARNER_CONTENT_CHANGED=NO · LEARNER_APP_CHANGED=NO · SENIOR_SOURCE_CHANGED=NO · MILESTONE_ROUTES_CHANGED=NO · M30_CREATED=NO · VERCEL_PROJECT_DELETED=NO

## Verdicts

- PRODUCTION_VERDICT = `PRODUCTION_VERIFIED`
- CANONICALIZATION_VERDICT = `CANONICALIZED` (auto-deploy proven on the human-preferred project; duplicate flagged for deferred cleanup — not a blocker)
- READY_FOR_PRODUCTION_OBSERVATION = YES

## Known non-blocking notes

1. `VERCEL_TOKEN` scope cannot read the two Flutter projects → Vercel-side config fields (root dir, build cmd, env) recorded from human-supplied metadata + observable behavior, not API. If exact field-level proof is required, a token from the owning team is needed.
2. `favicon.ico` returns 404 (Starlight emits only the `favicon.svg` link; .ico never requested by browsers when the svg link resolves). Cosmetic only.
3. `fluttercourse-java-spring.vercel.app` alias is SSO-protected — never give it to learners.
4. Every `main` push currently triggers deployments in BOTH projects — harmless but redundant until cleanup.
5. Pagefind search lacks Vietnamese stemming (indexer note); exact-term queries verified working.
