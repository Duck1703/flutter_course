---
title: "Bài 4 · Trigger-based motion — số tiền đếm nhảy + reduce-motion"
description: "`animationTrigger` int-gate: widget chỉ animate khi trigger *tăng* — amount đổi vì nhiều lý do, chỉ transition mới xứng animation. `GameMoneyAmountMotion` — `SingleTickerProviderStateMixin` + `didUpdateWidget` gate + `forward(from:0)` + interpolated digits qua `_AmountTemplate`/`_intAmount`/`_formatGrouped` + glitch cyan/magenta `ShaderMask`/`Transform.translate`. `GameMoneyAmount` gate `MediaQuery.disableAnimations` → `Duration.zero` (reuse — hành vi này honor). Ladder CTA `TextButton.styleFrom`+`shrinkWrap`+`WidgetStatePropertyAll`, ladder dialog `LayoutBuilder`+`FittedBox`+`toUpperCase`. +6 test → 276."
sidebar:
  label: "Bài 4 · trigger motion"
  order: 4
---

## Mục tiêu

- Phát biểu mental model: *trigger-based animation*
  widget không animate theo `amount` đổi (data đổi vì nhiều lý
  do: load lại, reset, cập nhật nền); nó animate khi
  `animationTrigger` **tăng** — một tín hiệu đếm đơn điệu từ
  DTO nói "vừa có transition thật".
- Thấy `didUpdateWidget` (từ Bài 3) ở vai trò *gate*:
  `widget.animationTrigger > oldWidget.animationTrigger &&
  widget.duration > Duration.zero` → `_controller.forward(from:0)`;
  ngược lại `amount` đổi → `_controller.value = 1` (snap).
- Hiểu **interpolated digits**: `_intAmount` (bóc chữ số → int),
  `_AmountTemplate` (giữ `prefix`/`suffix` — `$` + dấu phẩy),
  `_formatGrouped` — số tiền "đếm" bằng cách nội suy int, không
  phải tween chuỗi.
- Hiểu `MediaQuery.of(context).disableAnimations` → `Duration.zero`
  — **hành vi senior honor ở đây** (khác pulse Bài 3 cố ý bỏ
  qua): reduce-motion tắt hẳn motion + glitch.
- Port `game_money_amount_motion.dart` + `game_money_amount.dart`
  + ladder CTA + ladder dialog (support files) → **276/276**.

## Bạn đang ở đâu

- Cuối Bài 3: `flutter test` **270/270**. `AnimationController`,
  `CustomPainter`, `didUpdateWidget` đã học — bài này là reuse
  đầu tiên của chúng (một controller, một `SingleTicker…`).
- `GameMoneyData` đã có sẵn `animationTrigger: int` từ M19 —
  reducer/VM tăng nó mỗi khi tiền đổi *vì transition*; widget
  cũ chỉ `Text(data.amount)` trần, chưa ai đọc trigger.
- `formatGameMoney` trong `view_models/game/support/game_money_
  formatter.dart` sản ra `'$1,000'` — chuỗi đã format; motion
  widget phải *tự* bóc số ra để nội suy.
- Money hiển thị trong `_GameTopBar` scaffold cũ dạng text —
  không pill vàng, không glow, không đếm nhảy.

## Vì sao việc này quan trọng ngay bây giờ

- Đây là bài kiểm tra thật của /: không concept mới nào
  nặng — chỉ một `AnimationController` + một `didUpdateWidget`
  gate + curve. Nếu Bài 3 hiểu, bài này đọc trôi; nếu chưa,
  đây là chỗ phát hiện.
- `animationTrigger` là pattern **kiến trúc** — nó giải
  quyết "data đổi ≠ muốn animate". Pattern này tái xuất ở
  answer-list (`questionIndex` làm trigger — Bài 5) và là
  chuẩn senior cho mọi one-shot-motion.
