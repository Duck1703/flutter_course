---
title: "Bài 4 · Save trong VM — hasSavedResult & 7 sửa + 1 xoá"
description: "Atomic cut M22: ctor nhận UserProfileRepository, _emitWithSaveResult guard tại 4 transition, _saveGameResult/_applyLevelProgression port verbatim, xoá GameResult/resolvedResult/applyGameResult/expForNextLevel, openGame→Future<void>. Suite 169 → 168 (−9 test scaffold, +8 test persistence)."
sidebar:
  label: "Bài 4 · VM-side save"
  order: 4
---

## Mục tiêu

- Game VM nhận `UserProfileRepository` qua ctor (senior parity).
- `_emitWithSaveResult` + `_saveGameResult` + `_applyLevelProgression`
  + `_normalizedLevel` + `_syncSavedGameResult`(stub M25) vào VM.
- `GameSessionState.hasSavedResult` thay `resolvedResult`.
- Xoá `game_result.dart` + toàn bộ route-result transport.
- `UserProfileData` về 9 field senior (xoá `expForNextLevel`, `gainExp`,
  `expPerCorrectAnswer`, `applyGameResult`, `expPercent`).
- Suite **169 → 168** (9 test scaffold retire, +8 test persistence).

:::caution[Đây là "atomic cut"]
Tám đường dẫn phải đổi **cùng một bước** (7 file sửa + `game_result.dart`
xoá) — cắt nửa chừng thì không compile (vd xoá `expForNextLevel` trước
khi `gainExp` chết, hay xoá `GameResult` trước khi `openGame` đổi
signature). Làm theo thứ tự dưới và chỉ chạy test ở cuối.
:::

## Bạn đang ở đâu

- Bài 1: mental model — save là hiệu ứng cạnh của transition kết thúc.
- Bài 2–3: `LevelConfig` + `MenuLevelProgress` đã vào; menu đã đọc
  `progress` (không còn đọc `expForNextLevel`/`expPercent` từ UI).
- Còn lại: cụm transport `GameResult`/`buildGameResult`/`resolvedResult`/
  `applyGameResult` + curve cũ trong model — xoá sạch trong bài này.

## Bạn đã biết gì

- Bài 1: save-trong-VM, `hasSavedResult`, payload 4 transition.
- `UserProfileRepository` contract + `FakeUserProfileRepository`
  (M14). `unawaited`. `copyWith`/`clear*` flags.
- `debugPrint` cho log (đã gặp); `try/catch` quanh await.

## Dart/Flutter cần dùng — xuất hiện đầu tiên

| Construct | Vai trò |
| --- | --- |
| `context.read<UserProfileRepository>()` trong `create:` | DI app-scope vào VM màn (đã học ở M14 — đây là điểm gắn mới) |
| `unawaited(_saveGameResult(…))` | fire-and-forget: transition không chờ save xong |
| `while (nextLevel < max) { … break; }` | "đốt" ngưỡng từng cấp — vòng lặp accumulation |
| `num.clamp` thủ công | `_normalizedLevel` kẹp level về 1..100 |

## Mental model mới — "cờ và kết quả hiện diện *cùng nhau*"

Bốn đường khác nhau có thể kết thúc một ván: thắng câu cuối, thua,
walk-away, bấm về menu. Nhiều đường hơi *chạm nhau* — ví dụ
`_endGame` vừa kết thúc ván, người chơi lập tức bấm "về menu" →
`backToMenu` chạy. Nếu cả hai đường đều gọi save, profile ghi hai
lần: `gamesPlayed` +2 cho một ván, EXP nhân đôi.

Bất biến senior giữ cho việc này chỉ gồm ba câu:

```
TRƯỚC transition kết thúc:      hasSavedResult == false
KHI  transition kết thúc emit:  state mới ĐÃ chứa hasSavedResult == true
                                → save side-effect bắt đầu (unawaited)
SAU ĐÓ mọi đường khác:          đọc _state.hasSavedResult == true
                                → emit bình thường, KHÔNG save nữa
```

