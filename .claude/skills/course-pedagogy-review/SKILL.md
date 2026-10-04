---
name: course-pedagogy-review
description: Pedagogy Reviewer operating protocol — independent learner-first review of educational content using the P1–P12 model; copy-vs-reasoning, scaffold-fading, exercise-difficulty, learner-noise, and misconception instruments; PEDAGOGY_* verdicts. Load when acting as the Pedagogy Reviewer.
---

# course-pedagogy-review — adapter shim

> **Canonical skill:** `AI_HANDOFF/agent-system/skills/course-pedagogy-review/SKILL.md`
> — read it and follow it. Contract: `PEDAGOGY-REVIEW-CONTRACT.md`;
> template: `templates/content-pedagogy-review-template.md` under
> `AI_HANDOFF/agent-system/`.

Claude-specific wiring: the Pedagogy Reviewer runs as a fresh dispatched
agent, as a peer of Argus at stage 6. Do not let it inherit the authoring
context or Argus's review — pass file paths, not conversation history.