- Reduce-motion đúng chỗ: đây là một trong **ba** nơi senior
  honor `disableAnimations` (money→zero, reveal-blink→tắt,
  dialog-transition→0ms) — so sánh trực tiếp với pulse Bài 3
  *không* honor (parity cố ý).
- `Duration.zero` truyền *vào* widget như một prop — cha
  (`GameMoneyAmount`) đọc `MediaQuery`, con (`…Motion`) chỉ
  biết "duration = 0 → đứng yên". Tách *phát hiện* khỏi
  *phản ứng*.

## Bạn đã biết gì

- `AnimationController` + `SingleTickerProviderStateMixin` +
 `dispose` (Bài 3) — một controller duy nhất → `Single`.
- `didUpdateWidget(covariant old)` (Bài 3) — đây là nơi
  nó làm *gate*, không chỉ sync.
- `AnimatedBuilder` + `Curves.*` (M21) — `AnimatedBuilder`
  rebuild theo controller; `Curves.easeOutCubic.transform(value)`
  biến 0→1 thành 0→1-cong (đã thấy `switchInCurve` cùng curve).
- `MediaQuery` + `disableAnimations` (M21) — layer dialog
  cũ đã gate duration bằng nó; đây là cùng một API ở widget.
- `ShaderMask` + `BlendMode.srcIn` — cùng blend với
 `ColorFilter.mode` Bài 2: `srcIn` = giữ alpha nguồn,
  thay RGB — ở đây thay bằng *gradient* qua `shaderCallback`.
- `RegExp` + `replaceAll`/`indexOf`/`lastIndexOf` + `StringBuffer`
  — string parsing (Dart core, chưa có registry row riêng).
- `TextButton.styleFrom` + `WidgetStateProperty*` —
  style nút Material (chưa có registry row riêng);
  `MaterialTapTargetSize.shrinkWrap` là
  mới nhẹ (LIGHT).

## Mental model mới — "trigger tăng = tín hiệu animate" 

> **Trigger-based animation.** Widget nhận *hai* input:
> `amount` (data đích) + `animationTrigger` (int đếm đơn điệu
> từ DTO). Animate **chỉ khi** `trigger > oldTrigger` —
> `amount` đổi mà trigger đứng yên nghĩa là "data refresh
> nền, không phải transition mới" → snap thẳng. Trigger reset
> (game mới → về 0) cũng không phải `>` → snap.

Ba trường hợp `didUpdateWidget` phân biệt:

```dart
final shouldAnimate =
    widget.animationTrigger > oldWidget.animationTrigger &&
    widget.duration > Duration.zero;
if (shouldAnimate) {
  // trigger tăng + motion được phép → forward(from: 0)
} else if (widget.amount != oldWidget.amount) {
  _controller.value = 1;   // data đổi nhưng không-trigger → snap
}
// còn lại: không gì đổi → đứng yên
```

- `trigger: 0 → 1` (trả lời đúng, tiền nhảy) → **animate**.
- `trigger: 1 → 1`, `amount` đổi (re-map, load lại) → **snap**.
- `trigger: 1 → 0` (game mới reset) → **snap** (không `>`).
- `duration == Duration.zero` (reduce-motion) → **snap** luôn.

Và *đếm nhảy* là nội suy **int**, không phải chuỗi:

```dart
_displayAmount(progress) {
  if (_controller.value >= 1) return widget.amount;  // đích đúng chuỗi
  final delta = (_countEnd - _countStart) * progress;
  return _amountTemplate.format(_countStart + delta.round());
}
```

