---
title: "Bài 2 · `sealed class` — tập đóng các variant"
description: "Dart 3 sealed class: luật cùng file, không khởi tạo base, khác abstract/enum, khi nào KHÔNG dùng. Ví dụ độc lập PaymentState."
sidebar:
  label: "Bài 2 · sealed class"
  order: 2
---

## Mục tiêu

Sau bài này bạn **viết được** một sealed hierarchy Dart 3 và **giải
thích được** bốn luật của nó: tập subtype đóng, subtype phải nằm cùng
file, base không khởi tạo trực tiếp, và sealed là nền của `switch`
kiệt hợp (bài 3).

## Bạn đang ở đâu

- Milestone: **M15** (bài 2/5).
- App chưa đổi gì — bài này dạy cú pháp Dart trên một **ví dụ độc
  lập**, rồi bài 4–5 mới đem vào app.

## Vì sao việc này quan trọng ngay bây giờ

Bài 1 đã thấy: tập state hợp lệ là *hữu hạn* nhưng `class`/`abstract
class` thường **mở** — ai cũng có thể `extends` thêm variant ở file
khác, nên compiler không thể biết "đã liệt kê hết chưa". `sealed` là
từ khoá Dart 3 biến tập subtype thành *đóng* — và đó là điều kiện để
compiler kiểm tra kiệt hợp ở bài 3.

## Bạn đã biết gì

- class, `extends`, `abstract class`, `final class` (M13/01),
  constructor `const` + `required` (M01–M02).
- `enum` là tập giá trị đóng không mang payload (M08).

## Mental model mới — "enum có payload"

Cách nhanh nhất để hình dung `sealed class`: **enum mà mỗi giá trị
là một class riêng, mang được field riêng**.

- enum `PaymentResult { success, failure }` → hai cái tên, không data.
- sealed `PaymentState` → `PaymentSuccess(transactionId)` và
  `PaymentFailure(error)` — mỗi variant là một class thật, field của
  riêng nó.

Giới hạn: sealed không tự chọn *khi nào* chuyển variant — đó là việc
của code gán state (bài 5). Nó chỉ đảm bảo *tập variant đóng*.

## Dart cần dùng / Dart mới

| Cú pháp | Ví dụ | Nghĩa |
| --------- | ------- | ------- |
| `sealed class X` | `sealed class PaymentState` | base của tập đóng; **không `new` được** — chỉ tồn tại để làm cha chung |
| `final class Y extends X` | `final class PaymentIdle extends PaymentState` | variant lá — `final` cấm người khác extends/implement thêm |
| cùng file | các subtype **phải** nằm trong file của `sealed class` | đây là luật làm tập *đóng* — compiler liệt kê hết được |

Bốn luật cần nhớ:

1. **Tập subtype đóng**: chỉ các lớp khai báo trong cùng file được là
   subtype trực tiếp. File khác `extends` → lỗi biên dịch.
2. **Base không khởi tạo**: `PaymentState()` — lỗi; `sealed` hàm ý
   "abstract có giám sát".
3. **`switch` kiệt hợp**: trên sealed, compiler biết hết variant —
   thiếu case = lỗi (bài 3 khai thác triệt để).
4. **Vẫn là kế thừa thường**: variant có field/method riêng, `is`/
   `as` hoạt động bình thường.

Khác `abstract class`: abstract cho phép subtype ở **mọi file** (tập
mở) — M13 dùng nó cho event vì lúc đó chưa cần kiệt hợp. Khác enum:
enum = giá trị không payload; sealed = class có payload.

**Khi KHÔNG dùng sealed**: tập variant thực sự mở (plugin, type do
package khác mở rộng), hoặc khi bạn chỉ cần một kiểu đơn — sealed có
chi phí "phải liệt kê hết", đừng trả nó cho thứ không cần.

## Flutter cần dùng

Không có API Flutter mới — `sealed` là cú pháp Dart thuần. Nó sẽ gặp
Flutter ở bài 5 khi state sealed quyết định widget nào render.

## Ví dụ độc lập — `PaymentState`

```dart
sealed class PaymentState {
  const PaymentState();
}

final class PaymentIdle extends PaymentState {
  const PaymentIdle();
}

final class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

final class PaymentSuccess extends PaymentState {
  const PaymentSuccess(this.transactionId);
  final String transactionId;
}

final class PaymentFailure extends PaymentState {
  const PaymentFailure(this.error);
  final String error;
}
```

Bốn variant: hai cái không payload (Idle, Processing), hai cái mang
payload. Chú ý `const` constructor ở mọi variant — state là dữ liệu
bất biến.

Thử viết `class Hacked extends PaymentState {}` **ở file khác** →
compiler báo lỗi. Đó là luật cùng-file bảo vệ tập đóng.

## Android / Compose bridge

- **SIMILARITY**: Kotlin `sealed class` — tập subtype đóng + `when`
  kiệt hợp. Ý tưởng 1:1.
- **IMPORTANT DIFFERENCE**: Dart bắt buộc subtype **cùng file**
  (Kotlin cho phép cùng package/module). Và Dart sealed mở khoá
  *pattern matching* — `switch` expression với `(:final field)` —
  mạnh hơn `is`-check của Kotlin ở chỗ bóc dữ liệu ngay trong `case`
  (bài 3).
