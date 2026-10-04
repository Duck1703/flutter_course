---
title: "Bài 3 · CustomPainter + AnimationController — đồng hồ đếm ngược"
description: "Hai CORE concept đầu của milestone. `AnimationController` + `vsync`/`TickerProviderStateMixin` (F-38): timer sở hữu HAI controller — `_pulseController` repeat(reverse) bounds 1→1.08 ở ≤20%, `_progressController` lái Tween progress 1s giữa các nhịp giây. `CustomPainter` (F-39): stadium `Path` + `computeMetrics`+`extractPath` + `Paint` stroke gradient round-cap + `shouldRepaint`. `didUpdateWidget` (F-40) sync controller khi data đổi — animate vs snap. `GameScreenTopBar` host đầu tiên. +7 test → 270."
sidebar:
  label: "Bài 3 · painter + controller"
  order: 3
---

## Mục tiêu

- Phát biểu mental model **F-38**: `AnimationController` là
  *ticker mình sở hữu* — `vsync` để nhịp theo frame, `duration`
  cho một chu kỳ, `forward/reverse/repeat/stop` điều khiển,
  `dispose` bắt buộc; khác `AnimatedOpacity` ở chỗ widget
  implicit *tự* sở hữu controller, còn explicit controller mình
  phải tự quản lifecycle.
- Phát biểu mental model **F-39**: `CustomPainter` là
  *render-object tự vẽ* — `paint(Canvas, Size)` phát lệnh vẽ
  thuần (`Paint` = cọ/màu, `Path` = hình, `Canvas` = mặt vẽ);
  `shouldRepaint` là hợp đồng "delegate đổi → vẽ lại".
- Phát biểu mental model **F-40**: `didUpdateWidget` là *điểm
  đồng bộ* — khi widget config đổi (progress mới), State quyết
  định animate-tới hay snap-ngay.
- Port `GameCountdownTimer` + `_PillProgressPainter` (qua
  `part`/`part of` — D-45 reuse) + `GameScreenTopBar` verbatim.
- Đọc được hai controller cùng tồn tại: pulse (cosmetic loop
  vô hạn) vs progress (one-shot 1s mỗi nhịp giây) — và vì sao
  pulse **cố ý** không honor `disableAnimations`.
- Port `game_countdown_timer_test.dart` 7 case → **270/270**.

## Bạn đang ở đâu

- Cuối Bài 2: `flutter test` **263/263**. Ba widget common đã
  land (`QzdsGameButton`/`GlassIconButton`/`GameScreenBackground`)
  — chưa ai gọi.
- Đồng hồ game hiện tại render `Text(data.formattedTime)` trần
  trong `_GameTopBar` scaffold của screen cũ — không tiến trình
  viền, không pulse, không đổi màu theo ngưỡng.
- `GameTimerData` đã có sẵn `progress` (0..1) + `formattedTime`
  (`mm:ss`) từ M19 — widget mới chỉ *render* data này, không
  tính gì thêm.
- Chưa một file nào trong `lib/` dùng `AnimationController` —
  toàn bộ motion tới giờ là `AnimatedOpacity`/`AnimatedSwitcher`
  implicit (M21).

## Vì sao việc này quan trọng ngay bây giờ

- Đây là bài **duy nhất** của milestone học explicit-animation —
  `AnimationController`, `vsync`, `CustomPainter`, `didUpdateWidget`
  đều first-appearance ở đây; Bài 4 (money motion) và Bài 6
  (feature button ripple) **reuse trực tiếp** ba khái niệm này
  mà không dạy lại.
- Timer senior là bài toán điển hình: **hai nguồn motion khác
  nhau** — một loop vô hạn (pulse ở critical) + một one-shot
  (progress tween mỗi giây) — implicit widgets không làm được
  chuyện "chạy khi nào mình bảo" này.
- Painter là cách duy nhất vẽ *viền-tiến-trình-quanh-pill*:
  không widget nào render được "stroke theo stadium path với
  gradient, dừng ở phân-đoạn-progress" — phải `Canvas` thật.