`_AmountTemplate.fromAmount(r'$2,000')` → `prefix='$'`,
`suffix=''`; `_intAmount` bóc `2000`; `_formatGrouped` chèn
`,` mỗi 3 → `$1,500` giữa chừng. Giữ `prefix`/`suffix` nghĩa
là nó hoạt với mọi định dạng tiền (`$`, `đ`, `K`).

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `widget.animationTrigger > oldWidget.animationTrigger` | — so int đếm đơn điệu; `>` (không `!=`) là trọng tâm: reset về 0 không phải trigger |
| `widget.duration > Duration.zero` | `Duration` so `>` được (implements `Comparable`) — gate reduce-motion thứ hai |
| `_controller.forward(from: 0)` | `forward(from:)` = re-arm: reset `value` rồi chạy — gọn hơn `..value=0..forward()` (Bài 3) |
| `_controller.duration = _motionDuration` | controller `duration` *gán lại được* — didUpdateWidget cập nhật trước khi quyết animate |
| `_AmountTemplate.fromAmount` factory + `format` | record hóa prefix/suffix — `factory` bóc chữ số đầu/cuối |
| `RegExp(r'\d')` / `RegExp(r'[^0-9]')` | `r'…'` raw-string — `\d` không cần escape `\\d` |
| `Curves.easeOutCubic.transform(_controller.value)` | `Curve.transform(t)` — biến linear-0→1 thành eased-0→1, dùng *giá trị* chứ không gắn vào Tween |

## Flutter cần dùng

| API | Vai trò |
|---|---|
| `SingleTickerProviderStateMixin` | một controller duy nhất → mixin nhẹ (reuse) |
| `MediaQuery.of(context).disableAnimations` | đọc ở **cha** (`GameMoneyAmount`) → prop `duration` cho con — tách phát hiện/phản ứng |
| `AnimatedBuilder(animation: _controller, builder: …)` | rebuild mỗi frame tick — bên trong `Stack` xếp glitch-layers + text chính |
| `ShaderMask(blendMode: BlendMode.srcIn, shaderCallback: …)` | tô `Text` bằng `LinearGradient` cam (`0xFFFF6F00`→`0xFFFF8F00`) — `srcIn` giữ alpha chữ, đổi màu theo shader (reuse ở dạng shader) |
| `Transform.translate(offset: …, child: …)` | lệch glitch-layer theo `intensity` — cyan `(3·i, -0.8·i)`, magenta ngược — *không* đổi layout, chỉ đổi paint |
| `Stack(clipBehavior: Clip.none)` | glitch-layer tràn ra ngoài pill — `Clip.none` cho phép vẽ quá bounds |
| `TextButton.styleFrom({tapTargetSize: shrinkWrap, overlayColor: WidgetStatePropertyAll(…)})` | CTA trong ladder — `shrinkWrap` bỏ 48pt tap-target mặc định (CTA nằm trong bảng, không phải nút đứng), `WidgetStatePropertyAll` một màu mọi state |
| `LayoutBuilder` + `FittedBox` | ladder dialog co theo chiều cao: `FittedBox` scale bảng xuống khi viewport thấp |

## Ví dụ độc lập — trigger-gate thu nhỏ (DartPad)

```dart
// ISOLATED EXAMPLE — not in project. Từ senior: chỉ "animate" khi
// trigger TĂNG — amount đổi mà trigger yên thì snap.
class MoneyMotion {
  var countStart = 0;
  var countEnd = 0;
  var lastTrigger = 0;
  String display = r'$0';

  void update({required String amount, required int trigger}) {
    final end = int.parse(amount.replaceAll(RegExp(r'[^0-9]'), ''));
    if (trigger > lastTrigger) {
      countStart = countEnd;      // animate từ vị trí cũ…
      countEnd = end;             // …tới đích mới
      display = 'ANIMATE $countStart→$countEnd';
    } else if ('$end' != display) {
      countStart = countEnd = end; // không trigger → snap
      display = 'SNAP to \$$end';
    }
    lastTrigger = trigger;
  }
}

void main() {
  final m = MoneyMotion();
  m.update(amount: r'$1,000', trigger: 0);   // SNAP to $1000 (init)
  m.update(amount: r'$2,000', trigger: 1);   // ANIMATE 1000→2000
  m.update(amount: r'$3,000', trigger: 1);   // SNAP to $3000 (data refresh)
  m.update(amount: r'$0',     trigger: 0);   // SNAP to $0 (trigger reset)
  print(m.display); // SNAP to $0
}
```

