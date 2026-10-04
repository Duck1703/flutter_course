---
title: "Bài 04 — Bề mặt menu: 4 card hồ sơ, CTA gradient, và decomposition theo file"
description: "Menu surface converge: `menu_screen.dart` bỏ hết private-widget → `MenuScreenContent` (LayoutBuilder + `minHeight` center + `panelGap` cố định) + `profile/` 5 file (`MenuProfileHeader` pill+`GlassIconButton` gear, `EarningsCard`, `LevelProgressCard` ring-theo-tier + EXP bar, `StatsCard`, `ProfileAvatarImage` 3-tầng-fallback) + `LeaderboardEntryCard` (trophy SVG tint + subtitle) + `GradientCtaButton` (`QzdsGameButton` large `textGlow`) + `ScreenTop/BottomInset` (fallback 37/34). Auth dialogs + `OnboardingOverlayScope` + `LanguageChipRow` + `OnboardingGameButton` re-port verbatim — bản MenuTokens-era retire. `MenuLevelProgress` (M22) cuối cùng có visual. +24 test: 345/345."
sidebar:
  order: 4
  label: Bề mặt menu
---

# Bài 04 — Bề mặt menu: card hồ sơ, CTA, và file nhỏ

## Mục tiêu

Sau bài này bạn sẽ:

- Hiểu **decomposition theo trục file**: màn menu senior là ~9
  file nhỏ (mỗi file một trách nhiệm, <200 dòng) thay vì các
  private-widget chất trong `menu_screen.dart` — và vì sao "file
  nhỏ" không phải thẩm-mỹ mà là *diff-ability* (A-40).
- Đọc được bố cục `MenuScreenContent`: **gap cố-định giữa các
  card, margin co giãn** — `LayoutBuilder` + `minHeight` +
  `Center` cho "màn thấp thì scroll, màn cao thì căn giữa".
- Nắm `MenuLevelProgress` (đã có từ M22) cuối cùng **có visual**:
  ring level tô màu theo `MenuLevelTier` (base/milestone/major)
  + EXP bar riêng — "hai chỉ số không tranh một ý nghĩa".
- Thấy `ProfileAvatarImage` tái-lập chuỗi-fallback của Bài 03
  cho ngữ-cảnh profile: guest → asset; auth → `Image.network`
  (http/https) → initial-letter.
- Biết `GradientCtaButton` chỉ là **wrapper cấu-hình** quanh
  `QzdsGameButton` (`scale: large`, `textGlow: true`) — CTA
  không tự vẽ, nó *chọn tham số*.
- Hiểu "re-port verbatim": auth dialogs, `OnboardingOverlayScope`,
  `LanguageChipRow`, `OnboardingGameButton` từng là bản
  *adapted* thời `MenuTokens` — batch này thay bằng verbatim.

## Bạn đang ở đâu

Sau Bài 03, dialog leaderboard đã có pipeline senior. Nhưng
**bề mặt menu** — thứ nhìn thấy trước khi mở dialog nào — vẫn
là learner-era:

```text
learner (trước bài này):
  lib/screens/menu_screen.dart        private widgets: _ProfileHeader,
       _EarningsCard, _PlayButton… — một file nuôi cả màn hình
  MenuTokens-era widgets: literal màu/size rải rác, auth dialog
       và language chip là bản "gần giống" tự chế từ M14–M22
  Level card: chưa có — MenuLevelProgress (M22) chỉ là data

senior lib/widgets/menu/:
  menu_screen_content.dart + gradient_cta_button.dart +
  screen_top/bottom_inset.dart + profile/×5 + leaderboard/
  entry_card — mỗi file < 250 dòng
```

## Vì sao việc này quan trọng ngay bây giờ

