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

## 🤖 AI Local — Kiểm tra project sau bài này (TỔNG HỢP M19)

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m19/06 — TỔNG HỢP M19 (full regression: analyze + 126/126 + build web; toàn bộ game đã chuyển từ widget-State sang VM-owned state machine).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter build web` READ-ONLY (chỉ verify). Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. M19 = rebuild xuyên-stack: semantic cũ phải còn nguyên (menu nhận result, profile cộng EXP, settings lái locale, onboarding chỉ hiện một lần) — kiểm cả phía "người dùng không nhận ra đã đổi".

EXPECTED STATE SAU BÀI NÀY (đỉnh M19 — mọi lớp phải còn nguyên):
- DATA (bài 2): `GamePhase` 6 giá trị; `GameDialogState` sealed 6 variant; `GameScreenUiEvent` + 2 event; `GameSessionState` 9 field + `initial` + `copyWith`/`clearSelectedAnswer`; `GameQuizQuestionData` 8 field + `GameQuestionExplanationData` + `GameQuestionDifficulty`; bank `gameSample*` 15 câu; `gameMoneyLadderLevels` 15 + safe-haven 5/10/15; `GameResult.earnedAmount`; `applyGameResult` dùng `earnedAmount`; ARB key mới (`moneyLadderTitle`, `exitGame*`, `aiExplanationsTitle`, `understandButton`, `congratulationsTitle`, `youEarnedLabel`, `playAgainButton`, `menuButton` — không còn key cũ); file cũ `quiz_question*`/`quiz_questions*` + test cũ ĐÃ XOÁ.
- MAPPER (bài 3): `game_screen_data.dart` (GameAnswerState, GameMoneyData String-amount, GameQuestionData, GameAnswerOptionData, GameTimerData clamp+mm:ss); `support/game_money_formatter.dart`; `support/game_money_ladder_mapper.dart` (`calculateGameWalkAwayAmount` + `buildGameMoneyLadderItems` reversed); `game_screen_presentation_mapper.dart` chữ ký field lẻ + `_answerState` phase→màu.
- VM (bài 4): `GameScreenViewModel extends ChangeNotifier` — 3 const delay/time; `questions` injectable; `_events` broadcast; `Timer?`/`_isDisposed`/`_state`; `screenData`/`uiEvents`/`dialogState`/`state`; `submitAnswer`/`showMoneyLadder`/`showConfirmExit`/`startNewGame` (token đơn điệu)/`dismissDialog` router/`_onRevealElapsed`/`_onExplanationElapsed`/`_loadNextQuestionOrVictory`/`_endGame`/`_startTimer`/`_stopTimer`/`_tick`/`_schedule`(token+disposed guard)/`dispose`/`buildGameResult` switch — tất cả như checkpoint bài 4.
- SCREEN (bài 5): `GameScreen` stateless + injection; `_GameScreenEventBridge` (didChangeDependencies read + `_attachViewModel` idempotent + post-frame start/dialog-catchup + `_dialogOpen` + `_handleUiEvent` post-frame + `_showCurrentDialog` với nhánh `action==null` re-open/dismiss + `_handleRouteBack` theo variant + `PopScope canPop:false`); `_GameDialogHost` trả enum action; `lib/navigation/app_navigation_controller.dart` (navigatorKey + `openGame` → `Future<GameResult?>` + `goBack` canPop-guard); `main.dart` portraitUp + controller trong `AppDependencyScope` + `MaterialApp.navigatorKey`; `menu_screen.dart` `await openGame()`.
- TEST: `game_sample_questions_test` (7), `sealed_state_test` viết lại (6 variant), `game_screen_presentation_mapper_test` (4), `game_screen_view_model_test` (17 FakeAsync), `test/widgets/game_screen_test.dart` mới (~10 widget + nav-controller harness); `fake_async` trong dev-deps; `localizedTestApp` có param `navigatorKey`.
- `flutter analyze` sạch; `flutter test` → **126/126** (STRICT); `flutter build web` thành công.
- Tự làm `GameRatingDialog` (OPTIONAL — có thì variant + `showRating` + nhánh dismiss + test; KHÔNG tính thiếu nếu không làm).
- SEMANTIC CŨ GIỮ NGUYÊN (STRICT regression): menu `openGame` + `applyGameResult` nhận `GameResult` áp profile (EXP/tiền cập nhật); settings dialog + `languageCode` lái locale (M17 test vẫn xanh); onboarding overlay gate FutureBuilder vẫn hiện đúng một lần (M18 test vẫn xanh); `onboarding_completed: true` trong test host còn nguyên.

INVARIANTS NỀN — chưa đến, KHÔNG được có:
- KHÔNG `GameDialogLayer`/dialog trong `Stack` (M21); KHÔNG lifeline (`visibleOptionTexts`, `audiencePercentiles`, `usedFeatureButtons`, `featureButtons`, `GameConfirmWalkAwayDialog`/`GameAudiencePollDialog`/`GameAIAssistantDialog`) (M20); KHÔNG `GameShareResultEvent`/share (M27); KHÔNG VM-side save profile / `hasSavedResult` / `openGame` trả `Future<void>` (M22); KHÔNG `DreChangeNotifier`/reducer/action/effect (M26).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`/`AHEAD_RISKY` theo mức; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. M20 gắn lifelines vào cùng state machine — chưa chấm.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m19/06
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
