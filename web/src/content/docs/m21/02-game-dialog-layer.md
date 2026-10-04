---
title: "Bài 2 · GameDialogLayer — skeleton & backdrop"
description: "Tạo hai file mới: game_dialog_views.dart (9 view, nội dung port nguyên từ _GameDialogHost) và game_dialog_layer.dart skeleton (Positioned.fill + IgnorePointer + backdrop blur + tap-outside rules). Layer chưa gắn vào màn — kiểm bằng test riêng."
sidebar:
  label: "Bài 2 · layer + backdrop"
  order: 2
---

## Mục tiêu

- Tạo `lib/widgets/game/game_dialog_views.dart`: shell card +
  9 view, mỗi view nhận callback đúng tên senior (`onDismiss`/
  `onConfirm`/`onCancel`/`onPlayAgain`/`onBackToMenu`).
- Tạo `lib/widgets/game/game_dialog_layer.dart` bản skeleton:
  `Positioned.fill` → `IgnorePointer` → `_DialogBackdrop` → view
  theo variant — CHƯA có `AnimatedSwitcher` (Bài 3 thêm).
- Viết 3 test đầu cho layer (render confirm, tap-outside rules) —
  layer chạy độc lập, chưa gắn màn.

## Bạn đang ở đâu

- Bài 1: mental model in-tree — dialog là projection của `dialogState`.
- Hai file mới của bài này **chưa** được màn hình dùng — màn vẫn
  chạy scaffold `showDialog` đến Bài 4. Đó là cố ý: layer được xây
  và kiểm độc lập trước khi thay cơ chế cũ.

## Vì sao việc này quan trọng ngay bây giờ

Nguyên tắc "đổi cơ chế hiển thị, đổi không gì khác": 9 dialog body
đã đúng nội dung từ M19–M20 — bài này **port nguyên văn** chúng
sang view widgets, chỉ đổi "vỏ": `AlertDialog` trong route → card
trong cây. Nếu nội dung đổi cùng lúc cơ chế đổi, bug sẽ không biết
đổ ở đâu.

## Bạn đã biết gì

- `Stack`/`Positioned.fill` overlay (M18); model in-tree (Bài 1).
- `ListView`/`SingleChildScrollView`, `Column` (các màn trước).
- `AppLocalizations.of(context)` + key ARB (M17, F-25).
- Widget test `pumpWidget` + `find.text` (M19–M20).

## Dart/Flutter cần dùng — xuất hiện đầu tiên

| Construct | Vai trò |
|---|---|
| `BackdropFilter` + `ImageFilter.blur(σ)` (`dart:ui`) | làm mờ nội dung phía sau — "haze" của senior |
| `ClipRect` | giới hạn vùng blur trong bounds — thiếu nó blur "tràn" lệch layer |
| `GestureDetector(behavior: HitTestBehavior.opaque)` | vùng nền vô hình vẫn nhận tap — chặn tap xuyên |
| `IgnorePointer(ignoring:)` | tắt hit-test của cả subtree mà không gỡ widget |
| `MediaQuery.of(context).disableAnimations` | a11y reduced-motion (dùng ở Bài 3) |

`BackdropFilter`/`ClipRect`/`IgnorePointer`/`opaque` là **F-30**
(NORMAL) — widget hiệu ứng, không phải concept kiến trúc.

## Mental model mới — "hai chính sách dismiss, một hàm thuần"

Senior tách rõ hai rule:

```dart
bool _canDismissFromBackdrop(GameDialogState dialog) =>
    dialog is! GameMoneyLadderDialog && !_isTerminalDialog(dialog);

bool _isTerminalDialog(GameDialogState dialog) =>
    dialog is GameEndedDialog || dialog is GameVictoryDialog;
```

- **Tap nền** (`_canDismissFromBackdrop`): thang tiền và dialog kết
  thúc KHÔNG đóng bằng tap-outside — thang bắt buộc nút ĐÃ HIỂU,
  terminal bắt buộc chọn MENU/CHƠI LẠI. Còn lại (confirm, giải thích,
  poll, AI) tap nền đóng được.
- **Back hệ thống** là rule khác (`_handleRouteBack`, Bài 4) — đừng
  trộn hai rule: tap-outside là *tiện lợi*, back là *điều hướng*.

## Android / Compose bridge

