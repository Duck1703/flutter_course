---
title: "Bài 1 · Dialog là state, không phải route"
description: "Mental model của M21: dialog trong game không phải một màn/route bạn đi tới — nó là một widget tồn tại khi state bảo tồn tại. Checkpoint: hiểu model — chưa code."
sidebar:
  label: "Bài 1 · dialog = state"
  order: 1
---

## Mục tiêu

- Giải thích được 4 khác biệt gốc giữa **dialog route** (`showDialog`)
  và **in-tree dialog layer** (widget trong `Stack`): ownership,
  rendering, lifetime, back behavior.
- Chỉ ra được 3 "mùi" trong scaffold M19–M20 mà senior giải bằng
  in-tree layer.
- Đọc được sơ đồ `Stack[nội dung, GameDialogLayer]` và nói ai quyết
  định dialog hiện/ẩn ở mỗi lớp.

## Bạn đang ở đâu

- M20 xong: mọi dialog game đều đi qua `dialogState` (sealed 9
  variant) trong `GameScreenViewModel` — phần *state* đã đúng senior.
- Nhưng *hiển thị* vẫn là route: VM emit `GameDialogRequested` →
  bridge `_showCurrentDialog()` → `showDialog` → `_GameDialogHost`
  `ListenableBuilder` đọc `dialogState`.
- Back hệ thống pop **route dialog trước**, PopScope của trang
  không thấy gì; bridge phải vá: `action == null` → re-route theo
  variant (mở lại ladder/terminal, dismiss phần còn lại).

## Vì sao việc này quan trọng ngay bây giờ

Scaffold route hoạt động, nhưng giá của nó tăng theo số variant:

1. **Hai nguồn thật.** `dialogState` nói "dialog X đang mở", còn
   `Navigator` mới là thứ *thật sự* giữ route. Phải có cờ
   `_dialogOpen` + `GameDialogRequested` để đồng bộ hai phía —
   mỗi lệch pha là một bug "state bảo mở nhưng route đã pop".
2. **Back đi đường khác.** Back pop route dialog *im lặng* — trang
   không biết; sau đó bridge đoán ý định từ variant cũ (`action ==
   null → switch`). Đúng kết quả, sai đường: người đọc phải hiểu
   hai nơi mới thấy trọn luật back.
3. **10 emit-site.** Mỗi chỗ `_emit(copyWith(dialogState: …))` phải
   kèm `emitEvent(GameDialogRequested)` — quên một chỗ là dialog
   không bao giờ lên. Event "xin mở" tồn tại chỉ vì cơ chế route
   *cần ai đó đẩy route* — với in-tree layer nó dư thừa hoàn toàn.

## Bạn đã biết gì

- Sealed class + switch kiệt hợp (M15); `dialogState` 9
  variant (M19–M20).
- `Stack` + `Positioned.fill` làm overlay trong màn (M18).
- Event một-lần vs state (M13); `PopScope` dạng tối thiểu
  `canPop:false` + `onPopInvokedWithResult` (M19).
- `Navigator.push/pop` route (M06/M10).

## Mental model mới — "dialog = projection của state"

> **Route dialog:** bạn *đi tới* một màn — ai đó phải gọi
> `Navigator.push`, route sống trong stack điều hướng, back pop nó.
>
> **In-tree layer:** không có chuyện "đi tới". `Stack` của màn chơi
> luôn chứa `GameDialogLayer` làm con trên cùng; layer đọc
> `dialogState` và trả widget tương ứng — `Hidden` → SizedBox rỗng
> (không vẽ gì), `ConfirmExit` → card confirm. Dialog "mở" = state
> đổi → rebuild; "đóng" = state về `Hidden`. Back không pop gì —
> `PopScope(canPop:false)` bắt mọi back và hỏi VM.

