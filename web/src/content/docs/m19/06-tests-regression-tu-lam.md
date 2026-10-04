---
title: "Bài 6 · Regression + tự làm + tổng kết M19"
description: "Chạy lại toàn bộ checkpoint, flutter analyze/test/build web; bài tự làm production: thêm variant dialog mới đi xuyên state→VM→bridge→host. Tổng kết: mọi thứ đã chuyển từ widget sang VM."
sidebar:
  label: "Bài 6 · regression + tổng kết"
  order: 6
---

## Mục tiêu

- Chạy full regression: `flutter analyze` + `flutter test`
  (**126/126**) + `flutter build web`.
- Làm bài tự làm production: thêm một variant `GameDialogState`
  mới đi xuyên toàn stack — data → VM method → bridge → dialog host.
- Tổng kết những gì đã *chuyển* từ widget sang VM — và những gì
  còn treo cho M20–M26.

## Bạn đang ở đâu

- Bài 5: `GameScreen` VM-backed chơi được thật, 126/126 xanh.
- Bài này: kiểm chứng + một bài tập xuyên-stack.

## Vì sao việc này quan trọng ngay bây giờ

M19 là milestone "phá cũ dựng mới" duy nhất của Phase E–F — nó đụng
vào từng file test cũ. Regression không chỉ chứng minh "vẫn xanh"
mà chứng minh *semantic* cũ còn nguyên: menu vẫn nhận result, profile
vẫn cộng EXP, settings vẫn lái locale. Một milestone kiến trúc thành
công là milestone mà người dùng **không nhận ra** đã đổi.

## Full regression

```bash
cd learner-app
flutter analyze         # sạch — không warning
flutter test            # 126/126
flutter build web       # release web build OK
```

`npm run build` ở `web/`: site 102 trang sau khi milestone này được
tích hợp (95 trước + 7 route `/m19/`).

## Bản đồ trách nhiệm sau M19

| Thứ | Trước M19 | Sau M19 |
|-----|-----------|---------|
| phase game | `_phase` enum 3 giá trị trong `State` | `GameSessionState.phase` 6 giá trị, VM-owned |
| timer 15s | `Timer.periodic` trong `State` | `Timer.periodic` 30s trong VM, pause/resume theo dialog |
| tiền | `correctCount * 1000` phẳng | `gameMoneyLadderLevels` 15 bậc + safe havens |
| đáp án đã chọn | `_selectedIndex: int?` | `selectedAnswer: String?` theo text, `''` = timeout |
| dialog | `_dialogState` 3 variant cục bộ | `GameDialogState` sealed 6 variant, bridge `showDialog` |
| điều hướng | `Navigator.push` trong menu | `AppNavigationController` + `navigatorKey` |
| back | `WillPopScope`-style/none | `PopScope canPop:false` → `_handleRouteBack` theo variant |
| kết quả | `Navigator.pop(GameResult)` inline | `buildGameResult()` + `GameNavigateToMenuEvent` → `goBack(result)` |
| xoay màn | không khóa | `portraitUp` trong `main()` |

## Tự làm — thêm `GameRatingDialog` (production exercise)

**Bài toán:** sau dialog kết thúc, senior có thể muốn hỏi đánh giá.
Thêm variant `GameRatingDialog` (không payload) đi xuyên stack:

1. `game_session_state_data.dart`: `final class GameRatingDialog
   extends GameDialogState { const GameRatingDialog(); }`
2. `GameScreenViewModel`: method `void showRating()` — guard
   `phase == gameOver || victory`, emit `dialogState:
   GameRatingDialog()` + `GameDialogRequested`.
3. `_GameScreenEventBridge._handleRouteBack` + `_showCurrentDialog`:
   `GameRatingDialog` vào nhánh "dismiss được" (như confirm-exit).
4. `_GameDialogHost`: title + nút "RATE"/"LATER" → `dismiss`.
5. `dismissDialog` trong VM: `GameRatingDialog` rơi vào nhánh
   default (ẩn + không hồi timer vì phase kết thúc).
