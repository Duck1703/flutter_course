## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m09/03 — "showDialog & popUntil" (dialog kết quả là một route trên stack).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Trọng tâm: dialog là ROUTE (`showDialog` push DialogRoute) — đóng=pop, về menu=popUntil; và dialog được gọi từ `_finish` (event), KHÔNG phải trong `build`.

EXPECTED STATE SAU BÀI NÀY (trong `_GameScreenState`):
- `_showResultDialog()`: `showDialog<void>(context: context, barrierDismissible: false, builder: (dialogContext) => AlertDialog(...))` (STRICT: barrierDismissible=false — bắt buộc chọn nút, giữ bất biến finished; `<void>` vì dialog không trả kết quả).
- `AlertDialog` có `title`/`content`/`actions` với 2 `TextButton`: CHƠI LẠI = `Navigator.of(dialogContext).pop();` rồi `_restart();` (STRICT: pop route dialog bằng dialogContext, reset sau); VỀ MENU = `Navigator.of(context).popUntil((route) => route.isFirst)` (STRICT popUntil một lần — KHÔNG hai `pop()` liên tiếp).
- `_dialogTitle()` + `_resultText()`: `switch` trên `_endReason` có `case GameEndReason.victory`, `case GameEndReason.timeout`, `case GameEndReason.wrongAnswer`, **`case null`** (STRICT exhaustiveness trên `GameEndReason?` — thiếu case null analyzer bắt); title ~'CHIẾN THẮNG!'/'HẾT GIỜ!'/'KẾT THÚC', content dùng `'Đúng $_correctCount/${quizQuestions.length} câu'` + `\n` (semantic chuỗi cụ thể).
- `_finish` gọi `_showResultDialog()` — dialog là side-effect một lần trong event handler, KHÔNG nằm trong `build` (STRICT: `showDialog` trong build = push chồng lặp → DIVERGED).
- Panel kết quả inline của M08 (nhánh `_quizFinished`/`_QuizResultPanel` trong build) đã bị GỠ — build giờ chỉ render `_QuizBody`, dialog che trên khi finished (STRICT: cả hai cơ chế kết quả cùng tồn tại = thừa).
- `flutter analyze` → "No issues found!"; chơi thật: sai→KẾT THÚC, hết giờ→HẾT GIỜ!, đúng hết→CHIẾN THẮNG!; CHƠI LẠI reset tại chỗ; VỀ MENU về menu (stack sạch).

INVARIANTS NỀN:
- Phase machine + Timer của bài 1–2 (`_phase`, `_endReason`, `_finish`, `_restart`); `quizQuestions`; route push/pop M07; menu + async nguyên vẹn; chưa có named routes/dialog system.

Mục (STRICT) phải đúng; mục khác chấm semantic (màu, shape, chuỗi). Code vượt checkpoint (dialog-system riêng/named routes) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m09/03
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
