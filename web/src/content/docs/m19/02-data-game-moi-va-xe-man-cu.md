---
title: "Bài 2 · Nền data mới + xé màn chơi cũ"
description: "Dựng toàn bộ lớp data của game theo senior: GamePhase 6 giá trị, họ dialog sealed, GameSessionState bất biến + copyWith clear*, question model 8 field + ngân hàng 15 câu, thang tiền 15 bậc, GameResult.earnedAmount — rồi xé màn cũ để stub."
sidebar:
  label: "Bài 2 · nền data"
  order: 2
---

## Mục tiêu

- Tạo được `GameSessionState` — object bất biến giữ *toàn bộ* state
  một ván — và hiểu vì sao `copyWith` cần flag `clearSelectedAnswer`.
- Port được question model của senior (8 field, giải thích per-answer)
  và ngân hàng 15 câu mẫu.
- Dựng thang tiền 15 bậc với mốc an toàn tại Q5/Q10/Q15.
- Xé `game_screen.dart` cũ thành stub trống — game "mất" tạm, test
  cũ được thay bằng test cho model mới.

## Bạn đang ở đâu

- Bài 1: bạn đã có mental model máy trạng thái.
- Code hiện tại vẫn là `GameScreen` cũ 600+ dòng — cuối bài này nó
  thành stub ~15 dòng; Bài 5 mới dựng UI thật trở lại.
- Checkpoint cuối bài: `flutter analyze` sạch + `flutter test`
  **95/95** (xóa 14 test cũ, thêm 7 test bank câu hỏi, viết lại
  sealed test).

## Vì sao việc này quan trọng ngay bây giờ

Máy trạng thái chỉ là ý tưởng cho tới khi nó là *code*: một `enum`
cho tập trạng thái, một class bất biến cho "ảnh chụp" hiện tại, và
`copyWith` là cách duy nhất tạo ảnh chụp mới. Bài này đặt cả ba cái
đó xuống đất — cộng thêm model câu hỏi và thang tiền của senior, vì
VM ở Bài 4 sẽ làm việc trực tiếp trên chúng.

## Bạn đã biết gì

- `enum` với field (`displayName`), `sealed class` + `final class`
  variant (M15 — dialog family của menu cũng thế này).
- `copyWith`; `Duration` cơ bản; `const` constructor.
- `GameResult` + cơ chế pop-result (M10).

## Dựng từng phần

### Bước 1 — `GamePhase` + họ `GameDialogState` + event một-lần

Tạo `lib/data/game/game_session_state_data.dart` — file này giữ ba
thứ: phase của ván, họ dialog đóng kín, event một-lần:

```dart
enum GamePhase {
  /// Ván chưa bắt đầu — intro (thang tiền) đang mở.
  notStarted,
  /// Đang chơi — timer chạy, có thể bấm đáp án.
  playing,
  /// Đã bấm đáp án — chờ delay reveal (1.5s).
  answeredPending,
  /// Đã reveal đúng/sai — chờ delay trước dialog giải thích (1s).
  answeredRevealed,
  /// Ván thua kết thúc.
  gameOver,
  /// Thắng trọn câu cuối.
  victory,
}
```

Đọc kỹ hai phase giữa: `answeredPending` và `answeredRevealed` tách
"đã bấm, đang chờ chấm" khỏi "đã chấm, đang hiện màu đúng/sai". Đây
là chỗ máy trạng thái thắng boolean: muốn ô vừa bấm sáng màu chờ
rồi mới lộ đáp án, bạn cần *hai* phase — với boolean bạn sẽ phải
ghép `isSubmitted && !isRevealed`, một tổ hợp không tên.

Họ dialog (cùng file) — `sealed class GameDialogState` với 6
variant `final`:

- `GameDialogHidden` — không dialog.
- `GameMoneyLadderDialog({items})` — intro thang tiền; `items` là
  `List<GameMoneyLadderItemData>` (index/amount/isCurrent/isSpecial)
  đã format sẵn.
- `GameConfirmExitDialog({guaranteedAmount})` — xác nhận thoát,
  hiện mốc an toàn.
