## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m07/01 — "Route stack & Navigator.push".

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bài này tạo route thứ hai và nối CTA — GameScreen vẫn là placeholder tối thiểu, layout quiz là bài sau (không chấm thiếu nội dung).

EXPECTED STATE SAU BÀI NÀY:
- `lib/screens/game_screen.dart` tồn tại (STRICT path) với `class GameScreen extends StatelessWidget` + `const GameScreen({super.key})`; `build` trả `Scaffold` có `AppBar(title: 'Phòng chơi'...)` + body placeholder (semantic: chưa cần layout quiz đầy đủ).
- Trong `lib/screens/menu_screen.dart`: `import 'game_screen.dart';` (hoặc package import tương đương) có mặt; `_onPlayTap()` vẫn `setState` cho `_playTapCount++` và `_profile = _profile.gainExp(10)` RỒI mới gọi `Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => const GameScreen()))` (STRICT: push đặt sau setState trong cùng handler; `builder:` nhận closure trả widget, không truyền widget sẵn).
- KHÔNG có `GlobalKey<NavigatorState>`, `navigatorKey`, named routes, `routes:` map hay `go_router` — đều bài sau/không dùng (STRICT absent — thêm là ahead-of-course).
- `MaterialPageRoute<void>` với generic `void` (STRICT — app chưa trả result).
- `flutter analyze` → "No issues found!"; `flutter test` → 15 xanh; bấm CHƠI → GameScreen trượt lên, bấm ← về menu giữ counter/ticker.

INVARIANTS NỀN:
- `main.dart` async + `home: const MenuScreen()` trong `MaterialApp`; toàn bộ tầng async M05–M06 và state M03–M04 nguyên vẹn.

Mục (STRICT) phải đúng; mục khác chấm semantic (text placeholder, style AppBar). Code vượt checkpoint (đã có quiz layout đầy đủ — bài 2 — hoặc navigatorKey) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m07/01
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
