## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m14/02 — "Contract trong Dart" (file code đầu tiên của M14: contract repository + thêm rxdart; mọi thứ additive — app chưa ai gọi contract).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. LƯU Ý: bài này ADDITIVE — `ProfileStore` vẫn còn và VM vẫn dùng nó (đúng ý đồ); contract chưa có impl và chưa ai gọi.

EXPECTED STATE SAU BÀI NÀY:
- `pubspec.yaml` có `rxdart: ^0.28.0` trong dependencies (STRICT — dep mới duy nhất của bài; lockfile tương ứng); `flutter analyze` → "No issues found!".
- `lib/repositories/profile/user_profile_repository.dart` tồn tại (STRICT path + tên — y hệt senior): import `package:rxdart/rxdart.dart` + `../../data/profile/user_profile_data.dart`; chứa `abstract interface class UserProfileRepository` (STRICT: abstract interface class — KHÔNG abstract class thường).
- Contract đủ đúng 5 member (STRICT chữ ký): `ValueStream<UserProfileData> get userProfileStream;` + `Future<UserProfileData> loadUserProfile();` + `Future<void> saveUserProfile(UserProfileData userData);` + `Future<void> resetUserProfile();` + `Future<void> dispose();` — contract KHÔNG chứa body/impl (chỉ signature + doc).
- Chưa có `UserProfileRepositoryImpl` trong file (bài 4 — có sẵn cũng OK nếu learner đọc trước, nhưng không bắt buộc); chưa có `Provider<UserProfileRepository>` trong scope (bài 6).
- `lib/data/profile/profile_store.dart` VẪN CÒN và `MenuViewModel` vẫn nhận `ProfileStore` (STRICT — xoá sớm = DIVERGED); `_profile`/`loadState`/`applyGameResult` nguyên vẹn.

INVARIANTS NỀN:
- Event channel M13 (MenuUiEvent + broadcast + requestGame/resetProfile-emit); bridge M13/02; Provider scope M12 (Provider<ProfileStore>.value); persistence M10; game M09.

Mục (STRICT) phải đúng; mục khác chấm semantic (doc comment). Code vượt checkpoint (đã có impl+provider+MultiProvider) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m14/02
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