- `GameExplanationDialog({question, correctAnswer, explanation,
  isCorrect})` — giải thích sau reveal.
- `GameEndedDialog({earnedAmount})` / `GameVictoryDialog
  ({earnedAmount, affirmationMessage})` — hai dialog kết thúc.
  Senior chỉ phân biệt bằng *số tiền*, không có `GameEndReason`
  như learner cũ.

Và event một-lần (nhớ M13/M15: event ≠ state — listener mới không
được replay):

```dart
sealed class GameScreenUiEvent { const GameScreenUiEvent(); }

/// Xin điều hướng về menu — UI tự pop (kèm GameResult).
final class GameNavigateToMenuEvent extends GameScreenUiEvent {
  const GameNavigateToMenuEvent();
}

/// dialogState vừa đổi sang variant mở — bridge mở showDialog,
/// nội dung đọc từ viewModel.dialogState. Scaffold tới M21.
final class GameDialogRequested extends GameScreenUiEvent {
  const GameDialogRequested();
}
```

`GameDialogRequested` đáng một câu giải thích ngay: `dialogState`
(trong session state) là *nguồn thật* — nó nói "dialog nào đang
mở, nội dung gì". Event này chỉ là *tín hiệu* cho widget bridge
gọi `showDialog` đúng lúc (Bài 5). Senior render dialog trong
`Stack` nên không cần event này — learner giữ `showDialog` tới M21.

### Bước 2 — `GameSessionState`: ảnh chụp bất biến của ván

Cùng file — class trung tâm của milestone:

```dart
final class GameSessionState {
  const GameSessionState({
    required this.phase,
    required this.questionIndex,
    required this.moneyEarned,
    required this.guaranteedAmount,
    required this.moneyAnimationTrigger,
    required this.remainingTime,
    required this.dialogState,
    required this.flowToken,
    this.selectedAnswer,
  });

  factory GameSessionState.initial({required Duration timePerQuestion}) {
    return GameSessionState(
      phase: GamePhase.notStarted,
      questionIndex: 0,
      moneyEarned: 0,
      guaranteedAmount: 0,
      moneyAnimationTrigger: 0,
      remainingTime: timePerQuestion,
      dialogState: const GameDialogHidden(),
      flowToken: 0,
    );
  }
  // ... 9 final field + copyWith
}
```

Chín field, chia ba nhóm:

| Nhóm | Field | Vai trò |
|------|-------|---------|
| máy trạng thái | `phase`, `dialogState` | "đang ở đâu" trong ván + dialog nào mở |
| tiến trình | `questionIndex`, `moneyEarned`, `guaranteedAmount`, `selectedAnswer` | câu nào, tiền đang có, mốc an toàn đã qua, đáp án đã bấm |
| hạ tầng | `remainingTime`, `moneyAnimationTrigger`, `flowToken` | đồng hồ; key phát lại animation tiền; token vô hiệu callback delay cũ |

`selectedAnswer` là `String?` *theo text* (senior parity — không
lưu index). Ba giá trị có nghĩa: `null` = chưa bấm; `''` = hết giờ
(xử như sai); text thật = đã bấm.

#### `copyWith` + flag `clear*` — pattern mới quan trọng

```dart
GameSessionState copyWith({
  GamePhase? phase,
  /* ... mọi field khác ... */
  String? selectedAnswer,
  bool clearSelectedAnswer = false,
}) {
  return GameSessionState(
    phase: phase ?? this.phase,
    /* ... */
    selectedAnswer: clearSelectedAnswer
        ? null
        : selectedAnswer ?? this.selectedAnswer,
  );
}
```

Vấn đề `copyWith` truyền thống: field nullable không phân biệt được
"không truyền" (`selectedAnswer` không đổi) với "truyền null" (xóa
đáp án khi sang câu mới). `??` nuốt cả hai. Senior giải bằng flag
tường minh `clearSelectedAnswer` — bạn sẽ thấy nó chạy ở Bài 4 khi
`_loadNextQuestionOrVictory` reset đáp án.

Ví dụ độc lập cho pattern này (DartPad được):