| Chiều | Route `showDialog` | In-tree `GameDialogLayer` |
| ------- | -------------------- | --------------------------- |
| Chủ sở hữu hiển thị | `Navigator` (route stack) | Widget tree / `Stack` |
| Ai mở? | event + `showDialog()` | `dialogState` đổi → rebuild |
| Lifetime | Route entry tách khỏi cây | Cùng lifecycle màn chơi |
| Back | pop route trước, PopScope trang không thấy | `PopScope` thấy MỌI back → hỏi VM |
| Test | đếm route / `Navigator.pop` | pump state mới, assert text |

Đây là phần quan trọng nhất: senior không chọn in-tree vì "đẹp
hơn" — chọn vì **dialog state đã là nguồn thật**, nên phần hiển thị
phải là projection thuần của nó. Route + event là lớp dán chỉ tồn
tại để *mô phỏng* điều mà in-tree làm tự nhiên.

## Dart/Flutter cần dùng — xuất hiện đầu tiên

Không có syntax mới ở bài này — toàn concept. Bài 2–4 mới có
`AnimatedSwitcher`, `ValueKey(Type)`, `BackdropFilter`.

## Ví dụ độc lập (CORE)

Đừng nhìn game vội. Ví dụ 40 dòng tự chứa — một "overlay" đồ chơi:

```dart
sealed class OverlayState { const OverlayState(); }
final class OverlayHidden extends OverlayState {
  const OverlayHidden();
}
final class OverlayConfirm extends OverlayState {
  const OverlayConfirm();
}

class MiniScreen extends StatelessWidget {
  final OverlayState overlay;      // ← "dialogState" thu nhỏ
  final VoidCallback onDismiss;
  const MiniScreen({required this.overlay, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Center(child: Text('NỘI DUNG GAME')),   // lớp dưới
        Positioned.fill(                                // lớp trên
          child: IgnorePointer(
            ignoring: overlay is OverlayHidden,         // hidden → xuyên
            child: overlay is OverlayConfirm
                ? ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: onDismiss,
                        child: const Text('ĐÓNG'),
                      ),
                    ),
                  )
                : const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}
```

Ba điểm cần thấy:

- **Không `Navigator`, không event.** "Mở" = `overlay` đổi từ
  `OverlayHidden` → `OverlayConfirm`; widget khác → cây khác.
- **`Positioned.fill` + `IgnorePointer`.** Lớp overlay luôn nằm
  trong `Stack` — khi `Hidden` nó *phải* để tap xuyên xuống game
  (`ignoring: true`), khi có dialog nó chặn mọi tap vào nền.
- **`Stack` order = z-order.** Con sau vẽ trên con trước — dialog
  đặt cuối `children` để luôn trên nội dung.

GameDialogLayer của senior là đúng shape này, chỉ thêm backdrop
blur, `AnimatedSwitcher`, và 9 arm thay vì 1.

## Android / Compose bridge

```text
SIMILARITY:           Giống `if (state.dialog != null) { Dialog() }`
                      render trong cùng composition — recomposition
                      điều khiển hiện/ẩn, không cần Fragment/Intent.
IMPORTANT DIFFERENCE: Flutter `showDialog` đẩy ROUTE THẬT lên
                      Navigator — nó sống trong lịch sử điều hướng,
                      có transition route, và back xử nó trước khi
                      chạm trang. Đó không phải "dialog composition".
DO NOT ASSUME:        `showDialog` ≠ `Dialog()` composable. Muốn
                      kiểu Compose (render-theo-state), bạn tự đặt
                      dialog widget trong Stack — senior làm vậy.
```

## Senior project connection

| Senior (đọc được ở) | Vai trò |
| --- | --- |
| `lib/screens/game_screen.dart` — `Stack[..., GameDialogLayer]` | layer là con cuối, trên cùng |
| `lib/widgets/game/dialogs/game_dialog_layer.dart` | `Positioned.fill` → `IgnorePointer` → `AnimatedSwitcher` → backdrop → view theo variant |
| `lib/data/game/game_session_state_data.dart` — `GameScreenUiEvent` | chỉ `{GameNavigateToMenuEvent, GameShareResultEvent}` — **không** có event mở dialog |

## Chạy và quan sát

