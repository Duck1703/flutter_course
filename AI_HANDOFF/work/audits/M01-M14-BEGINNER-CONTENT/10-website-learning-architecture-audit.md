# 10 — Website Learning-Architecture Audit (Forge)

Site shape: Astro/Starlight. `docs/` tree = `index.mdx`, `getting-started.md`,
`m01`–`m14` directories, each = `index.md` (milestone overview: outcome,
lesson table, concepts-introduced list, completion criteria) + numbered lesson
pages. Roadmap page flips milestone status (M14 AVAILABLE / M15 PLANNED —
verified in built HTML during M14 site QA).

## Strengths

- **Consistent per-lesson skeleton** — learners always know where objectives,
  prerequisites ("Bạn đã biết gì"), mental model, mistakes, and self-check
  live. Repeatable structure is itself a learning aid.
- **Milestone index pages carry a concept table** ("Khái niệm được giới
  thiệu") — good for revisiting "where did I learn X".
- **Sidebar = milestone order**, prev/next links generated; page count
  (66 pages) appropriate; no mega-pages (largest lesson ~430 lines).
- Theory is **not buried**: mental-model and "vì sao" sections sit *before*
  the implementation steps in nearly every M01–M13 lesson.

## Gaps (learning-IA level)

| ID | Gap | Severity |
|----|-----|----------|
| IA-1 | **No concept glossary/index.** 76 concepts are introduced once each; the only revisit path is remembering which milestone taught it. No "concept → lesson" lookup. | LOW (P4) |
| IA-2 | **No progression map page** showing the setState→CN→Provider→events→repo-stream arc as a navigable story. Roadmap shows status, not conceptual dependencies. | LOW (P4) |
| IA-3 | Scaffolds are invisible as scaffolds *in the IA*: `_soundOn`, `_playTapCount`, the M06 ticker are presented as features; their temporary nature only surfaces at M13/03. A learner browsing M03/M06 can't tell them from permanent product. | LOW→MED (folds into F-05) |
| IA-4 | M14 lesson pages are the shortest and drop several named sections — the IA silently treats them as equivalent to richer M01–M13 pages. | MEDIUM (folds into F-06/F-07) |

## Density / decomposition

- Per-page length is healthy. Decomposition is good: e.g. navigation gets 3
  lessons, Provider gets 3, testing gets dedicated lessons.
- Exception: M14/03 tries to be ~4 topics in one page — a decomposition
  failure, not a length failure.

## Revisit-ability

A learner returning to "Stream" finds M06 (good). A learner returning to
"BehaviorSubject vs StreamController" finds it embedded inside a repository
lesson — concept discoverability for M14 topics is weak without a concept index.