Chỗ dễ trật là chữ "**ĐÃ**": cờ không phải "sẽ được set sau khi
emit". Nó phải nằm *bên trong chính state mà transition phát ra* —
`_emit(next.copyWith(hasSavedResult: true))`. Vì sao bắt buộc vậy?

- `_state` là nguồn đọc duy nhất của guard. Nếu emit `next` *trước*
  rồi set cờ ở một lệnh khác, tồn tại một khoảng mà `_state` công
  khai vẫn nói "chưa lưu" — và bất kỳ transition kết thúc nào chạy
  trong khoảng đó (back-to-menu, confirm-exit) đều đọc `false` và
  save thêm lần nữa.
- Emit cờ *cùng* transition = "ghi nhận xong" và "phát hiện đã ghi"
  là **một sự kiện nguyên tử** — không có kẽ hở để lệch thứ tự.

Đây cũng là cách senior làm: `_withSaveResult` gắn flag vào chính
state được reduce ra, và op save chỉ bắn khi flag cũ là `false`.
Learner chưa có kiến trúc reducer của M26 — bạn sẽ thấy bất biến
này xuất hiện lại ở đó dưới hình thức chặt chẽ hơn — nhưng bản
chất đã là nó: *flag và transition đi cùng nhau*.

> **Giữ câu này khi làm Tự làm cuối bài:** bug trồng sẵn ở đó phá
> đúng chỗ "ĐÃ" — bạn sẽ tự chứng kiến kẽ hở đó làm `saveCallCount`
> thành 2.

## Bước 1 — `GameSessionState`: `hasSavedResult` vào, `resolvedResult` ra

`game_session_state_data.dart`:

```dart
// xoá: import 'game_result.dart';

// ctor: thay `this.resolvedResult` bằng
this.hasSavedResult = false,

// field mới (thay toàn bộ `resolvedResult` field + doc):
/// Kết quả đã được lưu vào profile chưa — senior `hasSavedResult`:
/// `true` sau lần ghi đầu tiên tại transition kết thúc (victory/
/// gameOver/walkAway/backToMenu); guard trong
/// `GameScreenViewModel._emitWithSaveResult` chặn save lặp khi hai
/// đường kết thúc chạm nhau (vd `backToMenu` sau `_endGame`). Reset
/// về `false` trong `initial` — mỗi phiên lưu đúng một lần.
final bool hasSavedResult;

// copyWith: thay `GameResult? resolvedResult` + `clearResolvedResult`
// bằng `bool? hasSavedResult`, và thân:
hasSavedResult: hasSavedResult ?? this.hasSavedResult,
```

Đồng thời sửa doc `GameNavigateToMenuEvent`: pop trần — không còn
`GameResult` đi kèm (stream repo là nguồn truth).

## Bước 2 — `game_result.dart`: xoá file

`git rm lib/data/game/game_result.dart` (hoặc xoá tay). Mọi import
của nó sẽ hiện lỗi analyze — đúng ý đồ: chúng chỉ đường cho các bước
sửa tiếp theo.

## Bước 3 — `GameScreenViewModel`: ctor + guard + save

**Imports** — bỏ `game_result.dart`, thêm:

```dart
import '../../data/game/level_config.dart';
import '../../data/profile/user_profile_data.dart';
import '../../repositories/profile/user_profile_repository.dart';
```

**Ctor** — senior `required this.userProfileRepository` (auth/sync
repos của senior → M24/M25, chưa cần):

```dart
/// Repository profile — M22 ctor đúng senior; test inject
/// FakeUserProfileRepository.
final UserProfileRepository userProfileRepository;

GameScreenViewModel({
  required this.userProfileRepository,
  this.questions = gameSampleQuestions,
}) : _state = GameSessionState.initial(timePerQuestion: timePerQuestion);
```