## Bạn đã biết gì

- `StatefulWidget` + `State` + `initState`/`dispose` (F-04/F-05)
  — lifecycle sẵn có để gắn controller.
- `AnimatedSwitcher`/`AnimatedOpacity`/`FadeTransition` (F-29/F-30)
  — implicit animation + `AnimatedBuilder`; `AnimationController`
  là cấp-thấp hơn của cùng cơ chế.
- `part`/`part of` (D-45, M24/M26) — painter file là `part of`
  timer file: chia sẻ private `_strokeWidth`/`_PillProgressPainter`.
- `GameTimerData` (`progress`, `formattedTime`) — DTO M19;
  `Semantics(container: true, label: …)` — F-28 reuse.
- `@visibleForTesting` — `buildGameCountdownTimer
  ProgressPath`/`debugGameCountdownTimerPaintProgress` là seam
  test đã quen.
- `Tween`/curve concept — `Curves.easeOutCubic` đã thấy ở
  `switchInCurve` (M21); `Tween(begin,end).animate(controller)`
  là explicit-phiên-bản.

## Mental model mới — hai khối, một bài

### F-38 — "`AnimationController` là ticker mình sở hữu"

Implicit widgets (`AnimatedOpacity`) giấu controller: bạn đổi
`opacity`, widget tự tween trong `duration`. `AnimationController`
*là* controller đó — nhưng do **bạn** new-up, **bạn** cấp
`vsync`, **bạn** gọi `forward()/repeat(reverse: true)/stop()`,
và **bạn** `dispose()` khi State chết. Bốn trụ cột:

```dart
late final AnimationController _c = AnimationController(
  vsync: this,                 // ticker mượn State — cần mixin
  duration: AppTokens.motionSlow,
  lowerBound: 1,               // khoảng giá trị [1 .. 1.08]
  upperBound: _pulseMaxScale,
);
```

1. **`vsync: this`** — controller cần một `TickerProvider`;
   `TickerProviderStateMixin` cho State khả năng đó (một
   controller hoặc nhiều đều được — timer dùng **hai**). Một
   controller duy nhất thì `SingleTickerProviderStateMixin`
   (Bài 4) hiệu quả hơn.
2. **`lowerBound`/`upperBound`** — controller không chỉ đếm
   0→1: pulse chạy **1→1.08** trực tiếp (giá trị là scale).
3. **`repeat(reverse: true)`** — loop vô hạn: đếm lên rồi đếm
   xuống — "thở" của pulse. `forward()` = one-shot tới bound.
4. **`dispose()`** — State sở hữu ticker; quên dispose = ticker
   chạy ngầm sau khi widget unmount (leak + exception).

### F-39 — "`CustomPainter` là render-object tự vẽ"

`CustomPaint` là widget mỏng bọc một `CustomPainter` delegate:
Flutter layout xong, gọi `painter.paint(canvas, size)` với
`size` đã tính — bên trong bạn phát lệnh vẽ:

```dart
final paint = Paint()
  ..shader = LinearGradient(…).createShader(Offset.zero & size)
  ..style = PaintingStyle.stroke     // viền, không fill
  ..strokeCap = StrokeCap.round
  ..strokeWidth = _strokeWidth;      // 4
canvas.drawPath(progressPath, paint);
```

Ba khái niệm: **`Canvas`** = mặt vẽ (phát `drawPath`/`drawRect`/
`drawCircle`); **`Paint`** = cọ + màu (một lệnh vẽ một `Paint`);
**`Path`** = hình (chuỗi `moveTo/lineTo/arcToPoint`). Kỹ thuật
đặc trưng của timer: `path.computeMetrics().first` lấy
`PathMetric` → `.extractPath(0, length * progress)` cắt đoạn
đầu path theo tỉ lệ → **viền tiến trình** chạy quanh stadium.

### F-40 — "`didUpdateWidget` là điểm đồng bộ prop→controller"

