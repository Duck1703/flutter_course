---
title: "Bài 1 · Nền móng — dependencies, assets, design tokens"
description: "Hai dep đúng pin senior (flutter_svg ^2.3.0, google_fonts ^8.1.0) + hai asset-dir + 7 SVG + 1 PNG. `AppAssets` subset 8 const cố ý (còn lại → M29). `AppTokens` 318 dòng verbatim — spacing/icon/radius/motion/màu/typography GoogleFonts + `screenDesignWidth = 375` + `DesignFrame`. `surfaceGlow`/`FillBoxGradientTransform` + `headerSheen`. 6 ARB key semantics mới + regen gen-l10n. CORE: tokens là nguồn đúng duy nhất. +0 test → 259."
sidebar:
  label: "Bài 1 · tokens & assets"
  order: 1
---

## Mục tiêu

- Nêu được bài toán cảm nhận: mọi màu/khoảng cách/cỡ chữ đang
  nằm rải rác trong `MenuTokens` (bộ token tự sinh M14) và hardcode
  trong widget — không ai ngăn hai nút cùng vai trò dùng hai màu
  khác nhau.
- Phát biểu mental model: design token là
  *nguồn đúng duy nhất* — widget đọc `AppTokens.*`, không bao giờ
  tự nghĩ ra `Color(0xFF…)` hay `SizedBox(height: 44)` trần.
- Thêm đúng 2 dependency senior (`flutter_svg`, `google_fonts`)
  + 2 asset-dir vào `pubspec.yaml`, copy 7 SVG + 1 PNG.
- Viết `AppAssets` như một **subset có chủ đích** — chỉ 8 const
  cho asset thực sự shipped, phần còn lại chờ widget của nó ở M29.
- Hiểu `surfaceGlow`/`FillBoxGradientTransform` giải quyết bài
  toán "radial gradient trên surface dẹt" và `headerSheen` là
  gloss tuyến tính cố định cho title-bar dialog.
- Hiểu `screenDesignWidth = 375` + `DesignFrame` = triết lý
  "một khung thiết kế cố định, căn giữa" thay cho responsive
  `MediaQuery`.
- +0 test → suite giữ **259/259** (chưa widget nào dùng — nền
  móng land trước, consumer đến sau).

## Bạn đang ở đâu

- Cuối M27: `flutter test` **259/259**. App chạy trọn ván chơi
  bằng DRE thuần, notification + share + version đều thật.
- Hệ token hiện có là `MenuTokens` — bộ constants learner tự
  chế từ M14: đủ dùng cho menu phẳng, nhưng *không* có
  typography ramp, không motion tokens chuẩn senior, không
  `screenDesignWidth`, không bảng màu `qzds*`/`purple*`/`white*`
  mà visual senior cần.
- `pubspec.yaml` hiện chưa có `flutter_svg` (không render được
  SVG senior) và chưa có `google_fonts` (không có BeVietnamPro
  ramp).
- Không có `assets/` section nào trong pubspec — app chưa ship
  file asset nào.
- Icon đi qua `GameFeatureButtonData.icon: IconData` (Material
  icons) — pipeline SVG chưa tồn tại.

## Vì sao việc này quan trọng ngay bây giờ

- Năm bài sau sẽ port hàng chục widget senior — *tất cả* đều
  `import 'package:…/core/app_design_tokens.dart'` làm import đầu
  tiên. Nếu bài này chưa land, không file nào compile được.
- `AppTokens`/`AppAssets` là *điểm quy chiếu duy nhất* — khi
  senior sửa `spacingMd` hay đổi font, một dòng thay đổi lan ra
  toàn app. Hardcode rải rác làm mất đặc tính đó ngay lập tức.
- `google_fonts` fetch font *lúc runtime* (không bundle trong
  assets) — hiểu ngay từ đầu để không bất ngờ khi offline lần
  đầu render ra font hệ thống (parity senior — không "sửa").
