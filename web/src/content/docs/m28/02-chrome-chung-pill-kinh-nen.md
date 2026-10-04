---
title: "Bài 2 · Chrome chung — pill button, nút kính SVG, nền màn"
description: "Ba widget common đầu tiên dùng nền móng Bài 1: `QzdsGameButton` (pill 44pt + surfaceGlow + BoxShadow + `if (icon case final iconData?)` — mới), `GlassIconButton` (`SvgPicture.asset` + `ColorFilter.mode(Colors.white, BlendMode.srcIn)` — mới), `GameScreenBackground` (ColoredBox + gradient + Image.asset cover). Test `qzds_game_button_test` 4 case đầu tiên của milestone. +4 test → 263."
sidebar:
  label: "Bài 2 · chrome chung"
  order: 2
---

## Mục tiêu

- Port ba widget common verbatim: `QzdsGameButton` (pill action
  dùng khắp dialog/menu), `GlassIconButton` (nút tròn kính chứa
  SVG — nút back của game), `GameScreenBackground` (nền màn chơi:
  màu nền + gradient + ảnh cover mờ).
- Học **`SvgPicture.asset` + `ColorFilter.mode(…, BlendMode.srcIn)`**
 (NORMAL) — pipeline icon của senior: SVG trắng, tô màu
  qua colorFilter lúc render.
- Học **`if (x case final y?)`** — if-case null-extract
 (NORMAL): optional `IconData?` bung ra thành non-null
  `iconData` ngay trong `children:` list.
- Thấy `surfaceGlow` (Bài 1) làm việc thật trên surface dẹt
  44pt; `Semantics(button/enabled/label)` + `ExcludeSemantics`
 phục vụ a11y đúng shape.
- Port test đầu tiên của milestone: `qzds_game_button_test.dart`
  4 case → **263/263**.

## Bạn đang ở đâu

- Cuối Bài 1: `flutter test` **259/259**. `AppTokens`/`AppAssets`/
  `surfaceGlow`/`DesignFrame` đã land — chưa ai dùng.
- Nút dialog hiện tại là các `ElevatedButton`/`TextButton` phẳng
  tự chế (`MenuTokens`) và `_DialogShareButton` scaffold M27 —
  không glow, không pill 44pt, không sheen.
- Icon game đang là `IconData` Material (`Icons.close`…) — chưa
  có SVG nào render.
- `GameScreen` cũ dùng màu nền đơn giản — chưa có ảnh nền.

## Vì sao việc này quan trọng ngay bây giờ

- `QzdsGameButton` là **nút chuẩn của mọi dialog senior** —
  Bài 5 sẽ bọc nó thành `GameDialogButton` cho toàn bộ dialog
  family; không có nó thì shell không xong.
- `GlassIconButton` là nơi **đầu tiên** SVG render thật — học
  `colorFilter`/`BlendMode.srcIn` ở quy mô một file 53 dòng
  trước khi gặp lại ở lifeline/question-panel Bài 5–6.
- `GameScreenBackground` chứng minh asset-pipeline Bài 1 hoạt
  động — `Image.asset(AppAssets.menuBackground)` là consumer
  đầu tiên của `assets:` section; nếu pubspec Bài 1 sai, đây
  là nơi đầu tiên runtime nổ.
- Ba file này là *scaffold nền* cho mọi bài sau — không ai gọi
  chúng cho tới Bài 3 (`GlassIconButton` trong top bar) và
  Bài 6 (`GameScreenBackground` trong screen), nhưng chúng
  phải tồn tại trước.

## Bạn đã biết gì

- `Semantics(button: true, enabled: …, label: …)` + `ExcludeSemantics`
 (M20) — shape a11y y hệt `_GameFeatureButton` cũ.
- `GestureDetector` + `HitTestBehavior.opaque` — vùng bấm
  bao cả phần trong suốt của box.
- `DecoratedBox`/`BoxDecoration`/`BorderRadius`/`Border.all`/
  `BoxShadow` — chrome decoration đã quen qua MenuTokens
  (chưa có registry row riêng).
- `Stack` + `StackFit.expand` (M18) — overlay nền.
- `IconData?` nullable field + collection-`if` trong
 `children:` (reuse) — `if (icon case …)` là bước tiếp
  theo của pattern này.

## Mental model mới — "SVG là vector, colorFilter tô lúc render" 

