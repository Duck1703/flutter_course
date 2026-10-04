# Lesson Template — V2

Template for every lesson. See `TEACHING_STANDARD.md` (rules) and
`BEGINNER_CONTENT_STANDARD.md` (depth levels + exercise/scaffold rules).
Placeholders use `⟨angle brackets⟩`. **V2 change (Step-13):** adds isolated
example, experiment, and `Tự làm` sections as required for CORE_CONCEPT
lessons; allows intentional section merges for lighter lessons — merges are
declared, never silent (gate G23).

## Depth levels drive the template

- **CORE_CONCEPT lesson** (teaches a concept the learner must reuse):
  use the full skeleton below — all sections.
- **NORMAL lesson** (applies known concepts, one bounded new thing):
  "Mental model mới", "Ví dụ độc lập", "Thử nghiệm", and "Tự làm" may merge
  or drop — each drop must be declared in `04-content-draft.md` with reason.
- **LIGHT/checkpoint lesson** (wrap-up, comparison, review): may merge most
  sections; must still carry Goal / Where-we-are / Checkpoint.

```markdown
---
title: "Bài ⟨N⟩ · ⟨Lesson title⟩"
description: "⟨one line⟩"
sidebar:
  label: "Bài ⟨N⟩ · ⟨short label⟩"
  order: ⟨N⟩
---

## Mục tiêu
⟨What the learner can DO/EXPLAIN after this lesson — not "learn about".⟩

## Bạn đang ở đâu
- Milestone + position; app state entering the lesson; what changes.

## Vì sao việc này quan trọng ngay bây giờ
⟨The felt problem in the learner app — never "best practice".⟩

## Bạn đã biết gì
⟨Prior concepts; each must resolve to a real earlier lesson
(PREREQUISITE_GRAPH.md). Never cite a "cố ý chưa" item as learned.⟩

## Mental model mới
⟨Simplest accurate model + its limits. Required for CORE_CONCEPT.⟩

## Dart cần dùng / Dart mới
⟨Table: syntax | example | meaning — plus full first-appearance teaching
(name → role → syntax anatomy → why now).⟩

## Flutter cần dùng
⟨Same rule for Flutter APIs.⟩

## Ví dụ độc lập          (CORE_CONCEPT: required)
⟨Tiny runnable example detached from the Millionaire app — the concept
alone. Shown BEFORE its production application.⟩

## Android / Compose bridge
- SIMILARITY / IMPORTANT DIFFERENCE / DO NOT ASSUME
⟨"No useful bridge" only when true.⟩

## Senior project connection
⟨Read-only citations: file + symbol + what it demonstrates. Inspection,
never paste-target.⟩

## Build it step by step
⟨Numbered steps: WHERE (file path), add/replace, ~10–30 lines, each step
compiles or is explicitly labelled non-compiling.⟩

## Hiểu code
⟨Line-level walkthrough of new constructs and non-obvious behavior.⟩

## Chạy và quan sát
⟨Command → action → expected observable result.⟩

## Thử nghiệm             (encouraged all lessons; required CORE_CONCEPT)
⟨"What if X" — a prediction the learner can verify by running.⟩

## Lỗi hay gặp
⟨2–5 mistakes: why they happen + fix.⟩

## Tự làm                 (≥1 per milestone; required in CORE lessons)
⟨Task requiring production — hint via :::note[Gợi ý], solution inside
<details><summary>Đáp án</summary>. Never solution-first.⟩

## Kiểm tra hiểu biết
⟨2–4 Q&A, answers verifiable in app/code.⟩

## Ta cố ý chưa thêm
⟨Deferred complexity + the owning milestone.⟩

## Checkpoint hoàn thành
- [ ] Binary, observable criteria — reachable by a learner who has applied
      only the lessons so far (gate G24).
```

## Authoring checklist (author-facing, delete from lessons)

- [ ] Every `Bạn đã biết gì` claim resolves to a real earlier lesson
      (registry + graph checked, not memory).
- [ ] No unexplained first-appearance syntax anywhere.
- [ ] Every CORE_CONCEPT: mental model + isolated example + senior
      application + mistakes + exercise somewhere in the milestone.
- [ ] ≤3 major new concepts — more requires an Atlas split decision.
- [ ] Each checkpoint reachable at that point in the sequence (G24).
- [ ] Scaffolds carry the `:::caution[TEACHING SCAFFOLD]` marker at
      introduction with convergence milestone.
- [ ] Exercise = production, not trivia; solution hidden behind `<details>`.
- [ ] Deferred complexity named with its owner milestone.
