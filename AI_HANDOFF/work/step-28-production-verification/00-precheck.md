# Step 28 · 00 — Precheck

## Repository state (pre-flight)

| Check | Result |
|---|---|
| `git rev-parse --show-toplevel` | `D:/vibe_coding/flutter/flutter-course-accelerator-ai` PASS |
| `git branch --show-current` | `main` PASS |
| `git status --short` | clean PASS |
| `git rev-parse HEAD` | `676c44851c3a2592982ea19099311a6cf0e9764e` PASS |
| `git rev-parse origin/main` | `676c44851c3a2592982ea19099311a6cf0e9764e` PASS (post-hotfix) |
| local == remote | YES |

## Rollup hotfix verification

- `web/package.json` devDependencies: `@rollup/rollup-win32-x64-msvc` ABSENT — PASS
- `web/package-lock.json` root `devDependencies` declaration: ABSENT — PASS
- Platform binaries remain as `optional: true` transitive entries (incl. `rollup-linux-x64-gnu`) — expected auto-resolution mechanism, not a direct pin — PASS

## Local canonical build (pre-change baseline)

- `web/` → `npm run build` → PASS, **167 pages**, Pagefind indexed 166 pages / 18273 words
- `[WARN] [@astrojs/sitemap] The Sitemap integration requires the 'site' astro.config option. Skipping.` → confirmed missing `site:` defect (see 07-indexability)
- `git diff --check` → clean

## Tooling

- `vercel` CLI binary: not installed directly; `npx vercel` 62.2.0 works.
- `VERCEL_TOKEN`: set. Scope check (see 01-vercel-project-inventory) shows it cannot read the two known Flutter projects.
- Headless Chrome 143 available → real-browser smoke via puppeteer-core (installed in `%TEMP%/pp-smoke`, outside repo).
