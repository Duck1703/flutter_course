# Step 28 · 06 — Search (Pagefind), Static Assets, Console/Network

## Search — REAL functional test on production

Headless Chrome on `https://flutter-opal.vercel.app/`:

1. Search dialog opened (button click) — OK
2. Typed `Provider` into `.pagefind-ui__search-input` — OK
3. **5 results** returned; first result: `Bài 3 · ChangeNotifierProvider & scope` (m12/03) — relevant
4. Clicked first result → navigated to `/m12/03-changenotifierprovider-va-scope/` — result navigation works

Index assets on production: `/pagefind/pagefind.js` 200 (45.5KB), `pagefind-ui.js` 200 (120KB), `pagefind-entry.json` 200, `pagefind-highlight.js` 200. Index was built during the Vercel Linux deploy (not affected by the historical Windows local-build Pagefind limitation).

SEARCH_PAGEFIND=PASS.

## Static assets

`_astro/index.8xWNZ1cf.css`, `Search…CJiOmi4V.js`, `page.B1D-nYk3.js`, `print.DNXP8c50.css` → all 200, content-hash matches local `dist/`. No systematic missing-resource errors. STATIC_ASSETS=PASS.

## Console / network (all 6 desktop routes + 3 mobile + search)

- Errors: exactly ONE — `GET /favicon.svg` → 404 (referenced by Starlight default `<link rel="icon">`, file absent from `web/public` until Step-28 metadata commit which adds `web/public/favicon.svg`).
- Classification: NON_BLOCKING (cosmetic icon fetch). Fixed by metadata commit `1a38e5b`.
- No JS errors, no failed CSS, no API failures.

CONSOLE_NETWORK=PASS_WITH_NOTE → resolved by `1a38e5b` (verify post-deploy).
