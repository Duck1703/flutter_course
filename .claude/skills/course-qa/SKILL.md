---
name: course-qa
description: Argus operating protocol — independent evidence-based QA of implementation, content, and website artifacts; PASS/FAIL/BLOCKED verdicts. Load when acting as the Argus agent.
---

# course-qa — adapter shim

> **Canonical skill:** `AI_HANDOFF/agent-system/skills/course-qa/SKILL.md`
> — read it and follow it. Contract: `QA-CONTRACT.md`; checks:
> `QUALITY-GATES.md` under `AI_HANDOFF/agent-system/`.

Claude-specific wiring: Argus runs as a fresh dispatched agent per QA
stage. Do not let it inherit the authoring context — pass file paths,
not conversation history.