- **DO NOT ASSUME**: đã hiểu Kotlin sealed thì "bỏ qua" phần syntax
  Dart — điểm kiếm điểm của M15 nằm ở Dart 3 patterns, không phải ở
  tương đương tư tưởng.

## Senior project connection

- `lib/view_models/menu/menu_screen_ui_event.dart`: `sealed class
  MenuScreenUiEvent` + `final class MenuGameRequested` /
  `MenuSnackBarRequested(this.message)` — y hệt shape PaymentState:
  base không-payload-được, variant mang payload khi cần.
- `lib/data/game/game_session_state_data.dart`: `sealed class
  GameDialogState` + 9 variant (bản learner M15 giữ 3 — đủ cho UX
  hiện có).

## Build it step by step

Không đổi app trong bài này. Đọc kỹ ví dụ `PaymentState`, tự hỏi:
tại sao `PaymentState()` không khởi tạo được? Vì sao tôi không thêm
variant ở file khác được?

## Hiểu code

Đọc lại `PaymentState` ở trên theo 4 câu hỏi:

1. `PaymentState()` viết ở đâu được? — **không đâu**: sealed base
   không khởi tạo.
2. `PaymentSuccess` khác `PaymentIdle` ở gì? — variant mang payload
   (`transactionId`) vs variant marker.
3. Nếu bỏ `final` khỏi `final class PaymentIdle`? — vẫn hợp lệ nhưng
   ai cũng `extends PaymentIdle` được → variant không còn "lá".
4. Constructor có gì lạ? — `const` ở mọi variant: state là dữ liệu
   bất biến, `const PaymentIdle()` tạo singleton compile-time.

## Chạy và quan sát

`flutter analyze` — vẫn sạch (chưa sửa gì). Demo lỗi kiệt hợp nằm ở
**bài 3** — khi đã có `switch` để compiler kiểm tra.

## Thử nghiệm

PREDICT trước rồi mới làm: viết `PaymentState s = PaymentIdle();` —
compile được không? → Có (assign variant lên kiểu base là bình
thường). Rồi thử `PaymentState s = PaymentState();` → **lỗi** —
sealed base không khởi tạo. Hai thử nghiệm tách "không new được base"
khỏi "không gán được variant".

## Lỗi hay gặp

- **Đặt variant ở file khác** → `illegal_use_of_sealed…`/subtype
  error — nhớ luật cùng-file.
- **`sealed` khi tập thực sự mở** — ví dụ loại do plugin mở rộng:
  sealed sẽ cản mở rộng đúng-là-nên-có.
- **Bỏ `const` constructor** — state class nên immutable; quên
  `const` không lỗi nhưng mất khả năng `const`-hoá.

## Tự làm

**Sản xuất** — không phải copy: viết một sealed hierarchy mới cho
domain *trạng thái kết nối*:

```dart
sealed class ConnectionState { ... }
// Variant: ConnectionOffline, ConnectionConnecting(mang retries:int),
// ConnectionOnline
```

:::note[Gợi ý]
`ConnectionConnecting(this.retries)` + `final int retries;` — y hệt
`PaymentSuccess`.
:::

<details><summary>Đáp án</summary>

```dart
sealed class ConnectionState {
  const ConnectionState();
}

final class ConnectionOffline extends ConnectionState {
  const ConnectionOffline();
}

final class ConnectionConnecting extends ConnectionState {
  const ConnectionConnecting(this.retries);
  final int retries;
}

final class ConnectionOnline extends ConnectionState {
  const ConnectionOnline();
}
```

</details>

## Kiểm tra hiểu biết

1. Vì sao `sealed` bắt buộc subtype cùng file?
2. `sealed` khác `abstract` ở điểm nào? Khi nào `abstract` vẫn đúng
   hơn?
3. Vì sao sealed hợp "một trong vài state UI hữu hạn" hơn enum?

<details><summary>Đáp án</summary>

1. Cùng-file là cách compiler *liệt kê hết* subtype — điều kiện của
   kiệt hợp.
2. `abstract` = tập mở (subtype ở mọi file, không kiệt hợp); sealed =
   tập đóng. Vẫn dùng `abstract` khi thiết kế cho mở rộng.
3. Variant mang payload riêng; enum chỉ là tên.

</details>

## Ta cố ý chưa thêm

- `switch` expression + patterns — **bài 3 ngay sau**.
- `MenuDialogState`/`GameScreenUiEvent` — consumer chưa tồn tại.

## Checkpoint hoàn thành

- [ ] Tự làm `ConnectionState` viết được mà không nhìn đáp án.
- [ ] Giải thích được luật cùng-file là nền của kiệt hợp.

## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — ví dụ `PaymentState`/`ConnectionState` là Dart độc lập (scratch), chưa áp dụng vào app. Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, hỏi AI local: *"Viết một sealed class `ConnectionState` với 3 variant (offline, connecting kèm `retries`, online) — nhớ luật cùng file, base không khởi tạo, `const` ctor, `final class` cho variant lá."* — đối chiếu với đáp án trong bài.

Checkpoint code sang bài sau: project không đổi so với cuối M14 — `MenuUiEvent` vẫn `abstract`, `_endReason` vẫn enum nullable. Đừng áp dụng sealed vào app sớm — đó là nội dung bài 4–5.
