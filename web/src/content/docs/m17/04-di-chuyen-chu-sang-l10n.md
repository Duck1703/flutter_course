---
title: "Bài 4 · Dời chữ sang AppLocalizations — migration toàn bộ UI"
description: "Mechanical migration: AppLocalizations.of(context) ở mọi widget; factory+VM nhận chuỗi qua tham số (VM không chạm context); localizedTestApp ghim Locale('vi') giữ nguyên 87 assertions."
sidebar:
  label: "Bài 4 · Dời chữ sang l10n"
  order: 4
---

## Mục tiêu

Sau bài này bạn **làm được**:

- Áp một mẫu migration duy nhất khắp UI:
  `final l10n = AppLocalizations.of(context)` đầu `build`, rồi thay
  mọi literal bằng `l10n.key`.
- Hiểu và viết `localizedSettingItems`: ViewModel **không** import
  `AppLocalizations` — widget truyền chuỗi vào qua tham số; VM giữ
  nguyên context-free (test được như unit thường).
- Sửa test bị vỡ vì thiếu delegates: bọc widget bằng host có
  `localizationsDelegates` + `supportedLocales`, ghim
  `Locale('vi')` để assertion tiếng Việt cũ giữ nguyên ý nghĩa.

## Bạn đang ở đâu

- M17 bài 4/5 — bài "cơ khí" lớn nhất: mọi chuỗi UI rời code, vào
  ARB. Sau bài này app thật sự hai ngôn ngữ.
- Pipeline (bài 2) + wiring (bài 3) đã sẵn; giờ chỉ là áp pattern.

## Vì sao việc này quan trọng ngay bây giờ

`AppLocalizations` tồn tại mà không ai gọi = không có gì đổi. Bài
này là lúc mọi literal '…' bị thay bằng `l10n.*`. Nó là việc
*mechanical* nhất của milestone — và cũng là chỗ dễ gãy nhất nếu
làm ẩu: một `const` quên gỡ quanh `l10n.x`, một `of(context)` đặt
ngoài vùng có delegates, một test không bọc host l10n — mỗi cái một
lỗi riêng. Đi theo checklist, không sáng tạo.

## Bạn đã biết gì

- `AppLocalizations.of(context)` = tra InheritedWidget l10n do
  `MaterialApp` cấp (bài 2–3).
- `context.watch`/`context.read` (M12) — cùng họ tra-ngược-cây.
- `SettingItemData` sealed + `buildSettingItems` factory (M16).
- Widget test cần `MaterialApp` host bọc widget (M13+).

## Dart cần dùng

| Cú pháp | Ví dụ | Ý nghĩa |
|---|---|---|
| named param + default | `String soundText = 'Sound'` | caller có thể bỏ qua — default đứng sau |
| param forwarding | `soundText: soundText` | VM nhận chuỗi rồi chuyển tiếp vào factory |
| `final l10n = …` ở đầu build | `final l10n = AppLocalizations.of(context)` | lấy 1 lần, xài nhiều chỗ — tránh `of` lặp |

Không có syntax mới — bài này luyện *vị trí đặt* chúng (UI sở hữu chữ,
VM nhận qua tham số).

## Flutter cần dùng

- `AppLocalizations.of(context)` — trả instance theo locale hiện
  hành; **bắt buộc** có `localizationsDelegates` phía trên (đã cấu
  hình ở `MaterialApp` bài 3).
- Getter có placeholder → method:
  `l10n.profileLevel(profile.level)` → `'CẤP 3'`/`'LEVEL 3'`.
- `l10n` trong callback `onGenerateTitle`/builder lồng — nhớ lấy
  đúng `context` của scope có delegates.

## Android / Compose bridge

- `getString(R.string.x)` rải khắp Activity/Fragment ↔
  `AppLocalizations.of(context).x` rải khắp `build` — cùng cơ chế
  "tra resource theo locale tại chỗ render".
- **Khác biệt quan trọng:** Android tự resolve theo locale hệ thống
  (đổi resource-qualifier = đổi bản dịch); Flutter phân hai lớp —
  `MaterialApp.locale` chọn locale, `of(context)` tra instance —
  nên *đổi locale runtime* là một rebuild bình thường, không cần
  `recreate()`.
- ĐỪNG cho rằng mọi chuỗi phải qua resource: `nativeName`, username,
  nội dung câu hỏi là **data** — y như Android giữ `@string` cho
  chrome còn nội dung DB/API để nguyên.

## Senior project connection

