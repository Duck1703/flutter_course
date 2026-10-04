---
title: "Bài 3 · GameResult qua pop()"
description: "Navigator.push<T> trả Future<T?>, pop(result) mang kết quả về menu, dialog showDialog<_ResultAction> trả hành động, và đóng gói GameResult."
sidebar:
  label: "Bài 3 · GameResult qua pop()"
  order: 3
---

## Mục tiêu

Cho `GameScreen` đóng gói kết quả phiên chơi thành một `GameResult`
và "trả" nó về `MenuScreen` qua `Navigator.pop(result)` — cơ chế
route-result của Navigator, song song với `showDialog` trả giá trị.

## Bạn đang ở đâu

- Milestone: **M10** (bài 3/4)
- App hiện tại: `GameScreen` kết thúc bằng `popUntil(route.isFirst)` —
  menu biết *game đã đóng* nhưng không biết *ván chơi ra sao*. Storage
  đã sẵn sàng (bài 1–2), chỉ thiếu dữ liệu để lưu.

## Vì sao việc này quan trọng ngay bây giờ

Câu hỏi kiến trúc đơn giản mà khó: **ai chịu trách nhiệm biến ván chơi
thành tiến trình profile?** Game biết mọi thứ về ván (đúng mấy câu,
thắng hay thua); menu/profile biết cách áp vào stats. Giải pháp sạch
nhất ở quy mô này: game *trả kết quả về như một giá trị*, menu nhận và
xử lý — đúng một lần.

Navigator có sẵn cơ chế đó: `push<T>` trả `Future<T?>`, `pop(result)`
hoàn thành Future đó với `result`. Ta đã dùng `push<void>` suốt M07–M09
mà chưa tận dụng kiểu trả về — hôm nay dùng thật.

## Bạn đã biết gì

- Route stack `push`/`pop`/`popUntil` (M07, M09).
- `showDialog` là một route (M09) — nay sẽ *trả giá trị* luôn.
- `Future`/`await`/`mounted` check (M05).

## Mental model mới

```
MenuScreen                                    GameScreen
    │ push<GameResult>() ──► route Game mở        │
    │  Future<GameResult?> treo chờ                │  ... chơi ...
    │                                              │  pop(result)
    │ ◄── Future hoàn thành = result ──────────────┘
    ▼
 applyGameResult(result) → setState → save()
```

Ba điểm then chốt:

1. **Một route chỉ pop một lần → một Future chỉ hoàn thành một lần →
   result chỉ áp một lần.** "Apply-once" là tính chất của cơ chế,
   không cần cờ `if (!_applied)`.
2. **Pop trần (back AppBar) = `null`** — ván bỏ cuộc không ghi gì:
   route hoàn thành với giá trị mặc định `null`.
3. **Dialog cũng là route → cũng trả giá trị.** Ta đổi dialog M09 từ
   "tự điều hướng" sang "trả action" để quyết định tập trung một chỗ.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| generic push | `Navigator.of(context).push<GameResult>(route)` | `T` = kiểu giá trị route sẽ trả |
| generic route | `MaterialPageRoute<GameResult>(builder: ...)` | Route phải cùng `T` — compiler bắt nếu lệch |
| pop có result | `Navigator.of(context).pop(result)` | Hoàn thành Future của push với `result` |
| await showDialog | `final action = await showDialog<_ResultAction>(...)` | Dialog trả enum action thay vì tự điều hướng |
| `switch` trên enum nullable | `if (!mounted \|\| action == null) return;` | Dialog `pop()` trần → `null` |

## Flutter cần dùng

Không widget mới — toàn bộ là Navigator API đã có từ M07.

## Android / Compose bridge

- SIMILARITY: `push<GameResult>`/await ≈ `navController.navigate` +
  `savedStateHandle`/shared ViewModel, và gần hơn nữa là
  `startActivityForResult`/`ActivityResultContract` thời cũ — "mở màn,
  chờ kết quả". `pop(result)` ≈ `setResult(RESULT_OK, data)` + `finish()`.