Đúng gate của `GameMoneyAmountMotion`: `> lastTrigger` —
không `!=`, không `>=` — vì reset về 0 *không* phải transition
mới.

## Android / Compose bridge

**SIMILARITY — `animationTrigger` ≈ `LaunchedEffect(key)` /
`animateIntAsState` + key-change.** Compose `LaunchedEffect(trigger)`
re-launch animation khi key đổi; `animateIntAsState(target)`
nội suy int y hệt `_intAmount`+`_formatGrouped` — cả hai đều
là "đếm tới đích" chứ không tween chuỗi.

**IMPORTANT DIFFERENCE — trigger là *data*, không phải key-
effect.** Compose `LaunchedEffect(anyChange)` fire trên *mọi*
đổi trừ khi bạn tự gate; senior đẩy *quyết định animate* vào
DTO (`animationTrigger` do VM/reducer tăng) — widget chỉ
*phản ứng* `> old`. Ui-state mang tín hiệu "đã có transition"
thay vì widget tự đoán. Đó là tư duy unidirectional-data:
reducer biết "vừa answer-correct" nên nó bump trigger; widget
không cần biết *vì sao*.

**DO NOT ASSUME — `disableAnimations` không tự tắt
`AnimationController`.** `MediaQuery.of(context).disableAnimations`
là *flag đọc thủ công* — controller vẫn chạy nếu bạn forward();
senior gate nó bằng cách truyền `Duration.zero` từ cha +
double-check `duration > Duration.zero` trong `didUpdateWidget`.
Khác Android `animator_duration_scale` (hệ thống tự scale) —
ở đây *bạn* phải đọc và phản ứng. Và nhớ: pulse Bài 3 *cố ý*
không đọc flag này (parity).

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/widgets/game/money/game_money_amount_motion.dart` (196 dòng) | **verbatim-port** — gate `> oldWidget.animationTrigger && duration > zero` dòng 44–45, `forward(from:0)` dòng 53, `_displayAmount` dòng 105–110, `_AmountTemplate`/`_intAmount`/`_formatGrouped` dòng 120–152, `_glitchLayers` dòng 89–104 (`ShaderMask`/`Transform` 165–189) |
| `lib/widgets/game/money/game_money_amount.dart` (98 dòng) | **verbatim-port** — `disableAnimations → Duration.zero` dòng 16–18, `Semantics(prizeAmountSemanticLabel)` dòng 20–22, `_MoneyPill` yellow500 + glow dòng 42–77 |
| `lib/widgets/game/money/game_money_ladder_cta_button.dart` (109 dòng) | **verbatim-port** — `TextButton.styleFrom` + `shrinkWrap` + `WidgetStatePropertyAll` overlay dòng 40–52 |
| `lib/widgets/game/money/game_money_ladder_dialog.dart` (209 dòng) | **verbatim-port** — `LayoutBuilder`+`FittedBox` scale-down, `moneyLadderTitle.toUpperCase()` dòng 83, `_LadderItem`-rows (private class riêng của file, dòng 128–209 — KHÔNG phải `GameDialogMoneyRow`; cái đó thuộc shell Bài 5) |
| `test/widgets/game_money_amount_test.dart` (6 case) | **verbatim-port** — mid-animation `midpoint`≠đầu/cuối, `MediaQueryData(disableAnimations:)` seam dòng 143 |

## Build it step by step

**Bước 1 — `lib/widgets/game/money/game_money_amount_motion.dart`**
(196 dòng, verbatim senior — file lớn nhất bài). State:

```dart
class _GameMoneyAmountMotionState extends State<GameMoneyAmountMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _countStart = 0;
  var _countEnd = 0;
  var _amountTemplate = _AmountTemplate.fromAmount(r'$0');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _motionDuration,
      value: 1,               // khởi đầu "đã settle" — không nhảy lúc mount
    );
  }
