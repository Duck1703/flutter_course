## 🤖 AI Local — Kiểm tra project sau bài này (TỔNG HỢP M17)

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m17/05 — TỔNG HỢP M17 (locale-switch widget test + unit-test whitelist languageCode + tự thêm key l10n; suite 90/90).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test` (kể cả file test riêng), `flutter build web` READ-ONLY (chỉ để verify — không sửa). Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Test switch là bằng chứng feature sống: en default → persist 'vi' → chữ vi hiện KHÔNG restart.

EXPECTED STATE SAU BÀI NÀY:
- `test/localization_switch_test.dart` tồn tại với (STRICT):
  - `group('languageCode whitelist ...')`: unit test `UserSettingsData.fromMap` — 'en'/'vi' giữ nguyên; 'fr'/''/`7`/missing → `isNull` (whitelist `_supportedLanguageCode` bài 3).
  - `testWidgets('app locale follows persisted language settings', ...)`: `FakeUserSettingsRepository` + `addTearDown(repo.dispose)`; `pumpWidget` một host `StreamBuilder<UserSettingsData>(stream: repo.userSettingsStream, initialData: ...value, builder: (context, snapshot) => MaterialApp(locale: SupportedLanguageData.fromCode(snapshot.data?.languageCode) → Locale hoặc null, localizationsDelegates + supportedLocales, home: SettingsDialogScope(settingsRepository: repo, profile: UserProfileData(username:'TestPlayer'))))` (STRICT mirror `main.dart`); sau pumpAndSettle assert `find.text('SETTINGS')` + `'DONE'` (fallback en khi languageCode null); rồi `await repo.saveUserSettings(UserSettingsData(languageCode: 'vi'))` + pumpAndSettle + assert `'CÀI ĐẶT'`, `'XONG'`, `'Âm thanh'` (STRICT 3 assertion vi — live switch).
- `flutter test` → **90/90** (87 + 3 mới) (STRICT); `flutter analyze` sạch; `flutter build web` thành công.
- Tự làm (OPTIONAL — nếu có): key `appTagline` en+vi ARB + getter generated + `Text(l10n.appTagline)` ở cuối settings dialog + assert thêm trong test → chấm là bổ sung đúng, KHÔNG tính thiếu nếu không làm.
- Runtime: settings → English → toàn bộ chrome en; → Tiếng Việt → về vi (kể cả snackbar error qua enum→l10n switch).

INVARIANTS NỀN — toàn pipeline M17 phải còn nguyên:
- `l10n.yaml` + 2 ARB 48 keys + 3 file generated (bài 2); `main.dart` StreamBuilder + `_selectedLocaleFor` + `onGenerateTitle` (bài 3); `_supportedLanguageCode` whitelist trong fromMap (bài 3); `localizedTestApp` + 4 test file dùng nó + `localizedSettingItems` + `_snackBarText(l10n, ...)` + dialog-title/result-text helpers (bài 4); `localizedSettingItems` signature 6 String (bài 4); `'Đã đặt lại hồ sơ.'` literal trong MenuViewModel — scaffold learner; `FakeUserSettingsRepository` emit thật (M14).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (onboarding strings M18, ICU plural, golden l10n) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. M18 sẽ đụng onboarding — chưa chấm.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m17/05
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
