---
title: "Bài 4 · Cắt scaffold — PopScope, _handleRouteBack, mount layer"
description: "Bỏ GameDialogRequested + toàn bộ showDialog/_GameDialogHost; mount GameDialogLayer vào Stack; PopScope(onPopInvokedWithResult) → _handleRouteBack theo dialogState; _afterExit chờ terminal dialog animate-out trước khi pop route."
sidebar:
  label: "Bài 4 · mount + back"
  order: 4
---

## Mục tiêu

- Retire `GameDialogRequested` khỏi `game_session_state_data.dart` —
  `GameScreenUiEvent` còn đúng một variant `GameNavigateToMenuEvent`.
- Viết lại `_GameScreenEventBridge` trong `game_screen.dart`:
  `Stack[background, content, GameDialogLayer]` + `PopScope`.
- Xóa `_GameDialogHost`, `_GameDialogAction`, `_showCurrentDialog()`
  + `_dialogOpen`, và post-frame recovery — không còn route nào để "mở lỡ".
- Sửa test màn hình cho cơ chế mới (finder + timing).

## Bạn đang ở đâu

- Bài 2–3: `GameDialogLayer` + `AnimatedSwitcher` đã xong, test riêng
  xanh — nhưng chưa ai dùng. Màn vẫn chạy `showDialog` cũ.
- Bài này là **bước cắt**: đổi bên render + bên back của màn, xóa
  toàn bộ máy route cũ trong một nhịp.

## Vì sao việc này quan trọng ngay bây giờ

Đây là lúc scaffold biến mất thật — không "dần dần": hai cơ chế mở
dialog cùng tồn tại sẽ render chồng nhau. Migration phải atomic:
cắt dây route → gắn layer → đổi back handling, rồi chạy suite ngay.

## Dart/Flutter cần dùng — xuất hiện đầu tiên

| Construct | Vai trò | Depth |
|---|---|---|
| `PopScope(canPop: false, onPopInvokedWithResult:)` | chặn pop mặc định, callback khi hệ thống đòi back | mới — CORE |
| `NavigatorState.pop` vs `maybePop` | imperative pop **bypass** PopScope; `maybePop`/system back mới hỏi | cùng họ |
| `unawaited(Future)` (`dart:async`) | gọi async, chủ động không await | đã học ở M11 |

### `PopScope` — chặn cái gì, cho qua cái gì

`PopScope(canPop: false)` nói: *"route này không tự pop"*. Khi user
bấm back hệ thống (hoặc `maybePop`), Flutter hỏi `popDisposition` —
`canPop:false` trả "veto" và gọi `onPopInvokedWithResult(didPop:false)`.

Điểm nhiều người hiểu sai: **imperative `Navigator.pop()` đi thẳng,
không hỏi PopScope.** Vì vậy `goBack()` của ta vẫn pop route bình
thường — PopScope chỉ gate *yêu cầu* back từ hệ thống/gesture, không
gate lệnh pop của chính mình. Senior dùng đúng pattern này:
`canPop:false` + callback → `_handleRouteBack`.

## Mental model mới — "back là câu hỏi routing, VM trả lời"

```text
system back → PopScope(canPop:false) chặn pop
            → onPopInvokedWithResult → _handleRouteBack()
            → đọc dialogState, chia 3 nhánh:
              Hidden        → mở confirm-exit
              Ladder/Ended/Victory → ignore (bắt buộc nút)
              còn lại       → dismissDialog()
```

Back không còn nghĩa "đóng cái gì đó" — nó là *input* cho máy trạng
thái. Đây là điểm khác bản chất với `showDialog`: route tự xử back
theo stack của nó; in-tree không có "route con" — một PopScope duy
nhất ở biên màn quyết định tất cả.

## Android / Compose bridge

