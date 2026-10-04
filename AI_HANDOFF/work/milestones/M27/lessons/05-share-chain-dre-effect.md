---
title: "Bài 5 · Share chain — cưỡi effects-stream M26"
description: "Share KHÔNG phải kiến trúc mới — cưỡi DRE/effects-stream M26 (A-33 reuse): `_DialogShareButton` (TEACHING SCAFFOLD) → layer build chuỗi l10n → `viewModel.shareResult` → `GameShareRequested{text}` → reducer arm không-đổi-state + `[GameShareResult]` → bridge `_events.add(GameShareResultEvent)` → screen `RenderBox`/`sharePositionOrigin` → `SharePlus.instance.share(ShareParams)` (F-35) → catch → `Clipboard` + `resultCopiedSnackBar`. ARB +4 key. +0 test → 259."
sidebar:
  label: "Bài 5 · share chain"
  order: 5
---

## Mục tiêu

- Trace đủ **sáu mắt** của share: dialog button → layer build
  chuỗi → VM `shareResult` → `GameShareRequested` action → reducer
  → `GameShareResult` effect → bridge → `GameShareResultEvent` →
  screen gọi plugin.
- Hiểu vì sao share **cưỡi effects-stream** (A-33) thay vì kiến
  trúc riêng: "mở share sheet" là effect một-lần, không phải
  state — giống `GameNavigateToMenu`.
- Dùng `context.findRenderObject() as RenderBox?` +
  `localToGlobal(Offset.zero) & box.size` làm `sharePositionOrigin`
  (F-35) — vùng neo cho share sheet trên tablet.
- Fallback: `SharePlus.instance.share` throw (web…) → `Clipboard
  .setData` + snackbar `resultCopiedSnackBar` — degrade thay vì
  im lặng.
- ARB +4 key (`shareResultButton`, `shareResultMessage`,
  `shareVictoryResultMessage` placeholders, `resultCopiedSnackBar`).
- Nhận biết `_DialogShareButton` là **teaching scaffold** — senior
  `GameDialogButton`/`shareColor` gradient là M28.
- +0 test → **259/259** (share không thêm test — plugin path thật
  không test được trong unit test).

## Bạn đang ở đâu

- Cuối Bài 4: notification chain hoàn chỉnh — service DI'd,
  onboarding xin quyền thật, settings có version row. 259/259.
- Dialog kết thúc (`GameEndedDialog`/`GameVictoryDialog`) có hai
  nút MENU | CHƠI LẠI — chưa có SHARE.
- M26 đã xây đường ray: `GameAction` → reducer → `GameEffect` →
  `_handleEffect` bridge → `GameScreenUiEvent` → screen. Share
  chỉ cần đặt *một chuyến tàu* lên ray sẵn có.

## Vì sao việc này quan trọng ngay bây giờ

Nút share cám dỗ viết thẳng `onTap: () => Share.share(text)` trong
dialog — và đó là cách nhanh nhất để phá ranh giới A-35 (widget
import plugin) + làm share không test được + đặt `sharePosition
Origin` sai chỗ (dialog context ≠ screen context). Senior đi
vòng qua DRE chain vì: VM không chạm context; effect là data →
reducer testable; và *screen* — nơi có `RenderBox` + `Scaffold
Messenger` — mới là chỗ đúng cho platform call. Một dòng
`SharePlus` nhưng đi đúng đường.

## Bạn đã biết gì

- Toàn bộ DRE chain M26: `dispatch(action)` → `reduce(state,
  action)` → `DreResult(state, effects, asyncOp)` → bridge
  `_handleEffect` → `_events.add(UiEvent)` → screen listen —
  reducer thuần (A-31), effects-stream→bridge (A-33), marker
  interfaces `DreAction`/`DreEffect` (D-46); share đi đường
  *effects*, không đụng `asyncOp` (A-32) hay `flowToken` (A-34).
- `part`/`part of` extension `_handleEffect` trong
  `game_screen_view_model_effects.dart` (M24/M26 — D-45).
- Dialog in-tree: `GameDialogLayer` render theo `dialogState`
  với callback `ValueChanged`/`VoidCallback` (M21 — A-21);
  `l10n.*` lấy ở layer, view nhận chuỗi — "UI sở hữu chữ,
  VM context-free" (M17 — A-16/F-25); `.arb` + `@key`
  placeholders (M17 — D-31).
