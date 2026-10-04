# 11 — Content Governance Root Cause

Question: how did the Agent Product reach M14 with technically-correct but
pedagogically-uneven content? Verified against the actual gates, not guessed.

## What the current system checks (evidence)

From `QUALITY-GATES.md`, `course-content`/`course-qa` skills, and agent defs:

| Gate checks | Depth it actually verifies |
|-------------|---------------------------|
| Code↔lesson snippet identity | verbatim match — strong |
| Senior fidelity (G16) | architecture/product truth — strong |
| First-appearance gate | concept **named/mentioned**, with "cần dùng" table row |
| Milestone boundary | file-scope correct — strong |
| `flutter analyze`/`test`/site build | green — strong |
| **Concept depth** | **NOT a gate** — presence counts |
| **Lesson-template section completeness** | **NOT a gate** — M14 dropped 3+ named sections, nothing caught it |
| **Exercise/active-learning requirement** | **NOT a gate** — no lesson ever required a production exercise |
| **Learner-independence/transfer** | **NOT a gate** — "can they build it alone" is never measured |
| **Concept registry / prerequisite graph** | **does not exist** — no artifact tracks where each concept is taught |
| **Checkpoint feasibility** | **NOT checked** — M14/01's impossible `analyze`-clean checkpoint passed QA because QA replays the *final* code state, not the learner's sequential path |

## Root causes (process failures, not agent blame)

1. **The quality bar is fidelity-shaped.** Every gate asks "is it correct and
   senior-aligned?" — nothing asks "can a beginner learn from it?". The human's
   finding slipped through a *gap in what's measured*, not through carelessness.
2. **LESSON_TEMPLATE prescribes sections; no gate enforces them.** M14 dropped
   `Mental model mới`, `Lỗi hay gặp`, `Chạy và quan sát` — permitted silently.
3. **First-appearance gate counts mentions, not understanding.** `factory` got
   a point-of-use paragraph → "covered"; `abstract interface class` got 20
   lines → "covered". Depth is invisible to the gate.
4. **No concept-level ownership.** Nobody owns "is `factory` ever taught?"
   Course-wide it fell through milestones because each milestone's scope is
   self-contained.
5. **Sequential-executability isn't tested.** Milestones are implemented as one
   unit then described as 4 lessons; the mid-lesson checkpoints can assert
   states the sequential path never reaches (M14/01).
6. **"Android bridge" sections are disciplined** (SIMILARITY/DIFFERENCE/DO NOT
   ASSUME) — one place the system *does* guard pedagogy — but there's no
   equivalent guard for concept depth or transfer.

## Conclusion

`CURRENT_CONTENT_GOVERNANCE_SUFFICIENT: NO` — not because gates are weak at
what they check, but because **pedagogical depth, exercises, template-section
completeness, concept-registry, and learner-sequencing are simply not gated at
all**. See artifact 13 for proposed gates (not activated here).