- Thứ tự asset trước widget là bắt buộc: `Image.asset`/
  `SvgPicture.asset` fail lúc *runtime* nếu pubspec thiếu khai
  báo dir — nhưng `flutter analyze`/`flutter test` không bắt.
  Bài này đặt nền cho lỗi ở runtime đó.

## Bạn đã biết gì

- `pubspec.yaml` + `flutter pub get` — đã thêm dep ở M03
  (`provider`), M22 (supabase), M27 (5 dep platform).
- `import` + `export` — barrel file export lại file khác
  để consumer chỉ cần một import (Dart `export` cơ bản — chưa
  có registry row riêng).
- `static const` trên class — `MenuTokens.spacingMd`
  chính là shape này; `AppTokens` cùng pattern, quy mô lớn hơn.
- `LinearGradient`/`RadialGradient` — đã dùng trong
  `MenuTokens.cardBackground`/`accentCyan` decorations
  (chưa có registry row riêng — reuse từ code M-menu).
- ARB + `flutter gen-l10n` + placeholder `{name}` 
  — pipeline i18n M17 y nguyên.
- `BoxConstraints`/`ConstrainedBox`/`Center` — layout
  primitives đã quen.

## Mental model mới — "tokens là nguồn đúng duy nhất" (CORE)

> **Design tokens as single source of truth.** Mọi giá
> trị visual dùng lại (màu, spacing, radius, icon-size, motion
> duration, typography, design-width) sống trong *một* class
> `static const` / `static get` — `AppTokens`. Widget *đọc*;
> không widget nào *invent* giá trị visual.

Ba hệ quả:

1. **Đổi một chỗ, lan toàn app.** Đổi `qzdsButtonHeight = 44`
   thành `48` → mọi pill button cao hơn — kể cả test vẫn xanh
   vì test assert token, không assert số cứng (xem Bài 2).
2. **Tên mang ngữ nghĩa, không mang giá trị.** `white16` đọc
   là "white 16% alpha" — nhìn tên biết ngay độ mờ; `spacingSm`
   = "khoảng nhỏ" — không cần nhớ 12 là nhỏ hay vừa.
3. **File tokens export thêm tiện ích.** `app_design_tokens.dart`
   không chỉ chứa const — nó `export 'app_assets.dart'` +
   `export 'surface_glow_gradient.dart'` nên *một* import duy
   nhất đưa consumer cả token lẫn asset-path lẫn helper
   gradient. Đó là lý do mọi widget senior chỉ cần
   `import '../../core/app_design_tokens.dart';`.

Một cặp song hành:

- **`AppAssets`** = cùng ý tưởng cho *đường dẫn asset*: string
  path nằm một chỗ, đổi tên file chỉ sửa const — widget không
  hardcode `'assets/images/icons/game-back.svg'`.
- **`DesignFrame`** = ý tưởng này ở *layout*: `Center` +
  `ConstrainedBox(maxWidth: AppTokens.screenDesignWidth)` —
  "app thiết kế cho khung 375pt, căn giữa trên màn rộng"
  thay vì đo `MediaQuery` mọi nơi.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
| --- | --- |
| `export 'app_assets.dart';` | re-export — consumer của `app_design_tokens.dart` thấy luôn `AppAssets` + `surfaceGlow` mà không import thêm (barrel `export` — chưa có registry row). File tokens có 2 export ở dòng 4–5 |
| `static const double/Color/Duration` | token constants — compile-time, không instance (reuse) |
| `static TextStyle get body3 => GoogleFonts.beVietnamPro(…)` | getter thay const — `TextStyle` không const được vì `GoogleFonts.*` là factory runtime (biến thể) |
| `Color(0x14FFFFFF)` | ARGB hex: hai chữ số đầu là alpha — `0x14` ≈ 8% → `white08`, `0x1A` ≈ 10% → `white10`… đọc tên là biết alpha |
| `color.withValues(alpha: color.a * edgeOpacity)` | API mới của `Color` — `withValues` thay `withOpacity` (deprecated): nhân alpha giữ nguyên RGB; `color.a` đọc kênh alpha 0..1 |
| `Matrix4.identity()..translateByDouble(…)` | cascade trên `Matrix4` — build phép biến hình affine cho `GradientTransform` (LIGHT — chưa cần thông ma trận, chỉ cần hiểu "dịch gốc → scale → dịch lại") |
| `enum QzdsButtonScale { compact, large }` | hai preset kích thước pill — Bài 2 dùng `scale` để chọn padding/font |

