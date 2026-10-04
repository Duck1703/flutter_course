# Artifact 11 — Governance Smoke Test (G17–G24 dry run)

Non-production test: two hypothetical future-lesson fragments are
scored against the new beginner gates to prove the gates can actually
FAIL and PASS. Neither fragment is real course content.

## Specimen A — deliberately shallow (expected FAIL)

> **Bài X — sealed class**
> `sealed class` là class giới hạn số subclass. Senior dùng nó cho
> quiz state. Paste đoạn này vào `lib/data/quiz/quiz_state.dart`:
> ```dart
> sealed class QuizState { const QuizState(); }
> final class QuizIdle extends QuizState { const QuizIdle(); }
> final class QuizAnswered extends QuizState { const QuizAnswered(); }
> ```
> Xong. Checkpoint: analyze sạch.

| Gate | Verdict | Why |
|---|---|---|
| G17 CONCEPT_DEPTH | **FAIL** | definition + paste only; no anatomy, no runtime behavior, no when-NOT |
| G18 PREREQUISITE_CLOSURE | pass | `class`/`extends` already taught |
| G19 MENTAL_MODEL | **FAIL** | no model of exhaustiveness/exhaustive `switch` — the whole point |
| G20 INDEPENDENT_TRANSFER | **FAIL** | zero learner production |
| G21 ACTIVE_LEARNING | **FAIL** | no predict/experiment |
| G22 COGNITIVE_LOAD | pass | tiny |
| G23 TEMPLATE_COMPLETENESS | **FAIL** | no mistakes, no what-if, no self-check, no scaffold/fidelity note |
| G24 SEQUENTIAL_EXECUTABILITY | pass | snippet compiles |

**Result: FAIL — gate works** (G17, G19, G20, G21, G23 all fire;
a pre-remediation review would have passed this on "code correct +
senior claim true" alone).

## Specimen B — corrected (expected PASS)

> **Bài X — sealed class: công tắc được trợ giúp bởi compiler**
> - *Bạn sẽ hiểu:* tại sao senior muốn compiler đếm hết nhánh state.
> - *Mental model:* sealed = danh sách con đóng — compiler biết hết
>   con nên `switch` không cần `default`; quên một nhánh = lỗi
>   compile, không phải bug runtime. So với enum: mỗi con mang data
>   riêng.
> - *Anatomy:* `sealed` (không `implements` ngoài file) → mọi con
>   phải ở cùng file; `final class` = leaf không ai kế thừa nữa.
> - *Tiny example:* `AuthState{LoggedOut, LoggedIn(token)}` —
>   `switch` 3 dòng, thiếu nhánh đỏ ngay.
> - *Android bridge:* giống Kotlin `sealed class` + `when` exhaustive.
> - *Senior:* `QuizState` là lý do `game_screen` switch không có
>   `default`.
> - *Khi nào KHÔNG:* state không đóng / chỉ 1 nhánh — dùng class
>   thường.
> - *Predict:* thêm `QuizTimeout` mà không sửa `switch` → chuyện gì
>   xảy ra? (compile lỗi — đây là feature).
> - *Tự làm:* viết `FormState{Empty, Filling(progress), Submitted}`
>   + hàm `describe` switch hết nhánh.
> - *Lỗi hay gặp:* con ở file khác → "subclass must be in same file".
> - *Self-check:* 3 câu. *Chưa dạy:* pattern-matching destructuring
>   (M20+).

| Gate | Verdict | Why |
|---|---|---|
| G17 | PASS | what/why/anatomy/runtime/when-not all present |
| G19 | PASS | closed-set + compiler-exhaustiveness model stated |
| G20 | PASS | `Tự làm` requires producing a new hierarchy |
| G21 | PASS | predict + produce |
| G23 | PASS | all required sections present |

**Result: PASS — gate discriminates correctly.**

Smoke test conclusion: G17–G24 distinguish teaching from keyword
coverage. Gates are live.
