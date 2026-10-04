# M21 — SITE QA (Argus)

## Verdict: PASS (independent subagent)

Verified claim-by-claim:

1. `web/src/content/docs/m21/` — 6 files, all identical to
   `AI_HANDOFF/work/milestones/M21/lessons/` (full line-by-line
   comparison; identical truncation points and line counts).
2. `astro.config.mjs` — `M21 · Dialog layer kiểu senior` entry in
   Phase F after M20; syntactically valid; no m22/m23 entries.
3. `roadmap.md` — M21 `AVAILABLE`; M22–M29 remain `PLANNED`.
4. `concepts.md` — +5 rows all resolving to real `/m21/` slugs;
   `PopScope` reinforcement links `/m21/04-popscope-va-back-handling/`.
5. `state-progression.md` — Bước 12 appended after Bước 11; debt row
   cites M22 (FR-03/04), M26, M27 (FR-33), M28 (FR-32/34), M29.
6. Firewall: zero m22+ dirs in `src/content/docs/` and `dist/`;
   no config references.
7. `dist/m21/` — index + all 5 lesson dirs built; built title/sidebar
   verified genuine.
8. Consistency: index links → real filenames; sidebar.order 0–5
   unique ascending; edited tables balanced.

Page count independently counted: 108 milestone + 6 top-level =
**114** — matches.

Non-blocking observation: roadmap phase-grouping vs sidebar grouping
predates M21 (by design — sidebar lists only AVAILABLE milestones).

POST state: clean — no further edits to site files needed.