- IMPORTANT DIFFERENCE: kết quả đi *theo route pop*, không qua bus hay
  callback riêng. Ai `push` là người nhận — không có listener đăng ký
  nổi, nên "ai nhận result" = "ai await" — cực kỳ tường minh.
- DO NOT ASSUME: `popUntil` truyền được result. Nó pop nhiều route
  không kèm giá trị — đó là lý do VỀ MENU phải đổi cấu trúc (xem dưới).

## Senior project connection

- Senior không dùng route-result cho flow này: game VM tự gọi
  `userProfileRepository.saveUserProfile(savedProfile)` ngay trong
  session (`view_models/game/bridge/game_screen_view_model_result_persistence.dart`)
  vì VM của senior đã *giữ sẵn repository*. Learner M10 chưa có DI nên
  "trả result về cho menu" là đường đi đúng-quy-mô — M12/M14 sẽ dần
  chuyển trách nhiệm này gần với senior.
- Điểm giống senior giữ nguyên: **kết quả được đóng gói thành giá trị
  trước khi áp** — senior truyền `(earnedAmount, isWin, questionCount)`
  vào `_saveGameResult`, ta gói `GameResult` — cùng ý tưởng "mô tả
  phiên, tách khỏi chính sách".

## Build it step by step

### Bước 1 — Model `GameResult`

```dart
// lib/data/game/game_result.dart — FILE MỚI
/// Kết quả của một phiên chơi — M10.
///
/// "Gói tin" mà `GameScreen` trả về cho `MenuScreen` qua
/// `Navigator.pop(result)`: game chỉ mô tả *điều gì đã xảy ra*;
/// menu là chỗ duy nhất biết cách áp vào profile.
class GameResult {
  /// Số câu người chơi đã bấm CHỐT (không tính câu đang dở khi hết giờ).
  final int questionsAnswered;

  /// Số câu trả lời đúng.
  final int correctAnswers;

  /// `true` khi phiên kết thúc bằng chiến thắng (đúng câu cuối).
  final bool won;

  const GameResult({
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.won,
  });

  // == / hashCode / toString — chuẩn model của course (M04).
}
```

Đặt trong `data/game/` — nó là *dữ liệu của game*, không phải widget.

### Bước 2 — Đếm câu đã chốt trong `_GameScreenState`

```dart
// lib/screens/game_screen.dart — trong _GameScreenState, THÊM field:
/// Số câu đã bấm CHỐT — M10 đếm riêng để đóng gói `GameResult`:
/// câu đang dở khi hết giờ không được tính là "đã trả lời".
int _answeredCount = 0;
```

```dart
// _submitAnswer — trong setState, THÊM một dòng:
setState(() {
  _phase = GamePhase.revealing;
  _answeredCount++;                       // M10
  if (_question.isCorrect(_selectedIndex!)) {
    _correctCount++;
  }
});
```

Và trong `_restart()` reset luôn `_answeredCount = 0` — phiên mới =
đếm mới.

### Bước 3 — Đóng gói kết quả trong `_finish`

```dart
void _finish(GameEndReason reason) {
  _timer?.cancel();
  final result = GameResult(
    questionsAnswered: _answeredCount,
    correctAnswers: _correctCount,
    won: reason == GameEndReason.victory,
  );
  setState(() {
    _phase = GamePhase.finished;
    _endReason = reason;
  });
  _showResultDialog(result);
}
```

`result` là local — nó được đóng gói *một lần* tại lúc phiên kết thúc
và chỉ đi về menu khi người chơi chọn VỀ MENU (bước 4). CHƠI LẠI thì
`result` bị bỏ — phiên mới sinh result mới.

### Bước 4 — Dialog trả action, `pop(result)` mang kết quả

