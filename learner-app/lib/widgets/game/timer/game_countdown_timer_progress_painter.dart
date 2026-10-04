part of 'game_countdown_timer.dart';

class _PillProgressPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  const _PillProgressPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final safeProgress = progress.clamp(0, 1).toDouble();

    if (safeProgress <= 0 || size.width <= _strokeWidth) {
      return;
    }

    final path = buildGameCountdownTimerProgressPath(size);
    final metric = path.computeMetrics().first;
    final progressPath = metric.extractPath(0, metric.length * safeProgress);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _strokeWidth;

    canvas.drawPath(progressPath, paint);
  }

  @override
  bool shouldRepaint(covariant _PillProgressPainter oldDelegate) {
    return progress != oldDelegate.progress || colors != oldDelegate.colors;
  }
}

@visibleForTesting
Path buildGameCountdownTimerProgressPath(Size size) {
  final halfStroke = _strokeWidth / 2;
  final rect = Rect.fromLTWH(
    halfStroke,
    halfStroke,
    size.width - _strokeWidth,
    size.height - _strokeWidth,
  );
  final radius = math.min(rect.width, rect.height) / 2;
  final arc = Radius.circular(radius);

  return Path()
    ..moveTo(rect.center.dx, rect.top)
    ..lineTo(rect.right - radius, rect.top)
    ..arcToPoint(Offset(rect.right, rect.top + radius), radius: arc)
    ..lineTo(rect.right, rect.bottom - radius)
    ..arcToPoint(Offset(rect.right - radius, rect.bottom), radius: arc)
    ..lineTo(rect.left + radius, rect.bottom)
    ..arcToPoint(Offset(rect.left, rect.bottom - radius), radius: arc)
    ..lineTo(rect.left, rect.top + radius)
    ..arcToPoint(Offset(rect.left + radius, rect.top), radius: arc)
    ..lineTo(rect.center.dx, rect.top);
}

@visibleForTesting
double debugGameCountdownTimerPaintProgress(CustomPaint paint) {
  final painter = paint.foregroundPainter;

  if (painter is _PillProgressPainter) {
    return painter.progress;
  }

  throw StateError('CustomPaint is not using the countdown progress painter.');
}
