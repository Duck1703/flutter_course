# 00 — Audit Charter: M01–M14 Beginner Learning Content Audit

## Mode

SPECIAL AUDIT MODE — BEGINNER LEARNING CONTENT & CURRICULUM GOVERNANCE.
Read-only over `learner-app/**`, `web/src/content/**`, and the senior repo.
Writes permitted only under `AI_HANDOFF/work/audits/**`, `report/**`, and new
`project-context/**` governance artifacts that do not alter course progression.

## Trigger

Human review of the live website reports: the course is too focused on
reproducing project code; Flutter/Dart concepts are explained too briefly; a
beginner can follow code changes without understanding concepts, mental models,
syntax, lifecycle, or architectural reasoning. Prior QA verified technical
correctness, senior fidelity, code↔lesson consistency, and milestone
boundaries — NOT pedagogical depth. This audit answers the different question:
**can a Flutter beginner actually learn Flutter deeply from this course?**

## Learner profile

- Knows general programming, Kotlin, Android/Jetpack Compose.
- Knows ViewModel/repository at Android level.
- Near-complete beginner in Dart and Flutter.
- Android experience is a bridge, not a substitute for Flutter theory.
- Generic programming concepts (variables, if/else, loops) need NOT be retaught
  unless Dart behaves materially differently.

## Audit questions per lesson

Does the lesson teach WHAT/WHY/HOW/WHEN/WHEN-NOT of each concept; lifecycle &
ownership; relevant syntax; relation to prior knowledge; transfer outside this
project; learner self-explanation after completion? If the answer is mostly
"they can copy the project code" → pedagogically insufficient.

## Roles

- **Atlas** — audit lead: charter, learner profile, progression, prerequisite
  graph, milestone sequencing, theory-vs-project balance, final verdict,
  remediation priority.
- **Lumen** — primary auditor: inspected EVERY lesson M01–M14 (all 48 real
  lessons, not samples) for comprehensibility, depth, mental models, syntax,
  prerequisite closure, examples, exercises, transfer, analogies, lifecycle,
  mistakes, self-checks.
- **Flux** — technical support: concept inventory from actual learner code;
  verified explanations against real Flutter/Dart semantics; identified
  APIs used before conceptual introduction.
- **Argus** — independent pedagogy QA: challenged Lumen findings; sampled lesson
  text independently; hunted false positives/negatives, hidden prerequisite
  gaps, code-before-concept sequences, shallow definitions.
- **Forge** — learning IA: lesson hierarchy, navigation, discoverability,
  theory placement, density, roadmap visibility, revisit-ability. No site edits.

## Evidence base

- All 48 lesson files + 14 milestone index files read in full
  (`web/src/content/docs/m01` … `m14`).
- Governance docs: TEACHING_STANDARD, LESSON_TEMPLATE, COURSE_ARCHITECTURE,
  MILESTONE_ROADMAP, CURRICULUM_TRACEABILITY, CONTENT_STATUS,
  ANDROID_TO_FLUTTER_MAP, FLUTTER_BEGINNER_GAPS, SENIOR_FIDELITY_REGISTER,
  QUALITY-GATES, agent definitions, course-content/course-qa skills.
- Learner app code (read-only) for first-appearance verification.
- Targeted greps to verify first-appearance and prerequisite claims
  (e.g. `factory`, `async*`, `yield`, `pumpEventQueue`, scaffold retirements).

## Hard constraints honored

- No remediation. No lesson rewrites. No learner-app edits. No web edits.
- No M15 work. Senior source untouched (`main` @ `c8eb860`, clean).
- Previous PASS verdicts treated as fidelity evidence only, never as proof
  of pedagogical depth.
