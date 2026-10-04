import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/game/game_screen_data.dart';
import '../../../l10n/app_localizations.dart';

class GameFeatureButton extends StatefulWidget {
  final GameFeatureButtonData data;
  final VoidCallback? onPressed;

  const GameFeatureButton({super.key, required this.data, this.onPressed});

  @override
  State<GameFeatureButton> createState() => _GameFeatureButtonState();
}

class _GameFeatureButtonState extends State<GameFeatureButton>
    with TickerProviderStateMixin {
  static const _buttonSize = 48.0;
  static const _stateMotion = Duration(milliseconds: 200);
  static const _gradientRotation = Duration(milliseconds: 9000);
  static const _rippleMotion = Duration(milliseconds: 520);
  static const _disabledGradientAlpha = 0.3;

  late final AnimationController _gradientController;
  late final AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: _gradientRotation,
    );
    _rippleController = AnimationController(
      vsync: this,
      duration: _rippleMotion,
    );
    _syncGradientAnimation();
  }

  @override
  void didUpdateWidget(covariant GameFeatureButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncGradientAnimation();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final effectiveOnPressed = widget.data.isEnabled ? widget.onPressed : null;

    return Semantics(
      button: true,
      enabled: effectiveOnPressed != null,
      label: _semanticLabel(l10n),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: effectiveOnPressed == null
            ? null
            : () {
                _rippleController.forward(from: 0);
                effectiveOnPressed();
              },
        child: AnimatedOpacity(
          duration: _stateMotion,
          opacity: widget.data.isEnabled ? 1 : 0.38,
          child: AnimatedScale(
            duration: _stateMotion,
            scale: widget.data.isEnabled ? 1 : 0.94,
            child: SizedBox.square(
              dimension: _buttonSize,
              child: ClipOval(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _gradientController,
                    _rippleController,
                  ]),
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _GameFeatureButtonPainter(
                        colors: _gradientColors,
                        rotation: widget.data.isEnabled
                            ? _gradientController.value * math.pi * 2
                            : 0,
                        rippleProgress: _rippleController.value,
                      ),
                      child: child,
                    );
                  },
                  child: Center(
                    child: SvgPicture.asset(
                      widget.data.iconAsset,
                      width: AppTokens.iconLg,
                      height: AppTokens.iconLg,
                      excludeFromSemantics: true,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticLabel(AppLocalizations l10n) {
    return switch (widget.data.type) {
      GameFeatureButtonType.fiftyFifty => l10n.fiftyFiftySemanticLabel,
      GameFeatureButtonType.audiencePoll => l10n.askAudienceSemanticLabel,
      GameFeatureButtonType.aiAssistant => l10n.askAiSemanticLabel,
      GameFeatureButtonType.walkAway => l10n.walkAwaySemanticLabel,
      GameFeatureButtonType.exitGame => l10n.exitGameSemanticLabel,
    };
  }

  List<Color> get _gradientColors {
    final colors = switch (widget.data.type) {
      GameFeatureButtonType.walkAway || GameFeatureButtonType.exitGame =>
        const [AppTokens.red700, AppTokens.red500],
      _ => AppTokens.gameLifelineGradient.colors,
    };

    if (widget.data.isEnabled) {
      return colors;
    }

    return colors
        .map((color) => color.withValues(alpha: _disabledGradientAlpha))
        .toList(growable: false);
  }

  void _syncGradientAnimation() {
    if (widget.data.isEnabled) {
      if (!_gradientController.isAnimating) _gradientController.repeat();
      return;
    }

    _gradientController
      ..stop()
      ..value = 0;
    _rippleController.reset();
  }
}

class _GameFeatureButtonPainter extends CustomPainter {
  final List<Color> colors;
  final double rotation;
  final double rippleProgress;

  const _GameFeatureButtonPainter({
    required this.colors,
    required this.rotation,
    required this.rippleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final direction = Offset(math.cos(rotation), math.sin(rotation));
    final start = center + direction * radius;
    final end = center - direction * radius;

    canvas.drawCircle(
      center,
      radius,
      Paint()..shader = ui.Gradient.linear(start, end, colors),
    );

    for (var index = 0; index < 2; index++) {
      final delay = index * 0.22;
      final wave = ((rippleProgress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (wave <= 0 || wave >= 1) {
        continue;
      }

      canvas.drawCircle(
        center,
        radius * wave,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.5 * (1 - wave)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GameFeatureButtonPainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.rotation != rotation ||
        oldDelegate.rippleProgress != rippleProgress;
  }
}
