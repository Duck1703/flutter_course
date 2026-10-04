## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m29/04 — "Bề mặt menu: 4 card hồ sơ, CTA gradient, và decomposition theo file" (`menu_screen.dart` bỏ private-widget → `MenuScreenContent` (LayoutBuilder + `minHeight`-Center + `panelGap` cố định) + `profile/` 5 file (`MenuProfileHeader` pill+`GlassIconButton` gear, `EarningsCard`, `LevelProgressCard` ring-theo-tier + EXP bar, `StatsCard`, `ProfileAvatarImage` 3-tầng) + `LeaderboardEntryCard` + `GradientCtaButton` (`QzdsGameButton` large `textGlow`) + `ScreenTop/BottomInset` fallback 37/34; auth dialogs + `OnboardingOverlayScope` + `LanguageChipRow` + `OnboardingGameButton` RE-PORT verbatim — MenuTokens-era retire; `MenuLevelProgress` (M22 data) cuối-cùng-có-visual; +24 → 345).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `wc -l`/`grep` cho private-widget cấp-màn-hình. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. File là đơn-vị-review — private-widget cấp-màn-hình (`_ProfileHeader`/`_EarningsCard` trong `menu_screen.dart`) = DIVERGED convention; private-component-nhỏ trong file-chủ (`_LevelDial`/`_ExperienceBar`) = ĐÚNG.

EXPECTED STATE SAU BÀI NÀY:
- `lib/widgets/menu/menu_screen_content.dart` (FILE MỚI, STRICT verbatim): `class MenuScreenContent` + `static const double panelGap = AppTokens.spacingSm` (STRICT token-on-token, test đọc `MenuScreenContent.panelGap`); `LayoutBuilder` → `SingleChildScrollView(BouncingScrollPhysics)` → `ConstrainedBox(minHeight: constraints.maxHeight)` → `Center` → `DesignFrame` → `Padding(spacingMd h, panelGap v)` → `Column(mainAxisSize.min)` 4 phần tử `SizedBox(height: panelGap)` giữa: `LevelProgressCard(progress: MenuLevelProgress.fromProfile(userData))` / `EarningsCard(data: userData)` / `LeaderboardEntryCard(onTap:)` / `StatsCard(data: userData)` (STRICT thứ-tự chain — `Center` NGOÀI `ConstrainedBox` = dính-top; `Expanded`-spacing giữa card = giãn-gap sai-spec "gap cố định margin co giãn").
- `lib/widgets/menu/profile/` 5 FILE MỚI (STRICT verbatim mỗi <250d):
  - `menu_profile_header.dart` — pill `body5`+`caption3` 2-dòng + `GlassIconButton(assetIcon: AppAssets.iconGear, semanticLabel: l10n.settingsSemanticLabel)` + accent `isAuthenticated ? mint500 : qzdsYellow500` (STRICT màu-là-thông-tin guest-vàng/auth-mint);
  - `earnings_card.dart` — glass-card tổng-tiền-thắng `glassCardGradient`;
  - `level_progress_card.dart` — `static LinearGradient ringGradientFor(MenuLevelTier tier)` switch `base → levelRingGradient / milestone → levelRingMilestoneGradient / major → levelRingMajorGradient` (STRICT ring = TIER — tô theo `progress.ratio` = DIVERGED hai-chỉ-số-tranh-nghĩa; static pure-fn testable) + ring-CustomPainter `dial` + `Text.rich` `formattedCurrentExp` numeric1-white100 + ' / `formattedRequiredExp`' body3-white65 + `_ExperienceBar(ratio)` + `Text(isMaxLevel ? l10n.menuMaxLevelReached : l10n.menuExpToNextLevel(formattedRemainingExp, nextLevel))`;
  - `profile_avatar_image.dart` — `!isAuthenticated → Image.asset(AppAssets.avatar)` (STRICT guest-bundled — initial chỉ-auth-URL-lỗi) : `_validAvatarUrl(data.avatarUrl)` http/https-whitelist → `Image.network(errorBuilder → _initialAvatar)` `runes.first.toUpperCase` (fallback-chain khác LeaderboardAvatar Bài-03 ngữ-cảnh — KHÔNG gộp generic);
  - `stats_card.dart` — số-ván/thắng glass-card.