## Flutter cần dùng

| API | Vai trò |
| --- | --- |
| `pubspec.yaml` `dependencies:` | `flutter_svg: ^2.3.0` — render SVG (`SvgPicture.asset`, Bài 2); `google_fonts: ^8.1.0` — `GoogleFonts.beVietnamPro` type ramp (fetch runtime, không bundle) |
| `pubspec.yaml` `flutter.assets:` | khai báo **thư mục** asset — `assets/images/icons/` + `assets/images/backgrounds/`; thiếu dir → `Image.asset`/`SvgPicture.asset` throw lúc *runtime* (analyze không bắt) |
| `ConstrainedBox(BoxConstraints(maxWidth: …))` | giới trên chiều rộng — `DesignFrame` bọc nó trong `Center` |
| `RadialGradient(transform: …)` | `transform` xoay/co giãn không gian gradient trước khi vẽ — `FillBoxGradientTransform` kéo tròn thành elip |
| `GradientTransform.transform(bounds, {textDirection})` | override trả `Matrix4` (hoặc `null` = không transform) — hook duy nhất của class |
| `GoogleFonts.beVietnamPro(fontSize: …, fontWeight: …, color: …)` | trả `TextStyle` dùng font BeVietnamPro — fetch qua mạng lần đầu, cache sau; senior verbatim (không bundle font) |
| `Image.asset` / `SvgPicture.asset` (preview) | đọc asset đã khai báo — Bài 2 render thật |

## Ví dụ độc lập — token class + một consumer (DartPad)

```dart
// ISOLATED EXAMPLE — not in project. Thu nhỏ từ senior: một class
// const, widget chỉ đọc — đổi token đổi cả app.
class MiniTokens {
  static const spacing = 12.0;
  static const accent = 0xFF00E0FF; // cyan
  static const buttonHeight = 44.0;
  static const buttonPadding = 14.0;
}

// "Widget" giả: builder thuần in ra spec — đứng yên khi token đổi.
String describePill({required String label}) =>
    'Pill[$label] h=${MiniTokens.buttonHeight} '
    'pad=${MiniTokens.buttonPadding} gap=${MiniTokens.spacing} '
    'color=#${MiniTokens.accent.toRadixString(16).padLeft(8, '0')}';

void main() {
  print(describePill(label: 'TIẾP TỤC'));
  // Pill[TIẾP TỤC] h=44.0 pad=14.0 gap=12.0 color=#ff00e0ff
  // Đổi MiniTokens.buttonHeight = 48 → mọi "pill" cao hơn mà
  // describePill không sửa một chữ — đó là single source of truth.
}
```

Shape y hệt `AppTokens`: `static const` + consumer chỉ đọc —
điểm khác duy nhất là `AppTokens` có cả `static get` cho
`TextStyle` (không const được).

## Android / Compose bridge

**SIMILARITY — `AppTokens` ≈ `dimens.xml` + `Color.kt` theme
object gộp một chỗ.** Trên Android bạn đặt spacing trong
`res/values/dimens.xml`, màu trong theme/`Color.kt`; Compose đọc
`MaterialTheme.colorScheme`/`dimensionResource`. `AppTokens`
gom *tất cả* (màu + spacing + radius + motion + typography) vào
một file Dart — gần với một `object AppTheme` khổng lồ hơn là
resource XML.

