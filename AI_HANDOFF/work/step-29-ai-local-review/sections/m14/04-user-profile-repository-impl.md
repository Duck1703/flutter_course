## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m14/04 — "UserProfileRepositoryImpl" (impl đầu tiên của contract trong cùng file + repo test độc lập; app VẪN chạy ProfileStore — chưa nối dây).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test test/user_profile_repository_test.dart`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Trọng tâm: emit-path đúng thứ tự (ghi disk trước → emit sau), subject seeded, ctor private + create().

EXPECTED STATE SAU BÀI NÀY (trong `lib/repositories/profile/user_profile_repository.dart` — DƯỚI contract, cùng file):
- `class UserProfileRepositoryImpl implements UserProfileRepository` (STRICT implements trong cùng file): `static const _profileKey = 'user_profile';` (STRICT cùng key ProfileStore — khác key = đọc ghi hai ô nhớ khác nhau).
- `final SharedPreferences _preferences;` + `final BehaviorSubject<UserProfileData> _userProfileSubject;` + ctor `UserProfileRepositoryImpl._(this._preferences) : _userProfileSubject = BehaviorSubject<UserProfileData>.seeded(const UserProfileData());` (STRICT private ctor + seeded subject với default profile); `static Future<UserProfileRepositoryImpl> create()`: `await SharedPreferences.getInstance()` → `Impl._(preferences)` (STRICT async factory).
- `import 'package:shared_preferences/shared_preferences.dart';` + `import 'dart:convert';` đã thêm.
- `userProfileStream` getter → `_userProfileSubject.stream` (STRICT expose ValueStream, che subject).
- `UserProfileData _emitUserProfile(UserProfileData userData)`: hai guard `!_userProfileSubject.isClosed` và `_userProfileSubject.value != userData` trước `add`; `return userData` luôn (STRICT hai guard + luôn trả về).
- `loadUserProfile()`: `getString` → null → `_emitUserProfile(const UserProfileData())`; `jsonDecode` → `is Map` → `fromMap(Map<String, Object?>.from(decodedProfile))` → emit; `on FormatException` → emit defaults; cuối → emit defaults (STRICT ba nhánh fallback giống ProfileStore, nhưng kết quả đi QUA emit).
- `saveUserProfile`: `await setString(key, jsonEncode(toMap()))` → `if (!didSave) throw StateError(...)` → `_emitUserProfile(userData)` (STRICT thứ tự: disk trước, emit sau).
- `resetUserProfile()` → `saveUserProfile(const UserProfileData())`; `dispose()` → `_userProfileSubject.close()` (STRICT).
- `test/user_profile_repository_test.dart` tồn tại: `setUp(() => SharedPreferences.setMockInitialValues({}))`; test load-emits-defaults (profile + `.value` đều defaults); test save-persists-emits với late-listener replay (`listen` sau save → `pumpEventQueue()` → `seen.single.username == 'Lan'`); mọi test `await repo.dispose()` cuối ca (STRICT kỹ thuật pumpEventQueue + dispose).
- `flutter test test/user_profile_repository_test.dart` xanh; `flutter analyze` sạch; app `flutter run` hiển thị menu y hệt (repo chưa ai gọi — đúng trình tự).

INVARIANTS NỀN:
- `ProfileStore` vẫn còn + VM vẫn dùng (chưa xoá); contract 5 member bài 2; `UserProfileData` M10 (toMap/fromMap/==); event channel + bridge M13; Provider scope M12; persistence M10.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (đã nối VM/MultiProvider/fake repo) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m14/04
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