Stateful widget giữ `State` sống *qua* rebuild; khi parent
build widget mới với data mới, Flutter gọi `didUpdateWidget(
oldWidget)` — đây là chỗ State đọc `oldWidget` vs `widget` và
quyết định controller phải làm gì. Timer dùng nó hai lần:

```dart
@override
void didUpdateWidget(covariant GameCountdownTimer oldWidget) {
  super.didUpdateWidget(oldWidget);
  _syncProgress(oldWidget.data);   // tiến trình: animate hay snap?
  _syncPulse();                    // pulse: bật hay tắt?
}
```

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `part of 'game_countdown_timer.dart'` | painter file chia sẻ private của library — `_PillProgressPainter`, `_strokeWidth` (D-45 reuse) |
| `late final AnimationController _c = AnimationController(…)` | `late final` khởi tạo ngay tại field — `this` làm `vsync` an toàn vì State đã tồn tại trước khi field chạy (D-30 reuse) |
| `covariant GameCountdownTimer oldWidget` | `didUpdateWidget` override — `covariant` cho param hẹp hơn kiểu cha |
| `Tween<double>(begin: _animatedProgress, end: target).animate(_progressController)` | nối `Tween` vào controller → `Animation<double>`; `.value` nội suy giữa hai mốc |
| `..addListener(_updateAnimatedProgress)` | cascade gắn listener — mỗi frame controller tick → `setState` đọc `animation.value` |
| `progress.clamp(0, 1).toDouble()` | clamp int-num → double an toàn (painter tự vệ trước data xấu) |
| `math.min(rect.width, rect.height) / 2` | `dart:math` — bán kính stadium = nửa cạnh ngắn (`import 'dart:math' as math`) |

## Flutter cần dùng

| API | Vai trò |
|---|---|
| `TickerProviderStateMixin` | cấp `vsync` cho **nhiều** controller — timer có hai (`SingleTickerProviderStateMixin` chỉ đủ một — Bài 4) |
| `AnimationController({vsync, duration, lowerBound, upperBound})` | explicit ticker — repeat/reverse/forward/stop/value |
| `ScaleTransition(scale: _pulseController, child: …)` | implicit-widget lái bởi explicit-controller — `scale` nhận `Animation<double>` trực tiếp (bounds 1→1.08 nghĩa đen là scale) |
| `AnimatedDefaultTextStyle(duration: …, style: …, child: Text)` | implicit-đổi `TextStyle` — màu chữ crossfade `motionMedium` khi `_timerColor` đổi (chi tiết family ở Bài 5 — F-41 preview) |
| `CustomPaint(foregroundPainter: …, child: …)` | `foregroundPainter` vẽ *trên* child — viền tiến trình phủ lên pill |
| `Canvas.drawPath(path, paint)` | một lệnh vẽ duy nhất — gradient-stroke đoạn-progress |
| `Path.computeMetrics()` → `PathMetric.extractPath(0, len*p)` | cắt đoạn-đầu path theo tỉ lệ — kỹ thuật "progress dọc đường cong" |
| `Paint()..shader=…createShader(rect)..style=stroke..strokeCap=round` | cọ viền gradient — `createShader` cần `Rect` để map gradient lên box |
| `Semantics(container: true, label: l10n.timeRemainingSemanticLabel(…))` | a11y — đọc "Time remaining 00:24" (key Bài 1) |

## Ví dụ độc lập — một painter + một controller (DartPad)

```dart
// ISOLATED EXAMPLE — not in project. F-38+F-39 thu nhỏ:
// controller lái painter vẽ arc progress.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class _ArcPainter extends CustomPainter {
  final double progress;
  const _ArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawArc(
      rect.deflate(6),
      -math.pi / 2,              // bắt đầu đỉnh
      2 * math.pi * progress,    // quét theo progress
      false,
      Paint()
        ..color = const Color(0xFF00E0FF)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

class ArcDemo extends StatefulWidget {
  const ArcDemo({super.key});
  @override
  State<ArcDemo> createState() => _ArcDemoState();
}

class _ArcDemoState extends State<ArcDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();               // chạy vòng 0→1 mãi

  @override
  void dispose() {
    _c.dispose();            // BẮT BUỘC — ticker do mình sở hữu
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(
        size: const Size(80, 80),
        painter: _ArcPainter(_c.value),
      ),
    );
  }
}
```

