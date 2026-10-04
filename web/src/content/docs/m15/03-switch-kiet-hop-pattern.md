---
title: "Bài 3 · `switch` kiệt hợp + object patterns — bóc payload ngay trong case"
description: "switch expression trên sealed; pattern `Type()`; destructure `(:final field)`; wildcard `_`; exhaustiveness là lỗi biên dịch."
sidebar:
  label: "Bài 3 · switch kiệt hợp + patterns"
  order: 3
---

## Mục tiêu

Sau bài này bạn **đọc và viết được** `switch` *expression* trên một
sealed class, **bóc được** field của variant bằng object pattern
`Type(:final field)`, và **dự đoán được** lỗi biên dịch khi switch
không kiệt hợp.

## Bạn đang ở đâu

- Milestone: **M15** (bài 3/5). Vẫn trên ví dụ `PaymentState` của
  bài 2 — chưa đụng app.

## Vì sao việc này quan trọng ngay bây giờ

Sealed chỉ trả nợ một nửa: nó *đóng tập*. Nửa còn lại — *xử lý đủ
tập* — nằm ở `switch`. Đây là điểm Dart 3 vượt `is`-chain của M13:
thiếu case không còn là "nhánh `else` rơi xuống âm thầm" mà là **lỗi
biên dịch**. Trong một codebase nhiều dialog/variant như app senior,
đó là sự khác giữa "thêm variant xong quên một chỗ xử lý" và
"compiler chỉ thẳng mặt bạn".

## Bạn đã biết gì

- `switch` **statement** trên enum (M09) — cú pháp `case X: … break/return`.
- `is` type check (M13).
- Sealed class + variant + payload (bài 2).

## Mental model mới — "pattern = câu hỏi hình dạng"

`case` trong Dart 3 không còn là "so sánh bằng" như M09 — nó là
**pattern**: một câu hỏi về *hình dạng* của giá trị. `case
PaymentSuccess(:final id)` đọc là: *"có phải một PaymentSuccess
không? nếu có, bóc `transactionId` ra gọi là `id`"*.

Pattern có 3 mức ta dùng trong M15:

1. `Type()` — "có phải variant này không" (không cần payload).
2. `Type(:final f)` — "có phải variant này không **và** bóc field `f`".
3. `_` — wildcard: "mọi thứ còn lại".

## Dart cần dùng / Dart mới

| Cú pháp | Ví dụ | Nghĩa |
| --------- | ------- | ------- |
| `switch` expression | `final x = switch (v) { A() => 1, … };` | switch **trả về giá trị** — mọi nhánh phải `=> expr` |
| object pattern | `PaymentSuccess(:final transactionId)` | match type + **bóc field cùng tên** thành biến `transactionId` dùng ngay trong nhánh |
| rename pattern | `(transactionId: final id)` | bóc field `transactionId` nhưng đặt tên biến `id` |
| wildcard | `_ => 'default'` | bắt phần còn lại — như `default` nhưng *vẫn* kiệt hợp khi đặt cuối |
| switch statement | `switch (e) { case A(): …; case B(): … }` | không `break` trong Dart 3 — nhánh không rơi qua |

**Exhaustiveness**: trên sealed class, `switch` expression *bắt buộc*
đủ mọi variant — thiếu = `non_exhaustive_switch_expression`, code
không biên dịch. Với wildcard `_` cuối cùng, mọi variant chưa liệt kê
rơi vào `_` — vẫn kiệt hợp nhưng bạn mất "compiler bắt thêm case khi
thêm variant" ở nhánh đó.

`runtimeType` (chỉ *awareness*): senior dùng `ValueKey(state.runtimeType)`
làm key transition cho dialog layer (M21). Ta **không** dùng nó trong
learner M15 — ghi nhận là "kiểu runtime của object" để đọc senior.

## Flutter cần dùng

Không có API Flutter mới — patterns là cú pháp Dart. Ứng dụng vào
widget tree nằm ở bài 5.

## Ví dụ độc lập — xử lý `PaymentState`

```dart
String label(PaymentState s) {
  return switch (s) {
    PaymentIdle() => 'Chờ thao tác',
    PaymentProcessing() => 'Đang xử lý…',
    PaymentSuccess(:final transactionId) => 'Xong: $transactionId',
    PaymentFailure(:final error) => 'Lỗi: $error',
  };
}
```

Đọc nhánh 3: `PaymentSuccess(:final transactionId)` — *match
PaymentSuccess và bóc `transactionId` ra dùng ngay*. Không cần
`(s as PaymentSuccess).transactionId`.

## Hiểu code

Đọc `label` theo từng dòng:

1. `switch (s)` — `s` có kiểu base `PaymentState`; compiler liệt kê
   được đủ subtype vì tập đóng.
2. `PaymentIdle() => 'Chờ thao tác'` — pattern `Type()` chỉ hỏi
   "có phải variant này"; không bóc gì vì variant không payload.
