---
title: "M09 — Trọn vẹn một ván game"
description: GamePhase/GameEndReason enum, Timer đếm ngược, kết thúc ván (sai/hết giờ/thắng), showDialog kết quả, và popUntil về menu.
sidebar:
  label: Tổng quan M09
  order: 0
---

## Kết quả sau milestone này

`GameScreen` trở thành **một ván game thật, trọn vẹn trong một màn hình**:

- Mỗi câu hỏi có **đồng hồ đếm ngược 15 giây** — gần hết giờ chuyển đỏ.
- Chốt đáp án → **reveal** đúng/sai → bấm **TIẾP**.
- **Đáp án sai** hoặc **hết giờ** → ván chơi kết thúc (dialog "KẾT THÚC" /
  "HẾT GIỜ!").
- Đúng hết 4 câu → dialog **"CHIẾN THẮNG!"**.
- Dialog có hai nút: **CHƠI LẠI** (reset phiên tại chỗ) và **VỀ MENU**
  (gỡ cả dialog lẫn route game).

Đây là lần đầu state của màn hình phức tạp thật: ba phase loại trừ lẫn
nhau, một `Timer` phải quản lý vòng đời, và một route thứ ba (dialog) nằm
trên stack. File `game_screen.dart` giờ ~580 dòng — chính độ rối này là
lý do **M11+ (ViewModel)** tồn tại; ta cố ý chưa tách để bạn cảm nhận nỗi
đau trước.

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [GamePhase & Timer đếm ngược](/m09/01-game-phase-va-timer/) | `enum GamePhase`/`GameEndReason`, `Timer.periodic`, quy tắc cancel/dispose |
| 2 | [Máy trạng thái của phiên chơi](/m09/02-phase-flow/) | `submit→revealing→finish`, ba nhánh sau reveal, `_restart`, phase-guard |
| 3 | [showDialog & popUntil](/m09/03-showdialog-va-popuntil/) | Dialog là route, `barrierDismissible`, `switch` trên enum, `popUntil(route.isFirst)` |
| 4 | [Test phiên game có Timer](/m09/04-test-game-session/) | `pump(Duration)` nhảy đồng hồ ảo, test dialog/route, test phát hiện overflow thật |

## Khái niệm được giới thiệu

- **Dart:** `Timer.periodic` / `timer.cancel()`, `switch` statement trên
  enum (analyzer cảnh báo khi thiếu case), enum-nullable
  (`GameEndReason? _endReason`).
- **Flutter:** `showDialog`, `AlertDialog` (title/content/actions),
  `Navigator.popUntil`, vòng đời `initState`/`dispose` gắn với tài nguyên
  ngoài widget tree.
- **Kiến trúc:** phase machine tối giản — một biến `GamePhase` thay cho
  mớ bool rời rạc; mọi hành vi (chọn/chốt/tiếp/restart) là *transition*
  giữa các phase.

## Tiêu chí hoàn thành

- Đồng hồ 15→0 đếm được, đổi đỏ khi ≤5s; hết giờ tự kết thúc ván.
- Sai đáp án → dialog KẾT THÚC; đúng hết → CHIẾN THẮNG!; CHƠI LẠI reset
  sạch; VỀ MENU quay menu.
- `flutter test` xanh gồm cả test timeout/victory/pop-route.
- Vẫn chưa có: persistence, ViewModel, Provider, lifeline, thang điểm —
  đó là M10 trở đi.

## Tổng kết M09 — tự kiểm tổng hợp

- **Tôi học được gì?** `Timer`/`Timer.periodic`, `showDialog`,
  `Navigator.pop` đóng route/dialog, reset session.
- **Tôi giải thích được gì?** Chủ sở hữu hủy `Timer` trong `dispose`
  (bài Tự làm — `setState() after dispose`); dialog là route → pop
  trả value về caller.
- **Tôi viết được gì không copy?** Phát hiện timer-leak trong đoạn
  code lỗi và viết đúng một dòng fix.
- **Nếu X đổi thì sao?** `pop` ở root — `maybePop` an toàn hơn thế
  nào? (maybePop check `canPop`; pop thô ở root có thể đóng app.)
- **Concept cần lại sau:** `dispose`-ownership — subscription M13/M14;
  `pop(result)` — kết quả ván chơi đi về menu M10+.
