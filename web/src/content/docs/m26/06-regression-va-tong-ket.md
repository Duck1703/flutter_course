---
title: "Bài 6 · Regression tests + tổng kết "
description: "Port `game_screen_view_model_regression_test.dart` — 3 test ghim behavior qua đổi kiến trúc: submit-ignored-intro, stale-AI-result-sau-dismiss, terminal-save-once qua `backToMenu` lặp. Vì sao regression test tồn tại SAU refactor: pin behavior ở public surface. Recap reducer/VM/repository/UI ownership split; → CONVERGED → 251 → 254."
sidebar:
  label: "Bài 6 · regression + tổng kết"
  order: 6
---

## Mục tiêu

- Thêm `test/view_models/game/
  game_screen_view_model_regression_test.dart` — 3 test ghim
  behavior mà refactor *phải giữ*: submit bị bỏ khi intro còn mở,
  stale AI-result bị bỏ sau khi dialog đóng, terminal-save chỉ
  chạy một lần qua `backToMenu` lặp. +3 → **254/254**.
- Giải thích "regression test tồn tại SAU refactor": assert ở
  public surface (`dialogState`/`screenData`/`saveCallCount`) —
  reducer đổi bên trong, pins vẫn xanh.
- Recap ownership split của M26: reducer (transition + guard +
  scoring), VM-bridge (timer/future/repo/stream plumbing),
  repository (persistence), UI (render + notify taps).
- Đóng trong fidelity register: bản trung gian
  `ChangeNotifier`+manual-guards → `DreChangeNotifier` +
  `GameReducer` + `asyncOp`.

## Bạn đang ở đâu

- Bài 5: VM đã `extends DreChangeNotifier` + 2 bridge part;
  `GameSessionState` đã retire. Suite **251/251** — toàn bộ
  production code của M26 đã land.
- Chưa có test nào *chứng minh rằng refactor không đổi hành vi
  quan sát được* — 236 test cũ xanh là bằng chứng gián tiếp
  (chúng assert semantics M19–M25); 3 test hôm nay là pins chuyên
  biệt cho ba edge mà kiến trúc mới phải giữ.
- Senior chứng minh cùng ba điều này trong cùng file name —
  learner port ở tầng VM với `FakeUserProfileRepository` thay
  `FakeGameProfileRepository` (helper có sẵn từ M14).

## Vì sao việc này quan trọng ngay bây giờ

Refactor "đúng" không phải "chạy được" — là *không đổi gì quan
sát được*. Ba test này ghim đúng ba rủi ro của kiến trúc mới:
(1) guard `phase != playing` giờ sống trong reducer — submit sớm
vẫn phải im lặng; (2) delayed callback vòng qua dispatch giờ đi
xa hơn (`_schedule*` → `Future.delayed` → `dispatch(*Elapsed)` →
reducer) — stale phải bị loại ở *data*, không phải bằng may;
(3) save-once giờ là reducer-guard `hasSavedResult` — hai
`backToMenu` liên tiếp không được phát hai `GameSaveResult` op.
Ba pin này cũng là bằng chứng cuối cùng để ghi **:
CONVERGED**.

## Bạn đã biết gì

- Toàn bộ pipeline Bài 2–5: `dispatch` → `reduce` →
  state/effects/asyncOp → `_handleEffect`/`executeAsyncOp`.
- `FakeUserProfileRepository` (`saveCallCount`,
  `loadUserProfile`/`saveUserProfile` fast) + `FakeAuthRepository`
 + `FakeUserProfileSyncRepository` (M14/M24).
- `screenData.answers`/`featureButtons` qua mapper;
  `GameAnswerState.idle`; dialog variants `GameMoneyLadderDialog`/
  `GameAIAssistantDialog`/`GameDialogHidden`/`GameEndedDialog`
.

## Mental model — "regression test = đinh ghim behavior" (NORMAL)

```text
        reducer test (Bài 4)              regression VM test (Bài 6)
input   action + state trực tiếp          public method call (tap-level)
observe result.state/effects/asyncOp      dialogState/screenData/fake counters
bắt     sai transition/luật               sai TÍCH-HỢP: wiring, guard,
                                          lifecycle, nhịp dispatch
```

