# 14 — Independent Argus Pedagogy Review

Role: independently challenge Lumen/Flux findings. Re-read lesson text (not
summaries), hunt false positives AND false negatives.

## Challenges to findings — resolved

### Challenge 1: "Is the M14 regression overstated?"

Re-read all four M14 lessons in full.

- **Confirmed true:** `Mental model mới`, `Lỗi hay gặp`, `Chạy và quan sát`,
  `Flutter cần dùng`, named `Build it step by step` — present in ~every
  M01–M13 lesson, absent from all four M14 lessons. Verified by reading, not
  pattern-matching.
- **Confirmed true:** no isolated non-project example for interface/implements,
  BehaviorSubject, or MultiProvider anywhere in M14.
- **But also true (fairness):** M14/01's storage-vs-repository framing is
  genuinely good; M14/04's state-stream-vs-event-stream table is the best
  single artifact in the milestone; content is *compressed*, not wrong.
- **Verdict on challenge:** finding stands. HIGH is correct because the
  dropped sections coincide with the highest concept density in the course —
  the exact inverse of good pedagogy.

### Challenge 2: "Is 'no exercises' a false positive — maybe predict-Q&A suffices?"

Predict questions and break-it-observe steps are real active learning and
Lumen credited them (SOME, not NONE). But every predict question is answered
in-line immediately, and no lesson ever asks the learner to *produce* code.
For the course's stated goal — "capable of working independently" — the gap is
material and systemic. **HIGH stands**, but reworded: not "missing" so much as
"one activity mode missing from an otherwise active course".

### Challenge 3: "Is M14/01's checkpoint really impossible?"

Re-checked: bài 1 instructs deleting `profile_store.dart` and asserts
"`flutter analyze` sạch sau khi xoá", claiming "mọi call site đã chuyển sang
repo" — but the `MenuViewModel` rewiring that removes the last `ProfileStore`
dependency is the subject of **bài 4**. A learner following bài 1 alone hits a
compile wall the checkpoint says shouldn't exist. **Finding stands, MEDIUM** —
severity capped because a learner may reasonably treat the milestone as atomic.

### Challenge 4 — hunting false negatives (things Lumen might have missed)

- Re-sampled M05/02, M11/01, M07/01, M03/01 — the "excellent" ratings hold;
  these lessons genuinely lead with mental models (suspend-continuation, 3
  trees, ownership tables) before any project code.
- Checked for hidden code-first pages: none found in M01–M13 — every lesson
  introduces concept before its implementation steps.
- Checked `switch`/`cascade`/`tear-off` introductions: thin but present at
  point of use; correctly rated LOW/ADEQUATE, not findings.
- Checked `Theme`/tokens, `Text`/`Icon`/`Color`, `addTearDown`: all introduced
  adequately at point of use.
- **New micro-finding surfaced:** M14/02 uses `pumpEventQueue()` in a snippet
  before M14/04 explains it — captured as F-09.

### Challenge 5: "Could the verdict be STRONG?"

No — F-06/07/08 (M14 depth collapse + missing isolated examples + overload)
and F-11 (no production exercises anywhere) are real, evidence-backed, and
material to the learner profile. STRONG requires all of: mental models
sufficient, prerequisite graph closed, transfer possible, active learning —
three of these fail.

### Challenge 6: "Could it be MAJOR_CURRICULUM_REWORK?"

No — and this is the important contrary finding for the human review: **44 of
48 lessons are STRONG**, the prerequisite graph is closed except for one
false claim and one thin `factory` introduction, and the strongest pedagogy
(M05/M06/M11–M13) sits on the hardest foundations. The failure mode is
*localized depth-collapse + a missing activity type* — that is enrichment
scope, not rework scope.

## Argus disposition

- Lumen findings: **confirmed**, with F-05 softened (excellent retirement doc
  exists at M13/03; the gap is at *introduction*).
- No major findings overturned; no major missed findings surfaced beyond F-09
  (already registered).
- **Independent verdict agreement: NEEDS_SYSTEMATIC_ENRICHMENT.**
