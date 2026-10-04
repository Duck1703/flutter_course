# PEDAGOGY REVIEW — m29/01 `nen-mong-assets-tokens-arb`

> Reviewer: Pedagogy Reviewer (`pedagogy-reviewer`) — Step-22 calibration run
> Artifact under review: `web/src/content/docs/m29/01-nen-mong-assets-tokens-arb.md`
> CONTENT_REVISION: calibration run on shipped content (byte state at review time)
> Companion technical review: **NOT READ** — blind per contract §1
> Step-21 audit labels/scores: **NOT PROVIDED** — this verdict is derived
> from the lesson text and learner-context inputs only
> Verdict: **PEDAGOGY_PASS_WITH_NOTES**

## Intake gate

| Required input | Present? |
|---|---|
| Lesson file (shipped content) | Y |
| Concept registry + prerequisite graph | Y (M17 ARB/`gen-l10n`, M02 `AppTokens`, M14 `assets:` declaration — all prior-taught) |
| Teaching standards | Y |
| Fixed learner profile applied | Y |

## P1–P12 row

| Lesson | CORE concepts | P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m29/01 | sweep discipline (A-40), const-delegate, catalogue-as-contract, ARB parity | 4 | 3 | 3 | 2 | 3 | 4 | 2 | 3 | 4 | 4 | 2 | 3 | PASS_WITH_NOTES |

## Evidence per instrument

- **P3 model — usable but process-shaped (3).** The "Mental model mới"
  is `đọc → diff → port verbatim → verify` + a 3-outcome diff decision
  tree + the byte-parity catalogue sub-model. It does answer
  who-owns-what (senior decides the catalogue; sweep does not "improve"),
  what-changes (verbatim), what-does-NOT-happen (no silent refactors,
  deviations get documented). It is a **procedure** model rather than a
  Flutter-concept model — honestly flagged by the lesson itself
  ("Điểm mới so với mọi milestone trước… bản thiết kế đã có sẵn").
- **P4 clarity — real friction (2).** Systematic nonstandard hyphenation
  in learner prose: `dữ-liệu`, `chỉ-onboarding`, `byte-parity`,
  `gamepad-detail`-style compounds. Vietnamese readers must re-parse
  familiar words; not present in earlier-course lessons.
- **P7 PORT ledger — dominant-activity concern (2).**
  `PORT_VOLUME`: ~50 asset files copied, `app_assets.dart` 45-const
  verbatim, `onboarding_design_tokens.dart` verbatim, +11/−2 ARB keys —
  the lesson's entire production activity. `DERIVATION_BEFORE_ANSWER`:
  NO for the ports (diff commands are shown, then files are ported).
  `LEARNER_PRODUCED_UNAIDED`: the `Tự làm` PRODUCE task — a parity-diff
  script the learner authors. **Mitigating factors:** (a) the ported
  files are const catalogues/tokens — near the contract's
  non-learning-infrastructure exception; (b) the sweep process is the
  stated learning object of the milestone and is honestly taught;
  (c) exercises require reasoning (below). Result: FRICTION, not
  LEARNING_RISK — under this contract's own exception clause.
- **P9 activity — good for the context (4).** PREDICT (unused-const
  removal → later compile-error scenario), DEBUG (missing getter after
  ARB edit → forgot `gen-l10n`), PRODUCE (write the asset-diff script).
  All three test the *discipline* the lesson teaches — not recall.
- **P10 misconception — bounded.** "const không ai dùng = dead code"
  explicitly refused (catalogue-as-contract, DO NOT ASSUME); delegate
  vs literal-copy distinction taught with an isolated runnable example;
  "gần giống là divergence khó-phát-hiện nhất" is a real drift
  misconception caught.
- **P11 noise — real (2).** `(A-40, NORMAL)` inside the mental-model
  heading; `A-38`, `D-04`, `F-42`, `F-25` inside the Dart/Flutter tables
  and callouts — bookkeeping tokens in learner-visible positions.
- **P6 bridge — works.** Isolated delegate-token example →
  `OnboardingTokens` step → parity-check commands that produce
  observable output.

## Findings

- **PED-001 · FRICTION (P7)** — The lesson's production activity is
  entirely porting; no derivation precedes the answers (diff-then-paste).
  Learner risk: the "port verbatim" default, if unexamined, teaches
  copying as a substitute for design judgement. Mitigated by honest
  framing + three reasoning exercises, so FRICTION not LEARNING_RISK.
  Required outcome: before Bước 2–4 reveal the verbatim files, learner
  states what the diff *predicts* (which assets/consts/keys will differ
  and why). Remediation class: ADD_DERIVATION. Owner: Lumen.
- **PED-002 · FRICTION (P4)** — systematic nonstandard hyphenation
  (`dữ-liệu`, `chỉ-onboarding`, `byte-parity`) impedes reading for the
  stated Vietnamese learner. Remediation class: ENRICH (copyedit).
- **PED-003 · FRICTION (P11)** — `A-40`/`A-38`/`D-04`/`F-42`/`F-25`
  tokens inside heading and learner tables. Required outcome: concept
  names in prose; IDs to a trace footnote. Remediation class:
  REMOVE_NOISE.
- **PED-004 · NOTE (P3)** — the heading-level "mental model" is the
  port procedure itself; the byte-parity catalogue sub-model carries
  the actual Flutter-adjacent concept. Acceptable for a convergence
  milestone opener; if this shape recurred in concept milestones it
  would be LEARNING_RISK.

## Verdict rationale

Nothing here is *wrong* or only-copyable: the process model is honest
and bounded, the Flutter-adjacent concepts (delegate const,
catalogue-as-contract, `gen-l10n` discipline, string-path runtime cost)
are genuinely taught, and the exercises demand reasoning about *why*
verbatim is the default. The material issues — port-dominant activity,
orthography, ID noise — are real but friction-level given the
convergence milestone's stated purpose. `PEDAGOGY_PASS_WITH_NOTES`.

## Checks not performed

`app_assets.dart` "45 const" count and the "~10 unreferenced" claim —
senior-source verification routed to Argus. `diff -rq`/`comm` commands
not executed (read-only review).
