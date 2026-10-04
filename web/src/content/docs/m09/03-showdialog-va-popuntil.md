---
title: "Bài 3 · showDialog & popUntil"
description: "Dialog kết quả là một route trên stack: showDialog/AlertDialog, barrierDismissible, switch trên enum cho title/text, CHƠI LẠI vs VỀ MENU."
sidebar:
  label: "Bài 3 · showDialog & popUntil"
  order: 3
---

## Mục tiêu

Khi `phase == finished`, hiện **dialog kết quả thật** (không phải panel
inline của M08): `AlertDialog` với title theo lý do kết thúc, hai nút
**CHƠI LẠI** (reset tại chỗ) và **VỀ MENU** (gỡ cả hai route trên menu).

## Bạn đang ở đâu

- Milestone: **M09** (bài 3/4)
- App hiện tại: phase machine đầy đủ (bài 2) — `_finish` đã set phase
  `finished` + `_endReason`, chỉ thiếu `_showResultDialog` thật.

## Vì sao việc này quan trọng ngay bây giờ

M08 hiện kết quả bằng panel trong cùng màn hình — được cho quiz nhỏ,
nhưng "kết thúc ván" là một **trạng thái đặc biệt**: che mọi tương tác
bên dưới, bắt người chơi chọn một hướng. Đó đúng là bản chất của dialog
— và trong Flutter, dialog là **một route** trên cùng Navigator của
M07: stack lúc này là `[Menu] [Game] [Dialog]`. Hiểu dialog = route
giải thích ngay tại sao "về menu" lại là bài toán *pop hai route*.

## Bạn đã biết gì

- `Navigator.push/pop`, route stack, `MaterialPageRoute` (M07);
  `switch` trên enum (bài 2); `context` là "địa chỉ" trong tree (M07).

## Mental model mới

**`showDialog` = `Navigator.push` cho route hội thoại.**

```
Navigator stack:  [Menu route]  [Game route]  [DialogRoute]
                                            ▲
                              showDialog đẩy lên — tap nền (barrier)
                              có thể dismiss, nút bấm là pop()
```

Ba ý nghĩa:

- Dialog tự có `BuildContext` riêng (`dialogContext`) — bên dưới nó là
  màn game đang chờ.
- "Đóng dialog" = `Navigator.pop` *route đó* — cùng API M07.
- "Về menu từ dialog" = gỡ dialog **và** game = pop tới route đầu tiên —
  `popUntil`, không phải hai cú `pop()` rời.

**`switch` trên enum-nullable xài exhaustiveness:** `_endReason` là
`GameEndReason?` — Dart bắt buộc `case null` (hoặc `default`), và cảnh
báo khi thiếu một giá trị enum. Đó là phòng thủ miễn phí khi sau này
thêm lý do kết thúc.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `switch` statement | `switch (_endReason) { case victory: … case null: … }` | Exhaustive trên `GameEndReason?` — kể cả `null` |
| interpolation đa dòng | `'…\n$base'` | `Text` nhận chuỗi có `\n` — xuống dòng không cần widget thứ hai |
| lambda béo | `onPressed: () => Navigator.of(context).popUntil(…)` | Arrow-form vì body một expression |

## Flutter cần dùng

| API | Ví dụ | Nghĩa |
|-----|-------|-------|
| `showDialog<T>` | `showDialog<void>(context: context, barrierDismissible: false, builder: …)` | Push một DialogRoute; `<void>` = dialog không trả kết quả về |
| `AlertDialog` | `AlertDialog(title: …, content: …, actions: [TextButton…])` | Dialog Material chuẩn: tiêu đề / nội dung / hàng nút |
| `barrierDismissible` | `false` | Tap ra nền mờ không đóng — bắt chọn nút |
| `Navigator.popUntil` | `Navigator.of(context).popUntil((route) => route.isFirst)` | Pop lặp tới khi predicate đúng — gỡ dialog+game một lượt |
| `route.isFirst` | predicate của `popUntil` | Route đầu tiên trong stack (ở đây: Menu) |

## Android / Compose bridge

- SIMILARITY: `showDialog` ≈ `dialog` composable điều khiển bởi state;
  barrier ≈ scrim; `barrierDismissible` ≈ `onDismissRequest` không gọi.
- IMPORTANT DIFFERENCE: dialog **là route** — điều hướng, không phải
  node trong cây UI của màn hiện tại. Senior project xây cả hệ thống
  dialog-in-stack (M21); bây giờ `showDialog` đủ và đúng chuẩn.