```dart
class Form {
  final String name;
  final String? note;
  const Form({required this.name, this.note});

  Form copyWith({String? name, String? note, bool clearNote = false}) {
    return Form(
      name: name ?? this.name,
      note: clearNote ? null : note ?? this.note,
    );
  }
}

void main() {
  final f = Form(name: 'a', note: 'x');
  print(f.copyWith(name: 'b').note);      // 'x' — giữ nguyên
  print(f.copyWith(clearNote: true).note); // null — xóa rõ ràng
}
```

### Bước 3 — Question model 8 field của senior

`lib/data/game/game_quiz_question_data.dart` — thay model cũ 3
field + method (`question`/`options`/`correctIndex` + `isCorrect`):

```dart
enum GameQuestionDifficulty {
  easy('Easy'), medium('Medium'), hard('Hard');
  final String displayName;
  const GameQuestionDifficulty(this.displayName);
}

class GameQuestionExplanationData {
  final String explainForTrueAnswer;        // giải thích khi đúng
  final Map<String, String> explainForWrongAnswers; // per-đáp-án sai
  final String aiHintMessage;               // M20 mới dùng — AI hint
  const GameQuestionExplanationData({
    required this.explainForTrueAnswer,
    required this.explainForWrongAnswers,
    required this.aiHintMessage,
  });
}

class GameQuizQuestionData {
  final int id;
  final String question;
  final List<String> options;
  final String correctOption;   // theo TEXT, không phải index
  final String category;
  final String language;
  final GameQuestionDifficulty difficulty;
  final GameQuestionExplanationData explanation;
}
```

Hai điểm khác biệt cần nhớ:

- `correctOption` là **text** ("Bản in" chứ không phải index 1) —
  vì thế `selectedAnswer` trong session state cũng lưu text; so
  sánh `==` chuỗi là đủ.
- `explainForWrongAnswers` là `Map<String,String>`: key = text đáp
  án sai, value = lời giải thích riêng *cho từng sai lầm*. Dialog
  giải thích (Bài 4) chọn đúng entry; `aiHintMessage` là fallback
  chung — và chính là message lifeline "Hỏi AI" sẽ dùng ở M20.

### Bước 4 — Ngân hàng 15 câu + thang tiền 15 bậc

Senior bank gồm 3 file theo độ khó — copy cấu trúc y hệt:

```text
lib/data/game/
  game_sample_easy_questions_data.dart    // gameSampleEasyQuestions — 5 câu
  game_sample_medium_questions_data.dart  // gameSampleMediumQuestions — 5 câu
  game_sample_hard_questions_data.dart    // gameSampleHardQuestions — 5 câu
  game_sample_questions_data.dart         // gameSampleQuestions — gộp 15
```

`game_sample_questions_data.dart` chỉ là (chú ý prefix `game` —
tên y hệt senior):

```dart
const gameSampleQuestions = [
  ...gameSampleEasyQuestions,
  ...gameSampleMediumQuestions,
  ...gameSampleHardQuestions,
];
```

15 câu ↔ 15 level thang tiền — `game_money_ladder_data.dart`:

```dart
const gameMoneyLadderLevels = [
  GameMoneyLadderLevelData(level: 1, amount: 1000, isSafeHaven: false, difficulty: 'Easy'),
  // ... 2–4 Easy ...
  GameMoneyLadderLevelData(level: 5, amount: 20000, isSafeHaven: true,  difficulty: 'Easy'),
  // ... 6–9 Medium ...
  GameMoneyLadderLevelData(level: 10, amount: 400000, isSafeHaven: true, difficulty: 'Medium'),
  // ... 11–14 Hard ...
  GameMoneyLadderLevelData(level: 15, amount: 1000000, isSafeHaven: true, difficulty: 'Hard'),
];
```

`isSafeHaven` = mốc an toàn: qua Q5 bạn chắc chắn có $20,000, qua
Q10 có $400,000, Q15 là $1,000,000. Sai ở bất kỳ câu nào → ván
kết thúc với `guaranteedAmount` (mốc an toàn cao nhất đã qua),
không phải `moneyEarned`. Thứ tự file khớp độ khó câu hỏi: 5 easy
đầu cho level 1–5, medium cho 6–10, hard cho 11–15.

