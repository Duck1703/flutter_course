---
title: "M26 — Senior Architecture: DRE Refactor"
description: "6 bài: vì sao VM mutation tay 733 dòng đạt giới hạn (+0) → core/dre primitives — marker interfaces + DreReducer + DreChangeNotifier dispatch loop (+5) → GameState/GameAction/GameEffect/GameAsyncOp + contract barrel trong view_models/game/dre/ (+0) → GameReducer + 4 part files theo flow domain (+10) → VM extends DreChangeNotifier + 2 bridge part, GameSessionState retire (+0) → regression tests ghim behavior qua refactor (+3) → 254/254. converge."
sidebar:
  order: 0
  label: Tổng quan M26
---

# M26 · Senior Architecture: DRE Refactor

Cuối M25, 
`GameScreenViewModel`
 vẫn là bản trung gian: 
`extends
ChangeNotifier`
 + 
`_emit`
/
`_schedule`
/
`_emitWithSaveResult`
 tay —
733 dòng trộn transition, timer, delay, repository và lifecycle
guard trong một file. Milestone này đưa nó về đúng kiến trúc
senior: mọi transition chạy qua 
`GameReducer`
 thuần; timer/delay/
navigation là 
`GameEffect`
 fan qua effects-stream vào bridge;
persistence là async-op 
`GameSaveResult`
 duy nhất — đóng.

:::note[Triết lý milestone: "reducer trả về kết quả, không làm việc"]
- Repo **không bao giờ mở rộng từ viết tắt "DRE"** — không một
  comment hay doc nào định nghĩa ba chữ đó. Nó là tên pattern riêng
  của project, không phải port Redux/MVI/Elm — đừng bịa expansion.
- 
`reduce(state, action) → DreResult{state, effects, asyncOp}`
:
  reducer *khai báo* việc phải xảy ra; 
`DreChangeNotifier`
 *thực
  hiện* — swap state, 
`notifyListeners()`
 khi 
`!=`
, add effects vào
  stream broadcast, 
`unawaited`
 tối đa một asyncOp với snapshot
  post-reduce.
- Public API của VM không đổi một chữ — 
`game_screen.dart`
, widget
  test, mọi call-site compile y nguyên: refactor kiến trúc,
  contract đông cứng. Chỉ trừ 
`shareResult`
/
`GameShare*`
 — cố ý để
 M27.
:::

## Bản đồ bài học

| Bài | Nội dung | Checkpoint |
|-----|----------|-----------|
| [01](/m26/01-vi-sao-mutation-tay-dat-gioi-han/) | Felt problem: 733 dòng trộn 4 chủng việc; DRE trong repo này = action/effect/asyncOp/reducer (repo không expansion); diagram trước/sau; counter reducer độc lập | **236/236** (+0 — đọc hiểu) |
| [02](/m26/02-core-dre-primitives/) | 
`lib/core/dre/`
: 
`abstract interface class`
 markers + generic bounds 
`A extends DreAction`
; dispatch 5 nhịp — reduce → swap → 
`!=`
 notify → effects broadcast → 
`unawaited`
 asyncOp post-reduce snapshot + 
`onAsyncOpError`
; 
`@protected`
; 
`dre_change_notifier_test.dart`
 5 test | **241/241** (+5) |
| [03](/m26/03-game-state-actions-effects/) | 
`view_models/game/dre/`
: 
`GameState`
 13 field — 
`flowToken`
 thành state vs VM field cũ; 
`List/Map/Set.unmodifiable`
; 
`initial`
 + 
`copyWith`
/
`clear*`
; 13 
`GameAction`
 / 7 
`GameEffect`
 / 1 
`GameAsyncOp`
 sealed + barrel 
`game_dre_contract.dart`
; unused-but-compiling = scaffold | **241/241** (+0) |
| [04](/m26/04-game-reducer/) | 
`reducer/game_reducer.dart`
 + 
`part`
/
`part of`
 + 4 private 