- DO NOT ASSUME: `pop()` gọi hai lần liên tiếp an toàn. Route pop có
  animation — pop thứ hai có thể đập vào route vừa kết thúc chưa rời
  hẳn history. `popUntil` là API đúng cho "về tới đâu".

## Senior project connection

- `flutter-accelerator-ai/lib/widgets/game/dialogs/game_result_dialogs.dart`
  — senior có dialog thắng/thua riêng biệt trong hệ thống overlay
  (`GameDialogState` — sealed data đi kèm phase). Ta dùng `AlertDialog`
  chuẩn — cùng "dialog tại finished", chưa cần hệ thống overlay.
- `flutter-accelerator-ai/lib/navigation/app_navigation_controller.dart` —
  `goBack()` của senior cũng chỉ là `Navigator.pop` bọc lại. `popUntil`
  về route đầu tương đương "back to root" ở app lớn.

## Build it step by step

### Bước 1 — `_showResultDialog` trong `_GameScreenState`

```dart
// _GameScreenState — THÊM:
void _showResultDialog() {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // bắt buộc chọn nút — không tap-ra-ngoài
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: MenuTokens.backgroundBottom,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MenuTokens.radiusCard),
        ),
        title: Text(
          _dialogTitle(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _endReason == GameEndReason.victory
                ? MenuTokens.statGreen
                : MenuTokens.accentRed,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        content: Text(
          _resultText(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: MenuTokens.textPrimary,
            fontSize: 15,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // gỡ route dialog
              _restart();                        // reset phiên
            },
            child: const Text('CHƠI LẠI'),
          ),
          TextButton(
            onPressed: () =>
                // Route stack: [Menu] [Game] [Dialog] — popUntil gỡ mọi
                // route trên route đầu tiên trong một lần (gọi pop()
                // hai lần liên tiếp dễ trượt: dialog chưa rời history
                // nên pop thứ hai có thể đập vào dialog thay vì game).
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('VỀ MENU'),
          ),
        ],
      );
    },
  );
}
```

Ba chi tiết đáng đọc hai lần:

- **`dialogContext` vs `context`.** Builder cho dialog một `context`
  *thuộc route dialog*. `Navigator.of(dialogContext).pop()` chỉ chắc
  chắn gỡ dialog. Còn `context` của `State` (biến ngoài closure) trỏ
  lên Navigator gốc chứa cả stack — `popUntil` trên nó gỡ cả hai.
- **CHƠI LẠI pop dialog rồi `_restart()`** — thứ tự: gỡ route trước,
  reset state sau; `setState` của `_restart` chạy khi dialog đã rời.
- **`showDialog<void>`** — generic `T` là kiểu kết quả dialog trả về
  khi pop. Ta không cần kết quả (mọi hành động nằm trong `onPressed`)
  → `void`.

### Bước 2 — Title & text theo `_endReason`

```dart
// _GameScreenState — THÊM:
String _dialogTitle() {
  // switch statement trên enum: Dart cảnh báo nếu thiếu một case —
  // an toàn hơn chuỗi if/else khi sau này thêm lý do kết thúc.
  switch (_endReason) {
    case GameEndReason.victory:
      return 'CHIẾN THẮNG!';
    case GameEndReason.timeout:
      return 'HẾT GIỜ!';
    case GameEndReason.wrongAnswer:
    case null:
      return 'KẾT THÚC';
  }
}

String _resultText() {
  final base = 'Đúng $_correctCount/${quizQuestions.length} câu';
  switch (_endReason) {
    case GameEndReason.victory:
      return 'Bạn trả lời đúng tất cả!\n$base';
    case GameEndReason.timeout:
      return 'Hết thời gian trả lời.\n$base';
    case GameEndReason.wrongAnswer:
    case null:
      return 'Đáp án chưa đúng.\n$base';
  }
}
```

- `case null` bắt buộc vì `_endReason` nullable — `null` đi cùng
  `wrongAnswer` về "KẾT THÚC" (phòng thủ: không bao giờ nên xảy ra, nhưng
  nếu xảy ra thì không crash).
- `case` rơi xuống (`case wrongAnswer: case null:`) = cùng một nhánh —
  Dart cho phép liệt kê vài `case` chung một body.

### Bước 3 — Gỡ panel kết quả inline của M08