6. Test: widget test assert dialog mở/đóng đúng.

:::note[Gợi ý]
Nhánh default của `dismissDialog` (`_emit(copyWith(dialogState:
Hidden))` + `if (playing) _startTimer()`) đã xử `GameRatingDialog`
đúng rồi — không cần nhánh riêng, vì ở `gameOver`/`victory` timer
đã dừng và `phase != playing` nên `_startTimer` không gọi.
:::

<details><summary>Đáp án</summary>

```dart
test('rating dialog: mở ở gameOver, dismiss không hồi timer', () {
  FakeAsync().run((async) {
    final vm = startedVm(async, 3);
    final wrong = vm.screenData.answers
        .firstWhere((a) => a.answerText != vm.currentCorrectOption);
    vm.submitAnswer(wrong); // sai → reveal → explanation sai
    async.elapse(const Duration(milliseconds: 2500)); // qua 2 delay
    vm.dismissDialog(); // explanation sai → gameOver
    vm.showRating();
    expect(vm.dialogState, isA<GameRatingDialog>());
    vm.dismissDialog();
    expect(vm.dialogState, isA<GameDialogHidden>());
    expect(vm.state.phase, GamePhase.gameOver); // không quay playing
  });
});
```

</details>

## Debug — "flowToken lỗi thời"

Bài DEBUG ngược: giả sử ai đó đổi `startNewGame` thành
`flowToken: 0` (reset). Lỗi gì xảy ra — và *khi nào* nó xảy ra?

→ Reset làm token phiên mới đi lại từ 0: delayed callback của phiên
cũ mang *cùng* token với phiên mới → `_schedule` không vô hiệu nó.
Nhưng nó chỉ gây hại khi phiên mới **quay lại cùng phase** trước
deadline (phase-guard trong `_onRevealElapsed` chặn được callback
đến khi phase khác). Test chứng minh: `submitAnswer` → `playAgain()`
→ `dismissDialog` → `submitAnswer` (phiên mới `answeredPending`,
token trùng cũ) → `elapse(1500ms)` → reveal cũ chạy chồng lên phiên
mới. `startNewGame` hai lần không-sau-submit thì không có callback
nào để leak — bug chỉ lộ khi có delay đang chờ.

## Tổng kết milestone

1. **Học gì?** Máy trạng thái hữu hạn làm model session;
   `copyWith` + `clear*` trên immutable state; VM-owned
   `Timer.periodic` + `flowToken` anti-stale; presentation
   mapper tách state ↔ DTO; `PopScope`; nav
   controller + `navigatorKey`.
2. **Giải thích được?** Vì sao enum thắng boolean; vì sao timer ở
   VM; vì sao `dialogState` là nguồn thật còn `showDialog` chỉ là
   bridge; vì sao back phải route theo variant.
3. **Viết lại được?** VM test `fakeAsync`, mapper test thuần,
   widget test đầy đủ session — tất cả không cần app thật.
4. **Nếu … thì sao?** Quên `_isDisposed` → callback chạy sau khi
   route pop → crash; quên `barrierDismissible: false` → tap nền
   thoát terminal dialog; quên `action == null` → back thoát dialog
   mất kết quả.
5. **Cần ở đâu sau?** M20 gắn lifelines vào *cùng* state machine
   (`usedFeatureButtons`, `visibleOptionTexts`); M21 thay bridge
   `showDialog` bằng `GameDialogLayer` trong `Stack`; M22 cho VM tự
   save profile (retire pop-result); M26 chuyển `ChangeNotifier`
   → DRE.

## Checkpoint cuối milestone

- [ ] `flutter analyze` sạch; `flutter test` = **126/126**;
  `flutter build web` xanh.
- [ ] Chơi thật một ván: intro thang tiền → 15 câu → timer pause
  khi mở thang → giải thích sau mỗi câu → victory/gameOver → menu.
- [ ] Tự làm: `GameRatingDialog` đi xuyên stack được, test xanh.
- [ ] Vẽ được diagram: `Widget → method VM → copyWith → notify →
  rebuild / event → bridge → showDialog-pop`.