**IMPORTANT DIFFERENCE — token Dart là *code*, không phải
resource.** Không có qualifier `values-sw600dp`, không runtime
resource-lookup; `static const` inline thẳng vào binary. Muốn
"responsive" thì tự viết (và senior *không* viết — một khung
375 cố định). `GoogleFonts.beVietnamPro` cũng là code — nó
download font lúc runtime, khác hẳn `res/font/bevietnam.ttf`
bundled: **không có fallback offline ngoài font hệ thống**.

**DO NOT ASSUME — `assets:` trong pubspec ≠ `res/` tự đóng gói.**
Flutter chỉ ship file nằm dưới dir đã khai báo *verbatim*;
thiếu dòng `- assets/images/backgrounds/` thì `Image.asset` throw
`Unable to load asset` lúc chạy — `flutter analyze` *không* bắt
vì path chỉ là `String`. Và khác `R.drawable`: không có symbol
sinh tự động — `AppAssets.iconGameBack` là `String` const tay
viết, gõ sai là lỗi runtime.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
| --- | --- |
| `pubspec.yaml` — `flutter_svg: ^2.3.0`, `google_fonts: ^8.1.0` + `assets:` 2 dir | learner pin + khai báo y hệt |
| `lib/core/app_design_tokens.dart` (318 dòng) | **verbatim-port** — diff 0 sau rename; mọi const/getter + `QzdsButtonScale` + 2 `export` giữ nguyên |
| `lib/core/surface_glow_gradient.dart` (72 dòng) | **verbatim-port** — `FillBoxGradientTransform` + `surfaceGlow` + `headerSheen` |
| `lib/widgets/common/design_frame.dart` (20 dòng) | **verbatim-port** — `Center` + `ConstrainedBox(maxWidth: 375)` |
| `lib/core/app_assets.dart` (73 dòng, ~66 const) | learner port **subset 8 const** — chỉ asset thực shipped; ~58 const còn lại → M29 cùng widget của chúng |

:::tip[Suy ra trước — lookup layer `AppAssets` + `AppTokens`]
Trước khi thấy 318 dòng verbatim, tự thiết kế lớp tra cứu:

1. **`AppAssets` cần gì?** 8 file asset — nên là gì: `const String`
   path đầy đủ, hay base-dir + tên file ghép lại? Gõ một `class` với
   8 const theo tên bạn chọn — so với senior ngay sau.
2. **Tại sao không `Image.asset` trực tiếp?** Widget vẫn có thể gọi
   path string trần — chuyện gì hỏng khi asset đổi tên / đổi dir /
   thêm variant? Viện dẫn *ví dụ đổi tên* cụ thể.
3. **Token vs tham số widget.** `screenDesignWidth = 375` sống ở
   `AppTokens` hay truyền vào `DesignFrame`? — suy luận từ "ai
   được phép đổi nó, và đổi một chỗ hay mọi chỗ?".
4. **`IconAsset` tới SVG thế nào?** `GameFeatureButton` nhận
   `IconAsset` — ai biến nó thành `SvgPicture`: widget, mapper,
   hay `AppAssets` tự render?
:::

## Build it step by step

**Bước 1 — `pubspec.yaml`: hai dep + hai asset-dir.**

Cuối block `dependencies:` (verbatim senior pins):

```yaml
  # M28: hai pin đúng senior — `SvgPicture.asset` cho icon pipeline,
  # `GoogleFonts.beVietnamPro` cho type ramp trong AppTokens.
  flutter_svg: ^2.3.0
  google_fonts: ^8.1.0
```

Trong block `flutter:` (sau `uses-material-design: true`):

```yaml
  # M28: subset asset senior — game icons (SVG) + game screen
  # background. Full senior asset parity cố ý dời M29.
  assets:
    - assets/images/icons/
    - assets/images/backgrounds/
```

rồi `flutter pub get`. Vai trò từng dep:

| Dep | Việc |
| --- | --- |
| `flutter_svg` | `SvgPicture.asset` render SVG — pipeline icon lifeline/back/lightning/money (Bài 2, 5, 6) |
| `google_fonts` | `GoogleFonts.beVietnamPro` → `TextStyle` cho toàn bộ type ramp của `AppTokens` — fetch font qua mạng lần đầu (senior cũng vậy — parity cố ý, không bundle) |

**Bước 2 — copy 8 asset file.** Tạo hai thư mục và copy
verbatim từ senior repo `assets/images/`:

```text
assets/images/icons/game-audience.svg
assets/images/icons/game-back.svg
assets/images/icons/game-fifty-fifty.svg
assets/images/icons/game-lightning.svg
assets/images/icons/game-money.svg
assets/images/icons/game-sparkle.svg
assets/images/icons/game-trophy.svg
assets/images/backgrounds/menu-background.png
```

Đúng 7 icon game + 1 background — **không** copy avatar/
decorations/leaderboard/settings icon của senior (chính sách
subset: asset đi cùng widget dùng nó; widget đó → M29).

**Bước 3 — `lib/core/app_assets.dart`** (19 dòng, subset có
chủ đích):

```dart
/// M28: subset port của `AppAssets` senior — CHỈ khai báo asset paths
/// cho file thực sự shipped trong `assets/` ở milestone này (game
/// icons SVG + menu/game background). Các constant senior còn lại
/// (avatars, decorations, leaderboard, settings icons) sẽ được thêm
/// khi widget dùng chúng được port ở M29 — tránh dangling asset refs.
class AppAssets {
  static const String menuBackground =
      'assets/images/backgrounds/menu-background.png';
  static const String iconGameBack = 'assets/images/icons/game-back.svg';
  static const String iconGameFiftyFifty =
      'assets/images/icons/game-fifty-fifty.svg';
  static const String iconGameAudience = 'assets/images/icons/game-audience.svg';
  static const String iconGameSparkle = 'assets/images/icons/game-sparkle.svg';
  static const String iconGameTrophy = 'assets/images/icons/game-trophy.svg';
  static const String iconGameLightning =
      'assets/images/icons/game-lightning.svg';
  static const String iconGameMoney = 'assets/images/icons/game-money.svg';
}
```

Vì sao chỉ 8/66 const? — `AppAssets` trỏ tới file *phải tồn
tại*; khai báo const cho file chưa ship = dangling ref chờ ai
đó dùng nhầm. Khi M29 port widget settings/leaderboard, nó thêm
const + asset cùng lúc.

**Bước 4 — `lib/core/surface_glow_gradient.dart`** (72 dòng,
verbatim senior). Hai thứ cần thấy:

```dart
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
  // + operator== / hashCode — immutable value để Flutter so sánh
  // gradient giữa các lần rebuild.
}
```

và hàm helper:

```dart
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
```

**Bài toán nó giải:** `RadialGradient` của Flutter đo `radius`
theo `rect.shortestSide` — trên pill dẹt (rộng, thấp) vòng tròn
dừng giữa chừng → vệt sáng "đứng hình" ở giữa. Transform scale
mỗi trục theo tỉ lệ khung → tròn thành elip phủ hết box.
`headerSheen` (ở cuối file) là `LinearGradient` trắng
top→bottom cho title-bar dialog — gloss không màu để bar màu
nào cũng dùng được.

**Bước 5 — `lib/core/app_design_tokens.dart`** (318 dòng,
verbatim senior — diff 0 sau rename). Không cần gõ lại toàn bộ;
hiểu cấu trúc:

```dart
export 'app_assets.dart';
export 'surface_glow_gradient.dart';

enum QzdsButtonScale { compact, large }

class AppTokens {
  static const double spacingMd = 16;
  // … spacing/icon/radius/motion ~40 const …
  static const Duration motionMedium = Duration(milliseconds: 220);
  static const Duration dialogMotionLong = Duration(milliseconds: 300);
  static const double screenDesignWidth = 375;
  // … ~60 Color const (blue/purple/yellow/white-alpha/qzds*) …
  static TextStyle get body3 => GoogleFonts.beVietnamPro(
        fontSize: 14,
        // … ~25 TextStyle getter cho cả ramp …
      );
}
```

