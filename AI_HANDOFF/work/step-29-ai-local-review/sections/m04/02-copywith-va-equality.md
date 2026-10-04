## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m04/02 — "Immutability: copyWith, ==, hashCode".

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Toàn bộ bài là pure Dart trong file model — kiểm tra hành vi method, không chỉ sự tồn tại của chúng.

EXPECTED STATE SAU BÀI NÀY (trong `lib/data/profile/user_profile_data.dart`):
- `copyWith({...})` nhận toàn param nullable và trả `UserProfileData` MỚI với `param ?? this.field` cho đủ 8 field (STRICT cơ chế — param null = giữ nguyên).
- `gainExp(int amount)` trả object mới: cộng `currentExp`, `while` vượt `expForNextLevel` thì trừ cap, `level++`, cap mới `×1.5 round()` (STRICT hành vi; sử dụng `copyWith` bên trong là được).
- Ba getter: `expPercent` kẹp 1–99 (STRICT — `Expanded` cần flex>0, bài sau dùng làm flex), `winRateDisplay` trả `'—'` khi `gamesJoined == 0` (không chia-0), `totalEarningsDisplay` ghép format + `' VNĐ'`.
- `static String formatThousands(int)` nhóm chữ số theo 3 bằng dấu chấm (150000 → '150.000').
- `operator ==` mở đầu bằng `identical(this, other)`, kiểm `other is UserProfileData`, so đủ 8 field; `hashCode` = `Object.hash(...)` đủ 8 field (STRICT cả đôi — thiếu một nửa phá Set/Map/test).
- Chưa có `toMap`/`fromMap`/test file — bài sau, không thiếu.
- `flutter analyze` → "No issues found!".

INVARIANTS NỀN:
- 8 field `final` + `const` ctor + defaults (`'0XFF'`, `35000`) của bài 1 còn nguyên; file vẫn không import Flutter; menu UI chưa dùng model.

Mục (STRICT) phải đúng; mục khác chấm semantic (thứ tự method, tên biến local). Code vượt checkpoint (đã viết `toMap`, đã thêm test) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m04/02
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