- `_snackBarText` pattern enum→l10n (M16/Bài 3);
  `ScaffoldMessenger.showSnackBar` đã biết (M13). `Clipboard`
  (`package:flutter/services.dart`) là **lần đầu** trong codebase
  — mới ở bài này.

## Mental model mới — "share sheet là effect, không phải state"

```text
  _DialogShareButton.onTap
        │  (view: icon + label.toUpperCase())
        ▼
  layer: onShareResult( l10n.shareResultMessage(amount) )   ← build chuỗi có l10n + data
        │
        ▼
  screen: viewModel.shareResult(text)
        │
        ▼
  VM: dispatch(GameShareRequested(text))
        │
        ▼
  reducer: GameShareRequested(:text) => _result(state,          ← state KHÔNG đổi
           effects: [GameShareResult(text)])
        │
        ▼
  bridge: case GameShareResult(:text) → _events.add(
           GameShareResultEvent(text))
        │
        ▼
  screen: SharePlus.instance.share(ShareParams(text, origin))    ← context + RenderBox
          catch → Clipboard.setData + snackbar
```

Vì sao *không* để dialog gọi plugin thẳng: (1) widget import
plugin = phá A-35; (2) dialog context không phải chỗ đúng cho
`RenderBox` (screen box = anchor đúng); (3) reducer/bridge làm
share **testable ở mức data** — `reduce` trả `GameShareResult`
assert được mà không cần share sheet.

Giới hạn: effect chỉ mang `text` — `sharePositionOrigin` **không
đi qua** chain (nó phụ thuộc render tree, không phải dữ liệu);
screen tự resolve `RenderBox` lúc xử lý event.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `SharePlus.instance.share(ShareParams(text:…, sharePositionOrigin:…))` | instance API của `share_plus` 13.x — `ShareParams` là named-param object (F-35 — mới) |
| `context.findRenderObject() as RenderBox?` | lấy `RenderBox` của screen — origin anchor cho share sheet (iPad popover) |
| `box.localToGlobal(Offset.zero) & box.size` | `Offset & Size` → `Rect` — toạ-độ-màn-hình của cả screen làm vùng neo |
| `Future<void> _handleUiEvent(...)` | event handler giờ `async` — `listen` nhận `Future<void> Function` gán vào `void Function` vẫn hợp lệ (Future bị bỏ qua — cố ý, comment trong file ghi rõ) |
| `Clipboard.setData(ClipboardData(text: …))` (`package:flutter/services.dart`) | fallback khi share throw — copy vào clipboard OS |

## Flutter cần dùng

| API | Vai trò |
|---|---|
| `TextButton.icon(icon: Icon(Icons.share), label: Text(label.toUpperCase()))` | scaffold share button — đủ ngữ nghĩa (icon + chữ HOA + tap) |
| `_GameDialogCard(shareAction:)` | slot riêng một hàng trên MENU/CHƠI LẠI — chỉ hai dialog kết thúc truyền |
| `ShareParams(sharePositionOrigin:)` | Rect anchor — **bắt buộc trên iPad** (popover không có anchor → crash/iOS lỗi), Android/phone bỏ qua |

## Ví dụ độc lập — Rect từ `localToGlobal` (DartPad)

```dart
// `Offset & Size` → Rect — cú pháp `&` của Flutter
// (DartPad chế độ Flutter; Offset/Size/Rect re-export từ
// material.dart).
import 'package:flutter/material.dart';

void main() {
  const offset = Offset.zero;
  const size = Size(360, 640);
  final rect = offset & size;
  print(rect); // Rect.fromLTRB(0.0, 0.0, 360.0, 640.0)
}
```

`sharePositionOrigin` nhận đúng `Rect` này — vùng neo sheet trượt
lên (share sheet trên iPad là popover cần anchor; phone/Android
ignore).

## Android / Compose bridge

**SIMILARITY — `SharePlus.instance.share(ShareParams(text:…))` ≈
`Intent(Intent.ACTION_SEND).putExtra(Intent.EXTRA_TEXT, …)` +
`startActivity(createChooser)`.** Một dòng Dart bọc toàn bộ intent
chooser — kết quả user-chọn-app về cho OS, app không nhận lại.

**IMPORTANT DIFFERENCE — `sharePositionOrigin` là chuyện iPad,
không phải Android.** Popover trên iPad bắt buộc anchor Rect —
Android share sheet không dùng field này. Vẫn truyền vì cùng API
cho cả hai, và box-null → `null` vẫn compile/an-toàn.

