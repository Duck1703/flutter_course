# M22 — Step-24 Remediation Brief — CONTENT_REVISION aebe84d4e1764f98

## Audit

- 01/02/03/05 (A): exercises exist (paper-trace, hand-compute config,
  RECOGNIZE+MODIFY, write persistence test) — noise only.
- 04 (A→E, P3=2): planted-bug DEBUG exercise strong but NO explicit mental
  model for the save-once invariant → ADD_MENTAL_MODEL section before
  Bước 1: three-state invariant (false → emit carries flag+save begins →
  later attempts see true), why the flag must be set INSIDE the emitted
  state (atomic visibility), the late-flag failure window, senior
  `_withSaveResult` equivalence, forward-ref to M26 reducer *by name only*
  (no DRE teaching), direct pointer to the existing planted-bug exercise.

## Constraints

No `DreResult`/`asyncOp`/post-reduce-snapshot/reducer-op/dispatch taught —
only "kiến trúc reducer của M26" named as a future shape. Verified: real
code `_emitWithSaveResult` sets flag via `next.copyWith` in same emit —
mental model matches implementation.
