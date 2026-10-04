---
title: "Bài 3 · 50:50 và Hỏi khán giả: từ state tới thanh nút"
description: "Nối lifeline đầu tiên xuyên stack: mapper đọc visibleOptionTexts/audiencePercentiles + sản xuất featureButtons; VM guard + mutation; widget bar + poll dialog + ô trống. Checkpoint: 141/141."
sidebar:
  label: "Bài 3 · 50:50 + poll"
  order: 3
---

## Mục tiêu

- Nối `visibleOptionTexts` + `audiencePercentiles` +
  `usedFeatureButtons` từ `GameSessionState` (Bài 2) qua mapper tới
  UI — 50:50 và Hỏi khán giả hoạt động đầu đủ, dùng một lần.
- Hiểu chuỗi 3 lớp phòng thủ cho ô bị 50:50 xóa: mapper render
  `idle`, widget `onTap: null`, VM chặn `answerText.isEmpty`.
- Render thanh lifeline data-driven: `data.featureButtons` → nút,
  không if/else hardcode trong widget.

## Bạn đang ở đâu

- Sau Bài 2: 131/131 — state có chỗ chứa lifeline, helper thuần đã
  test, ARB có key — nhưng **runtime chưa đổi**: không nút nào
  trên màn, không method VM nào.
- Bài này bật hai lifeline đầu tiên. AI + walk-away chờ Bài 4
  (lý do: chúng đụng `Future.delayed` và `resolvedResult` — một
  phần async riêng, một phần kết-quả riêng).

## Vì sao việc này quan trọng ngay bây giờ

Đây là bài "đổ mạch" lớn của M20: ba file chạm nhau ở một contract
— mapper cần `featureButtons` field (Bài 2 cố ý chưa thêm), VM
cần mapper đọc `visibleOptionTexts`, màn cần `data.featureButtons`
để render bar. Sai thứ tự = analyze đỏ.

Điểm tinh tế nhất: **ô bị 50:50 xóa không biến mất khỏi lưới** —
nó render `''`, trạng thái `idle`, không tap được. Senior giữ ô
trống *nhìn thấy* vì vị trí đáp án A–D phải ổn định trong mắt
người chơi; "biến mất" sẽ làm UI nhảy.

## Bạn đã biết gì

- Mapper thuần `buildGameScreenPresentation` + `GameScreenData`
  DTO (M19); `_answerState` = f(phase) (M19).
- Guard `phase != playing → return` (M19); `_schedule` +
  `flowToken` (M19 — dùng ở Bài 4).
- `Set` dùng-một-lần + `{...old, x}` (Bài 1); helper thuần
  `applyGameFiftyFifty`/`buildGameAudiencePoll` (Bài 2).
- Dialog qua `dialogState` + `GameDialogRequested` + generic
  dismiss resume timer (M19).

## Dart/Flutter cần dùng — xuất hiện đầu tiên

| Cú pháp | Ví dụ | Nghĩa |
|---|---|---|
| `List.generate(n, (i) => …)` | labels A–D theo index | build list độ dài cố định từ index |
| `String.fromCharCode(65+i)` | `65+0` → `'A'` | ký tự từ code unit (65='A') |
| `LinearProgressIndicator(value:)` | `value: item.progress` | thanh % native, 0..1 |
| `AnimatedOpacity` | dim nút đã dùng | fade animation khai báo, không controller |
| `Semantics(button:, enabled:, label:)` | bọc nút custom | a11y label cho screen reader |
| `IconData` trong DTO | `data.icon` → `Icon(data.icon)` | icon là *data*, widget chỉ render |

:::note[Visual depth dời M28]
Senior `GameFeatureButton` là ~200 dòng `CustomPainter` (glow,
border vẽ tay) + icon SVG asset. Learner dùng `IconData` phẳng +
`AnimatedOpacity` — **hợp đồng hành vi giữ nguyên** (`isEnabled`
→ mờ + `onTap:null`), chỉ độ sâu visual được dời tới M28 — đơn giản hoá
có chủ đích, không phải "thiếu sót ngầm".
:::

## Android / Compose bridge

- **SIMILARITY:** `LinearProgressIndicator(value:)` ↔ Compose
  `LinearProgressIndicator(progress = { … })`; `AnimatedOpacity` ↔
  `animateFloatAsState` + `Modifier.alpha`; `Semantics(label:)` ↔
  `Modifier.semantics { contentDescription = … }`.
- **IMPORTANT DIFFERENCE:** `String.fromCharCode(65 + i)` sinh ký
  tự từ code unit — Compose không có pattern nhãn-A-D bằng char
  code phổ biến; đây là chữ ký riêng của senior.
- **DO NOT ASSUME:** icon-as-data (`IconData` trong DTO) không giống
  `@DrawableRes Int` — `Icons.percent` là *const object*, không
  phải resource id resolve lúc runtime.

