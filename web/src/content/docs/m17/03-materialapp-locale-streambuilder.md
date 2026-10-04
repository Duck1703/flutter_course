---
title: "Bài 3 · MaterialApp.locale lái bởi settings stream"
description: "CORE: StreamBuilder bọc MaterialApp — locale suy từ userSettingsStream mỗi lần emit; whitelist `languageCode` chốt đầu vào của `fromMap`; languageCode lạ → null → fallback hệ thống."
sidebar:
  label: "Bài 3 · locale ← stream"
  order: 3
---

## Mục tiêu

Sau bài này bạn **làm được**:

- Giải thích cơ chế `MaterialApp.locale` +
  `localizationsDelegates` + `supportedLocales`: ai chọn bản dịch,
  fallback đi đâu khi thiếu.
- Viết pattern senior: `StreamBuilder` bọc
  `MaterialApp`, `initialData` = `stream.value` — locale đổi **ngay**
  khi settings đổi, không restart.
- Hiểu và viết guard whitelist: `fromMap` lọc `languageCode` qua
  `SupportedLanguageData.isSupportedCode` — mã lạ/kiểu sai/rỗng →
  `null`.

## Bạn đang ở đâu

- M17 bài 3/5 — **bài CORE** của milestone. Bài 2 đã có
  `AppLocalizations` generated; bài này nối nó vào `MaterialApp` và
  lái `locale` bằng dữ kiện thật.
- Tới đây `languageCode` đã persist từ M16 nhưng vô dụng — bài này
  làm nó **có tác dụng thật**.

## Vì sao việc này quan trọng ngay bây giờ

Hỏi thật: `languageCode` đổi, ai rebuild app với locale mới?

- **Gọi `setState` ở đâu đó trong dialog?** → dialog không sở hữu
  `MaterialApp`; và "đổi ngôn ngữ" không phải state của một widget —
  nó là **dữ kiện persist** đã có stream riêng.
- **Restart app sau khi chọn?** → senior không làm vậy; UX cũng tệ.
- **Đọc `languageCode` một lần trong `main()`?** → persist chưa
  load xong hoặc người dùng đổi sau đó thì sao?

Senior trả lời bằng chính đường đi M14–M16 đã dạy: *stream là nguồn
truth duy nhất*. `userSettingsStream` emit `UserSettingsData` mới mỗi
lần ghi → đặt `StreamBuilder` ở **gốc app** → `MaterialApp` rebuild
với `locale` mới. Cùng một cơ chế với mọi rebuild khác — không phát
minh gì mới, chỉ leo scope lên app-root.

## Bạn đã biết gì

- `StreamBuilder` + `initialData` (M14) — rebuild khi stream
  emit, render ngay giá trị hiện có.
- `userSettingsStream.value` seed (M14/M16) — BehaviorSubject
  giữ giá trị cuối, đọc đồng bộ được.
- `context.read<T>()` lấy repo từ `AppDependencyScope` (M12).
- `SupportedLanguageData.fromCode` — `null` khi mã không hỗ trợ
  (M16).
- `fromMap` phòng thủ: sai kiểu/ngoài khoảng → default/null (M14) —
  bài này **siết thêm whitelist** cho `languageCode`.

## Flutter cần dùng

- `StreamBuilder<T>({stream, initialData, builder})` — widget rebuild
  mỗi khi stream emit; `initialData` cho frame đầu (đã học ở M14).
- `MaterialApp.locale` — `Locale?`; `null` = theo locale hệ thống.
- `MaterialApp.localizationsDelegates` / `supportedLocales` — list
  do `AppLocalizations` generated cung cấp; **thiếu delegates →
  `AppLocalizations.of` ném lỗi** mọi nơi dưới nó.
- `onGenerateTitle: (context) => …` — callback chạy **dưới**
  MaterialApp (khác `title:` là chuỗi tĩnh ở trên).
- `Locale('vi')` / `Locale('en')` — chỉ language code; chưa cần
  country code.

## Mental model mới — "locale là derived state của settings"

```
SharedPreferences ──load──▶ UserSettingsRepository
                              │ userSettingsStream (BehaviorSubject)
                              ▼  emit UserSettingsData {languageCode:'vi', …}
                    StreamBuilder ở app-root
                              │  fromCode → Locale('vi') / null
                              ▼
                    MaterialApp(locale: …)  ← delegates chọn bản dịch vi
                              │
                              ▼  toàn cây dưới đây
                    AppLocalizations.of(context).x → chuỗi vi
```

