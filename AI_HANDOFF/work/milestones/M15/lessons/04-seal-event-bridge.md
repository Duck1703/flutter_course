---
title: "Bài 4 · Seal hoá event bridge — MenuUiEvent → MenuScreenUiEvent"
description: "Áp dụng sealed + exhaustive switch vào event family của M13; FR-15 converge. File đổi tên theo senior; `is`-chain → switch kiệt hợp."
sidebar:
  label: "Bài 4 · seal event bridge"
  order: 4
---

## Mục tiêu

Sau bài này bạn **áp dụng được** `sealed class` + exhaustive `switch`
vào một event family thật: đổi `abstract class MenuUiEvent` thành
`sealed class MenuScreenUiEvent` (đúng tên senior) và viết lại cầu nối
`_handleUiEvent` bằng switch statement kiệt hợp.

## Bạn đang ở đâu

- Milestone: **M15** (bài 4/5) — **bài đầu tiên sửa code app**.
- Vào bài: `MenuUiEvent` là `abstract class` (M13); `_handleUiEvent`
  dùng `if (event is …) else if`.
- Ra bài: event family sealed + bridge là `switch` kiệt hợp — hợp
  senior 1:1 (đây là đóng register **FR-15**).

## Vì sao việc này quan trọng ngay bây giờ

`is`-chain của M13 có một nhược điểm âm thầm: thêm event mới vào
`MenuUiEvent` mà quên sửa `_handleUiEvent` → event ấy **rơi qua cả
chuỗi, không ai xử lý, không ai báo**. Sau khi sealed: cùng quên đó
là **lỗi biên dịch** tại `_handleUiEvent`. Đây là nâng cấp của M13 —
không phải sửa lỗi; M13 dùng `abstract` là cố ý đơn giản cho lúc đó.

## Bạn đã biết gì

- UI event một-lần + broadcast stream + bridge (M13 — `A-05`).
- `sealed class` + object pattern (bài 2–3 của milestone này).
- `unawaited` (M11): đánh dấu discard-async chủ đích.

## Mental model — event vẫn là event

Đổi `abstract` → `sealed` **không làm event thành state**. Bản chất
M13 giữ nguyên: `MenuScreenUiEvent` vẫn là "việc vừa xảy ra" (bấm nút
→ điều hướng/snackbar), không phải "UI đang hiển thị gì". Sealed chỉ
đóng *tập loại event* — tương tự state đóng nhưng dùng cho sự kiện.

Điểm này là reinforcement quan trọng của A-05: **cả event lẫn state
đều có thể là sealed hierarchy** — sealed là tính chất *của tập kiểu*,
không phải của vai trò state/event.

## Dart cần dùng

Không có syntax mới — bài này là **áp dụng** bài 2–3 vào code thật.

## Flutter cần dùng

Không có widget/API mới — `SnackBar`/`ScaffoldMessenger` đã học M13;
`unawaited` đã học M11. Chỉ có *cấu trúc dispatch* của bridge đổi.

## Ví dụ độc lập

Đã có (PaymentState) — bài này chuyển thẳng sang production vì shape
identical.

## Android / Compose bridge

- **SIMILARITY**: Kotlin `sealed class` + `when` cho event channel.
- **DO NOT ASSUME**: rename là "đổi cho giống senior thôi" — đúng là
  convergence, nhưng điểm mấu chốt là `sealed` bật kiệt hợp, tên chỉ
  là phần thưởng.

## Senior project connection

- `lib/view_models/menu/menu_screen_ui_event.dart` — sealed +
  `final class` variants, tên `MenuScreenUiEvent` chính xác.
- `lib/screens/menu_screen.dart::_handleUiEvent` — switch statement
  `case MenuGameRequested(): / case MenuSnackBarRequested(:final
  message):` — bản learner sao chép shape này nguyên vẹn.

## Build it step by step

Bốn file đổi **cùng lúc** (atomic — sửa lẻ sẽ không compile):

**Bước 1** — đổi tên file `lib/view_models/menu/menu_ui_event.dart`
→ `menu_screen_ui_event.dart`, rồi viết lại nội dung:

```dart
sealed class MenuScreenUiEvent {
  const MenuScreenUiEvent();
}

final class MenuGameRequested extends MenuScreenUiEvent {
  const MenuGameRequested();
}

final class MenuSnackBarRequested extends MenuScreenUiEvent {
  const MenuSnackBarRequested(this.message);
  final String message;
}
```