Bài 05 sẽ lắp `MenuDialogLayer` vào **stack của
`MenuScreenView`** — view đó không thể tồn tại nếu menu vẫn là
private-widget-trong-screen. Decomposition ở đây là *điều-kiện-
tiên-quyết* của dialog layer: view tách khỏi screen, card tách
khỏi view, từng mảnh đứng một file để layer/scope có chỗ cắm.
Về visual, đây là lúc menu nhìn "đúng senior" lần đầu — và là
lúc số test nhảy mạnh nhất của sweep (+24, toàn widget-test
cho từng card).

## Bạn đã biết gì

| Đã học | Ở đâu | Nhắc ngắn |
|---|---|---|
| **A-38** Token nguồn-duy-nhất | M28·01, M29·01 | `AppTokens.glassCardGradient`, `levelRingGradient`… đã trong nền |
| **F-30** `BackdropFilter` + scrim | M21 | `LevelProgressCard`/`glassCardGradient` — glass = blur + gradient + viền mờ |
| **F-42** `SvgPicture` + `ColorFilter.mode(srcIn)` | M28, M29·02 | trophy trắng trên entry-card — `srcIn` tô theo màu chỉ-định |
| **A-15/A-17** scoped VM / overlay VM | M16, M18 | auth/sign-out VM trong dialog-scope; overlay VM trong `OnboardingOverlayScope` |
| **F-39** `CustomPainter` | M28 | ring/dial vẽ tay — `LevelProgressCard` dùng painter cho ring |
| **F-07** `LayoutBuilder` + `ConstrainedBox` | M02 | màn-hình-co: scroll khi thấp, căn giữa khi cao |
| **A-40** Quy trình sweep | M29·01 | verbatim; re-port = thay bản adapted bằng bản verbatim |

## Mental model mới — "file là đơn vị review, không phải class"

M14–M28 bạn đã thấy mọi pattern kiến-trúc. Điều mới ở đây là
**kỷ luật chia file** của senior: convention repo là *"file
tập trung, tốt nhất dưới ~200 dòng"* — vì:

```text
- Mỗi file = một diff-review đọc hết được
- Tên file = documentation ("level_progress_card" nói ngay
  nó vẽ gì — "_LevelCard" private trong menu_screen không)
- Conflict git giảm: hai người sửa hai card khác file
- Sweep diff từng-file với senior là có thể
```

Private-widget *không* bị cấm — `_LevelDial`, `_ExperienceBar`
vẫn private trong `level_progress_card.dart`. Cái senior tránh
là **private-widget-cấp-màn-hình**: component đủ lớn để có
trách nhiệm riêng thì phải ra file riêng.

## Dart cần dùng

| Dart | Vai trò ở đây | Xem lại |
|---|---|---|
| `static const double panelGap = AppTokens.spacingSm` | gap-card là token-trên-token — catalog-level | D-04 |
| `switch (tier) { base => … milestone => … }` | `ringGradientFor` — enum→gradient một nơi, kiệt hợp | D-27 |
| `progress.isMaxLevel ? … : l10n.menuExpToNextLevel(...)` | nhánh text max-level | cơ bản M01 |
| `label.isEmpty ? l10n.startGameButton : label` | default-param + fallback l10n | cơ bản M01 |

## Flutter cần dùng

| Flutter | Vai trò ở đây | Xem lại |
|---|---|---|
| `LayoutBuilder` + `ConstrainedBox(minHeight: maxHeight)` + `Center` trong `SingleChildScrollView` | co-giãn theo chiều cao | F-07 |
| `BackdropFilter` + `glassCardGradient` | glass card | F-30 |
| `QzdsGameButton(scale: large, textGlow:)` | CTA dùng-chung | đã có từ M22-era |
| `MediaQuery.paddingOf(context).top` | `ScreenTopInset` — inset thật hoặc fallback 37 | mới tại đây |
| `GlassIconButton(assetIcon:)` | gear SVG trong nút kính | M22-era |

## Ví dụ độc lập — "màn thấp scroll, màn cao giữa"

