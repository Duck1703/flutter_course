import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_screen_data.dart';

class GameQuestionPanel extends StatelessWidget {
  final GameQuestionData data;

  const GameQuestionPanel({super.key, required this.data});

  static const double _panelMinHeight = 140;
  static const double _panelBorderWidth = 2;
  static const double _badgeBorderWidth = 2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppTokens.spacingMd,
        bottom: AppTokens.spacingMd,
        left: AppTokens.spacingZero,
        right: AppTokens.spacingZero,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.spacingLg),
            child: _buildQuestionSurface(context),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildCountBadge()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSurface(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('game-question-surface'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        gradient: AppTokens.gameQuestionStrokeGradient,
        boxShadow: const [
          BoxShadow(color: Color(0x80000000), blurRadius: AppTokens.spacingSm),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(_panelBorderWidth),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: _panelMinHeight),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(AppTokens.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppTokens.radiusLg - _panelBorderWidth,
            ),
            gradient: AppTokens.gameQuestionGradient,
          ),
          child: _buildQuestionText(context),
        ),
      ),
    );
  }

  Widget _buildQuestionText(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : AppTokens.motionSlow;

    return AnimatedSwitcher(
      duration: duration,
      child: SizedBox(
        key: ValueKey('${data.currentQuestionIndex}-${data.questionText}'),
        width: double.infinity,
        child: Text(
          data.questionText,
          textAlign: TextAlign.center,
          style: AppTokens.body4.copyWith(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _buildCountBadge() {
    return Container(
      key: const ValueKey('game-question-count-badge'),
      padding: const EdgeInsets.all(_badgeBorderWidth),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radius4),
        gradient: AppTokens.gameQuestionBadgeStrokeGradient,
        boxShadow: const [
          BoxShadow(color: Color(0x1AFFFFFF), blurRadius: AppTokens.spacingSm),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacingSm,
          vertical: AppTokens.spacingXs,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AppTokens.radius4 - _badgeBorderWidth,
          ),
          gradient: AppTokens.gameQuestionBadgeGradient,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _lightningIcon(),
            const SizedBox(width: AppTokens.spacingXs),
            Text(
              '${data.displayQuestionNumber}/${data.totalQuestions}',
              style: AppTokens.body4.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(width: AppTokens.spacingXs),
            _lightningIcon(),
          ],
        ),
      ),
    );
  }

  Widget _lightningIcon() {
    return SvgPicture.asset(
      AppAssets.iconGameLightning,
      width: AppTokens.iconLg,
      height: AppTokens.iconLg,
      colorFilter: const ColorFilter.mode(AppTokens.yellow600, BlendMode.srcIn),
    );
  }
}
