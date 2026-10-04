---
title: "Bài 1 · Kết quả là ghi-DB, không phải route-pop"
description: "Mental model M22: ai sở hữu 'kết quả ván' — VM lưu thẳng vào repository tại transition kết thúc, cờ hasSavedResult chặn ghi lặp, menu đọc lại qua stream. Route pop trần; GameResult transport retire."
sidebar:
  label: "Bài 1 · save trong VM"
  order: 1
---

## Mục tiêu

- Nắm được mental model của senior: **kết quả ván là một lần GHI
  vào repository**, không phải một object quay về qua
  `Navigator.pop`.
- Hiểu cờ `hasSavedResult` — vì sao cần, nó chặn lỗi gì.
- Đọc được bản đồ 4 điểm kết thúc ván → payload save tương ứng.

Bài này **chưa sửa code** — nó xây mô hình để Bài 2–4 code theo đúng
hướng thay vì "thêm feature".

## Bạn đang ở đâu

- M14: `UserProfileRepository` contract + `ValueStream` đã vào app;
  menu VM subscribe stream (đúng senior).
- M19–M21: game VM + `GameSessionState` + `GameDialogLayer` đã
  senior-shape.
- Nhưng **kết quả ván** vẫn đi đường tạm (M10 scaffold): VM build một
  `GameResult`, route `pop(result)`, menu `applyGameResult(result)`
  rồi mới save. M22 dời toàn bộ trách nhiệm đó về game VM — đúng chỗ
  senior đặt nó.

## Vì sao việc này quan trọng ngay bây giờ

Có ba lý do senior **không** trả kết quả qua route:

1. **Ownership.** "Kết quả ván" là hệ quả của *game session* — chỉ
   game VM biết chắc `isWin`, `earnedAmount`, `questionCount` đúng
   semantics (walk-away vào phase `victory` nhưng KHÔNG phải thắng).
   Đẩy qua route bắt menu — một màn khác — tái suy nghĩa đó.
2. **Đường đi của dữ liệu đã có sẵn.** Repository stream là "nguồn
   truth" từ M14: ai ghi cũng được, mọi màn tự cập nhật. Route-pop
   là đường phụ song song — hai đường cho một dữ liệu là mầm bug
   (ai ghi trước? nếu user kill app giữa chừng?).
3. **Route result dễ mất.** Hệ điều hành có thể kill activity/route
   bất cứ lúc nào — save phải xảy ra *ngay tại transition kết thúc*,
   không chờ UI về tới menu.

:::caution[TEACHING SCAFFOLD kết thúc]
`GameResult` + `Navigator.pop(result)` + `MenuViewModel.applyGameResult`
là scaffold tạm từ M10, đã được hẹn retire ở M22. Đây là
bài học "đổi ownership dữ liệu" — không phải fix bug.
:::

## Bạn đã biết gì

- `UserProfileRepository` contract + `FakeUserProfileRepository`
  (M14).
- `ValueStream`/`.value` + "stream là nguồn truth" (M14).
- `unawaited` — fire-and-forget có chủ đích (M11 — ).
- `GameSessionState` immutable + `copyWith` + 4 transition kết thúc
  (M19–M21).
- `Navigator.pop(result)` trả giá trị về `await push` (M10 — sắp
  retire tại chính bài này).

## Mental model mới — "save là một *hiệu ứng cạnh* của transition kết thúc" (CORE)

Trong senior, reducer thuần không gọi repo — nó *đánh dấu* "transition
này cần save" bằng một async op `GameSaveResult` đi kèm state mới:

```text
điểm kết thúc ván ──► state' (hasSavedResult: true)
                    └► GameSaveResult(earned, isWin, questionCount)
                              │
                              ▼
                    VM.executeAsyncOp → _saveGameResult()
                              │
                              ▼
                    UserProfileRepository.saveUserProfile(profile')
                              │
                              ▼
                    BehaviorSubject emit ──► MenuViewModel rebuild
```

Learner M22 giữ đúng *ngữ nghĩa* đó với cơ chế đơn giản hơn (chưa có
DRE queue — đó là M26): một helper `_emitWithSaveResult(next, …)`
phát state mới + `unawaited(_saveGameResult(…))` ngay tại 4 transition.

| Điểm kết thúc | `earnedAmount` | `isWin` | `questionCount` |
| --- | --- | --- | --- |
| `_loadNextQuestionOrVictory` nhánh victory (đúng câu cuối) | `moneyEarned` | `true` | `questionIndex + 1` |
| `_endGame` (sai/hết giờ) | `guaranteedAmount` | `false` | `questionIndex + 1` |
| `confirmWalkAway` | `_walkAwayAmount` | `false` | `questionIndex + 1` |
| `backToMenu` (thoát giữa ván) | `_walkAwayAmount` | `false` | `questionIndex + 1` |

Ba chi tiết senior dễ trượt — ghi nhớ ngay:

- `questionCount` = **số câu đã ĐẾN** (`questionIndex + 1`), không phải
  số câu trả lời đúng. Sai ở câu 2 vẫn là "đã đến 2 câu".
- Walk-away và backToMenu trả `isWin: false` — phase là `victory`
  nhưng *bản ghi* không phải thắng. Đây chính là lý do không thể suy
  `won` từ phase (bug tiềm ẩn của bản M20 từng phải vá bằng
  `resolvedResult` — giờ payload tường minh nên không cần suy nữa).