Timer senior y hệt shape này, khác ở chỗ: *hai* controller
(một loop pulse + một tween progress), `foregroundPainter`
thay `painter`, và path là stadium chứ không phải arc.

## Android / Compose bridge

**SIMILARITY — `CustomPainter` ≈ Compose `Canvas`/`android.
graphics.Canvas`; `AnimationController` ≈ `Animatable`/
`InfiniteTransition`.** Compose `Canvas { drawArc(…) }` phát
lệnh vẽ giống hệt `canvas.drawPath`; `rememberInfiniteTransition`
+ `animateFloat` là `repeat(reverse: true)`; `Animatable` +
`LaunchedEffect` là `forward()` + tween.

**IMPORTANT DIFFERENCE — ownership & lifecycle.** Trong Compose,
`remember` quản animation theo composition; không có `dispose`
tay. Flutter `AnimationController` là **object bạn sở hữu trong
`State`** — `vsync` cần mixin, ticker sống độc lập với build,
và **`dispose()` là trách nhiệm của bạn** (quên = leak +
`Ticker was disposed`/`still active` exception). `didUpdateWidget`
cũng không có tương đương Compose trực tiếp — Compose recompose
đọc prop mới tự nhiên; Flutter State *sống qua* prop đổi nên
cần hook để quyết animate-vs-snap.

**DO NOT ASSUME — `Path.computeMetrics` ≠ đo pixel.** Nó trả
`PathMetric` — chiều dài *hình học* của đường (đơn vị logical
pixel của bản vẽ); `extractPath(0, len*p)` cắt theo *độ dài cung*,
không theo thời gian hay x-ratio. Stadium path có hai đoạn
thẳng + hai nửa-cung — test `'builds progress border path'`
assert `metric.length ≈ 2*straight + 2πr` chính là tổng độ
dài hình học đó.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/widgets/game/timer/game_countdown_timer.dart` (185 dòng) | **verbatim-port** — hai controller dòng 45–56, `_isCritical <= 0.2` dòng 58, `_syncPulse`/`_syncProgress` dòng 129–163, `ScaleTransition` dòng 120–123 |
| `lib/widgets/game/timer/game_countdown_timer_progress_painter.dart` (73 dòng, `part of`) | **verbatim-port** — `paint`/`shouldRepaint` dòng 8–32, `buildGameCountdownTimerProgressPath` stadium dòng 37–64, `debugGameCountdownTimerPaintProgress` dòng 66–73 |
| `lib/widgets/game/layout/game_screen_top_bar.dart` (47 dòng) | **verbatim-port** — `DesignFrame` + `Stack` 72pt: `GlassIconButton(AppAssets.iconGameBack)` trái + `GameCountdownTimer` giữa |
| `test/widgets/game_countdown_timer_test.dart` (7 case) | **verbatim-port** — progress interpolation 500ms/250ms, stadium-path metric asserts, `debugGameCountdownTimerPaintProgress` seam |

## Build it step by step

**Bước 1 — `lib/widgets/game/timer/game_countdown_timer.dart`**
(185 dòng, verbatim senior). Đầu file:

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
// …
part 'game_countdown_timer_progress_painter.dart';

const double _strokeWidth = 4;
const double _pulseMaxScale = 1.08;
const Duration _progressAnimationDuration = Duration(seconds: 1);
```

Hai controller trong `State` (dùng `TickerProviderStateMixin`
vì **hai** ticker — `SingleTicker…` chỉ cấp một):

