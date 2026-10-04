# M10 — STEP-23 REMEDIATION BRIEF (Atlas)

## Step-21 findings

F-H1: 1/4 lessons with `Tự làm`; zero isolated examples. Persistence
is where "senior does X" claims matter most (`'user_profile'` key,
StateError-on-false) — preserved. No Repository/BehaviorSubject
concepts may leak in from M14.

## Lessons

| Lesson | Depth | CORE | V2 gaps | Action |
|---|---|---|---|---|
| `m10/01` SharedPreferences + ProfileStore | NORMAL | — | no `Tự làm` | +TỰ_LÀM (PREDICT persisted-vs-runtime fields) |
| `m10/02` JSON toMap/fromMap + factory | CORE_CONCEPT | D-15, D-16 | no runnable JSON example (factory example exists); no `Tự làm` | +ISOLATED_EXAMPLE (JSON roundtrip DartPad) +TỰ_LÀM (DEBUG corrupt-map + null-field decision) |
| `m10/03` GameResult via pop | NORMAL | — | no `Tự làm` | +TỰ_LÀM (PREDICT route-result on 3 return paths) |
| `m10/04` apply result + reset | NORMAL | — | `Tự làm` exists | EXISTING_ACTIVITY_RETAINED |

## Constraints

- No `UserProfileRepository` interface, `BehaviorSubject`/`ValueStream`
  (M14), no `fromMap` full rewrite.
- Files: `web/src/content/docs/m10/{01,02,03}*.md`.