> **`SvgPicture.asset` + tint qua `ColorFilter.mode`.**
> File SVG của senior đều fill đen/trắng sẵn; widget *không* sửa
> file — nó gắn `colorFilter: ColorFilter.mode(màu, BlendMode.srcIn)`
> để **thay toàn bộ pixel nguồn bằng một màu** giữ nguyên alpha.
> Một file SVG → mọi màu: trắng trên nút kính, vàng trong badge
> câu hỏi, cyan trên lifeline — cùng asset, khác filter.

Và `if-case`:

> **`if-case` — `if (expr case final x?)` null-extract trong widget
> list.** Pattern `final x?` khớp *chỉ khi* expr non-null và bind
> `x` thành non-null ngay trong nhánh — gọn hơn `if (icon != null)
> Icon(icon!)` vì không cần `!` và không phải viết lại tên field.

Hai pattern này lặp lại nhiều lần ở Bài 5–6 (`iconAsset`/`icon`
nullable trong `GameDialogShell`, `audiencePercentile` trong
answer option) — học ở file nhỏ, dùng ở file lớn.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `if (icon case final iconData?) ...[` | **mới** — if-case với null-check pattern: khớp khi `icon != null`, bind `iconData` non-null; `...[]` spread nhiều widget vào `children:` |
| `VoidCallback? onTap` → `enabled: onTap != null` | nút disable bằng null y hệt — semantics `enabled` đọc cùng một nguồn sự thật |
| `this.icon`/`this.scale` optional trong ctor | `QzdsGameButton` 6 field — `icon`/`scale`/`textGlow`/`lightShadow` có default, `text`/`color`/`onTap` bắt buộc |

## Flutter cần dùng

| API | Vai trò |
|---|---|
| `SvgPicture.asset(path, {width, height, colorFilter})` | **mới** — render SVG từ bundle; `colorFilter` tô toàn bộ bằng một `BlendMode` |
| `ColorFilter.mode(Colors.white, BlendMode.srcIn)` | `srcIn` = "source-in": thay pixel nguồn bằng `Colors.white`, giữ alpha → SVG mọi màu thành trắng; đổi sang `yellow600` → vàng |
| `SizedBox.square(dimension: 44)` + `Container` tròn + `glassGradient` | nút kính 44×44: `shape: circle` + border `white10` + gradient kính từ `AppTokens.glassGradient` |
| `surfaceGlow(color.withValues(alpha: 0.32))` | Bài 1 helper — lớp sáng elip phủ pill (DecoratedBox thứ hai bên trong DecoratedBox màu nền) |
| `ColoredBox` + `DecoratedBox(gradient)` + `Opacity(0.6)` + `Image.asset(BoxFit.cover)` | `GameScreenBackground`: 4 lớp — màu nền `screenBackground`, gradient `menuBackgroundGradient`, ảnh PNG cover ở opacity 0.6 |
| `ExcludeSemantics` | bọc `Row` nội dung — icon + text không đọc lại; chỉ `Semantics(label: text)` ngoài cùng đọc |

## Ví dụ độc lập — null-extract trong list (DartPad)

```dart
// ISOLATED EXAMPLE — not in project. Thu nhỏ từ senior: optional
// field bung trong collection-if mà không cần `!`.
String? maybeSuffix = 'PRO';

List<String> buildParts(String? suffix) => [
      'base',
      if (suffix case final s?) ...[
        'has:$s',           // s non-null ở đây — compiler bind sẵn
        'len:${s.length}',
      ],
      'end',
    ];

void main() {
  print(buildParts(maybeSuffix)); // [base, has:PRO, len:3, end]
  print(buildParts(null));        // [base, end] — nhánh case bỏ qua
}
```

Trong `QzdsGameButton` y hệt: `if (icon case final iconData?) …`
bung `IconData?` thành `IconData` non-null — nếu `icon` null,
cả `Icon` lẫn `SizedBox` gap đều không render (hai widget trong
một nhánh `...[ ]`).

## Android / Compose bridge

**SIMILARITY — `SvgPicture.asset` ≈ `ImageVector`/`painterResource`
trong Compose; `colorFilter` ≈ `ColorFilter.tint`.** Compose có
`Icon(painter, tint = …)` và `ColorFilter.tint(color)` với
`BlendMode.srcIn` mặc định — chuyển tất cả pixel không trong suốt
sang `color`. Flutter `flutter_svg` render SVG từ assets và
`ColorFilter.mode(color, BlendMode.srcIn)` làm đúng việc đó.

**IMPORTANT DIFFERENCE — `srcIn` đè *mọi* pixel, kể cả vùng
màu sẵn có.** File SVG senior đã fill sẵn (`fill="white"`); thêm
`srcIn` nghĩa là "chốt màu lúc render" — bỏ filter thì icon hiện
*màu gốc của file* (thường trắng), không phải không hiện gì.
Và `SvgPicture` không phải `IconData` — nó đọc file vector,
decode per-frame; không có font-glyph nào cả.

