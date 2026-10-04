---
title: "Bài 5 · Tổng hợp M17 — locale-switch test + tự thêm key mới"
description: "Viết widget test đúng shape senior: en default → persist 'vi' → chữ Việt hiện không restart; unit test whitelist `languageCode`; 90/90 + build web; Tự làm thêm ARB key end-to-end."
sidebar:
  label: "Bài 5 · Tổng hợp + Tự làm"
  order: 5
---

## Mục tiêu

Sau bài này bạn **làm được**:

- Viết widget test chứng minh "locale follows persisted settings" —
  đúng test senior có trong `widget_test.dart`.
- Unit-test whitelist `languageCode`: mã hợp lệ giữ nguyên, mã lạ → `null`.
- Tự thêm một key l10n mới đầu-cuối: ARB en+vi → `gen-l10n` →
  consume trong widget → test.

## Bạn đang ở đâu

- M17 bài 5/5 — tổng hợp. Toàn bộ pipeline đã xong: ARB (bài 2) →
  wiring (bài 3) → migration (bài 4). Bài này đóng gói bằng test
  chứng minh tính năng sống + bài tập tự thêm key.

## Vì sao việc này quan trọng ngay bây giờ

"Đổi ngôn ngữ không restart" là *promise* của milestone — promise
cần test. Senior có sẵn test đó trong `widget_test.dart`; tái dựng
nó là bằng chứng learner đạt parity hành vi, không chỉ "hình như
chạy được". Unit test whitelist khoá cửa sau cho dữ kiện bẩn từ disk.

## Bạn đã biết gì

- `testWidgets` + `pumpAndSettle` (M13+).
- `FakeUserSettingsRepository` (test/helpers, M14) — stream giả,
  `saveUserSettings` emit thật.
- `localizedTestApp` + `Locale('vi')` pin (bài 4).
- `StreamBuilder`/`initialData`/`.value` (bài 3).
- `SettingsDialogScope` cần `settingsRepository` + `profile` (M16).

## Dart cần dùng

| Cú pháp | Ví dụ | Ý nghĩa |
|---|---|---|
| `group(name, () { … })` | `group('languageCode whitelist', …)` | gom test liên quan, tên group xuất hiện trong output |
| `addTearDown(fn)` | `addTearDown(repo.dispose)` | dọn fake sau mỗi test — stream không rò |
| `const {'k': v}` map literal | `fromMap(const {'languageCode': 'fr'})` | test `fromMap` phòng thủ bằng map giả |

## Flutter cần dùng

- `testWidgets`/`pump`/`pumpAndSettle`/`find.text` — đã quen từ M13+;
  bài này ghép chúng thành test "end-to-end nhỏ" ở tầng widget: repo
  fake → stream → `MaterialApp.locale` → chữ hiển thị.
- `addTearDown` ở `flutter_test` — dọn `FakeUserSettingsRepository`.

## Android / Compose bridge

- Espresso `withLocale`/`runWithLocale` instrumentation test ↔
  widget test ghim `MaterialApp(locale:)` — Flutter test không cần
  device/system-locale: `locale` là prop, đổi trực tiếp trong test.
- **Khác biệt quan trọng:** test "đổi ngôn ngữ giữa chừng" ở Android
  gần như phải recreate Activity; ở đây chỉ là stream emit +
  `pumpAndSettle` — nên test live-switch viết được trong ~30 dòng.
- ĐỪNG cho rằng unit test JVM của Android tương đương hoàn toàn:
  `testWidgets` chạy trong fake-async env của Flutter — stream phát
  đồng bộ nhưng rebuild phải `pump*`.

## Senior project connection

Senior `test/widget_test.dart` có test *"app locale follows
persisted language settings"*: pump host `StreamBuilder`→`MaterialApp`
(y hệt `main.dart`), assert en mặc định, ghi `languageCode: 'vi'`
qua repo, pump, assert chữ Việt xuất hiện — không restart.
Learner tái dựng 1:1 bên dưới.

## Build it step by step

### Bước 1 — `test/localization_switch_test.dart`

