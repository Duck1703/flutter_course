# STATE MACHINE — Flutter Course Agent Product v1.0

Machine-readable milestone workflow states. Current state is recorded in
`AI_HANDOFF/work/milestones/M{N}/00-status.md` and mirrored nowhere else.
Course-level progress lives in `project-context/CURRENT_STATE.md` — this
machine never replaces it.

## States

```text
MILESTONE_PLANNED            milestone selected, scope read, no brief yet
BRIEF_READY                  01-brief.md complete
IMPLEMENTATION_IN_PROGRESS   Flux working on learner-app + evidence
IMPLEMENTATION_QA            Argus reviewing 02-* evidence + code
IMPLEMENTATION_APPROVED      Atlas approved (requires Argus PASS)
CONTENT_IN_PROGRESS          Lumen authoring 04-* + lessons/
CONTENT_QA                   Argus reviewing the draft
CONTENT_APPROVED             Atlas approved (requires Argus PASS)
SITE_IN_PROGRESS             Forge integrating into web/**
SITE_QA                      Argus reviewing site implementation
SITE_APPROVED                Atlas approved (requires Argus PASS)
MILESTONE_COMPLETE           Atlas final verdict + canonical sync + report
BLOCKED                      Argus BLOCKED or workflow halt; awaiting owner
BLOCKED_FOR_HUMAN            a §7 human gate was hit; only THE HUMAN unblocks
```

## Allowed transitions

| From | To | Trigger |
|------|----|---------|
| `MILESTONE_PLANNED` | `BRIEF_READY` | Atlas writes `01-brief.md` |
| `BRIEF_READY` | `IMPLEMENTATION_IN_PROGRESS` | Flux accepts brief |
| `IMPLEMENTATION_IN_PROGRESS` | `IMPLEMENTATION_QA` | Flux writes `02-*` + green gates |
| `IMPLEMENTATION_QA` | `IMPLEMENTATION_APPROVED` | Argus `PASS` + Atlas approval |
| `IMPLEMENTATION_QA` | `IMPLEMENTATION_IN_PROGRESS` | Argus `FAIL` → Flux remediates |
| `IMPLEMENTATION_QA` | `BRIEF_READY` | Argus `FAIL` + Atlas revises brief (dated addendum) |
| `IMPLEMENTATION_QA` | `BLOCKED` | Argus `BLOCKED` |
| `IMPLEMENTATION_APPROVED` | `CONTENT_IN_PROGRESS` | Lumen accepts evidence |
| `CONTENT_IN_PROGRESS` | `CONTENT_QA` | Lumen completes draft set |
| `CONTENT_QA` | `CONTENT_APPROVED` | Argus `PASS` + Atlas approval |
| `CONTENT_QA` | `CONTENT_IN_PROGRESS` | Argus `FAIL` → Lumen remediates |
| `CONTENT_QA` | `IMPLEMENTATION_IN_PROGRESS` | Argus `FAIL` + Atlas rules defect belongs to Flux |
| `CONTENT_QA` | `BLOCKED` | Argus `BLOCKED` |
| `CONTENT_APPROVED` | `SITE_IN_PROGRESS` | Atlas issues `06-site-handoff.md`; Forge accepts |
| `SITE_IN_PROGRESS` | `SITE_QA` | Forge completes integration + build |
| `SITE_QA` | `SITE_APPROVED` | Argus `PASS` + Atlas approval |
| `SITE_QA` | `SITE_IN_PROGRESS` | Argus `FAIL` → Forge remediates |
| `SITE_QA` | `CONTENT_IN_PROGRESS` | Argus `FAIL` + Atlas rules defect is content (Lumen re-drafts; handoff re-issued) |
| `SITE_QA` | `BLOCKED` | Argus `BLOCKED` |
| `SITE_APPROVED` | `MILESTONE_COMPLETE` | Atlas final verdict + canonical sync + report |
| `BLOCKED` | (the stage that blocked) | Blocking input/material resolved |
| any non-terminal state | `BLOCKED_FOR_HUMAN` | §7 human gate hit |
| `BLOCKED_FOR_HUMAN` | `MILESTONE_PLANNED` or prior valid state | THE HUMAN resolves and restates scope |

**Illegal:** any transition skipping a QA stage, any `*_APPROVED` without
the matching Argus `PASS` artifact, any transition issued by a role that
doesn't own it (Atlas owns forward transitions; Argus issues QA returns;
owners mark their own `*_IN_PROGRESS`).

## Remediation counter

Each QA→author loop increments a counter in `00-status.md`. Third
consecutive `FAIL` on the same stage pair forces Atlas reassessment
before another cycle (`WORKFLOW-CONTRACT.md` §3).

## Terminal discipline

`MILESTONE_COMPLETE` ends the run. The next milestone starts at
`MILESTONE_PLANNED` in a new `M{N+1}/` directory — never inside the
completed one.
