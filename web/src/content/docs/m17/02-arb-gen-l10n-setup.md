---
title: "Bài 2 · ARB + gen-l10n — dựng pipeline bản địa hoá"
description: "Tạo l10n.yaml + pubspec deps + app_en.arb/app_vi.arb (48 keys), chạy flutter gen-l10n, đọc code generated. Checkpoint: gen-l10n exit 0 + analyze clean — app vẫn chạy như cũ vì chưa ai gọi l10n."
sidebar:
  label: "Bài 2 · ARB + gen-l10n"
  order: 2
---

## Mục tiêu

Sau bài này bạn **làm được**:

- Bật pipeline: `flutter_localizations` + `intl: any` +
  `generate: true` trong `pubspec.yaml`, cấu hình `l10n.yaml`.
- Viết file ARB: `@@locale`, cặp `"key": "value"`, khối `"@key"`
  khai báo placeholder `{level}`/`{base}`, escape `''` cho nháy đơn.
- Chạy `flutter gen-l10n`, đọc code nó sinh ra ở `lib/l10n/` —
  getter cho key thường, method có tham số cho placeholder.

## Bạn đang ở đâu

- M17 bài 2/5. Bài 1 là mental model; bài này **dựng pipeline**: sau
  bài này `AppLocalizations` tồn tại trong project, nhưng chưa màn
  nào gọi nó → app chạy y hệt cũ.
- Bài 3 mới nối `MaterialApp.locale` vào settings stream; bài 4 mới
  dời từng chuỗi sang `l10n.*`.

## Vì sao việc này quan trọng ngay bây giờ

Pipeline phải đứng trước khi code dùng nó. Tách "setup" thành bài
riêng để lỗi (nếu có) chỉ nằm trong một chỗ: file cấu hình hoặc cú
pháp ARB. Làm ồ ạt cả setup lẫn migration thì khi `gen-l10n` lỗi bạn
không biết lỗi ở đâu.

## Bạn đã biết gì

- `pubspec.yaml` + `flutter pub get` (từ M01) — thêm dependency.
- JSON + `Map` literal (M10) — ARB là JSON có quy ước thêm.
- `UserSettingsData.languageCode` (M14/M16) — sẽ là đầu vào của
  `MaterialApp.locale` ở bài 3.
- **Chưa biết** (bài này dạy): cú pháp ARB + `@key` metadata,
  `gen-l10n`, file generated.

## Dart / Flutter cần dùng

- `flutter_localizations` — package SDK chứa delegates cho
  `MaterialApp`/`Cupertino`/`Widgets` (ngày-tháng, text direction,
  widget mặc định theo locale). `sdk: flutter` = đi kèm SDK, không
  cần version.
- `intl` — package generated code `import` vào (để format
  placeholder/ngày). `intl: any`: để `flutter_localizations` tự pin
  version — y hệt senior, tránh xung đột version khi bump SDK.
- `generate: true` — bảo Flutter tool chạy gen-l10n mỗi lần
  `pub get`/build, tự đồng bộ code với ARB.
- `l10n.yaml` — file cấu hình riêng của gen-l10n.

## Ví dụ độc lập — cú pháp ARB tối thiểu

```jsonc
// app_en.arb
{
  "@@locale": "en",
  "appTitle": "AI Millionaire",
  "profileLevel": "LEVEL {level}",
  "@profileLevel": {
    "placeholders": { "level": { "type": "int" } }
  },
  "wrongAnswerBody": "The answer wasn''t right.\n{base}",
  "@wrongAnswerBody": {
    "placeholders": { "base": { "type": "String" } }
  }
}
```

- `@@locale` — file này thuộc locale nào (bắt buộc).
- `"profileLevel": "LEVEL {level}"` — `{level}` là placeholder;
  block `"@profileLevel"` khai báo nó là `int` → gen ra
  `String profileLevel(int level)` — gọi `l10n.profileLevel(3)`.
- `''` — ARB escape cho nháy đơn (`use-escaping: true`); `wasn''t`
  render thành `wasn't`.
