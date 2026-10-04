## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m28/01 — "Nền móng — dependencies, assets, design tokens" (2 dep senior + 2 asset-dir + 7 SVG + 1 PNG; `AppAssets` subset 8 const; `AppTokens` 318-dòng verbatim + `screenDesignWidth=375` + `DesignFrame`; `surfaceGlow`/`FillBoxGradientTransform` + `headerSheen`; 6 ARB semantic keys; +0 test → 259 — nền chưa ai dùng).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter pub deps`, `flutter gen-l10n`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Đây là bài NỀN — chưa widget nào dùng `AppTokens`/`AppAssets` là ĐÚNG (consumer BÀI 2+). `MenuTokens` cũ vẫn tồn tại song song là ĐÚNG (widget cũ chưa migrate — retire dần).

EXPECTED STATE SAU BÀI NÀY:
- `pubspec.yaml` (STRICT): `flutter_svg: ^2.3.0` + `google_fonts: ^8.1.0` cuối block dependencies; block `flutter:` sau `uses-material-design: true` — `assets:` với `- assets/images/icons/` + `- assets/images/backgrounds/` (STRICT chỉ 2 dir — không assets khác).
- `assets/` files (STRICT đúng 8): `assets/images/icons/` có 7 SVG `game-audience.svg`, `game-back.svg`, `game-fifty-fifty.svg`, `game-lightning.svg`, `game-money.svg`, `game-sparkle.svg`, `game-trophy.svg` + `assets/images/backgrounds/menu-background.png` (STRICT subset — avatar/decorations/leaderboard/settings icons = AHEAD M29).
- `lib/core/app_assets.dart` (FILE MỚI, STRICT ~19 dòng subset): `class AppAssets` đúng 8 static const String — `menuBackground` = 'assets/images/backgrounds/menu-background.png', `iconGameBack`/`iconGameFiftyFifty`/`iconGameAudience`/`iconGameSparkle`/`iconGameTrophy`/`iconGameLightning`/`iconGameMoney` = 'assets/images/icons/game-*.svg' (STRICT chỉ 8 — 66-const full senior = AHEAD M29; hardcode path sai tên = runtime throw).
- `lib/core/surface_glow_gradient.dart` (FILE MỚI, STRICT verbatim): `@immutable class FillBoxGradientTransform extends GradientTransform` — `transform(Rect bounds, {TextDirection?})` → `shortestSide <= 0 → null` + `Matrix4.identity()..translateByDouble(center.dx, center.dy, 0, 1)..scaleByDouble(w/shortest, h/shortest, 1, 1)..translateByDouble(-center.dx, -center.dy, 0, 1)` + `operator==`/`hashCode` (immutable value); `RadialGradient surfaceGlow(Color color, {double radius = 0.85, double edgeOpacity = 0.2})` — `colors: [color, color.withValues(alpha: color.a * edgeOpacity)]` + `transform: const FillBoxGradientTransform()`; `headerSheen` LinearGradient trắng top→bottom.
- `lib/core/app_design_tokens.dart` (FILE MỚI, STRICT verbatim ~318 dòng): 2 export đầu `export 'app_assets.dart';` + `export 'surface_glow_gradient.dart';` (STRICT load-bearing — widget senior chỉ import file này một lần); `enum QzdsButtonScale { compact, large }`; `class AppTokens` — spacing/icon/radius const, `motionFast=120`/`motionMedium=220`/`motionSlow=450`/`dialogMotionLong=300` Duration const, `screenDesignWidth = 375`, `qzdsButtonHeight = 44`, ~60 Color const (`white08`/`white10`/`white24`/`white100`, `blue*`/`purple*`/`yellow500`/`yellow600`/`qzdsPurple500`/`screenBackground`/`menuBackground*`/`gameQuestionGradient`/`gameLifelineGradient`/`glassGradient`…), ~25 `static TextStyle get` qua `GoogleFonts.beVietnamPro` (STRICT getter không const — TextStyle factory runtime; `import 'package:google_fonts/google_fonts.dart'`).
- `lib/widgets/common/design_frame.dart` (FILE MỚI, STRICT verbatim): `class DesignFrame extends StatelessWidget` — `Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: AppTokens.screenDesignWidth), child: child))`.
- ARB +6 keys (STRICT verbatim): `optionSemanticLabel` ({label},{answer}), `selectedStateLabel` ("Selected"/"Đã chọn"), `correctStateLabel` ("Correct"/"Đúng" — STRICT đầy đủ "Đúng", không "Đú"), `incorrectStateLabel` ("Incorrect"/"Sai"), `prizeAmountSemanticLabel` ({amount}), `timeRemainingSemanticLabel` ({time}) — en có `@`-metadata placeholders, vi không cần; `app_localizations*.dart` regenerated (gen-l10n).
- `flutter analyze` sạch; `flutter test` → **259/259** (STRICT — chưa ai dùng: import tokens ngoài 4 file mới = AHEAD BÀI 2+).
- KHÔNG ĐƯỢC có (chưa đến): `QzdsGameButton`/`GlassIconButton`/`GameScreenBackground`/`game_screen_top_bar`/`game_countdown_timer`/`_PillProgressPainter`/`game_money_amount*`/`game_money_ladder*`/`game_answer_option*`/`game_question_panel`/`game_audience_poll_row`/`game_feature_button*`/`game_screen_body`/`game_dialog_shell`/`game_result_dialogs`/`game_help_dialogs`/`game_confirm_dialogs`/layer mới `widgets/game/dialogs/game_dialog_layer.dart` (BÀI 2–6); `iconAsset` trên `GameFeatureButtonData` (BÀI 6 — vẫn `icon: IconData`); `SvgPicture.asset` ở đâu trong lib (BÀI 2); widget nào import `app_design_tokens` ngoài 4 file mới (BÀI 2+); assets của M29 (avatars/leaderboard/settings icons); `withOpacity` deprecated (senior dùng `withValues` — DIVERGED API cũ).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- M27 đỉnh 259 (notification chain + share chain + version row + DI); M26 DRE; `MenuTokens` cũ vẫn sống (widget M14–M27 chưa migrate — retire dần M28–M29, không xoá vội); `GameFeatureButtonData.icon: IconData` (BÀI 6 swap); `game_dialog_layer.dart`/`game_dialog_views.dart` CŨ vẫn tồn tại (BÀI 6 xoá); `game_screen.dart` monolith 629d (BÀI 6 rewrite); `_DialogShareButton` scaffold (BÀI 6 retire); test suite 259 nguyên.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. Thiếu `export 'app_assets.dart'` trong tokens file = DIVERGED (widget senior một-import sẽ undefined sau này). ARB `correctStateLabel` vi "Đú" thay "Đúng" = NEEDS_FIX.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m28/01
PROJECT_ALIGNMENT: ON_TRACK | NEEDS_FIX | DIVERGED | BLOCKED
COURSE_POSITION: ON_TRACK | BEHIND | AHEAD_COMPATIBLE | AHEAD_RISKY
READY_FOR_NEXT_LESSON: YES | YES_AFTER_FIXES | NO
VERIFICATION_PERFORMED:
WHAT_MATCHES:
GAPS:
AHEAD_OF_COURSE:
DIVERGENCES:
REQUIRED_FIXES_BEFORE_CONTINUING:
EVIDENCE: file/symbol → observation
FILES_MODIFIED_BY_REVIEW: NONE
```
