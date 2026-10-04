---
title: "Bài 1 · Vì sao không viết cứng chữ — từ literal tới resource"
description: "Localization là gì, vì sao chuỗi hardcode không scale; mental model ARB → gen-l10n → AppLocalizations → widget; fallback chain khi thiếu bản dịch. Bài lý thuyết — chưa sửa code."
sidebar:
  label: "Bài 1 · Vì sao bản địa hoá"
  order: 1
---

## Mục tiêu

Sau bài này bạn **hiểu được**:

- Vì sao `'BẮT ĐẦU CHƠI'` viết thẳng trong widget là nợ kỹ thuật:
  muốn thêm ngôn ngữ = phải đụng vào mọi file UI.
- Mô hình resource: chuỗi sống trong file `.arb` (JSON theo quy ước
  của Flutter), tool `gen-l10n` đọc ARB và **sinh class Dart**
  `AppLocalizations` — widget gọi `AppLocalizations.of(context).key`
  thay vì literal.
- Fallback chain: locale thiếu bản dịch → rớt về **template** (`en`);
  `languageCode` lạ → whitelist → `null` → theo hệ thống.

## Bạn đang ở đâu

- M17 bài 1/5 — bài lý thuyết, **chưa đụng code**.
- Tới M16 app hiển thị toàn tiếng Việt viết cứng: `'CÀI ĐẶT'` trong
  dialog, `'CHỐT ĐÁP ÁN'` trong game, `'LEVEL 3'` trên menu… M16 đã
  cho chọn `languageCode` và persist nó — nhưng nó **chưa làm gì**.
  M17 nối dây cuối: `languageCode` → `MaterialApp.locale` → chữ đổi.
- Senior app (AI Millionaire) có sẵn hạ tầng này: `lib/l10n/*.arb` +
  `AppLocalizations` generated + `MaterialApp.locale` đi theo settings
  stream. M17 tái dựng đúng đường đi đó.

## Vì sao việc này quan trọng ngay bây giờ

Thử nghĩ: thêm tiếng Anh cho app hiện tại *mà không* có l10n.

- Mỗi `'CÀI ĐẶT'` phải thành `isVi ? 'CÀI ĐẶT' : 'SETTINGS'` — rải
  khắp các file UI (4 file màn/dialog + chuỗi trong VM), mỗi key một nhánh ternary → code UI phình to, test
  phải cover cả hai nhánh.
- Chuỗi có biến như `'Câu 3/15'` còn tệ hơn: vị trí số trong câu
  **khác nhau theo ngôn ngữ** ('Question 3/15' vs 'Câu 3/15') —
  hardcode nối chuỗi không diễn tả được.
- Người dịch không đọc code Dart — họ cần một file chữ thuần.

Senior giải bằng **resource + codegen**: chuỗi là dữ liệu (ARB),
compiler sinh API gọi chúng. Đây là cách hầu hết app lớn làm — và là
cách duy nhất để `MaterialApp.locale` phát huy tác dụng.

## Bạn đã biết gì

- `languageCode` đã persist trong `UserSettingsData` qua repository
  stream (M14) — M16 đã có chip chọn ngôn ngữ ghi giá trị này.
- `SupportedLanguageData` — danh sách ngôn ngữ hỗ trợ + `fromCode`
  (model tạo ở M16/02).
- `MaterialApp` cấu hình app-level: `theme`, `home`… bài 3 sẽ thêm
  `locale`/`localizationsDelegates`/`supportedLocales`.
- `StreamBuilder` (M14) — rebuild khi stream emit.
- `InheritedWidget` lookup qua `context` (M12 — Provider là
  trường hợp riêng) — `AppLocalizations.of(context)` cùng họ hàng.

## Mental model mới — "chuỗi là resource, không phải code"

```
app_en.arb ─┐                     ┌─ AppLocalizations.of(context)
            ├─ flutter gen-l10n ─→│    .settingsTitle  → "SETTINGS"/"CÀI ĐẶT"
app_vi.arb ─┘   (đọc 2 file)      └─ MaterialApp.locale quyết định bản nào
```

Ba đối tượng mới:

