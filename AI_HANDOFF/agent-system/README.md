# agent-system/ — Flutter Course Agent Product (canonical, tool-neutral)

> **Version: v1.0** — first production definition, built at Step 07.
> **Authority:** this directory is the permanent, tool-neutral definition of
> how the Flutter course is produced. It is canonical for **process and
> roles**. It is **not** canonical for **project state** — state lives in
> `project-context/` (see Source-of-Truth ordering below).

## 1. What the Agent Product is

A five-role course-production **company** that turns one approved milestone
at a time into: implemented learner-app code → verified evidence →
Vietnamese lessons → integrated website pages → a supervisor report.

The product is a set of Markdown contracts, role definitions, skills,
templates, and adapters. No runtime, no binaries, no tool lock-in.

## 2. Why it exists

Steps 01–06 were executed by one agent holding many roles implicitly.
M13–M29 are heavier (repositories, sealed classes, Supabase, DRE refactor,
localization, polish). The failure modes that matter for a teaching
product — premature concepts, code↔lesson drift, unverified senior claims,
self-approval — need **structural** prevention, not good intentions.

The Agent Product separates authoring from verification, makes every stage
produce a real artifact, and keeps a human-reviewable evidence trail.

## 3. Why it is tool-neutral

```
CANONICAL SYSTEM  (AI_HANDOFF/agent-system/**)
        ↓
tool adapter      (adapters/devin, adapters/claude-code, .claude/**)
        ↓
execution environment (Devin / Claude Code / Cursor / WorkBuddy / …)
```

Never the reverse. Tool configuration must never become the place where
project knowledge lives. If the tooling changes, the adapters change; the
canonical system does not.

**Adapters are thin pointers.** They may contain invocation wiring and
environment notes. They must not contain a second copy of a contract,
gate list, or role definition — that duplication is a known failure mode
(reference evidence: the Android course project maintained three copies of
its skill trees and they drifted).

## 4. The five roles

| ID | Name | One-line job |
|----|------|--------------|
| `atlas-flutter-course-architect` | **Atlas** | Owns scope, briefs, approvals, stage transitions, canonical state, final verdict |
| `flux-flutter-implementation-engineer` | **Flux** | Implements `learner-app/**` and produces verified implementation evidence |
| `lumen-flutter-learning-expert` | **Lumen** | Authors Vietnamese lessons from approved evidence — never from invention |
| `argus-course-qa-reviewer` | **Argus** | Independent evidence-based QA; PASS/FAIL/BLOCKED; never approves, never fixes |
| `forge-course-website-engineer` | **Forge** | Integrates CONTENT_APPROVED drafts into `web/**`; production build verification |

Full contracts: `TEAM-REGISTRY.md` + `agents/*.md`.

## 5. High-level workflow

```
THE HUMAN / SUPERVISOR
        ↓
Atlas → Milestone Brief → Flux → Implementation + Evidence
        ↓                                            ↓
   (scope fix)  ← Argus Implementation QA (FAIL)  PASS
        ↓                                            ↓
Atlas Implementation Approval → Lumen → Content Draft
        ↓                                            ↓
   (scope fix)  ← Argus Content QA (FAIL)         PASS
        ↓                                            ↓
Atlas Content Approval → Forge → Website Implementation
        ↓                                            ↓
   (scope fix)  ← Argus Website QA (FAIL)         PASS
        ↓                                            ↓
Atlas Final Milestone Verdict → Supervisor Report → THE HUMAN
```

No stage may be skipped. Exact state names and transitions:
`STATE-MACHINE.md`. Gate catalogue: `QUALITY-GATES.md`.
Full contract: `WORKFLOW-CONTRACT.md`.

## 6. How an AI agent should start

1. Read this README.
2. Read `WORKFLOW-CONTRACT.md` and `TEAM-REGISTRY.md`.
3. Read canonical **state** (never trust summaries):
   `project-context/CURRENT_STATE.md` → `DECISIONS.md` →
   `MILESTONE_ROADMAP.md` (current milestone section) → `CONTENT_STATUS.md`.
4. Check `AI_HANDOFF/work/milestones/` for an in-flight milestone.
5. Adopt exactly one role per artifact-producing step, per the workflow —
   in a multi-agent runtime dispatch the real role; in a single-agent
   runtime simulate role separation through stage boundaries (see
   `adapters/devin/README.md`).
6. Never assume hidden chat history. If required context is missing,
   stop per `WORKFLOW-CONTRACT.md` stop conditions.

## 7. Source-of-truth ordering

For **rules/process**: this directory → `project-context/AGENT_HANDOFF.md`
(day-to-day conventions) → active task specification.

For **project state** (highest wins):

1. `project-context/CURRENT_STATE.md` — where the course actually is
2. `project-context/MILESTONE_ROADMAP.md` — scope per milestone
3. `project-context/DECISIONS.md` — append-only decision log
4. `project-context/CONTENT_STATUS.md` — per-milestone delivery status
5. `project-context/M*_IMPLEMENTATION_NOTES.md` — per-step handoff notes
6. `AI_HANDOFF/work/milestones/M{N}/` — **temporary** milestone-production
   state (stage ledger, artifacts). Never overrides `project-context/`.
7. `report/STEP-*.md` — supervisor review artifacts
8. Senior repository `flutter-accelerator-ai/` — evidence only, read-only

Summaries, adapter files, and conversation history are **never** sources
of truth.

## 8. Creating a future tool adapter

1. Read `adapters/devin/README.md` and `adapters/claude-code/README.md` for
   the pattern.
2. Decide what the tool natively supports: real subagents (dispatch roles
   as separate agents) vs single agent (sequential role simulation with
   stage boundaries).
3. Write adapter files that **reference** canonical paths — never copy
   contract text into them.
4. Record the adapter's limitations honestly (e.g., simulated
   independence) in its README.
5. Register the adapter in `AGENT_PRODUCT.md` (project-context) under a
   dated note if it becomes load-bearing.

## 9. Hard rules (non-negotiable, restated for orientation)

- The senior repo `flutter-accelerator-ai/` is **read-only evidence**.
- `QA PASS` is never `APPROVED`. Only Atlas issues `*_APPROVED`.
- No role approves its own output. No role silently repairs another's.
- M{N} scope comes from `MILESTONE_ROADMAP.md` + the Atlas brief, not
  from convenience.
- The learner is an Android/Kotlin developer who is a **Flutter
  beginner** — `contracts/BEGINNER-FOLLOWABILITY-CONTRACT.md` is binding.
- Stop conditions route to THE HUMAN. Routine failures route to the
  producing role. Never improvise around a stop condition.
