## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m08/02 — "State của quiz & enum trạng thái".

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bài này dựng state + handlers — chúng CHƯA được nối vào UI (bài sau nối; cảnh báo `unused_element` tạm thời là chấp nhận).

EXPECTED STATE SAU BÀI NÀY (trong `lib/screens/game_screen.dart`):
- `class GameScreen extends StatefulWidget` + `class _GameScreenState extends State<GameScreen>` — hai-class của M03 (STRICT).
- `_GameScreenState` giữ 5 field: `int _questionIndex = 0`, `int? _selectedIndex` (nullable — STRICT, "chưa chọn" là null), `bool _submitted = false`, `bool _quizFinished = false`, `int _correctCount = 0` (STRICT tập field — mọi thứ UI cần suy ra từ đây).
- Hai getter suy ra: `QuizQuestion get _question => quizQuestions[_questionIndex]` và `bool get _isLastQuestion` (STRICT cơ chế derived — không lưu trùng); import `quiz_question.dart` + `quiz_questions.dart` có mặt.
- Bốn handler: `_selectAnswer(int)` guard `if (_submitted) return` rồi `setState` gán; `_submitAnswer()` guard `== null || _submitted` rồi `setState` đặt `_submitted = true` + `if (_question.isCorrect(_selectedIndex!)) _correctCount++`; `_nextQuestion()` setState tăng `_questionIndex` + reset `_selectedIndex`/`_submitted` (hoặc `_quizFinished = true` khi câu cuối); `_restart()` reset cả năm (STRICT guard + reset semantics).
- `enum _AnswerVisualState { idle, selected, correct, wrong, dimmed }` top-level private tồn tại (STRICT 5 giá trị); `_optionState(int)` trả đúng logic: chưa chốt → selected/idle; đã chốt → correctIndex→correct, selectedIndex→wrong, else→dimmed (STRICT thứ tự ưu tiên).
- `flutter analyze` → "No issues found!" (hoặc chỉ còn `unused_element` nếu handler chưa nối — chấp nhận); UI vẫn tĩnh là đúng.

INVARIANTS NỀN:
- `quizQuestions` bank + `QuizQuestion.isCorrect` của bài 1; hai route M07; toàn bộ M01–M06 nguyên vẹn; `MenuTokens` chưa cần đổi.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (đã nối handler vào UI — bài 3 — hoặc đã có GamePhase enum) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m08/02
PROJECT_ALIGNMENT: ON_TRACK | NEEDS_FIX | DIVERGED | BLOCKED
COURSE_POSITION: ON_TRACK | BEHIND | AHEAD_COMPATIBLE | AHEAD_RISKY
READY_FOR_NEXT_LESSON: YES | YES_AFTER_FIXES | NO
VERIFICATION_PERFORMED:
WHAT_MATCHES:
GAPS:
AHEAD_OF_COURSE:
DIVERGENCES:
REQUIRED_FIXES_BEFORE_CONTINUING:
EVIDENCE: file/symbol → observation
FILES_MODIFIED_BY_REVIEW: NONE
```
