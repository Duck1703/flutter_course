---
title: "Bài 4 · Hỏi AI và Dừng cuộc chơi: async mô phỏng + kết quả chốt"
description: "AI 700ms loading→kết quả trong MỘT dialog (ListenableBuilder live-read), walk-away → victory phase + resolvedResult{won:false} — tại sao phase một mình không đủ diễn tả kết quả. Checkpoint: 147/147."
sidebar:
  label: "Bài 4 · AI + walk-away"
  order: 4
---

## Mục tiêu

- Dựng luồng AI hai nhịp đúng senior: emit dialog `isLoading`
  ngay lập tức → `Future.delayed(700ms)` → emit lại variant kết
  quả — và hiểu vì sao host dialog phải đọc `dialogState` *live*.
- Dựng walk-away đầy đủ: gate `>0` → confirm dialog → phase
  `victory` nhưng `resolvedResult.won == false`.
- Giải thích được tại sao `phase` một mình không suy ra được
  `won`/`earned` — và `resolvedResult` là bản ghi *chốt* tại
  transition.

## Bạn đang ở đâu

- Sau Bài 3: 141/141 — bar đang có 2 nút sống (50:50, poll),
  `handleFeatureClick` có 2 arm `break` chờ nối, mapper
  `_buildFeatureButtons` có 2 entry + `canWalkAway` param sẵn.
- Bài này hoàn thiện bar (4 nút tối đa) và hai luồng còn lại.

## Vì sao việc này quan trọng ngay bây giờ

**AI là luồng async đầu tiên đụng dialog.** Cho tới M19 mọi
dialog đều "mở là xong" — nội dung bất biến theo snapshot lúc
route mở. AI khác: dialog phải *hiện loading* rồi *tự đổi sang
kết quả* sau 700ms **mà route `showDialog` không mở lại**. Nếu
host đọc `dialogState` một lần lúc mở, state mới đến vẫn hiện
spinner mãi — đây là chỗ `_GameDialogHost` của M19 phải đổi
kiến trúc (xem Bước 5).

**Walk-away là chỗ `phase` phản bội.** Senior đưa walk-away về
`phase: victory` — vì UI kết thúc giống thắng (dialog mừng, nút
chơi lại/về menu). Nhưng ván *không thắng*: `won` phải `false`,
tiền = walk-away chứ không phải jackpot. Nếu `buildGameResult()`
suy `won` từ `phase == victory` thì walk-away được tính là thắng
→ profile +gamesWon sai. Senior giải bằng `GameSaveResult` mang
`isWin` tường minh; learner port ý đó thành `resolvedResult` —
field `GameResult?` trên state, **set ngay tại transition**.

## Bạn đã biết gì

- `Future.delayed` + guard token trong `_schedule` (M19
  `flowToken`); `unawaited` (M11).
- `GameDialogState` sealed family + exhaustive switch (M15/M19) — Bài này thêm 2 variant nốt ở Bước 1;
  `GameAIAssistantDialog` mang `isLoading` — *một variant, hai hình*.
- `_walkAwayAmount(state)` = `calculateGameWalkAwayAmount`
  (guaranteed>0 ? max(guaranteed, earned) : 0) — M19, verbatim
  senior.
- `ListenableBuilder` (M11) — sẽ tái dùng *bên trong* một
  route `showDialog`.

## Dart cần dùng / Dart mới

| Cú pháp | Ví dụ | Nghĩa |
| --- | --- | --- |
| guard `is!` | `if (dialog is! GameAIAssistantDialog) return;` | "không còn là AI dialog" → bỏ kết quả trễ |
| staged emit | copyWith(dialogState: loading) → delay → copyWith(dialogState: result) | hai emit, một route |
| `resolvedResult ??` | `_state.resolvedResult ?? build(...)` | đã chốt thì đọc, chưa thì suy (transport M10) |

## Android / Compose bridge

- **SIMILARITY:** staged emit loading→result ↔ coroutine
  `delay(700)` rồi update `MutableStateFlow`; dialog rebuild theo
  state ↔ Compose recomposition theo `collectAsState`.
- **IMPORTANT DIFFERENCE:** `Future.delayed` + token guard chạy
  trên VM chứ không `viewModelScope` — Dart không có structured
  concurrency sẵn; `_isDisposed` + `flowToken` là "cancellation"
  viết tay.
