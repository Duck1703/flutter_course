# Step 28 · 05 — Mobile / Desktop Smoke

## Mobile — 375×812 (iPhone-ish width)

| Route | HTTP | content | `<pre>` | h-scroll | mobile menu button |
|---|---|---|---|---|---|
| `/` | 200 (304 revalidate) | 1449 | 0 | no (scrollW 375 = clientW 375) | n/a splash |
| `/m01/01-…/` | 200 (304) | 8540 | 5 | no | yes |
| `/m29/07-…/` | 200 (304) | 26346 | 16 | no | yes |

No horizontal overflow; hamburger menu control present on lesson pages; code blocks reachable. MOBILE_SMOKE=PASS.

## Desktop — 1440×900

See 04-production-route-smoke table: sidebar stable, TOC column present on lesson pages, code blocks render (5–16 `<pre>` per page), no overflow, no missing CSS. DESKTOP_SMOKE=PASS.
