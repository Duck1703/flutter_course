# Project Context

Stable identity document for the Flutter learning-course project. This file
should change rarely. Read it first, then `CURRENT_STATE.md`.

## Purpose

Rebuild the senior Flutter reference application **Flutter Accelerator AI**
("AI Millionaire" quiz game) progressively, as a learning course for an
experienced Android/Kotlin/Jetpack Compose developer who is a **beginner in
Dart and Flutter**.

The deliverable is a learner-facing project that reconstructs the senior
application feature-by-feature through guided steps — never by bulk-copying
the senior source.

## Paths

| Role | Path |
|------|------|
| Senior reference (READ-ONLY, immutable evidence) | `D:\vibe_coding\flutter\flutter-accelerator-ai` |
| Learner / course workspace | `D:\vibe_coding\flutter\flutter-course-accelerator-ai` |
| Canonical portable AI context | `D:\vibe_coding\flutter\flutter-course-accelerator-ai\project-context` |
| Supervisor reports (for human + supervising ChatGPT) | `D:\vibe_coding\flutter\report` |

## Learner Profile

- Experienced programmer; Android/Kotlin and Jetpack Compose experience.
- Has previously learned from a senior Android codebase.
- **Beginner** in: Dart, Flutter widget architecture, Flutter state
  management, Flutter navigation, Flutter project organization, lifecycle,
  tooling, build system, Flutter architectural conventions.
- Android knowledge may be used as a teaching **bridge**, never as a
  substitute for explaining Flutter concepts.

## Educational Philosophy

Progression pattern for each concept:

```
concept → beginner explanation → small isolated example
→ locate it inside the senior app → understand why the senior code uses it
→ reconstruct it in the learner project → verify behavior → continue
```

Rules:

- Treat the learner as a Flutter beginner even though they know Android.
- Simplify the senior implementation when it is too advanced; the senior
  code is the target, not the starting point.
- Every claim about the senior app must be grounded in its repository.
- The repository (not AI conversation history) is the source of truth.

## Source-of-Truth Hierarchy

1. Senior repository source code (`flutter-accelerator-ai/`) — behavior
   evidence. Never modified.
2. `project-context/` files in this workspace — durable decisions and
   audits. Canonical for agents.
3. `report/` — review artifacts for the supervising ChatGPT. Not canonical
   memory; important conclusions must be mirrored into `project-context/`.

## Portability Constraint

The project must remain usable across Devin, Claude Code, Cursor,
WorkBuddy, or any other agentic environment. Nothing important may live in
hidden memory, conversation history, or tool-specific state. Any agent must
be able to resume work by reading `project-context/` and the repositories.

## Constraints

- Senior repository is **read-only**: no edits, no commits, no dependency
  changes, no `flutter pub get`/build artifacts inside it unless explicitly
  approved later (prefer static inspection).
- Reports: after every substantial task, write a self-contained Markdown
  report to `D:\vibe_coding\flutter\report\STEP-XX-NAME.md` and append a
  row to `report/REPORT_INDEX.md`. Reports must stand alone — the
  supervising ChatGPT cannot see this filesystem.
- Do not commit secrets; Supabase/Google config comes from dart-defines and
  ignored env files.
