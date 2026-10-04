# Step 28 · 02 — Canonical Project Decision (drafted pre-push; finalized in 08/10)

## Criteria vs evidence

| Criterion | `flutter` | `flutter_course` |
|---|---|---|
| Repo `Duck1703/flutter_course` | yes (supplied meta) | yes (supplied meta) |
| Branch `main` | yes (supplied meta) | yes (supplied meta) |
| Production serves accepted main | YES — byte-identical to local build of `676c448` | YES — byte-identical |
| Stable public alias | `flutter-opal.vercel.app` — public, human-canonical URL | `fluttercourse-cyan` — public; `fluttercourse-java-spring` — SSO-walled |
| Git auto-deploy | UNKNOWN pre-push — deployment source `import` suggests manual | likely — deployment source `git`; proven empirically in 08 |
| Root/build config | not API-verifiable (token scope); build output matches `web/`+Astro | same |

## Decision rule applied

Canonical project = `flutter` **only if** the `1a38e5b` push triggers an automatic production redeploy on `flutter-opal.vercel.app`. If only `fluttercourse-cyan` updates, `flutter` lacks Git integration → `CANONICAL_WITH_ACTION_REQUIRED` (human links repo in Vercel UI or accepts `flutter_course` canonical). No alias moves; no deletions.

Result: see 08-git-auto-deploy + 10-production-closeout.
