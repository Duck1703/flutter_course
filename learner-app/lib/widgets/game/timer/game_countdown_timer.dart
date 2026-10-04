import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_screen_data.dart';
import '../../../l10n/app_localizations.dart';

part 'game_countdown_timer_progress_painter.dart';

const double _minWidth = 120;
const double _verticalPadding = 10;
const double _horizontalPadding = 40;
const double _strokeWidth = 4;
const double _pulseMaxScale = 1.08;
const Duration _progressAnimationDuration = Duration(seconds: 1);
const Color _warningColor = Color(0xFFFFC107);
const Color _criticalColor = Color(0xFFF44336);
const Key _criticalPulseKey = ValueKey('game-countdown-timer-pulse');
const List<Color> _normalBorderColors = [
  Color(0x1AFFFFFF),
  Colors.white,
  Color(0x80FFFFFF),
];
const List<Color> _warningBorderColors = [
  Color(0x33FFC107),
  _warningColor,
  Color(0x80FFC107),
];
const List<Color> _criticalBorderColors = [
  Color(0x4DF44336),
  _criticalColor,
  Color(0x99F44336),
];

class GameCountdownTimer extends StatefulWidget {
  final GameTimerData data;
  const GameCountdownTimer({super.key, required this.data});
  @override
  State<GameCountdownTimer> createState() => _GameCountdownTimerState();
}

class _GameCountdownTimerState extends State<GameCountdownTimer>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: AppTokens.motionSlow,
    lowerBound: 1,
    upperBound: _pulseMaxScale,
  );
  late final AnimationController _progressController = AnimationController(
    vsync: this,
    duration: _progressAnimationDuration,
  )..addListener(_updateAnimatedProgress);
  Animation<double>? _progressAnimation;
  double _animatedProgress = 0;

  bool get _isCritical => widget.data.progress <= 0.2;

  @override
  void initState() {
    super.initState();
    _animatedProgress = widget.data.progress;
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant GameCountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncProgress(oldWidget.data);
    _syncPulse();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = widget.data.progress;
    final timer = CustomPaint(
      foregroundPainter: _PillProgressPainter(
        progress: _animatedProgress,
        colors: _borderColors(_animatedProgress),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTokens.white10,
          borderRadius: BorderRadius.circular(AppTokens.radiusN),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: _minWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: _verticalPadding,
              horizontal: _horizontalPadding,
            ),
            child: AnimatedDefaultTextStyle(
              duration: AppTokens.motionMedium,
              style: AppTokens.body4.copyWith(
                color: _timerColor(progress),
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
              child: Text(widget.data.formattedTime),
            ),
          ),
        ),
      ),
    );
    return Semantics(
      container: true,
      label: l10n.timeRemainingSemanticLabel(widget.data.formattedTime),
      child: _isCritical
          ? ScaleTransition(
              key: _criticalPulseKey,
              scale: _pulseController,
              child: timer,
            )
          : timer,
    );
  }

  void _syncPulse() {
    if (_isCritical) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController
        ..stop()
        ..value = 1;
    }
  }

  void _syncProgress(GameTimerData oldData) {
    final targetProgress = widget.data.progress;

    if (oldData.totalTime == widget.data.totalTime &&
        oldData.remainingTime == widget.data.remainingTime) {
      return;
    }

    if (oldData.totalTime != widget.data.totalTime ||
        targetProgress >= _animatedProgress) {
      _progressController.stop();
      _progressAnimation = null;
      _animatedProgress = targetProgress;
      return;
    }

    _progressAnimation = Tween<double>(
      begin: _animatedProgress,
      end: targetProgress,
    ).animate(_progressController);
    _progressController
      ..value = 0
      ..forward();
  }

  void _updateAnimatedProgress() {
    final animation = _progressAnimation;

    if (animation == null) {
      return;
    }

    setState(() {
      _animatedProgress = animation.value;
    });
  }
}

Color _timerColor(double progress) => progress <= 0.2
    ? _criticalColor
    : (progress <= 0.4 ? _warningColor : Colors.white);

List<Color> _borderColors(double progress) => progress <= 0.2
    ? _criticalBorderColors
    : (progress <= 0.4 ? _warningBorderColors : _normalBorderColors);
