## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m03/02 — "setState & rebuild — cơ chế bên trong" (bài thí nghiệm cơ chế — không bắt buộc thay đổi code, nhưng các thí nghiệm chạy TRÊN project nên rủi ro để sót code thử).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Nhiệm vụ chính: xác nhận project vẫn ở trạng thái đúng sau các thí nghiệm "quên setState / debugPrint / setState rỗng" — không có code thí nghiệm sót lại.

EXPECTED STATE SAU BÀI NÀY (trong `lib/screens/menu_screen.dart` — bằng trạng thái cuối bài trước):
- `_MenuScreenState` vẫn có `_soundOn`, `_playTapCount`, `_toggleSound()` và `_onPlayTap()` — CẢ HAI mutation đều nằm TRONG `setState(...)` (STRICT: `_playTapCount++` và `_soundOn = !_soundOn` phải trong closure setState, không được viết trần).
- Không có `setState(...)` nào được gọi trực tiếp bên trong `build()` (STRICT — setState trong build là lỗi crash).
- `debugPrint` ở đầu `_MenuScreenState.build` được CHẤP NHẬN (bài cho phép giữ) — nhưng không được có `debugPrint` trong `build` của widget con khác sót lại từ thí nghiệm di chuyển; và không còn `setState(() {})` rỗng lạc chỗ.
- `_ProfileHeader`/`_PlayButton` vẫn StatelessWidget nhận params như cuối bài trước.
- `flutter analyze` → "No issues found!"; bấm nút/badge vẫn cập nhật UI.

INVARIANTS NỀN:
- Menu stateful hai-class (MenuScreen + _MenuScreenState), khung bọc M02, `MenuTokens`, `main.dart` còn nguyên; chưa có `Navigator`/package mới.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`/`AHEAD_RISKY`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m03/02
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
