---
name: company
description: Human-facing entrypoint + orchestration protocol for running one milestone through the complete Agent Product workflow (Atlas → Flux → Argus → Lumen → Argus → Forge → Argus → Atlas). Use for "run milestone M{N}", "continue the course", or any request that means "execute the company workflow".
---

# company — milestone orchestration entrypoint

This skill routes a human request into the canonical workflow and — in
runtimes without native subagents — serves as the orchestration loop that
walks the stage machine. It never authors, implements, reviews, or
approves on its own; it enforces `WORKFLOW-CONTRACT.md`.

## Follow (canonical, do not restate)

- `../../WORKFLOW-CONTRACT.md` — stages, verdicts, routing, human gates
- `../../STATE-MACHINE.md` — states and legal transitions
- `../../TEAM-REGISTRY.md` — who may do/approve what
- `../../QUALITY-GATES.md` — gates per stage

## Procedure

1. **Intake.** Identify the approved next milestone from
   `project-context/CURRENT_STATE.md` (not from the request's guess, not
   from memory). If the request names a different milestone than canonical
   state supports, flag it.
2. **Reconciliation read.** Read `DECISIONS.md`, the milestone's roadmap
   section, the latest `M*_IMPLEMENTATION_NOTES.md`.
3. **Create the work area.** `AI_HANDOFF/work/milestones/M{N}/` +
   `00-status.md` initialized to `MILESTONE_PLANNED`.
4. **Adopt Atlas.** Produce `01-brief.md`; advance to `BRIEF_READY`.
5. **Walk the machine.** For each stage, dispatch/adopt the owning role,
   require its artifact on disk, verify entry criteria before the next
   role starts, record every transition in `00-status.md`.
6. **Enforce separation.** In multi-agent runtimes dispatch real roles.
   In single-agent runtimes (Devin): one role hat per stage, artifacts
   committed to disk between roles, reviewer reads fresh —
   `adapters/devin/README.md`.
7. **Stop conditions.** `BLOCKED`/`BLOCKED_FOR_HUMAN` halt the loop;
   report verbatim. Never improvise around them.
8. **Close.** At `MILESTONE_COMPLETE`: Atlas canonical sync + supervisor
   report. Then STOP — do not start the next milestone.

## Verification duties (orchestrator-level)

- Artifact exists on disk before its consumer stage starts.
- `*_APPROVED` is never issued without the matching Argus `PASS` file.
- No stage output comes from the wrong role.
- Workflow state transitions match `STATE-MACHINE.md` exactly.

## Failure behavior

- Missing artifact at a gate → do not advance; report.
- QA `FAIL` → route per remediation table; increment the remediation
  counter in `00-status.md`; 3rd consecutive FAIL → Atlas reassessment.
- Dispatch unavailable in a runtime that requires it → report honestly as
  a limitation (or use the documented single-agent simulation — never
  pretend independence is real when simulated).
