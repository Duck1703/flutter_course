## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m01/02 — "main(), runApp() và cây Widget đầu tiên".

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, chạy formatter, `flutter pub get` hoặc thay đổi dependency/lockfile, viết patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi bài học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nếu nhiều project Flutter mà mơ hồ → `BLOCKED_PROJECT_ROOT`, đừng đoán.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; thứ ngoài danh sách KHÔNG tính là thiếu. Project học theo từng bài, đừng chấm theo app hoàn chỉnh — hiện tại app chỉ có một file Dart.

EXPECTED STATE SAU BÀI NÀY:
- `lib/main.dart` chỉ chứa ba phần: `void main()` gọi `runApp(const AIMillionaireApp())`; `class AIMillionaireApp extends StatelessWidget` (STRICT tên class — bài sau dùng lại) có `build` trả về `MaterialApp` với `home: const WelcomeScreen()`; `class WelcomeScreen extends StatelessWidget`.
- `MaterialApp` có `debugShowCheckedModeBanner: false` (semantic — title/tham số khác tự do).
- `WelcomeScreen.build` trả `Scaffold` nền tối + `Center` chứa `Text` hai dòng kiểu "AI MILLIONAIRE" có `TextStyle` (semantic: màu/chuỗi/cỡ chữ chính xác không bắt buộc).
- KHÔNG còn `MyApp`, `MyHomePage`, `_counter`, `setState` của template counter trong `lib/main.dart`.
- Chưa có `StatefulWidget`, chưa có thư mục `screens/`, chưa có package mới — đó là bài sau, không phải thiếu.
- `flutter analyze` → "No issues found!".

INVARIANTS NỀN:
- `pubspec.yaml` vẫn `name: ai_millionaire_course`, chỉ dependency `flutter`; không còn `test/widget_test.dart`.

Mục (STRICT) phải đúng tên vì bài sau dùng lại; mục khác chấm semantic. Code vượt checkpoint (đã tách file, đã thêm widget mới) → `AHEAD_COMPATIBLE` nếu không cản bước sau; `AHEAD_RISKY`/`DIVERGED` nếu phá nền (ví dụ đã cài Provider hay route phức tạp). Thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m01/02
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