```dart
/// VÍ DỤ ĐỘC LẬP — logic layout, không UI thật.
/// Mô phỏng: ConstrainedBox(minHeight: constraints.maxHeight)
double contentHeight(double screen, double natural) {
  // Column cao `natural`. ConstrainedBox ép TỐI THIỂU = screen:
  final effective = natural < screen ? screen : natural;
  // Center đặt content giữa `effective`; scroll chỉ khi effective > screen
  return effective;
}

void main() {
  print(contentHeight(800, 500)); // 800 → căn giữa, không scroll
  print(contentHeight(800, 1000)); // 1000 → scroll được 200px
}
```

## Android / Compose bridge

:::note[Android / Compose bridge — "file-per-composable"]
- **SIMILARITY**: convention "file < 200 dòng, một component
  một file" giống guideline Compose *"one public composable
  per file"* — file là đơn-vị-review.
- **IMPORTANT DIFFERENCE**: `MediaQuery.paddingOf` có *fallback
  literal* (`> 0 ? inset : 37`) — senior chọn giá trị mặc-định
  cho môi-trường không-báo-inset (web/test). Không "đoán bừa":
  fallback cũng là quyết-định được-ghi-trong-code.
- **DO NOT ASSUME**: đừng nghĩ `GradientCtaButton` tự vẽ
  gradient — nó chỉ *chọn* `QzdsGameButton` với tham-số
  `scale: large, textGlow: true`. CTA = preset, không phải
  widget mới.
:::

## Senior project connection