Bài này không đổi code — chỉ xác nhận baseline trước khi phá:

```bash
cd learner-app
flutter analyze        # No issues found
flutter test           # 147/147
```

Mở `lib/screens/game_screen.dart` hiện tại, tìm `_showCurrentDialog`
và đếm số chỗ `emitEvent(GameDialogRequested)` trong
`game_screen_view_model.dart` — 10 chỗ. Đó là "giá route" mà M21
trả xong ở Bài 4.

## Thử nghiệm — đoán trước khi chạy

:::note[PREDICT]
Với bản route hiện tại: dialog confirm-exit đang mở, bạn bấm
back hệ thống. Theo dõi đúng thứ tự: cái gì pop trước, PopScope
trang có chạy không, `dialogState` đổi khi nào?
:::

<details><summary>Đáp án</summary>

Back pop **route dialog trước** (nó là top-most route) →
`showDialog` future trả `null` → `_dialogOpen=false` → nhánh
`action == null` → variant là `ConfirmExit` → `dismissDialog()`
→ `dialogState` về `Hidden`. `PopScope` của trang **không chạy**
— back đã bị route nuốt. Đây chính là đường-vòng mà in-tree xóa:
Ở bản senior, PopScope thấy back ngay và `_handleRouteBack` đọc
`dialogState` — một nguồn, một nơi quyết định.

</details>

## Lỗi hay gặp

- **Nghĩ `showDialog` và dialog-in-Stack tương đương.** Không —
  route là entry trong navigator, có transition + pop riêng; widget
  trong Stack là node trong cây màn. Back/test/ownership đều khác.
- **Quên `IgnorePointer`.** Layer phủ full màn — thiếu nó, lúc
  `Hidden` vùng "trong suốt" vẫn nuốt tap của đáp án.

## Tự làm (RECOGNIZE)

:::note[Bài tập]
Không sửa code. Chỉ ra trong `game_screen.dart` hiện tại **ba nơi**
mà cơ chế route tạo code mà in-tree không cần: (a) cờ đồng bộ, (b)
đoạn vá sau pop, (c) phương tiện kích hoạt dialog.
:::

<details><summary>Đáp án</summary>

(a) `var _dialogOpen = false` — cờ nhớ "route đang mở" chỉ vì
Navigator và `dialogState` là hai nguồn; (b) nhánh `action == null`
trong `_showCurrentDialog` — vá lại hành vi back mà PopScope của
trang đáng lẽ xử trực tiếp; (c) `GameDialogRequested` +
`addPostFrameCallback` — event chỉ tồn tại để *push route*, kèm
ràng buộc "không push giữa build". In-tree xóa cả ba.

</details>

## Kiểm tra hiểu biết

1. `dialogState` là `GameDialogHidden` nhưng `IgnorePointer` bị
   bỏ quên — điều gì xảy ra với nút đáp án? *(Câu trả lời: layer
   trong suốt vẫn nuốt tap — SizedBox.expand hit-test full màn.)*
2. Vì sao "mở dialog" không cần event trong kiến trúc in-tree?
   *(Vì render là hệ quả của rebuild khi state đổi — không có
   `push` cần kích hoạt.)*
3. Một variant terminal (kết thúc) đang hiển; user bấm back. Ở bản
   in-tree, ai trả lời back? *(`PopScope` → `_handleRouteBack` →
   thấy terminal → bỏ qua — bắt buộc chọn nút.)*

## Ta cố ý chưa thêm

- Chưa code gì — Bài 2 mới tạo file layer.
- Chưa bàn `AnimatedSwitcher`/`ValueKey` — Bài 3.
- Back semantics chi tiết (`_handleRouteBack` từng nhánh,
  `_afterExit`) — Bài 4.

## Checkpoint hoàn thành

- [ ] Giải thích được "dialog = projection của `dialogState`" và
  chỉ ra 3 mùi của scaffold route.
- [ ] `flutter analyze` + `flutter test` vẫn **147/147** (chưa động
  gì — baseline sạch trước khi phá).