- Senior `menu_settings_dialog_scope.dart`: lấy `l10n` một lần đầu
  build, truyền `l10n.*` vào `viewModel.localizedSettingItems(...)`
  — y hệt.
- Senior `settings_view_model.dart` `localizedSettingItems({required
  6×String})` → `buildSettingItems` — signature learner **1:1**.
- Senior `_snackBarText(l10n, message)` — sealed switch enum→l10n —
  learner có cùng hàm.
- Senior widget test `LocalizedTestApp` tương đương
  `localized_test_app.dart` của learner — host có delegates +
  ghim locale.

## Build it step by step

### Bước 1 — factory nhận chuỗi qua tham số

`lib/view_models/settings/settings_item_factory.dart` — thêm 6
named params có **default tiếng Anh y hệt senior**:

```dart
List<SettingItemData> buildSettingItems({
  required UserSettingsData settings,
  required bool effectiveNotificationEnabled,
  String soundText = 'Sound',
  String musicText = 'Music',
  String hapticText = 'Haptic Feedback',
  String notificationsText = 'Notifications',
  String notificationTimeText = 'Notification Time',
  String notificationsHint = 'Once a day',
}) { … }
```

Trong thân, dùng các tham số thay literal:
`text: soundText`, `subtitle: notificationsHint`…

Vì sao default tiếng Anh? Senior làm vậy — default chỉ là "đường
lui" khi caller không truyền; production luôn truyền `l10n.*`.
M16 callers (`settingItems` trong test) vẫn compile không đổi.

### Bước 2 — VM: `localizedSettingItems` (context-free)

`lib/view_models/settings/settings_view_model.dart` — thêm:

```dart
/// Bản đã bản địa hoá — senior `localizedSettingItems`: widget truyền
/// chuỗi `l10n.*`, VM/factory không import AppLocalizations (VM
/// không chạm context — tầng UI sở hữu chữ).
List<SettingItemData> localizedSettingItems({
  required String soundText,
  required String musicText,
  required String hapticText,
  required String notificationsText,
  required String notificationTimeText,
  required String notificationsHint,
}) {
  return buildSettingItems(
    settings: _settings,
    effectiveNotificationEnabled: effectiveNotificationEnabled,
    soundText: soundText,
    musicText: musicText,
    hapticText: hapticText,
    notificationsText: notificationsText,
    notificationTimeText: notificationTimeText,
    notificationsHint: notificationsHint,
  );
}
```

> **Tại sao VM không tự `AppLocalizations.of(context)`?** Vì VM là
> logic — nó không có `BuildContext`, và *không nên* có: test VM như
> unit thường, không pump widget. Chữ là chuyện của UI layer — UI
> đọc `l10n` rồi **đổ chuỗi vào** VM qua tham số. Ranh giới này
> giống senior 1:1.

### Bước 3 — settings dialog dùng `localizedSettingItems` + l10n

`lib/widgets/menu/settings/settings_dialog.dart` — đầu `build` của
`_SettingsDialog`:

```dart
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
// (thêm import ở đầu file — cùng quy ước cho cả 4 file UI migrate)

final viewModel = context.watch<SettingsViewModel>();
final l10n = AppLocalizations.of(context);
final items = viewModel.localizedSettingItems(
  soundText: l10n.soundSetting,
  musicText: l10n.musicSetting,
  hapticText: l10n.hapticSetting,
  notificationsText: l10n.notificationsSetting,
  notificationTimeText: l10n.notificationTimeSetting,
  notificationsHint: l10n.settingsNotificationsHint,
);
```

Rồi thay toàn bộ literal trong dialog:

- `'GIỜ THÔNG BÁO'` → `l10n.notificationTimeTitle` (title nhánh
  picker).
- `'CÀI ĐẶT'` → `l10n.settingsTitle`.
- `_SettingsSectionTitle('NGÔN NGỮ'|'ÂM THANH'|'THÔNG BÁO'|'TÀI
  KHOẢN')` → `l10n.settingsSectionLanguage`/`settingsSectionAudio`/
  `settingsSectionNotifications`/`settingsSectionAccount`.
- `'XONG'` → `l10n.doneButton`.
- Snackbar bridge — trong `_SettingsDialogEventBridgeState` (M16),
  `_snackBarText` đổi signature: nhận thêm `AppLocalizations` ở đầu
  (senior `_snackBarText` cùng shape):

```dart
String _snackBarText(
    AppLocalizations l10n, SettingsSnackBarMessage message) {
  return switch (message) {
    SettingsSnackBarMessage.loadFailed =>
        l10n.settingsLoadErrorMessage,
    SettingsSnackBarMessage.updateFailed =>
        l10n.settingsUpdateErrorMessage,
    SettingsSnackBarMessage.notificationTimeUpdateFailed =>
        l10n.settingsNotificationTimeUpdateErrorMessage,
  };
}
```