## Senior project connection

- `view_models/game/game_screen_presentation_mapper.dart` (senior)
  — `_buildAnswers`/`_buildFeatureButtons`/`_answerState` nguyên
  bản; bài này port verbatim.
- `widgets/game/game_feature_button.dart` + `game_feature_button_bar.dart`
  (senior) — nút ~200 dòng `CustomPainter`; ta giữ hợp đồng, đơn
  giản visual.
- `view_models/game/reducer/game_reducer_feature_flow.dart` (senior)
  — `_useFiftyFifty`/`_showAudiencePoll`/`_audiencePollItems` là
  reducer handlers; learner giữ tên + ngữ nghĩa trong VM.

## Build it step by step

:::note[Giai đoạn A — data + mapper]
Bài này dài vì một lifeline chạm **ba lớp**. Ta chia thành ba giai
đoạn, mỗi giai đoạn kết thúc bằng một thứ *kiểm chứng được*:

- **A (Bước 1–2):** data mới + mapper — xong khi `analyze` chỉ còn
  lỗi "chưa truyền tham số" ở lớp trên (lỗi *có chủ đích*).
- **B (Bước 3–4):** VM — seed poll, guard `phase`, single-use.
- **C (Bước 5–6):** UI thanh lifeline + dialog poll + test.

Đừng đọc lướt A→C một mạch — sau mỗi giai đoạn, dừng và xác minh
bằng analyze/test trước khi tiếp.
:::

### Bước 1 — `GameScreenData.featureButtons` + variant poll

`lib/data/game/game_screen_data.dart` — giờ mới thêm (Bài 2 cố ý
giữ lại):

```dart
  const GameScreenData({
    required this.money,
    required this.question,
    required this.answers,
    required this.featureButtons,   // M20 — thanh lifeline
    required this.timer,
  });
```

`lib/data/game/game_session_state_data.dart` — thêm variant poll
(Bài 2 cố ý chưa thêm vì sealed → cần arm UI đi kèm; đến đúng lúc):

```dart
/// Dialog "hỏi khán giả" — M20. Senior `GameAudiencePollDialog`:
/// danh sách hàng đã format sẵn (option + % + progress).
final class GameAudiencePollDialog extends GameDialogState {
  const GameAudiencePollDialog({required this.items});

  /// Các hàng poll — một hàng mỗi đáp án.
  final List<GameAudiencePollItemData> items;
}
```

**Biên dịch sẽ đỏ ngay, ở hai chỗ** — mapper chưa truyền
`featureButtons`, và ba `switch` kiệt hợp (`_title`/`_content`/
`_actions`) thiếu arm `GameAudiencePollDialog`. Cả hai đều được
sửa trong bài này (Bước 2 + Bước 5) — đây là "variant + UI arm đi
chung" của sealed trong thực tế.

### Bước 2 — Mapper: 4 param mới + `_buildAnswers` viết lại +
`_buildFeatureButtons`

`lib/view_models/game/game_screen_presentation_mapper.dart` —
signature `buildGameScreenPresentation` thêm 4 named-required:

```dart
  required String? selectedAnswer,
  required List<String> visibleOptionTexts,
  required Map<String, int>? audiencePercentiles,
  required Set<GameFeatureButtonType> usedFeatureButtons,
  required bool canWalkAway,
}) {
```

thân hàm thêm `featureButtons:` và đổi `_buildAnswers` call:

```dart
    answers: _buildAnswers(
      question: question,
      phase: phase,
      selectedAnswer: selectedAnswer,
      visibleOptionTexts: visibleOptionTexts,
      audiencePercentiles: audiencePercentiles,
    ),
    featureButtons: _buildFeatureButtons(
      phase: phase,
      usedFeatureButtons: usedFeatureButtons,
      canWalkAway: canWalkAway,
    ),
    timer: GameTimerData(totalTime: totalTime, remainingTime: remainingTime),
```

`_buildAnswers` — **verbatim senior**: text lấy từ
`visibleOptionTexts` (không còn `question.options` trực tiếp),
nhãn A–D sinh bằng `String.fromCharCode(65 + index)`, % khán giả
tra `audiencePercentiles?[optionText]`:

```dart
/// Verbatim senior `_buildAnswers`: text ô lấy từ `visibleOptionTexts`
/// (50:50 đã thay ô bị xóa bằng `''`), % khán giả tra theo text.
List<GameAnswerOptionData> _buildAnswers({
  required GameQuizQuestionData question,
  required GamePhase phase,
  required String? selectedAnswer,
  required List<String> visibleOptionTexts,
  required Map<String, int>? audiencePercentiles,
}) {
  return List.generate(question.options.length, (index) {
    final optionText = visibleOptionTexts[index];
    return GameAnswerOptionData(
      answerLabel: String.fromCharCode(65 + index),
      answerText: optionText,
      state: _answerState(
        optionText: optionText,
        correctAnswer: question.correctOption,
        phase: phase,
        selectedAnswer: selectedAnswer,
      ),
      audiencePercentile: audiencePercentiles?[optionText],
    );
  });
}
```