**DO NOT ASSUME — `ExcludeSemantics`/`Semantics` không giống
`contentDescription` một đối một.** Compose/Android gắn
`contentDescription` trên từng node; Flutter `Semantics` cũng
gắn label — nhưng `ExcludeSemantics` *xoá nguyên subtree khỏi
semantic tree* (khác `clearAndSetSemantics` chỉ ghi đè). Quy
tắc senior: label ở *ngoài* (`Semantics(label: text)`), nội dung
trang trí ở *trong* (`ExcludeSemantics(Row)`), để TalkBack đọc
một lần "TIẾP TỤC, button" thay vì đọc icon + text lặp.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/widgets/common/qzds_game_button.dart` (145 dòng) | **verbatim-port** — `if (icon case …)` dòng 39, `Semantics(button/enabled/label)` dòng 118–121, `surfaceGlow` dòng 137 |
| `lib/widgets/common/glass_icon_button.dart` (53 dòng) | **verbatim-port** — `SvgPicture.asset` + `ColorFilter.mode(Colors.white, BlendMode.srcIn)` dòng 38–45 |
| `lib/widgets/common/game_screen_background.dart` (28 dòng) | **verbatim-port** — `ColoredBox` + `menuBackgroundGradient` + `Opacity(0.6)` + `Image.asset(BoxFit.cover)` |
| `test/widgets/qzds_game_button_test.dart` (4 case) | **verbatim-port** — assert theo *token* (`getSize == AppTokens.qzdsButtonHeight`), không assert số cứng |

## Build it step by step

**Bước 1 — `lib/widgets/common/qzds_game_button.dart`** (145
dòng, verbatim senior). Hai vùng đáng đọc kỹ:

```dart
    final content = ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon case final iconData?) ...[
            Icon(
              iconData,
              size: AppTokens.qzdsIconSm,
              color: AppTokens.white100,
            ),
            const SizedBox(width: AppTokens.spacingXs),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // …
```

```dart
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTokens.radiusN),
            // … border white24 + boxShadows …
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTokens.radiusN),
              gradient: surfaceGlow(
                AppTokens.white100.withValues(alpha: 0.32)),
            ),
            child: _label(),
          ),
        ),
      ),
    );
