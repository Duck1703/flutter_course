# Step 28 · 08 — Git Auto-Deploy Verification (empirical)

## Method

Step-28 deployment-metadata commit `1a38e5b` pushed to `origin/main` at ~00:40:5x. The commit introduces detectable production signatures: `/robots.txt` 200, `/sitemap-index.xml` 200, populated `<link rel="canonical" href="…">`, `/favicon.svg` 200. Polled both public domains.

## Results

| Domain | Project | Signature appeared | Evidence |
|---|---|---|---|
| `flutter-opal.vercel.app` | `flutter` | ~00:43:10 (+~2.5 min) | `robots.txt` 200, canonical `https://flutter-opal.vercel.app/`, home 27519B (was 27389B), sitemap 166 URLs, favicon.svg 200 |
| `fluttercourse-cyan.vercel.app` | `flutter_course` | ~00:41:59 (+~1.2 min) | `robots.txt` 200, same canonical content, sitemap 166 URLs |

## Conclusion

- **`flutter`: GIT_AUTO_DEPLOY = CONFIRMED.** The earlier deployment's `import` source type was a per-deployment trigger, not proof of absent Git integration. The project auto-deployed the push to `main` without any CLI/API action.
- **`flutter_course`: GIT_AUTO_DEPLOY = CONFIRMED** (`git` source type consistent).
- Both projects deploy the same repo/branch → every future `main` push produces TWO production deployments. Duplicate architecture is real and documented; consolidation deferred to human-approved cleanup (09).
- New auto-created deployment IDs are not readable via the current `VERCEL_TOKEN` scope (token cannot see these projects); deploy identity is proven by content signature instead.
