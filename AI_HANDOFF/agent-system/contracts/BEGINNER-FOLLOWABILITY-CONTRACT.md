# BEGINNER FOLLOWABILITY CONTRACT — binding for all learner-facing output

The learner: fluent in Android/Kotlin/Jetpack Compose; **beginner in Dart
and Flutter**. This contract makes that concrete. Violations are blocking
findings (gate G6/G7/G8). It tightens `project-context/TEACHING_STANDARD.md`
into reviewable rules — where they disagree in strictness, the stricter wins.

## Rules

1. **WHERE before WHAT.** Every code step states the exact file path to
   edit, and add-vs-replace explicitly, before the code block.
2. **No unexplained syntax.** Any Dart/Flutter construct not yet taught
   gets named + explained at first appearance (see rule 5).
3. **No hidden steps.** Files, edits, commands (`flutter pub add`,
   restarts, hot-reload vs restart), and IDE actions all appear as steps.
   A diff between "all steps executed" and the real learner-app diff must
   show zero unexplained deltas.
4. **Visible/checkable result.** Every lesson ends with something the
   learner can run, tap, or assert — never "trust the code".
5. **First-appearance rule.** First course appearance of a concept:
   name it → explain its role → explain its syntax → say why it appears
   *now* → connect it to the current implementation. Later milestones may
   reference it ("as introduced in M11"), never silently assume it.
6. **Previous knowledge may be referenced only if actually taught** in an
   earlier milestone — check `DEPENDENCY_GRAPH.md` + `CONTENT_STATUS.md`,
   not memory.
7. **Complete context for edits.** Show the full containing method/class
   region, not bare fragments.
8. **Compiles at every step.** Intermediate states must keep
   `flutter analyze` clean, or the step must say why and resolve in-step.
9. **No unexplained setup.** Any command the learner must run is stated
   verbatim with its expected output shape.
10. **Honest intermediate state.** If the lesson's code is a simplification
    of the senior target, it says so and names where the full version
    arrives.

## The senior-inference rule

> **A senior developer being able to infer a missing step does NOT make
> that step acceptable for this course.**

The test is the stated learner profile, not the author's imagination.

## Android bridges are bridges, not substitutes

Bridges accelerate understanding; they never replace Flutter teaching.
Required format where a bridge exists:

```
SIMILARITY:           ⟨what genuinely maps⟩
IMPORTANT DIFFERENCE: ⟨where the analogy breaks⟩
DO NOT ASSUME:        ⟨the trap an Android dev would hit⟩
```

Forbidden false equivalences (each is a blocking finding):

- "Widget is just Composable"
- "`ChangeNotifier` is Android `ViewModel`"
- "`BuildContext` is Android `Context`"
- "`Future` is a coroutine"
- "`Stream` is exactly `Flow`"

Because the learner is Android-experienced, these areas still require full
Flutter treatment: Dart syntax/semantics, Flutter mental models, widget
lifecycle vs composition, `BuildContext` semantics, state ownership
differences, Provider semantics, Dart async vs coroutines. **Knowing the
Android analog never grants permission to skip the Flutter explanation.**

## Exercise policy (Flutter course)

Exercises and checkpoints are part of the course
(`TEACHING_STANDARD.md` §13–14): 2–4 per lesson, verifiable in the running
app or code. This intentionally differs from no-exercise course policies —
do not import such policies from other projects.
