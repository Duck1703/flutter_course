# Step 28 · 07 — Indexability, Sitemap, Canonical Metadata

## Pre-change state (production @ 676c448)

| Item | State |
|---|---|
| `robots.txt` | 404 — absent (default crawlable, no sitemap pointer) |
| `sitemap-index.xml` | 404 — `@astrojs/sitemap` skipped because `site:` unset (build warning confirmed) |
| `<link rel="canonical">` | present but **empty** (`<link rel="canonical"/>` — no href) |
| `og:url` | present but empty |
| `meta robots` | none → indexable by default |
| Public reachability | `flutter-opal.vercel.app` + `fluttercourse-cyan` anonymous 200; `fluttercourse-java-spring` SSO-walled |

## Step-28 fix (branch `deployment/step28-production-metadata` → main `1a38e5b`)

- `web/astro.config.mjs`: `site: 'https://flutter-opal.vercel.app'` (the public, human-canonical domain — decided BEFORE config change, per protocol)
- `web/public/robots.txt`: allow-all + `Sitemap: https://flutter-opal.vercel.app/sitemap-index.xml`
- `web/public/favicon.svg`: minimal gold "M" coin mark (fixes per-page 404)

## Local post-change build verification

- `npm run build` → PASS, 167 pages, `sitemap-index.xml` created at `dist`
- `dist/index.html` canonical: `<link rel="canonical" href="https://flutter-opal.vercel.app/">` — populated
- `sitemap-0.xml`: **166 URLs** enumerated (all public pages; 404 page excluded as expected)
- `dist/robots.txt`, `dist/favicon.svg` present

INDEXABILITY=PASS (post-change), SITEMAP=PASS (post-change), ASTRO_SITE_CONFIG=UPDATED.
Production re-verification after redeploy recorded in 08/10.