```

Gate trong `didUpdateWidget` (đúng nghĩa):

```dart
  @override
  void didUpdateWidget(covariant GameMoneyAmountMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = _motionDuration;

    final shouldAnimate =
        widget.animationTrigger > oldWidget.animationTrigger &&
        widget.duration > Duration.zero;
    if (shouldAnimate) {
      _countStart =
          _intAmount(oldWidget.amount) ?? _intAmount(widget.amount) ?? 0;
      _countEnd = _intAmount(widget.amount) ?? _countStart;
      _amountTemplate = _AmountTemplate.fromAmount(widget.amount);
      _controller.forward(from: 0);
    } else if (widget.amount != oldWidget.amount) {
      _controller.value = 1;   // đổi không-trigger → snap
    }
  }
```

`_motionDuration` — chi tiết dễ trượt:

```dart
  Duration get _motionDuration => widget.duration == Duration.zero
      ? Duration.zero
      : const Duration(milliseconds: 260);
```

`widget.duration` chỉ dùng làm **zero/non-zero gate** — duration
thật luôn là 260ms khi animate (cha truyền `motionMedium` 220ms
nhưng con normalize về 260). `build`:

```dart
    if (widget.duration == Duration.zero) {
      return _amountText(amount: widget.amount);   // reduce-motion: phẳng
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(_controller.value);
        final amount = _displayAmount(progress);
        final intensity = (1 - progress).clamp(0, 1).toDouble();

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (intensity > 0) ..._glitchLayers(amount, intensity),
            _amountText(
              key: const ValueKey('game-money-amount-text'),
              amount: amount,
            ),
          ],
        );
      },
    );
```

Glitch = hai `Text` cùng content tô `0x9900E5FF`/`0x99FF00FF`
+ `Transform.translate` lệch theo `intensity` — chỉ hiện khi
đang chạy (`intensity > 0`), biến mất khi settle.

`_AmountTemplate`/`_intAmount`/`_formatGrouped` (dòng 120–152)
giữ format `'$2,000'` ↔ int `2000` hai chiều.

**Bước 2 — `lib/widgets/game/money/game_money_amount.dart`**
(98 dòng — cha đọc reduce-motion + pill vàng):

```dart
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : AppTokens.motionMedium;

    return Semantics(
      button: onTap != null,
      label: l10n.prizeAmountSemanticLabel(data.amount),
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: _MoneyPill(data: data, duration: duration),
        ),
      ),
    );
  }