```text
SIMILARITY:           `BackdropFilter` ≈ `Modifier.blur()` trên một
                      scrim trong Compose — blur layer dưới nó.
IMPORTANT DIFFERENCE: BackdropFilter đọc *pixels đã vẽ bên dưới*
                      — nó là hiệu ứng của LAYER, không phải thuộc
                      tính của widget. Đặt sai chỗ trong cây là mờ
                      sai vùng.
DO NOT ASSUME:        `HitTestBehavior.opaque` không phải "đục màu"
                      — nó chỉ nói "vùng trong suốt vẫn nhận hit".
                      `IgnorePointer` ≠ `Modifier.clickable{}` bỏ —
                      nó chặn tap cho CẢ subtree con.
```

## Senior project connection

| Senior (đọc được ở) | Learner port |
|---|---|
| `dialogs/game_dialog_layer.dart` → `_DialogBackdrop` | `ClipRect`+`BackdropFilter(σ=16)`+`ColoredBox(scrim)`+`Stack[Positioned.fill(GestureDetector opaque), SafeArea→Center→ConstrainedBox(375)]` — verbatim |
| `dialogs/game_dialog_shell.dart` | `_GameDialogCard` tối giản (title+body+actions) — gradient/sheen/SVG → **M28** |
| `dialogs/game_{confirm,help,result}_dialogs.dart` + `money/game_money_ladder_dialog.dart` | 9 view `Game*DialogView` — nội dung port từ `_GameDialogHost` M20, callback đổi sang tên senior |
| `app_design_tokens.dart` | `MenuTokens.dialogMotionLong/dialogHazeBlurSigma/dialogHazeScrim` (giá trị verbatim: 300ms / σ16 / transparent) |

## Build it step by step

### Bước 1 — Token dialog trong `MenuTokens`

Mở `lib/core/menu_tokens.dart`, **thêm** vào cuối class (trước `}`):

```dart
  // M21 — dialog layer (senior `AppTokens`): motion 300ms; blur σ16;
  // scrim trong suốt (0x00000000) — blur tự làm tối, senior cũng vậy.
  static const Duration dialogMotionLong = Duration(milliseconds: 300);
  static const double dialogHazeBlurSigma = 16;
  static const Color dialogHazeScrim = Color(0x00000000);
```

`designWidth` (375) đã có từ trước — tái dùng, không thêm.

### Bước 2 — `lib/widgets/game/game_dialog_views.dart` (FILE MỚI)

Port nguyên nội dung 9 dialog từ `_GameDialogHost` (M19–M20) sang
callback-style. File hoàn chỉnh — tạo mới với đúng nội dung sau:

```dart
/// View của từng variant [GameDialogState] — M21.
///
/// Nội dung giữ nguyên bản M19–M20 (message/option/progress/amount),
/// chỉ đổi "vỏ": `AlertDialog` trong route `showDialog` → card trong
/// cây widget (senior `GameDialogShell` có thêm gradient/sheen/SVG —
/// visual depth đó là M28, xem FR-32/FR-34).
///
/// Mỗi view nhận callback ĐÚNG tên senior (`onDismiss`/`onConfirm`/
/// `onCancel`/`onPlayAgain`/`onBackToMenu`) thay vì trả
/// `_GameDialogAction` qua `Navigator.pop` — không còn route để pop.
library;

import 'package:flutter/material.dart';

import '../../core/menu_tokens.dart';
import '../../data/game/game_session_state_data.dart';
import '../../l10n/app_localizations.dart';

/// Vỏ card chung — thay `AlertDialog` của bản route. Đúng vai trò
/// senior `GameDialogShell` (title bar + body), tối giản về visual.
class _GameDialogCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Widget content;
  final List<Widget> actions;

  const _GameDialogCard({
    required this.title,
    required this.titleColor,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(MenuTokens.spacingSm),
      decoration: BoxDecoration(
        color: MenuTokens.backgroundBottom,
        borderRadius: BorderRadius.circular(MenuTokens.radiusCard),
        border: Border.all(color: MenuTokens.cardBorder),
      ),
      padding: const EdgeInsets.all(MenuTokens.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: MenuTokens.spacingMd),
          Flexible(child: SingleChildScrollView(child: content)),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: MenuTokens.spacingMd),
            // Flexible: hai nút confirm không vượt bề rộng card
            // (AlertDialog cũ dùng OverflowBar làm việc này).
            Row(
              children: [
                for (final action in actions) Flexible(child: action),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
```

