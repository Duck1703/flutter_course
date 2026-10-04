# M18 — Argus website QA

**Verdict: PASS** (all 9 checks verified on disk + dist).

- Byte-identity: all 6 canonical↔web pairs identical line-for-line
  (frontmatter, headings, tables, synthesis). Parent-side MD5 hash
  proof also run during integration (all OK) — closes the
  invisible-bytes blind spot noted by reviewer.
- Sidebar: `astro.config.mjs:119-122` — M18 autogenerate under
  Phase E after M17.
- Roadmap: M18 AVAILABLE; M19–M29 remain PLANNED.
- Homepage: "M01–M18" complete / "M19–M29" in progress.
- Concepts: 3 rows added (F-26 overlay-in-Stack, D-32
  listEquals/unmodifiable, A-17 overlay-scoped VM) — all `/m18/…`
  links resolve to real files.
- State progression: intro arc line + `Bước 9` stage table present.
- Build output: `dist/m18/` = index + 5 lesson pages; total
  94 index.html + 404 = **95 pages** (claim verified).
- No `/m19/` dirs, files, or links anywhere.
- Internal links: all 9 `/m18/…` references resolve.

## Observation (non-blocking, pre-existing)

`roadmap.md` phase grouping places M14–M15 under Phase E while
`astro.config.mjs` places them under Phase D — predates M18
integration; flagged for a future consistency pass, not fixed here
(out of milestone scope).
