---
title: "Bài 1 · Vì sao widget không giữ nổi game"
description: "Mental model của M19: session game là một máy trạng thái hữu hạn — widget chỉ render + forward ý định. Checkpoint: hiểu được vì sao enum 6 phase thắng một nắm boolean."
sidebar:
  label: "Bài 1 · máy trạng thái"
  order: 1
---

## Mục tiêu

- Kể ra được 6 phase của một ván game và transition hợp lệ giữa
  chúng — trước khi nhìn dòng code nào.
- Giải thích được vì sao "4 biến `bool`" hỏng ở quy mô game: chúng
  mô tả *mọi* tổ hợp (kể cả tổ hợp vô nghĩa), còn enum chỉ mô tả
  các trạng thái *có nghĩa*.
- Nói được câu phân chia trách nhiệm của M19: **widget forward ý
  định, ViewModel sở hữu quyết định**.

## Bạn đang ở đâu

- M09–M15: `GameScreen` là `StatefulWidget` 600+ dòng tự giữ
  `_questionIndex`, `_selectedIndex`, `_correctCount`, `_answeredCount`,
  `_phase`, `_dialogState`, `_secondsLeft`, `_timer` — tám cụm state
  lỏng.
- M11–M14 bạn đã quen `ChangeNotifier`/`Provider`/stream-subscription
  ở *menu*; màn game là nơi cuối cùng còn `setState` cục bộ.
- Bài này chỉ dựng mental model — không đụng code.

## Vì sao việc này quan trọng ngay bây giờ

Nhìn lại file cũ (`lib/screens/game_screen.dart`, trước milestone
này): một `State` ôm trọn timer, điểm, index câu, phase, dialog —
và mọi hàm `_startTimer`/`_submitAnswer`/`_advanceAfterReveal` tự
gọi `setState`. Có ba vết đau cụ thể:

1. **State rời nhau.** `_phase`, `_selectedIndex`, `_dialogState`
   là ba biến *độc lập* — vậy `phase=revealing` + `selected=null`
   + `dialogState=Ended` cùng lúc thì sao? Code cũ trả lời: "ừ thì…
   đừng để xảy ra". Không có gì *ngăn* tổ hợp vô nghĩa.
2. **Timer thuộc widget.** `State.dispose` mà quên `cancel()` →
   timer chạy ngầm gọi `setState` trên state đã chết → crash.
   Widget vừa là nơi vẽ vừa là nơi giữ đồng hồ — hai lifetime
   khác nhau ép chung một chỗ.
3. **Test không thể tách.** Muốn test "trả lời sai → game over"
   phải pump cả màn hình, tap text, chờ animation. Logic game kẹt
   chết trong UI.

Senior giải quyết bằng một kiến trúc khác hẳn: *session game là một
máy trạng thái* do ViewModel sở hữu. Milestone này port đúng ý đó.

## Bạn đã biết gì

- `enum` + `sealed class` + `switch` kiệt hợp (M15).
- `ChangeNotifier` + `ChangeNotifierProvider` + `context.watch/read`
  (M11–M12).
- Event một-lần qua `StreamController.broadcast` — `uiEvents`
  (M13/M15).
- `copyWith` trên object bất biến (D-05, M10).

## Mental model mới — "ván game LÀ máy trạng thái"

Một **finite state machine** (máy trạng thái hữu hạn) = một tập
trạng thái đếm được + luật chuyển. Của game:

```text
                  tap đáp án         1.5s               1s
notStarted ──intro──▶ playing ─────────▶ answeredPending ──▶ answeredRevealed
   ▲                    │ hết giờ ────┘  (chờ chấm điểm)        │
   │                    └─ selectedAnswer='' → cũng vào         │ mở
   │                       answeredPending                      ▼
   │                                          GameExplanationDialog
   │                                                   │ dismiss
   │                    ┌── đúng → câu kế (về playing + timer reset)
   │                    ├── đúng câu cuối → victory
   │                    └── sai → gameOver
   └────── playAgain ◀── gameOver / victory (dialog kết thúc, chỉ nút)
```

Ba luật ghi nhớ:

- **Mỗi thời điểm đúng MỘT phase.** Enum `GamePhase` loại trừ lẫn
  nhau — không có "vừa playing vừa revealed".
- **Transition có guard.** `submitAnswer` chỉ có nghĩa trong
  `playing`; gọi ở phase khác → VM bỏ qua. Không còn cầu may
  "đừng gọi sai chỗ".
- **UI là hàm của phase.** Ô đáp án xanh/đỏ/xám không phải biến —
  nó được *suy ra* từ `phase` + `selectedAnswer` mỗi lần render.

