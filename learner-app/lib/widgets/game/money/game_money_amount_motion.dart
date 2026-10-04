import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';

class GameMoneyAmountMotion extends StatefulWidget {
  final String amount;
  final int animationTrigger;
  final Duration duration;

  const GameMoneyAmountMotion({
    super.key,
    required this.amount,
    required this.animationTrigger,
    required this.duration,
  });

  @override
  State<GameMoneyAmountMotion> createState() => _GameMoneyAmountMotionState();
}

class _GameMoneyAmountMotionState extends State<GameMoneyAmountMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _countStart = 0;
  var _countEnd = 0;
  var _amountTemplate = _AmountTemplate.fromAmount(r'$0');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _motionDuration,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant GameMoneyAmountMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = _motionDuration;

    final shouldAnimate =
        widget.animationTrigger > oldWidget.animationTrigger &&
        widget.duration > Duration.zero;
    if (shouldAnimate) {
      _countStart =
          _intAmount(oldWidget.amount) ?? _intAmount(widget.amount) ?? 0;
      _countEnd = _intAmount(widget.amount) ?? _countStart;
      _amountTemplate = _AmountTemplate.fromAmount(widget.amount);
      _controller.forward(from: 0);
    } else if (widget.amount != oldWidget.amount) {
      _controller.value = 1;
    }
  }

  Duration get _motionDuration => widget.duration == Duration.zero
      ? Duration.zero
      : const Duration(milliseconds: 260);

  @override
  Widget build(BuildContext context) {
    if (widget.duration == Duration.zero) {
      return _amountText(amount: widget.amount);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(_controller.value);
        final amount = _displayAmount(progress);
        final intensity = (1 - progress).clamp(0, 1).toDouble();

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (intensity > 0) ..._glitchLayers(amount, intensity),
            _amountText(
              key: const ValueKey('game-money-amount-text'),
              amount: amount,
            ),
          ],
        );
      },
    );
  }

  List<Widget> _glitchLayers(String amount, double intensity) {
    return [
      _amountText(
        key: const ValueKey('game-money-amount-glitch-layer-0'),
        amount: amount,
        color: const Color(0x9900E5FF),
        offset: Offset(3 * intensity, -0.8 * intensity),
      ),
      _amountText(
        key: const ValueKey('game-money-amount-glitch-layer-1'),
        amount: amount,
        color: const Color(0x99FF00FF),
        offset: Offset(-2.5 * intensity, 0.8 * intensity),
      ),
    ];
  }

  String _displayAmount(double progress) {
    if (_controller.value >= 1) return widget.amount;

    final delta = (_countEnd - _countStart) * progress;
    return _amountTemplate.format(_countStart + delta.round());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _AmountTemplate {
  final String prefix;
  final String suffix;

  const _AmountTemplate({required this.prefix, required this.suffix});

  factory _AmountTemplate.fromAmount(String amount) {
    final firstDigit = amount.indexOf(RegExp(r'\d'));
    final lastDigit = amount.lastIndexOf(RegExp(r'\d'));
    if (firstDigit == -1 || lastDigit == -1) {
      return _AmountTemplate(prefix: amount, suffix: '');
    }

    return _AmountTemplate(
      prefix: amount.substring(0, firstDigit),
      suffix: amount.substring(lastDigit + 1),
    );
  }

  String format(int value) => '$prefix${_formatGrouped(value)}$suffix';
}

int? _intAmount(String amount) {
  final digits = amount.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? null : int.parse(digits);
}

String _formatGrouped(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < text.length; index++) {
    final fromRight = text.length - index;
    buffer.write(text[index]);
    if (fromRight > 1 && fromRight % 3 == 1) buffer.write(',');
  }
  return buffer.toString();
}

Widget _amountText({
  Key? key,
  required String amount,
  Color? color,
  Offset offset = Offset.zero,
}) {
  final text = Text(
    amount,
    key: color == null ? null : key,
    textAlign: TextAlign.center,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: _textStyle.copyWith(color: color ?? Colors.white),
  );
  final content = color == null
      ? ShaderMask(
          key: key,
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
            ).createShader(bounds);
          },
          child: text,
        )
      : text;
  return offset == Offset.zero
      ? content
      : Transform.translate(offset: offset, child: content);
}

TextStyle get _textStyle => AppTokens.headline5.copyWith(
  color: Colors.white,
  fontSize: 32,
  fontWeight: FontWeight.w900,
  height: 1.1,
);
