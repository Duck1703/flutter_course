---
title: "Bài 2 · Nền data lifeline: state, dialog, helper thuần"
description: "Thêm 4 field state, item-poll + DTO nút feature + enum, helper toán thuần 50:50/poll, 12 key ARB — chưa nối VM/UI (sealed variant đi kèm UI ở Bài 3/4). Checkpoint: analyze sạch, 131/131."
sidebar:
  label: "Bài 2 · data + helper"
  order: 2
---

## Mục tiêu

- Thêm đúng *vị trí data* của lifelines: field mới trên
  `GameSessionState`, item/DTO poll + nút feature — mà **không**
  thay đổi hành vi runtime nào. (Sealed variant đến cùng UI ở
  Bài 3/4 — compiler ép điều đó.)
- Port verbatim ba hàm toán thuần của senior và chứng minh chúng
  đúng bằng unit test (không cần pump widget).
- Thêm 12 key localization senior-verbatim cho các dialog/nút mới.

## Bạn đang ở đâu

- Đầu M20 — app đang ở trạng thái cuối M19: 126/126 test, màn
  chơi chạy trên VM 6 phase, chưa có nút lifeline nào.
- Bài này "đổ nền": mọi thứ thêm vào đều **trơ** — VM chưa đọc
  field mới, UI chưa render nút nào. Chạy app sau bài này game
  y hệt M19. Đó là cố ý: data trước, hành vi sau.

## Vì sao việc này quan trọng ngay bây giờ

Thứ tự "data → VM → UI" là cách senior được cấu trúc và cũng là
cách diff dễ review nhất: file `game_session_state_data.dart` và
`game_screen_data.dart` định nghĩa *vùng đứng* của toàn bộ
lifeline — nếu state không có chỗ chứa `usedFeatureButtons`, VM
ở Bài 3 không có gì để `copyWith`.

Ba hàm trong `game_lifeline_helper.dart` là **thuần** — vào
question, ra kết quả, không state, không side-effect. Đây là
lớp dễ test nhất của milestone: viết xong chạy `flutter test`
là biết ngay đúng/sai, trước khi VM nào dùng tới.

## Bạn đã biết gì

- `copyWith` + cờ `clear*` trên state bất biến (M19);
  `List.unmodifiable` emit discipline (M18).
- `sealed class` + exhaustive `switch` (M15) —
  `GameDialogState` đã là sealed từ M15.
- `Set` mental model + `{...old, x}` / `contains` /
  `Set.unmodifiable` (Bài 1).
- ARB + generated localizations (M17); map literal
  + `jsonDecode` (M10).

## Mental model mới — "% poll là Map keyed bằng *text đáp án*"

`audiencePercentiles` có kiểu `Map<String, int>?` — key là
**text** của option (`'A0'`), không phải index. Vì sao?

- Poll trả "khán giả chọn đáp án X = 68%" — X là nội dung, và
  mapper đối chiếu theo `answerText` của từng ô.
- Ô bị 50:50 xóa (`''`) tự nhiên rớt khỏi map (không có key
  `''`) → item của nó 0% — senior dựng items từ
  `visibleOptionTexts` nên ô xóa hiện 0% trong dialog.
- `null` = "chưa dùng poll câu này" — khác với map rỗng: `null`
  là *chưa có*, `{}` là *có nhưng trống*. M19/02 đã dạy phân biệt
  này qua cờ `clear*` — `audiencePercentiles` dùng cùng pattern
  (`clearAudiencePercentiles` khi sang câu).

## Dart cần dùng / Dart mới

| Cú pháp | Ví dụ | Nghĩa |
|---|---|---|
| `firstWhere` | `options.firstWhere((o) => o != correct)` | phần tử đầu khớp — ném `StateError` nếu không có |
| map-comprehension | `{for (final o in options) o: value}` | build `Map` bằng for-in trong literal |
| `??` fallback | `answer.audiencePercentile ?? 0` | null → default |
| `fold<int>` | `values.fold<int>(0, (s, v) => s + v)` | gộp collection về 1 giá trị — ở test: tổng % |
| `Set<T>` field + `Set.unmodifiable` | `usedFeatureButtons` | tập đã-dùng bất biến (Bài 1) |
| `Map.unmodifiable` | `Map.unmodifiable(m)` | map chỉ-đọc ở boundary state |

## Android / Compose bridge

