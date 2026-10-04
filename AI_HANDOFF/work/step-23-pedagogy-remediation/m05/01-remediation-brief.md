# M05 — STEP-23 REMEDIATION BRIEF (Atlas)

## Step-21 findings

F-H1: 1/3 lessons with `Tự làm`; zero isolated examples. False-analogy
zone flagged high-priority (Future ≠ coroutine, eager-start, single
isolate) — lesson prose already handles it; exercises must *test* it.

## Lessons

| Lesson | Depth | CORE | V2 gaps | Action |
|---|---|---|---|---|
| `m05/01` Future/async/await | CORE_CONCEPT | D-09, D-10 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE (Dart) +TỰ_LÀM (PREDICT ordering) |
| `m05/02` FutureBuilder | CORE_CONCEPT | F-09 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE (Flutter) +TỰ_LÀM (PREDICT future-in-build) |
| `m05/03` async main | NORMAL | — | `Tự làm` exists (await vs .then) | EXISTING_ACTIVITY_RETAINED |

## Constraints

- No Stream/StreamBuilder (M06), no `.then` in new examples (m05/03's
  exercise owns it), no unawaited (M11), no Future.wait (M16+).
- m05/01 exercise must not duplicate m05/03's A/B/C `.then` prediction —
  use eager-start + await-yield instead.
- Files: `web/src/content/docs/m05/{01,02}*.md`.