và chỗ emit:
`SnackBar(content: Text(_snackBarText(AppLocalizations.of(context), message)))`.

- Account row — `_SettingsAccountRow.build` lấy `final l10n =
  AppLocalizations.of(context)`; dòng hint `'Khách — …'` →
  `l10n.settingsGuestSyncHint`; tên hiển thị vẫn `profile.username`
  (dữ kiện, không phải chrome).
- Language chips — **không** qua l10n: senior hiển thị
  `language.nativeName` ('English'/'Tiếng Việt' — nativeName là dữ
  kiện của `SupportedLanguageData`, luôn tự gọi tên mình bằng chính
  ngôn ngữ đó bất kể locale).

Nhớ bỏ `const` quanh mọi widget chạm `l10n.*` — chuỗi runtime không
const được.

### Bước 4 — notification time picker

`lib/widgets/menu/settings/notification_time_picker_dialog.dart` —
thêm `import '../../../l10n/app_localizations.dart';` và thay:

- `'HUỶ'` → `AppLocalizations.of(context).cancelButton`
- `'XÁC NHẬN'` → `AppLocalizations.of(context).confirmButton`

### Bước 5 — menu screen

`lib/screens/menu_screen.dart` — thêm
`import '../l10n/app_localizations.dart';` (file nằm ở `lib/screens/`
→ lên 1 cấp tới `lib/`); mỗi `build` cần l10n đặt
`final l10n = AppLocalizations.of(context);` ở đầu rồi thay:

- gear `semanticLabel: 'Cài đặt'` → `l10n.settingsSemanticLabel`
  (đọc context ngoài bằng `AppLocalizations.of(context)` trực tiếp
  nếu không có biến `l10n`).
- `'ĐẶT LẠI HỒ SƠ'` → `l10n.resetProfileButton`;
  `'BẮT ĐẦU CHƠI'` → `l10n.startGameButton`.
- Header: `'CẤP $level'` → `l10n.profileLevel(profile.level)`;
  `'$exp / $max EXP'` → `l10n.menuExpProgress(profile.currentExp,
  profile.expForNextLevel)`.
- Stats: `'Đã chơi'`/`'Thắng'`/`'Tỉ lệ thắng'`/`'TỔNG THƯỞNG'` →
  `l10n.gamesJoinedLabel`/`gamesWonLabel`/`menuWinRateLabel`/
  `totalEarningsLabel`.
- Leaderboard: `'Bảng xếp hạng'`/`'Top 10 người chơi'` →
  `l10n.leaderboardTitle`/`leaderboardSubtitle`.
- `const Row(...)` chứa `l10n.*` → gỡ `const` (chuỗi runtime).

`MenuViewModel` **giữ nguyên** `'Đã đặt lại hồ sơ.'` literal —
đây là chuỗi learner-scaffolding (senior `MenuScreenViewModel` có
variant `MenuSnackBarRequested` nhưng **không emit** từ luồng
reset-profile — senior không có nút đó).
không phải key ARB.

### Bước 6 — game screen

`lib/screens/game_screen.dart` — cùng thêm
`import '../l10n/app_localizations.dart';`:

- AppBar `'Phòng chơi'` → `AppLocalizations.of(context).gameRoomTitle`.
- Counter `'Câu $i/$n'` → `l10n.questionCounter(questionIndex + 1,
  questionCount)`; `'${seconds}s'` → `l10n.secondsRemaining(secondsLeft)`.
- Nút: `'CHỐT ĐÁP ÁN'`/`'TIẾP'`/`'XEM KẾT QUẢ'` →
  `l10n.submitAnswerButton`/`nextButton`/`seeResultButton`.
- Feedback: `'Chính xác!'`/`'Chưa đúng — …'` →
  `l10n.correctFeedback`/`wrongFeedback`.
- Hai nút trong dialog kết-thúc — `'CHƠI LẠI'`/`'VỀ MENU'` →
  `AppLocalizations.of(dialogContext).playAgainButton`/
  `AppLocalizations.of(dialogContext).menuButton`. **Để ý
  `dialogContext`**: nút nằm trong builder của `showDialog`, context
  đó nằm dưới MaterialApp có delegates nên hợp lệ — nhưng phải là
  context của dialog, không phải context ngoài.