Xoá hoàn toàn nhánh `if (_quizFinished)` / panel "Đúng X/4 câu" và nút
CHƠI LẠI inline trong `build` — dialog thay thế nó. `build` giờ chỉ có
`_QuizBody` bất kể phase (dialog đã che phía trên khi `finished`).

## Hiểu code

- Vì sao dialog được `showDialog` **bên trong `_finish`** thay vì để
  `build` tự vẽ theo `phase == finished`? — Vì dialog là *điều hướng*
  (push route), một side-effect một lần — để trong `build` sẽ bị build
  lại gọi lặp. Imperative show là cách đúng của imperative API.
- `barrierDismissible: false` không chỉ là UX — nó giữ **bất biến**
  "finished chỉ thoát qua CHƠI LẠI/VỀ MENU": nếu tap nền được dismiss,
  game ở phase `finished` không dialog = kẹt.
- `popUntil(route.isFirst)` hợp lệ vì stack cố định `[Menu][Game][Dlg]`.
  Nếu stack sâu hơn, một predicate kiểu `route.settings.name == '/menu'`
  sẽ cần **named routes** — nhưng senior app không dùng named routes
  (chỉ hai route, điều hướng qua `AppNavigationController` — M19), nên
  course cũng không dạy chúng: giữ ý "predicate cần cách nhận diện route"
  là đủ.

## Chạy và quan sát

- `flutter run` → chơi sai một câu → dialog "KẾT THÚC · Đáp án chưa
  đúng. Đúng 0/4 câu". CHƠI LẠI → ván mới; VỀ MENU → về menu.
- Đúng hết 4 câu → "CHIẾN THẮNG!" xanh lá.
- Để timer chạy hết → "HẾT GIỜ!".

## Lỗi hay gặp

1. **Pop dialog bằng `Navigator.of(context)` thay vì `dialogContext`** —
   hai context trỏ cùng Navigator nên thường "vẫn chạy", nhưng đọc sai
   ý đồ và dễ vỡ nếu dialog sống trên navigator khác. Pop route nào,
   dùng context route đó.
2. **Hai `pop()` liên tiếp để về menu** — pop thứ hai có thể đập vào
   dialog đang thoát (vẫn trong history giữa animation) → game còn lại.
   Một `popUntil` là đúng bản chất.
3. **`showDialog` để trong `build`** — build chạy lại là dialog push
   chồng. Side-effect điều hướng phải nằm trong event handler.
4. **Quên `case null`** — analyzer bắt ngay: switch trên `T?` phải xử
   `null`. Đó là tính năng, không phải phiền.

## Kiểm tra hiểu biết

1. Dialog đang mở mà back-button Android (`WillPopScope`/system back) —
   có pop được không với `barrierDismissible: false`? — *Có:
   barrierDismissible chỉ chặn tap-nền; system back vẫn pop route dialog
   (trừ khi chặn thêm). Ở mức M09 ta chấp nhận — game sau có thể
   PopScope.*
2. `showDialog<void>` — khi nào cần `T` khác `void`? — *Khi dialog trả
   kết quả: `final ok = await showDialog<bool>(…)` — caller `await` và
   nhận giá trị truyền vào `pop(value)`. Đây mọi hành động nằm trong
   nút, không cần trả về.*
3. Vì sao `_restart` chạy sau `pop` chứ không trước? — *Về ngữ nghĩa:
   gỡ route rồi reset — nếu `_restart` trước, setState chạy khi dialog
   vẫn đóng vai route trên cùng và người chơi thoáng thấy câu 1 dưới
   dialog.*

## Ta cố ý chưa thêm

- Animation dialog tuỳ biến / dialog trong Stack (kiểu senior) — M21.
- Trả kết quả về menu (`pop(result)` + `await push` đã học ở M07 nhận
  Future) — stats sẽ dùng ở milestone persistence.
- `PopScope`/`WillPopScope` chặn system-back — tuỳ chọn, sau.
- Named routes — senior app không dùng (imperative stack + controller
  M19), nên course không dạy; route hiện tại là anonymous
  `MaterialPageRoute`.

## Checkpoint hoàn thành

- [ ] `_finish` mở `AlertDialog` với title/text đúng 3 lý do.
- [ ] CHƠI LẠI reset phiên (câu 1, 15s, 0 đúng) mà không rời màn.
- [ ] VỀ MENU quay menu — `find`/`flutter run` xác nhận stack sạch.
- [ ] `flutter analyze` sạch; ván game hoàn chỉnh chơi được đầu-cuối.
