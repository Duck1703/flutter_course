---
name: company
description: Route a course-level request ("run milestone M{N}", "continue the course") into the Flutter Course Agent Product workflow. Reads canonical state, then orchestrates per WORKFLOW-CONTRACT.md — dispatching the real .claude/agents roles.
---

# /company — adapter shim

> **Canonical skill:** `AI_HANDOFF/agent-system/skills/company/SKILL.md` —
> read it and follow it. This file adds only Claude-specific wiring.

Claude-specific wiring:

- The five roles are real dispatchable agents under `.claude/agents/`.
  Dispatch by name: `atlas-flutter-course-architect`,
  `flux-flutter-implementation-engineer`,
  `lumen-flutter-learning-expert`, `argus-course-qa-reviewer`,
  `forge-course-website-engineer`.
- Argus MUST be dispatched as a fresh agent per QA stage — independence
  is real here, do not simulate it.
- Canonical state is `project-context/`, not memory or summaries.
- Stage artifacts live in `AI_HANDOFF/work/milestones/M{N}/`.
- If a required native agent cannot be dispatched, report it honestly —
  do not substitute a generic agent or silently simulate.
