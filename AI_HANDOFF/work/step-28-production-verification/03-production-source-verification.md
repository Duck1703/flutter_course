# Step 28 · 03 — Production Source Verification

## Method

Local build of `main` (`676c448`, pre-metadata commit) vs live production bytes.

## Results

| Check | Result |
|---|---|
| `GET https://flutter-opal.vercel.app/` | HTTP 200, `Server: Vercel`, no auth wall — publicly reachable |
| prod home vs `web/dist/index.html` | **BYTE-IDENTICAL** (26918 chars, same content-hashed `_astro` assets: `index.8xWNZ1cf.css`, `Search...CJiOmi4V.js`, `page.B1D-nYk3.js`, `print.DNXP8c50.css`) |
| prod `/m12/02-read-vs-watch/` vs `web/dist/.../index.html` | **BYTE-IDENTICAL** — page contains Step-26A remediation markers (`ĐỌC TRƯỚC` preview boundary, `context.read` teaching) → post-remediation content is live |
| Supplied deployment meta | `dpl_3zeC2EbsuYX1WiXCAPqgiffAXAfa` READY, source commit `676c448` |
| `fluttercourse-cyan.vercel.app/` | 200, byte-identical home (same commit) |
| `fluttercourse-java-spring.vercel.app/` | 302 → `vercel.com/sso-api?...` — SSO-protected alias, NOT learner-reachable |

## Verdict

`PRODUCTION_SOURCE_MATCHES_MAIN=YES` (verified against `676c448`; after the Step-28 metadata push, main advanced to `1a38e5b` — see 08 for redeploy observation).
`PRODUCTION_READY=YES`.