```dart
class _GameCountdownTimerState extends State<GameCountdownTimer>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: AppTokens.motionSlow,      // 450ms một nhịp
    lowerBound: 1,
    upperBound: _pulseMaxScale,          // 1 → 1.08 trực tiếp
  );
  late final AnimationController _progressController = AnimationController(
    vsync: this,
    duration: _progressAnimationDuration, // 1s mỗi nhịp giây
  )..addListener(_updateAnimatedProgress);
  Animation<double>? _progressAnimation;
  double _animatedProgress = 0;

  bool get _isCritical => widget.data.progress <= 0.2;
```

Pulse = loop vô hạn bật/tắt theo ngưỡng; progress = tween
one-shot mỗi nhịp giây.

`_syncPulse` — gate `<= 0.2`:

```dart
  void _syncPulse() {
    if (_isCritical) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);   // thở 1↔1.08
      }
    } else {
      _pulseController
        ..stop()
        ..value = 1;                              // về scale 1
    }
  }
```

`_syncProgress` — *animate hay snap* (F-40 đúng-nghĩa):

```dart
  void _syncProgress(GameTimerData oldData) {
    final targetProgress = widget.data.progress;

    if (oldData.totalTime == widget.data.totalTime &&
        oldData.remainingTime == widget.data.remainingTime) {
      return;                                    // cùng tick — đứng yên
    }

    if (oldData.totalTime != widget.data.totalTime ||
        targetProgress >= _animatedProgress) {
      _progressController.stop();
      _progressAnimation = null;
      _animatedProgress = targetProgress;        // reset/tăng → SNAP
      return;
    }

    _progressAnimation = Tween<double>(           // giảm → tween 1s
      begin: _animatedProgress,
      end: targetProgress,
    ).animate(_progressController);
    _progressController
      ..value = 0
      ..forward();
  }
```

Logic: đồng hồ *giảm* dần → nội suy mượt 1s giữa hai giây; nhưng
*khi reset về 30s* (`targetProgress >= animated`) hoặc đổi
`totalTime`, tween ngược sẽ chạy vòng — nên **snap** thẳng về
target. Test `'snaps progress when the countdown resets'`
chính là guard nhánh này.

`build` — pill + painter + pulse-gate:

```dart
    final timer = CustomPaint(
      foregroundPainter: _PillProgressPainter(
        progress: _animatedProgress,
        colors: _borderColors(_animatedProgress),
      ),
      child: DecoratedBox(
        // … ConstrainedBox(minWidth: 120) + Padding →
        child: AnimatedDefaultTextStyle(
          duration: AppTokens.motionMedium,
          style: AppTokens.body4.copyWith(
            color: _timerColor(progress),   // trắng/vàng/đỏ
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          child: Text(widget.data.formattedTime),
        ),
      ),
    );
    return Semantics(
      container: true,
      label: l10n.timeRemainingSemanticLabel(widget.data.formattedTime),
      child: _isCritical
          ? ScaleTransition(
              key: _criticalPulseKey,        // 'game-countdown-timer-pulse'
              scale: _pulseController,
              child: timer,
            )
          : timer,
    );
```

**`dispose` ở cuối** — bắt buộc cả hai:

```dart
  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
```

**Bước 2 — `lib/widgets/game/timer/game_countdown_timer_progress_painter.dart`**
(73 dòng, `part of` file trên — *không* có import riêng, chia
sẻ `_strokeWidth`/`math`):

```dart
class _PillProgressPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  const _PillProgressPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final safeProgress = progress.clamp(0, 1).toDouble();

    if (safeProgress <= 0 || size.width <= _strokeWidth) {
      return;
    }

    final path = buildGameCountdownTimerProgressPath(size);
    final metric = path.computeMetrics().first;
    final progressPath = metric.extractPath(0, metric.length * safeProgress);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _strokeWidth;

    canvas.drawPath(progressPath, paint);
  }

  @override
  bool shouldRepaint(covariant _PillProgressPainter oldDelegate) {
    return progress != oldDelegate.progress || colors != oldDelegate.colors;
  }
}
```

Stadium `Path` (đỉnh-giữa → phải → xuống → trái → lên → về
đỉnh, bo tròn 4 góc bằng `arcToPoint` với radius = nửa cạnh
ngắn) là `@visibleForTesting` nên test assert được hình học
mà không render pixel:

```dart
@visibleForTesting
Path buildGameCountdownTimerProgressPath(Size size) {
  final halfStroke = _strokeWidth / 2;
  final rect = Rect.fromLTWH(halfStroke, halfStroke,
      size.width - _strokeWidth, size.height - _strokeWidth);
  final radius = math.min(rect.width, rect.height) / 2;
  final arc = Radius.circular(radius);
  return Path()
    ..moveTo(rect.center.dx, rect.top)
    ..lineTo(rect.right - radius, rect.top)
    ..arcToPoint(Offset(rect.right, rect.top + radius), radius: arc)
    // … quanh 4 góc …
    ..lineTo(rect.center.dx, rect.top);
}
```

`debugGameCountdownTimerPaintProgress` là seam `@visibleForTesting`
thứ hai — test đọc `painter.progress` thay vì so pixel.

**Bước 3 — `lib/widgets/game/layout/game_screen_top_bar.dart`**
(47 dòng, verbatim — consumer đầu tiên):

```dart
    return DesignFrame(
      child: SizedBox(
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GlassIconButton(
                assetIcon: AppAssets.iconGameBack,
                semanticLabel: l10n.exitGameSemanticLabel,
                onTap: onBackTap,
              ),
            ),
            GameCountdownTimer(data: timer),
          ],
        ),
      ),
    );
```

`DesignFrame` (Bài 1) đầu tiên xuất hiện trong sản phẩm —
top bar giới hạn 375, timer căn giữa, nút back `GlassIconButton`
(Bài 2) bên trái.

**Bước 4 — `test/widgets/game_countdown_timer_test.dart`** (7
case, verbatim):

1. `'renders Compose-style pill with accessible time'` — text
   `00:25` + semantics `timeRemainingSemanticLabel`.
2. `'uses Compose countdown color thresholds'` — 25s trắng,
   12s vàng `0xFFFFC107`, 6s đỏ `0xFFF44336` (≤0.4 / ≤0.2).
3. `'pulses only in critical state'` — `ValueKey('game-countdown-
   timer-pulse')` chỉ có khi ≤0.2.
4. `'animates progress smoothly between second ticks'` — sau
   500ms progress ≈ 24.5/30; sau 250ms nữa 24.25/30 → đích 24/30.
5. `'snaps progress when the countdown resets'` — 6s→30s:
   progress nhảy thẳng 1.0, không tween ngược.
6. `'builds progress border path from the top center clockwise'`
   — `metric.length ≈ 2*116 + 2π*20`, tangents đúng điểm.
7. `'fits beside the back button in the game top bar'` — top
   bar 72pt: back trái + timer giữa không chồng.

**Bước 5 — verify.**

```text
flutter analyze  → No issues found!
flutter test test/widgets/game_countdown_timer_test.dart  → 7 passed
flutter test     → +270: All tests passed!
```

## Hiểu code — bốn chi tiết dễ trượt

1. **Pulse *không* honor `MediaQuery.disableAnimations` — cố
   ý.** Senior không gate pulse (chỉ money-motion + reveal-blink
   + dialog-transition honor — Bài 4/5). Port verbatim nghĩa là
   giữ hành vi này; nó là *deliberate parity fact*, không phải
   bug. `ScaleTransition` vẫn loop khi user bật reduce-motion.
2. **`ScaleTransition` bọc *ngoài* pill, không phải painter.**
   Pulse là scale của *toàn bộ timer* (chữ + viền) — painter
   chỉ lo viền-progress; scale là việc của widget layer. Tách
   hai loại motion: controller-pulse → `ScaleTransition`,
   controller-progress → painter `progress:` param.
3. **`_animatedProgress` là state riêng, không phải
   `widget.data.progress`.** Widget-data là *đích*; `_animated
   Progress` là *vị trí hiện tại* — painter nhận `_animated
   Progress` để viền chạy mượt giữa hai giây. Khi `widget.data`
   cập nhật mỗi giây, controller tween `_animatedProgress`
   từ vị-trí-cũ tới vị-trí-mới — đây là lý do test assert
   24.5/30 sau 500ms (giữa chừng).