`locale` không được lưu riêng — nó là **hàm của settings**:
`locale = f(languageCode)`. Một nguồn truth, render bằng state.

## Ví dụ độc lập — chọn locale từ một mã

```dart
Locale? _selectedLocaleFor(String? languageCode) {
  final language = SupportedLanguageData.fromCode(languageCode);
  return language == null ? null : Locale(language.code);
}
```

- `'vi'` → `Locale('vi')`; `'en'` → `Locale('en')`.
- `'fr'`/`null`/rỗng → `fromCode` trả `null` → trả `null` →
  `MaterialApp` fallback về locale hệ thống → template `en` đứng
  sau cùng. `Locale?` nullable **cố ý**: `null` là input hợp lệ
  ("để máy quyết").

## Android / Compose bridge

- `Locale.setDefault` + `recreate()`/`attachBaseContext` ↔
  `MaterialApp.locale` + rebuild — Flutter không cần recreate
  Activity; `locale` chỉ là prop của widget gốc.
- `Resources.getConfiguration().locale` ↔ `Localizations.localeOf
  (context)` khi cần đọc locale hiện tại sâu trong cây.
- SharedPreferences giữ `languageCode` ↔ `user_settings` store của
  repo — giống hệt nhau; khác là bên Flutter stream emit đẩy rebuild,
  không cần listener tay.

## Senior project connection

Senior `main.dart` (đọc-only `lib/main.dart`):

```dart
// senior — rút gọn đúng phần locale
StreamBuilder(
  stream: userSettingsRepository.userSettingsStream,
  initialData: userSettingsRepository.userSettingsStream.value,
  builder: (context, snapshot) => MaterialApp(
    locale: _selectedLocaleFor(snapshot.data?.languageCode),
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    navigatorKey: navigationController.navigatorKey, // learner chưa có
    ...
  ),
)
```

Learner tái dựng y hệt trừ `navigatorKey` (senior đọc
`navigationController` qua `context.read<AppNavigationController>()`;
learner chưa có controller đó — nó phục vụ deep-link/auth, không phải
vấn đề của M17).

Hai nơi senior cần chú ý:

- `onGenerateTitle` thay `title:` — title cần context **bên trong**
  MaterialApp mới tra được l10n (`of(context)` trong `title:` sẽ đứng
  NGOÀI vùng có delegates).
- `initialData: stream.value` — cùng idiom `.value` seed của
  `SettingsViewModel` (M16): BehaviorSubject luôn có giá trị cuối.

## Build it step by step

### Bước 1 — whitelist `languageCode` trong `fromMap`

Mở `lib/data/settings/user_settings_data.dart`. Trước hết thêm import
cho model ngôn ngữ — đặt sau block comment đầu file, ngay trước
`class UserSettingsData`:

```dart
import 'supported_language_data.dart';
```

> Nếu `flutter analyze` báo info `dangling_library_doc_comments`
> (block `///` đầu file giờ đứng trên `import` thay vì một
> declaration), đổi các dòng `///` đó thành `//` — comment thường.
> File production dùng `//` ngay từ đầu nên không dính lint này.

M16 parse `languageCode` chỉ kiểm "String không rỗng" — một mã lạ như
`'fr'` vẫn lọt vào model. Senior siết bằng whitelist ngay tại biên
`fromMap`:

```dart
factory UserSettingsData.fromMap(Map<String, Object?> map) {
  final hour = _boundedInt(map['notificationHour'], 0, 23);
  final minute = _boundedInt(map['notificationMinute'], 0, 59);
  final languageCode = _supportedLanguageCode(map['languageCode']); // ← đổi

  return UserSettingsData(
    // ... giữ nguyên các field khác
    languageCode: languageCode,
  );
}
```

**Xoá** helper cũ `_nonEmptyLanguageCode` (từ M16) và thay bằng helper
whitelist dưới đây — để nguyên cả hai sẽ thành unused-element warning.

```dart
/// Converged tại M17: y hệt senior `_supportedLanguageCode`
/// — không phải String HOẶC không nằm trong whitelist → null.
static String? _supportedLanguageCode(Object? value) {
  if (value is! String || !SupportedLanguageData.isSupportedCode(value)) {
    return null;
  }

  return value;
}
```