3. `PaymentSuccess(:final transactionId) => …` — object pattern:
   match type **và** khai báo biến `transactionId` gán field cùng tên;
   scope của `transactionId` là nhánh đó thôi.
4. Không `break`, không `default` — expression: mỗi nhánh trả giá
   trị; đủ variant = compile, thiếu = lỗi.

## Thử nghiệm (PREDICT)

Xoá nhánh `PaymentFailure` rồi đoán kết quả **trước** khi chạy:

- Compiler nói gì? → `The type 'PaymentState' isn't exhaustively
  matched … doesn't match 'PaymentFailure()'`
  (`non_exhaustive_switch_expression`).
- Đây là *lỗi*, không phải warning — code không biên dịch. Đó chính
  là "compiler bắt tay bạn" mà `is`-chain không bao giờ làm.

## Android / Compose bridge

- **SIMILARITY**: Kotlin `when` trên sealed cũng kiệt hợp.
- **IMPORTANT DIFFERENCE**: Dart pattern `(:final f)` bóc field
  *ngay trong case* — Kotlin phải `s as Success` rồi đọc field. Và
  Dart 3 không cần `break`; không-fall-through là mặc định.

## Senior project connection

- `lib/screens/menu_screen.dart::_handleUiEvent`: switch statement
  `case MenuGameRequested(): / case MenuSnackBarRequested(:final
  message):` — y hệt lesson.
- `lib/widgets/game/dialogs/game_dialog_layer.dart::_dialogBody`:
  `switch (dialog)` expression trả widget cho 9 variant + `ValueKey
  (dialog.runtimeType)` — `runtimeType` chỉ là "kiểu lúc chạy" làm
  key; cơ chế layer là M21.

## Build it step by step

Vẫn không đổi app. Gõ lại `label(PaymentState)` bằng tay (không copy),
xong thử trả lời: nếu sau này thêm variant `PaymentRefunded`, compiler
sẽ bắt bạn sửa **ở đâu**? — ở mọi `switch` expression kiệt hợp trên
`PaymentState`.

## Chạy và quan sát

Nếu đã tạo file scratch `PaymentState` ở bài 2, bây giờ viết `label()`
vào và xoá-thử một case — bạn sẽ thấy `non_exhaustive_switch_expression`
thật. (Bản app sẽ demo điều này trong test ở bài 5.)

## Lỗi hay gặp

- **`(:final f)` tưởng là đổi tên** — pattern bóc field *cùng tên*;
  `(field: final tenKhac)` mới đổi.
- **`default:` quen cũ** — trên sealed, wildcard `_` cuối vẫn kiệt
  hợp; nhưng *bỏ sót variant* khi không có `_` mới là điểm compiler
  giúp — đừng vội thêm `_` để "cho yên" mà mất cảnh báo.
- **Nhầm switch statement vs expression** — statement: `case X():
  hành động` (không trả giá trị); expression: `X() => giá trị`
  (phải có trong mọi nhánh).

## Tự làm

**Sản xuất** — với `ConnectionState` bạn đã viết ở bài 2, viết:

```dart
String describe(ConnectionState s) => switch (s) { … };
// Offline → "Mất mạng"; Connecting → "Đang thử lần $retries";
// Online → "Đã kết nối"
```

:::note[Gợi ý]
`ConnectionConnecting(:final retries) => 'Đang thử lần $retries'`.
:::

<details><summary>Đáp án</summary>

```dart
String describe(ConnectionState s) {
  return switch (s) {
    ConnectionOffline() => 'Mất mạng',
    ConnectionConnecting(:final retries) => 'Đang thử lần $retries',
    ConnectionOnline() => 'Đã kết nối',
  };
}
```

</details>

## Kiểm tra hiểu biết

1. `switch` expression khác statement ở đâu?
2. `(:final field)` làm gì mà `is` + cast không làm ngay được?
3. Wildcard `_` có phá kiệt hợp không? Cái giá của nó là gì?
4. Vì sao bỏ `default`/`_` lúc đầu lại *an toàn hơn*?

<details><summary>Đáp án</summary>

1. Expression trả về giá trị (`=>`), statement chỉ chạy code.
2. Bóc field trong chính pattern — khỏi cast, khỏi đọc lại field.
3. Không phá — vẫn kiệt hợp; nhưng variant mới thêm sau này sẽ rơi
   vào `_` thay vì báo lỗi.
4. Vì khi thêm variant, chỗ thiếu case trở thành *compile error* —
   compiler là checklist miễn phí.

</details>

## Ta cố ý chưa thêm

- `ValueKey(runtimeType)` + `AnimatedSwitcher` + in-`Stack` layer —
  **M21**.
- Guard pattern `when` / patterns phức tạp khác — chưa cần.

## Checkpoint hoàn thành

- [ ] Viết được `describe()` exhaustive không nhìn đáp án.
- [ ] Nói trước được error message khi xoá một case.