- **DO NOT ASSUME:** `walkAway` vào `victory` phase nhưng
  `won:false` — đừng suy kết quả từ phase; đây chính lý do
  `resolvedResult` tồn tại (UI-state ≠ domain-result).

## Senior project connection

- `view_models/game/game_screen_view_model.dart` (senior) —
  `_showAIAssistant`/`_showAIAssistantResult`/`_aiAssistantDelay`
  700ms/`confidencePercentage 85` verbatim; `_showConfirmWalkAway`
  + `_confirmWalkAway` (`isWin: false` trên `GameSaveResult`).
- `view_models/game/reducer/game_reducer_feature_flow.dart` —
  senior dispatch `GameFeatureButtonType.*` action → reducer; VM
  learner giữ tên method `_show*`/`_confirm*` cho parity.
- `widgets/game/dialogs/` (senior) — `_LoadingBody`,
  `_AIAssistantBody`, `AudiencePollRow`, `_ConfirmBody` — shape
  dialog learner port 1:1 phần *nội dung*.

## Build it step by step

### Bước 1 — Hai sealed variant còn lại (state file)

`lib/data/game/game_session_state_data.dart` — thêm hai variant
(Bài 2 cố ý chưa thêm vì sealed cần arm UI đi kèm; giờ đến cùng
bài):

```dart
/// Dialog xác nhận "dừng cuộc chơi" (walk-away) — M20.
/// Senior `GameConfirmWalkAwayDialog`: mang số tiền sẽ mang về.
final class GameConfirmWalkAwayDialog extends GameDialogState {
  const GameConfirmWalkAwayDialog({required this.currentAmount});

  /// Số tiền mang về nếu dừng — `formatGameMoney(walkAwayAmount)`.
  final String currentAmount;
}

/// Dialog "hỏi AI" — M20. Senior `GameAIAssistantDialog`: hai trạng
/// thái trong một variant — `isLoading` (spinner) → kết quả
/// (`selectedAnswer` + `confidencePercentage` + `explanation`).
final class GameAIAssistantDialog extends GameDialogState {
  const GameAIAssistantDialog({
    required this.selectedAnswer,
    required this.confidencePercentage,
    required this.explanation,
    this.isLoading = false,
  });

  /// Đáp án AI "chọn" — trong bản senior luôn là `correctOption`
  /// (AI mô phỏng, không gọi mạng).
  final String selectedAnswer;

  /// Độ tin cậy hiển thị — senior hardcode `85`.
  final int confidencePercentage;

  /// Gợi ý hiển thị — `question.explanation.aiHintMessage`.
  final String explanation;

  /// `true` trong 700ms chờ mô phỏng (`_aiAssistantDelay`).
  final bool isLoading;
}
```

**Compile đỏ tạm từ đây tới Bước 6** — ba `switch` kiệt hợp
(`_title`/`_content`/`_actions`) thiếu 2 arm mỗi. Đừng analyze giữa
chừng; arm đến ở Bước 6 cùng UI của chúng, giống flow poll ở Bài 3.

### Bước 2 — VM: `_aiAssistantDelay` + `_showAIAssistant` +
`_onAIAssistantElapsed`

`lib/view_models/game/game_screen_view_model.dart` — constant cạnh
hai delay cũ:

```dart
  /// M20 — senior `_aiAssistantDelay`: 700ms "AI suy nghĩ" mô phỏng.
  static const _aiAssistantDelay = Duration(milliseconds: 700);
```

Hai method — đọc comment kỹ, đây là bản verbatim senior của một
luồng *hai emit*:

```dart
  /// Hỏi AI — senior `_showAIAssistant`: mở dialog `isLoading`, đánh
  /// dấu đã dùng, pause timer, lên lịch 700ms. Kết quả MÔ PHỎNG
  /// (không gọi mạng): `selectedAnswer = correctOption`, 85%,
  /// `aiHintMessage` — xem [_onAIAssistantElapsed].
  void _showAIAssistant() {
    final token = _state.flowToken + 1;
    _stopTimer();
    _emit(
      _state.copyWith(
        flowToken: token,
        usedFeatureButtons: {
          ..._state.usedFeatureButtons,
          GameFeatureButtonType.aiAssistant,
        },
        dialogState: const GameAIAssistantDialog(
          selectedAnswer: '',
          confidencePercentage: 0,
          explanation: '',
          isLoading: true,
        ),
      ),
    );
    _emitEvent(const GameDialogRequested());
    _schedule(_aiAssistantDelay, token, _onAIAssistantElapsed);
  }

  /// AI "trả lời" sau delay — senior `_showAIAssistantResult`: guard
  /// kép token + dialog vẫn là AI (user có thể đã đóng giữa chừng —
  /// khi đó kết quả bị bỏ, đúng senior).
  void _onAIAssistantElapsed(int token) {
    if (_state.dialogState is! GameAIAssistantDialog) return;
    final question = questions[_state.questionIndex];
    _emit(
      _state.copyWith(
        dialogState: GameAIAssistantDialog(
          selectedAnswer: question.correctOption,
          confidencePercentage: 85,
          explanation: question.explanation.aiHintMessage,
        ),
      ),
    );
    // Không bắn GameDialogRequested: route `showDialog` đang mở sẵn,
    // `_GameDialogHost` rebuild theo `dialogState` mới
    // (ListenableBuilder — host đọc live).
  }
```

Ba guard chồng nhau và mỗi cái che một hỏng khác nhau:

| Guard | Hỏng nếu thiếu |
| --- | --- |
| `_schedule` token (`token != _state.flowToken → return`) | `playAgain`/ván mới → AI cũ "trả lời" vào ván mới |
| `_schedule` `_isDisposed` | callback chạy trên VM đã chết → crash |
| `_onAIAssistantElapsed` `is! GameAIAssistantDialog` | user đã đóng dialog giữa 700ms → kết quả trễ **mở lại** dialog (senior: bỏ) |

Và emit thứ hai **không** `_emitEvent(GameDialogRequested())` —
không có route mới; route cũ rebuild theo state (Bước 5).

### Bước 3 — VM: walk-away + `resolvedResult` chốt kết quả

```dart
  /// Mở xác nhận walk-away — senior `_showConfirmWalkAway`: chỉ khi
  /// `playing` VÀ có tiền mang về (> 0). Timer pause trong dialog.
  void _showConfirmWalkAway() {
    final amount = _walkAwayAmount(_state);
    if (_state.phase != GamePhase.playing || amount <= 0) return;
    _stopTimer();
    _emit(
      _state.copyWith(
        dialogState: GameConfirmWalkAwayDialog(
          currentAmount: formatGameMoney(amount),
        ),
      ),
    );
    _emitEvent(const GameDialogRequested());
  }

  /// Public wrapper senior — giữ tên cho parity (`dispatch
  /// GameConfirmWalkAwayRequested`).
  void showConfirmWalkAway() => _showConfirmWalkAway();

  /// Xác nhận dừng cuộc — senior `_confirmWalkAway`: phase `victory`
  /// (UI kết thúc giống thắng), timer về 0, dialog chiến thắng mang
  /// số tiền walk-away; bản ghi kết quả `won: false` + `earned` =
  /// walkAway (senior `isWin: false`, `earnedAmount: amount`).
  void confirmWalkAway() {
    final amount = _walkAwayAmount(_state);
    _emit(
      _state.copyWith(
        phase: GamePhase.victory,
        remainingTime: Duration.zero,
        resolvedResult: GameResult(
          questionsAnswered: _state.questionIndex + 1,
          correctAnswers: _state.questionIndex,
          won: false,
          earnedAmount: amount,
        ),
        dialogState: GameVictoryDialog(
          earnedAmount: formatGameMoney(amount),
          affirmationMessage:
              'Your knowledge is your superpower! Keep learning and growing!',
        ),
      ),
    );
    _emitEvent(const GameDialogRequested());
  }
```

Cùng pattern chốt-kết-quả được xới vào `_endGame`, nhánh victory
thật của `_loadNextQuestionOrVictory`, và `backToMenu` — mỗi chỗ
giờ set `resolvedResult` tường minh (`won:true` cho victory thật,
`won:false` + `earned: guaranteed` cho thua, `won:false` +
`earned: walkAway` cho thoát/dừng):

```dart
  /// M20: đọc [GameSessionState.resolvedResult] — bản ghi được CHỐT
  /// lúc transition (senior `GameSaveResult` mang `isWin`/
  /// `earnedAmount` tường minh). Quan trọng với walk-away: senior
  /// đẩy phase `victory` nhưng `isWin: false` — suy `won` từ phase
  /// sẽ sai.
  GameResult buildGameResult() {
    return _state.resolvedResult ??
        GameResult(
          questionsAnswered: _state.questionIndex + 1,
          correctAnswers: _state.questionIndex,
          won: false,
          earnedAmount: _walkAwayAmount(_state),
        );
  }
