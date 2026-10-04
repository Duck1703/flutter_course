---
title: "M19 — Kiến trúc game có cấu trúc: GameScreenViewModel"
description: "6 bài: mental model máy trạng thái → nền data mới + xé màn cũ → presentation mapper → GameScreenViewModel (CORE) → migration màn hình + PopScope + nav controller → tests + regression. Kết quả: game chạy trên state machine 6 phase, timer 30s do VM sở hữu, thang tiền 15 bậc thật."
sidebar:
  order: 0
  label: Tổng quan M19
---

# M19 · Kiến trúc game có cấu trúc — GameScreenViewModel

Đây là milestone lớn nhất từ đầu course: màn chơi 600+ dòng tự giữ
mọi state được **xé ra** và dựng lại theo kiến trúc senior —
`GameScreenViewModel` sở hữu một **máy trạng thái** 6 phase, state
bất biến đổi qua `copyWith`, timer `Timer.periodic` 30 giây do VM
điều khiển, thang tiền 15 bậc thật với mốc an toàn, và UI chỉ còn
một việc: render `screenData` + forward ý định người chơi.

:::caution[Đọc kỹ trước khi code]
Bài 2 *xé* `game_screen.dart` cũ và để lại một stub trống — game
"biến mất" tạm thời cho tới Bài 5. Đây là thiết kế: code cũ không
tương thích với kiến trúc mới, giữ nó sống nửa vời chỉ gây lỗi
biên dịch khó hiểu.
:::

## Bản đồ bài học

| Bài | Nội dung | Checkpoint |
|-----|----------|-----------|
| [01](/m19/01-vi-sao-widget-khong-giu-noi-game/) | Vì sao widget không giữ nổi game; máy trạng thái + ví dụ order-state | hiểu model — chưa code |
| [02](/m19/02-data-game-moi-va-xe-man-cu/) | Nền data: `GamePhase`×6, `GameSessionState`, dialog family 6 variant, question model + bank 15 câu, thang tiền, `GameResult.earnedAmount`, ARB đổi | analyze sạch, 95/95 |
| [03](/m19/03-mapper-state-sang-screen-data/) | `GameScreenData` + `buildGameScreenPresentation` — mapper thuần | +mapper test → 99/99 |
| [04](/m19/04-game-screen-view-model/) | **CORE**: `GameScreenViewModel` — dispatch methods, `Timer.periodic`, `flowToken`, explanation flow | +VM test → 116/116 |
| [05](/m19/05-man-hinh-moi-provider-bridge-popscope/) | `ChangeNotifierProvider` + event bridge + `PopScope` + `AppNavigationController` + khóa dọc | +widget test → 126/126 |
| [06](/m19/06-tests-regression-tu-lam/) | Full regression + `build web` + tự làm + tổng kết | **126/126** + build web |

## Kết quả sau M19

- Màn chơi hoạt động trên **máy trạng thái 6 phase**
  (`notStarted → playing → answeredPending → answeredRevealed →
  gameOver/victory`) thay cho 3 phase lỏng của M09.
- `GameScreenViewModel` (screen-scoped, `ChangeNotifierProvider`)
  sở hữu: timer 30s, điểm tiền theo thang 15 bậc, mốc an toàn
  Q5/Q10/Q15, dialog-state, mọi transition.
- UI render từ `GameScreenData` (DTO do mapper thuần suy ra) —
  widget không còn một field game nào.
- Back hệ thống → `PopScope` chặn pop, `dialogState` quyết định ý
  nghĩa nút back — không còn "pop trần mất kết quả".
- `AppNavigationController` + `GlobalKey<NavigatorState>`: điều
  hướng không cần `context`, app khóa dọc.
- Ngân hàng câu hỏi thật của senior: **15 câu** (5 easy / 5 medium /
  5 hard) với giải thích per-answer.

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** Máy trạng thái hữu hạn làm model session;
   immutable `GameSessionState` + `copyWith` + `clear*` flag; VM sở
   hữu `Timer.periodic` và delay bằng `flowToken`; presentation
   mapper tách "state" khỏi "hiển thị"; `PopScope` canPop:false.
2. **Giải thích được?** Vì sao enum 6 phase thắng 4 boolean; vì sao
   `copyWith` cần flag `clearSelectedAnswer`; vì sao timer sống trong
   VM chứ không trong `State`; vì sao dialog trong `showDialog` cần
   event `GameDialogRequested` + routing lại khi bị back pop.
3. **Viết lại không copy?** Tự làm: viết test transition sai-phase
   (Bài 4) + thêm variant dialog mới (Bài 6).
4. **Nếu … thì sao?** Bỏ `flowToken` → reveal cũ ghi đè phiên mới;
   quên cancel timer trong `dispose` → leak + crash; bỏ phase-guard
   `playing` → tap đáp án lúc reveal vẫn chấm điểm.
5. **Cần ở đâu sau?** M20 lifelines gắn thẳng vào state machine này
   (`usedFeatureButtons`, `visibleOptionTexts`); M21 thay scaffold
   `showDialog` bằng `GameDialogLayer` trong `Stack`; M26 đổi
   `ChangeNotifier` → DRE (actions/effects tách khỏi VM).

## Còn lại sau M19 (đã register)

- FR-04: `openGame()` trả `GameResult` qua pop — VM-side save ở M22.
- FR-07: dialog layer `showDialog` — in-`Stack` layer ở M21.
- FR-33: `GameShareResultEvent`/SharePlus — milestone chưa gán.
- DRE (`DreChangeNotifier` + reducer thuần) — M26 theo roadmap.
