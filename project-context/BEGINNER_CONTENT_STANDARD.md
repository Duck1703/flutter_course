# Beginner Content Standard

Canonical, binding on Lumen (authoring) and Argus (QA) for all lessons.
Companion to `TEACHING_STANDARD.md` (section structure) — this file defines
**depth**. A lesson may be technically correct and still fail this standard.
Gates G17–G24 in `AI_HANDOFF/agent-system/QUALITY-GATES.md` enforce it.

## Audience (fixed)

Programmer fluent in Kotlin/Android/Compose; beginner in Dart and Flutter.
Generic programming is not retaught; Dart/Flutter-specific semantics always
are. Android is a bridge (SIMILARITY / IMPORTANT DIFFERENCE / DO NOT ASSUME),
never a substitute.

## Content depth levels

Every concept used by course code has an assigned depth level, recorded in
`LEARNER_CONCEPT_REGISTRY.md` and in the milestone brief's LEARNING DESIGN
CHECK.

### LIGHT

For syntax trivia and incidental APIs (e.g. `String.fromCharCode`,
`debugPrint`, a second `Duration` usage). Requirements: named at point of use,
one-line role gloss, in the lesson's Dart/Flutter table.

### NORMAL

For useful but bounded concepts (e.g. `unawaited`, `ensureVisible`,
`pumpEventQueue`). Requirements: name, role, syntax, why-now, plus one
when-NOT-to-use or common-mistake line.

### CORE_CONCEPT

For concepts the learner must be able to *explain and reuse independently* —
widgets/state, async, streams, navigation, DI, repositories, subjects,
testability. A CORE_CONCEPT lesson section must normally address, in order:

1. What is it?
2. Why does it exist? (the felt problem)
3. Mental model (simplest accurate picture + its limits)
4. Syntax anatomy (what each part of the syntax means)
5. Runtime behavior (what actually happens when this executes)
6. Lifecycle / ownership (who creates, owns, updates, disposes)
7. When to use it
8. When NOT to use it
9. Tiny independent example — **not** the production code; something the
   learner could run outside the Millionaire app
10. Senior-project application (how the real code uses it)
11. Common mistakes
12. Experiment / prediction ("what if …")
13. Independent exercise (learner produces something)
14. Recap

Not every CORE_CONCEPT needs all 14 in every lesson it reappears in — but its
**first-teaching** lesson must cover 1–11, and items 12–13 must exist
somewhere in its milestone. A definition + snippet + analogy alone is
**keyword coverage, not teaching** — a FAIL under G17/G19.

## Independent production rule (permanent)

Every **milestone** must contain at least one activity where the learner
produces something not spelled out in the lesson: write a function, complete
an implementation, fix a deliberate bug, predict output, modify behavior,
build a tiny unrelated example, or write a test. Shape:

```markdown
## Tự làm
⟨task⟩ 
:::note[Gợi ý]
⟨hint⟩ — optional, hidden by default is fine
:::
<details><summary><strong>Đáp án</strong></summary>
⟨solution — never shown before the task⟩
</details>
```

Exercise difficulty progresses through the course: RECOGNIZE (early) →
PREDICT → MODIFY → PRODUCE → DEBUG (later milestones). Avoid trivia
("change the text from A to B").

## Synthesis checkpoint (permanent)

Every milestone index ends with **"Tổng kết milestone"** answering:

- What did I learn?
- What can I now explain to someone else?
- What can I write without copying?
- What would happen if X changed? (one concrete "what-if")
- Which concept here will be needed later?

These are learning checks, not gamification.

## Teaching scaffolds (permanent, extends G16)

Any course-only artifact introduced for teaching must be visibly marked at
the **point of introduction** — not only at retirement:

```markdown
:::caution[TEACHING SCAFFOLD]
Tồn tại để dạy ⟨concept⟩. Không tồn tại trong senior app — senior ⟨what
senior does instead⟩. Retire/converge tại ⟨M##⟩ (FR-##).
:::
```

A scaffold without this marker, or presented as senior behavior, is a G16/G17
blocking finding.

## Cognitive load

≤3 major new concepts per lesson. More requires an explicit split decision
recorded in the milestone brief's LEARNING DESIGN CHECK. Lesson length is not
the metric — number of *new simultaneous mental models* is.

## Sequential executability

Lessons are followed in order. A lesson's checkpoint must be reachable by a
learner who has applied exactly the lessons so far. If an intermediate state
cannot compile, the lesson must say so explicitly and never claim
`flutter analyze` clean at that point. Prefer ordering where every page ends
compilable.

## Concept convergence & reinforcement

Concepts should not be taught once and forgotten. The registry records a
reinforcement milestone for every CORE_CONCEPT; a later lesson that deepens
a concept says so ("M06 đã dạy Stream cơ bản; bài này nâng lên state stream").