- `\n` — xuống dòng như chuỗi thường.
- Key viết ở file en *nhưng thiếu* ở vi → vi rớt về bản en (template
  fallback) — không crash.

## Android / Compose bridge

- `values/strings.xml` ↔ `app_en.arb`; `values-vi/strings.xml` ↔
  `app_vi.arb`. Khác biệt: Android fallback theo *resource qualifier*
  tự động; ở đây gen-l10n tự sinh class fallback theo template `en`.
- `<string name="x">` ↔ `"x": "..."`; `<xliff:g>`/format-args ↔
  `{placeholder}` + `@key`.
- `R.string` generated ↔ `AppLocalizations` generated — cùng ý tưởng
  "id → code type-safe".

## Senior project connection

File `l10n.yaml` của learner **nội dung y hệt** senior:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-dir: lib/l10n
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
use-escaping: true
```

- `template-arb-file: app_en.arb` — en là mẫu; thiếu key ở vi → en.
- `nullable-getter: false` — `AppLocalizations.of(context)` trả
  non-null hoặc ném lỗi (an toàn hơn `!` rải rác).
- `use-escaping: true` — bật escape `''`.

Senior `app_en.arb` có 119 keys; learner 48 — chỉ đủ cho surface đã
có (M18+ sẽ thêm onboarding/auth/leaderboard keys khi màn tương ứng
đến).

## Build it step by step

### Bước 1 — `pubspec.yaml`: thêm deps + bật generate

Trong khối `dependencies:` thêm `flutter_localizations` và `intl`
(ngay dòng trên `provider` cho gọn), và trong khối `flutter:` cuối
file thêm `generate: true`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  # gen-l10n cần intl trực tiếp (generated code import package:intl).
  # `intl: any` y hệt senior — flutter_localizations tự pin version.
  intl: any
  provider: ^6.1.5+1
  # ... giữ nguyên phần còn lại

flutter:
  uses-material-design: true
  generate: true
```

### Bước 2 — `l10n.yaml`: cấu hình pipeline

