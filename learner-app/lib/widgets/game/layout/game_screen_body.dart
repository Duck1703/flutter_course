import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_screen_data.dart';
import '../../common/design_frame.dart';
import '../answers/game_answer_option_list.dart';
import '../money/game_money_amount.dart';
import '../questions/game_question_panel.dart';

class GameScreenBody extends StatelessWidget {
  final GameScreenData data;
  final List<GameAnswerOptionData> answers;
  final VoidCallback onMoneyAmountTap;
  final ValueChanged<GameAnswerOptionData> onAnswerTap;

  const GameScreenBody({
    super.key,
    required this.data,
    required this.answers,
    required this.onMoneyAmountTap,
    required this.onAnswerTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppTokens.spacingSm),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: DesignFrame(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.spacingMd,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GameMoneyAmount(
                          data: data.money,
                          onTap: onMoneyAmountTap,
                        ),
                        GameQuestionPanel(data: data.question),
                        GameAnswerOptionList(
                          questionIndex: data.question.currentQuestionIndex,
                          answers: answers,
                          onAnswerTap: onAnswerTap,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
