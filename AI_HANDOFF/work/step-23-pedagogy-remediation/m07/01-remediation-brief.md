# M07 — STEP-23 REMEDIATION BRIEF (Atlas)

## Step-21 findings

F-H1: 1/3 lessons with `Tự làm`; zero isolated examples. Navigator is a
flagged false-analogy zone (BuildContext ≠ Android Context; imperative
stack ≠ nav-graph strings). Intentional scaffolds: no named routes, no
AppNavigationController (M19), no route args — all must stay deferred.

## Lessons

| Lesson | Depth | CORE | V2 gaps | Action |
|---|---|---|---|---|
| `m07/01` route stack + push | CORE_CONCEPT | D-14, F-12 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE (2-screen app) +TỰ_LÀM (PREDICT stack states) |
| `m07/02` GameScreen layout + pop | NORMAL | — | no `Tự làm` | +TỰ_LÀM (PREDICT ownership placement for M08) |
| `m07/03` senior navigation checkpoint | NORMAL | — | `Tự làm` exists (pop/maybePop/stack) | EXISTING_ACTIVITY_RETAINED |

## Constraints

- No `GlobalKey<NavigatorState>`/AppNavigationController (M19), no
  named routes/go_router, no `pop(result)`, no `showDialog` (M09), no
  `PopScope` (M21), no quiz logic (M08).
- m07/02 exercise must NOT implement selection (that is M08's scope) —
  predict/design only.
- Example may not use Material buttons not yet taught — use
  GestureDetector + Container per course convention.
- Files: `web/src/content/docs/m07/{01,02}*.md`.