Tạo `l10n.yaml` ở **gốc package** (cùng tầng `pubspec.yaml`), nội
dung y hệt senior:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-dir: lib/l10n
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
use-escaping: true
```

### Bước 3 — `lib/l10n/app_en.arb`: template (48 keys)

Tạo `lib/l10n/app_en.arb` — **file đầy đủ**:

```json
{
  "@@locale": "en",
  "appTitle": "AI Millionaire",
  "settingsSemanticLabel": "Settings",

  "startGameButton": "START GAME",
  "resetProfileButton": "RESET PROFILE",
  "profileLevel": "LEVEL {level}",
  "@profileLevel": {
    "placeholders": { "level": { "type": "int" } }
  },
  "menuExpProgress": "{exp} / {maxExp} EXP",
  "@menuExpProgress": {
    "placeholders": {
      "exp": { "type": "int" },
      "maxExp": { "type": "int" }
    }
  },
  "totalEarningsLabel": "TOTAL EARNINGS",
  "leaderboardTitle": "Leaderboard",
  "leaderboardSubtitle": "Top 10 players",
  "gamesJoinedLabel": "Played",
  "gamesWonLabel": "Won",
  "menuWinRateLabel": "Win rate",

  "gameRoomTitle": "Game Room",
  "questionCounter": "Question {index}/{count}",
  "@questionCounter": {
    "placeholders": {
      "index": { "type": "int" },
      "count": { "type": "int" }
    }
  },
  "secondsRemaining": "{seconds}s",
  "@secondsRemaining": {
    "placeholders": { "seconds": { "type": "int" } }
  },
  "submitAnswerButton": "LOCK ANSWER",
  "nextButton": "NEXT",
  "seeResultButton": "SEE RESULT",
  "correctFeedback": "Correct!",
  "wrongFeedback": "Not quite — the correct answer is highlighted.",
  "victoryTitle": "VICTORY!",
  "timeoutTitle": "TIME IS UP!",
  "gameOverTitle": "GAME OVER",
  "correctCountBase": "Correct {correct}/{total} questions",
  "@correctCountBase": {
    "placeholders": {
      "correct": { "type": "int" },
      "total": { "type": "int" }
    }
  },
  "victoryBody": "You answered everything right!\n{base}",
  "@victoryBody": {
    "placeholders": { "base": { "type": "String" } }
  },
  "timeoutBody": "You ran out of time.\n{base}",
  "@timeoutBody": {
    "placeholders": { "base": { "type": "String" } }
  },
  "wrongAnswerBody": "The answer wasn''t right.\n{base}",
  "@wrongAnswerBody": {
    "placeholders": { "base": { "type": "String" } }
  },
  "playAgainButton": "PLAY AGAIN",
  "menuButton": "MENU",

  "settingsTitle": "SETTINGS",
  "settingsSectionLanguage": "LANGUAGE",
  "settingsSectionAudio": "AUDIO",
  "settingsSectionNotifications": "NOTIFICATIONS",
  "settingsSectionAccount": "ACCOUNT",
  "doneButton": "DONE",
  "notificationTimeTitle": "NOTIFICATION TIME",
  "confirmButton": "CONFIRM",
  "cancelButton": "CANCEL",
  "settingsLoadErrorMessage": "Unable to load settings",
  "settingsUpdateErrorMessage": "Unable to update settings",
  "settingsNotificationTimeUpdateErrorMessage": "Unable to update notification time",
  "settingsGuestSyncHint": "Sign in to sync progress & join the leaderboard",
  "soundSetting": "Sound",
  "musicSetting": "Music",
  "hapticSetting": "Haptic Feedback",
  "notificationsSetting": "Notifications",
  "notificationTimeSetting": "Notification Time",
  "settingsNotificationsHint": "Once a day"
}
```

> 31 trong 48 keys trùng tên với senior; 17 keys learner tự đặt cho
> phần chrome senior không localize (nút CHỐT ĐÁP ÁN…).

### Bước 4 — `lib/l10n/app_vi.arb`: bản dịch Việt

Cùng **đúng 48 key**; các block `@key` metadata được copy y nguyên
từ template. gen-l10n chỉ *bắt buộc* metadata ở template — `app_vi.arb`
của senior không mang block `@key` nào; learner giữ chúng là lựa chọn
đối xứng (gen-l10n chấp nhận cả hai cách), không phải parity claim.
Giá trị = đúng chữ app đang hiển thị:

```json
{
  "@@locale": "vi",
  "appTitle": "AI Millionaire",
  "settingsSemanticLabel": "Cài đặt",

  "startGameButton": "BẮT ĐẦU CHƠI",
  "resetProfileButton": "ĐẶT LẠI HỒ SƠ",
  "profileLevel": "CẤP {level}",
  "@profileLevel": {
    "placeholders": { "level": { "type": "int" } }
  },
  "menuExpProgress": "{exp} / {maxExp} EXP",
  "@menuExpProgress": {
    "placeholders": {
      "exp": { "type": "int" },
      "maxExp": { "type": "int" }
    }
  },
  "totalEarningsLabel": "TỔNG THƯỞNG",
  "leaderboardTitle": "Bảng xếp hạng",
  "leaderboardSubtitle": "Top 10 người chơi",
  "gamesJoinedLabel": "Đã chơi",
  "gamesWonLabel": "Thắng",
  "menuWinRateLabel": "Tỉ lệ thắng",

  "gameRoomTitle": "Phòng chơi",
  "questionCounter": "Câu {index}/{count}",
  "@questionCounter": {
    "placeholders": {
      "index": { "type": "int" },
      "count": { "type": "int" }
    }
  },
  "secondsRemaining": "{seconds}s",
  "@secondsRemaining": {
    "placeholders": { "seconds": { "type": "int" } }
  },
  "submitAnswerButton": "CHỐT ĐÁP ÁN",
  "nextButton": "TIẾP",
  "seeResultButton": "XEM KẾT QUẢ",
  "correctFeedback": "Chính xác!",
  "wrongFeedback": "Chưa đúng — đáp án đúng tô màu xanh.",
  "victoryTitle": "CHIẾN THẮNG!",
  "timeoutTitle": "HẾT GIỜ!",
  "gameOverTitle": "KẾT THÚC",
  "correctCountBase": "Đúng {correct}/{total} câu",
  "@correctCountBase": {
    "placeholders": {
      "correct": { "type": "int" },
      "total": { "type": "int" }
    }
  },
  "victoryBody": "Bạn trả lời đúng tất cả!\n{base}",
  "@victoryBody": {
    "placeholders": { "base": { "type": "String" } }
  },
  "timeoutBody": "Hết thời gian trả lời.\n{base}",
  "@timeoutBody": {
    "placeholders": { "base": { "type": "String" } }
  },
  "wrongAnswerBody": "Đáp án chưa đúng.\n{base}",
  "@wrongAnswerBody": {
    "placeholders": { "base": { "type": "String" } }
  },
  "playAgainButton": "CHƠI LẠI",
  "menuButton": "VỀ MENU",

  "settingsTitle": "CÀI ĐẶT",
  "settingsSectionLanguage": "NGÔN NGỮ",
  "settingsSectionAudio": "ÂM THANH",
  "settingsSectionNotifications": "THÔNG BÁO",
  "settingsSectionAccount": "TÀI KHOẢN",
  "doneButton": "XONG",
  "notificationTimeTitle": "GIỜ THÔNG BÁO",
  "confirmButton": "XÁC NHẬN",
  "cancelButton": "HUỶ",
  "settingsLoadErrorMessage": "Không thể tải cài đặt",
  "settingsUpdateErrorMessage": "Không thể cập nhật cài đặt",
  "settingsNotificationTimeUpdateErrorMessage": "Không thể cập nhật giờ thông báo",
  "settingsGuestSyncHint": "Đăng nhập để đồng bộ tiến trình & lên bảng xếp hạng",
  "soundSetting": "Âm thanh",
  "musicSetting": "Nhạc nền",
  "hapticSetting": "Rung",
  "notificationsSetting": "Thông báo",
  "notificationTimeSetting": "Giờ thông báo",
  "settingsNotificationsHint": "Mỗi ngày một lần"
}
```

### Bước 5 — generate + kiểm

```bash
flutter pub get
flutter gen-l10n
```

`gen-l10n` sinh vào `lib/l10n/`:

- `app_localizations.dart` — class cha `AppLocalizations`: danh sách
  `supportedLocales`, `localizationsDelegates` (gồm delegate của app
  + `GlobalMaterialLocalizations.delegate`…), hàm `of(context)` và
  `lookupAppLocalizations` chọn subclass theo locale.
- `app_localizations_en.dart` — `AppLocalizationsEn`: getter trả
  `'START GAME'`…, method `String profileLevel(int level) =>
  'LEVEL $level'` (dùng intl).
- `app_localizations_vi.dart` — `AppLocalizationsVi` y hệt, giá trị
  tiếng Việt.

Mở `app_localizations.dart` đọc qua — **đừng sửa**: mọi thay đổi phải
đi qua ARB + regenerate. (Khoá học commit luôn file generated giống
senior để `flutter test`/`build` chạy được kể cả khi quên gen.)

## Hiểu code — gen ra cái gì

- Key thường → `String get appTitle => 'AI Millionaire';`
- Key có placeholder → method:
  `String questionCounter(int index, int count) =>
  'Question $index/$count';` — gọi `l10n.questionCounter(3, 15)`.
- `AppLocalizations.of(context)` = `Localizations.of<AppLocalizations>
  (context, AppLocalizations)!` — tra widget tổ tiên; **không có
  delegates phía trên → ném lỗi** (nullable-getter: false nên `!`).

## Chạy và quan sát

```bash
flutter analyze   # sạch — generated code hợp lệ
flutter test      # vẫn 87/87 — CHƯA ai gọi l10n, app chạy như cũ
flutter run       # UI vẫn hiện literal cũ — bình thường, bài 4 mới đổi
```

App chạy **y hệt** như trước là đúng: pipeline tồn tại nhưng chưa
có consumer. Đừng hoảng khi không thấy gì đổi.

## Thử nghiệm

- Sửa `appTitle` trong `app_vi.arb` → `flutter gen-l10n` → mở
  `app_localizations_vi.dart` xem getter đổi chưa.
- Thêm key ở en nhưng quên thêm ở vi → `gen-l10n` vẫn OK; class vi
  sẽ kế thừa fallback en — kiểm bằng mắt trong file generated.

## Lỗi hay gặp

- `gen-l10n` báo lỗi JSON → thiếu dấu phẩy/phảy thừa ở ARB (JSON
  không cho trailing comma).
- `placeholder "x" not declared` — dùng `{x}` trong value nhưng quên
  `"@key"` block ở template.
- `''` quên escape → gen-l10n ăn mất một nháy: `wasn't` viết trong
  ARB phải là `wasn''t`.
