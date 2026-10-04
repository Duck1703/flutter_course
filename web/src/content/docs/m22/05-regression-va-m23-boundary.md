---
title: "Bài 5 · Regression tổng & biên M23"
description: "Kiểm chứng toàn cục M22: grep-zero các scaffold đã retire, bảng parity senior↔learner cho từng đường save, đọc 168/168 không hồi quy, và đặt ranh giới M23 (Supabase bootstrap) trước khi sang milestone kế."
sidebar:
  label: "Bài 5 · regression + M23"
  order: 5
---

## Mục tiêu

- Chạy bộ kiểm chứng tổng: `analyze` + `test` + `build web` + grep
  các symbol đã retire.
- Đọc hiểu bảng parity save-path senior ↔ learner (DRE asyncOp vs
  `unawaited` call).
- Biết M22 *không* làm gì: sync/auth stub, ring visual, DRE queue —
  và milestone nào sở hữu chúng.

## Bạn đang ở đâu

- Bài 4 đã cắt xong: save trong VM, transport route-result chết,
  model profile đúng 9 field senior.
- Đây là bài "nhìn lại toàn cục" trước khi sang M23 — thói quen
  cuối mỗi milestone: chứng minh regression + ghi lại ranh giới.

## Vì sao việc này quan trọng

Một migration chỉ "xong" khi chứng minh được **cái cũ đã chết hẳn**
và **cái mới làm đúng hơn cái cũ**. Suite xanh là cần thiết nhưng
chưa đủ — cần thêm grep-zero (không còn ai gọi scaffold) và parity
table (mọi con số khớp senior).

## Bảng parity — 4 đường save

| Trigger | Senior (DRE) | Learner M22 | `earnedAmount` | `isWin` | `questionCount` |
|---|---|---|---|---|---|
| Thắng câu cuối | `_loadNextQuestionOrVictory` nhánh victory → `GameSaveResult` op | `_loadNextQuestionOrVictory` → `_emitWithSaveResult` | `moneyEarned` | `true` | `questionIndex+1` |
| Sai/hết giờ | `_endGame` → op | `_endGame` → `_emitWithSaveResult` | `guaranteedAmount` | `false` | `questionIndex+1` |
| Dừng cuộc | `_confirmWalkAway` → op | `confirmWalkAway` → `_emitWithSaveResult` | `_walkAwayAmount` | `false` | `questionIndex+1` |
| Về menu | `_backToMenu` → op | `backToMenu` → `_emitWithSaveResult` | `_walkAwayAmount` | `false` | `questionIndex+1` |

Guard: senior `_withSaveResult` check `state.hasSavedResult` trước
khi kèm op — learner `_emitWithSaveResult` check `_state.
hasSavedResult` trước khi `unawaited`. **Cùng ngữ nghĩa, khác cơ chế
dispatch** (op queue vs gọi hàm) — DRE queue là M26.

## Checklist chứng minh

```text
# 1. Không còn ai gọi scaffold đã retire:
grep -rn "GameResult" lib/          → 17 hit nhưng KHÔNG còn
                                      declaration/reference thực thi:
                                      chỉ tên method mới
                                      (`_saveGameResult`,
                                      `_syncSavedGameResult`) +
                                      comment milestone-tagged
grep -rn "expForNextLevel|gainExp|expPercent|applyGameResult|
          buildGameResult|resolvedResult" lib/
                                    → chỉ comment milestone-tagged +
                                      2 local var cố ý:
                                      `expForNextLevel` trong
                                      `_applyLevelProgression` (tên
                                      senior dùng) và `expPercent`
                                      trong `_LevelCard` (Bài 3)

# 2. Suite + phân tích + build:
flutter analyze       → No issues found!
flutter test          → 168/168
flutter build web     → Built build\web
```