- `lib/widgets/menu/gradient_cta_button.dart` (FILE MỚI, STRICT verbatim ~20d): `Padding(spacingMd)` → `SizedBox(width: double.infinity)` → `QzdsGameButton(text: label.isEmpty ? l10n.startGameButton : label, color: AppTokens.qzdsPurple700, textGlow: true, scale: QzdsButtonScale.large, onTap:)` (STRICT preset-wrapper — tự-vẽ gradient mới = DIVERGED; `textGlow: true` + `scale: large` bắt-buộc).
- `lib/widgets/menu/screen_top_inset.dart` + `screen_bottom_inset.dart` (STRICT verbatim ~11d mỗi): `MediaQuery.paddingOf(context).top > 0 ? inset : 37` / bottom `34` (STRICT literal-fallback verbatim — contract-web/test).
- `lib/widgets/menu/leaderboard/leaderboard_entry_card.dart` (có-thể-đã-từ-Bài-03 hoặc-bài-này): trophy `SvgPicture` 28 `ColorFilter.mode(white100, srcIn)` + `l10n.leaderboardTitle` + `l10n.menuLeaderboardEntrySubtitle` + `Semantics(button: onTap != null, excludeSemantics: true)`.
- RE-PORT verbatim (bản-adapted-MenuTokens-era XOÁ): `lib/widgets/menu/auth/menu_auth_dialog*` + `menu_sign_out_dialog*` + `lib/widgets/common/language_chip_row.dart` + `lib/widgets/onboarding/onboarding_overlay_scope.dart` + `onboarding_game_button.dart` (STRICT token-only — literal-màu/size sót = adapted-drift DIVERGED; scope-vẫn-chain-M18-đơn-giản — FutureBuilder-gate BÀI 06).
- `lib/screens/menu_screen.dart` (STRICT): KHÔNG còn `_ProfileHeader`/`_EarningsCard`/`_StatsCard`/`_PlayButton` private-widget cấp-màn — screen chỉ scope/provider/nav; content ra `MenuScreenContent`; `menu_screen.dart` còn ~<150d (STRICT monolith-menu còn = DIVERGED).
- `test/widgets/` `menu_gradient_cta_button_test.dart` 3 + `menu_level_progress_card_test.dart` 12 (đa-số unit-logic `ringGradientFor`/`tier`) + `menu_profile_avatar_test.dart` 5 + `menu_screen_content_layout_test.dart` 4 (đo `panelGap` const).
- `flutter analyze` sạch; `flutter test` → **345/345** (STRICT 321 + 24).
- KHÔNG ĐƯỢC có (chưa đến): `MenuDialogState`/`menu_dialog_layer`/`menu_dialog_backdrop`/`menu_screen_view`/`PopScope(canPop:)`/`_dialogDismissLocked`/`Positioned.fill(MenuDialogLayer)` trong Stack menu (BÀI 05 — `showDialog`-route vẫn transport: `onSettingsTap → showSettingsDialog`, `onLeaderboardTap → showLeaderboardDialog`, auth/sign-out routes; `MenuScreenUiEvent` 6-variant vẫn); onboarding config/card/step-actions/step-indicator/overlay-4-class (BÀI 06 — `OnboardingOverlayScope` đã re-port nhưng overlay-visual M18-cũ); `menu_tokens.dart` xoá (BÀI 06 — file CÒN, chỉ consumer đổi-token); previews/`main`-verbatim (BÀI 07); `MenuDialog*` state-family (BÀI 05).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- Bài 03: leaderboard-pipeline DTO/mapper/pin/avatar/entry-card-assets + 321; Bài 02: settings-11-file + `iconAsset` + 313; Bài 01: 45-const + OnboardingTokens + 50-assets; M22 `MenuLevelProgress`/`LevelConfig`/`MenuLevelTier`/`passed`-milestone-loop (data — bài này visual); M18 `OnboardingViewModel`/overlay-VM-scope; M24 `AuthRepository`/`MenuAuthDialog`-adapted→verbatim + auth-state-stream; `QzdsGameButton`/`GlassIconButton` M22-M28; `MenuScreenViewModel` events/`dismissCurrentDialog`-pre-state (BÀI 05 rewrite); `userData` stream provider; `Settings*`/`Leaderboard*` dialog routes (BÀI 05 retire).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. Private-widget cấp-màn-hình còn = DIVERGED convention; `ringGradientFor` theo ratio = DIVERGED; `ConstrainedBox`/`Center` sai-thứ-tự = DIVERGED layout; adapted-widgets literal-sót = DIVERGED re-port-incomplete.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m29/04
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
