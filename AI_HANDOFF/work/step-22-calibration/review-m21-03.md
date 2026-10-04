# PEDAGOGY REVIEW — m21/03 `animated-switcher-va-keyed-transitions`

> Reviewer: Pedagogy Reviewer (`pedagogy-reviewer`) — Step-22 calibration run
> Artifact under review: `web/src/content/docs/m21/03-animated-switcher-va-keyed-transitions.md`
> CONTENT_REVISION: calibration run on shipped content (byte state at review time)
> Companion technical review: **NOT READ** — blind per contract §1
> Step-21 audit labels/scores: **NOT PROVIDED** — this verdict is derived
> from the lesson text and learner-context inputs only
> Verdict: **PEDAGOGY_PASS** (one FRICTION-level note, load)

## Intake gate

| Required input | Present? |
|---|---|
| Lesson file (shipped content) | Y |
| Concept registry + prerequisite graph | Y (M15 sealed `GameDialogState`, M21/02 dialog layer, `ValueKey` flagged first-appearance in-lesson) |
| Teaching standards | Y |
| Fixed learner profile applied | Y |

## P1–P12 row

| Lesson | CORE concepts | P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m21/03 | `AnimatedSwitcher`, `ValueKey(runtimeType)`, keyed transitions | 4 | 4 | 4 | 4 | 3 | 4 | 3 | 4 | 4 | 4 | 4 | 4 | PASS |

## Evidence per instrument

- **P3 mental model — usable and subtle.** *"state variant → transition
  identity"*: variant change → new `ValueKey` → swap animation; payload
  change same-variant → same key → rebuild, no animation. The
  "same-runtimeType AI dialog doesn't re-animate" golden case is exactly
  the non-obvious behavior a learner would otherwise mis-model. The
  actor-role analogy (`tên vai trong kịch`) carries its limits (key is
  identity *within one parent*, not a global id).
- **P5 load — high but organized (3).** New surface: `AnimatedSwitcher`,
  `ValueKey(runtimeType)`, `transitionBuilder` + curves, reduced-motion
  `disableAnimations`, plus 3 transition tests — ~4 mechanisms, each
  attached to one chain (key → identity → transition). No NEW→NEW
  dependency; `SizedBox.expand`-vs-`shrink` justification included.
- **P7 copy/reason — acceptable (3).** Four build steps show focused
  diffs with "khác skeleton ở ba chỗ" rationale each — not whole-file
  pastes. Learner reasons via `Thử nghiệm` predict + the DEBUG exercise
  before tests confirm. PORT_VOLUME modest.
- **P9 activity — DEBUG.** `Tự làm (DEBUG)` = planted keyed-transition
  defect; exercises test at step 4 first. Level is high for the course
  position — the exercise tests the CORE keyed-identity concept, not a
  peripheral.
- **P10 misconception — bounded.** `DO NOT ASSUME: key != data`
  (ValueKey(payload) would animate on every amount change — explicitly
  flagged as diverging from senior semantics); key-scope limit stated;
  reduced-motion accessibility taught as senior behavior.
- **P11 noise — clean.** No registry/gate tokens observed in learner
  prose.

## Findings

- FRICTION (P5) — the lesson ships ~378 lines covering switcher + keys +
  transitions + reduced-motion + 3 tests. Load is organized (single
  key→identity chain) and every piece is exercised, so this is FRICTION
  not LEARNING_RISK; a pause-point or two-column "before/after build()"
  would reduce it further. Remediation class: ENRICH.

## Verdict rationale

Keyed-identity is a genuinely subtle Flutter behavior, and this lesson
teaches it through a correct model, a golden-case contrast, focused diffs
with per-step rationale, a planted-bug DEBUG exercise, and bounded
analogies — the CORE concept is reasoned about, not pasted. Load is the
only material pressure and it stays organized. `PEDAGOGY_PASS`.

## Checks not performed

Senior-source verification of "case-vàng của senior" / reduced-motion
senior claims — routed to Argus. Test assertions not re-run (content
review only).