```text
SIMILARITY:           `PopScope` ≈ `BackHandler(enabled=true,
                      onBack={...})` trong Compose — chặn back mặc
                      định, gọi callback của bạn.
IMPORTANT DIFFERENCE: PopScope là *widget theo route* — nó gắn với
                      route hiện tại, tự hủy khi route pop. Không có
                      "BackHandler lồng nhau ưu tiên con" như Compose.
DO NOT ASSUME:        `canPop:false` không chặn imperative `pop()` —
                      nó chỉ veto *request* (system back / maybePop).
                      Nếu bạn cần chặn cả lệnh mình gọi, đặt guard
                      trong chính method đó.
```

## Build it step by step

### Bước 1 — Retire `GameDialogRequested`

Trong `lib/data/game/game_session_state_data.dart`, **xóa** class
`GameDialogRequested` khỏi family `GameScreenUiEvent` — còn lại:

```dart
/// Sự kiện UI một-lần (M13) — M21 chỉ còn điều hướng: dialog là
/// STATE render in-tree, không cần event "mở dialog" nữa.
sealed class GameScreenUiEvent {
  const GameScreenUiEvent();
}

/// Yêu cầu quay về menu — `_GameScreenEventBridge` pop route kèm
/// `GameResult` (transport M10; retire ở M22 khi VM tự save).
final class GameNavigateToMenuEvent extends GameScreenUiEvent {
  const GameNavigateToMenuEvent();
}
```

Trong `lib/view_models/game/game_screen_view_model.dart`, **xóa mọi
dòng** `emitEvent(GameDialogRequested(...))` — chúng nằm rải rác ở
`showMoneyLadder`, `showConfirmExit`, `_showAudiencePoll`,
`_showAIAssistant`, `_showConfirmWalkAway`,
`confirmWalkAway`, `_onExplanationElapsed`, `_loadNextQuestionOrVictory`,
`_endGame` và chỗ khởi tạo. Mọi method ấy **đã** `copyWith(dialogState:
...)` — event chỉ là "tín hiệu mở route" và giờ không cần nữa.

> Kiểm nhanh: `grep "GameDialogRequested" lib/` — không còn
> kết quả *trong code* (doc-comment nhắc lịch sử không tính).

### Bước 2 — Bridge: `_handleRouteBack` + `_afterExit`

Trong `lib/screens/game_screen.dart`, `_GameScreenEventBridge` giữ
`_attachViewModel`/`dispose`/`_handleUiEvent` (chỉ còn nhánh
`GameNavigateToMenuEvent`), **thêm** hai khối:

```dart
  // Back / exit — PopScope chặn pop mặc định, VM quyết định ý nghĩa
  // "back" theo `dialogState` (senior `_handleRouteBack`).
  void _handleRouteBack() {
    final viewModel = _viewModel;
    if (viewModel == null) return;
    final dialog = viewModel.dialogState;

    // Không dialog → mở xác nhận thoát (VM tự guard phase).
    if (dialog is GameDialogHidden) {
      viewModel.showConfirmExit();
      return;
    }
    // Intro ladder & dialog kết thúc: back không làm gì — terminal
    // dialog bắt buộc chọn nút; ladder intro phải đóng bằng nút.
    if (dialog is GameMoneyLadderDialog ||
        dialog is GameEndedDialog ||
        dialog is GameVictoryDialog) {
      return;
    }
    // ConfirmExit / Explanation → back = đóng dialog.
    viewModel.dismissDialog();
  }
```

Và choreography của nút trong dialog kết thúc (senior `_afterExit`):

```dart
  void _handleBackToMenu() =>
      unawaited(_afterExit((vm) => vm.backToMenu()));
  void _handlePlayAgain() => unawaited(_afterExit((vm) => vm.playAgain()));

  /// Terminal dialog animate-out XONG rồi mới `backToMenu`/`playAgain`
  /// — pop route ngay sẽ cắt mất exit-motion của layer.
  /// `_terminalActionPending` chặn double-tap lặp action.
  Future<void> _afterExit(
    void Function(GameScreenViewModel viewModel) action,
  ) async {
    if (_terminalActionPending) return;
    final viewModel = _viewModel;
    if (viewModel == null) return;

    _terminalActionPending = true;
    try {
      if (viewModel.dialogState is GameEndedDialog ||
          viewModel.dialogState is GameVictoryDialog) {
        viewModel.dismissDialog();
        final duration = MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : MenuTokens.dialogMotionLong;
        if (duration > Duration.zero) await Future<void>.delayed(duration);
      }
      if (!mounted || _viewModel == null) return;
      action(_viewModel!);
    } finally {
      _terminalActionPending = false;
    }
  }
```

