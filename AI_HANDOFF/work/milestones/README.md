# work/milestones/ — per-milestone production area

Temporary milestone-production state lives here, one directory per
milestone run. **This is not canonical course state** — canonical progress
lives in `project-context/CURRENT_STATE.md` (`WORKFLOW-CONTRACT.md` §0).

## Layout (created by the orchestrator at `MILESTONE_PLANNED`)

```text
M{N}/
├── 00-status.md                     stage ledger — updated every transition
├── 01-brief.md                      Atlas
├── 02-implementation-evidence.md    Flux
├── 03-implementation-qa.md          Argus
├── 04-content-draft.md              Lumen (manifest)
├── lessons/                         Lumen (draft lesson files)
│   ├── index.md
│   └── NN-slug.md
├── 05-content-qa.md                 Argus
├── 06-site-handoff.md               Atlas
├── 07-site-qa.md                    Argus
├── 08-final-verdict.md              Atlas
└── notes/                           optional scratch — never authority
```

## `00-status.md` format

```markdown
# M{N} — Workflow Status

Current state: ⟨STATE-MACHINE.md value⟩
Remediation cycles: impl ⟨n⟩ · content ⟨n⟩ · site ⟨n⟩

## Transition log (append-only)
- ⟨date⟩ MILESTONE_PLANNED → BRIEF_READY — Atlas — 01-brief.md r1
- …
```

## Rules

- One milestone directory per run; never reuse a completed one.
- Completed milestone dirs are never deleted or "cleaned" — they are the
  audit trail.
- Directories here are created at milestone start, not before. **No
  production artifacts for a milestone exist until its run begins** —
  a `M13/` dir appearing before M13's run would itself be a G15 defect.
