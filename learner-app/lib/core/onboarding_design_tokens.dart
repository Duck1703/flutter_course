import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_design_tokens.dart';

/// Visual language shared by the onboarding overlay and the QZDS-style
/// light-surface dialogs (auth, sign-out). Values that also exist as app
/// foundations reference [AppTokens] instead of redeclaring the literal;
/// only genuinely onboarding-specific values are defined here.
class OnboardingTokens {
  /// Pill height on the onboarding screen itself, which has room for one
  /// full-size action; dialogs use the compact `AppTokens.qzdsButtonHeight`.
  static const double buttonHeightLarge = 48;
  static const double badgeSize = 64;
  static const double badgeIconSize = 30;
  static const double headerHeight = 40;
  static const double indicatorActiveWidth = 24;
  static const double indicatorSize = 8;

  static const Color grey600 = AppTokens.qzdsBlack600;
  static const Color blue500 = AppTokens.blue500;
  static const Color blue100 = Color(0xFFAEBFFD);
  static const Color purple500 = AppTokens.qzdsPurple500;
  static const Color purple600 = AppTokens.qzdsPurple600;
  static const Color purple50 = AppTokens.qzdsPurple50;
  static const Color purple100 = AppTokens.qzdsPurple100;
  static const Color yellow500 = AppTokens.qzdsYellow500;
  static const Color yellow600 = AppTokens.qzdsYellow600;
  static const Color purple700 = AppTokens.qzdsPurple700;
  static const Color grey100 = AppTokens.qzdsGrey100;
  static const Color grey400 = Color(0xFF9E9E9E);
  static const Color grey700 = Color(0xFF616161);
  static const Color yellow100 = AppTokens.qzdsYellow100;

  /// Step accent green. Distinct from [AppTokens.green500] (`#22C55E`), which
  /// is the game's positive-action green.
  static const Color accentGreen500 = Color(0xFF4CAF50);
  static const Color accentGreen700 = Color(0xFF2E7D32);
  static const Color accentGreen100 = Color(0xFFC8E6C9);

  static const Color hazeScrim = Color(0x1A000000);

  static TextStyle get body1 => GoogleFonts.beVietnamPro(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  static TextStyle get subtitle2 => GoogleFonts.beVietnamPro(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0,
  );

  static LinearGradient get cardShellGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [purple600, purple50],
  );

  /// Gradient of the round step badge above each onboarding description.
  static LinearGradient badgeGradient(Color start, Color end) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [start, end],
  );

  /// Tinted surface shared by the reminder preview row and the ready-step chips.
  static BoxDecoration get infoTileDecoration => BoxDecoration(
    color: grey100.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusMd),
    border: Border.all(color: purple100.withValues(alpha: 0.4)),
  );

  /// Centre-out sheen on the onboarding and auth pill buttons.
  static RadialGradient get buttonGlow =>
      surfaceGlow(Colors.white.withValues(alpha: 0.32));

  static Duration get motionLong => AppTokens.dialogMotionLong;
  static Duration get motionEmphasis => const Duration(milliseconds: 400);
  static Duration get motionSlow => const Duration(milliseconds: 500);
}