**4 transition kết thúc** — đổi `_emit(...)` thành
`_emitWithSaveResult(…, earnedAmount:…, isWin:…)` và xoá mọi
`resolvedResult: GameResult(…)`:

```dart
// _loadNextQuestionOrVictory — nhánh victory (câu cuối đúng):
_emitWithSaveResult(
  _state.copyWith(phase: GamePhase.victory, …victoryDialog…),
  earnedAmount: _state.moneyEarned,
  isWin: true,
);

// _endGame:
_emitWithSaveResult(
  _state.copyWith(phase: GamePhase.gameOver, …endedDialog…),
  earnedAmount: _state.guaranteedAmount,
  isWin: false,
);

// confirmWalkAway:
_emitWithSaveResult(
  _state.copyWith(phase: GamePhase.victory, …victoryDialog…),
  earnedAmount: amount,            // = _walkAwayAmount(_state)
  isWin: false,
);

// backToMenu:
_stopTimer();
_emitWithSaveResult(
  _state.copyWith(remainingTime: Duration.zero),
  earnedAmount: _walkAwayAmount(_state),
  isWin: false,
);
_emitEvent(const GameNavigateToMenuEvent());
```

**Xoá** `buildGameResult()` + toàn bộ `resolvedResult:` constructions.

**Thêm block persistence** (cuối file, trước `_emit`):

```dart
// ------------------------------------------------------------------
// Result persistence (M22) — senior
// reducer/game_reducer_session_flow.dart::_withSaveResult +
// bridge/game_screen_view_model_result_persistence.dart.
// Learner chưa có DRE/asyncOp queue (M26): save là một `unawaited`
// gọi từ boundary transition; cờ `hasSavedResult` trên state chặn
// lặp — đúng ngữ nghĩa `_withSaveResult` (flag set TRONG cùng
// transition, op chỉ bắn khi flag cũ là false).
// ------------------------------------------------------------------

/// Emit [next] + lưu kết quả ván MỘT LẦN — tương đương
/// `_withSaveResult` của reducer senior.
void _emitWithSaveResult(
  GameSessionState next, {
  required int earnedAmount,
  required bool isWin,
}) {
  if (_state.hasSavedResult) {
    _emit(next);
    return;
  }

  _emit(next.copyWith(hasSavedResult: true));
  unawaited(
    _saveGameResult(
      earnedAmount: earnedAmount,
      isWin: isWin,
      // `questionIndex` không đổi trong mọi transition kết thúc —
      // đọc sau emit vẫn là giá trị pre-transition (senior:
      // `state.questionIndex + 1`).
      questionCount: _state.questionIndex + 1,
    ),
  );
}
```

+ `_saveGameResult`, `_syncSavedGameResult` (stub), `_applyLevelProgression`,
`_normalizedLevel` — port verbatim từ bridge senior
(`view_models/game/bridge/game_screen_view_model_result_persistence.dart`;
mọi dòng giữ nguyên, chỉ `_syncSavedGameResult` là stub `debugPrint`
"M25").

**Điểm cần tập trung khi port:**

- `_saveGameResult` bọc toàn thân trong `try/catch` + `debugPrint` —
  persistence fail không được crash ván chơi.
- `gainedExp: earnedAmount` — EXP = tiền nhận được (senior), không
  phải số câu đúng × hằng.
- `gamesWon` chỉ tăng khi `isWin` — walk-away/backToMenu là `false`.

## Bước 4 — `UserProfileData` surgery

Xoá khỏi `user_profile_data.dart`:

```text
- import '../game/game_result.dart';
- field expForNextLevel (+ ctor param, + copyWith, + toMap key,
  + fromMap parse, + ==, + hashCode, + doc mentions)
- gainExp(int amount)            // curve ×1.5 — scaffold chờ M22
- expPerCorrectAnswer            // hằng EXP tạm
- applyGameResult(GameResult)    // menu-side policy — retire ở bài này
- expPercent getter              // menu dùng MenuLevelProgress.ratio
```