1. **ARB** (Application Resource Bundle) — JSON có quy ước: mỗi key
   là một chuỗi; `@@locale` đánh dấu file này thuộc ngôn ngữ nào;
   `"@key"` kèm metadata (khai báo placeholder `{x}`).
2. **`AppLocalizations`** — class *Flutter tự sinh* từ ARB: mỗi key
   thành getter/method type-safe. Không viết tay, không sửa tay.
3. **`MaterialApp.locale` + delegates** — cơ chế Flutter chọn bản
   dịch: `supportedLocales` nói app hỗ trợ gì; `locale` ép ngôn ngữ
   hiện tại; `localizationsDelegates` dạy widget cách nạp resource.

> Mental model: giống `strings.xml` của Android — nhưng thay vì id
> số `R.string.x`, bạn được class Dart thật, gọi như method thường,
> autocomplete + compile-check đầy đủ.

## Android / Compose bridge

- `res/values/strings.xml` + `values-vi/strings.xml` ≈
  `app_en.arb` + `app_vi.arb`. Android chọn resource theo locale của
  máy; Flutter cho bạn tự lái bằng `MaterialApp.locale`.
- `context.getString(R.string.x)` ≈ `AppLocalizations.of(context).x`.
- Compose: `stringResource(R.string.x)` ≈ tương tự — cùng ý tưởng
  "tra chuỗi theo locale tại chỗ render".
- Điểm khác quan trọng: đổi `Locale` trong Android thường kéo theo
  `attachBaseContext`/`recreate()`; Flutter chỉ cần `MaterialApp`
  rebuild với `locale` mới — một rebuild bình thường.

## Senior project connection

Senior `lib/l10n/`:

- `app_en.arb` = **template** (mọi `@key` metadata khai báo ở đây),
  `app_vi.arb` cùng bộ key. Senior có ~119 keys; learner M17 bắt đầu
  48 keys — chỉ đủ cho surface hiện có (phần còn lại đến theo từng
   feature;
  các key khác sẽ được thêm khi màn tương ứng xuất hiện ở M18+).
- `l10n.yaml` khai báo thư mục ARB, file template, tên class sinh ra.
- `pubspec.yaml`: `flutter_localizations: sdk: flutter` +
  `intl: any` + `generate: true`.
- `main.dart`: `StreamBuilder` bọc `MaterialApp`, `locale` suy từ
  `userSettingsStream` — bài 3 tái dựng y hệt.
- Test senior `widget_test.dart` assert "app locale follows persisted
  language settings" — bài 5 tái dựng test này.

## Chạy và quan sát

Chưa có gì để chạy — bài này thuần mental model. Nếu muốn xem trước:

```bash
dir lib\l10n   # chưa tồn tại — bài 2 tạo
```

## Kiểm tra hiểu biết

1. Vì sao `'Câu ' + i.toString() + '/' + n.toString()` không thể
   bản địa hoá đúng? (gợi: vị trí biến trong câu)
2. File `.arb` là gì — code Dart hay dữ liệu? Ai đọc nó?
3. `AppLocalizations` là class viết tay hay sinh tự động? Sửa file
   generated được không?
4. Nếu `MaterialApp.locale = Locale('fr')` mà app không có
   `app_fr.arb` thì chuyện gì xảy ra?
5. Vì sao en được chọn làm *template* (chứa metadata `@key`)?

## Ta cố ý chưa thêm

- **ICU plural/select** (`{count, plural, =0{...} other{...}}`) — ARB
  hỗ trợ, senior hiện không dùng cho surface này; nhắc để bạn biết nó
  tồn tại, không dạy sâu.
- **RTL layout** (ar/he) — hai ngôn ngữ đều LTR.
- **Bản địa hoá ngày/số** (`DateFormat`, `NumberFormat`) — `intl`
  hỗ trợ; app hiện chưa hiển thị số theo định dạng locale.

## Checkpoint hoàn thành

Bài lý thuyết — không có thay đổi code. Tự kiểm: giải thích được cho
người khác pipeline `ARB → gen-l10n → AppLocalizations → of(context)`
và vì sao fallback về `en` khi thiếu bản dịch là an toàn.
