# CONTENT HANDOFF CONTRACT — Lumen → (Argus, Atlas)

Lumen's stage-5 output lives in `AI_HANDOFF/work/milestones/M{N}/`:

- `04-content-draft.md` — the draft **index/manifest** (this contract)
- `lessons/index.md` — milestone overview draft
- `lessons/NN-slug.md` — one file per lesson, in teaching order

Template: `templates/content-draft-template.md` for the manifest;
`project-context/LESSON_TEMPLATE.md` for each lesson body (its 16 sections
are mandatory).

## The draft manifest (`04-content-draft.md`) must contain

1. **Lesson decomposition** — ordered list: slug, title, milestone
   coverage slice.
2. **Learning goals** — per lesson + milestone total.
3. **New concepts & first appearances** — table: concept | lesson where
   explained | where introduced in code.
4. **Prerequisite references** — which earlier milestones each lesson
   relies on (real taught items only).
5. **Incremental implementation** — confirmation each step is
   ≤ ~30 new/changed lines or justified.
6. **Code explanation coverage** — every snippet's new constructs are
   explained in or adjacent to the block.
7. **Android bridges** — per-lesson, three-line format.
8. **Senior evidence references** — citations used, with evidence class.
9. **Exercises/checks** — per lesson, with where answers are verifiable.
10. **Common mistakes** — per lesson.
11. **Intentionally delayed concepts** — what the draft names as deferred
    and where.
12. **Completion criteria** — binary checkpoint per lesson + milestone.
13. **Code snapshot alignment** — confirmation that every snippet matches
    the on-disk learner app at this milestone (or is labelled
    intermediate).

## Hard rules

- Drafts live **only** in `AI_HANDOFF/work/milestones/M{N}/`. Lumen never
  writes to `web/` — content enters the site only after
  `CONTENT_APPROVED`, via Forge.
- Code in lessons = code that exists (or will exist via the lesson's own
  steps) in `learner-app/` **at this milestone** — verified against Flux's
  approved evidence, never invented.
- If a necessary concept has no milestone that teaches it: do not silently
  absorb it — flag to Atlas (micro-intro or roadmap amendment decision).
- Vietnamese for learner-facing prose; technical terms stay in English
  where the course convention does so (follow existing M01–M12 style).
