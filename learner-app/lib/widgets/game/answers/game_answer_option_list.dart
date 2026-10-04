import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_screen_data.dart';
import 'game_answer_option.dart';

class GameAnswerOptionList extends StatefulWidget {
  final int questionIndex;
  final List<GameAnswerOptionData> answers;
  final ValueChanged<GameAnswerOptionData> onAnswerTap;

  const GameAnswerOptionList({
    super.key,
    required this.questionIndex,
    required this.answers,
    required this.onAnswerTap,
  });

  @override
  State<GameAnswerOptionList> createState() => _GameAnswerOptionListState();
}

class _GameAnswerOptionListState extends State<GameAnswerOptionList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTokens.motionSlow,
    )..forward();
  }

  @override
  void didUpdateWidget(covariant GameAnswerOptionList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.questionIndex != widget.questionIndex) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.answers.length, (index) {
        final answer = widget.answers[index];
        final start = math.min(index * 0.1, 0.4);
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, 1, curve: Curves.easeOutCubic),
        );

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == widget.answers.length - 1
                ? 0
                : AppTokens.spacingSm,
          ),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final value = animation.value;

              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1 - value)),
                  child: Transform.scale(
                    scale: 0.98 + (0.02 * value),
                    child: child,
                  ),
                ),
              );
            },
            child: GameAnswerOption(
              data: answer,
              onTap: () => widget.onAnswerTap(answer),
            ),
          ),
        );
      }),
    );
  }
}
