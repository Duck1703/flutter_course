## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m02/02 — "Khung màn hình menu & MenuTokens".

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Project học theo từng bài, đừng chấm theo app hoàn chỉnh — menu hiện chỉ là KHUNG ba vùng placeholder, chưa có nội dung thật, đó là đúng.

EXPECTED STATE SAU BÀI NÀY:
- `lib/core/menu_tokens.dart` tồn tại, chứa `class MenuTokens` với constructor private `MenuTokens._()` và các `static const` (STRICT: tên class `MenuTokens`; gồm ít nhất `designWidth`, các `spacing*`, `radiusCard`, `radiusPill`, nhóm `background*`/`card*`/`text*`/`accent*`/`button*`/`earnings*`/`stat*` — giá trị màu cụ thể semantic).
- `lib/screens/menu_screen.dart` tồn tại, chứa `class MenuScreen extends StatelessWidget` (STRICT — bài sau đổ thịt vào nó) với `build` theo chuỗi bọc: `Scaffold` → `Container(decoration: LinearGradient)` → `SafeArea` → `Center` → `ConstrainedBox(maxWidth: MenuTokens.designWidth)` → `Column` ba vùng [ `_ProfileHeader`, `Expanded(child: _MenuBody)`, `_PlayButton` ].
- Ba class private `_ProfileHeader`/`_MenuBody`/`_PlayButton` tồn tại trong cùng file — hiện chỉ là placeholder có màu (chưa đổ thịt, KHÔNG lỗi).
- `lib/main.dart`: `MaterialApp` có `theme:` `ThemeData` dark/`useMaterial3` (semantic chi tiết), `home: const MenuScreen()` (STRICT), `WelcomeScreen` đã bị XOÁ — không còn tham chiếu nào tới nó.
- `flutter analyze` → "No issues found!"; app chạy hiển thị ba vùng màu.

INVARIANTS NỀN:
- `pubspec.yaml` `name: ai_millionaire_course`, chỉ dependency `flutter`; `test/widget_test.dart` đã xoá; `main()` vẫn đồng bộ đơn giản.

Mục (STRICT) phải đúng tên/đường vì bài 3–4 dựng tiếp trên chúng; mục khác chấm semantic. Code vượt checkpoint (đã tự đổ thịt placeholder) → `AHEAD_COMPATIBLE` nếu không phá khung; `AHEAD_RISKY`/`DIVERGED` nếu thay cấu trúc bọc. Thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m02/02
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
