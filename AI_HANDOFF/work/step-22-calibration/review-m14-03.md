# PEDAGOGY REVIEW — m14/03 `stream-state-behavior-subject-value-stream`

> Reviewer: Pedagogy Reviewer (`pedagogy-reviewer`) — Step-22 calibration run
> Artifact under review: `web/src/content/docs/m14/03-stream-state-behavior-subject-value-stream.md`
> CONTENT_REVISION: calibration run on shipped content (byte state at review time)
> Companion technical review: **NOT READ** — blind per contract §1
> Step-21 audit labels/scores: **NOT PROVIDED** — this verdict is derived
> from the lesson text and learner-context inputs only
> Verdict: **PEDAGOGY_PASS**

## Intake gate

| Required input | Present? |
|---|---|
| Lesson file (shipped content) | Y |
| Concept registry + prerequisite graph | Y (M13 event-stream, M14/02 contract, M11 ChangeNotifier all prior-taught) |
| Teaching standards | Y |
| Fixed learner profile applied | Y |

## P1–P12 row

| Lesson | CORE concepts | P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m14/03 | `BehaviorSubject`, `ValueStream`, state-vs-event stream | 4 | 4 | 4 | 4 | 3 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | PASS |

## Evidence per instrument

- **P3 mental model — usable.** The event-vs-state table answers
  exists/creates/subscribes/replays/disposes: *"`seed(0)` → giá trị luôn
  sẵn; subscribe trễ: replay ngay"* vs broadcast *"miss"*. The two-stream
  table (`userProfileStream` vs `events`) pre-loads the exact confusion
  point for the milestone. Model carries limits ("`Stream` SDK không có
  `.value`").
- **P5 load — 3.** New mechanisms: `BehaviorSubject.seeded`/`.value`/
  replay, `ValueStream` read-face, `isClosed`/`close()` lifecycle — one
  coherent concept family around a single contrast; no NEW→NEW chain.
- **P7 copy/reason — clean.** No port steps at all; the lesson is pure
  concept + isolated example (`BehaviorSubject<int>` counter, runnable
  standalone). Zero PORT_VOLUME; DERIVATION = the whole lesson.
- **P9 activity — PREDICT.** `Tự làm` asks the learner to predict
  `a`/`b`/`s.value` for a late subscriber and the broadcast
  counterfactual — tests the CORE replay semantics, not recall. Hidden
  answer block present. Within-milestone production exercises live in
  m14/02/05/06 — appropriate allocation for the pure-concept lesson.
- **P10 misconception — explicitly bounded.** `ĐỪNG đánh đồng
  BehaviorSubject = StateFlow`; `.value` absent on SDK `Stream`;
  `close()` leak; broadcast-for-state bug named as the reason
  `MenuLoadState` existed. All four dangerous analogies get limits.
- **P11 noise — clean.** Zero registry/gate tokens observed in the
  lesson body.

## Findings

None above NOTE.

- NOTE — `Tự kiểm tra` answers are given inline (not collapsed); a
  self-test reader may see the answer first. Style-level; does not
  affect the exercised PREDICT exercise.

## Verdict rationale

The lesson's CORE concepts are taught through a usable mental model, an
isolated runnable example, a predict-before-answer exercise that tests
exactly the replay semantics, and explicitly bounded analogies. No port
activity; no missing prerequisites; no noise. `PEDAGOGY_PASS`.

## Checks not performed

Senior-source verification of "senior luôn seed"/"đúng pattern senior"
claims — routed to Argus (out of this review's scope per contract §6).
