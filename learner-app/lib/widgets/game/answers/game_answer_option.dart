import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_screen_data.dart';
import '../../../l10n/app_localizations.dart';
import 'game_answer_option_colors.dart';

const _answerRevealBlinkKey = ValueKey<String>('game-answer-reveal-blink');
const _answerRevealBlinkDuration = Duration(milliseconds: 1200);
const _answerRevealBlinkVisiblePortion = 0.42;

class GameAnswerOption extends StatelessWidget {
  final GameAnswerOptionData data;
  final VoidCallback? onTap;

  const GameAnswerOption({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = GameAnswerOptionColors.fromState(data.state);
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final effectiveOnTap = data.answerLabel.isEmpty || data.answerText.isEmpty
        ? null
        : onTap;

    return Semantics(
      container: true,
      button: true,
      enabled: effectiveOnTap != null,
      label: l10n.optionSemanticLabel(data.answerLabel, data.answerText),
      value: _stateLabel(data.state, l10n),
      liveRegion: data.state != GameAnswerState.idle,
      onTap: effectiveOnTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: effectiveOnTap,
          child: TweenAnimationBuilder<double>(
            key: ValueKey(
              '${data.answerLabel}:${data.answerText}:${data.state}',
            ),
            tween: Tween(
              begin: 0,
              end: _shouldBlink && !disableAnimations ? 1 : 0,
            ),
            duration: _shouldBlink && !disableAnimations
                ? _answerRevealBlinkDuration
                : Duration.zero,
            builder: (context, progress, child) {
              final blinkOpacity = _blinkOpacity(progress);
              return Stack(
                children: [
                  child!,
                  if (blinkOpacity > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          key: _answerRevealBlinkKey,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppTokens.radiusN,
                            ),
                            color: Colors.white.withValues(alpha: blinkOpacity),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
            child: AnimatedContainer(
              duration: disableAnimations
                  ? Duration.zero
                  : AppTokens.motionMedium,
              curve: Curves.easeOutCubic,
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 58),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.spacingXl,
                vertical: AppTokens.spacingSm,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTokens.radiusN),
                color: colors.background,
                border: Border.all(color: colors.border),
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      data.answerLabel,
                      textAlign: TextAlign.center,
                      style: _answerTextStyle(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 44),
                    child: Text(
                      data.answerText,
                      textAlign: TextAlign.center,
                      style: _answerTextStyle(),
                    ),
                  ),
                  if (_showsAudienceBadge)
                    Positioned(
                      right: -AppTokens.spacingMd,
                      top: -AppTokens.spacingXs,
                      child: _AudienceBadge(value: data.audiencePercentile!),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _showsAudienceBadge {
    return data.audiencePercentile != null && data.answerText.isNotEmpty;
  }

  bool get _shouldBlink => data.state == GameAnswerState.correct;

  double _blinkOpacity(double progress) {
    if (!_shouldBlink ||
        progress <= 0 ||
        progress >= _answerRevealBlinkVisiblePortion) {
      return 0;
    }
    final visibleProgress = progress / _answerRevealBlinkVisiblePortion;
    final pulse = math.sin(visibleProgress * math.pi);
    return pulse * 0.34;
  }

  TextStyle _answerTextStyle() {
    return AppTokens.body4.copyWith(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.35,
    );
  }

  String? _stateLabel(GameAnswerState state, AppLocalizations l10n) {
    return switch (state) {
      GameAnswerState.idle => null,
      GameAnswerState.selected => l10n.selectedStateLabel,
      GameAnswerState.correct => l10n.correctStateLabel,
      GameAnswerState.incorrect => l10n.incorrectStateLabel,
    };
  }
}

class _AudienceBadge extends StatelessWidget {
  final int value;

  const _AudienceBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusN),
        gradient: const LinearGradient(
          colors: [AppTokens.blue500, AppTokens.mint500],
        ),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacingSm,
          vertical: AppTokens.spacingXs,
        ),
        child: Text(
          '$value%',
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
}