### Bước 5 — `GameResult.earnedAmount`

`lib/data/game/game_result.dart` thêm field thứ tư:

```dart
class GameResult {
  final int questionsAnswered;
  final int correctAnswers;
  final bool won;
  final int earnedAmount; // MỚI — tiền theo thang thật
}
```

Trước M19, `applyGameResult` ở profile tự suy tiền từ `correctAnswers`
(chính sách phẳng). Giờ tiền đến từ thang — game tính, result chở.
Đây là nửa đầu của việc đóng gói kết quả; phần `EXP = earnedAmount`,
`totalEarnings`, `totalQuestionCount` thuộc M22.

Cập nhật `UserProfileData.applyGameResult`: dùng `result.earnedAmount`
cho tiền, giữ EXP đếm theo `correctAnswers` (như cũ). Patch các
construction `GameResult(` trong test thêm `earnedAmount:`.

### Bước 6 — ARB: đổi bộ string game sang key senior

UI tap-to-submit làm chết các key cũ (`gameNextButton` và đồng bọn,
`submitAnswerButton`, `correctFeedback`, `wrongFeedback`,
`victoryTitle`, `timeoutTitle`, `correctCountBase`, `secondsRemaining`…).
Trong `app_en.arb`/`app_vi.arb`, block game mới
dùng tên key senior cho các dialog (chuỗi English port verbatim, vi
dịch), cộng hai key learner cho top bar:

- `gameRoomTitle`, `questionCounter` ("Question {index}/{count}" —
  placeholder `index`/`count`, không phải `current`/`total`; hai key
  này là *learner-named* cho top bar, senior không có — các key
  dialog bên dưới mới là tên verbatim senior)
- `moneyLadderTitle` — dialog thang tiền (intro + giữa ván)
- `exitGameTitle` / `exitGameMessage` / `exitGameButton` /
  `continuePlayingButton` — confirm-exit (đừng quên nút "chơi tiếp",
  thiếu nó break compile ở Bài 5)
- `aiExplanationsTitle` / `understandButton` — dialog giải thích
- `gameOverTitle` / `congratulationsTitle` / `youEarnedLabel` —
  hai dialog kết thúc
- `playAgainButton` / `menuButton` — nút trên dialog kết thúc
  (chuỗi learner "PLAY AGAIN"/"MENU" viết hoa; senior hiển thị hoa
  bằng `toUpperCase()` — chữ khác nhau, key giống)

Sau đó `flutter gen-l10n` (hoặc để `flutter pub get`/`analyze` sinh
lại). Rule tự kiểm: `grep` tên key cũ trong `lib/` phải ra 0 kết
quả trước khi xóa key khỏi ARB — ví dụ `grep gameNextButton lib/`
(tên key cũ thật, đã đổi ở M18) phải không còn hit nào.

### Bước 7 — Xé màn cũ, thay test

Cuối cùng, phần nặng ký nhất:

1. `lib/screens/game_screen.dart` → stub:

   ```dart
   class GameScreen extends StatelessWidget {
     const GameScreen({super.key});
     @override
     Widget build(BuildContext context) =>
         const Scaffold(body: Center(child: Text('Game — M19 WIP')));
   }
   ```

   `MenuScreen` vẫn `Navigator.push` tới `GameScreen` như cũ
   (`AppNavigationController` chưa tồn tại — Bài 5 mới tạo) → app
   compile được — nhưng game thật "mất" tới Bài 5.

   ⚠️ Đừng quên `lib/data/onboarding/onboarding_content_data.dart`:
   file này import ngân hàng câu hỏi cũ — sửa nó sang
   `gameSampleQuestions.length` (label "15 câu" của card onboarding)
   ngay trong bước này, nếu không `analyze` báo import chết.

2. Xóa file model/test cũ: `quiz_question.dart` (model 3-field)
   **và** `quiz_questions.dart` — ngân hàng 4 câu cũ import model
   đó, để sót lại sẽ break analyze; rồi `test/quiz_questions_test.dart`,
   `test/widgets/game_screen_test.dart` (toàn bộ — nó test UI cũ
   không còn tồn tại).

