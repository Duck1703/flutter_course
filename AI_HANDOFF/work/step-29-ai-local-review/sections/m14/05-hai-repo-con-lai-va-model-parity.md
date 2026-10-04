## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m14/05 — "Hai repo còn lại + model parity" (UserSettingsData 7 field, UserSettingsRepository + OnboardingRepository cùng pattern, UserProfileData đạt field set senior).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. LƯU Ý: settings/onboarding repo CHƯA CÓ consumer — tồn tại là chủ đích của roadmap (consumer M16/M18), không phải code thừa. `totalEarningsDisplay` getter VẪN CÒN (retire ở bài 7 — xoá sớm = lỗi).

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/settings/user_settings_data.dart` (STRICT path): model 7 field `soundEnabled, musicEnabled, hapticEnabled, notificationEnabled, notificationHour, notificationMinute, languageCode` (STRICT đúng 7); final + copyWith + toMap + fromMap + ==/hashCode giống UserProfileData; parse: `hapticEnabled` vắng/sai kiểu → `true` (STRICT default BẬT, khác các bool khác vắng→false); `notificationHour`/`Minute` kẹp `0–23`/`0–59` qua `_boundedInt`; `languageCode` guard non-empty.
- `lib/repositories/settings/user_settings_repository.dart` (STRICT): `abstract interface class UserSettingsRepository` (stream `ValueStream<UserSettingsData>` + `loadUserSettings` + `saveUserSettings` + `dispose` — 4 member) + `UserSettingsRepositoryImpl` cùng file: key `'user_settings'` (STRICT khác 'user_profile'), ctor `._` + `create()`, `BehaviorSubject.seeded(const UserSettingsData())`, `_emitSettings` hai guard y hệt.
- `lib/repositories/onboarding/onboarding_repository.dart` (STRICT): `abstract interface class OnboardingRepository` (`ValueStream<bool> get onboardingCompletedStream` + `loadOnboardingCompleted` + `setOnboardingCompleted` + `dispose`) + impl: key `'onboarding_completed'`, `BehaviorSubject<bool>.seeded(false)`, `prefs.getBool`/`setBool` — KHÔNG JSON.
- `UserProfileData` có thêm `final String totalEarnings;` + `final int totalQuestionCount;` (STRICT field lưu trữ — `totalEarnings` là chuỗi ĐÃ FORMAT); `applyGameResult` ghi `totalEarnings: formatVnd(...)` và `totalQuestionCount: +result.questionsAnswered`; `toMap` dùng `'avatarUrl': ?avatarUrl` (STRICT null-aware element — key vắng khi null); `fromMap` đủ guard: `_stringValue` chỉ nhận non-empty sau trim, `_intValue` chỉ nhận int ≥ 0, `_nullableStringValue` cho avatarUrl, `_moneyFromDisplay` khôi phục số từ `totalEarnings` (parse totalEarnings TRƯỚC totalMoneyWon), `_isLegacyDemoProfile` trả defaults khi khớp bộ showcase.
- `totalEarningsDisplay` getter VẪN TỒN TẠI (STRICT — UI còn đọc; retire bài 7).
- Ba test mới/cập nhật: `test/user_settings_repository_test.dart`, `test/onboarding_repository_test.dart`, `test/user_profile_data_test.dart` bổ sung ca mới (STRICT 3 file; cùng mẫu setMockInitialValues/create/dispose).
- `flutter test` + `flutter analyze` xanh; app vẫn chạy ProfileStore (chưa nối — đúng).

INVARIANTS NỀN:
- Profile repo contract+impl bài 2/4 nguyên vẹn; event channel + bridge M13; Provider scope M12 (vẫn chỉ ProfileStore); persistence M10.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (repo đã trong MultiProvider/VM đã migrate) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m14/05
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