| File senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/widgets/menu/menu_screen_content.dart` | 4-card stack, `panelGap`, LayoutBuilder-center |
| `lib/widgets/menu/profile/{menu_profile_header,earnings_card,level_progress_card,profile_avatar_image,stats_card}.dart` | profile block — 5 file |
| `lib/widgets/menu/gradient_cta_button.dart` | CTA preset `QzdsGameButton` large+textGlow |
| `lib/widgets/menu/screen_{top,bottom}_inset.dart` | inset an-toàn + fallback |
| `lib/widgets/menu/leaderboard/leaderboard_entry_card.dart` | trophy srcIn + subtitle (consume pipeline Bài 03) |
| `lib/widgets/menu/auth/*` + `lib/widgets/common/language_chip_row.dart` + `lib/widgets/onboarding/onboarding_overlay_scope.dart` + `onboarding_game_button.dart` | **re-port verbatim** — bản MenuTokens-era retire |
| `lib/view_models/menu/menu_level_progress.dart` | data-side đã có từ M22 — giờ visual đến |
| `test/widgets/{menu_gradient_cta_button(3),menu_level_progress_card(12),menu_profile_avatar(5),menu_screen_content_layout(4)}` | +24 |

## Build it step by step

### Bước 1 — Content: 4 card, gap cố-định, margin co-giãn

```dart
// learner-app/lib/widgets/menu/menu_screen_content.dart (trích)
class MenuScreenContent extends StatelessWidget {
  static const double panelGap = AppTokens.spacingSm;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: DesignFrame(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.spacingMd, vertical: panelGap),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    LevelProgressCard(
                      progress: MenuLevelProgress.fromProfile(userData)),
                    const SizedBox(height: panelGap),
                    EarningsCard(data: userData),
                    const SizedBox(height: panelGap),
                    LeaderboardEntryCard(onTap: onLeaderboardTap),
                    const SizedBox(height: panelGap),
                    StatsCard(data: userData),
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

:::note[Đọc doc-comment senior — đó là spec]
*"The four rows keep a single fixed gap so they group visually,
and the block is centered in the area between the header and
the primary action instead of hanging from the top. Taller
screens grow the margins around the block, never the gaps
inside it."* — quy-tắc-thiết-kế viết trong code: **gap cố-
định, margin co-giãn**. Đổi `panelGap` thành
`Expanded`-spacing sẽ làm màn cao giãn-khoảng-cách — sai spec.
:::

### Bước 2 — `MenuLevelProgress` cuối cùng có visual

```dart
// learner-app/lib/widgets/menu/profile/level_progress_card.dart (trích)
static LinearGradient ringGradientFor(MenuLevelTier tier) {
  return switch (tier) {
    MenuLevelTier.base => AppTokens.levelRingGradient,
    MenuLevelTier.milestone => AppTokens.levelRingMilestoneGradient,
    MenuLevelTier.major => AppTokens.levelRingMajorGradient,
  };
}
```

```dart
// _buildExperience (trích) — EXP sống ở bar + text, KHÔNG ở ring:
Text.rich(TextSpan(
  text: progress.formattedCurrentExp,
  style: AppTokens.numeric1.copyWith(color: AppTokens.white100),
  children: [TextSpan(
    text: ' / ${progress.formattedRequiredExp}',
    style: AppTokens.body3.copyWith(color: AppTokens.white65))])),
_ExperienceBar(ratio: progress.ratio),
Text(progress.isMaxLevel
    ? l10n.menuMaxLevelReached
    : l10n.menuExpToNextLevel(
        progress.formattedRemainingExp, progress.nextLevel)),
```

:::tip[Hai chỉ số, hai kênh]
Comment senior: *"the ring states the level tier; experience
progress lives only in the bar, so the two never compete for
the same meaning."* Ring = **tier** (bạn đã vượt mốc nào —
từ `MenuLevelProgress.tier` suy từ `LevelConfig` milestones);
bar+text = **EXP** (tiến-tới-level-kế). Một vùng-một-nghĩa:
đây là lý do ring *không* tô theo `ratio`.
:::

### Bước 3 — Avatar 3-tầng, ngữ-cảnh profile

```dart
// learner-app/lib/widgets/menu/profile/profile_avatar_image.dart (trích)
Widget _image() {
  if (!isAuthenticated) {
    return Image.asset(AppAssets.avatar, /* bundled guest */);
  }
  final avatarUrl = _validAvatarUrl(data.avatarUrl);
  if (avatarUrl == null) return _initialAvatar();
  return Image.network(avatarUrl,
      errorBuilder: (_, _, _) => _initialAvatar());
}
```

Cùng whitelist `http||https` + `runes.first` như Bài 03 —
nhưng **nhánh guest khác**: guest luôn thấy `AppAssets.avatar`
bundled (không initial); chỉ user-auth-mới rơi vào URL/initial.
Hai widget (`ProfileAvatarImage`, `LeaderboardAvatar`) có
*quy-tắc-fallback khác nhau theo ngữ-cảnh* — đừng gộp một
hàm "avatar cho mọi nơi"; gộp = mất sắc-thái.

### Bước 4 — CTA là preset, không phải widget mới

```dart
// learner-app/lib/widgets/menu/gradient_cta_button.dart (gần-trọn)
return Padding(
  padding: const EdgeInsets.all(AppTokens.spacingMd),
  child: SizedBox(
    width: double.infinity,
    child: QzdsGameButton(
      text: buttonLabel,                 // l10n.startGameButton fallback
      color: AppTokens.qzdsPurple700,
      textGlow: true,
      scale: QzdsButtonScale.large,
      onTap: onTap,
    ),
  ),
);
```

`GradientCtaButton` là ví dụ "wrapper-cấu-hình": giá trị của
nó là **tên** (đọc `GradientCtaButton()` hiểu ngay "nút CTA
lớn") và **mặc-định** (label rỗng → `startGameButton`). Toàn
bộ vẽ/scale/glow/haptic nằm trong `QzdsGameButton` dùng-chung.

### Bước 5 — Inset, header, entry-card, re-port

```dart
// lib/widgets/menu/screen_top_inset.dart — verbatim 11 dòng
final topInset = MediaQuery.paddingOf(context).top;
return SizedBox(height: topInset > 0 ? topInset : 37);
```

```dart
// menu_profile_header.dart (trích)
GlassIconButton(
  assetIcon: AppAssets.iconGear,                     // SVG không IconData
  semanticLabel: l10n.settingsSemanticLabel,
  onTap: onSettingsTap,
);
// pill: accent = isAuthenticated ? mint500 : qzdsYellow500
// → vàng = "guest, progress local"; mint = "đã sync"
```

```dart
// leaderboard_entry_card.dart (trích)
SvgPicture.asset(AppAssets.iconTrophy, width: 28, height: 28,
  colorFilter: const ColorFilter.mode(AppTokens.white100,
                                      BlendMode.srcIn)),
