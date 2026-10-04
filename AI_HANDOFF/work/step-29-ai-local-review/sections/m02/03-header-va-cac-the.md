## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m02/03 — "Header hồ sơ & các thẻ đầu tiên".

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Chấm hình dáng layout, không chấm đẹp/xấu pixel.

EXPECTED STATE SAU BÀI NÀY (tất cả trong `lib/screens/menu_screen.dart`):
- `_ProfileHeader` là header THẬT: `Padding` bọc `Row` gồm [container avatar tròn có viền + `Icon`, `SizedBox` ngang, `Expanded` chứa `Column` hai `Text` (tên + caption phụ, canh `start`), `_IconBadge` cuối hàng] — `Expanded` là điểm bắt buộc để badge bám phải.
- `class _IconBadge` private tồn tại với `final IconData icon` + `required this.icon` trong constructor (STRICT — đây là pattern widget-nhận-param bài kiểm tra).
- `_MenuBody` là `Padding > Center > Column(mainAxisSize: min, crossAxisAlignment: stretch)` chứa [ `_LevelCard()`, `SizedBox`, `_EarningsCard()` ] — `stretch` để các thẻ giãn hết khung.
- `_LevelCard` hiển thị nhãn cấp + số EXP + thanh tiến trình hai đoạn `Expanded(flex: 3)`/`Expanded(flex: 7)` (STRICT tỉ lệ 3:7 — đó là sản phẩm của bài; label/text cụ thể semantic).
- `_EarningsCard` là `Container` có `gradient:` trong `BoxDecoration` với nhãn + số tiền.
- `_PlayButton` VẪN là placeholder màu ở đáy — chưa đổ thịt là cố ý, không lỗi.
- Nếu learner làm bài Tự làm: một `_StreakCard` có thể nằm thêm trong `children` của `_MenuBody` — có hay không đều chấp nhận; nếu có thì nó là `Container + decoration` cùng pattern và có `SizedBox` phân cách.
- `flutter analyze` → "No issues found!".

INVARIANTS NỀN:
- Khung bọc của `MenuScreen` (gradient → SafeArea → Center → ConstrainedBox 375 → Column ba vùng) còn nguyên; `MenuTokens`/`main.dart` không đổi.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`/`AHEAD_RISKY`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m02/03
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
