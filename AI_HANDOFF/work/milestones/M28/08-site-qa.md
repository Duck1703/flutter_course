# M28 — Argus website QA

**Reviewer:** Argus (independent, `subagent_explore`)
**Scope:** `web/src/content/docs/m28/` (7 files), astro.config.mjs,
roadmap.md, index.mdx, state-progression.md, concepts.md, dist/ output.

## Round 1 verdict

**PASS_WITH_FINDINGS** — 2 MINOR + 1 NIT:

1. MINOR — `index.mdx:41–42` claimed M28 both complete and "đang
   được biên soạn" → fixed to "M29" only.
2. MINOR — `m28/index.md:28–29` "30 file lib/ khớp byte-với-byte"
   contradicted the same file's "28 verbatim + 2 converged" → fixed
   to "28 file khớp byte-với-byte + 2 file hội tụ chỉ khác
   doc-comment VI" in BOTH staged source and deployed copy.
3. NIT — `concepts.md` if-case row missing `(D-48)` tag carried by
   all 8 sibling M28 rows → added.

## Parent-executed verification (Argus profile lacks exec)

- `diff -q` on all 7 staged↔deployed pairs: **IDENTICAL**
  (post-remediation).
- `npm run build`: **159 pages**, Complete.

## Passed checks (Argus)

- Inventory: exactly 7 m28 files, identical names.
- Frontmatter valid on all 7 (title/description/sidebar label+order).
- Sidebar entry after M27, `directory: 'm28'`.
- Roadmap M28 `AVAILABLE`, M29 still `PLANNED`.
- Bước 19 table complete; technical claims spot-verified against
  lesson source (1s tween, pulse ≤0.2, 1.0→1.08, 260ms,
  `QzdsButtonScale`, `screenDesignWidth=375`, M29 deferral).
- concepts.md: exactly 9 M28 rows in correct sections; all
  `/m28/…` links resolve.
- dist/m28: 7 pages, Vietnamese titles, prev/next pagination
  correct, no stale pre-remediation text.
- No stale `M01–M27`/`M01-M27` anywhere in web/src.

## Final verdict

**PASS** — all findings remediated, byte-equality proven, build clean.