Chi tiết quan trọng trong shell:

- `Column(mainAxisSize: min)` — card co theo nội dung, không kéo
  full màn.
- `Flexible(child: SingleChildScrollView(child: content))` — nội dung
  dài (giải thích, thang 15 dòng) cuộn được trong giới hạn card.
- `Row` actions bọc `Flexible` — `AlertDialog` cũ có `OverflowBar`
  tự wrap; card thường không có, phải tự co (đây là bug overflow
  128px thật đã sửa trong implementation).

Tiếp tục **trong cùng file**, 9 view. Nội dung bên trong từng card
là *nguyên văn* phần body bạn đã viết trong `_GameDialogHost` M19–M20
— chỉ thay chữ ký: không còn `onAction(_GameDialogAction.x)`, thay
bằng callback đúng tên senior:

```dart
/// Thang tiền thưởng — intro (notStarted) lẫn mở giữa ván. NÚT "ĐÃ
/// HIỂU" là cách duy nhất đóng (senior chặn cả backdrop lẫn back).
class GameMoneyLadderDialogView extends StatelessWidget {
  final GameMoneyLadderDialog data;
  final VoidCallback onDismiss;

  const GameMoneyLadderDialogView({
    super.key,
    required this.data,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _GameDialogCard(
      title: l10n.moneyLadderTitle,
      titleColor: MenuTokens.accentCyan,
      content: SizedBox(
        width: 260,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in data.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${item.index}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: item.isCurrent
                              ? MenuTokens.accentCyan
                              : MenuTokens.textSecondary,
                          fontSize: 12,
                          fontWeight: item.isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: MenuTokens.spacingSm),
                    Expanded(
                      child: Text(
                        item.amount,
                        style: TextStyle(
                          color: item.isSpecial
                              ? MenuTokens.accentYellow
                              : MenuTokens.textPrimary,
                          fontSize: 13,
                          fontWeight: item.isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (item.isSpecial)
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: MenuTokens.accentYellow,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        _DialogTextButton(label: l10n.understandButton, onTap: onDismiss),
      ],
    );
  }
}

/// Xác nhận thoát — "Chơi tiếp" (cancel) | "Thoát trò chơi" (confirm).
class GameConfirmExitDialogView extends StatelessWidget {
  final GameConfirmExitDialog data;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const GameConfirmExitDialogView({
    super.key,
    required this.data,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _GameDialogCard(
      title: l10n.exitGameTitle,
      titleColor: MenuTokens.accentCyan,
      content: _ConfirmMessage(
        message: l10n.exitGameMessage,
        amount: data.guaranteedAmount,
      ),
      actions: [
        _DialogTextButton(
          label: l10n.continuePlayingButton,
          onTap: onCancel,
        ),
        _DialogTextButton(
          label: l10n.exitGameButton,
          color: MenuTokens.accentRed,
          onTap: onConfirm,
        ),
      ],
    );
  }
}
```

Hai view confirm/walk-away/explanation/poll/AI/ended/victory còn lại
đi cùng khuôn — **sao chép đúng nguyên tắc**: body giữ nguyên từ
`_GameDialogHost`, actions map callback:

| View | Body (giữ nguyên) | Actions |
|---|---|---|
| `GameConfirmWalkAwayDialogView` | `_ConfirmMessage(message: walkAwayMessage, amount: data.currentAmount)` | `keepPlayingButton`→`onCancel`, `confirmWalkAwayButton` đỏ→`onConfirm` |
| `GameExplanationDialogView` | cột: `data.question` + Row(bolt+`data.correctAnswer`) + Divider + `data.explanation` | `understandButton`→`onDismiss` |
| `GameAudiencePollDialogView` | `SizedBox(width:280)` + per-item Row(label 24w + `LinearProgressIndicator` + `item.percentage`) | `understandButton`→`onDismiss` |
| `GameAIAssistantDialogView` | `data.isLoading ? spinner+aiThinkingMessage : (chip selectedAnswer + '85%' + data.explanation)` | `isLoading` → `[]` (loading không nút — senior `_LoadingBody`) else `understandButton`→`onDismiss` |
| `GameEndedDialogView` | `_EarnedContent(youEarnedLabel, data.earnedAmount)` | `menuButton`→`onBackToMenu`, `playAgainButton`→`onPlayAgain` |
| `GameVictoryDialogView` | `_EarnedContent` + `data.affirmationMessage` | giống Ended |