```

`_MoneyPill` = `DecoratedBox` vàng `_yellow500` + hai
`BoxShadow` (trắng mờ + vàng đổ) + `ClipRRect` bọc `Stack`
(`Positioned.fill` `_MoneyPillGlow` + `GameMoneyAmountMotion`
giữa). Truyền `data.amount`/`data.animationTrigger`/`duration`
xuống motion widget.

**Bước 3 — `lib/widgets/game/money/game_money_ladder_cta_button.dart`**
(109 dòng — nút CTA `UNDERSTAND`/`ĐÃ HIỂU` NẰM TRONG ladder dialog, dismiss nó).
`TextButton.styleFrom` + `tapTargetSize: MaterialTapTargetSize.
shrinkWrap` (bỏ min-48 để nằm gọn) + `overlayColor:
WidgetStatePropertyAll(…)` (một màu overlay mọi state) —
comment trong file giải thích "TextButton hands its child
loose constraints" vì sao phải shrink-wrap.

**Bước 4 — `lib/widgets/game/money/game_money_ladder_dialog.dart`**
(209 dòng — bảng thang tiền trong dialog). `LayoutBuilder`
đo chiều cao → `FittedBox` scale bảng xuống khi viewport thấp;
tiêu đề `l10n.moneyLadderTitle.toUpperCase()` — **đây là nguồn
của `THANG TIỀN THƯỞNG` HOA** mà `menu_screen_ui_events_test`
assert ở Bài 6. Các hàng tiền là `_LadderItem` — private class RIÊNG của file
(dòng 128–209), không phải `GameDialogMoneyRow` của shell Bài 5;
file này land bây giờ đúng vì nó chỉ phụ thuộc `AppTokens` +
`formatGameMoney` (đã có) + `flutter_svg` + l10n, còn
consumer của nó (`GameDialogLayer.showMoneyLadder`) ở Bài 5.

**Bước 5 — `test/widgets/game_money_amount_test.dart`** (6 case,
verbatim):

1. `'renders centered pill-only amount display'` — pill vàng +
   text căn giữa.
2. `'keeps tap and semantics contract stable'` — `onTap` +
   `prizeAmountSemanticLabel` (`'Prize amount $1,000'`).
3. `'counts smoothly and glitches when animation trigger
   increases'` — trigger 0→1: sau mount text đích `$2,000`
   *chưa* hiện — `midpoint` (130ms) **không** là `$1,000` lẫn
   `$2,000` (đang nội suy) + glitch-layer tồn tại; sau
   `pumpAndSettle` `$2,000` + glitch mất.
4. `'updates amount without glitch when trigger is unchanged'`
   — amount đổi, trigger yên → snap thẳng, không glitch.
5. `'updates amount without glitch when trigger resets'` —
   trigger 1→0 → snap `$0`.
6. `'skips motion when reduced animations are requested'` —
   `MediaQueryData(disableAnimations: true)` → `$2,000` ngay,
   không glitch.

Seam reduce-motion: `MediaQuery(data: MediaQueryData(
disableAnimations: true), child: …)` bọc host — không cần
thiết bị thật.

:::note
Test này lần đầu dùng `tester.getSemantics(finder)` +
`matchesSemantics(label:…)` — API đọc semantics-node trực tiếp
(khác `find.bySemanticsLabel` chỉ *tìm* node). Concept 
semantics nâng được đặt tên chính thức ở Bài 5 (LIGHT).
:::

**Bước 6 — verify.**

```text
flutter analyze  → No issues found!
flutter test test/widgets/game_money_amount_test.dart  → 6 passed
flutter test     → +276: All tests passed!
```

## Hiểu code — bốn chi tiết dễ trượt

1. **`widget.duration` là *gate*, không phải duration thật.**
   Cha truyền `motionMedium` (220ms) nhưng `_motionDuration`
   trả **260ms** khi animate — param chỉ kiểm `== Duration.zero`.
   Tưởng "đổi `motionMedium` sẽ đổi tốc độ đếm" là sai — tốc
   độ đếm cố định 260ms; param chỉ bật/tắt.
2. **Mid-animation hiển thị *chuỗi nội suy*, không phải đích.**
   `_displayAmount` trả `_amountTemplate.format(countStart +
   delta.round())` khi `value < 1` → người nhìn thấy `$1,500`
   giữa chừng; `if (value >= 1) return widget.amount` chốt đúng
   chuỗi đích ở cuối. Test nên assert *sau-settle* (`pumpAnd
   Settle`) hoặc assert *không đầu không cuối* ở midpoint —
   đừng assert `$1,500` chính xác (làm test brittle theo curve).
3. **`_controller` khởi đầu `value: 1`.** "Đã settle" là mặc
   định — mount đầu không đếm; chỉ `forward(from: 0)` khi
   trigger tăng mới re-arm về 0 rồi chạy.
4. **`forward(from: 0)` khác `..value = 0 ..forward()`.** Cùng
   hiệu quả re-arm, nhưng `from:` là one-call — Bài 3 dùng
   cascade hai lệnh, ở đây senior dùng named-param. Cả hai
   đúng; nhận ra chúng là *cùng một thao tác*.