Vì sao phải chờ: nút "MENU"/"CHƠI LẠI" trong terminal dialog kích
một route-pop (`goBack`). Nếu pop ngay khi dialog còn đang hiển thị,
exit-fade của layer bị cắt ngang — senior chờ `dialogMotionLong` để
animation chạy trọn. `disableAnimations` → không chờ.

### Bước 3 — `build()`: PopScope + Stack[…, GameDialogLayer]

**Thay** phần `build` trả về — bọc `Scaffold` trong `PopScope`, và
thêm `GameDialogLayer` là child cuối của `Stack`:

```dart
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameScreenViewModel>();
    final data = viewModel.screenData;
    final l10n = AppLocalizations.of(context);
    final lowTime = data.timer.remainingTime.inSeconds <= 5;

    return PopScope(
      // Back không bao giờ pop route trực tiếp — ý nghĩa "back" do VM
      // quyết định theo dialogState (mở confirm-exit / đóng dialog).
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleRouteBack();
      },
      child: Scaffold(
        backgroundColor: MenuTokens.backgroundTop,
        body: Stack(
          children: [
            // ... giữ nguyên: gradient background + SafeArea→Center→
            // ConstrainedBox→Padding→Column[topBar, question, featureBar]
            // Lớp dialog trên cùng — đọc `dialogState` TRỰC TIẾP; khi
            // `GameDialogHidden` nó `IgnorePointer` nên không chặn game.
            GameDialogLayer(
              dialog: viewModel.dialogState,
              onDismiss: viewModel.dismissDialog,
              onConfirmWalkAway: viewModel.confirmWalkAway,
              onBackToMenu: _handleBackToMenu,
              onPlayAgain: _handlePlayAgain,
            ),
          ],
        ),
      ),
    );
  }
```

`GameDialogLayer` đứng **cuối** `children` = trên cùng z-order —
paint sau → đè lên game, hit-test trước → chặn tap khi hiện.

### Bước 4 — Xóa scaffold route

**Xóa** khỏi `game_screen.dart`: `_GameDialogHost` (toàn bộ class),
`_GameDialogAction` (enum), method `_showCurrentDialog()` (mở route
`showDialog`), flag `_dialogOpen` cùng khối re-route sau pop
(`action == null → …`), và phần post-frame recovery trong
`_attachViewModel` — thay bằng comment ghi lý do:

```dart
    // M21: KHÔNG cần post-frame recovery nữa — dialog không phải
    // route đã lỡ mở; `GameDialogLayer` đọc `dialogState` trực tiếp
    // từ frame đầu (VM chưa-start vẫn render `GameDialogHidden`).
```

Giữ import `dart:async` (cần cho `unawaited` ở `_afterExit`).
Bridge không import `game_dialog_views.dart` — views đi qua layer.
Thêm import:

```dart
import '../widgets/game/game_dialog_layer.dart';
```

### Bước 5 — Sửa test cho cơ chế mới

`test/widgets/game_screen_test.dart` — ba loại sửa:

1. **Finder `AlertDialog` → view type.** Duy nhất một chỗ còn scope
   route (test walk-away đọc amount trong card):

```dart
    // card dialog walk-away (M21: không còn AlertDialog route).
    expect(
      find.descendant(
        of: find.byType(GameConfirmWalkAwayDialogView),
        matching: find.text(r'$20,000'),
      ),
      findsOneWidget,
    );
```