```dart
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/data/settings/supported_language_data.dart';
import 'package:ai_millionaire_course/data/settings/user_settings_data.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:ai_millionaire_course/widgets/menu/settings/settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_user_settings_repository.dart';

/// M17 — locale follows persisted settings: whitelist unit tests
/// + widget test đúng shape senior `widget_test.dart`
/// ("app locale follows persisted language settings").
void main() {
  group('languageCode whitelist (senior _supportedLanguageCode)', () {
    test('mã hỗ trợ giữ nguyên: en / vi', () {
      expect(
        UserSettingsData.fromMap(const {'languageCode': 'en'}).languageCode,
        'en',
      );
      expect(
        UserSettingsData.fromMap(const {'languageCode': 'vi'}).languageCode,
        'vi',
      );
    });

    test('mã không hỗ trợ / sai kiểu / rỗng → null', () {
      expect(
        UserSettingsData.fromMap(const {'languageCode': 'fr'}).languageCode,
        isNull,
      );
      expect(
        UserSettingsData.fromMap(const {'languageCode': ''}).languageCode,
        isNull,
      );
      expect(
        UserSettingsData.fromMap(const {'languageCode': 7}).languageCode,
        isNull,
      );
      expect(
        UserSettingsData.fromMap(const {}).languageCode,
        isNull,
      );
    });
  });

  testWidgets('app locale follows persisted language settings', (
    tester,
  ) async {
    final repo = FakeUserSettingsRepository();
    addTearDown(repo.dispose);

    // Mirror `main.dart`: StreamBuilder bọc MaterialApp, locale ←
    // SupportedLanguageData.fromCode(languageCode) (null → fallback en).
    await tester.pumpWidget(
      StreamBuilder<UserSettingsData>(
        stream: repo.userSettingsStream,
        initialData: repo.userSettingsStream.value,
        builder: (context, snapshot) {
          final language = SupportedLanguageData.fromCode(
            snapshot.data?.languageCode,
          );
          return MaterialApp(
            locale: language == null ? null : Locale(language.code),
            localizationsDelegates:
                AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsDialogScope(
              settingsRepository: repo,
              profile: const UserProfileData(username: 'TestPlayer'),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // languageCode null → fallback template en.
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('DONE'), findsOneWidget);

    // Ghi 'vi' qua repo → stream emit → MaterialApp.locale đổi →
    // chữ Việt hiện KHÔNG cần restart (senior test y hệt).
    await repo.saveUserSettings(
        const UserSettingsData(languageCode: 'vi'));
    await tester.pumpAndSettle();

    expect(find.text('CÀI ĐẶT'), findsOneWidget);
    expect(find.text('XONG'), findsOneWidget);
    expect(find.text('Âm thanh'), findsOneWidget);
  });
}
```

### Bước 2 — chạy

```bash
flutter test test/localization_switch_test.dart   # 3/3
flutter test                                    # 90/90 (87 + 3)
flutter analyze                                 # sạch
flutter build web                               # √
```

## Hiểu code — vì sao test này chứng minh được feature

- Host `StreamBuilder`→`MaterialApp` **sao chép đúng `main.dart`**:
  test không pump app thật, nó tái dựng đúng hình thùng root — bằng
  chứng hợp lệ cho "wiring ở root đúng".
- `languageCode == null` → `locale: null` → hệ thống/test env mặc
  định en → assert `'SETTINGS'`/`'DONE'` — kiểm chứng **fallback**.
- `saveUserSettings(languageCode: 'vi')` đi qua repo thật (fake
  cùng contract) → stream emit → StreamBuilder rebuild → assert chữ
  vi — kiểm chứng **live switch**, y hệt senior.
- Group whitelist khoá cửa sau: `fr`/`''`/`7`/missing đều → `null`.

## Chạy và quan sát

- `flutter test` → **90/90**.
- `flutter run`: settings → English → toàn app en; Tiếng Việt → về
  vi. Snackbar lỗi (nếu ép fail repo) cũng đổi ngôn ngữ theo — nhờ
  enum→l10n switch.
- `flutter build web` → √.

## Thử nghiệm

- Sửa test assert `'CÀI ĐẶT'` ngay sau pump đầu (khi locale null) →
  fail: giá trị hiện là 'SETTINGS' — xác nhận fallback chạy đúng.