- **SIMILARITY:** Kotlin `Set<T>` + `set.plus(x)` trả set mới ↔ Dart
  `{...old, x}`; `firstOrNull`/`first {}` ↔ `firstWhere`; map-of-
  comprehension ↔ `map {}.associate {}`.
- **IMPORTANT DIFFERENCE:** Dart `sealed class` + `switch` expression
  *báo lỗi compile* khi thiếu arm — tương đương `when` trên sealed
  interface Kotlin, nhưng Dart ép kiệt hợp cả ở expression lẫn
  statement switch trên sealed type.
- **DO NOT ASSUME:** `Map<String,int>?` keyed bằng *text* không giống
  `SparseIntArray`/index-keyed — key ở đây là nội dung đáp án.

## Senior project connection

- `view_models/game/support/game_lifeline_helper.dart` (senior) —
  file helper toán thuần: `applyGameFiftyFifty` + `buildGameAudiencePoll`
  + `buildGameAudiencePollItems` + `_splitWrongAudience`. Bài này port
  **verbatim** — đọc senior để thấy từng hàm nguyên bản.
- `data/game/game_session_state_data.dart` (senior `GameState`) —
  `visibleOptionTexts`/`audiencePercentiles`/`usedFeatureButtons` là
  ba field state lifeline thật của senior.
- `data/game/game_screen_data.dart` (senior) — `GameFeatureButtonType`
  năm giá trị + `GameFeatureButtonData` (senior dùng `iconAsset`
  `String`; learner dùng `IconData` — hội tụ visual ở M28).

## Build it step by step

### Bước 1 — Item data của poll (state file)

`lib/data/game/game_session_state_data.dart` — thêm sau
`GameConfirmExitDialog` (trước `GameExplanationDialog`):

```dart
/// Một hàng trong dialog poll — senior `GameAudiencePollItemData`.
final class GameAudiencePollItemData {
  const GameAudiencePollItemData({
    required this.option,
    required this.percentage,
    required this.progress,
  });

  /// Nhãn đáp án (`A`–`D`).
  final String option;

  /// Phần trăm đã format (`"68%"`).
  final String percentage;

  /// Giá trị 0..1 cho thanh progress.
  final double progress;
}
```

:::caution[TEACHING SCAFFOLD — sealed variant đi kèm UI của nó]
Ba sealed variant `GameAudiencePollDialog` / `GameConfirmWalkAwayDialog` /
`GameAIAssistantDialog` sẽ được thêm **ở đúng bài dùng chúng** — poll ở
Bài 3, walk-away + AI ở Bài 4 — chứ không phải ở đây. Lý do kỹ thuật:
`GameDialogState` là `sealed`, nên thêm variant làm ba `switch` kiệt
hợp trong `game_screen.dart` (`_title`/`_content`/`_actions`, đều không
có arm `_`) thành *non-exhaustive* → **lỗi biên dịch ngay**. Variant
phải đến cùng lúc với các arm UI xử lý nó.
:::

### Bước 2 — Bốn field state + `copyWith` + `initial`

Cùng file, trong `class GameSessionState`:

```dart
  /// Text đang hiển thị của từng ô đáp án — M20. Bằng
  /// `question.options` khi chưa 50:50; sau 50:50 hai ô sai bị thay
  /// bằng `''` (mapper render idle + VM chặn submit text rỗng).
  /// `List.unmodifiable` — đúng senior.
  final List<String> visibleOptionTexts;

  /// Phần trăm khán giả theo *text đáp án* — `null` khi chưa dùng
  /// poll; xóa về `null` khi sang câu mới. `Map.unmodifiable` hoặc null.
  final Map<String, int>? audiencePercentiles;

  /// Bộ lifeline đã dùng — sổ "dùng một lần". `Set.unmodifiable`;
  /// mọi ghi đi qua VM (`{...used, type}`).
  final Set<GameFeatureButtonType> usedFeatureButtons;

  /// Kết quả đã chốt của phiên — M20 interim carrier cho transport
  /// route-pop (senior: `GameSaveResult` asyncOp + `hasSavedResult`,
  /// VM persist qua repository — M22). Set khi ván resolve để
  /// `buildGameResult()` không phải suy `won`/`earned` từ phase —
  /// walk-away cũng vào phase `victory` nhưng `won=false`.
  final GameResult? resolvedResult;
```

Ctor: ba field đầu là **named required qua biến trung gian** để gói
unmodifiable ở initializer; `resolvedResult` là `this.` optional:

```dart
  GameSessionState({
    // ... các required cũ giữ nguyên ...
    required List<String> visibleOptionTexts,
    required Map<String, int>? audiencePercentiles,
    required Set<GameFeatureButtonType> usedFeatureButtons,
    this.selectedAnswer,
    this.resolvedResult,
  }) : visibleOptionTexts = List.unmodifiable(visibleOptionTexts),
       audiencePercentiles = audiencePercentiles == null
           ? null
           : Map.unmodifiable(audiencePercentiles),
       usedFeatureButtons = Set.unmodifiable(usedFeatureButtons);
```

`initial()` cập nhật ba dòng seed:

```dart
      visibleOptionTexts: const [],
      audiencePercentiles: null,
      usedFeatureButtons: const {},
```

`copyWith` — ba param `T?` + hai cờ clear mới (tổng ba cờ gồm
`clearSelectedAnswer` cũ):

```dart
    List<String>? visibleOptionTexts,
    Map<String, int>? audiencePercentiles,
    Set<GameFeatureButtonType>? usedFeatureButtons,
    GameResult? resolvedResult,
    bool clearSelectedAnswer = false,
    bool clearAudiencePercentiles = false,
    bool clearResolvedResult = false,
```

và trong thân `return GameSessionState(...)`:

```dart
      visibleOptionTexts:
          visibleOptionTexts ?? this.visibleOptionTexts,
      audiencePercentiles: clearAudiencePercentiles
          ? null
          : audiencePercentiles ?? this.audiencePercentiles,
      usedFeatureButtons:
          usedFeatureButtons ?? this.usedFeatureButtons,
      resolvedResult: clearResolvedResult
          ? null
          : resolvedResult ?? this.resolvedResult,
```

:::note[Vì sao `audiencePercentiles`/`resolvedResult` cần cờ clear?]
`param ?? this.param` không phân biệt được "caller không truyền"
với "caller muốn set `null`" — cờ `clear*` là escape hatch đã học
cờ `clear*` (M19/02). `visibleOptionTexts`/`usedFeatureButtons` không cần
cờ vì chúng không bao giờ "về null" — reset về list rỗng được
viết tường minh `visibleOptionTexts: const []` nếu cần.
:::

File cần `import 'game_screen_data.dart'` (cho
`GameFeatureButtonType`) — kiểm đầu file, thêm nếu thiếu.

### Bước 3 — `game_screen_data.dart`: enum + DTO nút + field poll

Thêm `GameFeatureButtonType` + `GameFeatureButtonData` (đặt trước
`GameScreenData`), và `audiencePercentile` lên
`GameAnswerOptionData`:

```dart
/// Năm nút lifeline của senior (`game_screen_data.dart`) — M20.
/// `exitGame` là nút ✕ trên top bar (không nằm trong thanh lifeline
/// — mapper senior cũng không đưa nó vào `featureButtons`); bốn nút
/// còn lại render ở thanh dưới màn.
enum GameFeatureButtonType {
  fiftyFifty,
  audiencePoll,
  aiAssistant,
  walkAway,
  exitGame,
}

/// Một nút trên thanh lifeline — senior `GameFeatureButtonData`.
/// `icon` là `IconData` thay `String iconAsset` của senior
/// (learner chưa có pipeline SVG/`flutter_svg` — độ sâu visual hội
/// tụ ở M28); `type`/`semanticLabel`/`isEnabled`/`copyWith` giữ
/// đúng shape senior.
class GameFeatureButtonData {
  final GameFeatureButtonType type;
  final IconData icon;
  final String semanticLabel;
  final bool isEnabled;

  const GameFeatureButtonData({
    required this.type,
    required this.icon,
    required this.semanticLabel,
    this.isEnabled = true,
  });

  GameFeatureButtonData copyWith({bool? isEnabled}) {
    return GameFeatureButtonData(
      type: type,
      icon: icon,
      semanticLabel: semanticLabel,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
```

Trên `GameAnswerOptionData` — thêm field optional:

```dart
  const GameAnswerOptionData({
    required this.answerLabel,
    required this.answerText,
    this.state = GameAnswerState.idle,
    this.audiencePercentile,          // M20 — % khán giả, null = chưa poll
  });

  /// Phần trăm khán giả của riêng ô này (sau poll); `null` nếu chưa.
  final int? audiencePercentile;
```

Class này **chưa có `copyWith` từ M19** — thêm *cả method* (không chỉ
một dòng). Chú ý cờ `clearAudiencePercentile`: `??` không set được
`null`, nên xóa % phải qua cờ — cùng pattern `clearSelectedAnswer`
của `GameSessionState`:

```dart
  GameAnswerOptionData copyWith({
    String? answerText,
    GameAnswerState? state,
    int? audiencePercentile,
    bool clearAudiencePercentile = false,
  }) {
    return GameAnswerOptionData(
      answerLabel: answerLabel,
      answerText: answerText ?? this.answerText,
      state: state ?? this.state,
      audiencePercentile: clearAudiencePercentile
          ? null
          : audiencePercentile ?? this.audiencePercentile,
    );
  }
```

(`answerText`/`state` nằm trong chữ ký vì mapper Bài 3 sẽ gọi
`copyWith` trên từng option để gắn `GameAnswerState` + `%` poll.)

:::caution[Chưa thêm `featureButtons` vào `GameScreenData` ở đây]
Field `required featureButtons` trên `GameScreenData` sẽ làm
constructor **đổi chữ ký** — mapper M19 chưa truyền → lỗi biên
dịch. Field này đến ở Bài 3, cùng bước mapper bắt đầu sản xuất
nó. Bài này chỉ thêm *additive* pieces (field optional, class/enum/
method mới — **không** sealed variant nào) nên mọi `switch` kiệt
hợp giữ nguyên và tất cả vẫn compile.
:::

### Bước 4 — Helper toán thuần (verbatim senior)

:::note[Suy luận trước — bảng luật của bạn, không phải của senior]
Hai lifeline sắp được port *verbatim* — nhưng trước khi đọc code,
tự viết bảng luật ra giấy. Cho câu hỏi mẫu:

```
Q: "Thủ đô Việt Nam?"  đúng = "Hà Nội"
options = ["Huế", "Hà Nội", "Đà Nẵng", "Cần Thơ"]   difficulty = easy
```

1. **50:50** — sau khi dùng, `visibleOptionTexts` trông như thế nào?
   Ô sai nào *còn lại*: ngẫu nhiên? ô đầu? ô cuối? — và ô bị xoá
   biểu diễn bằng gì trong list `String` (gợi: mapper đọc text rỗng)?
2. **Hỏi khán giả** — đáp án đúng nhận bao nhiêu % ở độ khó easy,
   và 3 ô sai chia phần còn lại thế nào để tổng = 100? Viết 4 số
   theo thứ tự options — không được dùng số "đẹp" tự nghĩ.
3. Poll là `Map<String,int>` — key là *index* hay *text đáp án*?
   (Nhớ mental model của bài: key bằng gì thì hai option giống nhau
   sẽ va chạm thế nào?)

So với bảng luật senior ngay bên dưới — mỗi chỗ lệch là một câu hỏi
thiết kế đáng hiểu.
:::


File mới
`lib/view_models/game/support/game_lifeline_helper.dart`:

```dart
import '../../../data/game/game_quiz_question_data.dart';
import '../../../data/game/game_screen_data.dart';
import '../../../data/game/game_session_state_data.dart';

/// Hàm thuần của lifelines — verbatim senior
/// `view_models/game/support/game_lifeline_helper.dart` (M20).

/// 50:50 — *deterministic* theo senior (KHÔNG random): giữ đáp án đúng
/// và ô sai ĐẦU TIÊN (`firstWhere`), hai ô sai còn lại thành `''` —
/// chuỗi rỗng = ô bị xóa (mapper render idle, VM chặn submit rỗng).
List<String> applyGameFiftyFifty(GameQuizQuestionData question) {
  final wrong = question.options.firstWhere(
    (it) => it != question.correctOption,
  );
  return question.options
      .map((it) => it == question.correctOption || it == wrong ? it : '')
      .toList(growable: false);
}

/// Poll khán giả — % đáp án đúng theo độ khó (easy 68 / medium 52 /
/// hard 42); phần còn lại chia cho 3 ô sai qua [_splitWrongAudience]
/// (50% / 32% / phần dư → tổng luôn 100).
Map<String, int> buildGameAudiencePoll(GameQuizQuestionData question) {
  final correct = switch (question.difficulty) {
    GameQuestionDifficulty.easy => 68,
    GameQuestionDifficulty.medium => 52,
    GameQuestionDifficulty.hard => 42,
  };
  final wrongValues = _splitWrongAudience(100 - correct);
  var wrongIndex = 0;
  return {
    for (final option in question.options)
      option: option == question.correctOption
          ? correct
          : wrongValues[wrongIndex++],
  };
}

/// Map percentiles → hàng dialog (label + "%" + progress 0..1) —
/// verbatim senior `buildGameAudiencePollItems`.
List<GameAudiencePollItemData> buildGameAudiencePollItems(
  List<GameAnswerOptionData> answers,
) {
  return answers
      .map((answer) {
        final value = answer.audiencePercentile ?? 0;
        return GameAudiencePollItemData(
          option: answer.answerLabel,
          percentage: '$value%',
          progress: value / 100,
        );
      })
      .toList(growable: false);
}

List<int> _splitWrongAudience(int remaining) {
  final first = (remaining * 0.5).round();
  final second = (remaining * 0.32).round();
  return [first, second, remaining - first - second];
}
```