Refactor đổi *cách* state đổi (method-mutation → reduce) chứ
không đổi *gì quan sát được* — pin là assert trên public
surface, không đụng `dispatch`/`reducer` (cả hai là chi tiết bên
trong).

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `await Future.delayed(800ms/2600ms)` | **đồng hồ thật** — khác `FakeAsync` của file test chính; senior verbatim (đợi `_aiAssistantDelay` 700ms / reveal+explanation 2500ms) |
| `await Future.delayed(Duration.zero)` | flush microtask cho `unawaited` op hoàn tất |
| `setUp`/`tearDown` trên ba fake + VM | subject ownership — |
| helper `_answer`/`_answerState`/`_featureButton` | tra `screenData` theo text/label — assert qua public surface |

## Flutter cần dùng

`flutter_test` với đồng hồ *thật* (`Future.delayed` 800ms/2600ms)
— khác `FakeAsync` của `game_screen_view_model_test.dart`;
không có API mới, khác biệt duy nhất là test chờ delay thật của
bridge (`_aiAssistantDelay` 700ms, reveal+explanation 2500ms) và
flush microtask bằng `Duration.zero` cho `unawaited` op.

## Ví dụ độc lập

Ba assert cốt lõi, thu nhỏ (bỏ Flutter):

```dart
var saveCalls = 0;
var aiDialogOpen = false;
var token = 0;

void scheduleAI(int t) {
  token = t;
  aiDialogOpen = true;
  // 700ms sau: nếu !aiDialogOpen → kết quả bị drop (stale)
}
void dismiss() => aiDialogOpen = false;
void saveOnce() { if (saveCalls == 0) saveCalls++; }

void main() {
  scheduleAI(1); dismiss();
  assert(!aiDialogOpen);          // stale bị loại
  saveOnce(); saveOnce();
  assert(saveCalls == 1);         // terminal save-once
}
```

Xương sống của test 2 và 3 — guard là data (`aiDialogOpen`/
`saveCalls`), không phải exception.

## Android / Compose bridge

**SIMILARITY — ViewModel unit test qua `stateFlow.value` + fake
repo counter.** Assert `dialogState`/`saveCallCount` ≈ assert
`uiState` + verify `repository.save()` gọi 1 lần.

**IMPORTANT DIFFERENCE — đồng hồ thật thay `TestDispatcher`.**
Test này dùng `Future.delayed` thật (800ms/2600ms) — senior
verbatim; file chính dùng `FakeAsync.elapse`. Hai kiểu đồng hồ
trong một suite, hai trade-off: thật = chậm nhưng đúng nhịp
delay; ảo = nhanh nhưng cần tất cả timer trong `run` scope.

**DO NOT ASSUME — regression test đặt SAU refactor là cố ý.**
Không phải test để tìm bug lúc viết; nó là *pin* — khóa hành vi
quan sát được trước khi ai đó (kể cả bạn ở milestone sau) "tối
ưu" reducer mà vô tình đổi semantics.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `test/view_models/game/game_screen_view_model_regression_test.dart` | 3 test verbatim — learner đổi `FakeGameProfileRepository` (helper senior) → `FakeUserProfileRepository` (helper M14 có sẵn, cùng `saveCallCount`) |
| `lib/view_models/game/reducer/game_reducer_*_flow.dart` | pins chứng minh guard `phase != playing`, `dialogState is! GameAIAssistantDialog`, `hasSavedResult` đúng chỗ |
| `lib/view_models/game/bridge/` | delayed re-dispatch + `_events.add` — đường effect→action→event test 2–3 đi qua |

## Build it step by step

**Bước 1 — `test/view_models/game/game_screen_view_model_regression_test.dart`**
(file mới — verbatim senior, đổi package import + fake helper):

```dart
import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/data/game/game_session_state_data.dart';
import 'package:ai_millionaire_course/view_models/game/game_screen_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_profile_sync_repository.dart';
import '../../helpers/fake_user_profile_repository.dart';

void main() {
  group('GameScreenViewModel regression coverage', () {
    late FakeUserProfileRepository profileRepository;
    late FakeAuthRepository authRepository;
    late FakeUserProfileSyncRepository syncRepository;
    late GameScreenViewModel viewModel;

    setUp(() {
      profileRepository = FakeUserProfileRepository();
      authRepository = FakeAuthRepository();
      syncRepository = FakeUserProfileSyncRepository();
      viewModel = GameScreenViewModel(
        userProfileRepository: profileRepository,
        authRepository: authRepository,
        profileSyncRepository: syncRepository,
      );
    });

    tearDown(() async {
      viewModel.dispose();
      await profileRepository.dispose();
      await authRepository.dispose();
      await syncRepository.dispose();
    });
```