2. **Timing dismiss 300 → 400ms.** `AnimatedSwitcher` bắt reverse một
   frame sau swap-build — `pump(300)` đáp đúng *ranh* animation, child
   outgoing vẫn còn một frame. Mọi `pump(300)` đi **sau** hành động
   đóng dialog (tap ĐÃ HIỂU, tap nền, back) đổi thành `pump(400)`;
   `pump(300)` sau khi *mở* (entry) giữ nguyên.

3. `test/game_screen_view_model_test.dart` — test cũ assert
   `GameDialogRequested` được emit; event đã chết:

```dart
    // M21: dialog là STATE, không còn event `GameDialogRequested` —
    // chỉ `GameNavigateToMenuEvent` còn trong family.
    expect(events, isEmpty);
```

(`events` ở đây là danh sách `GameScreenUiEvent` thu sau
`startNewGame` — không còn event nào được phát.)

## Chạy và quan sát

```bash
flutter analyze
flutter test    # 153/153 — số lượng giữ nguyên, assertions đổi chủ
flutter run     # mở app, vào game, bấm ✕: confirm-exit hiện IN-TREE
                # (không còn push route — URL/back stack không đổi)
```

Chạy tay kiểm chứng: ✕ mở confirm → tap nền đóng; ✕ lại → nút
"THOÁT TRÒ CHƠI" về menu. Chọn sai đáp án → dialog kết thúc fade-in,
nút CHƠI LẠI animate-out rồi ván mới.

## Thử nghiệm — đoán trước khi chạy

:::note[PREDICT]
`PopScope(canPop:false)` đang bọc màn game. Trong test menu→game,
`openGame()` push route rồi `backToMenu()` gọi `goBack()` (imperative
`Navigator.pop`). Route có pop được không — hay PopScope chặn luôn
và `_handleRouteBack` chỉ dismiss dialog?
:::

<details><summary>Đáp án</summary>

Pop bình thường. `PopScope` chỉ được hỏi qua `popDisposition` khi
có *request* (system back, `maybePop`) — imperative `Navigator.pop`
đi thẳng qua. Đây là lý do senior dùng pattern này an toàn: back
hệ thống bị chặn để VM quyết, còn code mình chủ động pop vẫn pop.
(Nếu PopScope chặn cả imperative, `backToMenu` sẽ chỉ dismiss dialog
và kẹt trong game — test menu→game→back sẽ fail.)

</details>

## Lỗi hay gặp

- **Test fail "dialog vẫn còn" sau pump(300)** — ranh animation:
  reverse controller khởi động sau swap-build một frame; cần 400ms.
- **`The getter 'showConfirmExit' isn't defined`** — thiếu `context.
  watch<GameScreenViewModel>()` hoặc gọi trên `data` thay `viewModel`.
- **Dialog hiện CHỒNG lên route-dialog cũ** — sót một nhánh
  `showDialog`; `grep "showDialog" lib/screens/game_screen.dart`
  không còn *lời gọi* nào (comment nhắc lại không tính; menu settings
  `showDialog` nằm ở `menu_screen.dart` — file khác, M29 mới đụng).

## Tự làm (DEBUG)

:::note[Bài tập]
Bug được gieo: `_handleRouteBack` thiếu nhánh `GameDialogHidden` —
back khi không dialog thì `dismissDialog()` (no-op) thay vì mở
confirm-exit. Viết test phát hiện: pump game, gọi
`tester.binding.handlePopRoute()` (hoặc simulate back), expect
`Thoát trò chơi?` xuất hiện. Fix lại nhánh `Hidden`.
:::

<details><summary>Đáp án</summary>

```dart
await tester.binding.handlePopRoute();
await tester.pump();
expect(find.text('Thoát trò chơi?'), findsOneWidget);
```

Không có nhánh `Hidden`, back là no-op → assert fail → thấy bug.
Khôi phục `if (dialog is GameDialogHidden) { showConfirmExit(); }`.
Bài học: back-table là policy **máy trạng thái**, từng nhánh phải
có test — không phải "switch cho đủ case là xong".