Vì sao lọc **ở `fromMap`** chứ không ở chỗ dùng? Vì đây là *cổng duy
nhất* dữ kiện disk vào model — lọc ở cổng thì mọi consumer sau đó
(`Locale`, chips, test) khỏi phòng thủ lại —
đăng ký từ M16, hẹn đúng M17.

### Bước 2 — `main.dart`: StreamBuilder bọc MaterialApp

Thêm import `AppLocalizations` + `SupportedLanguageData`, rồi viết
lại `build` của `AIMillionaireApp`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_dependency_scope.dart';
import 'data/settings/supported_language_data.dart';
import 'l10n/app_localizations.dart';
import 'repositories/onboarding/onboarding_repository.dart';
import 'repositories/profile/user_profile_repository.dart';
import 'repositories/settings/user_settings_repository.dart';
import 'screens/menu_screen.dart';

class AIMillionaireApp extends StatelessWidget {
  const AIMillionaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Đúng pattern senior: MaterialApp.locale lái bởi StreamBuilder
    // trên settings stream; đổi languageCode trong settings → stream
    // emit → MaterialApp rebuild với Locale mới — KHÔNG cần restart.
    final settingsStream =
        context.read<UserSettingsRepository>().userSettingsStream;

    return StreamBuilder(
      stream: settingsStream,
      initialData: settingsStream.value,
      builder: (context, snapshot) {
        final selectedLocale =
            _selectedLocaleFor(snapshot.data?.languageCode);

        return MaterialApp(
          locale: selectedLocale,
          onGenerateTitle: (context) =>
              AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          localizationsDelegates:
              AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF5137E5),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: const MenuScreen(),
        );
      },
    );
  }

  /// Senior `_selectedLocaleFor`: mã lạ/null → null → MaterialApp
  /// fallback về device locale (template en khi thiếu bản dịch).
  Locale? _selectedLocaleFor(String? languageCode) {
    final language = SupportedLanguageData.fromCode(languageCode);
    return language == null ? null : Locale(language.code);
  }
}
```

Để ý `StreamBuilder` **không** ghi generic — kiểu suy từ
`stream`/`initialData` (y hệt senior), khỏi cần import
`user_settings_data.dart` cho main.dart.

### Bước 3 — kiểm

```bash
flutter analyze
flutter test      # vẫn 87/87 — test chưa qua l10n, chữ cũ còn nguyên
flutter run
```

App vẫn hiển thị tiếng Việt literal (bài 4 mới đổi). Nhưng hạ tầng
đã sống: mở `main.dart` — `MaterialApp.locale` giờ phụ thuộc
`snapshot.data?.languageCode`.

## Hiểu code

- `context.read<UserSettingsRepository>()` — lấy repo từ
  `AppDependencyScope` ở **trên** `MaterialApp` (provider cha của
  cây, reachable ở app-root).
- `initialData: settingsStream.value` — không có dòng này,
  `StreamBuilder` render frame đầu với `snapshot.data == null` →
  `locale == null` nháy một frame trước khi stream emit — `.value`
  seed khử nháy (đã học ở M14).
- `onGenerateTitle` — title hiển thị ở task-switcher OS; callback
  nhận context **dưới** MaterialApp nên `of(context)` hợp lệ. Nếu để
  `title: AppLocalizations.of(context).appTitle` ở args MaterialApp
  → context đó là của app-root, **chưa có** delegates → lỗi.
- `localizationsDelegates` — list delegates gen sẵn: delegate của
  `AppLocalizations` + `GlobalMaterialLocalizations`… cung cấp bản
  dịch cho cả widget hệ thống (nút back, tooltip, date picker).

## Chạy và quan sát

Chưa đổi gì về hình — nhưng thử nghiệm tư tưởng:

```dart
// (không cần code thật) nếu languageCode='en' đã persist từ trước,
// frame đầu đã dựng MaterialApp với Locale('en').
```

Đổi `languageCode` bằng tay trong `SharedPreferences` rồi hot
restart → `fromMap` → stream → `Locale('en')` — `MaterialApp` đã sẵn
sàng phục vụ en, chỉ chờ bài 4 thay literal bằng `l10n.*`.

## Thử nghiệm

- Trong `_selectedLocaleFor`, `print(languageCode)` qua
  `debugPrint` — restart app, đổi ngôn ngữ trong dialog (M16 chip) →
  xem stream emit đẩy rebuild tại gốc.
- Bỏ `initialData` thử → đôi khi thấy app nháy en một frame khi mở
  (tuỳ timing) — đó là lý do `.value` seed tồn tại.

## Lỗi hay gặp

- `AppLocalizations.of(context)` trả null/throw trong `title:` —
  nhớ `onGenerateTitle`.
- `StreamBuilder` quên `initialData` → frame đầu `snapshot.data`
  null → locale nháy; thêm `.value` seed.
- `languageCode: 'fr'` trong store → whitelist trong `fromMap` → `null`
  → locale null → fallback — **đúng**, đừng "sửa" bằng cách bỏ guard.
- Gọi `context.watch` ở `AIMillionaireApp.build` để nghe repo → sai:
  repo không phải Listenable; stream mới là cổng emit → StreamBuilder.

## Tự làm — dự đoán locale cho mọi đầu vào

Điền bảng *trước* khi mở đáp án — với mỗi giá trị `languageCode`
trong store, dự đoán `MaterialApp.locale` cuối cùng và điều người
dùng thấy:

| `languageCode` trong store | `Locale?` truyền vào | App hiển thị ngôn ngữ? |
| --- | --- | --- |
| `'vi'` |  |  |
| `'en'` |  |  |
| `'fr'` |  |  |
| `null` (chưa bao giờ ghi) |  |  |
| `'vi'` rồi user gạt sang `'en'` trong dialog |  |  |

Kèm: với hàng cuối, trace đường đi đầy đủ từ `save` tới rebuild —
nêu tên 5 điểm chạm (repository → stream → seed/builder → locale →
delegates).

<details><summary>Đáp án</summary>

- `'vi'` → `Locale('vi')` → vi. `'en'` → `Locale('en')` → en.
- `'fr'` → whitelist `fromMap` trả `null` → `locale: null` → Flutter
  dùng locale hệ thống; nếu hệ thống cũng không nằm trong
  `supportedLocales` → rớt về template `en`. *Đây là hành vi đúng —
  đừng "sửa" bằng cách bỏ whitelist.*
- `null` → `locale: null` → fallback hệ thống → template en.
- Đổi chip: `settingsRepository.save` ghi `languageCode: 'en'` →
  `userSettingsStream` emit `UserSettingsData` mới → `StreamBuilder`
  ở gốc rebuild → `MaterialApp` nhận `locale: Locale('en')` →
  `AppLocalizations.of(context)` mọi nơi trả bản en — không restart.

Điểm học: **locale không phải state riêng** — nó là *derived state*
của `languageCode` đã persist, suy ra mỗi lần stream emit.

</details>

## Kiểm tra hiểu biết

1. Vì sao `locale` là `Locale?` (nullable) thay vì `Locale`?
2. `languageCode` đổi lúc app đang chạy — trace đường đi từ `save`
   tới `MaterialApp` rebuild.
3. Vì sao whitelist nằm trong `fromMap` chứ không phải trong
   `_selectedLocaleFor`? (gợi: một cổng vào, nhiều consumer)
4. `supportedLocales` thiếu `'vi'` mà stream emit `'vi'` — Flutter
   làm gì?
5. Senior dùng `onGenerateTitle` — tại sao không phải `title:`?

## Ta cố ý chưa thêm

- **`Localizations.override`** — widget ép locale cho subtree; senior
  không cần; M17 chỉ lái locale ở root.
- **`localeResolutionCallback`** — senior dùng mặc định
  (`locale` → supported → first supported); learner giữ nguyên.
- **`navigatorKey`/deep-link** — senior có `AppNavigationController`;
  learner chưa có surface đó (không phải scope M17).

## Checkpoint hoàn thành

- `flutter analyze` sạch.
- `flutter test` → **87/87** (không đổi — chữ literal vẫn còn).
- `main.dart` chứa `StreamBuilder` (kiểu suy `UserSettingsData`) bọc
  `MaterialApp` với `locale`/`delegates`/`supportedLocales`.
- `user_settings_data.dart` có `_supportedLanguageCode` whitelist —
  `fromMap({'languageCode': 'fr'})` → `languageCode == null`
  (kiểm bằng test nhanh hoặc `dart` snippet).
