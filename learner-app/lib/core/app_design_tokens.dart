import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

export 'app_assets.dart';
export 'surface_glow_gradient.dart';

/// How much room a pill action button takes.
///
/// Dialogs stack two to four actions inside a card, so they use [compact] —
/// a fixed 44px pill with a 14px label and a leading glyph. A screen's single
/// primary action has the room to stay [large] and keeps the taller pill and
/// 16px label it had before the dialog redesign.
enum QzdsButtonScale { compact, large }

class AppTokens {
  static const double spacingZero = 0;
  static const double spacingXxs = 4;
  static const double spacingXs = 8;
  static const double spacingSm = 12;
  static const double spacingMd = 16;
  static const double spacingLg = 20;
  static const double spacingXl = 24;
  static const double qzdsSpacingXxxs = 1;
  static const double qzdsSpacingXs = 4;
  static const double qzdsSpacingSm = 10;
  static const double qzdsSpacingXxl = 40;
  static const double qzdsSpacingGiant = 80;
  static const double iconLg = 24;
  static const double qzdsIconXs = 16;
  static const double qzdsIconSm = 18;
  static const double qzdsIconSmPlus = 20;
  static const double qzdsIconMd = 24;
  static const double qzdsIconBadgeSm = 28;
  static const double qzdsIconXl = 40;
  static const double qzdsPickerItemHeight = 40;
  /// Height every pill action button settles on: the minimum comfortable tap
  /// target, so dialogs stack several of them without growing tall.
  static const double qzdsButtonHeight = 44;
  static const double qzdsButtonHorizontalPadding = 14;
  static const double qzdsChipHeight = 36;
  static const double radiusMd = 12;
  static const double radius4 = 16;
  static const double qzdsRadiusMd = 8;
  static const double qzdsRadiusLg = 16;
  static const double radiusLg = 24;
  static const double radiusN = 9999;
  static const double dialogHazeBlurSigma = 16;
  static const double dialogQzdsSpacingSm = 10;
  static const double leaderboardDialogTitleHeight = 55;
  static const double leaderboardDialogBorderWidth = 2;
  static const Duration motionFast = Duration(milliseconds: 120);
  static const Duration motionMedium = Duration(milliseconds: 220);
  static const Duration motionSlow = Duration(milliseconds: 450);
  static const Duration dialogMotionLong = Duration(milliseconds: 300);
  static const double screenDesignWidth = 375;
  static const Color screenBackground = Color(0xFF575757);
  static const Color menuBackgroundOverlay = Color(0x1A001927);
  static const Color dialogHazeScrim = Color(0x00000000);
  static const Color mint500 = Color(0xFF00E0FF);
  static const Color blue500 = Color(0xFF0036F9);
  static const Color blue900 = Color(0xFF00104B);
  static const Color qzdsBlack600 = Color(0xFF757575);
  static const Color qzdsGrey100 = Color(0xFFF5F5F5);
  static const Color green400 = Color(0xFF89E87F);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green700 = Color(0xFF15803D);
  static const Color red500 = Color(0xFFF44336);
  static const Color red700 = Color(0xFFD32F2F);
  static const Color magenta400 = Color(0xFFE15CFF);
  static const Color orange500 = Color(0xFFFA7D00);
  static const Color purple300 = Color(0xFFAA9BFF);
  static const Color purple400 = Color(0xFF8F7CFF);
  static const Color qzdsPurple100 = Color(0xFFD3CBFF);
  static const Color qzdsPurple500 = Color(0xFF745CFF);
  static const Color qzdsPurple600 = Color(0xFF624AF2);
  static const Color qzdsPurple700 = Color(0xFF5137E5);
  static const Color qzdsPurple50 = Color(0xFFE0DAFF);
  static const Color purple800 = Color(0xFF3F25D7);
  static const Color purple900 = Color(0xFF2509C4);
  static const Color qzdsYellow100 = Color(0xFFFFF9C4);
  static const Color qzdsYellow500 = Color(0xFFFFC107);
  static const Color qzdsYellow600 = Color(0xFFFFB300);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow600 = Color(0xFFFFB300);
  static const Color white08 = Color(0x14FFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white14 = Color(0x24FFFFFF);
  static const Color white16 = Color(0x29FFFFFF);
  static const Color white55 = Color(0x8CFFFFFF);
  static const Color white65 = Color(0xA6FFFFFF);
  static const Color white72 = Color(0xB8FFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white100 = Colors.white;
  static TextStyle get body3 => GoogleFonts.beVietnamPro(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );
  static TextStyle get body4 => GoogleFonts.beVietnamPro(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
  );
  static TextStyle get headline5 => GoogleFonts.beVietnamPro(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0,
  );
  static TextStyle get qzdsSubtitle2 => GoogleFonts.beVietnamPro(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
  static TextStyle get qzdsBody1 => GoogleFonts.beVietnamPro(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  static TextStyle get qzdsCaption1 => GoogleFonts.beVietnamPro(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );
  static TextStyle get qzdsWheelNumber => GoogleFonts.beVietnamPro(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
  );
  static TextStyle get body5 => GoogleFonts.beVietnamPro(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
  );
  static TextStyle get headline4 => GoogleFonts.beVietnamPro(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
  );
  static TextStyle get label1 => GoogleFonts.beVietnamPro(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );
  static TextStyle get caption2 => GoogleFonts.beVietnamPro(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 1.5,
  );
  static TextStyle get caption3 => GoogleFonts.beVietnamPro(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0,
  );
  static TextStyle get numeric1 => GoogleFonts.beVietnamPro(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
  );
  static TextStyle get numericXl => GoogleFonts.beVietnamPro(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    height: 1,
    letterSpacing: 0,
  );
  static const LinearGradient settingsDialogOuterGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [qzdsPurple600, qzdsPurple50],
  );
  static const LinearGradient settingsIconGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [qzdsPurple500, qzdsPurple600],
  );
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [
      Color.fromRGBO(255, 255, 255, 0.05),
      Color.fromRGBO(255, 255, 255, 0.3),
    ],
  );
  static const LinearGradient levelBadgeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x66C0F7FF), Color(0x6600E0FF)],
  );
  static const LinearGradient menuBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF030611),
      Color(0xFF03081F),
      Color(0xFF060F4D),
      Color(0xFF000E8E),
      Color(0xFF0014EB),
      Color(0xFF0A1A90),
      Color(0xFF061130),
      Color(0xFF030A3F),
      Color(0xFF040913),
    ],
    stops: [
      0,
      0.14238,
      0.29758,
      0.37533,
      0.45210,
      0.72934,
      0.84548,
      0.92266,
      1,
    ],
  );

  static const RadialGradient earningsGradient = RadialGradient(
    center: Alignment(0.5, 0.0),
    radius: 1.2,
    colors: [Color(0xFFFFCC00), Color(0xFFFDA500), orange500],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient gameQuestionGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [blue900, purple900],
  );

  static const LinearGradient gameQuestionStrokeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xADFFFFFF), Color(0x33FFFFFF), Color(0x03FFFFFF)],
    stops: [0, 0.9, 1],
  );

  static const LinearGradient gameQuestionBadgeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [purple900, purple400],
  );

  static const LinearGradient gameQuestionBadgeStrokeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x1AFFFFFF),
      Color(0x33FFFFFF),
      Color(0x4DFFFFFF),
      Color(0x80FFFFFF),
    ],
  );

  static const LinearGradient gameLifelineGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mint500, Color(0xFF325DFA)],
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(255, 255, 255, 0.12),
      Color.fromRGBO(255, 255, 255, 0.3),
    ],
  );

  /// Menu level ring ramps, one per level tier. Linear and diagonal so the
  /// colour spreads evenly around the whole ring, and tiered so the ring says
  /// how far the player has come instead of repeating the EXP bar.
  static const LinearGradient levelRingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mint500, qzdsPurple500],
  );

  static const LinearGradient levelRingMilestoneGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [qzdsPurple500, magenta400],
  );

  static const LinearGradient levelRingMajorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [qzdsYellow500, orange500],
  );

  /// Dark dial behind the level number inside the EXP ring.
  static const RadialGradient levelDialGradient = RadialGradient(
    center: Alignment(0, -0.4),
    radius: 0.9,
    colors: [Color(0xFF0B1447), Color(0xFF040A24)],
  );

  /// Amber-tinted glass for the menu profile pill while signed out.
  static const LinearGradient guestPillGradient = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [Color(0x24FFC107), Color(0x3DFFFFFF)],
  );

  /// Glass row used by the menu leaderboard entry card.
  static const LinearGradient menuEntryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1AFFFFFF), Color(0x38FFFFFF)],
  );
}