```dart
// _GameScreenState — THAY toàn bộ _showResultDialog:
Future<void> _showResultDialog(GameResult result) async {
  final action = await showDialog<_ResultAction>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        // … title/content giữ nguyên M09 …
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(_ResultAction.playAgain),
            child: const Text('CHƠI LẠI'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(_ResultAction.backToMenu),
            child: const Text('VỀ MENU'),
          ),
        ],
      );
    },
  );

  // Sau await, màn có thể đã bị pop từ nơi khác.
  if (!mounted || action == null) return;
  switch (action) {
    case _ResultAction.playAgain:
      _restart();
    case _ResultAction.backToMenu:
      // pop(result): route game rời stack và Future của
      // push<GameResult> bên menu hoàn thành với kết quả này.
      Navigator.of(context).pop(result);
  }
}

/// Hành động mà dialog kết quả trả về — dialog chỉ *báo* lựa chọn,
/// không tự quyết định điều hướng.
enum _ResultAction { playAgain, backToMenu }
```

Hai nút giờ chỉ `pop(action)` — đóng dialog và báo lựa chọn về nơi
`await`. Thiết kế này giải đúng bài toán result: dialog pop xong
(awaited) rồi route game mới `pop(result)` — hai bước tuần tự, không
còn cặp pop đồng thời của M09, và result đi theo đúng route game.

Nhớ đổi `_showResultDialog()` cũ thành `Future<void>` và thêm import
`game_result.dart`.

## Hiểu code

- **Vì sao `_ResultAction` private (`_`)?** Nó là chi tiết dialog của
  màn game — ai ngoài file này cũng không cần biết. Tương phản
  `GameResult` public: nó là "hợp đồng" giữa hai màn hình.
- **`action == null` khi nào nếu `barrierDismissible: false`?** Trong
  code hiện tại thì không xảy ra — nhưng guard vẫn đúng: back-button
  hệ thống/dialog popped từ nơi khác trong tương lai sẽ cho `null`,
  và `switch` trên enum non-null gọn hơn.
- **`won` tính từ `reason == victory` thay vì đếm đúng hết?** Một
  nguồn sự thật: `GameEndReason` đã mã hoá "vì sao kết thúc" — suy ra
  `won` từ nó không thể lệch với UI dialog.

## Chạy và quan sát

- `flutter analyze` sạch; `flutter test` — test "VỀ MENU … áp vào
  profile" sẽ xanh ở bài 4 khi menu đã nhận result.
- Chạy tay chưa thấy khác: ván chơi vẫn kết thúc/dialog y như M09 —
  result đang "đi trong route" nhưng menu chưa hứng (bài 4).

## Lỗi hay gặp

1. **`push<GameResult>` nhưng route là `MaterialPageRoute<void>`** —
   kiểu result lệch nhau: pop kèm giá trị sẽ ném/ép sai. Hai chữ
   `GameResult` phải khớp.
2. **Giữ nguyên `popUntil` cho VỀ MENU** — `popUntil` pop không kèm
   result → menu nhận `null` → stats không đổi. Phải qua đường "dialog
   trả action → pop(result)".
3. **Quên `mounted` sau `await showDialog`** — game route có thể đã
   pop bởi luồng khác; `_restart()`/`pop` trên State chết sẽ ném.

## Kiểm tra hiểu biết

1. Khi nào Future của `push<GameResult>` hoàn thành với `null`? —
   *Route pop mà không kèm giá trị: back AppBar, back hệ thống, hoặc
   `pop()` trần.*
2. Vì sao không truyền callback `onResult(GameResult)` từ menu vào
   `GameScreen` thay route-result? — *Được, nhưng callback giữ màn gọi
   phải biết nội bộ game; route-result dùng đúng cơ chế Navigator, ít
   đường dây hơn và chuẩn bị cho tương lai (deeplink/route khác).*