**DO NOT ASSUME — share sheet không throw → không có catch.**
Trên web/unsupported platform plugin throw → không fallback thì
user bấm SHARE không gì xảy ra. Senior's policy: degrade sang
`Clipboard` + snackbar báo đã copy — người dùng vẫn có nội dung.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/view_models/game/dre/game_dre_action.dart` — `GameShareRequested` | verbatim — payload `String text` đã build sẵn ở UI layer |
| `lib/view_models/game/dre/game_dre_effect.dart` — `GameShareResult` | verbatim — effect data |
| `lib/view_models/game/reducer/game_reducer.dart` — arm `GameShareRequested(:text) => _result(state, effects: [GameShareResult(text)])` | verbatim — state không đổi |
| `lib/view_models/game/bridge/game_screen_view_model_effects.dart` — arm `GameShareResult` | verbatim — `_events.add(GameShareResultEvent(text))` |
| `lib/data/game/game_session_state_data.dart` — `GameShareResultEvent` | verbatim — UI event family |
| `lib/screens/game_screen.dart` — `Future<void> _handleUiEvent` + share arm | verbatim — RenderBox + SharePlus + Clipboard fallback |
| `lib/widgets/game/dialogs/game_dialog_layer.dart` — `onShareResult` + build text per variant | verbatim — l10n + data tại layer |
| `lib/widgets/game/dialogs/game_result_dialogs.dart` — `GameDialogButton` `shareColor` `#325DFA`/`green500` | **learner scaffold `_DialogShareButton`** — ngữ nghĩa đúng, visual → M28 |

## Build it step by step

**Bước 1 — ARB keys** (`app_en.arb` + `app_vi.arb`, verbatim
senior strings):

```json
  "shareResultButton": "Share Result",
  "shareResultMessage": "I won {amount} in Flutter Accelerator AI!",
  "@shareResultMessage": {"placeholders": {"amount": {"type": "String"}}},
  "shareVictoryResultMessage": "I won {amount} in Flutter Accelerator AI! {message}",
  "@shareVictoryResultMessage": {"placeholders": {"amount": {"type": "String"}, "message": {"type": "String"}}},
  "resultCopiedSnackBar": "Result copied to clipboard",
```

```json
  "shareResultButton": "Chia sẻ kết quả",
  "shareResultMessage": "Tôi đã thắng {amount} trong Flutter Accelerator AI!",
  "shareVictoryResultMessage": "Tôi đã thắng {amount} trong Flutter Accelerator AI! {message}",
  "resultCopiedSnackBar": "Đã sao chép kết quả",
```

**Bước 2 — action + effect + ui-event** (ba `final class` verbatim):

```dart
// game_dre_action.dart
/// M27 — senior `GameShareRequested`: payload = chuỗi share ĐÃ build
/// sẵn tại UI layer (l10n + amount) — VM chỉ chuyển tiếp, reducer
/// phát effect ra platform.
final class GameShareRequested extends GameAction {
  final String text;

  const GameShareRequested(this.text);
}
```

```dart
// game_dre_effect.dart
/// M27 — senior `GameShareResult`: bridge đổi thành
/// `GameShareResultEvent` cho screen mở share sheet.
final class GameShareResult extends GameEffect {
  final String text;

  const GameShareResult(this.text);
}
```

```dart
// game_session_state_data.dart
/// Xin mở share sheet với nội dung đã build — M27 (FR-33 converge):
/// screen thực hiện `SharePlus.instance.share`, lỗi → clipboard.
final class GameShareResultEvent extends GameScreenUiEvent {
  final String text;

  const GameShareResultEvent(this.text);
}
```

**Bước 3 — reducer arm** (verbatim — *không đổi state*):

```dart
      GameBackToMenuRequested() => _backToMenu(state),
      // M27 — senior verbatim: share không đổi state, chỉ phát effect.
      GameShareRequested(:final text) => _result(
        state,
        effects: [GameShareResult(text)],
      ),
    };
```

**Bước 4 — bridge arm** trong `_handleEffect` (verbatim):

```dart
      case GameNavigateToMenu():
        _events.add(const GameNavigateToMenuEvent());
      // M27 — senior `game_screen_view_model_effects.dart`: effect
      // share → uiEvent cho screen (`SharePlus` + clipboard fallback).
      case GameShareResult(:final text):
        _events.add(GameShareResultEvent(text));
```

**Bước 5 — VM wrapper** `game_screen_view_model.dart` (verbatim):

