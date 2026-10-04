---
title: "M21 — Dialog layer trong Stack & xử lý back"
description: "5 bài: dialog-là-state (không phải route) → GameDialogLayer + backdrop → AnimatedSwitcher + ValueKey(runtimeType) → PopScope/_handleRouteBack + retire scaffold → tests + regression. Kết quả: không còn showDialog trong màn chơi; 9 variant render in-tree đúng senior."
sidebar:
  order: 0
  label: Tổng quan M21
---

# M21 · Dialog layer trong Stack & xử lý back

M19–M20 đã cho `dialogState` đầy đủ 9 variant — nhưng *cách hiển thị*
vẫn là scaffold tạm: `showDialog` đẩy một route, `_GameDialogHost`
đọc state bên trong route, `GameDialogRequested` báo "xin mở", và
khi back hệ thống pop route dialog, bridge phải *vá* lại bằng
`_showCurrentDialog` + `_dialogOpen`. M21 thay toàn bộ cơ chế đó
bằng đúng kiến trúc senior: **dialog render in-tree trong `Stack`
của màn hình**, lái hoàn toàn bởi `vm.dialogState`.

:::note[Dialog-layer đóng ở đây]
Từ M15 tới M20 dialog của learner là `AlertDialog` trong route
`showDialog` — đúng chức năng nhưng sai *cơ chế* so với senior.
M21 là điểm hội tụ đã hẹn: cùng một `dialogState`, khác hẳn phần
trình bày.
:::

## Bản đồ bài học

| Bài | Nội dung | Checkpoint |
|-----|----------|-----------|
| [01](/m21/01-dialog-la-state-khong-phai-route/) | Tại sao `showDialog` ngừng scale ở 9 variant; mental model "dialog = widget có/không theo state" (CORE) | hiểu model — chưa code |
| [02](/m21/02-game-dialog-layer/) | `GameDialogLayer` skeleton: `Positioned.fill` + `IgnorePointer` + backdrop blur + tap-outside rules; 9 view port từ host cũ | analyze sạch, **150/150** |
| [03](/m21/03-animated-switcher-va-keyed-transitions/) | `AnimatedSwitcher` + `ValueKey(runtimeType)` + fade/slide + `disableAnimations` (CORE) | **153/153** |
| [04](/m21/04-popscope-va-back-handling/) | Lắp layer vào `Stack` màn; `PopScope` đầy đủ; `_handleRouteBack` senior; retire scaffold + `GameDialogRequested`; `_afterExit` | **153/153** |
| [05](/m21/05-tests-regression-tu-lam/) | Hoàn thiện layer test (10 tests kiểu senior) + regression + PRODUCE variant mới end-to-end | **157/157** + build |

## Kết quả sau M21

- `game_screen.dart` **không còn `showDialog`** — mọi dialog là node
  trong `Stack`, lái bởi `dialogState`.
- `GameDialogRequested` bị xóa khỏi `GameScreenUiEvent` — "mở dialog"
  chỉ là đổi state, không cần event một-lần.
- Back hệ thống đi qua `PopScope` → `_handleRouteBack`: không dialog →
  xác nhận thoát; thang tiền/kết thúc → bỏ qua; còn lại → đóng dialog.
  Không route nào bị pop lén.
- Chuyển variant animate (fade + slide), mutation cùng variant
  (AI loading→kết quả) **không** re-animate — nhờ `ValueKey(runtimeType)`.
- `MediaQuery.disableAnimations` → motion tắt hẳn (a11y).

## Điều milestone này cố ý chưa làm

- Card dialog vẫn là chrome đơn giản (title + body + TextButton) —
  `GameDialogShell` gradient/sheen/SVG của senior đến **M28**.
- Dialog *menu* (settings, sign-out…) vẫn `showDialog` — `MenuDialogLayer`
  đến **M29**.
- Nút share trên dialog kết quả chưa có — **M27**.
- `hasSavedResult`/persist kết quả — **M22**; DRE — **M26**.

## Checkpoint tổng kết

- [ ] `flutter analyze` sạch; `flutter test` **157/157**;
  `flutter build web` xanh.
- [ ] `grep showDialog lib/screens/game_screen.dart` → 0 kết quả
  (comment không tính).
- [ ] Chơi thử: back ở mỗi loại dialog đúng luật; tap nền chỉ đóng
  dialog được-phép; animation mượt; máy ảo reduced-motion thì swap
  tức thì.

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** Dialog-route vs in-tree layer; `AnimatedSwitcher`
   + key-identity; backdrop/`IgnorePointer`/opaque-tap; `PopScope` + bảng quyết định back của senior.
2. **Giải thích được?** Vì sao 10 emit-site `GameDialogRequested` là
   mùi code; vì sao `ValueKey(runtimeType)` (không phải index/payload)
   là đúng key; vì sao terminal action phải chờ animate-out
   (`_afterExit`); vì sao back KHÔNG pop route dialog nữa.
3. **Chuyển được?** Thêm một variant mới end-to-end (state → arm →
   rule dismiss → nút VM) và debug được bug key-trùng/IgnorePointer.