Text(l10n.leaderboardTitle, …),
Text(l10n.menuLeaderboardEntrySubtitle, …),  // key mới Bài 01
```

:::caution[Re-port ≠ port-lần-đầu]
`menu_auth_dialog*`, `menu_sign_out_dialog*`,
`onboarding_overlay_scope`, `language_chip_row`,
`onboarding_game_button` **đã tồn tại** ở learner — nhưng là
bản *adapted* thời MenuTokens (literal thay token, bỏ sót
chi tiết). Sweep thay chúng bằng verbatim — quy-trình A-40
không hỏi "đã có chưa" mà hỏi "khớp chưa". Đây là chỗ FR-16/
FR-28-residual âm thầm converge.
:::

## Hiểu code — 6 chi tiết dễ trượt

**1. `Center` nằm *trong* `ConstrainedBox`, không phải ngoài**
— thứ-tự `SingleChildScrollView → ConstrainedBox(minHeight) →
Center → DesignFrame`: minHeight ép ít-nhất-cao-bằng-viewport
để `Center` có chỗ mà căn; đảo thứ tự → Center chỉ cao bằng
content → không căn gì.

**2. `panelGap` là `static const` *trên class*** — không phải
const file-level: nó là *tham-số thiết-kế của component này*
(gap giữa 4 card), đọc `MenuScreenContent.panelGap` từ test
layout được — test `menu_screen_content_layout_test` đo đúng
const này.

**3. `ringGradientFor` là `static` trên card** — test gọi
`LevelProgressCard.ringGradientFor(tier)` không cần pump;
gradient-theo-tier là pure-function → testable không-UI (12
case level-card test phần lớn là unit-logic).

**4. `Semantics(button: onTap != null, excludeSemantics: true)`**
trên entry-card — `button` chỉ true khi có handler (card vẫn
render khi `onTap:null`, chỉ không-tap-được);
`excludeSemantics` gộp con-thành-một-node tránh đọc-rời-rạc.

**5. `topInset > 0 ? topInset : 37`** — 37 là fallback của
senior cho môi-trường không-inset (widget-test/web); verbatim
cả literal — "magic number" này là *contract hiển-thị*, đổi nó
là đổi khoảng-trống header trên web.

**6. `menu_profile_header` pill-accent** — guest vàng, auth
mint: **màu là thông-tin** ("progress của bạn đang local"), không
phải trang-trí. `body5`+`caption3` hai-dòng tên/sub-status —
cùng anatomy `SettingsAccountRow` (Bài 02) — consistency có
chủ-đích.

## Chạy và quan sát

```bash
cd learner-app
flutter test test/widgets/menu_gradient_cta_button_test.dart \
             test/widgets/menu_level_progress_card_test.dart \
             test/widgets/menu_profile_avatar_test.dart \
             test/widgets/menu_screen_content_layout_test.dart
