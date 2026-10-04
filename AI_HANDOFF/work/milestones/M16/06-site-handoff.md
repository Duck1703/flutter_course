# M16 — SITE HANDOFF (Atlas → Forge)

Content APPROVED (`05-content-qa.md` PASS). Integrate only the
approved lesson set — do not pre-publish M17+.

## Deliverables

- Copy `work/milestones/M16/lessons/*.md` (index + 5) to
  `web/src/content/docs/m16/` — keep filenames; web copies must stay
  byte-identical to canonical lessons (check: only frontmatter/
  sidebar conventions differ per established pattern — for M15 the
  web copies were byte-identical).
- `index.md` frontmatter: `title: "M16 — ..."`, `sidebar.label:
  Tổng quan M16`, `order: 0` (same convention as m15/index.md).
- `roadmap.md`: M15 stays AVAILABLE → add/advance M16 row to
  AVAILABLE; M17–M29 remain PLANNED.
- `concepts.md`: add M16 concept rows (F-23 Switch, F-24 wheel
  picker, A-15 dialog-scoped VM, D-29 padLeft, D-30 late) linking to
  the lessons.
- `state-progression.md`: add the M16 stage — "repository→stream→
  dialog-scoped VM→controls→persisted UI" second domain loop.
- `index.mdx` (homepage): update progress claim M01–M16 complete /
  M17–M29 đang biên soạn.
- No `/m17` or later links anywhere.

## Verify before handoff back

- `npm run build` green; new routes `/m16/`, `/m16/01..05` present;
  sidebar shows M16; prev/next links m15↔m16 correct; concept-index
  links resolve; roadmap row correct; Pagefind Windows caveat OK to
  note if it recurs.