Giữ nguyên: 9 field còn lại, `winRateDisplay`, `formatVnd`,
`formatThousands`, toàn bộ parse phòng thủ + `_isLegacyDemoProfile`.

> `fromMap` KHÔNG cần xử lý key `expForNextLevel` còn sót trên disk:
> nó chỉ đọc key mình biết — key lạ tự bị bỏ qua (đúng bản chất
> parse phòng thủ).

Cập nhật doc class: field set khớp senior nguyên bộ (hội tụ
converge).

## Bước 5 — transport retirement

```dart
// app_navigation_controller.dart
Future<void> openGame() {
  return _push<void>(
    MaterialPageRoute<void>(builder: (context) => const GameScreen()),
  );
}
// (xoá import game_result.dart, sửa doc: không còn result đi kèm)

// game_screen.dart — _handleUiEvent:
case GameNavigateToMenuEvent():
  // M22: pop trần — VM đã save qua repo.
  _navigationController?.goBack();

// game_screen.dart — provider:
create: (context) => GameScreenViewModel(
  userProfileRepository: context.read<UserProfileRepository>(),
)..startNewGame(),
// (+ import repositories/profile/user_profile_repository.dart)

// menu_screen.dart — _openGame:
Future<void> _openGame() async {
  await context.read<AppNavigationController>().openGame();
}
// (không còn await result / applyGameResult)

// menu_view_model.dart — xoá method applyGameResult + import
// game_result.dart. Menu giờ chỉ đọc stream (đã đúng từ M14).
```

## Bước 6 — tests

**`test/game_screen_view_model_test.dart`:**

```dart
import 'helpers/fake_user_profile_repository.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';

// helper — repo param để assert persistence:
GameScreenViewModel startedVm(
  FakeAsync async,
  int questionCount, {
  FakeUserProfileRepository? repo,
}) {
  final vm = GameScreenViewModel(
    userProfileRepository: repo ?? FakeUserProfileRepository(),
    questions: bank(questionCount),
  );
  ...
}

// mọi `GameScreenViewModel(questions: …)` khác → thêm
// `userProfileRepository: FakeUserProfileRepository(),`
```

- Xoá group `buildGameResult` (2 test) + tail `buildGameResult()` trong
  test walk-away.
- Thêm group `result persistence (M22)` — 8 test: gameOver payload
  (guaranteed=0, isWin=false, questionCount=2), backToMenu walkAway
  20k + double-call vẫn 1 save, victory isWin=true/gamesWon+1,
  confirmWalkAway, gameOver→backToMenu chặn lặp, playAgain reset flag
  → save #2, EXP=earnedAmount lên cấp (seed 34000 → L2/1000), cap
  level 100.
  Sau mỗi trigger gọi `async.flushMicrotasks()` — `_saveGameResult`
  là `unawaited` nên cần flush microtask queue của FakeAsync.

**`test/user_profile_data_test.dart`:** xoá import `game_result.dart`,
assert `expForNextLevel`, param `expForNextLevel:` trong round-trip,
hai test `gainExp`, test `expPercent`, và cả group
`applyGameResult` (3 test) — tổng −6 test.

**`test/menu_view_model_test.dart`:** xoá import + test
`applyGameResult` (−1); trong test `resetProfile` thay
`vm.applyGameResult(...)` bằng `repo.saveUserProfile(
const UserProfileData(gamesJoined: 2, gamesWon: 1))`.

**`test/widgets/game_screen_test.dart`:** `pumpGameScreen` thêm
param `FakeUserProfileRepository? profileRepo` + inject vào ctor;
test walk-away đổi `buildGameResult()` asserts → `repo.saveCallCount`,
`repo.value.gamesWon/totalMoneyWon` (thêm `await tester.pump()` cho
save kịp chạy). Hai comment nhắc `GameResult` cập nhật sang M22.

**Số lượng test — hiểu đúng nhịp −9/+8:**

