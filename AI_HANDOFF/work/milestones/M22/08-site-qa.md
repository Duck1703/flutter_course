# M22 — SITE QA (Argus)

## Verdict: PASS (0 blockers)

Argus independently verified the Forge integration: 6 files
content-identical to approved sources, sidebar entry placed and
labeled per convention, roadmap flipped PLANNED→AVAILABLE, Bước 13
state-progression row cross-checked line-by-line against learner
code, 3 concept rows with correct /m22/ links, all hrefs resolve,
frontmatter valid on all pages, no stray files.

## Minor dispositions

- **Byte-identity caveat** — Argus lacked exec access; parent closed
  it with `git diff --no-index` on all 6 pairs → all identical.
- **VCS caveat** — `web/` is not a git repo; the course workspace is
  file-tracked (no `.git` at root either). Confirmed via `git status`
  failing at both roots; file inventory clean per Argus glob sweep.

## Nits (no action)

- Roadmap M22 "Bạn học được" paraphrase — matches row style.
- Sidebar `·` vs page `—` — consistent with M19–M21 convention.
- L04 "169 → 168" vs index "168/168" — consistent with taught
  arithmetic.

## Build

`npm run build` → **120 pages**, all `/m22/` routes present
(pagefind windows-x64 + sitemap `site` warnings = known non-fatal,
identical to M21 build).