Cuối file, 3 widget phụ dùng chung:

```dart
/// Message + số tiền — phần thân chung của hai dialog xác nhận.
class _ConfirmMessage extends StatelessWidget {
  final String message;
  final String amount;
  const _ConfirmMessage({required this.message, required this.amount});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(message, textAlign: TextAlign.center,
          style: const TextStyle(
              color: MenuTokens.textPrimary, fontSize: 14)),
      const SizedBox(height: MenuTokens.spacingSm),
      Text(amount,
          style: const TextStyle(
              color: MenuTokens.accentYellow,
              fontSize: 20,
              fontWeight: FontWeight.bold)),
    ],
  );
}

/// "Bạn nhận được $X" — dùng chung cho dialog thua/thắng.
class _EarnedContent extends StatelessWidget {
  final String label;
  final String amount;
  const _EarnedContent({required this.label, required this.amount});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label,
          style: const TextStyle(
              color: MenuTokens.textSecondary, fontSize: 13)),
      const SizedBox(height: MenuTokens.spacingXs),
      Text(amount,
          style: const TextStyle(
              color: MenuTokens.accentYellow,
              fontSize: 26,
              fontWeight: FontWeight.bold)),
    ],
  );
}

/// Nút text action — visual tối giản (senior `QzdsGameButton`
/// gradient → M28).
class _DialogTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _DialogTextButton({
    required this.label,
    required this.onTap,
    this.color = MenuTokens.accentCyan,
  });
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    child: Text(
      label.toUpperCase(),
      textAlign: TextAlign.center,
      style: TextStyle(
          color: color, fontWeight: FontWeight.bold, letterSpacing: 1.1),
    ),
  );
}
```

> File hoàn chỉnh ~670 dòng — nội dung bạn đã từng viết, chỉ là bóc
> ra khỏi host và đổi chữ ký callback. Nếu thiếu chi tiết nào, mở
> `_GameDialogHost` trong `game_screen.dart` hiện tại để đối chiếu
> body — nó sẽ bị xóa ở Bài 4.

### Bước 3 — `lib/widgets/game/game_dialog_layer.dart` (FILE MỚI, skeleton)

Bản skeleton: đúng thứ tự `Positioned.fill` → `IgnorePointer` →
backdrop → view, **chưa** có `AnimatedSwitcher` (Bài 3 thêm).
Đây là intermediate-state có chủ đích — học xương trước, motion sau.