— ba test (verbatim senior):

```dart
    test('submit answer is ignored while intro ladder is visible', () {
      viewModel.startNewGame();

      viewModel.submitAnswer(viewModel.screenData.answers.first);

      expect(viewModel.dialogState, isA<GameMoneyLadderDialog>());
      expect(_answerState(viewModel, 'Hanoi'), GameAnswerState.idle);
      expect(viewModel.screenData.money.amount, r'$0');
      expect(profileRepository.saveCallCount, 0);
    });

    test('stale AI assistant result is ignored after dialog dismiss',
        () async {
      viewModel.startNewGame();
      viewModel.dismissDialog();

      viewModel.handleFeatureClick(_featureButton(viewModel, 'Ask AI'));
      expect(viewModel.dialogState, isA<GameAIAssistantDialog>());

      viewModel.dismissDialog();
      await Future<void>.delayed(const Duration(milliseconds: 800));

      expect(viewModel.dialogState, isA<GameDialogHidden>());
    });

    test('terminal result is saved once across repeated menu actions',
        () async {
      viewModel.startNewGame();
      viewModel.dismissDialog();

      viewModel.submitAnswer(_answer(viewModel, 'Ho Chi Minh City'));
      await Future<void>.delayed(const Duration(milliseconds: 2600));
      viewModel.dismissDialog();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.dialogState, isA<GameEndedDialog>());
      expect(profileRepository.saveCallCount, 1);

      viewModel.backToMenu();
      viewModel.backToMenu();
      await Future<void>.delayed(Duration.zero);

      expect(profileRepository.saveCallCount, 1);
    });
```

— và ba helper cuối file (verbatim):

```dart
GameAnswerOptionData _answer(GameScreenViewModel viewModel, String text) {
  return viewModel.screenData.answers.singleWhere(
    (answer) => answer.answerText == text,
  );
}

GameAnswerState _answerState(GameScreenViewModel viewModel, String text) {
  return _answer(viewModel, text).state;
}

GameFeatureButtonData _featureButton(
  GameScreenViewModel viewModel,
  String label,
) {
  return viewModel.screenData.featureButtons.singleWhere(
    (button) => button.semanticLabel == label,
  );
}
```

**Bước 2 — `flutter analyze` + `flutter test`** → **254/254**;
`flutter build web` PASS. Đóng milestone.

## Hiểu code — ba chi tiết dễ trượt

1. **Test 2: guard cứu là `dialogState is!`, KHÔNG phải token.**
   `dismissDialog` không tăng `flowToken` (default branch chỉ đổi
   `dialogState`) → `GameAIAssistantElapsed(2)` đến sau 800ms có
   token *vẫn khớp* (`state.flowToken` vẫn 2 — select AI đã bump
   1→2, dismiss không đụng). Cái loại nó là guard thứ hai
   `state.dialogState is! GameAIAssistantDialog` → `_result(state)`
   → dialog giữ `GameDialogHidden`. Hai guard hai vai — token cho
 "flow đã tăng", dialog-check cho "dialog đã đổi".
2. **Test 3: save-once là reducer-guard, nav vẫn emit.** Hai
   `backToMenu` → hai reduce `_withSaveResult`; lần hai
   `hasSavedResult == true` → `_result(state, effects: effects)`
   → `GameNavigateToMenu` vẫn add vào `uiEvents` (UI vẫn pop
   được) nhưng **không** `GameSaveResult` op → `saveCallCount`
 giữ 1. Idempotence giờ sống trong reduce.
3. **Đồng hồ thật, không FakeAsync.** `2600ms > 1500+1000` đủ cho
   reveal+explanation; `800ms > 700` đủ cho AI delay; `Duration.zero`
   flush microtask để `unawaited` op (`_saveGameResult` → fake
   repo fast) hoàn tất trước assert. Chậm ~4 giây tổng — giá của
   verbatim-senior thay vì đổi sang `FakeAsync`.

## Chạy và quan sát

