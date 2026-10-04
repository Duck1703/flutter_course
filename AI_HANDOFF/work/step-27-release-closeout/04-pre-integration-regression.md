# STEP 27 — 04 PRE-INTEGRATION REGRESSION (on `79249c6`)

| Check | Result |
|---|---|
| `git diff --check` | **PASS** |
| `flutter analyze` (learner-app) | **PASS** — "No issues found!" |
| `flutter test` (learner-app) | **PASS — 396/396** |
| `flutter build web` (learner-app) | **PASS** — built in 71.0s (font tree-shake + wasm dry-run hints, non-blocking; same as Step-26 baseline) |
| `npm run build` (web) | **PASS — 167 page(s) built, Complete!** (pagefind windows-x64 + sitemap `site` warnings — pre-existing platform notes) |
| Milestone indexes | **29** |
| Learner lessons | **132** |
| Frontmatter | all valid |
| Markdown fences | all balanced |
| M30 directories | none |
| Unexpected routes | none (site output = milestone routes only) |

## Baseline diffs

- `git diff 9323e57 79249c6 -- learner-app/` → **empty** — zero app changes attributable to remediation
- Senior repo `D:/vibe_coding/flutter/flutter-accelerator-ai`: **clean**, HEAD `c8eb860ed9f4dbcda176c8282a9feb4d2d70d1d3` (matches Step-26 recorded baseline)
