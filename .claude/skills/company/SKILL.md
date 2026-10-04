---
name: company
description: Route a course-level request ("run milestone M{N}", "continue the course") into the Flutter Course Agent Product workflow. Reads canonical state, then orchestrates per WORKFLOW-CONTRACT.md — dispatching the real .claude/agents roles.
---

# /company — adapter shim

> **Canonical skill:** `AI_HANDOFF/agent-system/skills/company/SKILL.md` —
> read it and follow it. This file adds only Claude-specific wiring.

Claude-specific wiring:

- The six roles are real dispatchable agents under `.claude/agents/`.
  Dispatch by name: `atlas-flutter-course-architect`,
  `flux-flutter-implementation-engineer`,
  `lumen-flutter-learning-expert`, `argus-course-qa-reviewer`,
  `pedagogy-reviewer`, `forge-course-website-engineer`.
- Argus AND `pedagogy-reviewer` MUST each be dispatched as fresh agents
  per review stage — independence is real here, do not simulate it.
  Stage 6 requires both on the same content revision, blind to each
  other.
- Canonical state is `project-context/`, not memory or summaries.
- Stage artifacts live in `AI_HANDOFF/work/milestones/M{N}/`.
- If a required native agent cannot be dispatched, report it honestly —
  do not substitute a generic agent or silently simulate.