3. `_answeredCount` cần thiết không nếu `_questionIndex + 1` gần như
   đúng? — *Không đủ: `_questionIndex` là "đang ở câu nào", kể cả câu
   chưa chốt khi hết giờ. Đếm ở `_submitAnswer` diễn tả đúng "đã bấm
   CHỐT".*

## Tự làm (PREDICT)

`push<GameResult>` trả `Future<GameResult?>` — menu `await` nó. Dự đoán
`result` trên 6 đường về (hai đường cuối đi qua dialog `_ResultAction`
của bài này):

1. Ván kết thúc → dialog → bấm **CHƠI LẠI**.
2. Ván kết thúc → dialog → bấm **VỀ MENU**.
3. Người chơi bấm **← trên AppBar** giữa ván.
4. Người chơi bấm **back hệ điều hành** (Android back gesture).
5. **Phản biện:** nếu VỀ MENU vẫn giữ `popUntil(route.isFirst)` của
   M09 thay vì đường "dialog trả action → `pop(result)`" — menu nhận
   gì, và stats có đổi không?

Với mỗi đường: Future của menu có hoàn thành không? `result` là gì?

:::note[Gợi ý]
Dialog bây giờ chỉ trả một *action* (`pop(_ResultAction.…)`) — game
đọc action rồi mới quyết `pop(result)` hay restart. AppBar/system
back là `maybePop` không result. `popUntil` là pop *không result*
theo predicate — và lesson liệt kê nó trong Lỗi hay gặp.
:::

<details><summary>Đáp án</summary>

1. Future **chưa** hoàn thành — dialog pop với `playAgain`, game
   `_restart()` và **route game còn trên stack** → `push` vẫn treo.
   (Đúng: ván mới đang chơi, result sẽ đến khi route game rời.)
2. `result` = `GameResult` — dialog pop với `backToMenu` → game
   `Navigator.of(context).pop(result)` → GameRoute rời stack kèm
   result → menu apply stats/save. Hai bước tuần tự: dialog trả
   action (awaited), rồi route game pop kèm kết quả.
3. `null` — AppBar back là pop không result; Future hoàn thành với
   `null`. Menu phải handle `result == null` ("thoát giữa ván": không
   apply gì — lựa chọn thiết kế hợp lệ, không phải lỗi).
4. `null` — giống (3); system back cũng là pop không result →
   `Future<GameResult?>` là contract đúng: kiểu nullable là bắt buộc.
5. `null` và **stats không đổi** — `popUntil` gỡ GameRoute không kèm
   result → menu nhận `null` y hệt đường (3)/(4): ván chơi bị "quên"
   về mặt dữ liệu. Đây chính là bug trong Lỗi hay gặp số 2 — và lý do
   flow mới là "dialog action → `pop(result)`": result chỉ đi qua
   `pop` của đúng route game.

Bài học: **kết quả route là kênh optional** — mọi cách rời route không
qua `pop(result)` đều trả `null` về phía await. Viết `await push<T>`
mà không nghĩ đến `null` là viết một nửa contract.

</details>

## Ta cố ý chưa thêm

- Trả result bằng `RouteObserver`/navigation controller — senior có
  `AppNavigationController` nhưng đó là tầng điều hướng tập trung,
  chưa cần ở quy mô hai màn.
- `PopScope`/confirm-exit — M21 (dialog layer) sẽ đụng.
- Kết quả *một phần* (cập nhật live khi từng câu chốt) — là feature
  stream/repository M14+.

## Checkpoint hoàn thành

- [ ] `lib/data/game/game_result.dart` tồn tại với 3 field + ==/hashCode.
- [ ] `_submitAnswer` tăng `_answeredCount`; `_restart` reset nó về 0.
- [ ] `_finish` tạo `GameResult` và `_showResultDialog(result)`.
- [ ] Dialog trả `_ResultAction`; nhánh `backToMenu` gọi
  `Navigator.of(context).pop(result)`.
