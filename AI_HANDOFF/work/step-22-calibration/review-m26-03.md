# PEDAGOGY REVIEW — m26/03 `game-state-actions-effects`

> Reviewer: Pedagogy Reviewer (`pedagogy-reviewer`) — Step-22 calibration run
> Artifact under review: `web/src/content/docs/m26/03-game-state-actions-effects.md`
> CONTENT_REVISION: calibration run on shipped content (byte state at review time)
> Companion technical review: **NOT READ** — blind per contract §1
> Step-21 audit labels/scores: **NOT PROVIDED** — this verdict is derived
> from the lesson text and learner-context inputs only
> Verdict: **PEDAGOGY_PASS_WITH_NOTES**

## Intake gate

| Required input | Present? |
|---|---|
| Lesson file (shipped content) | Y |
| Concept registry + prerequisite graph | Y (M19/04 `flowToken`, M15 sealed/`switch`, M04 `copyWith`, m26/02 `DreAction` marker — all prior-taught and verified) |
| Teaching standards | Y |
| Fixed learner profile applied | Y |

## P1–P12 row

| Lesson | CORE concepts | P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m26/03 | token-in-state, effect-as-intent, `GameAction`/`GameEffect` contract | 3 | 4 | 4 | 3 | 2 | 4 | 2 | 3 | 4 | 4 | 2 | 3 | PASS_WITH_NOTES |

## Evidence per instrument

- **P3 model — usable.** *"token trong state; effect là ý định"*: the
  model shows the OLD failure concretely (`_onRevealElapsed` checked
  phase but not token → stale could slip) then the DRE shape (action
  carries captured token; reducer compares; stale = no-op data, not
  exception). Effect-as-data is explicitly modeled ("hãy hẹn reveal —
  không Timer bên trong; ai thực hiện? VM bridge Bài 5").
- **P5 load — high (2).** New surface in one lesson: token-in-state,
  effect-as-intent, action-carries-token, sealed family + marker,
  `unmodifiable` defensive views, `clear*` flags, `initial` factory,
  barrel `export`, plus the 13-field `GameState` + 13-variant
  `GameAction` + 7-variant `GameEffect` + async-op catalogue. Mitigation
  present (DartPad isolated example first; "Hiểu code — bốn chi tiết"
  distillation), but the enumeration volume is real.
- **P7 PORT ledger — the material concern (2).**
  `PORT_VOLUME`: five new `game_dre_*.dart` files, all steps labeled
  "file mới — verbatim senior" (state+copyWith, action variants, effect
  variants, async op, barrel — several hundred contract lines).
  `DERIVATION_BEFORE_ANSWER`: **partial** — the DartPad `DownloadState`
  example derives the token-guard *mechanism* before the game files
  appear (good), but the contract *surface* (field list, variant list,
  clear-flags) is pasted, never derived. `LEARNER_PRODUCED_UNAIDED`:
  the `Tự làm` copyWith simulation (predict which fields change).
  The CORE mechanism is reasoned; the contract catalogue is copied.
- **P9 activity — PRODUCE (4).** `Tự làm — PRODUCE`: write the copyWith
  chain for "dismiss dialog while playing" and predict which of
  `flowToken`/`selectedAnswer`/`remainingTime` change — directly tests
  the token-in-state semantics. `Thử nghiệm` adds predict cases.
- **P10 misconception — bounded.** `collectLatest`/job-cancellation
  analogy gets an explicit DIFFERENCE (huỷ-ảo bằng data, không huỷ
  coroutine); `List.unmodifiable ≠ immutable type` as its own DO NOT
  ASSUME; "stale = dữ liệu lệch, không phải exception" is itself the
  misconception guard.
- **P11 noise — real (2).** Registry IDs embedded in learner prose:
  heading carries `(A-32 + F-33, CORE)`; the Dart table cites D-26,
  D-34, D-42, D-46 inline. Learner-facing bookkeeping tokens the reader
  cannot resolve — moderate load.

## Findings

- **PED-001 · FRICTION (P7)** — Steps 1–5 are verbatim senior contract
  ports; the token-guard mechanism is derived in DartPad but the
  contract surface is not. Learner risk: the DRE contract can feel like
  a dictated API rather than a designed one. Required outcome: before
  revealing `game_dre_action.dart`'s 13 variants, learner predicts the
  variant list from the VM's known event sources. Remediation class:
  ADD_DERIVATION. Owner: Lumen.
- **PED-002 · FRICTION (P11)** — `A-32`, `F-33`, `D-26`, `D-34`,
  `D-42`, `D-46` embedded in learner-visible heading + tables. Learner
  risk: unresolved tokens read as unexplained jargon exactly where
  concept load peaks. Required outcome: concept names in prose; IDs
  confined to a trace footnote. Remediation class: REMOVE_NOISE.
- **PED-003 · FRICTION (P5)** — ~10 new mechanisms in one page with
  the contract catalogue counted separately (per contract P5). Load is
  organized (DartPad first) but a split boundary (state model /
  contract files) would help. Remediation class: SPLIT or pause-point.

## Verdict rationale

The CORE concept (token-in-state + effect-as-intent) is genuinely taught
— usable model, honest old-bug motivation, runnable isolated example,
PRODUCE exercise, bounded analogies. The findings are FRICTION-level
(port-surface-not-derived, ID noise, load) — none make the CORE learning
dependent on copying. `PEDAGOGY_PASS_WITH_NOTES`.

## Checks not performed

Senior-file verification of every `verbatim` label (13 vs 14 variants,
4-line barrel) — routed to Argus. `part`/`part of` mechanics are m26/04's
scope — not assumed here, correctly.