```

(`backToMenu` + `_endGame` + victory-arm: thêm `resolvedResult:
GameResult(...)` vào `copyWith` hiện có — xem file production cho
field chính xác từng nhánh; fallback của `buildGameResult` vẫn
phục vụ "thoát giữa ván" chưa-resolve.)

### Bước 4 — Nối 2 arm switch + hoàn thiện bar

Trong `handleFeatureClick` — hai arm `break` thành call thật:

```dart
      case GameFeatureButtonType.aiAssistant:
        _showAIAssistant();
      case GameFeatureButtonType.walkAway:
        _showConfirmWalkAway();
```

Trong mapper `_buildFeatureButtons` — thêm AI (luôn có) + walkAway
(có điều kiện) đúng thứ tự senior:

```dart
    _feature(
      GameFeatureButtonType.audiencePoll,
      Icons.people,
      'Ask the Audience',
      canPlay,
      usedFeatureButtons,
    ),
    _feature(
      GameFeatureButtonType.aiAssistant,
      Icons.auto_awesome,
      'Ask AI',
      canPlay,
      usedFeatureButtons,
    ),
  ];
  if (canWalkAway) {
    buttons.add(
      _feature(
        GameFeatureButtonType.walkAway,
        Icons.emoji_events,
        'Walk Away',
        canPlay,
        usedFeatureButtons,
      ),
    );
  }
  return buttons;
```

Giờ `canWalkAway` param (đã khai Bài 3) thật sự được dùng — nút
walk-away **xuất hiện** chỉ sau safe haven đầu. Đây là senior
paradox đáng nhớ: `canWalkAway` (hiện nút) dùng `guaranteedAmount
> 0`, còn `_canUseFeature` (cho bấm) dùng `_walkAwayAmount > 0` —
hai điều kiện khác nhau, senior giữ riêng có chủ đích.

### Bước 5 — `_GameDialogHost`: snapshot → live-read

Đây là thay đổi kiến trúc nhỏ nhưng then chốt của M20. Bản M19
đọc `dialogState` **một lần lúc route mở** (param truyền vào);
AI cần dialog tự đổi khi emit thứ hai đến — nên host phải
`ListenableBuilder` trên chính VM:

```dart
/// Host render một variant của [GameDialogState] thành `AlertDialog`.
/// Scaffold M19–M20 — M21 thay bằng `GameDialogLayer` trong `Stack`.
///
/// M20: đọc `viewModel.dialogState` LIVE qua [ListenableBuilder] thay
/// snapshot lúc mở — dialog "Hỏi AI" tự đổi loading → kết quả khi VM
/// phát state mới (route `showDialog` không cần event mở lại).
class _GameDialogHost extends StatelessWidget {
  final GameScreenViewModel viewModel;
  final AppLocalizations l10n;

  const _GameDialogHost({required this.viewModel, required this.l10n});

  /// Variant đang thật sự mở — đọc trực tiếp từ state.
  GameDialogState get dialog => viewModel.dialogState;

  @override
  Widget build(BuildContext context) {
    void close([_GameDialogAction action = _GameDialogAction.dismiss]) =>
        Navigator.of(context).pop(action);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return AlertDialog(
          // ... giữ nguyên: title: Text(_title, ...),
          // content: _content, actions: _actions(close) ...
        );
      },
    );
  }
```

**Đổi cả call-site** — builder của `showDialog` trong
`_showCurrentDialog` giờ truyền `viewModel:` thay `dialog:` (bản
M19 truyền snapshot `dialog: dialog`); `l10n` vẫn lấy từ
`dialogContext`:

```dart
      builder: (dialogContext) => _GameDialogHost(
        // M20: truyền VM + đọc `dialogState` TRỰC TIẾP qua
        // ListenableBuilder — dialog "Hỏi AI" đổi nội dung
        // loading→kết quả KHÔNG qua event mới, nên route đang mở
        // phải tự rebuild theo state (bản in-Stack M21 sẽ làm điều
        // này tự nhiên hơn).
        viewModel: viewModel,
        l10n: AppLocalizations.of(dialogContext),
      ),
