# Course Architecture

How the learning course is organized to rebuild the senior application
(`flutter-accelerator-ai`, package `ai_millionaire`) from an empty learner
project. This document defines philosophy and policy; milestone specifics
live in `MILESTONE_ROADMAP.md`.

## Course Mission

Take a programmer experienced in Kotlin/Android/Jetpack Compose — but new
to Dart and Flutter — from `flutter create` to a working reconstruction of
the senior "AI Millionaire" quiz app, ending with an explicit
senior-alignment pass. The learner must understand every line they write.

## Target Learner & Starting Assumptions

Assumed already known:

- general programming (types, OOP, collections, control flow);
- Kotlin idioms (classes, lambdas, coroutines, flows conceptually);
- Android platform model (Activity, manifest, permissions);
- Jetpack Compose (declarative UI, recomposition, state hoisting);
- repository pattern and ViewModel/state concepts;
- building software with AI assistance.

Explicitly **not** assumed (each gets a proper introduction):

- Dart syntax and conventions;
- Dart null safety;
- `Future`/`Stream` and Dart's event loop;
- the Flutter widget model and immutability;
- `BuildContext` and the widget tree;
- Flutter widget/state lifecycle;
- layout constraints ("constraints go down, sizes go up");
- `Provider`, `ChangeNotifier`, `AnimatedBuilder`/`ListenableBuilder`;
- Flutter navigation (`Navigator`, routes, `PopScope`);
- `SharedPreferences` and serialization;
- platform plugins and permissions in Flutter;
- `flutter_test` / `WidgetTester`;
- Flutter tooling (`pub`, `flutter analyze`, hot reload, gen-l10n).

## Educational Philosophy

1. **Concept before code.** A learner never pastes what they cannot
   explain. Prefer *understand 10–30 lines → implement → observe → expand*
   over *copy 200 lines → explain afterwards*.
2. **One conceptual jump per milestone.** A milestone introducing several
   brand-new mental models is split (see `MILESTONE_ROADMAP.md`).
3. **Just-in-time concepts.** No topic is taught "because Flutter uses it
   someday"; it is taught when the learner app needs it.
4. **Simplify first, converge later.** Beginner implementations are real
   and runnable, then deliberately refactored toward senior patterns so the
   learner sees *why* the abstraction exists.
5. **The senior app is evidence, not scripture.** Teaching order follows
   learning dependency + feature dependency + cognitive load, not senior
   directory order or commit history.

## The Learn-Then-Build Loop

Every concept milestone follows:

```
NEW CONCEPT
→ why it exists
→ beginner mental model
→ tiny isolated example
→ Android/Compose comparison where useful
→ important difference from Android
→ inspect where the senior project uses it
→ implement smallest useful version in learner app
→ run/observe behavior
→ explain what happened
→ test/check understanding
→ continue
```

## Senior-Reference Usage Policy

- The senior repository is **read-only evidence** and the final alignment
  target. It is never code to copy blindly.
- Every feature lesson cites the senior files it corresponds to
  (e.g. `lib/view_models/game/reducer/game_reducer.dart`).
- When senior and learner implementations differ, the lesson says so and
  says why (see Simplification Policy).
- Learner code should reach *equivalent behavior* before reaching
  *equivalent structure*.

## Simplification Policy (Ladders)

Advanced senior patterns are met at the right level, then revisited:

| Concern | Level 1 (beginner) | Level 2 (structured) | Level 3 (senior-aligned) |
|---------|--------------------|----------------------|--------------------------|
| Local widget state | `setState` in `StatefulWidget` | — | same (senior uses it sparingly) |
| Feature state | `setState` in the screen | `ChangeNotifier` + `ListenableBuilder` + `Provider` | DRE reducer + effects + async ops (game only) |
| Dialogs | `showDialog` | sealed dialog state rendered in a `Stack` | `GameDialogLayer`/`MenuDialogLayer` + `AnimatedSwitcher` + `PopScope` choreography |
| DI | manual constructor wiring | `Provider`/`MultiProvider` scope | `AppDependencyScope` parity |
| Persistence | none → `SharedPreferences` raw | repository contract + `BehaviorSubject` stream | + Supabase sync/merge |
| Leaderboard | static seed list | repository contract + fake | Supabase view read + stale-request guard |
| Auth | none/guest | `AuthRepository` contract + disabled impl | email/Google via Supabase; Apple optional |
| Navigation | `Navigator.push` | controller object + `PopScope` | `AppNavigationController` parity |
| Async correctness | none | guards (`_isDisposed`, request ids) | `flowToken` staleness invalidation |
| Animation | implicit (`AnimatedSwitcher`) | `AnimationController` basics | `CustomPainter`, motion choreography |

Not every feature needs all three levels; ladders exist only where the
senior pattern would overwhelm a beginner. **When each abstraction is
introduced and why** is documented per milestone in
`MILESTONE_ROADMAP.md` and per feature in `CURRICULUM_TRACEABILITY.md`.

## Android Bridge Policy

- Every milestone names its bridges in the form:
  `SIMILARITY:` / `IMPORTANT DIFFERENCE:` / `DO NOT ASSUME:`.
- Analogies accelerate, never replace, the Flutter explanation.
- Known traps (from `ANDROID_TO_FLUTTER_MAP.md`) are taught explicitly:
  no modifier chain; no data classes; manual subscription disposal;
  `BuildContext` ≠ Android `Context`; dialogs are widgets, not routes;
  no `viewModelScope`.

## Dart-in-Context Policy

There is no standalone Dart bootcamp. Dart concepts attach to the first
milestone that needs them (syntax/classes/null safety early; `Future`
before persistence; `Stream` before repository streams; sealed classes
before state-driven dialogs). Each milestone lists `Dart introduced` /
`Dart reused` / `Flutter introduced` / `Flutter reused`.

## Testing Philosophy

- Tests are a teaching tool and a safety net, not homework.
- Progression: pure-Dart `test()` → `testWidgets` (find/tap/pump) →
  fake repositories for VM tests → `pump(duration)` virtual-time tests →
  contract/staleness tests.
- The learner first feels the pain tests prevent, then learns the test.
- Senior parity target: `test/helpers/` hand-written fakes; no mockito.

## Milestone Completion Philosophy

A milestone is complete only when its **completion criteria** are
observably true in the running learner app (not "lesson read"). Criteria
are binary and checkable; see `MILESTONE_ROADMAP.md`.

## Theory vs Implementation Balance

- Every milestone must end with a running app that visibly changed.
- Theory-only stretches are forbidden: explanation is always anchored to
  code being written that milestone.
- Depth standard: this course explains *more* than an equivalent Android
  course would, because the ecosystem is new.

## Advanced-Feature Delay Policy

The following are deliberately placed late or in appendices (senior parity
is still reachable): DRE reducer architecture, `part`/`part of`
organization, in-Stack dialog layers, onboarding gating chain, Supabase
auth (Google/Apple/email), notification permissions + timezone scheduling,
profile sync merge/rollback, stale-async guards (`flowToken`, request ids),
`CustomPainter`, elaborate `AnimationController` choreography, widget
previews, release kit/signing tooling.

## Course Completion Definition

The course is complete when **all** of the following hold:

1. The learner app runs and reproduces the senior app's core user journeys:
   menu hub → 15-question timed quiz with lifelines → results; onboarding;
   settings; leaderboard; optional auth/sync.
2. Each senior feature F1–F15 has a recorded coverage status in
   `CURRICULUM_TRACEABILITY.md` (CORE/ADVANCED/APPENDIX/OPTIONAL_TOOLING).
3. The learner app structure intentionally mirrors senior conventions
   (screens/widgets/view_models/repositories/data separation) via the
   senior-alignment milestones.
4. The learner can explain, unaided, why each senior abstraction exists —
   including what the simplified version could not do.