- Dialog end-game — hai helper đổi signature nhận `AppLocalizations`,
  `switch` trên `_dialogState` giữ nguyên cấu trúc sealed (kể cả nhánh
  `GameDialogHidden` vẫn phải trả gì đó — `''`):

```dart
String _dialogTitle(AppLocalizations l10n) {
  return switch (_dialogState) {
    GameVictoryDialog() => l10n.victoryTitle,
    GameEndedDialog(:final reason) => switch (reason) {
      GameEndReason.timeout => l10n.timeoutTitle,
      GameEndReason.wrongAnswer => l10n.gameOverTitle,
    },
    GameDialogHidden() => '',
  };
}

String _resultText(AppLocalizations l10n) {
  final base =
      l10n.correctCountBase(_correctCount, quizQuestions.length);
  return switch (_dialogState) {
    GameVictoryDialog() => l10n.victoryBody(base),
    GameEndedDialog(:final reason) => switch (reason) {
      GameEndReason.timeout => l10n.timeoutBody(base),
      GameEndReason.wrongAnswer => l10n.wrongAnswerBody(base),
    },
    GameDialogHidden() => '',
  };
}
```

Gọi: `_dialogTitle(AppLocalizations.of(context))` /
`_resultText(AppLocalizations.of(context))` — `{base}` là placeholder
String nhận chuỗi con đã format sẵn qua `correctCountBase`.

> ⚠️ **Dự kiến đỏ giữa bài:** sau Bước 6, các màn đã gọi
> `AppLocalizations.of(context)` nhưng test chưa có delegates →
> `flutter test` lúc này **fail là bình thường**. Bước 7 vá đúng chỗ
> đó — đừng quay lại sửa screen vì test đỏ.

### Bước 7 — test host `localized_test_app.dart` + ghim locale

Mọi widget test pump `MaterialApp` giờ **bắt buộc** có delegates —
không có thì `AppLocalizations.of` ném lỗi. Tạo
`test/helpers/localized_test_app.dart`:

```dart
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Host MaterialApp cho widget test: delegates + supportedLocales +
/// ghim `locale: vi` để assertion tiếng Việt hiện hữu giữ nguyên ý
/// nghĩa. (Senior test assert English vì device locale en — learner
/// test chọn vi để khỏi viết lại 87 assertions.)
MaterialApp localizedTestApp({
  required Widget home,
  Locale locale = const Locale('vi'),
  Widget? child,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child ?? home,
  );
}
```

Rồi trong 4 file test, thay `MaterialApp(home: …)` bằng
`localizedTestApp(home: …)` (import helper):

- `test/menu_provider_scope_test.dart`
- `test/menu_screen_ui_events_test.dart`
- `test/widgets/game_screen_test.dart`
- `test/widgets/settings_dialog_test.dart`

> Vì sao không đổi assertion sang tiếng Anh? Ghim `Locale('vi')` giữ
> nguyên giá trị assert ('CÀI ĐẶT'…) — ít churn hơn, và bài 5 sẽ có
> test riêng assert cả hai chiều en↔vi.

### Bước 8 — kiểm

```bash
flutter analyze
flutter test      # 87/87 — assertions vi ghim locale vẫn đúng
flutter run       # app hiển thị vi — như cũ, NHƯNG giờ đi qua l10n
```

Đổi ngôn ngữ trong dialog CÀI ĐẶT → English → toàn bộ menu/game/
dialog đổi sang en ngay lập tức (đó là payoff của cả milestone).

## Hiểu code — một pattern, năm chỗ

Cùng một động tác lặp lại: `final l10n = AppLocalizations.of(context)`
→ thay literal → gỡ `const` nếu vướng. Khác biệt duy nhất: code dữ
kiện (model) không đụng — `nativeName`, `username`, câu hỏi quiz là
**data**, chỉ chrome mới qua ARB.

## Chạy và quan sát

`flutter run` → ⚙ → mở settings: chip "English" → toàn màn đổi
en (LANGUAGE/AUDIO/NOTIFICATIONS/ACCOUNT/DONE…); chọn "Tiếng Việt"
→ về vi. Dialog title, snackbar message, section đều đổi cùng lúc
— chứng tỏ một nguồn truth.

## Thử nghiệm

- Sửa `app_vi.arb` `settingsTitle` → `gen-l10n` → hot restart →
  title dialog đổi — vòng lặp resource→code thấy rõ.
- Cố tình xoá `localizationsDelegates` ở test host → chạy test →
  đọc stack trace `AppLocalizations.of` fail — ghi nhớ triệu chứng.

## Lỗi hay gặp