```

`_content`/`_actions`/`_title` giờ đọc `dialog` *trong* builder →
mỗi emit rebuild route đang mở. (Vì `_content`/`_actions` là getter
trên host đọc `viewModel.dialogState` lazy qua getter `dialog` —
chúng tự nhận giá trị mới mỗi build.)

:::caution[Vì sao không "đóng loading rồi mở dialog kết quả"?]
Route-level mở–đóng tốn animation + pop/push mới, và back-press
giữa hai route có cửa sổ state kỳ lạ. Senior giữ **một route,
hai nội dung**: variant đổi trong `dialogState`, cùng `AlertDialog`
rebuild. M21 sẽ làm điều này còn sạch hơn khi dialog vào `Stack`
(visibility = state, không route nào cả).
:::

### Bước 6 — `_content`/`_actions` arms cho AI + walk-away

`_content` — hai arm mới (walk-away dùng chung shape
confirm-exit: message + số tiền; AI chia loading/result theo
`isLoading`):

```dart
    // M20 — walk-away: cùng shape confirm-exit (senior `_ConfirmBody`
    // dùng chung): message + số tiền mang về.
    GameConfirmWalkAwayDialog(:final currentAmount) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.walkAwayMessage, textAlign: TextAlign.center,
            style: const TextStyle(
                color: MenuTokens.textPrimary, fontSize: 14)),
        const SizedBox(height: MenuTokens.spacingSm),
        Text(currentAmount,
            style: const TextStyle(
                color: MenuTokens.accentYellow,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ],
    ),
    // M20 — AI (mô phỏng): `isLoading` → spinner + "AI đang suy
    // nghĩ..."; xong → chip đáp án + 85% + gợi ý (senior
    // `_AIAssistantBody`).
    GameAIAssistantDialog(
      :final isLoading,
      :final selectedAnswer,
      :final confidencePercentage,
      :final explanation,
    ) =>
      isLoading
          ? Padding(
              padding: const EdgeInsets.symmetric(
                vertical: MenuTokens.spacingLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: MenuTokens.accentCyan,
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: MenuTokens.spacingMd),
                  Text(
                    l10n.aiThinkingMessage,
                    style: const TextStyle(
                      color: MenuTokens.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: MenuTokens.spacingLg,
                    vertical: MenuTokens.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x2E89E87F),
                    borderRadius: BorderRadius.circular(
                      MenuTokens.radiusCard,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.task_alt,
                        size: 18,
                        color: MenuTokens.statGreen,
                      ),
                      const SizedBox(width: MenuTokens.spacingXs),
                      Flexible(
                        child: Text(
                          selectedAnswer,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: MenuTokens.statGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MenuTokens.spacingSm),
                Text(
                  '$confidencePercentage%',
                  style: const TextStyle(
                    color: MenuTokens.accentCyan,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  explanation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MenuTokens.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
```

`_actions` — walk-away hai nút; **AI không có nút khi đang
loading** (senior `_LoadingBody` không render nút — user chỉ
back được):

```dart
      // M20 — walk-away: "Chơi tiếp" (dismiss) | "Xác nhận dừng"
      // (confirmWalkAway → senior `_confirmWalkAway`).
      GameConfirmWalkAwayDialog() => [
        _DialogTextButton(
          label: l10n.keepPlayingButton,
          onTap: () => close(),
        ),
        _DialogTextButton(
          label: l10n.confirmWalkAwayButton,
          color: MenuTokens.accentRed,
          onTap: () => close(_GameDialogAction.confirmWalkAway),
        ),
      ],
      // M20 — poll luôn có nút hiểu; AI chỉ có nút khi hết loading
      // (senior `_LoadingBody` không render nút — user chỉ back được).
      GameAudiencePollDialog() => [
        _DialogTextButton(
          label: l10n.understandButton,
          onTap: () => close(),
        ),
      ],
      GameAIAssistantDialog(:final isLoading) => isLoading
          ? const []
          : [
              _DialogTextButton(
                label: l10n.understandButton,
                onTap: () => close(),
              ),
            ],
```

`_title` thêm `GameConfirmWalkAwayDialog() => l10n.walkAwayTitle`
+ `GameAIAssistantDialog() => l10n.aiAssistantTitle`.

**Enum + dispatch** — `_GameDialogAction` thêm `confirmWalkAway`;
`switch (action)` trong `_showCurrentDialog` (nơi xử lý kết quả
`await showDialog`) thêm arm:

```dart
      case _GameDialogAction.confirmWalkAway:
        viewModel.confirmWalkAway();
```

### Bước 7 — Test

**Sealed** (`test/sealed_state_test.dart`) — thêm 2 arm nốt vào
`label()` → **đủ 9 variant, khớp senior 1:1**:

```dart
          GameConfirmWalkAwayDialog() => 'confirm-walk-away',
          GameAIAssistantDialog() => 'ai-assistant',
```

cùng hai `expect` construct (walk-away mang `currentAmount`, AI
test ở hình `isLoading: true`):

```dart
      expect(
        label(const GameConfirmWalkAwayDialog(currentAmount: r'$0')),
        'confirm-walk-away',
      );
      expect(
        label(
          const GameAIAssistantDialog(
            selectedAnswer: '',
            confidencePercentage: 0,
            explanation: '',
            isLoading: true,
          ),
        ),
        'ai-assistant',
      );
```

**VM** (`test/game_screen_view_model_test.dart`) — +4 test hai
group:

- `hỏi AI (mô phỏng)` ×2: loading ngay (`isLoading`, used chứa
  `aiAssistant`, timer pause) → `async.elapse(700ms)` → kết quả
  `selectedAnswer='A0'`, `confidencePercentage=85`,
  `explanation='gợi ý'` (từ `aiHintMessage` bank mini), dismiss →
  timer chạy lại. Test 2 — **đóng giữa loading**: `dismissDialog`
  trong 700ms rồi `elapse(1s)` → `dialogState` vẫn
  `GameDialogHidden` (kết quả trễ bị bỏ — guard `is!` chứng
  minh).
- `walk-away + thoát` ×2: trước safe haven nút ẩn + bấm tay bị
  `_canUseFeature` chặn; sau 5 câu đúng (guaranteed=20k) →
  `GameConfirmWalkAwayDialog` mang `'$20,000'` → `confirmWalkAway`
  → `phase=victory` + `GameVictoryDialog('$20,000')` +
  `buildGameResult()` trả `{won:false, earned:20000,
  questionsAnswered:6}`; và `walkAway` KHÔNG ghi `usedFeatureButtons`.

**Mapper** — bật assert đầy đủ (thay bản L03 2-nút): `canWalkAway:
true` → 4 type theo thứ tự; `notPlaying` → mọi nút disable +
không `walkAway`.

**Widget** — +2 test:

- `hỏi AI → "đang suy nghĩ" → kết quả đúng + 85% + hint`: tap
  `Icons.auto_awesome` → `'AI đang suy nghĩ...'`; `pump(800ms)` →
  `'Đúng 1'` (chip) + `'85%'` + `'hint 1'`; ĐÃ HIỂU đóng.
- `walk-away sau safe haven → confirm → Chúc mừng mang đúng số
  tiền; kết quả won=false`: bank mini 6 câu (`_mkQ`), 5 câu đúng
  qua `answerAndAdvance` → `Icons.emoji_events` hiện → tap →
  dialog `'Dừng cuộc chơi?'` + `'$20,000'` — assert dùng
  `find.descendant(of: find.byType(AlertDialog), matching:
  find.text(r'$20,000'))` vì chip tiền trên top bar *cũng* hiển
  thị `$20,000` (`find.descendant` = finder API mới — giới hạn
  match trong subtree) →
  `'XÁC NHẬN DỪNG'` → `'Chúc mừng'` + `won=false`.

và **sửa test bar L03**: `Icons.auto_awesome` `findsNothing` →
`findsOneWidget` (AI đã vào bar).

## Chạy và quan sát

```bash
flutter analyze          # sạch
flutter test             # 147/147 (+4 VM, +2 widget, mapper assert mở)
flutter run              # bar đủ 3 nút; sau safe haven Q5 hiện nút
                         # walk-away; AI dialog đổi loading→kết quả
```

Điểm quan sát đúng-senior: **trong 700ms loading không có nút
ĐÃ HIỂU** — chỉ back/dismiss được; **walk-away → "Chúc mừng"**
(dialog victory) nhưng profile **không** +gamesWon.

## Thử nghiệm — đoán trước khi chạy

Trong `_onAIAssistantElapsed`, tạm xóa dòng
`if (_state.dialogState is! GameAIAssistantDialog) return;` rồi
chạy `flutter test`. **Đoán:** test nào fail?
*(Đáp án: test "đóng giữa loading" fail — sau `dismissDialog`
dialogState về `GameDialogHidden`, hết 700ms result emit ghi đè
thành `GameAIAssistantDialog` → dialog *mở lại* dù user đã đóng.
Đây là cửa sổ "kết quả trễ" mà guard `is!` che — và là lý do
route đang mở phải đọc live state.)*

## Lỗi hay gặp

- **Emit thứ hai kèm `GameDialogRequested`** → mở *thêm* một route
  dialog chồng lên — senior không bắn event cho result emit;
  chỉ loading emit mới mở route.
- **Quên guard `is! GameAIAssistantDialog`** → user đóng loading
  rồi 700ms sau kết quả *mở lại* dialog — test "đóng giữa
  loading" bắt đúng bug này.
- **`won: true` cho walk-away** — phase là `victory` nhưng kết
  quả là `won:false`; đọc `resolvedResult`, đừng suy từ phase.
- **`_walkAwayAmount` vs `guaranteedAmount`** cho gate hiện nút —
  senior: nút hiện theo `guaranteedAmount > 0` (mapper), guard
  bấm theo `_walkAwayAmount > 0` (VM). Gộp hai điều kiện = lệch
  senior.

## Tự làm

:::note[Gợi ý]
Điều gì xảy ra nếu user bấm AI → đóng loading → bấm AI **lần
hai** trước khi 700ms của lần đầu hết hạn? Truy theo: lần hai có
vào được không (`usedFeatureButtons`)? `flowToken` mới vô hiệu
callback nào?
:::

<details><summary>Đáp án</summary>

Lần hai **không vào được** — `aiAssistant` đã nằm trong
`usedFeatureButtons` từ emit đầu (ghi ngay lúc mở loading, không
đợi kết quả) → `_canUseFeature` chặn. Lỡ vào được thì `flowToken
+1` của emit mới cũng đã vô hiệu callback 700ms cũ qua
`_schedule`. Kết quả: không có kết quả-trễ nào có thể ghi đè
dialog mới — double protection đúng senior.

</details>

## Kiểm tra hiểu biết

1. Vì sao emit kết quả AI không `_emitEvent(GameDialogRequested())`?
   *(Route `showDialog` đang mở sẵn — host `ListenableBuilder` tự
   rebuild theo `dialogState` mới; event mới = route mới chồng.)*
2. Walk-away vào `phase: victory` nhưng `won:false` — field nào
   bảo toàn sự thật, và nó được set ở đâu?
   *(`resolvedResult`, set trong `confirmWalkAway` tại transition.)*
3. Tại sao nút AI không có ĐÃ HIỂU khi `isLoading`?
   *(Senior `_LoadingBody` không render nút — dialog đang "bận";
   đóng bằng back/generic dismiss, kết quả trễ sẽ bị bỏ qua
   guard.)*

## Ta cố ý chưa thêm

- AI **thật** (network/LLM call) — senior cũng mô phỏng
  (`Future.delayed` + fixed 85% + `aiHintMessage`); không có
  milestone "AI thật" trong roadmap — đây là hành vi cuối.
- `GameSaveResult` async-op + `hasSavedResult` + VM persist qua
  repository — **M22** (khi đó `resolvedResult`/route-pop
  transport được thay bằng save-site trong VM ở M22).
- `GameDialogLayer` trong `Stack` — **M21**; `ListenableBuilder`
  host là bước quá độ hợp lý.

## Checkpoint hoàn thành

- [ ] `flutter analyze` sạch; `flutter test` = **147/147**.
- [ ] Bar đủ 3 nút trước safe haven; nút 🏆 hiện sau câu 5 đúng.
- [ ] AI: loading 700ms → chip đáp án đúng + 85% + gợi ý; đóng
  giữa loading không mở lại.
- [ ] Walk-away → "Chúc mừng $20,000"; profile `gamesWon` không
  tăng (result `won:false`).