```dart
  /// M27 — senior `shareResult`: wrapper dispatch `GameShareRequested`
  /// — UI (dialog layer) build sẵn chuỗi share từ l10n + số tiền.
  void shareResult(String text) {
    dispatch(GameShareRequested(text));
  }
```

**Bước 6 — `game_dialog_views.dart`**: `_GameDialogCard` thêm slot
`shareAction` + hai dialog kết thúc wire `onShare` + nút scaffold.

Card slot (verbatim):

```dart
  /// M27 — nút share chiếm MỘT HÀNG RIÊNG trên hàng MENU|CHƠI LẠI
  /// (senior `game_result_dialogs.dart`: share `GameDialogButton`
  /// ...
  final Widget? shareAction;
```

```dart
          if (shareAction != null) ...[
            const SizedBox(height: MenuTokens.spacingMd),
            SizedBox(width: double.infinity, child: shareAction),
          ],
          if (actions.isNotEmpty) ...[
            SizedBox(height: shareAction == null
                ? MenuTokens.spacingMd
                : MenuTokens.spacingXs),
```

Nút scaffold (verbatim — đọc kỹ caution dưới):

```dart
/// Nút SHARE của dialog kết thúc — M27. Learner-style `_DialogTextButton`
/// variant: senior `GameDialogButton` (gradient/glow/icon) là visual
/// M28; ngữ nghĩa nút (label uppercase + icon share + tap) đã đúng.
class _DialogShareButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DialogShareButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.share, color: color, size: 18),
      label: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
```

:::caution[TEACHING SCAFFOLD]
`_DialogShareButton` là **scaffold** — tái dùng `TextButton.icon`
style có sẵn của learner để wire được chuỗi share *ngay* mà không
kéo `GameDialogButton` của senior (gradient + glow + icon slot +
`shareColor` `#325DFA`/`green500`) vào milestone này. Ngữ nghĩa
đã đúng senior — icon share + label uppercase + `onTap` — còn
visual parity là **FR-32/FR-34 → M28**. Đừng "làm đẹp" nút này
ở đây: giữ scaffold, tập trung vào chuỗi.
:::

Hai dialog wire (verbatim — chú ý color per variant):

```dart
      // Senior `shareColor` của Ended: `#325DFA` (xanh dương).
      shareAction: _DialogShareButton(
        label: l10n.shareResultButton,
        color: const Color(0xFF325DFA),
        onTap: onShare,
      ),
```

```dart
      // M27: `onShare` wired — senior `shareColor` của Victory là
      // `green500` (xanh lá) → MenuTokens.statGreen.
      shareAction: _DialogShareButton(
        label: l10n.shareResultButton,
        color: MenuTokens.statGreen,
        onTap: onShare,
      ),