```dart
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/menu_tokens.dart';
import '../../data/game/game_session_state_data.dart';
import 'game_dialog_views.dart';

/// Lớp dialog trong `Stack` — M21, senior `game_dialog_layer.dart`.
/// Skeleton Bài 2: mount đúng, CHƯA animate (Bài 3 thêm
/// AnimatedSwitcher + ValueKey + transitionBuilder).
class GameDialogLayer extends StatelessWidget {
  final GameDialogState dialog;
  final VoidCallback onDismiss;
  final VoidCallback onConfirmWalkAway;
  final VoidCallback onBackToMenu;
  final VoidCallback onPlayAgain;

  const GameDialogLayer({
    super.key,
    required this.dialog,
    required this.onDismiss,
    required this.onConfirmWalkAway,
    required this.onBackToMenu,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final canDismissFromBackdrop = _canDismissFromBackdrop(dialog);
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: dialog is GameDialogHidden,
        child: dialog is GameDialogHidden
            ? const SizedBox.shrink()
            : _DialogBackdrop(
                onDismiss:
                    canDismissFromBackdrop ? onDismiss : () {},
                child: _dialogBody(),
              ),
      ),
    );
  }

  /// Tap nền chỉ dismiss được dialog "xem thêm/xác nhận" — senior
  /// `_canDismissFromBackdrop`: thang tiền (phải bấm nút) và dialog
  /// kết thúc (bắt buộc chọn hành động) chặn tap-outside.
  bool _canDismissFromBackdrop(GameDialogState dialog) {
    return dialog is! GameMoneyLadderDialog && !_isTerminalDialog(dialog);
  }

  bool _isTerminalDialog(GameDialogState dialog) {
    return dialog is GameEndedDialog || dialog is GameVictoryDialog;
  }

  /// Map variant → view — exhaustive switch, mọi variant non-hidden
  /// đều có widget riêng (senior `_dialogBody`).
  Widget _dialogBody() {
    return switch (dialog) {
      GameDialogHidden() => const SizedBox.shrink(),
      GameMoneyLadderDialog() => GameMoneyLadderDialogView(
        data: dialog as GameMoneyLadderDialog,
        onDismiss: onDismiss,
      ),
      GameConfirmExitDialog() => GameConfirmExitDialogView(
        data: dialog as GameConfirmExitDialog,
        onConfirm: onBackToMenu,
        onCancel: onDismiss,
      ),
      GameConfirmWalkAwayDialog() => GameConfirmWalkAwayDialogView(
        data: dialog as GameConfirmWalkAwayDialog,
        onConfirm: onConfirmWalkAway,
        onCancel: onDismiss,
      ),
      GameExplanationDialog() => GameExplanationDialogView(
        data: dialog as GameExplanationDialog,
        onDismiss: onDismiss,
      ),
      GameAudiencePollDialog() => GameAudiencePollDialogView(
        data: dialog as GameAudiencePollDialog,
        onDismiss: onDismiss,
      ),
      GameAIAssistantDialog() => GameAIAssistantDialogView(
        data: dialog as GameAIAssistantDialog,
        onDismiss: onDismiss,
      ),
      GameEndedDialog() => GameEndedDialogView(
        data: dialog as GameEndedDialog,
        onPlayAgain: onPlayAgain,
        onBackToMenu: onBackToMenu,
      ),
      GameVictoryDialog() => GameVictoryDialogView(
        data: dialog as GameVictoryDialog,
        onPlayAgain: onPlayAgain,
        onBackToMenu: onBackToMenu,
      ),
    };
  }
}
```

Chi tiết quan trọng:

- `switch` là **kiệt hợp trên sealed** — Dart bắt buộc đủ arm; quên
  variant nào = compile error. Đó là lý do "9 variant" không thể
  lặng lẽ hỏng.
- `GameConfirmExitDialogView.onConfirm` nhận `onBackToMenu` — nút
  "THOÁT TRÒ CHƠI" trong confirm-exit = về menu (đúng semantics
  senior; hàm `_afterExit` của Bài 4 lo phần choreography).
- `onDismiss` truyền vào backdrop chỉ khi `canDismissFromBackdrop` —
  không thì truyền `() {}`: GestureDetector vẫn *nuốt* tap (không
  xuyên xuống game) nhưng không làm gì.

### Bước 4 — `_DialogBackdrop` (cuối cùng file layer)