`extension _GameReducer*Flow`
 (
`part`
/
`part of`
 reuse từ M24 — mới: private 
`extension`
 qua part files); switch exhaustive 13 arm; guard 
`_result(state)`
 same-instance; 
`_withSaveResult`
 → 
`GameSaveResult`
 op idempotent; 10 reducer test thuần — không Flutter, không fake | **251/251** (+10) |
| [05](/m26/05-vm-migration-va-bridges/) | VM rewrite 733→166 dòng: 
`extends DreChangeNotifier<…>`
; ctor wire 
`GameReducer`
 + 
`GameState.initial`
; 
`effects.listen(_handleEffect)`
; public = 
`dispatch`
 one-liners; 
`executeAsyncOp`
 → 
`_saveGameResult`
; 2 
`part 'bridge/…'`
; xoá 
`GameSessionState`
 khỏi 
`data/`
 | **251/251** (+0 — behavior-preserving) |
| [06](/m26/06-regression-va-tong-ket/) | 3 regression test ghim behavior qua refactor: submit-ignored-intro, stale-AI-result-sau-dismiss, terminal-save-once qua 
`backToMenu`
 lặp; recap reducer/VM/repo/UI; → CONVERGED | **254/254** (+3) |

## Kết quả cuối milestone

- 
`flutter analyze`
 sạch · 
`flutter test`
 **254/254**
  (236 + 5 + 0 + 10 + 0 + 3) · 
`flutter build web`
 PASS.
- VM public API y nguyên: 
`startNewGame`
, 
`submitAnswer`
,
  
`handleFeatureClick`
, 
`showMoneyLadder`
, 
`showConfirmExit`
,
  
`showConfirmWalkAway`
, 
`confirmWalkAway`
, 
`dismissDialog`
,
  
`backToMenu`
, 
`playAgain`
, 
`screenData`
, 
`dialogState`
,
  
`uiEvents`
 — 
`game_screen.dart`
 + widget tests +
  
`game_screen_view_model_test`
 không sửa một dòng.
- 
`GameSessionState`
 → 
`GameState`
 (tên senior), nhà mới
  
`view_models/game/dre/game_dre_state.dart`
; 
`data/game/
  game_session_state_data.dart`
 chỉ còn 
`GamePhase`
 +
  
`GameDialogState`
 + 
`GameScreenUiEvent`
 — khớp layout senior.
- FR đóng: — bản trung gian 
`ChangeNotifier`
 +
  manual-guards → 
`DreChangeNotifier`
 + 
`GameReducer`
 + 
`asyncOp`
.
  Hai divergence nhỏ được gỡ: guard delay giờ check 
`flowToken`

  trong state (không chỉ 
`phase`
), 
`dismissDialog`
 trên dialog đã
  hidden đi qua default branch (+1 notify — verbatim senior).

## Điều milestone này cố ý chưa làm

| Chưa làm | Milestone sở hữu | Vì sao |
|---|---|---|
| 
`GameShareRequested`
 action + 
`GameShareResult`
 effect + 
`GameShareResultEvent`
 + 
`shareResult`
 | **M27** | SharePlus/plumbing — reducer switch cố ý thiếu arm share; đừng flag "missing case" |
| Notification permission/scheduling + version text 
`v$appVersion`
 | **M27** (residual) | platform extras chưa vào scope |
| Visual parity: 
`SettingsDialogShell`
/
`OnboardingGameButton`
/icon-asset/
`LevelProgressCard`
 | **M28** (32/34) | chrome hiện tại đủ cho behavior; polish gộp đợt visual |
| 
`MenuDialogLayer`
 + 
`MenuDialogAuth`
/
`MenuDialogSignOut`
 state | **M29** | transport 
`showDialog`
 giữ — cùng scaffold settings/leaderboard |
| 
`onAsyncOpError`
 override trong game VM | — | senior game không override — 
`_saveGameResult`
 tự try/catch nuốt+log; hook chỉ là extension point |