4. **`part of` chia sẻ private.** `_PillProgressPainter` và
   `_strokeWidth` là private-của-library — file `part` tham
   gia cùng library nên dùng được; đồng thời `buildGameCountdown
   TimerProgressPath`/`debugGameCountdownTimerPaintProgress`
   không-gạch-dưới + `@visibleForTesting` → public-cho-test mà
   không public-cho-app (D-45 reuse `part of`; `@visibleForTesting` chưa có registry row).

## Chạy và quan sát

```text
flutter analyze  → No issues found!
flutter test test/widgets/game_countdown_timer_test.dart  → 7 passed
flutter test     → +270: All tests passed!   (263 + 7)
```

`GameScreenTopBar` chưa có ai gọi (screen mới ở Bài 6) —
compile-độc-lập; top-bar-fit test trong file chứng minh nó
layout đúng với back button.

## Thử nghiệm

Trong `_syncPulse`, đổi `repeat(reverse: true)` thành
`repeat()` (không reverse) — đoán test `'pulses only in
critical state'` có đỏ không, và visual khác gì.

<details>
<summary>Đáp án</summary>

Test **không đỏ** — nó chỉ assert `ValueKey('game-countdown-
timer-pulse')` tồn-tại-khi-critical, không đo dáng lặp. Trên
màn: `repeat()` (không reverse) nhảy scale 1→1.08 rồi *giật
về 1* đột ngột mỗi 450ms — pulse "giật" thay vì "thở". Với
`reverse: true`, controller đếm lên rồi đếm xuống trong cùng
`duration` → chuyển động mượt hai chiều. Đây là lý do senior
chọn reverse — và cũng là loại khác-biệt-visual mà test không
gánh (REAL_DEVICE_VISUAL_CHECK: NOT_PERFORMED).
</details>

## Lỗi hay gặp

1. **Quên `dispose()` controller** — `Ticker` sống sau unmount
   → `A Ticker was active when its State was disposed` exception;
   *mọi* `AnimationController` phải `dispose()` trong `dispose()`.
2. **Dùng `SingleTickerProviderStateMixin` cho hai controller**
   — mixin đó chỉ cấp *một* ticker → runtime assert "got
   multiple tickers"; hai controller cần `TickerProviderStateMixin`.
3. **`shouldRepaint` trả `true` mặc định "cho chắc"** — painter
   repaint mỗi frame kể cả khi không đổi → lãng phí; đúng:
   so `progress` + `colors` (senior làm vậy).
4. **`Tween` begin từ `targetProgress` thay vì `_animated
   Progress`** — tween phải bắt *từ vị trí hiện tại* (`_animated
   Progress`), không từ đích — bắt từ đích nghĩa là nhảy về
   đích rồi đứng yên.
5. **Snap khi nên tween / tween khi nên snap** — nhánh
   `targetProgress >= _animatedProgress` bắt đúng hai trường
   hợp "tiến lên" (reset) và "đổi totalTime"; đảo logic →
   test `'snaps progress…'` đỏ.

## Tự làm — DEBUG

Giả sử ai đó **bỏ `..value = 0` trong `_syncProgress`** (giữ
`..forward()` thôi). Trace chuyện gì xảy ra trên test
`'animates progress smoothly between second ticks'`:

(a) Test có đỏ không? Ở assert nào?  (b) Vì sao `forward()`
từ `value` hiện-tại (không reset) phá tween?

:::note[Gợi ý]
`forward()` chạy từ `value` hiện tại tới `upperBound`. Sau
nhịp đầu (25→24s, 1s), `value` đã là 1.0. Nhịp tiếp theo gọi
`forward()` từ 1.0…
:::

<details>
<summary><strong>Đáp án</strong></summary>