Hai điểm đáng đọc kỹ:

- **50:50 deterministic, không `Random`** — senior chọn "ô sai
  *đầu tiên*" bằng `firstWhere`. Nghe phản trực giác ("50:50 phải
  ngẫu nhiên chứ") nhưng đó là implementation thật: dễ test, dễ
  review, và người chơi không phân biệt được vì ô nào bị xóa không
  quan trọng miễn là còn 1 đúng + 1 sai.
- **`_splitWrongAudience` không chia đều** — 50% và 32% của phần
  còn lại, ô cuối nhận *phần dư* nên tổng luôn 100 (easy: đúng 68,
  sai nhận 16/10/6). Map-comprehension `{for ... o: v}` dùng
  `wrongIndex++` — side-effect trong literal, hơi "bẩn" nhưng đó
  là code senior, ta giữ verbatim.

### Bước 5 — Test helper (bằng chứng thuần)

File mới `test/game_lifeline_helper_test.dart`:

```dart
import 'package:ai_millionaire_course/data/game/game_quiz_question_data.dart';
import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/view_models/game/support/game_lifeline_helper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test hàm thuần lifelines — M20. `applyGameFiftyFifty` deterministic
/// (đúng senior: giữ correct + sai-đầu, KHÔNG random);
/// `buildGameAudiencePoll` percentiles theo độ khó, tổng luôn 100.
void main() {
  GameQuizQuestionData q(GameQuestionDifficulty difficulty) {
    return GameQuizQuestionData(
      id: 1,
      question: 'Q?',
      options: const ['W1', 'CORRECT', 'W2', 'W3'],
      correctOption: 'CORRECT',
      category: 'T',
      language: 'vi',
      difficulty: difficulty,
      explanation: const GameQuestionExplanationData(
        explainForTrueAnswer: 't',
        explainForWrongAnswers: {},
        aiHintMessage: 'h',
      ),
    );
  }

  group('applyGameFiftyFifty', () {
    test('giữ đáp án đúng + ô sai ĐẦU, hai ô sai còn lại thành rỗng',
        () {
      // 'W1' là ô sai đầu tiên → giữ; 'W2'/'W3' xóa → ''.
      expect(
        applyGameFiftyFifty(q(GameQuestionDifficulty.easy)),
        ['W1', 'CORRECT', '', ''],
      );
    });

    test('không mutate bank gốc — options nguyên vẹn', () {
      final question = q(GameQuestionDifficulty.medium);
      applyGameFiftyFifty(question);
      expect(question.options, ['W1', 'CORRECT', 'W2', 'W3']);
    });
  });

  group('buildGameAudiencePoll', () {
    test('easy: đúng 68%; wrongs 50%/32%/dư của 32 → tổng 100', () {
      final poll = buildGameAudiencePoll(q(GameQuestionDifficulty.easy));
      expect(poll['CORRECT'], 68);
      expect(poll.values.fold<int>(0, (s, v) => s + v), 100);
      // 32 chia: round(16) + round(10.24→10) + (32-16-10=6).
      expect([poll['W1'], poll['W2'], poll['W3']], [16, 10, 6]);
    });

    test('medium 52% / hard 42%; tổng luôn 100', () {
      expect(
        buildGameAudiencePoll(q(GameQuestionDifficulty.medium))[
            'CORRECT'],
        52,
      );
      final hard = buildGameAudiencePoll(q(GameQuestionDifficulty.hard));
      expect(hard['CORRECT'], 42);
      expect(hard.values.fold<int>(0, (s, v) => s + v), 100);
    });
  });

  group('buildGameAudiencePollItems', () {
    test('map % sang item: label + "NN%" + progress 0..1; null → 0',
        () {
      const answers = [
        GameAnswerOptionData(
          answerLabel: 'A',
          answerText: 'x',
          audiencePercentile: 68,
        ),
        GameAnswerOptionData(answerLabel: 'B', answerText: 'y'),
      ];
      final items = buildGameAudiencePollItems(answers);
      expect(items[0].option, 'A');
      expect(items[0].percentage, '68%');
      expect(items[0].progress, closeTo(0.68, 0.001));
      expect(items[1].percentage, '0%');
      expect(items[1].progress, 0);
    });
  });
}
```