```dart
/// Backdrop của senior: `ClipRect` giới hạn blur trong màn hình +
/// `BackdropFilter` làm mờ nội dung game phía dưới + scrim +
/// `GestureDetector` opaque nhận tap-outside + card căn giữa theo
/// `DesignFrame` (ConstrainedBox theo `designWidth`).
class _DialogBackdrop extends StatelessWidget {
  final Widget child;
  final VoidCallback onDismiss;

  const _DialogBackdrop({required this.child, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        key: const ValueKey('game-dialog-backdrop-filter'),
        filter: ImageFilter.blur(
          sigmaX: MenuTokens.dialogHazeBlurSigma,
          sigmaY: MenuTokens.dialogHazeBlurSigma,
        ),
        child: ColoredBox(
          color: MenuTokens.dialogHazeScrim,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  // opaque: vùng "vô hình" vẫn nhận tap — nếu không,
                  // tap xuyên qua vùng trống xuống nút/đáp án bên dưới.
                  behavior: HitTestBehavior.opaque,
                  onTap: onDismiss,
                ),
              ),
              SafeArea(
                minimum: const EdgeInsets.symmetric(
                  vertical: MenuTokens.spacingLg,
                ),
                child: Center(
                  // Senior `DesignFrame`: giới hạn card theo design
                  // width để màn rộng (tablet/web) không kéo giãn.
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: MenuTokens.designWidth,
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Đọc đúng thứ tự paint: `ClipRect` bọc ngoài (blur không tràn) →
`BackdropFilter` (làm mờ pixels dưới) → `ColoredBox` scrim (senior
để transparent — blur tự làm tối) → `Stack[GestureDetector full-màn,
card căn giữa]`. GestureDetector đứng TRƯỚC card trong `children`
nên card hit-test trước — tap vào nút/card không bị coi là tap nền.

### Bước 5 — Test đầu tiên của layer (FILE MỚI)

`test/widgets/game_dialog_layer_test.dart` — layer được test độc
lập với game screen: pump một `_TestSurface` chứa `Stack[black,
GameDialogLayer]` rồi đổi `dialog` prop (mô phỏng VM đổi state).

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_millionaire_course/core/menu_tokens.dart';
import 'package:ai_millionaire_course/data/game/game_session_state_data.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:ai_millionaire_course/widgets/game/game_dialog_layer.dart';

/// Widget test riêng cho `GameDialogLayer` — M21, model theo senior
/// `test/widgets/game_dialog_layer_test.dart`: surface tối thiểu,
/// `dialog` là prop — đổi prop = mô phỏng VM đổi `dialogState`.
void main() {
  testWidgets('tap ngoài KHÔNG đóng thang tiền (phải bấm nút)', (
    tester,
  ) async {
    var dismissCount = 0;
    await _pumpTestSurface(
      tester,
      _TestSurface(
        dialog: _moneyLadderDialog,
        onDismiss: () => dismissCount++,
      ),
    );

    await tester.pump(MenuTokens.dialogMotionLong);
    await tester.tapAt(const Offset(8, 8));
    await tester.pump();
    expect(dismissCount, 0);
    expect(find.text('Thang tiền thưởng'), findsOneWidget);
  });

  testWidgets('tap ngoài VẪN đóng dialog confirm-exit', (tester) async {
    var dismissCount = 0;
    await _pumpTestSurface(
      tester,
      _TestSurface(
        dialog: const GameConfirmExitDialog(guaranteedAmount: r'$0'),
        onDismiss: () => dismissCount++,
      ),
    );

    await tester.pump(MenuTokens.dialogMotionLong);
    await tester.tapAt(const Offset(8, 8));
    await tester.pump();
    expect(dismissCount, 1);
  });

  testWidgets('nút ĐÃ HIỂU của thang tiền gọi onDismiss', (tester) async {
    var dismissCount = 0;
    await _pumpTestSurface(
      tester,
      _TestSurface(
        dialog: _moneyLadderDialog,
        onDismiss: () => dismissCount++,
      ),
    );

    await tester.pump(MenuTokens.dialogMotionLong);
    await tester.tap(find.text('ĐÃ HIỂU'));
    await tester.pump();
    expect(dismissCount, 1);
  });
}

Future<void> _pumpTestSurface(WidgetTester tester, _TestSurface surface) {
  tester.view.physicalSize = const Size(MenuTokens.designWidth, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  return tester.pumpWidget(surface);
}

const _moneyLadderDialog = GameMoneyLadderDialog(
  items: [
    GameMoneyLadderItemData(
      index: 15,
      amount: r'$1,000,000',
      isCurrent: false,
      isSpecial: true,
    ),
    GameMoneyLadderItemData(
      index: 1,
      amount: r'$1,000',
      isCurrent: true,
      isSpecial: false,
    ),
  ],
);

/// Bề mặt test tối thiểu — `Stack` + `GameDialogLayer`, pump lại với
/// `dialog` khác = mô phỏng VM đổi `dialogState` (senior `_TestSurface`).
class _TestSurface extends StatelessWidget {
  final GameDialogState dialog;
  final VoidCallback? onDismiss;
  final bool disableAnimations;

  const _TestSurface({
    required this.dialog,
    this.onDismiss,
    this.disableAnimations = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: SizedBox(
          width: MenuTokens.designWidth,
          height: 812,
          child: Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: Colors.black)),
              GameDialogLayer(
                dialog: dialog,
                onDismiss: onDismiss ?? () {},
                onConfirmWalkAway: () {},
                onBackToMenu: () {},
                onPlayAgain: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Hai điểm mới trong test:

- `tester.view.physicalSize` + `devicePixelRatio = 1` — đặt màn ảo
  đúng 375×812 logical (senior test cũng làm vậy — kiểm layout theo
  design width thật).
- `tapAt(Offset(8,8))` — tap GÓC MÀN = nền, không trúng card. Đây là
  cách test "tap outside" mà không cần biết tọa độ card.
- `await tester.pump(MenuTokens.dialogMotionLong)` sau mỗi
  `_pumpTestSurface` — "settle" đợi xong entry-motion. Bài 2 skeleton
  chưa animate nên pump này chưa đổi gì; viết sẵn từ giờ để file test
  không phải sửa lại khi Bài 3 thêm `AnimatedSwitcher`.

## Chạy và quan sát

```bash
flutter analyze   # phải sạch — 2 file mới chưa ai import vẫn compile
flutter test      # 150/150 (147 cũ + 3 layer)
```

Layer chưa hiện trong app — đúng, nó chưa được mount. Test mới là
bằng chứng layer tự render + đúng luật tap-outside.

## Thử nghiệm — đoán trước khi chạy

:::note[PREDICT]
Bỏ `IgnorePointer` khỏi skeleton layer, giữ `SizedBox.shrink()` khi
Hidden. Game chạy bình thường hay không? Tap đáp án có ăn không?
:::

<details><summary>Đáp án</summary>

VẪN ăn — `SizedBox.shrink()` không chiếm diện tích nên không có gì
nuốt tap. `IgnorePointer` chỉ *thật sự* cần khi child có kích thước
(ta sẽ đổi thành `SizedBox.expand` ở Bài 3 để AnimatedSwitcher có
child full-size cho transition). Nhưng để `IgnorePointer` ngay từ
giờ là đúng senior: lớp này luôn "có khả năng chặn", chỉ state quyết
định khi nào nó chặn.

</details>

## Lỗi hay gặp

- **`BackdropFilter` tràn blur ra ngoài** — quên `ClipRect` bọc
  ngoài; blur vẽ theo layer boundary, không phải widget boundary.
- **Tap nền không ăn** — `GestureDetector` mặc định `deferToChild`:
  vùng trong suốt không hit được. Phải `HitTestBehavior.opaque`.
- **`Row` actions tràn ngang** — `AlertDialog` cũ có `OverflowBar`;
  card thường không → bọc `Flexible` cho mỗi nút.

## Tự làm (MODIFY)

:::note[Bài tập]
Thêm `onDismiss`-callback-counter vào `_TestSurface` của test 2 và
verify: tap vào *card* (không phải nền) **không** gọi `onDismiss`.
Đổi `_canDismissFromBackdrop` cho `ConfirmExit` thành non-dismissable,
chạy test — kỳ vọng gì? Revert lại sau khi thấy.
:::

<details><summary>Đáp án</summary>

Tap card → `dismissCount` vẫn 0: card là child SAU GestureDetector
trong Stack → hit-test trước, `onTap` của nút/card nuốt sự kiện.
Sau khi sửa rule (ConfirmExit không dismissable), test 2 fail
(`expect(dismissCount, 1)` nhận 0) — đúng như kỳ vọng: rule được
test ở layer, không cần VM. Revert.

</details>

## Kiểm tra hiểu biết

1. Vì sao `_DialogBackdrop` đặt `GestureDetector` TRƯỚC card trong
   `Stack.children`? *(Con sau hit-test trước — card/nút nhận tap
   trước backdrop.)*
2. `_canDismissFromBackdrop` trả `false` cho `GameEndedDialog` —
   vì sao? *(Terminal dialog bắt buộc chọn MENU/CHƠI LẠI —
   tap-outside không được "bỏ qua" quyết định.)*
3. Khi `Hidden`, skeleton trả `SizedBox.shrink()` thay vì backdrop —
   vì sao? *(Không có gì để hiển thị; cũng tránh BackdropFilter blur
   vô nghĩa mỗi frame.)*

## Ta cố ý chưa thêm

- `AnimatedSwitcher`/`ValueKey`/transition — **Bài 3** (skeleton
  swap thô, giúp thấy rõ layer-mount trước).
- Mount vào `game_screen.dart` + xóa scaffold — **Bài 4**.
- `MediaQuery.disableAnimations` — **Bài 3** cùng animation.
- `GameDialogShell` chrome (gradient/sheen/Qzds button) — M28.

## Checkpoint hoàn thành

- [ ] `flutter analyze` sạch.
- [ ] `flutter test` **150/150** (147 + 3 layer tests mới).
- [ ] `game_dialog_views.dart` + `game_dialog_layer.dart` tồn tại,
  compile; `game_screen.dart` chưa đổi (vẫn scaffold `showDialog`).