`_answerState` thêm **lớp phòng thủ 1** — ô rỗng luôn idle,
check đầu tiên:

```dart
GameAnswerState _answerState({...}) {
  if (optionText.isEmpty) return GameAnswerState.idle;
  // … các arm cũ giữ nguyên …
}
```

`_buildFeatureButtons` + `_feature` — verbatim senior. **Ở bài
này list chỉ có 2 nút** (`fiftyFifty`, `audiencePoll`); AI +
walk-away vào list ở Bài 4 (`canWalkAway` param đã sẵn sàng):

```dart
/// Verbatim senior `_buildFeatureButtons`: nút luôn có + `walkAway`
/// chỉ thêm khi `canWalkAway` (guaranteedAmount > 0 — senior tính ở
/// VM), `exitGame` KHÔNG nằm trong thanh (nút ✕ top bar gọi
/// `showConfirmExit` riêng). `isEnabled = canPlay && !used`.
List<GameFeatureButtonData> _buildFeatureButtons({
  required GamePhase phase,
  required Set<GameFeatureButtonType> usedFeatureButtons,
  required bool canWalkAway,
}) {
  final canPlay = phase == GamePhase.playing;
  final buttons = [
    _feature(
      GameFeatureButtonType.fiftyFifty,
      Icons.percent,
      '50:50',
      canPlay,
      usedFeatureButtons,
    ),
    _feature(
      GameFeatureButtonType.audiencePoll,
      Icons.people,
      'Ask the Audience',
      canPlay,
      usedFeatureButtons,
    ),
    // Bài 4 nối: aiAssistant (luôn có) + walkAway (khi canWalkAway).
  ];
  return buttons;
}

/// FR-34: `icon` là `IconData` thay `String iconAsset` của senior
/// (learner chưa có pipeline SVG) — hội tụ M28.
GameFeatureButtonData _feature(
  GameFeatureButtonType type,
  IconData icon,
  String label,
  bool canPlay,
  Set<GameFeatureButtonType> usedFeatureButtons,
) {
  return GameFeatureButtonData(
    type: type,
    icon: icon,
    semanticLabel: label,
    isEnabled: canPlay && !usedFeatureButtons.contains(type),
  );
}
```

File cần `import 'package:flutter/material.dart'` (IconData/Icons)
nếu chưa có.

:::note[Giai đoạn B — hành vi của VM]
Bạn đã biết: sealed state (M15), guard `phase` (M19/04), `copyWith`
cờ `clear*` (M19/02), Set dùng-một-lần (Bài 1). **Mới trong giai
đoạn này:** seeding `audiencePercentile` vào state khi bấm lifeline
và quy tắc "mỗi nút dùng một lần". Kiểm chứng cuối giai đoạn: VM
compile sạch, test VM cũ vẫn xanh (chưa có test mới — đến Bước 6).
:::

### Bước 3 — VM: truyền 4 arg, seed, reset, guard submit

`lib/view_models/game/game_screen_view_model.dart`:

**(a)** Getter `screenData` — truyền đủ:

```dart
  GameScreenData get screenData => buildGameScreenPresentation(
    // ... các arg cũ giữ nguyên ...
    visibleOptionTexts: _state.visibleOptionTexts,
    audiencePercentiles: _state.audiencePercentiles,
    usedFeatureButtons: _state.usedFeatureButtons,
    // Senior: `canWalkAway: state.guaranteedAmount > 0` — nút
    // walk-away chỉ HIỆN khi đã qua safe haven đầu; guard dùng lần
    // (`_canUseFeature`) kiểm riêng `_walkAwayAmount > 0`.
    canWalkAway: _state.guaranteedAmount > 0,
  );
```

**(b)** `startNewGame` — seed text hiển thị (50:50 sẽ ghi đè bản
copy này, bank gốc nguyên):

```dart
    _emit(
      GameSessionState.initial(timePerQuestion: timePerQuestion)
          .copyWith(
        flowToken: _state.flowToken + 1,
        // M20: seed text hiển thị = options câu đầu (50:50 sẽ thay 2 ô
        // bằng `''` trên bản copy này, không đụng bank gốc).
        visibleOptionTexts: questions.first.options,
        dialogState: GameMoneyLadderDialog(/* ... giữ nguyên ... */),
      ),
    );
```

**(c)** `_loadNextQuestionOrVictory` — reset theo câu (senior:
`visibleOptionTexts` về options câu mới, `audiencePercentiles` về
`null`; `usedFeatureButtons` **không** reset — dùng-một-lần tính
cả ván):