```text
flutter analyze → No issues found!
flutter test test/view_models/game/game_screen_view_model_regression_test.dart → 3/3 xanh
flutter test    → +254: All tests passed!   (251 + 3)
flutter build web → PASS
```

Milestone đóng: 236 → 241 (+5 notifier) → 241 (+0 contract) →
251 (+10 reducer) → 251 (+0 migration, test cũ xanh nguyên) →
254 (+3 regression).

## Thử nghiệm

Đoán `profileRepository.saveCallCount` / `viewModel.dialogState`
cho bốn kịch bản trên cùng `setUp` (trước khi đối chiếu test):

(a) `startNewGame()` → `dismissDialog()` → `submitAnswer(sai)` →
đợi 2600ms → `dismissDialog()` → `backToMenu()` ×3;
(b) `startNewGame()` → `backToMenu()` (chưa dismiss intro);
(c) `startNewGame()` → `dismissDialog()` → `backToMenu()` ×2.

<details>
<summary>Đáp án</summary>

- a → `saveCallCount == 1`, `dialogState == GameEndedDialog` —
  `_endGame` save một lần tại dismiss; ba `backToMenu` vẫn emit
  nav nhưng op bị `hasSavedResult` chặn, dialog không đổi
  (đúng shipped test 3, mở rộng lần thứ ba).
- b → `saveCallCount == 1`, `dialogState` vẫn
  `GameMoneyLadderDialog` — `backToMenu` từ `notStarted` vẫn đi
  `_backToMenu` → `_withSaveResult` (walkAway=0, isWin=false):
  save chạy ngay cả khi chưa chơi — "về menu từ intro" vẫn ghi
  một result; `copyWith` chỉ đụng `remainingTime` nên `dialogState`
  giữ intro (nav đã pop màn hình — state vẫn nhớ). Đây là
  senior-verbatim, không phải bug.
- c → `saveCallCount == 1`, `dialogState == GameDialogHidden` —
  cùng lý do: lần đầu save (walkAway=0), lần hai bị flag chặn;
  intro đã dismiss trước đó nên dialog giữ hidden suốt.
</details>

## Lỗi hay gặp

1. **Tưởng token-guard cứu test 2** — `dismissDialog` không bump
   `flowToken`; guard thực sự cứu là `dialogState is!
   GameAIAssistantDialog`. Đọc đúng guard đúng lớp.
2. **Assert `saveCallCount == 0` khi `backToMenu` sớm** — save
   chạy ngay cả từ intro/`playing` (walkAway có thể 0 nhưng
   `questionCount`/`gamesJoined` vẫn ghi) — senior semantics.
3. **Đổi test sang `FakeAsync` "cho nhanh"** — phá verbatim
   senior và đổi điều test chứng minh (đồng hồ thật chứng minh
   `Future.delayed` của bridge đúng delay).
4. **Tưởng regression test "dư thừa" vì suite cũ xanh** — pins
   nhắm edge kiến trúc mới (vòng dispatch, op-once, guard tầng)
   mà test cũ không nhắm trực tiếp.

## Tự làm — DEBUG (planted bug)

Trong `_withSaveResult` (session flow), xoá nhánh
`if (state.hasSavedResult) return _result(state, effects: effects);`
— tức mọi terminal transition đều phát `GameSaveResult` op. Chạy
`flutter test test/view_models/game/game_screen_view_model_regression_test.dart`:
đoán test nào đỏ, assert nào, Actual là gì?

:::note[Gợi ý]
Test 3 gọi `backToMenu()` **hai lần** sau khi `_endGame` đã save
một lần.
:::

<details>
<summary>Đáp án — đã verify bằng đọc code</summary>

Đỏ `'terminal result is saved once across repeated menu actions'`
tại `expect(profileRepository.saveCallCount, 1)` **cuối** (assert
đầu vẫn xanh — `_endGame` save đúng một lần). Mỗi `backToMenu`
tiếp theo phát thêm một `GameSaveResult` op → `executeAsyncOp` →
`_saveGameResult` → `saveUserProfile` được gọi thêm → Actual ≥ 2
(hai op lọt qua; số chính xác phụ thuộc flush của
`Duration.zero`). Điểm mấu chốt: `hasSavedResult` trong
**state**, check trong **reducer** — là nơi DUY NHẤT giữ
save-once; VM không tự đếm.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao regression test tồn tại *sau* refactor thay vì
  *trước*? — **Đáp:** chúng là pins khóa hành vi quan sát được
  của kiến trúc mới — viết sau khi cấu trúc chốt để ghim
  semantics qua mọi refactor tiếp theo; suite cũ (236) đã pin
  semantics cũ.