3. Viết `test/game_sample_questions_test.dart` mới (7 test):
   bank đúng 15 câu; mọi câu đúng 4 option; `correctOption` phải
   nằm trong `options`; mọi *option sai* đều có key giải thích trong
   `explainForWrongAnswers` (chiều assert: wrong options ⊆ keys);
   `difficulty` nằm trong tập enum hợp lệ.

4. Viết lại `test/sealed_state_test.dart` cho họ dialog mới
   (`GameDialogState` 6 variant — switch kiệt hợp, mỗi variant mang
   đúng payload).

5. Chạy `flutter analyze` + `flutter test` → **95/95**.

:::caution[TEACHING SCAFFOLD — stub screen]
Stub `GameScreen` chỉ tồn tại để app compile trong khoảng trống
Bài 2–4; nó không phải sản phẩm. Hội tụ: Bài 5 của chính milestone
này thay stub bằng màn VM-backed thật.
:::

## Android / Compose bridge

- **SIMILARITY:** một `data class UiState` bất biến + `copy()` của
  Kotlin chính là `GameSessionState` + `copyWith` ở đây — cùng ý
  tưởng "state mới = bản sao có sửa".
- **IMPORTANT DIFFERENCE:** Kotlin `copy(note = null)` truyền được
  null thật; Dart `copyWith(note: null)` bị `??` nuốt — vì vậy cần
  `clearNote` flag. Đây là idiomatic Dart, không phải lỗi thiết kế.
- **DO NOT ASSUME:** sealed dialog family này không render tự thân —
  nó chỉ là *data*; ai render (bridge `showDialog` M19, `Stack` M21)
  là chuyện của Bài 5.

## Senior project connection

- `lib/data/game/game_session_state_data.dart` (senior) — file
  nguồn của port: `GamePhase`, `GameDialogState` family (senior có
  thêm 3 variant lifeline → M20), `GameScreenUiEvent` (senior có
  thêm `GameShareResultEvent` — share đến M27).
- `lib/data/game/game_quiz_question_data.dart` + 3 file bank
  `game_sample_*` (senior) — port nguyên shape; bank learner chứa
  bộ câu hỏi mẫu riêng nhưng cùng schema.
- `lib/data/game/game_money_ladder_data.dart` (senior) — 15 level
  verbatim.
- `lib/view_models/game/dre/game_dre_state.dart` (senior) — nơi
  `GameState` đầy đủ sống; `GameSessionState` là bản "lite" cùng
  shape, DRE ở M26.

## Chạy và quan sát

```bash
flutter pub get      # gen-l10n lại nếu cần
flutter analyze      # phải sạch — stub compile được
flutter test         # 95/95
```

Và xác nhận game "chết có chủ đích": chạy app, bấm BẮT ĐẦU CHƠI →
màn stub "Game — M19 WIP". Nếu thấy thế = đúng.

## Tự làm — viết transition "sang câu mới" bằng tay

Bạn chưa cần VM để luyện `copyWith` + `clear*`. Cho trước:

```dart
final s = GameSessionState(
  phase: GamePhase.answeredRevealed,
  questionIndex: 3,
  moneyEarned: 500,
  guaranteedAmount: 200,
  moneyAnimationTrigger: 1,
  remainingTime: const Duration(seconds: 12),
  dialogState: const GameDialogHidden(),
  flowToken: 2,
  selectedAnswer: 'Paris',
);
```

**Nhiệm vụ** — viết `s.copyWith(...)` tạo state của câu 4 đang chơi:

1. `phase` → `GamePhase.playing`, `questionIndex` → `4`,
   `remainingTime` → reset đồng hồ (`Duration(seconds: 30)`), và
   **quên đáp án cũ** — dùng đúng cơ chế `clear*`.
2. Dự đoán trước khi chạy: `moneyEarned`, `moneyAnimationTrigger`,
   `flowToken` của state mới là bao nhiêu — và ai sẽ đụng chúng ở
   transition thật (Bài 4)?