:::note[Giới hạn của model này]
Máy trạng thái này là *intermediate architecture*: senior dùng DRE
(`DreChangeNotifier` + reducer thuần) với action/effect tách biệt.
Course cố ý ở mức `ChangeNotifier` + `copyWith` — DRE có milestone
riêng (M26). Model máy trạng thái thì giống hệt; chỉ khác *ai viết
transition* (method VM bây giờ, reducer sau này).
:::

## Ví dụ độc lập — máy trạng thái đơn hàng

Trước khi đụng game, cầm một ví dụ ~25 dòng chạy được trong DartPad:

```dart
enum OrderPhase { idle, paid, shipped }

class OrderMachine {
  OrderPhase phase = OrderPhase.idle;

  void pay() {
    // Guard: chỉ đi idle → paid; gọi lần hai / gọi khi đã ship → bỏ qua.
    if (phase != OrderPhase.idle) return;
    phase = OrderPhase.paid;
  }

  void ship() {
    if (phase != OrderPhase.paid) return;
    phase = OrderPhase.shipped;
  }
}

void main() {
  final order = OrderMachine();
  order.ship(); // vô nghĩa — đang idle, bị guard chặn
  order.pay();  // idle → paid
  order.ship(); // paid → shipped
  print(order.phase); // OrderPhase.shipped
}
```

Nhận ra ngay: không có `isPaid`/`isShipped` boolean nào — enum một
biến duy nhất làm *bất khả thi* các transition vô nghĩa (`ship` từ
`idle`, hay `ship` lại từ `shipped`). `GamePhase` y hệt cái này,
chỉ nhiều phase và có timer/delay kèm theo.

## Android / Compose bridge

- **SIMILARITY:** `ViewModel` giữ state + UI observe — giống hệt
  `ViewModel` + `StateFlow`/`collectAsState` bên Compose.
- **IMPORTANT DIFFERENCE:** trên Android bạn hay model phase bằng
  `sealed class`/`UiState` data class; ở đây phase là `enum` đơn
  thuần vì payload phụ đã nằm trong `GameSessionState` riêng.
- **DO NOT ASSUME:** `Timer`/`Future.delayed` trong VM ≠ coroutine
  `delay` trong `viewModelScope` — Dart không có structured
  concurrency; VM phải tự hủy timer trong `dispose()` (Bài 4).

## Senior project connection

- `lib/view_models/game/dre/game_dre_state.dart` (senior): `GameState`
  giữ `phase`, `questionIndex`, `moneyEarned`, `selectedAnswer`… —
  cùng ý tưởng một object state.
- `lib/data/game/game_session_state_data.dart` (senior): `enum
  GamePhase` với đúng 6 giá trị mà Bài 2 port.
- `lib/view_models/game/reducer/game_reducer.dart` (senior): nơi *thực thi*
  transition ở senior — M19 giữ method-on-VM, M26 mới chuyển qua
  reducer thuần.

## Chạy và quan sát

Chưa cần chạy — bài lý thuyết. Nếu muốn xem "bằng chứng vấn đề",
mở `git show HEAD~<m19>`… không, đơn giản hơn: đọc lại
`lib/screens/game_screen.dart` *trước* khi Bài 2 xé nó — đếm số
biến `int`/`bool`/phase/`Timer` trong `_GameScreenState` cũ (từ
git history: `git log --oneline -- lib/screens/game_screen.dart`).

## Kiểm tra hiểu biết

1. Vì sao `phase == playing && dialog is Ended` là "vô nghĩa" mà
   vẫn biểu diễn được trong thiết kế cũ?
   → Vì `phase` và `dialogState` là hai biến *độc lập* — không có
   gì bắt chúng tương thích. Trong M19, `dialogState` nằm TRONG
   `GameSessionState` và VM chỉ emit tổ hợp hợp lệ.
2. `submitAnswer` gọi khi đang `answeredPending` — VM làm gì?
   → Bỏ qua (guard `phase != playing → return`).
3. Vì sao nói "UI là hàm của phase" thay vì "UI giữ state"?

## Ta cố ý chưa thêm

- Reducer/action/effect của DRE — M26.
- `visibleOptionTexts`/`audiencePercentiles`/`usedFeatureButtons`
  trong state — M20.
- Dialog render trong `Stack` (`GameDialogLayer`) — M21.

## Checkpoint hoàn thành

- [ ] Vẽ được 6-phase diagram từ trí nhớ (không nhìn bài).
- [ ] Trả lời được: "guard `phase == playing` ngăn cái gì?"
- [ ] Giải thích được `OrderMachine` tự viết trong ví dụ độc lập.