### Bước 6 — ARB + 12 key senior

`lib/l10n/app_vi.arb` — thêm vào block game (verbatim senior vi):

```json
  "fiftyFiftySemanticLabel": "50:50",
  "askAudienceSemanticLabel": "Hỏi khán giả",
  "askAiSemanticLabel": "Hỏi AI",
  "walkAwaySemanticLabel": "Dừng cuộc chơi",
  "exitGameSemanticLabel": "Thoát trò chơi",
  "walkAwayTitle": "Dừng cuộc chơi?",
  "walkAwayMessage": "Bạn sẽ mang về số tiền hiện tại và kết thúc trò chơi. Không thể hoàn tác.",
  "confirmWalkAwayButton": "Xác nhận dừng",
  "keepPlayingButton": "Chơi tiếp",
  "aiAssistantTitle": "Trợ lý AI",
  "audienceHelpTitle": "Hỏi khán giả",
  "aiThinkingMessage": "AI đang suy nghĩ...",
```

`lib/l10n/app_en.arb` — cùng 12 key, bản en verbatim senior
(`"Walk Away?"`, `"AI Assistant"`, `"AI is thinking..."`, …).
Rồi `flutter pub get` (hoặc `flutter gen-l10n`) để regenerate —
getter mới xuất hiện trên `AppLocalizations`.

### Bước 7 — Sealed test: **không đổi**

`test/sealed_state_test.dart` giữ nguyên — `GameDialogState` vẫn 6
variant (M19) vì bài này không thêm variant nào (caution ở Bước 1).
Switch kiệt hợp sẽ mở rộng ở Bài 3 (7 arm — thêm
`GameAudiencePollDialog`) rồi Bài 4 (9 arm — khớp senior 1:1), cùng
lúc với UI xử lý chúng.

## Hiểu code

- `GameAIAssistantDialog` (sẽ thêm ở Bài 4) là **một variant, hai
  hình**: `isLoading` true → UI render spinner; false → render kết
  quả. Senior chọn "đổi nội dung dialog" thay vì "đóng dialog
  loading rồi mở dialog kết quả" — Bài 4 sẽ thấy vì sao (route
  không cần mở lại).
- `audiencePercentile` nằm trên *DTO đáp án*, không phải state —
  mapper đổ `Map<String,int>` của state xuống từng ô theo text
  (Bài 3). Thiết kế này giữ dialog + ô đáp án đọc cùng một nguồn.
- `wrongIndex++` trong map-comprehension: index tăng ngay trong
  expression — lần lượt `wrongValues[0]`, `[1]`, `[2]` cho ba ô
  sai theo *thứ tự options*.

## Chạy và quan sát

```bash
flutter pub get        # regen l10n
flutter analyze        # phải sạch
flutter test           # 131/131 — +5 helper mới
flutter run            # game Y HỆT M19 — chưa có nút nào (đúng!)
```

Nếu game thay đổi gì sau bài này → bạn đã chạm phần behavior —
quay lại check diff.

## Thử nghiệm — đoán trước khi chạy

Tạm đổi hằng easy `68` thành `67` trong `buildGameAudiencePoll`
(file helper) rồi chạy `flutter test`. **Đoán:** test "easy:
đúng 68%…" có ba expect — `poll['CORRECT']==68`, tổng `fold==100`,
và `[W1,W2,W3]==[16,10,6]`. Bao nhiêu expect fail?
*(Đáp án: **hai** — `CORRECT` và `[16,10,6]` fail, nhưng tổng
`fold==100` vẫn **pass**: `_splitWrongAudience(33)` trả 17/11/5,
ô cuối nhận phần dư nên tổng luôn 100. Đây chính là điểm hay của
thiết kế "phần dư" — khóa invariant bằng test.)*

## Lỗi hay gặp

- **Quên `import 'game_screen_data.dart'`** trong file state →
  `GameFeatureButtonType` undefined. Analyzer báo ngay.
- **Cho `featureButtons` vào `GameScreenData` sớm** → mapper
  compile-error; đó là việc của Bài 3 (mục caution trên).
