# M14 — Site Handoff (Atlas → Forge)

Date: 2026-10-02 · Content state: `CONTENT_APPROVED`
(Argus `05-content-qa.md` r1 = PASS; Atlas approval logged in
`00-status.md`.)

## Approved content payload

Source (verbatim — do not edit teaching content):
`AI_HANDOFF/work/milestones/M14/lessons/`
- `index.md`
- `01-vi-sao-profilestore-chua-du.md`
- `02-rxdart-behavior-subject-valuestream.md`
- `03-ba-repository-va-multiprovider.md`
- `04-menuviewmodel-noi-vao-stream.md`

## Integration tasks (Forge)

1. Copy the five files into `web/src/content/docs/m14/` (verbatim —
   code fences and Vietnamese text byte-identical).
2. `web/astro.config.mjs` sidebar: add the M14 group under the
   existing phase-D entry (same shape as M13: `Tổng quan M14` +
   4 lessons, order 0–4, collapsed pattern of prior milestones).
3. Roadmap page (`web/src/content/docs/` roadmap file): M14
   `PLANNED` → `AVAILABLE`. **Only M14** flips; M15–M29 stay PLANNED.
4. Prev/next lesson links: follow the established frontmatter/link
   convention already used by M13 pages (check how m13 wires order —
   Starlight sidebar `order` handles prev/next automatically; keep
   whatever convention m13 used).
5. `npm run build` must pass; record real output (page count, caveats
   like the known duplicate-id warnings + pagefind Windows skip).
6. Write evidence into `07-site-qa` inputs are Argus's, but record a
   short Forge note in the M14 work dir or inside the QA exchange:
   files copied, sidebar entries added, roadmap diff, build result.

## Boundaries

- Forge touches only `web/` + this handoff's evidence notes. No
  learner-app edits, no lesson-content edits, no canonical state.
- Do not create `m15/` or any future-milestone directory.
- Do not deploy/publish.