- **Hỏi:** test 2 chứng minh guard nào, và tại sao KHÔNG phải
  token-guard? — **Đáp:** `dialogState is! GameAIAssistantDialog`
  — `dismissDialog` không bump `flowToken` nên token vẫn khớp;
 cái loại stale là dialog-check (hai guard hai vai).
- **Hỏi:** `backToMenu` lần hai — cái gì emit, cái gì bị chặn? —
  **Đáp:** `GameNavigateToMenu` effect vẫn emit (UI vẫn pop);
  chỉ `GameSaveResult` op bị `hasSavedResult` chặn.
- **Hỏi:** converge ở mức file nghĩa là gì? — **Đáp:**
  VM `extends DreChangeNotifier` + `GameReducer` + `asyncOp`
  `GameSaveResult` + `flowToken`-in-state — intermediate
  `ChangeNotifier`+manual-guards retire, khớp senior form.

## Ta cố ý chưa thêm

- `shareResult` + `GameShareRequested`/`GameShareResult`/
 `GameShareResultEvent` — **M27**.
- Platform extras: notification permission/scheduling + version
 text `v$appVersion` — **M27** (residual).
- Visual parity: `SettingsDialogShell`/`OnboardingGameButton`/
 icon-asset/`LevelProgressCard` — **M28** (32/34).
- `MenuDialogLayer` + `MenuDialogAuth`/`MenuDialogSignOut` state
 — **M29**.
- `onAsyncOpError` override / rollback-save / `==` cho
  `GameState` / DRE hoá các VM khác — senior không có.

## Checkpoint hoàn thành

- [ ] `game_screen_view_model_regression_test.dart` đủ 3 test
  xanh (verbatim senior, fake helper M14).
- [ ] `flutter analyze` sạch; `flutter test` **254/254**;
  `flutter build web` PASS.
- [ ] Nói được: test 2 được cứu bởi `dialogState is!` (không
  phải token); `backToMenu` ×2 emit nav nhưng save một lần.
- [ ] Kể được converge thế nào (intermediate →
  `DreChangeNotifier` + `GameReducer` + `asyncOp`) và divergence
  nào còn mở ở milestone nào (M27/M28/M29).

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** `part`/`part of` + private `extension` theo flow
 domain; `abstract interface class` marker + generic
 bounds; effects-stream → bridge; async-op
 boundary + post-reduce snapshot; project-local reducer
; `flowToken`-in-state stale guard (ý tưởng
 `_requestId` nhưng token sống trong state, check ở
   reducer).
2. **Giải thích được?** Vì sao reducer thuần (10 test không
   Flutter); vì sao effect là data chứ không phải `Timer`; vì sao
   token nằm trong `GameState`; vì sao `hasSavedResult` guard
   sống ở reducer; vì sao `GameState` không cần `==`; vì sao repo
   không expansion "DRE".
3. **Viết lại không copy?** Tự làm: `Multiply` counter action
   (Bài 1) + PREDICT chuỗi dispatch (Bài 2) + copyWith dismiss
   (Bài 3) + test `GameTimerTicked`-ngoài playing và DEBUG xoá
   `flowToken !=` (Bài 4) + PREDICT vòng lặp effect (Bài 5) +
   DEBUG xoá `hasSavedResult` (Bài 6).
4. **Nếu … thì sao?** Delayed callback trễ → token lệch → reducer
   no-op; dismiss dialog → delay vẫn "đúng token" nhưng
   `dialogState is!` loại; dispatch sau dispose → ignored; op
   throw → `onAsyncOpError` (game mặc định — `_saveGameResult`
   nuốt+log); `backToMenu` ×n → save một lần, nav emit n lần.
5. **Cần ở đâu sau?** M27 share plumbing + platform extras;
   M28 visual parity; M29 `MenuDialogLayer`. Shape
   `dispatch → reduce → effect/asyncOp` là mẫu cho mọi
   state-machine lớn sau này.