- **Dùng `Random().nextInt` cho 50:50** → sai senior. Đúng là
  `firstWhere` ô sai đầu tiên.
- **`Map.unmodifiable` quên bọc** → ai đó `.clear()` map state là
  đổi được state "bất biến" — boundary phải đóng băng.

## Tự làm — dự đoán output helper trước khi chạy

Cho câu hỏi:

```dart
const q = GameQuizQuestionData(
  /* … id/level/… */ question: 'Q',
  options: ['A1', 'A2', 'A3', 'A4'],
  correctOption: 'A3',
  difficulty: GameQuestionDifficulty.hard,
);
```

**Phần 1 — bằng tay.** Viết kết quả dự đoán của:

- `applyGameFiftyFifty(q)` — list 4 phần tử chính xác theo thứ tự.
- `buildGameAudiencePoll(q)` — Map 4 entry, tổng = 100.
- `buildGameAudiencePollItems` trên `answers` có `audiencePercentile`
  [68, 16, 10, 6] — field `percentage`/`progress` của từng hàng.

**Phần 2 — kiểm chứng.** Viết test tạm `expect` cả ba output —
`flutter test` phải xanh. Nếu đỏ: sai ở đâu — luật của bạn hay code?

<details><summary>Đáp án</summary>

- `applyGameFiftyFifty` → `['A1', '', 'A3', '']` — `firstWhere`
  lấy ô sai ĐẦU TIÊN theo thứ tự list (`'A1'`), giữ `'A1'` + `'A3'`,
  hai ô sai còn lại thành `''`. Bẫy hay gặp: tưởng "giữ đáp án đúng
  + một ô sai BẤT KỲ" — không, deterministic theo thứ tự options.
- `buildGameAudiencePoll` (hard) → đúng `42`; còn lại 58 chia
  29/19/10 → `{'A1': 29, 'A2': 19, 'A3': 42, 'A4': 10}` — tổng 100,
  ô cuối nhận phần dư.
- `buildGameAudiencePollItems` → hàng A3: `percentage '68%'`,
  `progress 0.68` — `%` là chuỗi đã format, `progress` là 0..1 cho
  thanh.

Điểm học: helper thuần = luật có thể *đọc như bảng* — ai đọc được
bảng luật sẽ đọc được code, và test chỉ là bảng đó dưới dạng `expect`.

</details>

## Kiểm tra hiểu biết

1. `audiencePercentiles` kiểu `Map<String,int>?` — tại sao key là
   *text* đáp án chứ không phải index?
   *(Poll gắn % vào nội dung; ô bị 50:50 xóa tự rớt khỏi map → 0%.)*
2. `resolvedResult` tồn tại để làm gì nếu `phase` đã có
   `victory`/`gameOver`?
   *(Walk-away cũng vào `victory` nhưng `won=false` — phase một
   mình không suy ra được kết quả.)*
3. Test `không mutate bank gốc` chứng minh điều gì về
   `applyGameFiftyFifty`? *(Nó trả List mới, không sửa
   `question.options` — quan trọng vì bank là shared const.)*

## Ta cố ý chưa thêm

- Ba sealed dialog variant (`GameAudiencePollDialog` /
  `GameConfirmWalkAwayDialog` / `GameAIAssistantDialog`) — **Bài 3**
  (poll) và **Bài 4** (walk-away + AI), kèm các arm UI của chúng.
- `featureButtons` field trên `GameScreenData` + mapper feature —
  **Bài 3** (cùng bước mapper dùng nó).
- `handleFeatureClick`/`_canUseFeature`/mọi method VM — **Bài 3–4**.
- Widget thanh lifeline + dialog UI — **Bài 3–4**.
- `GameShareResultEvent` (share kết quả) — chưa assign milestone
.

## Checkpoint hoàn thành