Ba vùng cần nhớ: **kích thước** (`spacing*`/`icon*`/`radius*`/
`qzdsButtonHeight=44`/`screenDesignWidth=375`), **thời gian**
(`motionFast=120`/`motionMedium=220`/`motionSlow=450`/
`dialogMotionLong=300`), **màu + chữ** (~60 `Color` const +
~25 `TextStyle get` qua `GoogleFonts.beVietnamPro`).

**Bước 6 — `lib/widgets/common/design_frame.dart`** (20 dòng,
verbatim):

```dart
class DesignFrame extends StatelessWidget {
  final Widget child;

  const DesignFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppTokens.screenDesignWidth,
        ),
        child: child,
      ),
    );
  }
}
```

Một widget duy nhất gói "căn giữa + giới hạn 375" — top bar,
body, feature bar, dialog layer của senior đều bọc trong nó
(Bài 3/5/6 thấy dùng thật). `maxWidth` chỉ là *giới trên* —
màn hẹp hơn 375 thì child vẫn co theo.

**Bước 7 — ARB: 6 key semantics mới.** Thêm vào `app_en.arb`
(sau block `@ladderOptionSemanticLabel` hiện có — giữ thứ tự
alphabet của file):

```json
  "optionSemanticLabel": "Option {label}, {answer}",
  "@optionSemanticLabel": {
    "placeholders": {"label": {"type": "String"}, "answer": {"type": "String"}}
  },
  "selectedStateLabel": "Selected",
  "correctStateLabel": "Correct",
  "incorrectStateLabel": "Incorrect",
  "prizeAmountSemanticLabel": "Prize amount {amount}",
  "@prizeAmountSemanticLabel": {
    "placeholders": {"amount": {"type": "String"}}
  },
  "timeRemainingSemanticLabel": "Time remaining {time}",
  "@timeRemainingSemanticLabel": {
    "placeholders": {"time": {"type": "String"}}
  },
```

và `app_vi.arb` (không cần `@` metadata — placeholder thừa hưởng
từ locale template `en`):

```json
  "optionSemanticLabel": "Đáp án {label}, {answer}",
  "selectedStateLabel": "Đã chọn",
  "correctStateLabel": "Đúng",
  "incorrectStateLabel": "Sai",
  "prizeAmountSemanticLabel": "Giải thưởng {amount}",
  "timeRemainingSemanticLabel": "Thời gian còn lại {time}",
```

Chạy `flutter gen-l10n` (hoặc `flutter pub get` — gen chạy tự
động theo `generate: true`) để regenerate `app_localizations*.dart`.
`correctStateLabel` tiếng Việt phải là `"Đúng"` đầy đủ — bản
gõ tắt `"Đú"` là bug thật từng lọt ở bước này.

**Bước 8 — `flutter analyze` + `flutter test`** → **259/259**
giữ nguyên: chưa widget nào import `AppTokens`/`AppAssets` —
bài này chỉ đặt nền.

## Hiểu code — ba chi tiết dễ trượt

1. **`export` trong file tokens là load-bearing.** Widget senior
   viết `import '../../core/app_design_tokens.dart'` *một dòng* —
   nhờ 2 `export` mà `AppAssets` + `surfaceGlow` đi theo. Xoá
   `export 'app_assets.dart'` → mọi `AppAssets.iconGameBack` ở
   widget senior lỗi undefined mà không ai hiểu vì sao (họ
   tưởng import tokens là đủ — đúng, *nhờ* export).
