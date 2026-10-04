import 'package:ai_millionaire_course/data/game/game_session_state_data.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_dialog_state.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_screen_ui_event.dart';
import 'package:flutter_test/flutter_test.dart';

/// M15 — sealed hierarchy behavior tests: variants carry payloads and
/// exhaustive `switch` over a sealed class covers the whole family.
/// M19: `GameDialogState` mở rộng theo senior — 6 variant (thêm thang
/// tiền, xác nhận thoát, giải thích); `GameEndedDialog`/`GameVictoryDialog`
/// giờ mang `earnedAmount` thay `GameEndReason`. M20: +3 variant
/// lifeline (`GameConfirmWalkAwayDialog`, `GameAudiencePollDialog`,
/// `GameAIAssistantDialog`) — đủ 9 của senior.
void main() {
  group('MenuScreenUiEvent (sealed) — 2 variant (M29, FR-29)', () {
    test('switch kiệt hợp xử lý mọi variant của event', () {
      // Exhaustive switch statement — compiler từ chối nếu thiếu case.
      // M29: dialog mở/đóng lái bằng `MenuDialogState` (không qua
      // event một-lần) nên family chỉ còn đúng 2 variant senior.
      String describe(MenuScreenUiEvent event) {
        return switch (event) {
          MenuGameRequested() => 'game',
          MenuSnackBarRequested() => 'snackbar',
        };
      }

      expect(describe(const MenuGameRequested()), 'game');
      expect(describe(const MenuSnackBarRequested('hi')), 'snackbar');

      // Variant mang payload — message đi qua intact.
      expect(const MenuSnackBarRequested('xin chào').message, 'xin chào');
    });
  });

  group('MenuDialogState (sealed) — 5 variant (M29, FR-29)', () {
    test('switch kiệt hợp + isVisible + transitionKey', () {
      // `isVisible` đúng senior: mọi variant khác `MenuDialogNone`.
      // `transitionKey` = runtimeType — AnimatedSwitcher của
      // `MenuDialogLayer` đổi key → animate theo variant.
      String label(MenuDialogState state) {
        return switch (state) {
          MenuDialogNone() => 'none',
          MenuDialogLeaderboard() => 'leaderboard',
          MenuDialogSettings() => 'settings',
          MenuDialogAuth() => 'auth',
          MenuDialogSignOut() => 'sign-out',
        };
      }

      const states = <MenuDialogState>[
        MenuDialogNone(),
        MenuDialogLeaderboard(),
        MenuDialogSettings(),
        MenuDialogAuth(),
        MenuDialogSignOut(),
      ];

      expect(states.map(label), [
        'none',
        'leaderboard',
        'settings',
        'auth',
        'sign-out',
      ]);
      expect(states.map((s) => s.isVisible), [
        false,
        true,
        true,
        true,
        true,
      ]);
    });
  });

  group('GameDialogState (sealed) — 9 variant (M19 + lifelines M20)', () {
    test('GameEndedDialog / GameVictoryDialog mang earnedAmount', () {
      const ended = GameEndedDialog(earnedAmount: r'$20,000');
      const victory = GameVictoryDialog(
        earnedAmount: r'$1,000,000',
        affirmationMessage: 'msg',
      );
      expect(ended.earnedAmount, r'$20,000');
      expect(victory.earnedAmount, r'$1,000,000');
    });

    test('switch kiệt hợp phân biệt đủ 9 variant dialog', () {
      // Cùng shape với `_title`/`_content` trong game_screen.dart —
      // thiếu một case là lỗi biên dịch (kiệt hợp của sealed).
      String label(GameDialogState state) {
        return switch (state) {
          GameDialogHidden() => 'hidden',
          GameMoneyLadderDialog() => 'ladder',
          GameConfirmExitDialog() => 'confirm-exit',
          GameConfirmWalkAwayDialog() => 'confirm-walk-away',
          GameExplanationDialog() => 'explanation',
          GameAudiencePollDialog() => 'audience-poll',
          GameAIAssistantDialog() => 'ai-assistant',
          GameEndedDialog() => 'ended',
          GameVictoryDialog() => 'victory',
        };
      }

      expect(label(const GameDialogHidden()), 'hidden');
      expect(
        label(const GameMoneyLadderDialog(items: [])),
        'ladder',
      );
      expect(
        label(const GameConfirmExitDialog(guaranteedAmount: r'$0')),
        'confirm-exit',
      );
      expect(
        label(const GameConfirmWalkAwayDialog(currentAmount: r'$0')),
        'confirm-walk-away',
      );
      expect(
        label(
          const GameExplanationDialog(
            question: 'q',
            correctAnswer: 'a',
            explanation: 'e',
            isCorrect: true,
          ),
        ),
        'explanation',
      );
      expect(
        label(const GameAudiencePollDialog(items: [])),
        'audience-poll',
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
      expect(
        label(const GameEndedDialog(earnedAmount: r'$0')),
        'ended',
      );
      expect(
        label(
          const GameVictoryDialog(
            earnedAmount: r'$1,000,000',
            affirmationMessage: 'x',
          ),
        ),
        'victory',
      );
    });

    test('victory là variant riêng — `is` trên sealed phân biệt được',
        () {
      bool isVictory(GameDialogState state) => state is GameVictoryDialog;
      const GameDialogState state = GameVictoryDialog(
        earnedAmount: r'$0',
        affirmationMessage: 'x',
      );
      expect(isVictory(state), isTrue);
      expect(state is GameEndedDialog, isFalse);
    });
  });
}
