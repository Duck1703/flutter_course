---
title: "M22 — Lưu kết quả & lên cấp"
description: "5 bài: save-ownership chuyển vào game VM → LevelConfig bảng milestone → MenuLevelProgress derived view → _emitWithSaveResult + hasSavedResult + retire GameResult transport → regression + biên M23."
sidebar:
  order: 0
  label: Tổng quan M22
---

# M22 · Lưu kết quả & lên cấp

Từ M10, learner "trả kết quả" bằng `Navigator.pop(GameResult)` và để
menu save — một scaffold tiện cho lúc chưa có repository. Sau M14
(contract + stream) và M19–M21 (game session đầy đủ), scaffold đó
đã trở thành **đường phụ sai ownership**. M22 dời save về đúng chỗ
senior đặt: trong game VM, tại boundary của transition kết thúc —
một lần duy nhất nhờ cờ `hasSavedResult`.

:::note[Scaffold cũ đóng ở đây]
- `expForNextLevel` (field lưu thừa) → xoá; ngưỡng suy qua `LevelConfig`.
- EXP = `earnedAmount` (tiền), không còn `correctAnswers × 50`.
- `GameResult` route transport → retire; menu đọc stream.
:::

## Bản đồ bài học

| Bài | Nội dung | Checkpoint |
|-----|----------|-----------|
| [01](/m22/01-ket-qua-la-ghi-db/) | Mental model: save là hiệu ứng cạnh của transition; `hasSavedResult`; stream→menu (CORE) | hiểu model — chưa code |
| [02](/m22/02-level-config/) | `LevelConfig` port + config table + `while` thăng cấp | 164/164 |
| [03](/m22/03-menu-level-progress/) | `MenuLevelProgress` derived view + `_LevelCard` rewire | 169/169 |
| [04](/m22/04-vm-save-mot-lan/) | Atomic cut: repo ctor + `_emitWithSaveResult` + `_saveGameResult` + xoá `GameResult` transport | 168/168 |
| [05](/m22/05-regression-va-m23-boundary/) | Grep-zero scaffold, parity table, ranh giới M23 | 168/168 + build web |

## Kết quả cuối milestone

- Chơi xong một ván (thắng/thua/walk-away/thoát) → profile ghi DB
  **đúng một lần**, menu cập nhật tức thì qua stream.
- Level/EXP đi theo bảng milestone thật của senior (×1.5 ở 5/10/15,
  ×2 ở 30/50/70/80, ×3 ở 20/40/60, ×4 ở 90, ×5 ở 100; trần 100).
- `UserProfileData` còn đúng 9 field — bản sao field-set của senior.

## Điều milestone này cố ý chưa làm

- `_syncSavedGameResult` chỉ là stub `debugPrint` — sync Supabase
  + auth check là **M24/M25** (chưa có `AuthRepository`/
  `UserProfileSyncRepository` trên ctor).
- VM chưa là DRE — `_emitWithSaveResult` mô phỏng `_withSaveResult`,
  asyncOp queue thật là **M26**.
- `shareResult`/`GameShareResultEvent` — **M27**.
- Card level trên menu vẫn là `_LevelCard` đơn giản; ring/glass/
  tier-gradient của `LevelProgressCard` + `menuMaxLevelReached`/
  `menuExpToNextLevel` label là **M28**. Ở max level, bar text
  sẽ lộ `maxExpRequirement` thô — cosmetic sót lại, đã ghi nhận.

## Checkpoint tổng kết

- [ ] `flutter analyze` sạch; `flutter test` **168/168**;
  `flutter build web` xanh.
- [ ] Grep `GameResult|buildGameResult|resolvedResult|applyGameResult|
  expForNextLevel|gainExp` trong `lib/` → không còn declaration/
  reference thực thi (chỉ comment milestone-tagged + 2 local var
  cố ý trong `_applyLevelProgression`/`_LevelCard`).
- [ ] Chơi thử: thắng → menu +EXP/+gamesWon; walk-away → +tiền
  đúng `_walkAwayAmount`, gamesWon KHÔNG tăng; thoát sớm →
  `gamesJoined`+1, EXP 0; restart app → stats giữ nguyên.

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** Save-ownership trong VM + `hasSavedResult`;
   `LevelConfig` bảng milestone-multiplier; `MenuLevelProgress`
   derived view-model; `unawaited` fire-and-forget tại
   boundary; `copyWith(clear*)` cho flag nhất-thời.
2. **Giải thích được?** Vì sao `GameResult` route-pop sai ownership;
   vì sao guard phải check state hiện hành VÀ cờ phải được ghi vào
   state đã emit; vì sao
   `questionCount = questionIndex + 1` (đến, không phải đúng); vì
   sao walk-away `isWin: false` dù phase `victory`; vì sao EXP =
   `earnedAmount` chứ không phải số câu đúng.
3. **Viết lại không copy?** Tự làm: DEBUG quên-set-cờ (Bài 4) +
   PRODUCE test thoát-trước-safe-haven (Bài 5).
4. **Nếu … thì sao?** Bỏ `hasSavedResult` → gameOver rồi back ra
   menu save 2 lần (`gamesJoined` +2); emit `next` quên
   `copyWith(hasSavedResult: true)` → cờ mãi `false`, backToMenu
   save lần 2; quên `flushMicrotasks` trong test → `saveCallCount
   == 0` dù code đúng.
5. **Cần ở đâu sau?** M25 biến `_syncSavedGameResult` stub thành
   sync thật; M26 đưa `_emitWithSaveResult` về `_withSaveResult`
   op trong reducer; M28 dùng `progress.tier`/`formatted*` lái
   `LevelProgressCard` mới.