- Tạo `l10n.yaml` trong `lib/` → tool không thấy; nó nằm **gốc
  package**.

## Tự làm — một key mới, từ quyết định tới generated code

Bạn sắp cần key cho thanh tiến trình (milestone sau): chuỗi dạng
`"LEVEL {level} · {exp} XP"`. **Đừng copy** — tự quyết:

**Phần A — dự đoán trước khi gen.** Viết ra giấy:

1. Tên key bạn chọn (camelCase, mô tả *vai trò* chứ không phải nội
   dung — vì sao `levelProgress` tốt hơn `levelXxp`?)
2. Signature Dart mà gen-l10n sẽ sinh — kiểu trả về, tham số, thứ tự.
3. Câu gọi ở widget: `l10n.???`

**Phần B — viết cặp ARB + gen.** Thêm entry vào `app_en.arb` (kèm
`@key` với hai placeholders `int`) và `app_vi.arb` — **thứ tự
placeholder trong câu vi có được đổi không?** (thử `"Cấp {level} —
{exp} kinh nghiệm"`). Chạy `flutter gen-l10n` → exit 0 → mở file
generated kiểm chứng signature bạn dự đoán.

**Phần C — chẩn đoán.** Cố tình đổi `app_vi.arb` để placeholder
khác tên en (`{exp}` → `{diem}`). Chạy `flutter gen-l10n` — đọc
thông báo lỗi, sửa lại, gen lại exit 0. Đây là triệu chứng bạn sẽ
gặp khi đồng bộ hai file.

