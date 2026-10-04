# Teaching Standard

Canonical contract for every future lesson author. Applies to all
milestones in `MILESTONE_ROADMAP.md`. Violations of this standard are
review-blocking.

> **Step-13 extension.** Structure rules live here; **depth** rules live in
> `BEGINNER_CONTENT_STANDARD.md` (LIGHT/NORMAL/CORE_CONCEPT levels, isolated
> examples, exercises, scaffold marking, cognitive-load and sequential-
> executability rules). Both documents are binding; the stricter applies.
> The per-lesson skeleton is `LESSON_TEMPLATE.md` (V2).

## Audience Contract

Write for a programmer fluent in Kotlin/Android/Compose who has **never
seen Dart or Flutter**. Never say "as you already know" about anything
Flutter/Dart. Android knowledge may be referenced only as a labeled bridge.

## Mandatory Lesson Sections

Every lesson MUST contain these sections in this order:

1. **Goal** — one sentence: what the learner can do after this lesson.
2. **Where we are** — milestone position + what exists in the learner app
   right now.
3. **Why this matters now** — the concrete problem in the learner app that
   this lesson solves (never "because it's a best practice").
4. **What you already know** — bridge recap from previous milestones.
5. **New mental model** — the simplest accurate model for the concept.
   Prefer a picture/analogy plus its limits.
6. **Dart concepts** — only the Dart needed for this lesson's code.
7. **Flutter concepts** — only the Flutter needed for this lesson's code.
8. **Android/Compose bridge** — `SIMILARITY:` / `IMPORTANT DIFFERENCE:` /
   `DO NOT ASSUME:` lines where a bridge exists; omit only if none exists.
9. **Senior source evidence** — exact file paths (and symbols where
   useful) showing where/how the senior app uses this. Read-only citation;
   never present senior code as the thing to paste.
10. **Step-by-step implementation** — numbered, small increments. Each step
    compiles and can be observed.
11. **Code walkthrough** — line-level explanation of every new construct
    the learner just typed.
12. **Run and observe** — what to run, what to look at, what to tap, what
    should change.
13. **Common mistakes** — the 2–4 errors a Flutter beginner most likely
    makes here, each with cause + fix.
14. **Check your understanding** — 2–4 questions or micro-tasks with
    answers verifiable in the running app or code.
15. **What we deliberately have not added yet** — the senior-level
    complexity deferred, and when it returns.
16. **Completion checkpoint** — binary criteria proving the lesson's goal
    (ties into milestone completion criteria).

## Code Presentation Rules

- **Explanation-before-or-with-code.** No code block may introduce
  unexplained syntax. Explanation may precede the block or annotate it
  line-by-line immediately after — but a learner must never meet raw code
  first.
- **First-appearance rule.** The first time a concept, keyword, or
  annotation appears in the course, it gets a full explanation and the
  lesson links to that explanation as canonical. Later lessons may use it
  freely but should name-check the original ("as introduced in M05").
- **Increment size.** Prefer steps of ~10–30 new/changed lines. A step
  larger than ~60 lines must be justified or split.
- **Complete context.** Show the full containing method/class region being
  edited — never bare fragments the learner cannot place. Mark edits as
  "add"/"replace" explicitly.
- **Every snippet compiles.** Code in a step must keep the project
  analyzable; if a temporary state would fail `flutter analyze`, say so
  and resolve within the same step.
- **Senior code citation ≠ assignment.** Quoting senior source is for
  *inspection* ("notice how…"), never "copy this into your app".

## Language & Terminology Rules

- Define each Flutter/Dart term at first use (`BuildContext`,
  `notifyListeners`, `sealed class`, `hot reload`, …). A term used without
  prior definition is a defect.
- Keep Android bridges precise; use the three-line bridge format; ban
  "X is just Y" phrasing.
- Use consistent course terms: learner app, senior app, milestone, lesson.

## Scope & Delay Rules

- A lesson may not require a concept the roadmap has not yet taught. If it
  seems necessary, either the milestone is mis-sequenced or the concept
  needs a micro-introduction inside the lesson (and the roadmap should be
  amended via `DECISIONS.md`).
- Every deferred senior complexity must be named in section 15 so the
  learner knows the gap is intentional.
- No secrets, keys, or real credentials in lesson content; dart-defines and
  placeholder values only.

## Verification Requirements Per Lesson

- `Run and observe` must be reproducible on the learner project at that
  milestone's state.
- `Check your understanding` must be answerable from the lesson + running
  app, not from outside knowledge.
- Where a milestone lists a test target, the lesson shows the test being
  written and run (`flutter test`), with assertion intent explained.

## File & Folder Conventions (learner project)

- Mirror senior organization as the course converges:
  `lib/screens/`, `lib/widgets/`, `lib/view_models/`, `lib/repositories/`,
  `lib/services/`, `lib/data/`, `lib/core/`, `lib/navigation/`.
- Introduce folders when the milestone first needs them, with a one-line
  "why this folder exists" note. No speculative scaffolding.