2. **`TextStyle` là `static get`, không phải `static const`.**
   `GoogleFonts.beVietnamPro(…)` là factory gọi runtime (đăng ký
   font, fetch/cache) → không const được. Mỗi lần đọc
   `AppTokens.body3` là một `TextStyle` mới — rẻ, nhưng đừng so
   `identical()`.
3. **`screenDesignWidth = 375` là design-decision, không phải
   responsive.** Nó *không* đo màn hình — là số cố định của
   design system senior. `DesignFrame` + `ConstrainedBox` nghĩa
   là "màn rộng → cột giữa 375; màn hẹp → full-bleed". (Manifest
   ghi discrepancy: tài liệu course nhắc "390pt convention" — **disk là
   nguồn đúng: 375**.)

## Chạy và quan sát

```text
flutter pub get  → resolves 2 pin mới
flutter analyze  → No issues found!
flutter test     → +259: All tests passed!   (không đổi — chưa ai dùng)
```

Kiểm chứng nhanh dep: `flutter pub deps | grep flutter_svg`
(PowerShell: `| findstr …`). Kiểm chứng asset: `dir
assets\images\icons` thấy đủ 7 SVG.

## Thử nghiệm

Xoá dòng `- assets/images/backgrounds/` khỏi pubspec,
`flutter pub get` + `flutter test` — đoán suite có đỏ không?
Sau đó suy ra *đường nào* sẽ hỏng và *khi nào*.

<details>
<summary>Đáp án</summary>

Suite **không đỏ** — asset-path chỉ là `String`; analyze không
resolve nó, và *hiện tại* chưa widget nào render
`AppAssets.menuBackground` (Bài 2 mới có `GameScreenBackground`).
Hỏng ở **runtime** khi `Image.asset('assets/images/backgrounds/
menu-background.png')` chạy: `Unable to load asset` → exception
trong frame. Đây chính là lớp lỗi mà test widget không gánh
được cho đến khi consumer render thật — lý do asset-dir land
trước widget.
</details>

## Lỗi hay gặp

1. **Khai `assets:` sai indent** — `assets:` nằm *dưới* `flutter:`,
   cùng cấp `uses-material-design`; lệch indent → pub get lỗi
   YAML hoặc Flutter không thấy asset.
2. **Khai file cụ thể thay vì dir** — khai `-
   assets/images/icons/game-back.svg` thì chỉ file đó ship;
   senior khai *dir* (`…/icons/`) để mọi file trong dir vào bundle.
3. **Port hết `AppAssets` senior ngay bây giờ** — 58 const còn
   lại trỏ file chưa tồn tại trong `assets/`; không ai dùng thì
   vô hại, nhưng một widget import sớm sẽ runtime-crash trên
   path không có file → chờ M29.
4. **Quên `flutter gen-l10n` sau khi sửa ARB** — code gọi
   `l10n.timeRemainingSemanticLabel` lỗi undefined getter cho
   tới khi gen lại (Bài 3 mới có caller — nhưng quên bây giờ
   thì Bài 3 vỡ).
5. **Bundle font vào `assets/fonts/` "cho chắc"** — senior
   *không* bundle; `GoogleFonts` tự fetch. Thêm file font là
   diverge khỏi senior + tăng bundle size.

## Tự làm — PRODUCE

Trên DartPad, viết `MyAssets` — một class theo shape `AppAssets`
cho ba icon settings *giả tưởng* (`assets/images/icons/setting.svg`,
`speaker.svg`, `music.svg`) — kèm doc-comment 1 dòng nói rõ đây
là "subset chờ M29". Sau đó viết `describeIcon(String path)` in
`'<basename>'` từ path (`path.split('/').last`) và verify trên
ba const.

:::note[Gợi ý]
Shape: `class MyAssets { static const String x = '…'; }` —
không constructor, không instance.
:::

<details>
<summary><strong>Đáp án</strong></summary>