**Đọc đúng 168:** 157 (cuối M21) + 7 (LevelConfig) + 5
(MenuLevelProgress) + 8 (persistence) − 9 (scaffold tests retire).
Con số GIẢM so với đỉnh 169 là kỳ vọng — giảm đúng các test của
scaffold đã xoá, không phải test bị làm yếu.

## Đường dữ liệu sau M22 — đọc lại một lần

```text
transition kết thúc (victory/gameOver/walkAway/backToMenu)
  → _emitWithSaveResult: flag? → emit state' + unawaited save
  → _saveGameResult: load profile → +money/+EXP(LevelConfig)/+stats
  → userProfileRepository.saveUserProfile → BehaviorSubject emit
  → MenuViewModel._handleUserProfile → notifyListeners
  → menu rebuild: _LevelCard đọc MenuLevelProgress.fromProfile
```

Không còn `GameResult`, không còn `Navigator.pop(result)`, không còn
`MenuViewModel.applyGameResult`. Menu **không biết** vừa có ván chơi
— nó chỉ render profile mới nhất. Đó là "stream là nguồn truth"
trọn vẹn.

## Ranh giới M22 — những gì CỐ Ý chưa làm

| Chưa làm | Milestone sở hữu | Vì sao |
|---|---|---|
| `_syncSavedGameResult` thật (Supabase sync + auth check) | M24/M25 | chưa có `AuthRepository`/`UserProfileSyncRepository` trên ctor |
| DRE `GameSaveResult` asyncOp + reducer queue | M26 | learner VM chưa là `DreChangeNotifier` |
| `LevelProgressCard` ring/glass/tier-gradient | M28 | visual polish — M22 chỉ cần data |
| `menuMaxLevelReached` label + `menuExpToNextLevel` | M28 | đi kèm layout mới của card |
| `shareResult` + `GameShareResultEvent` | M27 | share_plus |

:::note[Trần level 100 trên menu]
Ở `isMaxLevel`, `requiredExp = maxExpRequirement` → hàng text "5 /
9007199254740991 EXP" trông xấu. Đó là cosmetic còn sót lại — senior
che bằng card khác (`menuMaxLevelReached`) ở M28. Ghi nhận, không vá.
:::

## Checkpoint cuối milestone

- `flutter analyze` sạch; `flutter test` **168/168**;
  `flutter build web` PASS.
- Grep các scaffold (`GameResult` type, `expForNextLevel` field,
  `gainExp`, `expPercent` getter, `applyGameResult`, `buildGameResult`,
  `resolvedResult`) → không còn **declaration/reference thực thi**
  nào trong `lib/` — chỉ comment milestone-tagged kể chuyện retire
  + 2 local var cố ý nêu trên.
- Replay từ clone cuối M21 đi qua được cả 5 bài với checkpoint xanh
  ở từng bài (157 → 164 → 169 → 168 → 168).

## Tự làm — PRODUCE (sandbox, không merge)

Viết thêm một test persistence *mà senior coverage gợi ý nhưng suite
hiện chưa có*:

```dart
test('thoát giữa ván TRƯỚC safe haven → walkAway=0, vẫn save '
    'gamesJoined+1', () {
  FakeAsync().run((async) {
    final repo = FakeUserProfileRepository();
    final vm = startedVm(async, 3, repo: repo);
    addTearDown(vm.dispose);
    vm.backToMenu(); // câu 1, chưa qua mốc → earned 0
    async.flushMicrotasks();
    expect(repo.saveCallCount, 1);
    expect(repo.value.gamesJoined, 1);
    expect(repo.value.totalMoneyWon, 0);
    expect(repo.value.totalQuestionCount, 1);
    expect(repo.value.currentExp, 0);
  });
});
```

Chạy `flutter test test/game_screen_view_model_test.dart -n "TRƯỚC"`
để xanh lẻ. Bài học: "thua trắng tay" vẫn là một ván đã chơi — senior
ghi `gamesJoined` kể cả khi `earnedAmount == 0`.