| Nguồn | Δ |
| --- | --- |
| user_profile_data: 2×gainExp + 1×expPercent + 3×applyGameResult | −6 |
| menu_view_model: applyGameResult | −1 |
| vm test: group buildGameResult | −2 |
| vm test: group result persistence mới | +8 |

169 − 9 + 8 = **168**. Test scaffold chết cùng scaffold — đó là dấu
hiệu sạch, không phải hồi quy.

## Android / Compose bridge

```text
SIMILARITY:           `unawaited(_saveGameResult(…))` ≈
                      `viewModelScope.launch { repository.save(…) }`
                      không `join()` — fire-and-forget tại boundary,
                      UI không chờ DB.
IMPORTANT DIFFERENCE: `hasSavedResult` sống TRONG state object —
                      không phải biến `@Volatile` trên ViewModel. Khi
                      `initial` reset state, flag tự reset; không ai
                      quên clear.
DO NOT ASSUME:        `Navigator.pop(result)` ≠ `setResult()` +
                      `finish()` hoàn chỉnh — route-pop result mất
                      cùng route nếu màn sau không đọc kịp. Đó là lý
                      do senior save trong VM thay vì transport.
```

## Checkpoint

- `flutter analyze` sạch: zero reference tới `GameResult`,
  `buildGameResult`, `resolvedResult`, `applyGameResult`,
  `expForNextLevel`, `gainExp`, `expPercent` (getter) trong `lib/`.
- `flutter test` → **168/168**.
- Sanity tay: `flutter run`, chơi thua một ván → về menu thấy
  `gamesJoined` +1 ngay (stream), không cần hot-restart.

## Tự làm — DEBUG

Bug có chủ đích (làm trong sandbox/copy, không merge): trong
`_emitWithSaveResult`, emit `next` **nguyên bản** — quên gắn cờ
`hasSavedResult` vào state mới:

```dart
void _emitWithSaveResult(GameSessionState next, {…}) {
  if (_state.hasSavedResult) { _emit(next); return; }
  _emit(next);                              // quên copyWith cờ
  unawaited(_saveGameResult(…));
}
```

Đoán trước rồi chạy `flutter test test/game_screen_view_model_test.dart`
— test nào bắt được bug, vì sao?

<details>
<summary>Đáp án</summary>

- Guard vẫn đọc `_state.hasSavedResult` đúng — nhưng cờ **không bao
  giờ được set**, vì chỗ set nó duy nhất là `next.copyWith(
  hasSavedResult: true)` vừa bị bỏ.
- `_endGame` → save #1, state emit ra vẫn `hasSavedResult: false`
  (copyWith không truyền → giữ false). Người chơi bấm "về menu" →
  `backToMenu` → guard thấy `_state.hasSavedResult == false` →
  `unawaited(_saveGameResult)` chạy LẦN NỮA → `saveCallCount == 2`.
- **Ba test đỏ** — test đỏ *sớm nhất* là `thua câu 2 → save 1 lần:
  earned=guaranteed(0), isWin=false, questionCount=2…`: nó assert
  trực tiếp `vm.state.hasSavedResult` `isTrue` → fail ngay, chứng
  minh cờ không bao giờ được set.
- Test `gameOver rồi backToMenu → hasSavedResult chặn save lần 2` đỏ:
  `expect(repo.saveCallCount, 1)` nhận 2 — đúng lỗi mà cờ sinh ra
  để chặn.
- Test `thoát giữa ván sau safe haven → backToMenu save walkAway
  amount + stats; gọi lại → vẫn 1 lần` cũng đỏ cùng cơ chế
  (`saveCallCount==2`).

Bài học: guard chỉ có nghĩa khi cờ **ghi vào state đã emit** — đọc
đúng nguồn (`_state`) nhưng quên ghi lại cũng hỏng. Đây là lý do
senior để `_withSaveResult` set flag *trong cùng transition* tạo ra
save, thay vì một nơi khác.

