# Devin Adapter — Agent Product v1.0

**Adapter, not canonical.** Canonical system: `../../` (the
`agent-system/` tree). This file explains how the company maps onto a
single-agent runtime.

## The core limitation (stated honestly)

Devin executes as **one agent**. There are no native subagents to give
the six roles real process isolation. Role independence is therefore
**simulated** through discipline, not enforced by the runtime.

Simulation mechanics:

1. **Explicit stage boundaries.** One role hat at a time. While wearing
   Flux, produce Flux artifacts only.
2. **Separate artifact files.** Every stage writes its artifact to
   `AI_HANDOFF/work/milestones/M{N}/` before the next role starts. The
   file, not the conversation, is the handoff.
3. **Fresh re-reading at each stage.** When switching roles, re-read the
   artifacts from disk as if written by someone else.
4. **Argus treats prior output as untrusted.** Review = verify against
   real files and real commands, never the executor's earlier claims.
   The reviewer must not rely on "I remember writing this".
5. **No self-approval.** Even though one agent produces everything, an
   `*_APPROVED` may only be recorded when the required distinct review
   artifact(s) with verdict `PASS` exist — the artifacts enforce the
   separation the runtime can't.
6. **Dual stage-6 review, simulated blindness.** Argus content QA and
   Pedagogy Review run as **two sequential hats on the same
   `CONTENT_REVISION`**. Whichever hat runs second must not read the
   first reviewer's artifact until its own verdict is frozen on disk.
   `CONTENT_APPROVED` requires both.
7. **Atlas approval references review verdicts.** Every approval line
   cites the review artifact(s) it is based on — stage 6 cites both.

## Honest consequence

Simulated independence is weaker than real independence: the reviewing
context shares generation history with the authoring context. The smoke
test and the QA contract compensate with evidence-first checks, but the
limitation is recorded — if a real multi-agent runtime is later available,
prefer it.

## Usage

Human says: `Run Agent Company for M13.` (or `Continue the course.`)

Then follow `ORCHESTRATOR-PROMPT.md`. In short:

1. Read `agent-system/README.md` → `WORKFLOW-CONTRACT.md` →
   `TEAM-REGISTRY.md`.
2. Read `project-context/CURRENT_STATE.md` → `DECISIONS.md` → milestone
   roadmap section.
3. Create `AI_HANDOFF/work/milestones/M{N}/` + `00-status.md`.
4. Walk stages per `STATE-MACHINE.md`, switching role hats explicitly
   and writing each artifact to disk.
5. At `MILESTONE_COMPLETE`: canonical sync + supervisor report → stop.
6. Never start the next milestone in the same run.

## What this adapter must never do

- Treat simulated QA as equivalent to real independent QA in reports —
  the Step report must state how roles were executed.
- Skip an artifact because "the same agent knows the content" — the disk
  artifact is the contract.
- Store canonical knowledge in Devin memory, sessions, or summaries.