3. Cố tình viết `selectedAnswer: null` thay vì cờ `clear*` — chạy
   và in `selectedAnswer` — nó *có* bị xoá không? Giải thích hành vi
   của `??` trong `copyWith`.

Xác minh bằng `dart run` scratch hoặc `expect` trong test tạm:
`next.selectedAnswer == null`, `next.phase == GamePhase.playing`,
`next.flowToken == 2` (giữ nguyên — token chỉ đổi khi VM quyết bắt
đầu flow mới ở Bài 4).

<details><summary>Đáp án</summary>

```dart
final next = s.copyWith(
  phase: GamePhase.playing,
  questionIndex: 4,
  remainingTime: const Duration(seconds: 30),
  clearSelectedAnswer: true,   // null tường minh — ?? không bẫy được
);
```

- `moneyEarned`/`guaranteedAmount`/`moneyAnimationTrigger`/`flowToken`
  giữ nguyên — không truyền = giữ (đó là nghĩa của `??`).
- `selectedAnswer: null` **không xoá được** — `null ?? this.selectedAnswer`
  → `'Paris'` sót lại sang câu 4 (bug hiển thị đáp án cũ). Đây chính là
  lý do flag `clearSelectedAnswer` tồn tại: phân biệt "không truyền" với
  "truyền null".

Điểm học: immutable snapshot + `copyWith` flag = mỗi transition là một
*phép tính* bạn tự viết được — VM của Bài 4 chỉ là nơi gọi những phép
đó theo đúng thứ tự.

</details>

## Kiểm tra hiểu biết## Kiểm tra hiểu biết

1. Vì sao `copyWith` cần `clearSelectedAnswer` thay vì cho phép
   `selectedAnswer: null`?
   → `??` không phân biệt "không truyền" vs "truyền null"; flag tường
   minh là cách Dart idiomatic xử lý nullable field.
2. `selectedAnswer = ''` nghĩa gì, khác `null` thế nào?
   → `''` = hết giờ (đã "trả lời" một đáp án rỗng — xử như sai khi
   reveal); `null` = chưa bấm gì.
3. `guaranteedAmount` khác `moneyEarned` ở đâu?
   → `moneyEarned` = tiền level hiện tại (mất khi sai);
   `guaranteedAmount` = mốc an toàn cao nhất đã qua (giữ khi sai).
4. Vì sao `correctOption` là text chứ không phải index?
   → Senior parity: mọi so sánh đáp án đều theo text; đáp án trùng
   text nhau vẫn đúng semantics vì đều là "cùng đáp án".

## Sai lầm thường gặp

- **Quên `flutter gen-l10n`** sau khi sửa ARB → analyzer báo thiếu
  getter `AppLocalizations` mới.
- **Xóa key ARB còn đang được dùng** — phải grep hết tham chiếu
  trước.
- **Để test cũ sống sót** — test trỏ vào widget/model đã xóa sẽ fail
  compile, không phải fail assert; xóa file test cũ ngay khi xóa
  production cũ.
- **`copyWith` thiếu field** — quên forward một field trong phần
  `??` làm state "mất lặng lẽ". Cứ thêm field là sửa `copyWith`.

## Ta cố ý chưa thêm

- `visibleOptionTexts`, `audiencePercentiles`, `usedFeatureButtons`
  trong `GameSessionState` — lifelines M20.
- `GameConfirmWalkAwayDialog`/`GameAudiencePollDialog`/
  `GameAIAssistantDialog` — M20.
- `GameShareResultEvent` — share đến M27, chưa cần giờ.
- `hasSavedResult` — lưu kết quả VM-side ở M22.

## Checkpoint hoàn thành

- [ ] `lib/data/game/` có: `game_session_state_data.dart`,
  `game_quiz_question_data.dart`, `game_money_ladder_data.dart`,
  3 file bank + aggregator, `game_result.dart` (4 field),
  `game_screen_data.dart` sẽ đến ở Bài 3.
- [ ] `game_screen.dart` là stub; `flutter analyze` sạch.
- [ ] `flutter test` = **95/95** (7 test bank mới + sealed mới).
- [ ] `grep gameNextButton lib/` = 0 kết quả (key cũ đã xóa sạch).