</details>

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m22/04 — "Save trong VM — hasSavedResult & 7 sửa + 1 xoá" (atomic cut: game VM nhận UserProfileRepository qua ctor; _emitWithSaveResult + _saveGameResult + _applyLevelProgression + _normalizedLevel + _syncSavedGameResult stub; hasSavedResult thay resolvedResult; xoá game_result.dart + toàn bộ route-result transport + 4 member scaffold trên UserProfileData; openGame→Future<void>).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `grep`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Đây là ATOMIC CUT — 7 file sửa + 1 file xoá phải đi cùng nhau; cắt nửa chừng (sót scaffold) = NEEDS_FIX/DIVERGED, không phải "đang làm dở chấp nhận được".

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/game/game_session_state_data.dart` (STRICT): `import 'game_result.dart'` đã xoá; field `GameResult? resolvedResult` + cờ `clearResolvedResult` trong copyWith thay bằng `final bool hasSavedResult` (ctor `this.hasSavedResult = false`, copyWith `hasSavedResult ?? this.hasSavedResult`); doc `GameNavigateToMenuEvent` cập nhật (pop trần).
- `lib/data/game/game_result.dart` (STRICT) — FILE ĐÃ XOÁ; `grep -rn "game_result.dart" lib/` → 0 import còn lại.
- `lib/view_models/game/game_screen_view_model.dart` (STRICT): ctor `required this.userProfileRepository` (kiểu `UserProfileRepository`, test inject Fake); import level_config + user_profile_data + user_profile_repository; `buildGameResult()` ĐÃ XOÁ cùng mọi `resolvedResult:` constructions; `_emitWithSaveResult(next, {required earnedAmount, required isWin})` — `_state.hasSavedResult → _emit(next) return` ELSE `_emit(next.copyWith(hasSavedResult: true))` + `unawaited(_saveGameResult(earnedAmount:, isWin:, questionCount: _state.questionIndex + 1))` — flag set TRONG cùng emit (STRICT: emit next nguyên bản rồi set cờ lệnh khác = kẽ hở double-save, bug trong bài); 4 transition dùng nó với payload đúng bảng (victory-last: moneyEarned/true; _endGame: guaranteedAmount/false; confirmWalkAway: _walkAwayAmount/false; backToMenu: _walkAwayAmount/false + `remainingTime: zero` + `GameNavigateToMenuEvent` sau emit); `_saveGameResult` bọc `try/catch` + `debugPrint` (persistence fail không crash ván), `gainedExp: earnedAmount` (EXP=tiền, KHÔNG đếm câu đúng), `gamesWon` chỉ +khi isWin, gọi `_applyLevelProgression(profile, gainedExp:)` rồi `saveUserProfile` + `_syncSavedGameResult()` (stub `debugPrint` 'M25' — KHÔNG có Supabase); `_applyLevelProgression` dùng `LevelConfig.getExpRequiredForLevel` + while-loop đốt ngưỡng kẹp `_normalizedLevel(1..100)`; `_normalizedLevel` clamp thủ công.
- `lib/data/profile/user_profile_data.dart` surgery (STRICT): ĐÃ XOÁ — `import '../game/game_result.dart'`, field `expForNextLevel` (+ctor param +copyWith +toMap key +fromMap parse +== +hashCode), method `gainExp`, `expPerCorrectAnswer`, `applyGameResult(GameResult)`, getter `expPercent`. GIỮ: 9 field còn lại (đúng bộ senior), `winRateDisplay`, `formatVnd`, `formatThousands`, parse phòng thủ + `_isLegacyDemoProfile`; `fromMap` KHÔNG thêm xử lý key cũ sót trên disk (key lạ tự bỏ qua).
- TRANSPORT RETIRE (STRICT): `app_navigation_controller.dart` `openGame() → Future<void>` (MaterialPageRoute<void>, xoá import game_result); `game_screen.dart` `_handleUiEvent` nhánh `GameNavigateToMenuEvent` → `_navigationController?.goBack()` trần (không còn truyền result); provider `create:` truyền `userProfileRepository: context.read<UserProfileRepository>()` (+import repo); `menu_screen.dart` `_openGame` chỉ `await …openGame()` (không còn `await result`/`applyGameResult`); `menu_view_model.dart` xoá `applyGameResult` + import.
- TEST (STRICT — suite 168/168 = 169 −9 scaffold +8 persistence): `game_screen_view_model_test.dart` — mọi ctor `GameScreenViewModel(` truyền `userProfileRepository: FakeUserProfileRepository()` (helper `startedVm(async, n, {repo})`); xoá group buildGameResult (−2); group mới `result persistence` +8 test (gameOver payload guaranteed=0/isWin=false/questionCount=2; backToMenu walkAway 20k + double-call → 1 save; victory isWin=true/gamesWon+1; confirmWalkAway; gameOver→backToMenu chặn lặp; playAgain reset flag→save #2; EXP=earnedAmount lên cấp seed 34000→L2/exp 1000; cap level 100) — sau trigger `async.flushMicrotasks()` vì save là unawaited; `user_profile_data_test.dart` −6 test (2 gainExp + 1 expPercent + 3 applyGameResult + assert expForNextLevel khỏi round-trip); `menu_view_model_test.dart` −1 applyGameResult (resetProfile test đổi sang `repo.saveUserProfile(UserProfileData(gamesJoined:2, gamesWon:1))`); `test/widgets/game_screen_test.dart` — `pumpGameScreen` +param `FakeUserProfileRepository? profileRepo` inject ctor; test walk-away đổi asserts `buildGameResult()` → `repo.saveCallCount`/`repo.value.gamesWon`/`totalMoneyWon` (+`await tester.pump()` cho save kịp chạy).
- `flutter analyze` sạch — zero reference `GameResult`/`buildGameResult`/`resolvedResult`/`applyGameResult`/`expForNextLevel`/`gainExp`/`expPercent`(getter) trong `lib/` (comment milestone-tagged + 2 local var cố ý `expForNextLevel` trong `_applyLevelProgression` và `expPercent` trong `_LevelCard` KHÔNG tính); `flutter test` → **168/168** (STRICT — số GIẢM từ 169 là đúng: test scaffold chết cùng scaffold).
- KHÔNG ĐƯỢC có (chưa đến): `_syncSavedGameResult` gọi Supabase/auth thật (M24/M25 — chỉ stub debugPrint); `AuthRepository`/`UserProfileSyncRepository` trên ctor VM (M24/M25); DRE `GameSaveResult` asyncOp + reducer/`DreChangeNotifier` (M26); `LevelProgressCard` ring/glass (M28); share/`GameShareResultEvent` (M27); `menuMaxLevelReached`/`menuExpToNextLevel` (M28).

INVARIANTS NỀN:
- `LevelConfig` (Bài 2) + `MenuLevelProgress` + `_LevelCard` rewire (Bài 3); M21 layer/PopScope/`_handleRouteBack`/`_afterExit`/`GameNavigateToMenuEvent` duy nhất; M20 lifelines (walk-away giờ save `isWin:false` payload tường minh thay `resolvedResult`); M14 `UserProfileRepository` contract + `BehaviorSubject`/`ValueStream` + Fake repo; M15–M18 nền.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc hoặc scaffold sót lại → `BEHIND`/`NEEDS_FIX` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m22/04
PROJECT_ALIGNMENT: ON_TRACK | NEEDS_FIX | DIVERGED | BLOCKED
COURSE_POSITION: ON_TRACK | BEHIND | AHEAD_COMPATIBLE | AHEAD_RISKY
READY_FOR_NEXT_LESSON: YES | YES_AFTER_FIXES | NO
VERIFICATION_PERFORMED:
WHAT_MATCHES:
GAPS:
AHEAD_OF_COURSE:
DIVERGENCES:
REQUIRED_FIXES_BEFORE_CONTINUING:
EVIDENCE: file/symbol → observation
FILES_MODIFIED_BY_REVIEW: NONE
```