```dart
    _emit(
      _state.copyWith(
        phase: GamePhase.playing,
        questionIndex: _state.questionIndex + 1,
        remainingTime: timePerQuestion,
        dialogState: const GameDialogHidden(),
        clearSelectedAnswer: true,
        visibleOptionTexts: questions[_state.questionIndex + 1].options,
        clearAudiencePercentiles: true,
      ),
    );
```

**(d)** `submitAnswer` — **không sửa gì, chỉ đọc lại**. Guard
`answerText.isEmpty` đã có sẵn từ M19 (port verbatim senior
`_submitAnswer` — lúc đó chưa có ô trống nên guard "chưa bao giờ
bắn"); M20 lần đầu tạo ra ô `''` nên guard này trở thành *lớp
phòng thủ 3* hoạt động thật. Mở method kiểm tra dòng đầu:

```dart
  void submitAnswer(GameAnswerOptionData answer) {
    if (_state.phase != GamePhase.playing || answer.answerText.isEmpty) {
      return;
    }
    // ...
  }
```

### Bước 4 — VM: `handleFeatureClick` + `_canUseFeature` + hai method

Thêm block lifelines vào VM (import helper ở đầu file):
`import 'support/game_lifeline_helper.dart';`

```dart
  /// Bấm một nút lifeline — senior `handleFeatureClick`: guard
  /// `isEnabled` của button data trước, rồi `_canUseFeature` kiểm lại
  /// theo state (belt-and-suspenders đúng senior).
  void handleFeatureClick(GameFeatureButtonData button) {
    if (!button.isEnabled) return;
    if (!_canUseFeature(button.type)) return;

    switch (button.type) {
      case GameFeatureButtonType.fiftyFifty:
        _useFiftyFifty();
      case GameFeatureButtonType.audiencePoll:
        _showAudiencePoll();
      case GameFeatureButtonType.aiAssistant:
        break; // Bài 4: _showAIAssistant.
      case GameFeatureButtonType.walkAway:
        break; // Bài 4: _showConfirmWalkAway.
      case GameFeatureButtonType.exitGame:
        showConfirmExit();
    }
  }

  /// Senior `_canUseFeature`: phase phải `playing`; walk-away yêu cầu
  /// có tiền mang về (`_walkAwayAmount > 0`); exit luôn được; các nút
  /// còn lại bị chặn khi đã nằm trong `usedFeatureButtons`.
  bool _canUseFeature(GameFeatureButtonType type) {
    if (_state.phase != GamePhase.playing) return false;
    if (type == GameFeatureButtonType.walkAway) {
      return _walkAwayAmount(_state) > 0;
    }
    if (type == GameFeatureButtonType.exitGame) return true;
    return !_state.usedFeatureButtons.contains(type);
  }

  /// 50:50 — senior `_useFiftyFifty`: `visibleOptionTexts` thay bằng
  /// bản đã xóa 2 ô sai; đánh dấu đã dùng. Không pause timer (không
  /// mở dialog).
  void _useFiftyFifty() {
    _emit(
      _state.copyWith(
        visibleOptionTexts: applyGameFiftyFifty(
          questions[_state.questionIndex],
        ),
        usedFeatureButtons: {
          ..._state.usedFeatureButtons,
          GameFeatureButtonType.fiftyFifty,
        },
      ),
    );
  }

  /// Hỏi khán giả — senior `_showAudiencePoll`: tính percentiles theo
  /// độ khó, đánh dấu đã dùng, mở dialog với items đã build từ
  /// `visibleOptionTexts` (ô đã xóa → 0%), pause timer.
  void _showAudiencePoll() {
    final percentiles = buildGameAudiencePoll(
      questions[_state.questionIndex],
    );
    _stopTimer();
    _emit(
      _state.copyWith(
        audiencePercentiles: percentiles,
        usedFeatureButtons: {
          ..._state.usedFeatureButtons,
          GameFeatureButtonType.audiencePoll,
        },
        dialogState: GameAudiencePollDialog(
          items: _audiencePollItems(_state, percentiles),
        ),
      ),
    );
    _emitEvent(const GameDialogRequested());
  }

  /// Senior `_audiencePollItems`: build hàng poll từ
  /// `visibleOptionTexts` — ô bị 50:50 xóa (`''`) → 0%.
  List<GameAudiencePollItemData> _audiencePollItems(
    GameSessionState state,
    Map<String, int> percentiles,
  ) {
    return List.generate(state.visibleOptionTexts.length, (index) {
      final option = state.visibleOptionTexts[index];
      final value = option.isEmpty ? 0 : percentiles[option] ?? 0;
      return GameAudiencePollItemData(
        option: String.fromCharCode(65 + index),
        percentage: '$value%',
        progress: value / 100,
      );
    }, growable: false);
  }
```

**Hiểu hai chi tiết quan trọng:**

- `handleFeatureClick` kiểm **hai** lần: `button.isEnabled` (mapper
  đã suy) rồi `_canUseFeature` (state thật). Nút bấm tay —
  `GameFeatureButtonData(isEnabled: true)` — vẫn bị `_canUseFeature`
  chặn nếu state không cho phép. Đây là "belt and suspenders" cố
  ý của senior.
- `_useFiftyFifty` **không** `_stopTimer()` — không mở dialog nên
  đồng hồ chạy tiếp (bạn đang chơi chứ không đang đọc). Poll/AI
  có dialog → pause. Nhỏ nhưng đúng senior.

:::note[Giai đoạn C — UI nhìn state]
Mọi quyết định đã xong ở A+B. Giai đoạn này chỉ là render: thanh
lifeline đọc `usedFeatureButtons`, ô đáp án đọc `''` của 50:50,
dialog poll đọc variant mới. **Không concept mới** — chỉ là sealed
UI arm + widget hiện có. Kiểm chứng: chạy app, bấm 50:50 thấy hai ô
trống, mở poll thấy 4 thanh %.
:::

### Bước 5 — Màn: thanh lifeline + ô trống + dialog poll

`lib/screens/game_screen.dart`:

**(a)** Dưới lưới đáp án (trong `Column` body, trước `SizedBox`
đáy), render bar từ data:

```dart
                      // M20 — thanh lifeline (senior `GameFeatureButtonBar`
                      // dưới body): render data-driven từ mapper.
                      _GameFeatureBar(
                        buttons: data.featureButtons,
                        l10n: l10n,
                        onPressed: viewModel.handleFeatureClick,
                      ),
```

**(b)** **Lớp phòng thủ 2** — `_AnswerOption.build`: ô trống vẫn
render slot nhưng `onTap: null`:

```dart
    return GestureDetector(
      // M20 (senior `GameAnswerOption`): ô bị 50:50 xóa (`answerText`
      // rỗng) vẫn render slot nhưng không tap được — VM cũng chặn
      // submit text rỗng ở tầng dưới.
      onTap: option.answerText.isEmpty ? null : onTap,
      child: /* ... giữ nguyên ... */,
    );
```

**(c)** Hai widget mới cuối file — `_GameFeatureBar` +
`_GameFeatureButton` (bản phẳng — visual depth đến M28):

```dart
/// Thanh lifeline — senior `GameFeatureButtonBar` (FR-34: flat
/// IconData thay painter/SVG — M28 hội tụ visual). Render từ
/// `data.featureButtons`; widget không giữ trạng thái "đã dùng" —
/// `isEnabled` đã được mapper suy ra, tap forward `handleFeatureClick`.
class _GameFeatureBar extends StatelessWidget {
  final List<GameFeatureButtonData> buttons;
  final AppLocalizations l10n;
  final void Function(GameFeatureButtonData) onPressed;

  const _GameFeatureBar({
    required this.buttons,
    required this.l10n,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final button in buttons) ...[
          _GameFeatureButton(
            data: button,
            semanticLabel: _labelFor(button.type),
            onPressed: () => onPressed(button),
          ),
          if (button != buttons.last)
            const SizedBox(width: MenuTokens.spacingSm),
        ],
      ],
    );
  }

  String _labelFor(GameFeatureButtonType type) => switch (type) {
    GameFeatureButtonType.fiftyFifty => l10n.fiftyFiftySemanticLabel,
    GameFeatureButtonType.audiencePoll =>
      l10n.askAudienceSemanticLabel,
    GameFeatureButtonType.aiAssistant => l10n.askAiSemanticLabel,
    GameFeatureButtonType.walkAway => l10n.walkAwaySemanticLabel,
    GameFeatureButtonType.exitGame => l10n.exitGameSemanticLabel,
  };
}

/// Một nút lifeline — FR-34: visual đơn giản hóa (icon Material +
/// AnimatedOpacity) thay painter gradient/ripple + SVG của senior
/// (→ M28). Giữ đúng hợp đồng hành vi: `isEnabled` → opacity 0.38 +
/// onTap null; tap forward `handleFeatureClick`.
class _GameFeatureButton extends StatelessWidget {
  final GameFeatureButtonData data;
  final String semanticLabel;
  final VoidCallback onPressed;

  const _GameFeatureButton({
    required this.data,
    required this.semanticLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: data.isEnabled,
      label: semanticLabel,
      child: GestureDetector(
        onTap: data.isEnabled ? onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: data.isEnabled ? 1 : 0.38,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MenuTokens.cardBackground,
              border: Border.all(
                color: data.isEnabled
                    ? MenuTokens.accentCyan
                    : MenuTokens.cardBorder,
                width: 1.5,
              ),
            ),
            child: Icon(
              data.icon,
              size: 22,
              color: data.isEnabled
                  ? MenuTokens.accentCyan
                  : MenuTokens.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
```

Chi tiết đáng nhớ: `semanticLabel` *data* trong
`GameFeatureButtonData` là label tiếng Anh senior (fallback —
verbatim mapper), còn nhãn a11y thực sự render qua `_labelFor` →
`l10n.*SemanticLabel`. Senior cũng tách hai lớp này
(`game_feature_button.dart` map type → l10n riêng).

**(d)** `_content` arm cho poll — `GameAudiencePollDialog` render
mỗi item = label + `LinearProgressIndicator` + `%`:

```dart
    // M20 — poll khán giả: mỗi hàng = nhãn + progress + % (senior
    // `AudiencePollRow` dùng `LinearProgressIndicator` — giữ nguyên).
    GameAudiencePollDialog(:final items) => SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(item.option,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: MenuTokens.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: MenuTokens.spacingSm),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: item.progress,
                      color: MenuTokens.accentCyan,
                      backgroundColor: MenuTokens.cardBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: MenuTokens.spacingSm),
                  Text(item.percentage,
                      style: const TextStyle(
                          color: MenuTokens.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    ),
```

`_title` arm — `GameAudiencePollDialog() => l10n.audienceHelpTitle`.

và `_actions` arm — **bắt buộc** (switch kiệt hợp thiếu arm → lỗi
biên dịch; đồng thời đây là nút `ĐÃ HIỂU` đóng dialog):

```dart
      GameAudiencePollDialog() => [
        _DialogTextButton(
          label: l10n.understandButton,
          onTap: () => close(),
        ),
      ],
```

Đừng nhầm hai tầng "không cần code": ở tầng **VM** thì
`dismissDialog` là generic — `close()` rỗng → `dismiss` → ẩn dialog
+ resume timer, không cần method mới. Nhưng ở tầng **UI** thì
`_actions` phải có arm riêng vì switch kiệt hợp sealed. Back hệ
thống đi qua `_handleRouteBack` có sẵn (generic arm → dismiss).

### Bước 6 — Test sealed + mapper + VM + widget

**Sealed** (`test/sealed_state_test.dart`) — `GameDialogState` giờ
có 7 variant → switch kiệt hợp trong test báo lỗi ngay. Thêm arm
`GameAudiencePollDialog() => 'audience-poll'` vào `label()` + dòng
expect tương ứng:

```dart
      expect(
        label(const GameAudiencePollDialog(items: [])),
        'audience-poll',
      );
```

Đây là lý do variant phải đi kèm code xử lý: compiler không cho
quên. (Bài 4 thêm nốt 2 arm walk-away + AI → đủ 9 của senior.)

**Mapper** (`test/game_screen_presentation_mapper_test.dart`) —
local builder `build({...})` thêm 4 param + truyền tiếp:

```dart
  GameScreenData build({
    GamePhase phase = GamePhase.playing,
    String? selectedAnswer,
    int moneyEarned = 0,
    Duration remaining = const Duration(seconds: 30),
    List<String>? visibleOptionTexts,
    Map<String, int>? audiencePercentiles,
    Set<GameFeatureButtonType> usedFeatureButtons = const {},
    bool canWalkAway = false,
  }) {
    return buildGameScreenPresentation(
      // ... arg cũ giữ nguyên ...
      // M20: text hiển thị mặc định = options gốc (chưa 50:50).
      visibleOptionTexts: visibleOptionTexts ?? question.options,
      audiencePercentiles: audiencePercentiles,
      usedFeatureButtons: usedFeatureButtons,
      canWalkAway: canWalkAway,
    );
  }
```

và +2 test:

```dart
  test('50:50: text rỗng → ô render idle + audiencePercentile tra '
      'theo text', () {
    final data = build(
      // Sau 50:50: 'B' (đúng) + 'A' (sai đầu) giữ; 'C'/'D' bị xóa.
      visibleOptionTexts: const ['A', 'B', '', ''],
      audiencePercentiles: const {'A': 16, 'B': 52},
    );
    expect(data.answers.map((a) => a.answerText), ['A', 'B', '', '']);
    expect(data.answers[2].state, GameAnswerState.idle);
    expect(data.answers[0].audiencePercentile, 16);
    expect(data.answers[1].audiencePercentile, 52);
    expect(data.answers[2].audiencePercentile, isNull);
  });

  // L03-stage: bar có 2 nút; Bài 4 thêm aiAssistant + walkAway
  // (production cuối assert 4 + walkAway gating).
  test('featureButtons: 2 nút khi playing, used → isEnabled=false',
      () {
    final data = build(
      usedFeatureButtons: const {GameFeatureButtonType.fiftyFifty},
    );
    expect(
      data.featureButtons.map((b) => b.type),
      [
        GameFeatureButtonType.fiftyFifty,
        GameFeatureButtonType.audiencePoll,
      ],
    );
    expect(data.featureButtons[0].isEnabled, isFalse); // đã dùng
    expect(data.featureButtons[1].isEnabled, isTrue);
  });
```

**VM** (`test/game_screen_view_model_test.dart`) — +6 test trong
ba group. Mẫu đầy đủ của test 50:50 (FakeAsync của M19/04):

```dart
  /// Tìm button data theo type trong `screenData.featureButtons`.
  GameFeatureButtonData feature(
    GameScreenViewModel vm,
    GameFeatureButtonType type,
  ) => vm.screenData.featureButtons.firstWhere((b) => b.type == type);

  test('xóa 2 ô sai (giữ đúng + sai-đầu), single-use, ô trống '
      'không submit được', () {
    FakeAsync().run((async) {
      final vm = startedVm(async, 6);
      addTearDown(vm.dispose);

      vm.handleFeatureClick(feature(vm, GameFeatureButtonType.fiftyFifty));

      expect(vm.state.visibleOptionTexts, ['A0', 'W0_1', '', '']);
      expect(
        vm.state.usedFeatureButtons,
        contains(GameFeatureButtonType.fiftyFifty),
      );
      // Button giờ disabled trong screenData.
      expect(
        feature(vm, GameFeatureButtonType.fiftyFifty).isEnabled,
        isFalse,
      );
      // Bấm lại → no-op.
      vm.handleFeatureClick(feature(vm, GameFeatureButtonType.fiftyFifty));
      expect(vm.state.visibleOptionTexts, ['A0', 'W0_1', '', '']);

      // Ô rỗng không submit được (guard `answerText.isEmpty` — đúng
      // senior `_submitAnswer`).
      vm.submitAnswer(
        const GameAnswerOptionData(answerLabel: 'C', answerText: ''),
      );
      expect(vm.state.phase, GamePhase.playing);
    });
  });
```

Năm test còn lại — `lifelines — khả dụng + single-use` (2),
`50:50 sang câu reset`, `hỏi khán giả` (2). Xuyên suốt chúng
assert:

- `screenData.featureButtons` có 2 nút khi `playing`; button
  disabled → `handleFeatureClick` no-op; non-playing → mọi feature
  bị chặn (kể cả exitGame — phase gate trước).
- `_useFiftyFifty` → `visibleOptionTexts == ['A0','W0_1','','']`,
  `usedFeatureButtons` chứa type, ô `''` không submit được;
  sang câu → texts reset nhưng used-set giữ.
- Poll → `GameAudiencePollDialog` 4 items, đúng 68% cho easy,
  `audiencePercentiles['A0'] == 68`, timer pause (elapse không
  trừ `remainingTime`), dismiss → timer chạy lại; sang câu →
  percentiles `null`.

**Widget** (`test/widgets/game_screen_test.dart`) — +2 test:

- `bar lifeline: 2 nút playing; 50:50 xóa 2 ô + nút tắt`:
  `find.byIcon(Icons.percent)`/`Icons.people` findsOneWidget;
  `Icons.auto_awesome` findsNothing (Bài 4 mới thêm nút AI);
  tap `%` → `'Sai 1b'`/`'Sai 1c'` biến mất khỏi cây, `Đúng 1` +
  `Sai 1a` còn; `vm.state.usedFeatureButtons` chứa fiftyFifty.
- `hỏi khán giả → dialog 4 hàng % đúng 68; ĐÃ HIỂU đóng`:
  tap `Icons.people` → `'Hỏi khán giả'` + `'68%'` +
  `findsNWidgets(4)` `LinearProgressIndicator`; tap ĐÃ HIỂU →
  dialog đóng.

:::caution[VM tiêm phải start trước pump — sửa `pumpGameScreen`]
`screenData` giờ index `visibleOptionTexts` — VM chưa `startNewGame`
→ list rỗng → **RangeError ngay frame đầu**. Helper test cập nhật:

```dart
    final vm = GameScreenViewModel(questions: questions ?? miniBank())
      ..startNewGame();
```

Đây đúng senior (VM luôn start trước build đầu — `create:` gọi
ngay khi read). Event intro bắn trước khi bridge subscribe; nhánh
recovery post-frame (`dialogState is! GameDialogHidden →
_showCurrentDialog`) vẫn mở intro ladder đúng.
:::

## Chạy và quan sát

```bash
flutter analyze          # sạch
flutter test             # 141/141 (+6 VM, +2 mapper, +2 widget)
flutter run              # thanh 2 nút dưới đáp án; tap % xóa 2 ô;
                         # nút mờ sau khi dùng; tap people → dialog 68%
```

Điểm quan sát đúng-senior: **sau 50:50, đồng hồ vẫn chạy** (không
dialog, không pause); **sau poll, đồng hồ dừng** tới khi ĐÃ HIỂU.
Ô trống vẫn nhìn thấy, không tap được.

## Thử nghiệm — đoán trước khi chạy

Trong `_useFiftyFifty`, tạm đổi `applyGameFiftyFifty(...)` thành
`questions[_state.questionIndex].options` (bỏ hẳn helper — không
xóa ô nào) rồi chạy `flutter test`. **Đoán:** bao nhiêu test fail?
*(Đáp án: helper test không fail vì nó test hàm riêng; VM test
`visibleOptionTexts == ['A0','W0_1','','']` fail, widget test "ô
xóa biến mất" fail — nhưng nút vẫn tắt đúng nên test single-use
**không** fail (`usedFeatureButtons` vẫn được ghi). Phân tầng
đúng cho thấy tầng nào gánh hành vi nào.)*

## Lỗi hay gặp

- **`RangeError` frame đầu trong test** — quên `..startNewGame()`
  trên VM tiêm (xem caution trên). App thật không gặp vì `create:`
  đã start.
- **Làm ô rỗng `return SizedBox.shrink()`** — sai: lưới nhảy vị
  trí, khác senior. Ô trống phải *render* (idle) nhưng không tap.
- **`usedFeatureButtons.add(type)`** — ném lỗi runtime trên
  `Set.unmodifiable`. Ghi đúng: `{..._state.usedFeatureButtons,
  type}` trong `copyWith`.
- **Reset `usedFeatureButtons` khi sang câu** — sai semantics:
  dùng-một-lần là *cả ván*, chỉ `visibleOptionTexts`/
  `audiencePercentiles` reset theo câu.
- **`firstWhere` ném `StateError`** — nếu question không có đáp án
  sai nào (bank 1-option pathological). Bank thật luôn 4 options
  + 1 đúng → không xảy ra; helper test khóa giả định này.

## Tự làm

:::note[Gợi ý]
`thoát trò chơi` (`exitGame`) đã đi qua `handleFeatureClick` →
`showConfirmExit()` — nhưng nút ✕ top bar hiện gọi thẳng
`viewModel.showConfirmExit()`. Hợp nhất hai đường đó: cho ✕ gọi
`handleFeatureClick(GameFeatureButtonData(type: exitGame, …))`?
:::

<details><summary>Đáp án</summary>

Không nên — và senior cũng không. `_canUseFeature` cho `exitGame`
luôn `true` khi `playing`, nhưng nút ✕ phải hoạt động cả trong
các trạng thái khác theo `_handleRouteBack` (đóng dialog, ignore
terminal…). Hai đường có *guard khác nhau*: `handleFeatureClick`
cho bar (chỉ playing), ✕ cho top-bar (route-aware). Giữ tách
đúng senior: `exitGame` trong enum tồn tại cho button-data parity,
không phải để hợp nhất wiring.

</details>

## Kiểm tra hiểu biết

1. Tại sao 50:50 không `_stopTimer()` nhưng poll thì có?
   *(50:50 không mở dialog — không có gì để "đọc" nên không pause;
   poll mở dialog phải pause giống mọi dialog khác.)*
2. Ba lớp phòng thủ của ô trống là gì, và tại sao cần cả ba?
   *(mapper `isEmpty→idle` render; widget `onTap:null` chặn tap;
   VM `answerText.isEmpty` chặn submit — mỗi lớp che một đường
   vào khác nhau.)*
3. `usedFeatureButtons` sống qua `dismissDialog`/`sang câu` nhưng
   reset khi nào? *(Chỉ `startNewGame` — `initial()` Set rỗng.)*

## Ta cố ý chưa thêm

- Nút `aiAssistant`/`walkAway` trong `_buildFeatureButtons` +
  hai arm switch đang `break` — **Bài 4** (cùng `_showAIAssistant`,
  `_showConfirmWalkAway`, `confirmWalkAway`, `resolvedResult`).
- `GameFeatureButton` painter/SVG — **M28**.
- In-Stack `GameDialogLayer` thay `showDialog` — **M21**.

## Checkpoint hoàn thành

- [ ] `flutter analyze` sạch; `flutter test` = **141/141**.
- [ ] Chạy app: bar có đúng 2 nút (% + people); tap % → 2 ô sai
  trống nhưng vẫn hiển thị; nút mờ đi, tap lại không đổi gì.
- [ ] Tap people → dialog 4 hàng, đáp án đúng 68% (câu easy);
  ĐÃ HIỂU → timer chạy tiếp.
- [ ] Back hệ thống trong dialog poll → đóng dialog (generic
  dismiss), không thoát màn.
