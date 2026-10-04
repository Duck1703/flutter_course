## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m09/01 — "GamePhase & Timer đếm ngược".

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bài này thay bool M08 bằng enum phase + thêm Timer — `_finish`/dialog chưa nối (bài sau; `unused_element` tạm thời chấp nhận).

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/game/game_session_state.dart` tồn tại (STRICT path): `enum GamePhase { answering, revealing, finished }` + `enum GameEndReason { wrongAnswer, timeout, victory }` — 2 enum, đúng số giá trị (STRICT).
- Trong `_GameScreenState`: `static const int secondsPerQuestion = 15` (STRICT 15s — bài chọn 15 thay 30); field mới `GamePhase _phase = GamePhase.answering`, `GameEndReason? _endReason`, `int _secondsLeft = secondsPerQuestion`, `Timer? _timer` (STRICT); **không còn `_submitted`/`_quizFinished`** — chúng bị `_phase` thay thế hoàn toàn; `import 'dart:async'` + import enum file có mặt.
- `initState` gọi `_startTimer()`; `dispose` gọi `_timer?.cancel()` trước `super.dispose()` (STRICT — ba quy tắc sống còn của Timer).
- `_startTimer()`: `_timer?.cancel()` đầu tiên → `_secondsLeft = secondsPerQuestion` → `_timer = Timer.periodic(const Duration(seconds: 1), _onTick)` (STRICT luôn hủy cũ trước tạo mới).
- `_onTick(Timer)`: guard `if (_phase != GamePhase.answering) return;` → `setState(() => _secondsLeft--)` → `if (_secondsLeft <= 0) _finish(GameEndReason.timeout)` (STRICT thứ tự: guard → trừ trong setState → check ≤0 sau; `_finish` có thể là stub bài này).
- `_QuizBody` nhận thêm `secondsLeft`; header Row có `Icons.timer_outlined` + `'${secondsLeft}s'` đổi `accentRed` khi ≤5 (semantic: có đồng hồ UI đổi màu).
- `flutter analyze` → "No issues found!" (trừ `unused_element` tạm); chạy: đồng hồ đếm 15→0 (chưa có dialog — đúng).

INVARIANTS NỀN:
- Quiz chơi được M08: `quizQuestions`, `_questionIndex/_selectedIndex/_correctCount`, `_QuizBody`/options/enum `_AnswerVisualState`; route M07; menu + async M05–M06 nguyên vẹn.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (đã có dialog kết quả/reducer/VM) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m09/01
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
