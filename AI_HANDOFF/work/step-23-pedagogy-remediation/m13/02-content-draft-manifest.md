# M13 — CONTENT DRAFT MANIFEST

CONTENT_REVISION: `a6c571ad|8a017393|0d427cbe`

| Lesson | Change type | CORE | Exercise level | Decision required | Verification |
|---|---|---|---|---|---|
| m13/01 | ISOLATED_EXAMPLE (pure-Dart broadcast no-replay, `dart:async` only) + TỰ_LÀM | D-19/A-04 | RECOGNIZE | classify 6 items state-vs-event + late-listener question | DartPad output / boundary rule |
| m13/02 | TỰ_LÀM | F-20 | PREDICT | predict initState-subscribe, unguarded re-attach, missing cancel | framework semantics |
| m13/03 | NONE (existing exercise) | — | — | — | retained |

The isolated example is intentionally Flutter-free: broadcast no-replay
semantics are pure Dart and run verbatim in DartPad.