```dart
/// Subset-cho-sau: ba icon settings chưa shipped — demo shape
/// AppAssets, file thật + const thật land cùng widget M29.
class MyAssets {
  static const String iconSetting = 'assets/images/icons/setting.svg';
  static const String iconSpeaker = 'assets/images/icons/speaker.svg';
  static const String iconMusic = 'assets/images/icons/music.svg';
}

String describeIcon(String path) => path.split('/').last;

void main() {
  print(describeIcon(MyAssets.iconSetting)); // setting.svg
  print(describeIcon(MyAssets.iconSpeaker)); // speaker.svg
  print(describeIcon(MyAssets.iconMusic));   // music.svg
}
```

Đây đúng cách `AppAssets` sẽ mọc ở M29: const mới *và* file
mới cùng một bước, không const mồi.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao `AppTokens.body3` là `static get` còn
  `AppTokens.spacingMd` là `static const`? — **Đáp:** `TextStyle`
  qua `GoogleFonts.beVietnamPro` là giá trị runtime (font fetch/
  cache); `double` là literal compile-time — const được.
- **Hỏi:** `AppAssets` chỉ có 8/66 const của senior — thiếu có
  phải bug? — **Đáp:** không, là chính sách subset: const trỏ
  file chưa ship = dangling ref; M29 thêm const + file cùng
  widget dùng chúng.
- **Hỏi:** `export 'app_assets.dart'` trong file tokens làm
  gì? — **Đáp:** re-export — consumer import `app_design_tokens.
  dart` một dòng thấy luôn `AppAssets`/`surfaceGlow`; không cần
  import thứ hai.
- **Hỏi:** `screenDesignWidth = 375` đo màn hình thiết bị à? —
  **Đáp:** không — const cố định của design system; `DesignFrame`
  + `ConstrainedBox(maxWidth: 375)` căn giữa trên màn rộng.
- **Hỏi:** thiếu `- assets/images/backgrounds/` trong pubspec
  thì `flutter analyze` bắt không? — **Đáp:** không — path là
  `String` thường; lỗi chỉ xuất hiện khi `Image.asset` chạy
  (runtime `Unable to load asset`).

## Ta cố ý chưa thêm

- Bất kỳ widget nào **dùng** `AppTokens`/`AppAssets`/`DesignFrame`
  — Bài 2/3/5/6 mới có consumer; bài này compile độc lập.
- `MenuTokens` → `AppTokens` migration cho widget cũ — **M29**
 (phần còn lại); hai bộ token cùng tồn tại tạm thời.
- `AppAssets` 58 const còn lại + asset files tương ứng — **M29**
  (chính sách subset).
- Test cho tokens/assets — senior cũng không test const file;
  verify bằng consumer test (Bài 2+).
- Font files bundled — `GoogleFonts` runtime-fetch là parity
  senior (không bundle).
- i18n cho `GameScreenTopBar`/painter — timer semantic label dùng
  key `timeRemainingSemanticLabel` vừa thêm (Bài 3 render thật).

## Checkpoint hoàn thành

- [ ] `pubspec.yaml` có đủ 2 pin (`flutter_svg ^2.3.0`,
  `google_fonts ^8.1.0`) + 2 `assets:` dir; `flutter pub get` xanh.
- [ ] `assets/images/icons/` có đúng 7 SVG game;
  `assets/images/backgrounds/menu-background.png` tồn tại.
- [ ] `lib/core/app_assets.dart` (8 const), `surface_glow_gradient.
  dart`, `app_design_tokens.dart` (2 `export` + `QzdsButtonScale` +
  `screenDesignWidth = 375`), `widgets/common/design_frame.dart`
  tồn tại — verbatim senior (trừ `AppAssets` subset + comment VI).
- [ ] `app_en.arb`/`app_vi.arb` có 6 key mới; `gen-l10n` sinh
  getter `optionSemanticLabel`/`timeRemainingSemanticLabel`/…;
  `correctStateLabel` vi = `"Đúng"`.
- [ ] `flutter analyze` sạch; `flutter test` **259/259** (+0 —
  nền móng land, consumer chưa có).