</details>

## Kiểm tra hiểu biết

1. Vì sao `GameNavigateToMenuEvent` vẫn là *event* chứ không phải
   state? *(Điều hướng = side-effect một-lần trên Navigator — không
   phải thứ render; state chỉ mô tả "vẽ gì".)*
2. `Ladder`/`Ended`/`Victory` back = ignore, nhưng tap nền của ba
   cái đó cũng bị chặn — hai rule giống nhau? *(Không: back-ignore
   vì "bắt buộc quyết định", tap-chặn vì `_canDismissFromBackdrop`.
   Cùng kết quả, khác lý do — tách hai hàm.)*
3. `_afterExit` await trước khi `goBack` — nếu bỏ await, hiện tượng
   gì? *(Route pop ngay, exit-fade bị cắt — dialog "biến mất khựng"
   thay vì trượt ra.)*

## Ta cố ý chưa thêm

- `GameResult` transport qua `goBack(result)` — **M22** thay bằng
  VM-save; giờ giữ nguyên transport M10.
- Menu settings `showDialog` — ngoài phạm vi M21 (**M29**).
- `GameScreenUiEvent` còn một variant — có thể thành callback thuần
  khi M22 retire nốt transport; giữ sealed để khớp cấu trúc senior.

## Checkpoint hoàn thành

- [ ] `grep "GameDialogRequested\|showDialog" lib/screens/game_screen.dart`
  → 0 kết quả **trong code** (tên event còn xuất hiện trong vài
  doc-comment ghi lịch sử M21 — comment không tính).