<details><summary>Đáp án</summary>

1. `levelProgress` — key đặt theo vai trò sống được khi text đổi;
   `levelXxp` gắn vào nội dung cụ thể nên bẻ key mỗi lần đổi chữ.
2. `String levelProgress(int level, int exp)` — key có placeholder
   gen ra **method** (không phải getter); tham số theo thứ tự khai
   báo trong `placeholders`.
3. `l10n.levelProgress(4, 1250)`.
4. Thứ tự placeholder trong value của *từng file* tự do — chỉ tên
   phải khớp en template; `{diem}` khác tên là lỗi gen-l10n.

</details>

## Kiểm tra hiểu biết

1. `template-arb-file` nghĩa là gì — chuyện gì xảy ra nếu vi thiếu
   một key?
2. `@profileLevel` khai báo gì? Nếu bỏ nó, code gọi
   `l10n.profileLevel(3)` còn compile không?
3. Vì sao `intl: any` thay vì pin `^0.20.2`?
4. Vì sao sau khi gen xong app vẫn hiển thị chữ cũ?

## Ta cố ý chưa thêm

- **`@@locale` cấu hình trong yaml** (`untranslated-messages-file`,
  `synthetic-package`, `format`, `header`…) — senior không dùng; mặc
  định đủ.
- **ICU plural/select** — nhắc ở bài 1; M17 không cần.
- **`AppLocalizations.delegate` custom** — gen-l10n tự tạo; không
  viết tay.

## Checkpoint hoàn thành

- `flutter pub get` OK; `flutter gen-l10n` exit 0 và sinh 3 file
  `app_localizations*.dart` trong `lib/l10n/`.
- `flutter analyze` → `No issues found!`.
- `flutter test` → **87/87** (chưa đổi — hợp lệ).
- Mở `app_localizations_en.dart`, tìm `profileLevel` — thấy method
  có tham số `int level`.