- [ ] `flutter analyze` sạch sau 7 bước.
- [ ] `flutter test` = **131/131** (126 cũ + 5 helper).
- [ ] `flutter run` — màn chơi không đổi gì (không nút mới).
- [ ] `test/sealed_state_test.dart` *không đổi* — `GameDialogState`
  vẫn 6 variant (variant mới đi kèm UI ở Bài 3/4).

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m20/02 — "Nền data lifeline: state, dialog, helper thuần" (4 field state + enum/DTO nút + 3 helper thuần + 12 key ARB — KHÔNG đổi hành vi runtime; sealed variant + UI đến bài 3/4).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, chạy `flutter gen-l10n` để "sửa" output, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bài này ADDITIVE-ONLY: không variant sealed mới (chúng cần arm UI — đến bài 3/4), không `featureButtons` trên `GameScreenData` (đổi signature — bài 3), không method VM mới. Runtime y hệt M19 là ĐÚNG.

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/game/game_session_state_data.dart`: `final class GameAudiencePollItemData{option, percentage(String 'NN%'), progress(double 0..1)}` mới; `GameSessionState` thêm 4 field (STRICT): `List<String> visibleOptionTexts` (ctor gói `List.unmodifiable`), `Map<String,int>? audiencePercentiles` (gói `Map.unmodifiable` khi non-null — key = TEXT đáp án), `Set<GameFeatureButtonType> usedFeatureButtons` (gói `Set.unmodifiable`), `GameResult? resolvedResult`; `initial()` seed `visibleOptionTexts: const [], audiencePercentiles: null, usedFeatureButtons: const {}`; `copyWith` thêm 3 param + 2 cờ mới `clearAudiencePercentiles`, `clearResolvedResult` (tổng 3 cờ clear); `import 'game_screen_data.dart'` cho `GameFeatureButtonType`.
- `lib/data/game/game_screen_data.dart`: `enum GameFeatureButtonType {fiftyFifty, audiencePoll, aiAssistant, walkAway, exitGame}` (STRICT 5 giá trị); `class GameFeatureButtonData{GameFeatureButtonType type, IconData icon, String semanticLabel, bool isEnabled = true}` + `copyWith({bool? isEnabled})` (STRICT `IconData` — KHÔNG `String iconAsset`, learner chưa có SVG pipeline M28); `GameAnswerOptionData` thêm `final int? audiencePercentile` + `copyWith({answerText, state, audiencePercentile, clearAudiencePercentile})` (STRICT flag pattern); `GameScreenData` CHƯA có `featureButtons` (STRICT — có sớm = AHEAD vì phá signature trước mapper).
- `lib/view_models/game/support/game_lifeline_helper.dart` (STRICT verbatim): `List<String> applyGameFiftyFifty(question)` — DETERMINISTIC giữ `correctOption` + ô sai ĐẦU `firstWhere`, còn lại `''` (KHÔNG Random); `Map<String,int> buildGameAudiencePoll(question)` — đúng 68/52/42 theo easy/medium/hard, `_splitWrongAudience` 50%/32%/phần-dư tổng=100, map-comprehension keyed bằng text; `List<GameAudiencePollItemData> buildGameAudiencePollItems(answers)` — `audiencePercentile ?? 0` → `'$value%'` + `value/100`.
- `test/game_lifeline_helper_test.dart` (STRICT ~5 test): fifty-fifty giữ đúng+sai-đầu → `['W1','CORRECT','','']`; không mutate bank; poll easy 68 + wrongs [16,10,6] + tổng 100; medium 52/hard 42; items label+'NN%'+progress+null→0.
- ARB: 12 key mới cả 2 file (STRICT): `fiftyFiftySemanticLabel, askAudienceSemanticLabel, askAiSemanticLabel, walkAwaySemanticLabel, exitGameSemanticLabel, walkAwayTitle, walkAwayMessage, confirmWalkAwayButton, keepPlayingButton, aiAssistantTitle, audienceHelpTitle, aiThinkingMessage`; `AppLocalizations` regenerated có getter.
- `test/sealed_state_test.dart` KHÔNG đổi — `GameDialogState` vẫn 6 variant (STRICT — variant poll/AI/walk-away chưa thêm).
- `flutter analyze` sạch; `flutter test` → **131/131** (STRICT 126 + 5 helper).
- KHÔNG có `handleFeatureClick`/`_canUseFeature`/`_useFiftyFifty`/`_showAudiencePoll` trong VM (bài 3); KHÔNG `GameAudiencePollDialog`/`GameConfirmWalkAwayDialog`/`GameAIAssistantDialog` variant (bài 3/4 — có sớm = compile đỏ vì switch kiệt hợp thiếu arm → DIVERGED); KHÔNG lifeline bar trong `game_screen.dart` (bài 3); KHÔNG `resolvedResult` set ở đâu ngoài field (bài 4 mới dùng).

INVARIANTS NỀN:
- GameSessionState+phase+dialog-6+event+copyWith/clearSelectedAnswer (M19); VM + timer + flowToken + `buildGameResult` switch (M19); mapper + `GameAnswerOptionData` cũ (M19); menu/settings/onboarding/l10n M14–M18; `fake_async` dev-dep (M19).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m20/02
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
