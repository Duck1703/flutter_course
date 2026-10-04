---
title: "M15 · Sealed classes & state-driven UI"
description: "Dart 3 sealed class + exhaustive switch + object patterns; seal hoá event bridge (FR-15) và dialog state game (FR-07) theo senior."
sidebar:
  label: "M15 · Sealed & state-driven UI"
  order: 15
---

# M15 · Sealed classes & state-driven UI

Milestone đầu tiên của nhóm "Dart 3 trở lên": biến các tập kiểu rời
rạc (`abstract` event + `is`-chain, `GameEndReason?` nullable) thành
**sealed hierarchies đóng** và chuyển mọi chỗ dispatch sang `switch`
kiệt hợp — đúng cấu trúc senior.

## Bài học

| # | Bài | Trọng tâm |
|---|-----|-----------|
| 1 | Vì sao cần state đóng | boolean soup → finite variants; state-driven UI là gì |
| 2 | `sealed class` | luật cùng-file, base không khởi tạo, vs abstract/enum |
| 3 | `switch` kiệt hợp + patterns | switch expression, `Type()`, `(:final field)`, `_`, exhaustiveness |
| 4 | Seal event bridge | `MenuScreenUiEvent` + `_handleUiEvent` switch (FR-15) |
| 5 | `GameDialogState` | sealed dialog state → render-by-state (FR-07 partial) |

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** `sealed class` (tập variant đóng cùng file), `switch`
   expression + object pattern `(:final field)` + wildcard `_`,
   kiệt hợp = lỗi biên dịch; UI render theo state.
2. **Giải thích được?** Vì sao nhóm cờ/field rời rạc cho phép tổ hợp
   vô nghĩa; vì sao sealed ≠ enum (payload) và ≠ abstract (đóng vs mở);
   vì sao state vẫn là state, event vẫn là event sau khi sealed.
3. **Viết lại không copy?** Tự làm: `ConnectionState` hierarchy +
   `describe()` kiệt hợp; DEBUG switch thiếu variant.
4. **Nếu … thì sao?** Thêm variant mới → mọi `switch` kiệt hợp báo
   lỗi cho tới khi xử lý — compiler là checklist.
5. **Cần ở đâu sau?** M19 máy phase + reducer; M21 dialog layer
   trong `Stack` + `ValueKey(runtimeType)`; mọi tập UI-state đóng.

Checklist kỹ thuật:

- [ ] `flutter analyze` sạch; `flutter test` 74 green; web build √.
- [ ] Event family sealed + bridge là `switch` statement kiệt hợp.
- [ ] `GameDialogState` 3-variant; dialog content = `switch`
      expression kiệt hợp; `GameDialogHidden` là variant thật.
- [ ] Demo được "xoá một case → `non_exhaustive_switch_expression`".

## Vẫn tạm / scaffold

- `showDialog`/`AlertDialog` mechanism → in-`Stack` layer ở **M21**.
- `GameDialogState` còn 3/9 variant — thêm theo feature M19–M21.
- `GamePhase` 3-value enum → máy 6-phase senior ở **M19**.

> Learner không tạo `MenuDialogState` trong M15 — menu chưa có
> dialog nào (settings M16, leaderboard M23, auth M24). Type đó đến
> cùng consumer đầu tiên của nó — không tạo sẵn type không-consumer.
