import 'package:flutter/material.dart';

/// Stretches a radial gradient so it fills the whole painted box.
///
/// Flutter sizes a [RadialGradient] from `radius * rect.shortestSide`, so on a
/// wide, short surface — a pill button, a dialog header, a leaderboard row —
/// the circle stops long before the left and right edges and the sheen reads as
/// a bright blob stranded in the middle. Scaling the gradient per axis turns
/// that circle into an ellipse shaped like the box, so the light falls off
/// evenly all the way to every edge whatever the widget's aspect ratio.
@immutable
class FillBoxGradientTransform extends GradientTransform {
  const FillBoxGradientTransform();

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final shortestSide = bounds.shortestSide;
    if (shortestSide <= 0) {
      return null;
    }
    final center = bounds.center;
    return Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(
        bounds.width / shortestSide,
        bounds.height / shortestSide,
        1,
        1,
      )
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FillBoxGradientTransform;

  @override
  int get hashCode => (FillBoxGradientTransform).hashCode;
}

/// Centre-out sheen for pill buttons, dialog headers, and highlight overlays.
///
/// Both stops stay lit: the edge keeps [edgeOpacity] of the centre's alpha
/// instead of fading to transparent, so a wide surface brightens everywhere and
/// never picks up the dark ring a fading glow leaves behind. [radius] is read as
/// a fraction of the painted box thanks to [FillBoxGradientTransform] — values
/// above `0.5` push the falloff past the edges and keep the light soft.
RadialGradient surfaceGlow(
  Color color, {
  double radius = 0.85,
  double edgeOpacity = 0.2,
}) {
  return RadialGradient(
    center: Alignment.center,
    radius: radius,
    colors: [color, color.withValues(alpha: color.a * edgeOpacity)],
    transform: const FillBoxGradientTransform(),
  );
}

/// Top-down gloss for dialog title bars.
///
/// A long, thin strip has no room for a radial hotspot without showing where
/// the light stops, and tinting the sheen makes every bar read differently — a
/// cyan sheen over a yellow bar turns green. So the title strip gets plain white
/// light running top to bottom: identical on every dialog, whatever colour the
/// bar itself is, and with no horizontal edge for the eye to catch.
const LinearGradient headerSheen = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0x4DFFFFFF), Color(0x0DFFFFFF)],
);
