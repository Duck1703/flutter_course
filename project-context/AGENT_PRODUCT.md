# Agent Product — v1.0

The portable multi-agent operating system that produces future milestones
(M13–M29). Built at Step 07; pending supervisor approval.

## Purpose

Steps 01–06 ran as a single agent holding many implicit roles. The Agent
Product makes the production process a **first-class, versioned,
tool-neutral artifact**: five roles, a stage machine, quality gates,
contracts, templates, and adapters — so that QA independence, scope
firewalls, and evidence discipline are structural rather than aspirational.

## Canonical path

```
AI_HANDOFF/agent-system/        ← the canonical definition (tool-neutral)
AI_HANDOFF/work/milestones/     ← per-milestone production area
AI_HANDOFF/work/smoke/          ← smoke-test artifacts (non-production)
.claude/                        ← Claude Code adapter (thin pointers only)
CLAUDE.md                       ← Claude bootstrap pointer
```

Tool adapters live in `agent-system/adapters/` and `.claude/`. They are
wiring, never knowledge — canonical truth stays in `agent-system/` and
`project-context/`.

## The team (five roles)

| Role | Job | Approves |
|------|-----|----------|
| **Atlas** | scope, briefs, stage transitions, canonical state, final verdict | `IMPLEMENTATION_APPROVED`, `CONTENT_APPROVED`, `SITE_APPROVED`, `MILESTONE_COMPLETE` — only after Argus `PASS` |
| **Flux** | senior evidence → `learner-app/` implementation + tests + evidence artifact | nothing |
| **Lumen** | Vietnamese lessons from approved evidence | nothing |
| **Argus** | independent QA — `PASS`/`FAIL`/`BLOCKED`, never `APPROVED` | nothing (validation only) |
| **Forge** | approved content → `web/**` integration + builds | nothing |

Full registry: `AI_HANDOFF/agent-system/TEAM-REGISTRY.md`.

## Workflow (one milestone)

```
Atlas brief → Flux implementation+evidence → Argus impl QA
→ Atlas IMPLEMENTATION_APPROVED → Lumen content draft
→ Argus content QA → Atlas CONTENT_APPROVED → Forge site integration
→ Argus site QA → Atlas SITE_APPROVED → Atlas final verdict
→ canonical sync → supervisor report → STOP
```

`QA PASS` is never `APPROVED`. No stage skipping. Full contract:
`AI_HANDOFF/agent-system/WORKFLOW-CONTRACT.md`; states:
`STATE-MACHINE.md`; gates: `QUALITY-GATES.md` (G1–G15).

## Tool portability

- **Canonical → adapter → runtime.** Never the reverse.
- Devin: single-agent role simulation with stage boundaries —
  `adapters/devin/` (README + `ORCHESTRATOR-PROMPT.md` for
  "Run Agent Company for M{N}").
- Claude Code: real subagents via `.claude/agents/` + `.claude/skills/`
  thin stubs + root `CLAUDE.md` pointer.
- New tools: create an adapter per `agent-system/README.md` §8.

## How to start a milestone

1. Read `agent-system/README.md` → `WORKFLOW-CONTRACT.md`.
2. Read `CURRENT_STATE.md` → confirm the approved next milestone.
3. Run `skills/company/SKILL.md`'s procedure (or the Devin orchestrator
   prompt).
4. All artifacts land in `AI_HANDOFF/work/milestones/M{N}/`.
5. Stop at `MILESTONE_COMPLETE`; never roll into the next milestone.

## Relationship to project context

- `project-context/` remains canonical for **state**; `agent-system/` is
  canonical for **process and roles**. `AGENT_HANDOFF.md` covers
  day-to-day conventions and predates the Agent Product — where they
  overlap on process, `agent-system/` is more specific and wins.
- `AI_HANDOFF/work/milestones/M{N}/` is temporary production state; it
  never overrides `project-context/`.

## Version

**v1.0** — initial definition. Version bumps are recorded here and in
`DECISIONS.md` when the system's contracts materially change; no release
infrastructure exists.