- `earnedAmount` ở walk-away là `_walkAwayAmount` — số *an toàn* theo
  `guaranteedAmount`/`moneyEarned`, không phải `moneyEarned` thô.

## `hasSavedResult` — cờ chốn "hai đường kết thúc"

Nhìn lại flow: `_endGame` đã save khi dialog kết thúc mở ra. Nhưng
nút "VỀ MENU" trên dialog đó gọi `backToMenu` — *cũng* là một
transition kết thúc mang `GameSaveResult` trong senior. Không có
guard, mỗi ván thua sẽ bị ghi **hai lần** (gamesJoined +2, EXP ×2).

Senior chặn bằng `hasSavedResult` trên state — **idempotence flag**:

```text
_withSaveResult(state, …):
    if (state.hasSavedResult) → chỉ state', không op
    else → state'.hasSavedResult = true  +  GameSaveResult op
```

Flag set *trong cùng transition* → bất kể bao nhiêu đường kết thúc
chạm nhau sau đó (backToMenu sau gameOver, double-tap ✕…), chỉ lần
đầu ghi DB. `GameSessionState.initial` reset flag → phiên mới lưu
được lại.

> **Vì sao flag ở trên state, không phải bool private trong VM?**
> Vì "đã save chưa" là *thuộc tính của phiên* — mọi đường mutation
> đều phải nhìn thấy nó. Giấu trong VM thì `copyWith`/`initial` không
> quản được vòng đời; để trong state thì flag tự reset khi phiên reset
> — cùng lý do `flowToken` sống trong state (M19).

## Android / Compose bridge

```text
SIMILARITY:           save = side-effect tại boundary ≈ gọi
                      repository.update() trong ViewModel sau khi
                      reduce state — cùng chỗ, cùng vai trò.
IMPORTANT DIFFERENCE: senior bản DRE tách op ra khỏi reducer (op
                      được *dispatch* rồi VM thực thi async). Bản
                      learner gọi thẳng — semantic giống, cơ chế
                      đơn giản hơn; DRE queue đến M26.
DO NOT ASSUME:        "pop kèm result rồi màn sau save" giống
                      startActivityForResult/onActivityResult —
                      đúng hình dáng, nhưng senior cố tình KHÔNG
                      dùng nó cho persistence vì result có thể
                      mất cùng route.
```

## Dự kiến cấu trúc sau M22

```text
GameScreenViewModel
  ├─ userProfileRepository (ctor — senior parity)
  ├─ _emitWithSaveResult(next, earnedAmount, isWin)   ← guard
  ├─ _saveGameResult(earnedAmount, isWin, questionCount)
  │     └─ _applyLevelProgression(profile, gainedExp: earnedAmount)
  │           └─ LevelConfig.getExpRequiredForLevel(level)
  └─ _syncSavedGameResult()   ← stub M25 (auth chưa có)

MenuScreen: chỉ đọc userData từ stream — KHÔNG apply gì cả.
AppNavigationController.openGame() → Future<void> (pop trần).
```

## Checkpoint

- `flutter analyze` sạch (bài này không đổi code).
- `flutter test` vẫn **157/157**.
- Tự kiểm: trả lời được — "nếu user bấm VỀ MENU trên dialog
  game-over, `saveCallCount` của repo là mấy?" (Đáp án: **1** —
  `_endGame` đã ghi; `backToMenu` thấy `hasSavedResult` nên bỏ qua.)

## Tự làm — PREDICT

Không sửa code. Cho phiên: đúng Q1–Q5 (safe haven 20k), bấm
walk-away ở Q6, xác nhận, rồi trên dialog victory bấm "VỀ MENU".

Viết ra giấy payload `_saveGameResult` được gọi (ba trường) và
`saveCallCount` cuối cùng. Sau đó đối chiếu:

<details>
<summary>Đáp án</summary>

- `earnedAmount = _walkAwayAmount` = 20000 (moneyEarned=guaranteed=20k
  ở Q6, safe-haven-aware).
- `isWin = false` — dù dialog hiển thị kiểu victory.
- `questionCount = 5 + 1 = 6`.
- `saveCallCount = 1` — `confirmWalkAway` đã ghi; `backToMenu` sau đó
  thấy `hasSavedResult` → chỉ điều hướng.

</details>

## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — thuần mental model (save = hiệu ứng cạnh của transition kết thúc; `hasSavedResult`; bảng 4 điểm kết thúc → payload). Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, xác nhận baseline còn nguyên trước khi cắt ở Bài 4:

```bash
flutter analyze   # sạch
flutter test      # 157/157 — y hệt cuối M21
```

Và cơ chế scaffold CŨ phải vẫn còn sống nguyên (chưa retire — đó là việc của Bài 4):

- `lib/data/game/game_result.dart` tồn tại.
- `GameSessionState.resolvedResult` + `clearResolvedResult` vẫn trong state file.
- `MenuViewModel.applyGameResult`, `GameScreenViewModel.buildGameResult`, `openGame` trả `Future<GameResult?>`, `Navigator.pop(result)` đều còn.
- `UserProfileData` vẫn có `expForNextLevel`/`gainExp`/`expPercent`/`expPerCorrectAnswer`.

Kiểm tra hiểu (tự trả lời): "nếu user bấm VỀ MENU trên dialog game-over, `saveCallCount` là mấy?" — đáp án: **1** (`_endGame` đã ghi, `backToMenu` thấy `hasSavedResult` → bỏ qua).

Checkpoint code sang bài sau: không file/field mới — transport route-result vẫn là cơ chế duy nhất đưa kết quả về menu.
