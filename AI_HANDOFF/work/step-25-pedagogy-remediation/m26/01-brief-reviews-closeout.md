# M26 — Step-25 Brief + Dual Review + Atlas + Closeout

CONTENT_REVISION: `4ebe64fd9ef79a77` (sha256 of m26/*.md, frozen post-edit)

## Audit (all 6 lessons)

- 01 vi-sao-mutation-tay-dat-gioi-han (S): motivation lesson — protected. Noise.
- 02 core-dre-primitives (S): state/action/effect/op distinctions + generic
  boundaries + dispatch model — protected. Noise.
- 03 game-state-actions-effects (S, F-H3 target): full contract family ported
  verbatim before semantics land. Intervention: DERIVE contract-inventory
  admonition before `## Build it step by step` — learner inventories
  STATE/ACTION/EFFECT/OP buckets from the intermediate VM they already
  dissected, predicts variant types/roles, derives dependency direction;
  hidden answer maps to the real 13-field state / 13 actions / 7 effects /
  1 op.
- 04 game-reducer (S, F-M2 target): heaviest port (4 part files + 10 tests).
  Intervention: five-phase load map before `## Build it step by step`
  (transition thuần → skeleton → session+op → feature flow → regression),
  PHA markers at step boundaries, plus pattern-scope callout — DRE is this
  project's architecture choice, not a universal Flutter rule (when it helps
  vs when it's overkill).
- 05 vm-migration-va-bridges (A): noise only.
- 06 regression-va-tong-ket (A): noise only.

## Interventions

- ADD_DERIVE_FIRST: m26/03 (contract inventory — the milestone's main
  answer-first defect).
- ADD_PHASE_STRUCTURE + PATTERN_SCOPE: m26/04 (P5 load + universalization
  risk).
- REMOVE_NOISE: ~170 prose ID tokens.
- ORTHOGRAPHY: plain-VN compounds normalized.

## Argus Technical QA — PASS

- Answer key verified vs real contract files: `GameAction` variants
  (`GameStarted`, `GameAnswerSubmitted`, `GameAnswerRevealElapsed{flowToken}`,
  `GameTimerTicked`, `GameFeatureSelected{type}`, `GameWalkAwayConfirmed`,
  `GameBackToMenuRequested`…), `GameEffect` 7 (`GameStartTimer`,
  `GamePauseTimer`, `GameStopTimer`, `GameScheduleAnswerReveal{token}`,
  `GameScheduleExplanation`, `GameScheduleAIAssistant`,
  `GameNavigateToMenu`), `GameAsyncOp` = `GameSaveResult{earnedAmount,
  isWin, questionCount}` — all match shipped learner code verbatim.
- Phase map matches actual step structure; pattern-scope statement is
  accurate (DRE is project choice; ChangeNotifier suffices for small state).

## Pedagogy Reviewer — PEDAGOGY_PASS

- F-H3 at M26: learner produces the contract skeleton (buckets + roles +
  direction) unaided before the verbatim reveal.
- F-M2 at m26/04: explicit phases + verify checkpoints reduce working-
  memory pressure; no route split needed.
- P7/P9 raised; protected m26/01–02 untouched pedagogically.

## Atlas — APPROVED

Dual review on `4ebe64fd9ef79a77`; scope = m26/** + index only.

## Closeout

- Highest exercise level: BEFORE PRODUCE → AFTER DERIVE+PRODUCE+DEBUG.
- m26/04 load: REMEDIATED (phase map + scope callout).
- Verdict: **COMPLETE**.
