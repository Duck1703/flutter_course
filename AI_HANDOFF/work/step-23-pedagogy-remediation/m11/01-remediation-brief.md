# M11 — STEP-23 REMEDIATION BRIEF (Atlas)

## Step-21 findings

F-H1: 1/3 lessons with `Tự làm`; zero isolated examples.
ChangeNotifier/ListenableBuilder is a top-priority false-analogy zone
(ChangeNotifier ≠ StateFlow emission; notifyListeners = signal not
value). Exercises must test exactly those distinctions.

## Lessons

| Lesson | Depth | CORE | V2 gaps | Action |
|---|---|---|---|---|
| `m11/01` why setState doesn't scale | CORE_CONCEPT | A-03 | no `Tự làm` | +TỰ_LÀM (RECOGNIZE ownership classification) |
| `m11/02` notifyListeners + ListenableBuilder | CORE_CONCEPT | F-15, F-16 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE (counter notifier) +TỰ_LÀM (PREDICT signal semantics) |
| `m11/03` VM ownership + test | NORMAL | — | `Tự làm` exists | EXISTING_ACTIVITY_RETAINED |

## Constraints

- No Provider (M12), no `context.watch/read`, no `_events` stream
  (M13), no repository (M14).
- Example notifier must not pretend to be the app VM.
- Files: `web/src/content/docs/m11/{01,02}*.md`.
