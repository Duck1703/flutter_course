# Agent Handoff

How to continue this project with zero conversation history. Read this
before any substantial work.

## Mandatory reading order

1. `PROJECT_CONTEXT.md` — purpose, paths, learner profile, constraints.
2. `CURRENT_STATE.md` — where the project actually is; the first file to
   consult for progress.
3. `DECISIONS.md` — established decisions; do not silently reverse them.
4. Task-relevant context files:
   - `SENIOR_SOURCE_AUDIT.md` — what the senior app contains (evidence).
   - `FEATURE_INVENTORY.md` — features, difficulty, teaching stance.
   - `ARCHITECTURE_MAP.md` — flows and wiring.
   - `FLUTTER_BEGINNER_GAPS.md` — prerequisite knowledge classes.
   - `ANDROID_TO_FLUTTER_MAP.md` — analogy bridges and traps.
   - `DEPENDENCY_GRAPH.md` — technical/learning prerequisites.
5. The senior repository itself when verification is needed
   (`D:\vibe_coding\flutter\flutter-accelerator-ai`, **read-only**).

## Rules

- The repository is the source of truth. Past AI conversation is NOT
  canonical — trust files, not memory.
- Verify against real source evidence before writing claims about the
  senior app; mark anything unverifiable as `UNVERIFIED`.
- Do not modify the senior repository (no edits, builds, pub get, commits).
- Write only where the current task permits. Learner app source, website,
  and curriculum content require explicit task scope.
- Update `CURRENT_STATE.md` after substantial work.
- Update `DECISIONS.md` only when a real decision is made (append entries).
- After every substantial task: write a self-contained report to
  `D:\vibe_coding\flutter\report\STEP-XX-NAME.md` and append a row to
  `report/REPORT_INDEX.md`. Reports must include enough evidence for a
  supervisor with no filesystem access.
- Respect scope: if the task says "discovery only", do not scaffold code.

## Portability

This project must remain portable between Devin, Claude Code, Cursor,
WorkBuddy, and other agentic environments. Keep all durable knowledge in
`project-context/` and `report/` as plain Markdown. Do not rely on any
IDE-specific memory, rules, or hidden state.