- Ghi `languageCode: 'fr'` → UI vẫn en (whitelist rớt về null) —
  hành vi **mong muốn**, không phải bug.

## Lỗi hay gặp

- Quên `addTearDown(repo.dispose)` → stream fake rò giữa các test.
- Assert vi khi `languageCode` chưa lưu → fail; fallback là en.
- Quên `pumpAndSettle` sau `saveUserSettings` → stream emit chưa
  rebuild kịp → assert ảo.

## Tự làm — thêm key l10n mới đầu-cuối (PRODUCE)

**Đề bài.** Thêm một dòng chân trang cho **settings dialog**: sau
hàng tài khoản (cuối `Column` trong `SingleChildScrollView`), một
`Text` nhỏ hiển thị `appTagline`.

Yêu cầu:

1. Thêm `"appTagline": "Beat the quiz, reach the top"` vào
   `app_en.arb` và `"appTagline": "Vượt quiz, lên đỉnh bảng"` vào
   `app_vi.arb`.
2. `flutter gen-l10n` → kiểm getter `appTagline` xuất hiện trong
   `app_localizations*.dart`.
3. Render trong `settings_dialog.dart` bằng `l10n.appTagline`.
4. Mở rộng `localization_switch_test`: sau khi persist `'vi'`,
   assert thêm `find.text('Vượt quiz, lên đỉnh bảng')` — **được**
   vì test pump `SettingsDialogScope` chứa đúng dialog đó.

<details><summary>Gợi ý</summary>

- Key mới chỉ cần value thường (không placeholder) → chỉ cần dòng
  `"key": "value"` ở cả hai ARB, không cần block `@key`.
- Trong `build` của `_SettingsDialog` đã có `final l10n` — chỉ cần
  thêm `Text(l10n.appTagline)` + `SizedBox` vào cuối `Column`.
- Lý do chọn dialog chứ không menu: test switch đã pump
  `SettingsDialogScope` — assert nằm trong cây đó mới có nghĩa.

</details>

<details><summary>Đáp án tham khảo</summary>

```jsonc
// app_en.arb — thêm cuối file (trước `}`), nhớ dấu phẩy sau key trước đó
  "appTagline": "Beat the quiz, reach the top"
```

```jsonc
// app_vi.arb
  "appTagline": "Vượt quiz, lên đỉnh bảng"
```

```dart
// settings_dialog.dart — cuối Column trong SingleChildScrollView,
// sau _SettingsAccountRow
_SettingsAccountRow(profile: profile),
const SizedBox(height: MenuTokens.spacingSm),
Text(
  l10n.appTagline,
  textAlign: TextAlign.center,
  style: TextStyle(color: MenuTokens.textSecondary, fontSize: 12),
),
```

```dart
// localization_switch_test.dart — thêm sau assert 'Âm thanh'
expect(find.text('Vượt quiz, lên đỉnh bảng'), findsOneWidget);
```

`flutter gen-l10n && flutter test` → vẫn xanh khi widget hiển thị đúng.

</details>

## Kiểm tra hiểu biết

1. Vì sao test dựng lại `StreamBuilder`→`MaterialApp` thay vì pump
   `AIMillionaireApp`? (gợi: repo fake, cô lập)
2. `languageCode='fr'` → UI hiển thị ngôn ngữ nào, đi qua mấy tầng
   fallback?
3. Một literal sót lại trong `lib/` sẽ "lộ" thế nào khi locale=en?
4. `Tự làm` yêu cầu assert chuỗi mới — vì sao phải assert cả trong
   test chứ không chỉ nhìn bằng mắt?

## Ta cố ý chưa thêm

- Test mọi key trên mọi màn — không cần; một test switch chứng minh
  cơ chế, việc còn lại là coverage lặp.
- Golden test theo locale — chưa có golden infra (không phải scope).
- Onboarding strings — M18 sẽ đụng.

## Checkpoint hoàn thành — TỔNG HỢP M17

- `flutter analyze` → sạch.
- `flutter test` → **90/90** (87 cũ + 3 mới).
- `test/localization_switch_test.dart` xanh — locale đổi live qua
  repo stream.
- `flutter build web` → √.
- Runtime: chip English↔Tiếng Việt đổi toàn bộ chrome ngay lập tức.

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