- [ ] `flutter analyze` sạch; `flutter test` **153/153**.
- [ ] Chạy tay: ✕ → confirm-exit in-tree; back trên confirm → đóng;
  back trên game → mở confirm.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m21/04 — "Cắt scaffold: PopScope, _handleRouteBack, mount layer" (retire GameDialogRequested + xóa toàn bộ showDialog/_GameDialogHost; mount GameDialogLayer vào Stack cuối children; PopScope veto + back-table theo dialogState; _afterExit chờ terminal animate-out). Đây là bước CẮT ATOMIC — hai cơ chế không được cùng tồn tại.

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `grep`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. `GameResult` transport qua `goBack(result)` GIỮ NGUYÊN (M22 mới thay bằng VM-save); menu `showDialog` settings là file khác — KHÔNG đụng (M29).

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/game/game_session_state_data.dart` (STRICT): class `GameDialogRequested` ĐÃ XÓA khỏi `GameScreenUiEvent` — family còn đúng `GameNavigateToMenuEvent` (sealed 1 variant).
- `lib/view_models/game/game_screen_view_model.dart` (STRICT): MỌI dòng `emitEvent(GameDialogRequested(...))` đã xóa (10 chỗ: showMoneyLadder, showConfirmExit, _showAudiencePoll, _showAIAssistant, _showConfirmWalkAway, confirmWalkAway, _onExplanationElapsed, _loadNextQuestionOrVictory, _endGame, khởi tạo); mọi emit chỉ còn `copyWith(dialogState: …)`. VERIFY: `grep "GameDialogRequested" lib/` → 0 kết quả trong code (doc-comment lịch sử không tính). Phần VM còn lại (timer, lifelines, flowToken, _schedule, guards) KHÔNG đổi.
- `lib/screens/game_screen.dart` — `_GameScreenEventBridge` (STRICT): `_handleUiEvent` chỉ còn nhánh `GameNavigateToMenuEvent`; `build()` = `PopScope(canPop: false, onPopInvokedWithResult: (didPop, result) { if (!didPop) _handleRouteBack(); }, child: Scaffold(body: Stack(children: […game content…, GameDialogLayer(…)])))` — `GameDialogLayer` là child CUỐI Stack (trên cùng z-order); args `dialog: viewModel.dialogState, onDismiss: viewModel.dismissDialog, onConfirmWalkAway: viewModel.confirmWalkAway, onBackToMenu: _handleBackToMenu, onPlayAgain: _handlePlayAgain`; `import '../widgets/game/game_dialog_layer.dart'`; `import 'dart:async'` giữ lại cho `unawaited`.
- `_handleRouteBack()` (STRICT bảng 3 nhánh theo `viewModel.dialogState`): `GameDialogHidden → viewModel.showConfirmExit()`; `GameMoneyLadderDialog || GameEndedDialog || GameVictoryDialog → return` (ignore — ladder + terminal bắt buộc nút); mọi variant còn lại → `viewModel.dismissDialog()`. THIẾU nhánh Hidden = back no-op (bug exercise trong bài — DIVERGED).
- `_afterExit` + wrappers (STRICT): `void _handleBackToMenu() => unawaited(_afterExit((vm) => vm.backToMenu()));` `void _handlePlayAgain() => unawaited(_afterExit((vm) => vm.playAgain()));`; `_afterExit` — guard `_terminalActionPending` + `_viewModel==null`; nếu dialog là Ended/Victory → `dismissDialog()` + `await Future.delayed(disableAnimations ? zero : MenuTokens.dialogMotionLong)` (chờ exit-motion trước khi pop route); `!mounted || _viewModel == null → return`; rồi `action(_viewModel!)`; `finally` reset flag.
- ĐÃ XÓA khỏi `game_screen.dart` (STRICT — còn sót = DIVERGED render chồng): toàn bộ class `_GameDialogHost` (kể cả ListenableBuilder), enum `_GameDialogAction`, method `_showCurrentDialog()`, flag `_dialogOpen`, khối `action == null →` re-route sau pop, post-frame recovery trong `_attachViewModel` (thay bằng comment lý do); mọi `showDialog(` call trong file — `grep "showDialog" lib/screens/game_screen.dart` → 0 (comment không tính; `menu_screen.dart` settings dialog là file khác, giữ nguyên).
- TEST sửa (STRICT): `test/widgets/game_screen_test.dart` — finder walk-away đổi sang `find.descendant(of: find.byType(GameConfirmWalkAwayDialogView), matching: find.text(r'$20,000'))`; mọi `pump(300)` SAU hành động đóng dialog → `pump(400)` (reverse controller khởi động 1 frame sau swap-build; pump-300-sau-mở giữ nguyên); `test/game_screen_view_model_test.dart` — test từng assert `GameDialogRequested` giờ `expect(events, isEmpty)` (chỉ còn navigate-to-menu event khi có).
- `flutter analyze` sạch; `flutter test` → **153/153** (số lượng giữ nguyên — assertions đổi chủ cho cơ chế mới, hành vi không lỏng).
- KHÔNG ĐƯỢC có (chưa đến): VM-side save/`GameSaveResult`/`hasSavedResult` (M22); `onShare`/`GameShareResultEvent` trong terminal view (M27 — senior có, cố ý không port); level/leaderboard (M22–M23); menu dialog layer (M29); gradient/sheen shell (M28).

INVARIANTS NỀN:
- Layer đầy đủ Bài 2–3: 9 view + `_dialogBody` kiệt hợp + `ValueKey(runtimeType)` + `AnimatedSwitcher` + `disableAnimations` + `_DialogBackdrop` opaque + tap-outside rules + 6 layer test xanh; `GameDialogState` 9 variant + 4 lifeline field + `resolvedResult`; lifelines M20 (5 nút, AI 700ms, walk-away resolvedResult.won=false); `backToMenu()`/`goBack(result)` imperative pop vẫn đi qua PopScope (imperative bypass — ĐÚNG); menu/settings/onboarding/l10n M14–M18.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. Nếu project đã mount layer NHƯNG vẫn giữ song song `showDialog`/`_GameDialogHost` = cắt chưa atomic → NEEDS_FIX (render chồng).

OUTPUT (đúng format; mục trống → "None"):
LESSON: m21/04
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