(a) **Đỏ.** Sau nhịp 25→24s xong, `_progressController.value
== 1.0`. Khi data đổi 24→23s và `_syncProgress` dựng tween
mới `begin:24/30 end:23/30` nhưng chỉ `forward()` từ `1.0`:
controller đã ở đích (upperBound=1) → `forward()` không đi
đâu → `animation.value` kẹt ở `end=23/30` ngay lập tức (hoặc
đứng im nếu đã-complete). Assert `_paintProgress ==
closeTo(23.5/30)` sau 500ms sẽ nhận `23/30` (snap ngay tới
đích, không nội suy) → FAIL. (b) `..value = 0` là bước *re-arm*
tween: reset controller về đầu để `forward()` chạy trọn 0→1
trong `duration` — thiếu nó, tween mới không bao giờ chạy vì
controller đã complete. Đây là contract "mỗi nhịp giây =
một tween mới từ đầu" — `..value = 0` + `..forward()` đi
đôi.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao timer cần `TickerProviderStateMixin` chứ
  không `SingleTickerProviderStateMixin`? — **Đáp:** hai
  controller (`_pulseController` + `_progressController`) cần
  hai ticker — `Single` chỉ cấp một, runtime assert ngay.
- **Hỏi:** `_isCritical` đọc `widget.data.progress` hay
  `_animatedProgress`? — **Đáp:** `widget.data.progress` (đích
  thật) — pulse phản ứng *state logic*, không phải vị trí
  tween đang chạy; viền mới dùng `_animatedProgress`.
- **Hỏi:** `extractPath(0, metric.length * p)` cắt theo gì? —
  **Đáp:** theo *độ dài cung* của stadium path — đoạn-đầu
  path dài `p` phần-trăm chu vi; không theo thời gian.
- **Hỏi:** pulse có tắt khi `disableAnimations` bật không? —
  **Đáp:** không — parity cố ý: senior không gate pulse; chỉ
  money-motion/reveal-blink/dialog-transition honor (Bài 4/5).
- **Hỏi:** `didUpdateWidget` khác `build` ở chỗ nào? — **Đáp:**
  `build` render widget-config mới; `didUpdateWidget` là hook
  State *giữa* hai config — nơi so `oldWidget` vs `widget`
  để lái controller (animate-vs-snap) trước khi build chạy.

## Ta cố ý chưa thêm

- Consumer của `GameScreenTopBar`/`GameCountdownTimer` trong
  `GameScreen` — **Bài 6** (screen mới import chúng).
- `GameMoneyAmountMotion` — **Bài 4** (một controller +
  trigger-gate).
- `GameFeatureButton` painter (gradient xoay + ripple) —
  **Bài 6** (hai controller + `Listenable.merge`, painter
  circle khác stadium).
- `AnimatedDefaultTextStyle` giải-kỹ — F-41 family ở Bài 5;
  ở đây nó chỉ là "implicit đổi TextStyle".
- `Interval` stagger + `CurvedAnimation` — Bài 5 answer-list.
- Test `disableAnimations` cho pulse — không có, vì pulse
  *cố ý* không honor (parity fact — không viết test cho
  hành vi senior không có).

## Checkpoint hoàn thành

- [ ] `lib/widgets/game/timer/game_countdown_timer.dart` +
  `…_progress_painter.dart` (`part of`) + `layout/game_screen_
  top_bar.dart` tồn tại verbatim senior.
- [ ] Hai controller: `_pulseController` bounds `1`→`1.08`
  `repeat(reverse: true)` ở ≤0.2; `_progressController` tween
  1s mỗi nhịp giây, snap khi reset.
- [ ] `didUpdateWidget` gọi `_syncProgress(oldWidget.data)` +
  `_syncPulse`; `dispose()` gọi trên cả hai.
- [ ] `_PillProgressPainter`: stadium `Path` + `computeMetrics
  ().first.extractPath(0, len*p)` + `Paint` stroke gradient
  round-cap; `shouldRepaint` so `progress`+`colors`.
- [ ] `test/widgets/game_countdown_timer_test.dart` 7 case xanh.
- [ ] `flutter analyze` sạch; `flutter test` **270/270** (+7).
