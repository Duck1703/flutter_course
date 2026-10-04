# CLAUDE.md — Bootstrap pointer only

This file wires Claude Code into the canonical system. It is not the
system. If anything here conflicts with `AI_HANDOFF/agent-system/**`, the
canonical tree wins.

## Start here (reading order)

1. `AI_HANDOFF/agent-system/README.md` — what the Agent Product is
2. `AI_HANDOFF/agent-system/WORKFLOW-CONTRACT.md` — binding process
3. `project-context/CURRENT_STATE.md` — live course state
4. `project-context/DECISIONS.md` — binding decisions
5. `AI_HANDOFF/agent-system/TEAM-REGISTRY.md` — roles and write scopes

## Rules (pointers, not copies)

- Use the canonical Agent Product for all milestone work — roles,
  gates, artifacts, and stage order are defined under
  `AI_HANDOFF/agent-system/`.
- Never bypass workflow gates: `QA PASS` ≠ `APPROVED`; only the Atlas
  role approves — impl/site after the matching Argus `PASS`, content
  after BOTH Argus technical `PASS` and Pedagogy Reviewer
  `PEDAGOGY_PASS`/`PEDAGOGY_PASS_WITH_NOTES` on the same
  `CONTENT_REVISION`.
- Dispatch roles as real `.claude/agents/` subagents where possible —
  especially Argus and the Pedagogy Reviewer, which must review
  outside the authoring context and independently of each other.
- The senior repo (`../flutter-accelerator-ai`) and the Android reference
  repo are read-only.
- `project-context/` is canonical state; `.claude/` is adapter wiring.
- Never commit secrets; never deploy/publish without human authorization.