- `AppLocalizations.of(context)` trả lỗi trong test → test thiếu
  delegates; bọc `localizedTestApp`.
- `const` bao `Text(l10n.x)` → compile error "not a constant"; gỡ
  `const`.
- Assertion fail `'CÀI ĐẶT'` not found → quên `locale: Locale('vi')`
  (mặc định test chạy en template → hiện 'SETTINGS').
- Truyền `BuildContext` vào VM để VM tự lấy l10n → sai ranh giới;
  chữ đi vào VM **qua tham số**.

## Tự làm — migrate nốt hàng "Phiên bản"

Ở Tự làm cuối M16 bạn đã thêm `SettingInfoItemData` với label cứng
`'Phiên bản'`. Chuỗi đó vẫn nằm ngoài l10n — migrate nó đầy đủ.

**Phần A — quyết định phạm vi.** Ba chuỗi còn "cứng" trong app — với
mỗi cái: *đưa vào l10n hay không, và vì sao?*

| Chuỗi | Vào l10n? |
|---|---|
| Label `'Phiên bản'` của info row (M16/05 Tự làm) | |
| Câu hỏi/đáp án trong quiz question bank | |
| `nativeName` `'Tiếng Việt'` trên `LanguageChip` | |

**Phần B — migrate end-to-end** (không copy — quyết rồi mở đáp án):

1. Tên key bạn chọn + nội dung `app_en.arb`/`app_vi.arb`.
2. `localizedSettingItems` nhận String tham số — label mới đi qua
   tham số nào: thêm param thứ bảy hay tái dùng param có sẵn?
3. Call site truyền `l10n.<key>` ở đâu?
4. Verify: `flutter gen-l10n` exit 0; widget test ghim `Locale('vi')`
   thấy 'Phiên bản', `Locale('en')` thấy bản en.

<details><summary>Đáp án</summary>

**A.** Label 'Phiên bản' → **vào l10n** (chrome UI, đổi theo locale).
Quiz content → **không** — đó là domain data, senior cũng không
localize ngân hàng câu hỏi. `nativeName` → **không** — chuỗi tự mô
tả bằng chính ngôn ngữ đó ("Tiếng Việt" phải luôn hiện là "Tiếng
Việt" kể cả khi app đang en).

**B.**
1. `settingsVersionLabel` — `"Version"` en / `"Phiên bản"` vi.
2. Thêm param thứ bảy `String versionText` vào
   `localizedSettingItems` — factory không biết l10n, chữ đi vào
   qua tham số (đúng pattern Bước 1–2).
3. Ở chỗ gọi `localizedSettingItems(...)` trong settings dialog —
   thêm `versionText: l10n.settingsVersionLabel`.
4. Test ghim locale: pump với `Locale('vi')` → `find.text('Phiên
   bản')`; `Locale('en')` → `find.text('Version')`.

Điểm học: quyết định "có localize không" nằm ở *vai trò của chuỗi*
— chrome UI thì có, domain data và tên-tự-thân thì không.

</details>

## Kiểm tra hiểu biết## Kiểm tra hiểu biết

1. Vì sao `localizedSettingItems` nhận 6 String thay vì tự gọi
   `AppLocalizations.of`?
2. `LanguageChip` hiển thị `nativeName` chứ không `l10n.*` — đúng
   hay thiếu sót? Vì sao?
3. `of(context)` ở `onGenerateTitle` hợp lệ còn ở `title:` thì lỗi —
   giải thích.
4. Một widget không rebuild khi đổi locale — nguyên nhân hay gặp?
   (gợi: literal sót lại / `const` cache).

## Ta cố ý chưa thêm

- **Leaderboard/auth/onboarding strings** — surface tương ứng chưa
  đến (M18 onboarding; M22+ auth) → chưa có key.
- **`.toUpperCase()` tại widget layer** — senior giữ data
  sentence-case rồi upper khi render; learner bake sẵn casing trong
  ARB ('START GAME'). Tương đương về hiển thị — chỉ đổi
  chỉ khi cần parity pass.
- **Localization cho quiz-bank** — nội dung câu hỏi là data; senior
  cũng không localize chúng trong hệ l10n này.

## Checkpoint hoàn thành

- `flutter analyze` sạch.
- `flutter test` → **87/87** (vi pin giữ assertions).
- Runtime check: đổi chip ngôn ngữ trong settings → toàn bộ chrome
  đổi en↔vi không restart.
- `grep` lib/ không còn literal vi trong 4 file UI đã migrate (trừ
  quiz data + enum snackbar ở VM).