| Rollback/retry cho 
`GameSaveResult`
 fail | — | senior không có: lỗi save log+swallow — save là best-effort, lần sau là retry tự nhiên |
| Middleware/store/time-travel/debugger | — | DRE là project-local, không phải port Redux — đừng import tư tưởng senior không có |
| 
`==`
/equality cho 
`GameState`
 | — | senior không override: 
`!=`
 trong dispatch là identity — mọi instance mới notify, guard 
`_result(state)`
 same-instance im lặng |
| DRE hoá menu/settings/onboarding VMs | — | senior chỉ áp DRE cho game VM; các VM còn lại giữ 
`ChangeNotifier`
 tay — đúng parity |

## Checkpoint tổng kết

- [ ] 
`flutter analyze`
 sạch; 
`flutter test`
 **254/254**;
  
`flutter build web`
 xanh.
- [ ] 
`lib/core/dre/`
 hai file verbatim senior — không doc comment,
  không chữ nào mở rộng "DRE".
- [ ] 
`view_models/game/dre/`
 đủ 5 file: state/action/effect/
  asyncOp/contract — 13 + 7 + 1 variant (không share).
- [ ] 
`reducer/`
 5 file: 
`GameReducer`
 + 4 
`part of`
 — reduce là
  switch exhaustive, mọi guard trả 
`_result(state)`
.
- [ ] VM 166 dòng: mọi public method là 
`dispatch`
 one-liner; 2
  
`part 'bridge/…'`
 xử effect + persistence; 
`GameSessionState`

  không còn trong 
`data/`
.
- [ ] 18 test mới: 5 notifier + 10 reducer + 3 regression; 236
  test cũ xanh nguyên — refactor không sửa một dòng test nào.
- [ ] Nói được không lắp bắp: DRE không expansion; 
`flowToken`
 là
  data trong state; effect là ý định (không phải 
`Timer`
); asyncOp
  tối đa một per reduce với snapshot post-reduce.

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** 
`part`
/
`part of`
 + private 
`extension`
 chia file
 theo flow domain; 
`abstract interface class`
 marker +
 generic bounds; effects-stream → bridge; async-op
 boundary + post-reduce snapshot; project-local reducer
; 
`flowToken`
-in-state stale guard (cùng ý tưởng
 
`_requestId`
 nhưng token sống trong state, check ở reducer).
2. **Giải thích được?** Vì sao reducer thuần (test không Flutter);
   vì sao effect là data chứ không phải 
`Timer`
; vì sao token nằm
   trong 
`GameState`
 chứ không phải field VM; vì sao
   
`hasSavedResult`
 guard sống ở reducer; vì sao 
`GameState`
 không
   cần 
`==`
.
3. **Viết lại không copy?** Tự làm: 
`Multiply`
 action cho counter
   (Bài 1) + PREDICT chuỗi dispatch trên harness (Bài 2) + copyWith
   dismiss-dialog (Bài 3) + test 
`GameTimerTicked`
 ngoài 
`playing`

   và DEBUG xoá 
`flowToken !=`
 (Bài 4) + PREDICT vòng lặp effect
   (Bài 5) + DEBUG xoá 
`hasSavedResult`
 (Bài 6).
4. **Nếu … thì sao?** Delayed callback trễ → token lệch → reducer
   no-op (không exception); dispatch sau dispose → ignored; op
   throw → 
`onAsyncOpError`
 (game để mặc định — 
`_saveGameResult`

   tự nuốt); 
`backToMenu`
 ×2 → save một lần, nav vẫn emit.
5. **Cần ở đâu sau?** M27 thêm 
`GameShareRequested`
/
 
`GameShareResult`
/
`shareResult`
 + platform extras (
 /28); M28 visual parity; M29 
`MenuDialogLayer`
. Shape
   
`dispatch → reduce → effect/asyncOp`
 của M26 là mẫu cho mọi
   state-machine lớn sau này.