## Chạy và quan sát

```text
flutter analyze  → No issues found!
flutter test test/widgets/game_money_amount_test.dart  → 6 passed
flutter test     → +276: All tests passed!   (270 + 6)
```

`GameMoneyAmount`/`…Ladder…` chưa có consumer trong screen —
consumer đến Bài 5 (layer money-ladder) + Bài 6 (top-bar/body).
`game_money_ladder_dialog` chỉ biên dịch vì nó tự chứa trong
`FittedBox`/`LayoutBuilder` — caller thật ở layer Bài 5.

## Thử nghiệm

Trong `didUpdateWidget`, đổi `widget.animationTrigger >
oldWidget.animationTrigger` thành `!=` — đoán test nào đỏ và
vì sao.

<details>
<summary>Đáp án</summary>

Test `'updates amount without glitch when trigger resets'` **đỏ.**
Với `!=`: trigger `1 → 0` (reset) khớp `!=` → `shouldAnimate`
đúng → `forward(from:0)` chạy + glitch layers xuất hiện →
assert `findsNothing` cho `game-money-amount-glitch-layer-0`
nhận `findsOneWidget` → FAIL. `>` là đúng vì trigger chỉ
*tăng* mới báo transition; reset về 0 là "xóa trigger" —
không animate. (Test `'…unchanged'` vẫn xanh vì trigger 1→1
không `!=` cũng không `>`.) Đây là lý do senior chọn `>` chứ
không `!=`/`>=`: đơn điệu tăng là contract, reset là ngoại lệ.
</details>

## Lỗi hay gặp

1. **Animate theo `amount` đổi** — `amount` đổi khi load lại/
   reset/re-map nền; gate phải là `trigger >` — data đổi không
   đồng nghĩa transition mới.
2. **`!=` thay `>`** — trigger reset 1→0 sẽ animate (nhầm);
   test `'…resets'` bắt đúng lỗi này.
3. **Assert giá trị giữa chừng** — `$1,500` phụ thuộc curve +
   timing; assert `≠ đầu ∧ ≠ cuối` (test senior) hoặc sau
   `pumpAndSettle`, không assert chính xác midpoint.
4. **Quên `_controller.value = 1` nhánh else** — `amount` đổi
   không trigger mà giá trị controller vẫn <1 (đang chạy dở)
   → `_displayAmount` vẫn trả nội suy → text không snap.
5. **Gate reduce-motion trong `initState` duy nhất** — duration
   đổi *lúc chạy* (user bật setting giữa chừng) cần
   `didUpdateWidget` cập nhật `_controller.duration` trước —
   `initState` chỉ chạy một lần.

## Tự làm — DEBUG

Ai đó **bỏ `widget.duration > Duration.zero` khỏi
`shouldAnimate`** (giữ `trigger >` thôi). Trace test
`'skips motion when reduced animations are requested'`:

(a) Test đỏ ở đâu? (b) Vì sao `if (widget.duration ==
Duration.zero) return _amountText(…)` trong `build` *không*
cứu được dù gate build-time còn nguyên?

:::note[Gợi ý]
`build` return sớm khi `duration == zero` — vậy `_controller.
forward(from:0)` trong `didUpdateWidget` có gây glitch không
nếu build không bao giờ render `AnimatedBuilder`? Xem chỗ
nào khác `intensity`/`glitch` được tính…
:::

<details>
<summary><strong>Đáp án</strong></summary>

