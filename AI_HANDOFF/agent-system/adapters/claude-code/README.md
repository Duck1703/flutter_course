# Claude Code Adapter — Agent Product v1.0

**Adapter, not canonical.** Canonical system: `../../` (the
`agent-system/` tree). Never copy contract text into adapter files.

## What Claude Code supports natively

- **Subagents** (`.claude/agents/*.md`) — real role dispatch is possible:
  each of the six roles maps to a native agent file.
- **Skills** (`.claude/skills/*/SKILL.md`) — on-demand protocol loading.
- **CLAUDE.md** at repo root — always-on project memory; keep it a thin
  pointer, not a copy of the workflow.

## Adapter layout in this repo

```text
.claude/
├── agents/   6 files — one per role; each points to
│             AI_HANDOFF/agent-system/agents/<role>.md as its contract
└── skills/   7 files — one per skill; each points to
              AI_HANDOFF/agent-system/skills/<skill>/SKILL.md
CLAUDE.md     thin bootstrap pointer (repo root)
```

Every `.claude/` file says where its canonical definition lives and adds
only Claude-specific invocation wiring. If a `.claude` file and the
canonical file disagree, **the canonical file wins** — fix the adapter.

## Dispatch model

Claude Code can spawn real subagents, so role independence is **real**
here (unlike the single-agent Devin simulation): dispatch
`argus-course-qa-reviewer` and `pedagogy-reviewer` as separate fresh
agents so they review without the authoring context — and without each
other's verdicts. Prefer a fresh agent instance for each QA stage over
reusing the author's context.

## Rules that survive any adapter

- `QA PASS` ≠ `APPROVED`; only the Atlas agent issues `*_APPROVED`.
- No `.claude/` file contains project truth — the canonical tree does.
- Agents read state from `project-context/`, never from memory files.
