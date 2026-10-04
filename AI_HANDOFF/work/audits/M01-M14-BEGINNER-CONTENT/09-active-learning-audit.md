# 09 — Active Learning Audit

Question: are learners asked to *think and produce*, or only read→copy→run?

## What exists today

| Mechanism | Presence | Quality |
|-----------|----------|---------|
| Predict/"what happens if" questions | M01, M03, M05–M09, M11–M13 (many lessons) | GOOD — e.g. "bỏ setState thì sao", "remove the `==` guard then trigger dCD" |
| Comprehension self-checks w/ answers | **Every lesson** | GOOD — 3–4 Q&A, answers inline |
| "Chạy và quan sát" experiment steps | M01–M13 lessons | GOOD — deliberate break-it steps (e.g. remove guard → double navigation) |
| Writing tests as activity | M04/04, M08/04, M09/04, M11/03, M13/03 | GOOD |
| **Independent exercises (write code not shown)** | **NONE anywhere** | **ABSENT** |
| Mini-challenges / bug-spot / fill-in-blank / build-unrelated-example | NONE | ABSENT |
| Milestone-end synthesis task | NONE — checkpoints are checklists | ABSENT |

## Per-milestone classification

M01–M13: **SOME** (predict + observe + self-check; no production exercises).
M14: **SOME-WEAK** (self-check only; the "Chạy và quan sát" experiment section
is absent from all four lessons).

## The core finding (systemic)

The course's activity model is **guided-replication + comprehension-check**,
never **independent production**. A learner can finish M14 having never once
written a widget, stream, or repository that the lesson didn't fully spell out.
For the stated goal — "capable of working independently" — this is the audit's
most consequential systemic gap, and it's invisible to code-correctness QA.

Severity: **HIGH** (systemic; cheap to fix per-lesson; not a rework driver).

## Milestone checkpoint quality

Checkpoints are behavioral checklists ("bấm CTA thấy đổi", "giải thích được
X"). Most include ≥1 "giải thích được" item — better than "app works". But
none require producing anything. Index pages list "Tiêu chí hoàn thành" as
artifact checklists; what-the-learner-can-now-explain is implicit.

- GOOD checkpoints: M03 ("giải thích được: setState chỉ báo Flutter rằng State
  cần rebuild"), M13, M14 ("giải thích được vì sao state cần replay").
- WEAK: none purely "app works", but all are verify-only, never produce.
