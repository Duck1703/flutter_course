# M06 — STEP-23 REMEDIATION BRIEF (Atlas)

## Step-21 findings

F-H1: 1/3 lessons with `Tự làm`; zero structurally-isolated examples.
Stream is a flagged false-analogy zone (Stream ≠ Flow, lazy,
single-subscription vs broadcast). Prose already strong — add runnable
examples + decisions, no rewrites. `menuSessionTicker` is a declared
TEACHING SCAFFOLD (FR-22) — preserve label verbatim.

## Lessons

| Lesson | Depth | CORE | V2 gaps | Action |
|---|---|---|---|---|
| `m06/01` Stream vs Future | CORE_CONCEPT | D-11 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE (Dart, lazy) +TỰ_LÀM (PRODUCE countdown) |
| `m06/02` StreamBuilder | CORE_CONCEPT | F-10 | no isolated example; no `Tự làm` | +ISOLATED_EXAMPLE (Flutter app) +TỰ_LÀM (MODIFY placement/2nd-subscription decision) |
| `m06/03` listen/cancel/StreamController | CORE_CONCEPT | D-12, D-13 | `Tự làm` retained; LEARNING EXAMPLE not runnable | make example runnable (main+print, `Ví dụ độc lập` marker) |

## Constraints

- No ValueStream/BehaviorSubject/rxdart (M14), no `await for`/`async*`,
  no stream transformers (M13+), no Timer.periodic (M09).
- Ticker scaffold label FR-22 must remain untouched.
- Files: `web/src/content/docs/m06/{01,02,03}*.md`.