(a) **Không đỏ.** Với `disableAnimations: true`, `GameMoneyAmount`
truyền `Duration.zero` → `build` return sớm `_amountText`
phẳng — `AnimatedBuilder` + glitch không bao giờ vào cây.
`forward(from:0)` vẫn *chạy* ngầm (ticker tick) nhưng không
ai render kết quả → test assert `$2,000` + `glitch finds
Nothing` vẫn xanh. (b) Gate `duration > zero` trong
`shouldAnimate` là *tối ưu + phòng thủ*: nó giữ `_countStart`
/`_amountTemplate`/`_controller` khỏi bị dirty bởi những
trigger tăng mà không render (và tránh ticker chạy vô ích).
Bỏ nó không vỡ test *này* nhưng làm lệch contract
"duration là điều kiện của animate, không chỉ của render".
Đây là ví dụ "test xanh ≠ code đúng hợp đồng" — hai gate
(build + didUpdateWidget) cùng tồn tại vì chúng bảo vệ hai
thứ khác nhau.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** `animationTrigger` do ai tăng? — **Đáp:** VM/reducer
  (DTO `GameMoneyData`) — trigger là *data trong state*, widget
  chỉ phản ứng `>`; widget không tự quyết định "đây là
  transition" (unidirectional data).
- **Hỏi:** `_motionDuration` trả bao nhiêu khi
  `widget.duration == motionMedium`? — **Đáp:** `260ms` —
  `widget.duration` chỉ là zero/non-zero gate; tốc độ đếm
  cố định 260.
- **Hỏi:** reduce-motion tắt glitch bằng cách nào? — **Đáp:**
  hai lớp — `GameMoneyAmount` truyền `Duration.zero` → `build`
  return phẳng (không `AnimatedBuilder` vào cây) *và*
  `shouldAnimate` gate `duration > zero` giữ controller
  không forward.
- **Hỏi:** `_displayAmount` trả `widget.amount` khi nào? —
  **Đáp:** khi `_controller.value >= 1` (settled) — chuỗi đích
  chính xác; giữa chừng nó trả `_amountTemplate.format(nội
  suy)` với `$` + `,` giữ nguyên.
- **Hỏi:** `SingleTicker…` đủ không, hay cần `TickerProvider…`?
  — **Đáp:** đủ — một controller duy nhất; Bài 3 cần
  `TickerProvider…` vì hai controller.

## Ta cố ý chưa thêm

- Consumer của `GameMoneyAmount` trong `GameScreenBody`/top-bar
  — **Bài 6**.
- `GameMoneyLadderDialogView` mở từ `GameDialogLayer` —
  **Bài 5** (layer mới gọi nó).
- `GameDialogMoneyRow` (hàng tiền căn giữa với coin) — **Bài 5**
  trong `game_dialog_shell.dart` (test `game_dialog_money_row_
  test` 4 case).
- Pulse/ripple `disableAnimations`-gate — **không thêm**: parity
  cố ý (senior không honor ở hai chỗ đó).
- `CurvedAnimation`/`Interval` stagger — **Bài 5** answer-list.
- `formatGameMoney` giải kỹ — đã cover ở M19; ở đây chỉ cần
  biết nó sản `'$1,000'`.

## Checkpoint hoàn thành

- [ ] `lib/widgets/game/money/game_money_amount_motion.dart` —
  `SingleTicker…` + gate `trigger > old && duration > zero` +
  `forward(from:0)` + `_displayAmount` + `_AmountTemplate` +
  glitch layers, verbatim.
- [ ] `lib/widgets/game/money/game_money_amount.dart` —
  `MediaQuery.disableAnimations → Duration.zero` + `Semantics(
  prizeAmountSemanticLabel)` + `_MoneyPill` vàng + glow,
  verbatim.
- [ ] `game_money_ladder_cta_button.dart` (`TextButton.styleFrom`
  + `shrinkWrap` + `WidgetStatePropertyAll`) +
  `game_money_ladder_dialog.dart` (`LayoutBuilder`+`FittedBox`+
  `toUpperCase`) verbatim.
- [ ] `test/widgets/game_money_amount_test.dart` 6 case xanh —
  đặc biệt `midpoint` ≠ đầu/cuối + `MediaQueryData(disable
  Animations:)` seam.
- [ ] `flutter analyze` sạch; `flutter test` **276/276** (+6).