```

Kiến trúc: **hai `DecoratedBox` lồng nhau** — ngoài là `color`
nền + border + shadow (phần "thân nút"), trong là `surfaceGlow`
(lớp sáng elip từ Bài 1). `scale` chọn `compact` (pin 44pt —
nút xếp chồng trong dialog không phình) vs `large` (padding
dọc tự do — nút hero như PLAY). `textGlow` thêm `Shadow` trắng
vào text, `lightShadow` chọn bộ `boxShadows` nhạt hơn.

**Bước 2 — `lib/widgets/common/glass_icon_button.dart`** (53
dòng, verbatim):

```dart
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: 44,
          child: Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTokens.white10),
                gradient: AppTokens.glassGradient,
              ),
              padding: const EdgeInsets.all(AppTokens.spacingXs),
              child: SvgPicture.asset(
                assetIcon,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
```

Đây là nút **back** của game (Bài 3 `GameScreenTopBar` gắn
`AppAssets.iconGameBack` vào `assetIcon`). `assetIcon` là
`String` path — **đây là shape `iconAsset` mà Bài 6 sẽ migrate
toàn bộ lifeline theo**.

**Bước 3 — `lib/widgets/common/game_screen_background.dart`**
(28 dòng, verbatim):

```dart
    return ColoredBox(
      color: AppTokens.screenBackground,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppTokens.menuBackgroundGradient,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppTokens.menuBackgroundOverlay),
            Opacity(
              opacity: 0.6,
              child: Image.asset(
                AppAssets.menuBackground, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
```

Bốn lớp chồng từ dưới lên: màu nền xám `screenBackground` →
gradient `menuBackgroundGradient` → lớp phủ tối `menuBackgroundOverlay`
→ ảnh PNG cover ở 60%. Consumer đầu tiên của `Image.asset` —
kiểm chứng asset-pipeline Bài 1.

**Bước 4 — `test/widgets/qzds_game_button_test.dart`** (4 case,
verbatim senior — file test đầu tiên của milestone):

1. `'settles on the minimum comfortable tap target'` — pill
   compact cao đúng `AppTokens.qzdsButtonHeight` (44) — assert
   **token**, không assert `44` cứng.
2. `'draws the leading icon before the label when one is given'`
   — có `icon` → `Icon` render trước text.
3. `'the large scale stays taller than a dialog action'` —
   `QzdsButtonScale.large` không pin 44 → cao hơn.
4. `'keeps the icon out of the accessible label'` —
   `ExcludeSemantics` giữ icon khỏi label; test assert
   `find.bySemanticsLabel('PLAY')` tìm thấy đúng một node
   (`getSemantics`/`matchesSemantics` xuất hiện từ Bài 4/5).

**Bước 5 — verify.**

```text
flutter analyze  → No issues found!
flutter test test/widgets/qzds_game_button_test.dart  → 4 passed
flutter test     → +263: All tests passed!
```

## Hiểu code — ba chi tiết dễ trượt

1. **`QzdsGameButton` là `StatelessWidget` — KHÔNG có
   animation.** `QzdsButtonScale.compact/large` là *preset
   kích thước* (enum), không phải hiệu ứng press-scale. Brief
   từng gợi ý "press-scale" — disk là nguồn đúng: nút này tĩnh
   hoàn toàn; mọi motion của nó là `surfaceGlow`/`textGlow`
   tĩnh.
2. **`BlendMode.srcIn` ≠ đổi màu file.** `srcIn` nghĩa là "giữ
   alpha nguồn, đổi RGB thành màu filter" — file SVG gốc đã
   fill trắng sẵn; filter trắng lên trắng *trông* như không
   làm gì, nhưng nó *là* chỗ chốt màu: đổi filter thành
   `yellow600` ở lightning (Bài 5) là icon vàng — cùng asset.
3. **`Opacity(0.6)` bọc `Image.asset`, không bọc cả
   `DecoratedBox`.** Mờ ảnh thì được; mờ cả gradient nền là
   sai — ba lớp dưới (màu nền, gradient, overlay) phải đặc.
   Đặt `Opacity` ngoài cùng = làm mờ cả nền.

## Chạy và quan sát

```text
flutter analyze  → No issues found!
flutter test test/widgets/qzds_game_button_test.dart  → 4 passed
flutter test     → +263: All tests passed!   (259 + 4)
```

`GameScreenBackground`/`GlassIconButton` chưa có consumer —
compile độc lập; consumer đầu tiên ở Bài 3 (top bar) và Bài 6
(screen).

## Thử nghiệm

Trong `glass_icon_button.dart`, đổi `BlendMode.srcIn` thành
`BlendMode.srcOver`, `flutter test` — đoán test có đỏ không?
Sau đó suy ra hành vi khác gì trên màn.

<details>
<summary>Đáp án</summary>

Suite **không đỏ** — không test nào render `GlassIconButton`
(nó chưa có consumer). Trên màn: `srcOver` vẽ màu *lên trên*
pixel nguồn nhưng *không* thay pixel — với `Colors.white` mờ
alpha 255 thì kết quả tương tự trắng, nhưng với màu bán trong
(`Colors.white54`) `srcOver` chỉ phủ mờ còn `srcIn` đổi hẳn
RGB sang trắng giữ alpha. Với file fill trắng sẵn, visual
gần như giống nhau ở filter trắng — khác biệt chỉ lộ khi
filter là màu alpha < 255 hoặc file SVG nhiều màu gốc
(lightning vàng Bài 5 — `srcOver` sẽ *pha* chứ không *đổi*
màu).
</details>

## Lỗi hay gặp

1. **Bỏ `colorFilter` đi vì "icon đã trắng"** — file SVG fill
   trắng *sẵn*; nhưng filter là chỗ senior *chọn* màu render:
   bỏ nó mất chỗ tint — Bài 5 cần `yellow600` cho lightning,
   Bài 6 cần tint lifeline.
2. **`excludeFromSemantics` trên `SizedBox` chứa semantics**
   — đặt `ExcludeSemantics` sai chỗ (ngoài `Semantics`) làm
   mất luôn label "button"; đúng chỗ: *trong* `Semantics`,
   bọc `Row` trang trí.
3. **`HitTestBehavior.deferToChild`** — vùng trống giữa icon
   và text không bắt tap; senior dùng `opaque` để cả box bấm
   được.
4. **Nhầm `QzdsButtonScale` với animation** — nó là preset
   kích thước (enum), không animate; muốn press-scale phải
   `AnimationController` (Bài 3 học) — nút này *cố ý* tĩnh.
5. **`Image.asset` trước khi pubspec có dir** — `Unable to
   load asset` runtime; quay lại Bài 1 kiểm tra `assets:`.

## Tự làm — PREDICT

Trong `qzds_game_button.dart`, **bỏ `ExcludeSemantics`** khỏi
`_label()` (giữ `Semantics(label: text)` ngoài cùng). Đoán:

(a) `test 'keeps the icon out of the accessible label'` có đỏ
không? (b) TalkBack đọc gì khác đi trên nút có `icon`?

:::note[Gợi ý]
`ExcludeSemantics` xoá *subtree* khỏi semantics; bỏ nó thì
`Icon` + `Text` trong `Row` đều thành semantics-node riêng —
`Icon` có semantics-label mặc định không?
:::

<details>
<summary><strong>Đáp án</strong></summary>

(a) **Test ĐỎ** — `find.bySemanticsLabel('PLAY')` mong đúng
MỘT node; khi `ExcludeSemantics` bị gỡ, `Text('PLAY')` bên trong
tạo thêm một semantics node cùng label `'PLAY'` → finder khớp
≥2 node → `findsOneWidget` fail. (b) Cấu trúc cũng sai về
accessibility: TalkBack đọc text hai lần (node `Text` + node
`Semantics(label:)`), và `Icon` xuất hiện như node không nhãn
gây nhiễu traversal. `ExcludeSemantics` là *dọn subtree* để
chỉ còn một node button sạch — vì vậy senior bọc `Row`, chứ
không bọc `Semantics` cha.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** `if (icon case final iconData?)` khác `if (icon !=
  null)` + `Icon(icon!)` ở đâu? — **Đáp:** if-case *bind* giá
  trị non-null thành biến mới (`iconData`) — không cần `!`,
  không lặp tên field; và nó ở trong `children:` nên gọn hơn
  tách ra ngoài.
- **Hỏi:** `BlendMode.srcIn` làm gì với pixel đã có màu? —
  **Đáp:** thay RGB bằng màu filter, giữ nguyên alpha — cùng
  một file SVG, filter trắng→trắng, filter vàng→vàng.
- **Hỏi:** vì sao test assert `AppTokens.qzdsButtonHeight` thay
 vì `44`? — **Đáp:** — token là nguồn đúng; design đổi
  44→48 thì test + code đổi cùng một chỗ, test vẫn xanh.
- **Hỏi:** `GameScreenBackground` mấy lớp? Liệt kê từ dưới
  lên. — **Đáp:** bốn — `ColoredBox(screenBackground)` →
  `DecoratedBox(menuBackgroundGradient)` → `ColoredBox(
  menuBackgroundOverlay)` trong Stack → `Opacity(0.6,
  Image.asset cover)`.
- **Hỏi:** `GlassIconButton.assetIcon` nhận `String` — vì sao
  không nhận `IconData`? — **Đáp:** đó là shape mới của pipeline:
  icon là *asset path* (`AppAssets.iconGameBack`), render qua
  `SvgPicture` — Bài 6 migrate toàn lifeline theo kiểu này.

## Ta cố ý chưa thêm

- Consumer của ba widget — `GlassIconButton` vào `GameScreenTopBar`
  (Bài 3), `QzdsGameButton` vào `GameDialogButton`/shell (Bài 5),
  `GameScreenBackground` vào `GameScreen` (Bài 6).
- `GameDialogButton` (wrapper `QzdsGameButton` + `shareColor`)
  — **Bài 5** cùng `GameDialogShell`.
- Press-scale animation — nút *cố ý* tĩnh (parity senior);
  controller học ở Bài 3.
- `flutter_svg` cho lifeline/question-panel — Bài 5/6.
- Test cho `GlassIconButton`/`GameScreenBackground` — senior
  không có test riêng cho hai file này (cover gián tiếp qua
  `game_screen_test` Bài 6).

## Checkpoint hoàn thành

- [ ] Ba file `lib/widgets/common/` tồn tại verbatim:
  `qzds_game_button.dart` (`if (icon case final iconData?)`,
  `Semantics(button/enabled/label)`, 2 `DecoratedBox` lồng +
  `surfaceGlow`), `glass_icon_button.dart` (`SvgPicture.asset` +
  `ColorFilter.mode(srcIn)`), `game_screen_background.dart`
  (4 lớp).
- [ ] `test/widgets/qzds_game_button_test.dart` 4 case xanh.
- [ ] Kể được `srcIn` làm gì và vì sao icon fill trắng vẫn
  cần `colorFilter`.
- [ ] `flutter analyze` sạch; `flutter test` **263/263**
  (+4 từ qzds test).