```

**Bước 7 — `game_dialog_layer.dart`**: param + build chuỗi tại
layer (verbatim — l10n ở layer, view nhận chuỗi):

```dart
/// M27 (FR-33 converge): `onShareResult` nhận chuỗi share đã build
/// (l10n + số tiền) và đẩy lên screen → `viewModel.shareResult`.
class GameDialogLayer extends StatelessWidget {
  ...
  final ValueChanged<String> onShareResult;
  ...
    required this.onShareResult,
```

```dart
    // M27: share text cần l10n — build MỘT lần ở đây, `_dialogBody`
    // dùng biến cục bộ (không `AppLocalizations.of` trong switch arm
    // vì `_dialogBody` không nhận context).
    final l10n = AppLocalizations.of(context);
```

```dart
      GameEndedDialog() => GameEndedDialogView(
        data: dialog as GameEndedDialog,
        onPlayAgain: onPlayAgain,
        onBackToMenu: onBackToMenu,
        // M27 — senior `game_dialog_layer.dart`: share text build tại
        // layer (cần l10n + data variant), callback nhận chuỗi thô.
        onShare: () => onShareResult(
          l10n.shareResultMessage(
            (dialog as GameEndedDialog).earnedAmount,
          ),
        ),
      ),
      GameVictoryDialog() => GameVictoryDialogView(
        data: dialog as GameVictoryDialog,
        onPlayAgain: onPlayAgain,
        onBackToMenu: onBackToMenu,
        onShare: () => onShareResult(
          l10n.shareVictoryResultMessage(
            (dialog as GameVictoryDialog).earnedAmount,
            (dialog as GameVictoryDialog).affirmationMessage,
          ),
        ),
      ),
```

**Bước 8 — `game_screen.dart`**: wire `onShareResult` vào layer +
handler `Future<void>` + share arm (verbatim):

```dart
            GameDialogLayer(
              dialog: viewModel.dialogState,
              onDismiss: viewModel.dismissDialog,
              onConfirmWalkAway: viewModel.confirmWalkAway,
              onShareResult: viewModel.shareResult,
              onBackToMenu: _handleBackToMenu,
              onPlayAgain: _handlePlayAgain,
            ),
```

```dart
  // M27 — senior `Future<void>` (share case await `SharePlus` +
  // clipboard); `listen(_handleUiEvent)` vẫn hợp lệ (Future<void>
  // Function assign được vào void Function).
  Future<void> _handleUiEvent(GameScreenUiEvent event) async {
    if (!mounted) return;
    switch (event) {
      case GameShareResultEvent(:final text):
        // M27 — senior verbatim: share sheet theo ShareParams +
        // sharePositionOrigin từ RenderBox của screen; plugin lỗi
        // (vd: web không hỗ trợ) → clipboard + snackbar báo đã copy.
        final box = context.findRenderObject() as RenderBox?;
        try {
          await SharePlus.instance.share(
            ShareParams(
              text: text,
              sharePositionOrigin: box == null
                  ? null
                  : box.localToGlobal(Offset.zero) & box.size,
            ),
          );
        } catch (_) {
          await Clipboard.setData(ClipboardData(text: text));
          if (!mounted) return;
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.resultCopiedSnackBar),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      case GameNavigateToMenuEvent():
        _navigationController?.goBack();
    }
  }
```

Kèm hai import mới: `package:share_plus/share_plus.dart` +
`package:flutter/services.dart` (cho `Clipboard`).

**Bước 9 — test host compile-forced**: `required onShareResult`
trên `GameDialogLayer` bắt `test/widgets/game_dialog_layer_test
.dart` truyền callback:

```dart
              onShareResult: (_) {},
```

**Bước 10 — `flutter analyze` + `flutter test`** → **259/259**
(+0 — share không có unit test mới: reducer-arm khớp shape
`reduce` hiện có; plugin path không test được trong suite — xem
Tự làm để tự viết reducer test scratch; `onShareResult: (_) {}`
chỉ là vá call-site).

## Hiểu code — năm chi tiết dễ trượt

1. **Chuỗi share build ở layer, không phải VM.** `shareResult
   Message(amount)` cần cả `l10n` (context) *và* `data.earnedAmount`
   — layer là điểm duy nhất có cả hai. VM chỉ nhận `String` thô
   → VM/contract giữ sạch khỏi `AppLocalizations` (A-16).
2. **`_handleUiEvent` → `Future<void>` an toàn.** `listen` chấp
   nhận `void Function`; truyền `Future<void> Function()` vẫn gán
   được — Future "lơ lửng" cố ý (share/clipboard là fire-and-
   forget, không ai await kết quả).
3. **`findRenderObject` trên *screen* context, không phải dialog.**
   Anchor phải là vùng hiển thị ổn định — dialog có thể đã pop.
   `box == null → null` (vẫn compile, iPad chỉ cần anchor khi
   sheet hiện).
4. **Fallback *trong* `catch`, không else.** `Clipboard` chỉ chạy
   khi `share` throw — web/unsupported → user vẫn copy được.
   `!mounted` re-guard sau `await` vì sheet có thể đóng-cùng-pop.
5. **`state` không đổi trong reducer arm.** Share là side-effect
   thuần — `_result(state, effects:…)` giữ nguyên instance;
   dialog state/phase/game gì cũng không đổi. Test reducer chỉ
   assert `effects.single is GameShareResult` (Tự làm).

## Chạy và quan sát

```text
flutter analyze  → No issues found!
flutter test     → +259: All tests passed!
```

Thật-máy: end game → dialog → SHARE → share sheet bật với chuỗi
"Tôi đã thắng $X trong Flutter Accelerator AI!" — **nhưng**
`REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED`; trên web bấm SHARE
→ clipboard + snackbar "Đã sao chép kết quả".

## Thử nghiệm

Trong reducer arm, đổi `effects: [GameShareResult(text)]` thành
`_result(state.copyWith(…))` — ví dụ mark `shareCount++`. Có đúng
mental model không? Vì sao senior *không* làm vậy?

<details>
<summary>Đáp án</summary>

Sai mental model: share là **side-effect** (mở sheet OS), không
phải state-game. Đổi `state` → mọi `reduce(GameShareRequested)`
phải trả state mới → test break + persist/serialize share-count
vào save chain không cần thiết. Senior giữ `state` nguyên:
reducer chỉ *định tuyến* intent → effect; state là truth của
*game*, share-sheet là truth của *platform*.
</details>

## Lỗi hay gặp

1. **`Share.share(text)` / `SharePlus.instance.share(text)`** —
   API cũ/nhầm: v13 dùng `ShareParams` object — `SharePlus.
   instance.share(ShareParams(text: …))`.
2. **Build chuỗi share trong VM** — VM không có context/l10n;
   chuỗi phải sinh ở layer (widget).
3. **`sharePositionOrigin` truyền box của dialog** — dialog có thể
   đã pop khi sheet mở; anchor phải là *screen* RenderBox.
4. **Quên `!mounted` sau `await Clipboard.setData`** — sheet đóng
   pop route → snackbar vào context chết → crash; file có re-guard.
5. **Bỏ catch vì "share không lỗi"** — web/unsupported throw; user
   bấm SHARE im lặng không gì xảy ra nếu thiếu fallback.

## Tự làm — PRODUCE

Viết reducer test scratch (file `test/` tạm hoặc DartPad-style
`test` block) assert `GameShareRequested`:

```dart
test('share requested → state giữ nguyên + effect GameShareResult',
    () {
  final result = reducer.reduce(
    initialState,
    const GameShareRequested('Tôi đã thắng \$5,000!'),
  );

  // điền 3 expect
});
```

<details>
<summary><strong>Đáp án</strong></summary>

```dart
  expect(result.state, same(initialState));        // state không đổi
  expect(result.effects, hasLength(1));
  final effect = result.effects.single as GameShareResult;
  expect(effect.text, 'Tôi đã thắng \$5,000!');
```

Suite shipped không có test này — đây là lỗ hổng coverage bạn tự
bù (reducer-arm là pure-data nên test được mà không cần plugin).
Bài 6 nhắc lại vì sao senior không thêm: contract assert bằng
DreResult.shape đủ, VM path được widget test gánh.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** sáu mắt của share? — **Đáp:** `_DialogShareButton`
  → layer build text → `viewModel.shareResult` → `GameShare
  Requested` → reducer → `GameShareResult` → bridge → `GameShare
  ResultEvent` → screen `SharePlus`/`Clipboard`.
- **Hỏi:** vì sao share qua effect thay vì dialog gọi plugin? —
  **Đáp:** (1) widget không import plugin (A-35); (2) screen có
  `RenderBox` đúng cho anchor + `ScaffoldMessenger` cho fallback;
  (3) reducer phát *data* → testable không cần OS.
- **Hỏi:** `sharePositionOrigin` để làm gì? — **Đáp:** anchor Rect
  cho popover iPad (bắt buộc); Android/phone ignore — screen
  `localToGlobal(Offset.zero) & box.size`.
- **Hỏi:** web bấm SHARE được gì? — **Đáp:** `share` throw →
  catch → `Clipboard.setData` + snackbar `resultCopiedSnackBar`.

## Ta cố ý chưa thêm

- `GameDialogButton` gradient/glow/icon + `shareColor` token —
  **M28** (visual parity FR-32/FR-34); `_DialogShareButton` là
  scaffold đã-caution.
- Share có ảnh/screenshot (`ShareFiles`) — senior chỉ text.
- iPad popover verify thật — không device (Bài 6 honesty note).
- Share analytics/đếm lượt — senior không track.
- Test VM cho share path (share qua effect chứ không state —
  reducer test scratch ở Tự làm đủ chứng minh contract).

## Checkpoint hoàn thành

- [ ] ARB có đủ 4 key share (en+vi, đúng placeholders
  `{amount}`/`{message}`).
- [ ] `GameShareRequested`/`GameShareResult`/`GameShareResultEvent`
  ba `final class` verbatim; reducer + bridge arm verbatim.
- [ ] `shareResult` wrapper trong VM; `onShareResult: viewModel.
  shareResult` tại `GameDialogLayer` call-site.
- [ ] `_DialogShareButton` tồn tại kèm caution-scaffold note;
  color `#325DFA`/`statGreen` đúng variant.
- [ ] Screen `_handleUiEvent` là `Future<void>` + share arm có
  `findRenderObject` + `ShareParams` + Clipboard-fallback +
  `!mounted` re-guard.
- [ ] `flutter analyze` sạch; `flutter test` **259/259**;
  `flutter build web` xanh.