Điểm đổi: `abstract class MenuUiEvent` → `sealed class
MenuScreenUiEvent`. Tên + file giờ khớp senior nguyên tử.

**Bước 2** — `menu_view_model.dart`: sửa import và hai chỗ kiểu:

```dart
import 'menu_screen_ui_event.dart';
// …
final StreamController<MenuScreenUiEvent> _events =
    StreamController<MenuScreenUiEvent>.broadcast();
Stream<MenuScreenUiEvent> get events => _events.stream;
```

**Bước 3** — `menu_screen.dart`: sửa import + viết lại bridge:

```dart
void _handleUiEvent(MenuScreenUiEvent event) {
  switch (event) {
    case MenuGameRequested():
      unawaited(_openGame());
    case MenuSnackBarRequested(:final message):
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
  }
}
```

Và `StreamSubscription<MenuUiEvent>` → `StreamSubscription<MenuScreenUiEvent>`.

**Bước 4** — `test/menu_view_model_test.dart`: đổi import sang file
mới (nội dung test không đổi).

## Hiểu code

- `case MenuSnackBarRequested(:final message):` — object pattern vừa
  match vừa bóc `message`; trong nhánh `message` là `String` sẵn,
  khỏi `event.message` và khỏi cast.
- Không có `default`/`_`: hai case đã đủ tập đóng → kiệt hợp. Nếu sau
  này thêm `MenuXyzRequested`, **file này sẽ không compile** cho tới
  khi bạn thêm case — đó là tính năng, không phải phiền toái.
- `switch` *statement* (không `=>`) vì mỗi nhánh làm hành động, không
  trả giá trị — đúng như senior.

## Chạy và quan sát

- `flutter analyze` → `No issues found!`
- `flutter test` → tất cả test menu (event stream, bridge) vẫn xanh —
  hành vi không đổi, chỉ *cơ chế kiểm tra* đổi.
- Demo kiệt hợp: tạm xoá `case MenuSnackBarRequested…` → analyze báo
  `non_exhaustive_switch_statement` → đó là compiler làm việc cho
  bạn. (Statement dùng mã `…_statement`; expression dùng
  `…_expression` — cùng ý nghĩa.)

## Thử nghiệm

Thêm nhanh variant giả `final class MenuDebugRequested extends
MenuScreenUiEvent` vào file event **mà không sửa bridge** → quan sát
analyzer báo `non_exhaustive_switch_statement` ngay tại
`_handleUiEvent`. Xoá variant đó. Bạn vừa thấy "compiler là
checklist" tự hoạt động.

## Lỗi hay gặp

- **Sửa event file mà quên bridge** → `non_exhaustive_switch` — đó
  là thông điệp *mong muốn*.
- **Giữ lại `else if`** vì quen — trên sealed hãy dùng `switch`;
  `is`-chain còn chạy được nhưng mất kiệt hợp.
- **Đổi tên file mà quên một import** — Dart báo ngay, nhưng hãy quét
  cả `test/`.

## Tự làm

Không có exercise riêng — bài này là áp dụng; exercise sản xuất nằm
ở bài 2 và 5.

## Kiểm tra hiểu biết

1. Vì sao đây là "evolution" của M13 chứ không phải sửa bug?
2. `MenuScreenUiEvent` sealed — event hay state? Vì sao câu hỏi đó
   quan trọng?
3. Thêm event mới mà quên xử lý: trước M15 chuyện gì xảy ra, sau M15
   chuyện gì xảy ra?

<details><summary>Đáp án</summary>

1. `abstract` + `is` là đơn giản cố ý cho M13; sealed là nâng cấp khi
   tập event đã ổn định và cần compiler giám sát.
2. Vẫn là *event* — sealed là tính chất tập kiểu, không phải vai trò.
   Event = một lần, không replay, không "đọc lại".
3. Trước: im lặng rơi qua — bug lặng. Sau: `non_exhaustive_switch` —
   compile error.

</details>

## Ta cố ý chưa thêm

- `GameScreenUiEvent` của senior — game chưa có VM (M19).
- `MenuDialogState` learner — chưa có menu dialog (M16+).

## Checkpoint hoàn thành

- [ ] `flutter analyze` sạch sau 4 bước.
- [ ] `flutter test` menu tests xanh.
- [ ] Demo: xoá một case → compile error → restore.