# 3 + 12 + 5 + 4 = 24 case mới
flutter test                 # 345/345 (+24)
wc -l lib/widgets/menu/**/*.dart | sort -n   # file nào > ~250?
```

Quan sát: màn menu hiển 4 card — level ring đổi màu khi level
qua mốc milestone; CTA "BẮT ĐẦU" phát-sáng; avatar guest vàng,
đăng-nhập-xong mint.

## Thử nghiệm

| Thử | Dự đoán | Thực tế |
|---|---|---|
| Thay `panelGap` bằng `Expanded` giữa các card | Màn cao trông sao? | Khoảng-trống *giữa* card giãn — card rời nhau, mất cụm "một panel". Spec: margin co-giãn, gap cố-định |
| `ringGradientFor` tô theo `progress.ratio` | Visual ổn hơn? | Mâu-thuẫn-ngữ-nghĩa: ring sẽ "đầy dần" như bar — hai chỉ-số tranh nhau. Senior cố-ý tách tier/ratio |
| Bỏ `ConstrainedBox(minHeight)` | Màn cao trông sao? | `Center` chỉ cao-bằng-content → cụm card dính-top thay-vì-giữa; scroll-view vẫn scroll nhưng layout-spec mất |
| Guest tap avatar, `isAuthenticated=false` | Avatar nào? | `AppAssets.avatar` bundled — initial chỉ dành user-auth-URL-lỗi; guest có *design riêng* |

## Lỗi hay gặp

| Lỗi | Vì sao | Sửa |
|---|---|---|
| Card cụm dính trên màn cao | thiếu `ConstrainedBox(minHeight: maxHeight)` hoặc `Center` sai chỗ | đúng thứ-tự Scroll→Constrained→Center |
| Ring đổi màu khi EXP tăng | nhầm `ringGradientFor(tier)` thành ratio-gradient | ring = tier (milestone), bar = ratio |
| `menuLeaderboardEntrySubtitle` undefined | Bài 01 chưa thêm key / chưa gen-l10n | regen; key là của Bài 01 |
| CTA không glow | thiếu `textGlow: true` hoặc `scale` sai | verbatim `GradientCtaButton` — preset đã-chọn-sẵn |
| File >250 dòng sau port | ghép 2 card vào một file | mỗi public-component một file — convention senior |

## Tự làm

**PREDICT** — Một dev bỏ `ConstrainedBox(minHeight:)` và than
phiền "màn điện-thoại-nhỏ bị overflow". Thực tế widget nào cứu
overflow, và widget nào cứu căn-giữa?

:::note[Gợi ý]
Hai vấn đề khác nhau được hai widget khác nhau xử — tìm đúng
vai của `SingleChildScrollView` vs `Center`.
:::

<details>
<summary>Đáp án</summary>

`SingleChildScrollView` cứu overflow (màn thấp → cuộn);
`Center`+`ConstrainedBox(minHeight: viewport)` cứu căn-giữa
(màn cao → block đứng giữa). Bỏ ConstrainedBox: màn thấp vẫn
cuộn ngon nhưng màn cao mất căn — hai nửa của cùng một spec
"co-giãn theo chiều cao", thiếu một là chỉ đúng nửa trường-hợp.

</details>

**DEBUG** — `menu_level_progress_card_test` đỏ: "expected
`levelRingMilestoneGradient`, found `levelRingGradient`" ở
level 5. Đọc `MenuLevelProgress.tier` + `LevelConfig`, nói
level 5 ra tier gì và vì sao.

:::note[Gợi ý]
Tier = milestone *cao nhất đã đi qua* — vòng lặp `passed <=
level` kiểm `isMajorMilestone` rồi `isMilestoneLevel`.
:::

<details>
<summary>Đáp án</summary>

Level 5 là `isMilestoneLevel(5)==true` trong `LevelConfig` →
vòng lặp ghi `reached = milestone` → tier `milestone` → ring
dùng `levelRingMilestoneGradient`. Nếu test kỳ-vọng base thì
test sai; nếu code trả base thì `isMilestoneLevel` không được
kiểm. Điểm-suy-luận nằm hết trong `MenuLevelProgress.tier` —
pure logic, test không cần widget.

</details>

**PRODUCE** — Viết `_rowGradient`-kiểu-senior cho một
`StatsChip` mới: enum `StatsTone{neutral,positive,negative}` →
`Color` textColor qua switch-expression. Đặt hàm ở đâu — card
hay token?

:::note[Gợi ý]
Nghĩ theo A-38: tone→color là quy-tắc-của-component hay quy-
tắc-của-hệ-thống? `ringGradientFor` nằm đâu?
:::

<details>
<summary>Đáp án</summary>

```dart
enum StatsTone { neutral, positive, negative }

