import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_millionaire_course/core/surface_glow_gradient.dart';

void main() {
  group('surfaceGlow', () {
    test('reaches the horizontal edges of a wide, short box', () {
      const bounds = Rect.fromLTWH(0, 0, 280, 48);
      final gradient = surfaceGlow(const Color(0x52FFFFFF), radius: 0.5);

      final matrix = gradient.transform!.transform(bounds)!;
      // Flutter sizes the circle from the shortest side; the transform must
      // stretch it back out to half the width on the horizontal axis.
      final circleRadius = gradient.radius * bounds.shortestSide;
      expect(circleRadius * matrix.entry(0, 0), closeTo(bounds.width / 2, 0.01));
      expect(
        circleRadius * matrix.entry(1, 1),
        closeTo(bounds.height / 2, 0.01),
      );
    });

    test('keeps the ellipse centred on an offset box', () {
      const bounds = Rect.fromLTWH(20, 10, 200, 40);
      final matrix = surfaceGlow(
        const Color(0x52FFFFFF),
      ).transform!.transform(bounds)!;

      // Scaling happens around the box centre, so the centre maps to itself.
      final center = bounds.center;
      expect(
        matrix.entry(0, 3),
        closeTo(center.dx * (1 - matrix.entry(0, 0)), 0.01),
      );
      expect(
        matrix.entry(1, 3),
        closeTo(center.dy * (1 - matrix.entry(1, 1)), 0.01),
      );
    });

    test('leaves a square box untouched', () {
      const bounds = Rect.fromLTWH(0, 0, 64, 64);
      final matrix = surfaceGlow(
        const Color(0x52FFFFFF),
      ).transform!.transform(bounds)!;

      expect(matrix, Matrix4.identity());
    });

    test('keeps the edge lit instead of fading to transparent', () {
      const color = Color(0x52FFFFFF);
      final gradient = surfaceGlow(color, edgeOpacity: 0.2);

      expect(gradient.colors.first, color);
      expect(gradient.colors.last.a, closeTo(color.a * 0.2, 0.001));
      expect(gradient.colors.last.a, greaterThan(0));
    });

    test('skips a degenerate box', () {
      expect(
        surfaceGlow(const Color(0x52FFFFFF)).transform!.transform(Rect.zero),
        isNull,
      );
    });
  });
}
