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

## Ví dụ độc lập — `showDialog` tối thiểu

Trước khi gặp dialog kết quả, xem một dialog trần trong app ~50 dòng
(DartPad — chế độ Flutter):

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: DemoScreen()));

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Xoá mục này?'),
                content: const Text('Hành động không thể hoàn tác.'),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(dialogContext).pop(),
                    child: const Text('HUỶ'),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(dialogContext).pop(),
                    child: const Text('XOÁ'),
                  ),
                ],
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue,
            child: const Text('Mở dialog',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
```

Chạy và thử ba điều:

- Bấm "Mở dialog" → dialog hiện **và nền mờ đi**: `showDialog` đã push
  một `DialogRoute` lên đỉnh stack — đúng mental model route của M07.
- Bấm ra vùng nền mờ → dialog đóng: `barrierDismissible` mặc định `true`.
  (Dialog game sẽ đặt `false` — bắt người chơi chọn nút.)
- `dialogContext` là context **của dialog**: `Navigator.of(dialogContext)
  .pop()` đóng đúng route dialog. (Trong ví dụ đơn giản này dùng context
  ngoài cũng "chạy được" — nhưng thói quen đúng quan trọng khi dialog
  bắn từ chỗ sâu hơn.)

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

## Tự làm (PREDICT)

Stack đang là `[Menu, Game]` và dialog kết quả vừa hiện
(`barrierDismissible: false`). Vẽ stack sau mỗi hành động — rồi kiểm
chứng trong app:

1. Bấm ra vùng nền mờ.
2. Bấm nút **CHƠI LẠI** (đọc code: nó gọi gì — `pop` hay `popUntil`?).
3. Sau khi dialog hiện lại ở ván tiếp theo, bấm **VỀ MENU**.
4. Câu phản biện: thay `popUntil((r) => r.isFirst)` bằng hai lần `pop()`
   liên tiếp — dự đoán điều gì có thể sai?

:::note[Gợi ý]
`barrierDismissible: false` có nghĩa chữ nghĩa. Đọc lại `Hiểu code` /
`Build it step by step` của bài: nút CHƠI LẠI cần giữ game route, nút
VỀ MENU cần gỡ cả dialog lẫn game. `pop()` tưởng "gỡ một cái" — nhưng
pop animation bất đồng bộ: pop thứ hai đập vào stack đang biến đổi.
:::

<details><summary>Đáp án</summary>

1. **Không gì xảy ra** — `barrierDismissible: false` nuốt tap nền;
   stack vẫn `[Menu, Game, DialogRoute]`.
2. CHƠI LẠI chỉ `pop` **route dialog** (kèm reset state game) → stack
   `[Menu, Game]` — ván mới bắt đầu ngay trong route cũ.
3. VỀ MENU `popUntil((route) => route.isFirst)` → gỡ DialogRoute **và**
   GameRoute một lượt → `[Menu]`.
4. Hai `pop()` liên tiếp là race: pop đầu khởi động animation đóng
   dialog, pop thứ hai có thể trúng vào stack chưa ổn định — route sai
   bị gỡ, hoặc hành vi lệ thuộc timing. `popUntil` là một thao tác
   nguyên tử "gỡ tới khi predicate đúng" — đúng công cụ cho "về tới
   đâu", và cũng là lý do `canPop`-style guard tồn tại.

</details>

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

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m09/03 — "showDialog & popUntil" (dialog kết quả là một route trên stack).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Trọng tâm: dialog là ROUTE (`showDialog` push DialogRoute) — đóng=pop, về menu=popUntil; và dialog được gọi từ `_finish` (event), KHÔNG phải trong `build`.

EXPECTED STATE SAU BÀI NÀY (trong `_GameScreenState`):
- `_showResultDialog()`: `showDialog<void>(context: context, barrierDismissible: false, builder: (dialogContext) => AlertDialog(...))` (STRICT: barrierDismissible=false — bắt buộc chọn nút, giữ bất biến finished; `<void>` vì dialog không trả kết quả).
- `AlertDialog` có `title`/`content`/`actions` với 2 `TextButton`: CHƠI LẠI = `Navigator.of(dialogContext).pop();` rồi `_restart();` (STRICT: pop route dialog bằng dialogContext, reset sau); VỀ MENU = `Navigator.of(context).popUntil((route) => route.isFirst)` (STRICT popUntil một lần — KHÔNG hai `pop()` liên tiếp).
- `_dialogTitle()` + `_resultText()`: `switch` trên `_endReason` có `case GameEndReason.victory`, `case GameEndReason.timeout`, `case GameEndReason.wrongAnswer`, **`case null`** (STRICT exhaustiveness trên `GameEndReason?` — thiếu case null analyzer bắt); title ~'CHIẾN THẮNG!'/'HẾT GIỜ!'/'KẾT THÚC', content dùng `'Đúng $_correctCount/${quizQuestions.length} câu'` + `\n` (semantic chuỗi cụ thể).
- `_finish` gọi `_showResultDialog()` — dialog là side-effect một lần trong event handler, KHÔNG nằm trong `build` (STRICT: `showDialog` trong build = push chồng lặp → DIVERGED).
- Panel kết quả inline của M08 (nhánh `_quizFinished`/`_QuizResultPanel` trong build) đã bị GỠ — build giờ chỉ render `_QuizBody`, dialog che trên khi finished (STRICT: cả hai cơ chế kết quả cùng tồn tại = thừa).
- `flutter analyze` → "No issues found!"; chơi thật: sai→KẾT THÚC, hết giờ→HẾT GIỜ!, đúng hết→CHIẾN THẮNG!; CHƠI LẠI reset tại chỗ; VỀ MENU về menu (stack sạch).

INVARIANTS NỀN:
- Phase machine + Timer của bài 1–2 (`_phase`, `_endReason`, `_finish`, `_restart`); `quizQuestions`; route push/pop M07; menu + async nguyên vẹn; chưa có named routes/dialog system.

Mục (STRICT) phải đúng; mục khác chấm semantic (màu, shape, chuỗi). Code vượt checkpoint (dialog-system riêng/named routes) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m09/03
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