Color textColorFor(StatsTone tone) => switch (tone) {
  StatsTone.neutral => AppTokens.white72,
  StatsTone.positive => AppTokens.green400,
  StatsTone.negative => AppTokens.red500,
};
```

Đặt **trên card** (`static`/top-level trong file card) — theo
mẫu `ringGradientFor`: tone→color là quy-tắc-trình-bày của
component, không phải foundation. `AppTokens` chỉ chứa *giá
trị*; *mapping* enum→giá-trị sống cạnh nơi dùng.

</details>

## Kiểm tra hiểu biết

**H: Vì sao decomposition ra file lại là việc của sweep?** —
Vì điều-kiện-tiên-quyết: Bài 05 cần `MenuScreenView` với Stack
để cắm `MenuDialogLayer`; screen-private-widget không có chỗ
cắm. Và "file nhỏ" làm diff-với-senior đọc-được (A-40).

**H: `GradientCtaButton` có vẽ gì không?** — Không. Nó là
preset `QzdsGameButton(scale: large, textGlow: true,
color: qzdsPurple700)` + label-fallback — giá trị nằm ở tên-
gọi-ngữ-nghĩa và tham-số-đã-chọn, không phải paint-code.

**H: Khác biệt `ProfileAvatarImage` vs `LeaderboardAvatar`?** —
Cùng whitelist-URL + initial-fallback, khác *nhánh guest*:
profile-guest → `AppAssets.avatar` bundled; leaderboard-current-
user-null-url → initial (không dùng asset guest). Ngữ-cảnh
quyết fallback — không gộp chung.

**H: `MenuLevelProgress` có từ M22 — sao giờ mới có visual?** —
M22 port data-side trước (tier/ratio/format). Visual ring cần
asset/tokens/glass — đợi nền M28+M29·01. Đây là kiểu "data
trước, pixel sau" xuyên-milestone.

## Ta cố ý chưa thêm

- **`MenuScreenView` chưa có Stack/dialog-layer** — view hiện
  chỉ ghép header+content+CTA; `MenuDialogLayer` +
  `OnboardingOverlayScope`-trong-stack đến Bài 05 (bản scope
  re-port ở đây chỉ là file verbatim, chưa lắp vào chỗ mới).
- **Không port `earnings_card`/`stats_card` nội-dung chi-tiết
  ở đây** — chúng verbatim senior (gradient + định-dạng tiền);
  bài này dạy *bố cục và quy-tắc*, không liệt-kê-từng-dòng.
- **Auth dialog *visual* chưa mở** — file verbatim đã vào,
  nhưng `MenuDialogAuth` variant mở nó là chuyện Bài 05.
- **Không xoá `menu_tokens.dart` ở đây** — còn consumer
  onboarding; xoá ở Bài 06 khi onboarding-visual xong.

## Checkpoint hoàn thành

- [x] `MenuScreenContent`: 4 card, `panelGap` token, LayoutBuilder
      + `minHeight` + `Center` — "màn thấp scroll, màn cao giữa".
- [x] `profile/` 5 file verbatim: pill guest-vàng/auth-mint,
      ring-theo-tier + EXP bar (hai kênh hai nghĩa), avatar
      3-tầng-fallback.
- [x] `GradientCtaButton` preset `QzdsGameButton` large+textGlow;
      `ScreenTopInset` fallback 37; entry-card trophy `srcIn` +
      `menuLeaderboardEntrySubtitle`.
- [x] Auth dialogs + `OnboardingOverlayScope` + `LanguageChipRow`
      + `OnboardingGameButton` **re-port verbatim** — bản
      MenuTokens-era retire.
- [x] `flutter analyze` clean · `flutter test` **345/345**
      (+24: cta 3 + level-card 12 + avatar 5 + layout 4).
