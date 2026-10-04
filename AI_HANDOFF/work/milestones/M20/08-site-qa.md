# M20 — SITE QA (Argus, independent)

## Round 1 — flagged FAIL, resolved as stale-read artifact

Independent site QA (subagent, full-content reads) reported one
HIGH: `m20/04-hoi-ai-va-dung-cuoc-choi.md` diverged from the
approved source — web copy carried the remediation edits
(renumbered Bước 3–7, `unawaited`→M11/D-17, sealed-test block,
`ListenableBuilder` comment) while the source read showed the
pre-remediation version.

**Root cause:** stale-read anomaly. The subagent's own process
note recorded *three* distinct file states observed mid-review
and one served-stale snapshot. The web copy was written from the
remediated source *after* r1 remediation; the QA read of the
source file hit a pre-remediation snapshot.

**Ground-truth verification (parent, post-review):** md5
byte-compare of all 6 files `AI_HANDOFF/…/lessons/` vs
`web/src/content/docs/m20/` → **all 6 IDENTICAL** at the fixed
state (L04 = 739 lines both sides, contains the remediation).

### All other checks — PASS (verified by subagent, unaffected by
the stale read)

- 6 files present, names 1:1 with source.
- `astro.config.mjs:133-135` — `m20` autogenerate in Phase F
  group after m19.
- `roadmap.md:62` — M20 = `status-available`; M21 stays planned.
- `index.mdx:41-42` — "M01–M20 … M21–M29 đang được biên soạn".
- `state-progression.md:142` — `### Bước 11` with correct 5-row
  table format.
- `concepts.md` — 9 new rows citing real `/m20/*` routes.
- `dist/m20/` — all 6 `index.html` pages generated with real
  content (`<title>M20 — Lifelines…`).
- Internal links — only 5 `](` links, all `/m20/…` slugs, all
  resolve.
- No m21+ leaks; sidebar ends at m20.
- Frontmatter valid on all 6 (order 0 + 1–5, correct labels).

### Residual fixed

- LOW `state-progression.md` header row `|| | |` → normalized to
  `| | |` matching prior steps; rebuilt green (108 pages).

## VERDICT: PASS

Site integration is byte-identical to approved content, routes
build clean, and no unapproved content edits exist (the reported
"divergence" was a stale read of an already-fixed file).
