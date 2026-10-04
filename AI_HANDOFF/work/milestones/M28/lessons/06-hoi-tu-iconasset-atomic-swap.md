---
title: "Bài 6 · Hội tụ — iconAsset pipeline, atomic swap, regression"
description: "Atomic swap: `GameFeatureButtonData.icon: IconData` → `iconAsset: String` + mapper emit `AppAssets` — đổi DTO phá old-screen + vm-test *cùng lúc* nên phải land một bài (compile-forced atomicity). `GameFeatureButton`+bar port: `TickerProvider`×2, `Listenable.merge`, painter gradient-xoay + ripple, `disableAnimations` cố ý không honor. `GameScreenBody` + `GameScreen` thin-shell senior (`ChangeNotifierProvider` + `AnnotatedRegion` + `Stack` 4 lớp + `_afterExit` dialogMotionLong-wait). Xoá `game_dialog_layer.dart` cũ + `game_dialog_views.dart`. Rewrite `game_screen_test` (14→14) + helpers `pumpGame`/`MultiProvider` + flow(7) + result-flow(8) + feature-button(5); vm_test 2-site iconAsset + `menu_screen_ui_events_test` HOA. +20 → 309/309."
sidebar:
  label: "Bài 6 · hội tụ"
  order: 6
---

## Mục tiêu

- Hoàn tất **atomic swap**: `GameFeatureButtonData.icon:
  IconData` → `iconAsset: String` + mapper emit `AppAssets` —
  một field DTO đổi phá *đồng thời* old-screen (`Icon(data.icon)`),
  `game_screen_view_model_test` (`icon: IconData(0)` ×2), và
  mapper (`Icons.*`) → không có trạng-thái-nửa-chừng nào compile
  được, nên toàn bộ land trong một bài.
- Port `GameFeatureButton` + `GameFeatureButtonBar` — lifeline
  SVG trên painter gradient-xoay + hai-vòng-ripple, `Ticker
  ProviderStateMixin`×2 + `Listenable.merge`, `AnimatedOpacity`
  0.38 + `AnimatedScale` 0.94.
- Port `GameScreenBody` + `GameScreen` thin-shell senior —
  `ChangeNotifierProvider` tạo VM trong screen, `Annotated
  Region<SystemUiOverlayStyle>`, `Stack` bốn lớp (background/
  column/dialog-layer), `_afterExit` chờ `dialogMotionLong`,
  share `SharePlus` + `Clipboard` (M27 reuse).
- **Xoá** hai file cũ: `lib/widgets/game/game_dialog_layer.dart`
  (239d) + `lib/widgets/game/game_dialog_views.dart` (726d) —
  scaffold M20/M21 retire.
- Rewrite test: `game_screen_test.dart` (14→14 shape mới:
  `pumpGame` + `MultiProvider` + `const GameScreen()`),
  `game_screen_test_helpers.dart`, `game_screen_flow_test` (7),
  `game_screen_result_flow_test` (8), `game_feature_button_test`
  (5); update `game_screen_view_model_test` (2-site iconAsset)
  + `menu_screen_ui_events_test` (HOA). → **309/309**.

## Bạn đang ở đâu

- Cuối Bài 5: `flutter test` **289/289**. Mọi bề mặt mới đã
  tồn tại *độc lập*: timer, money, answers, question, dialogs,
  layer mới ở `widgets/game/dialogs/` — nhưng `GameScreen`
  **vẫn là bản cũ**: 629 dòng monolith M20 với `_GameTopBar`/
  `_GameFeatureButton`/`_GameAnswerButton` scaffold inline,
  import layer cũ `widgets/game/game_dialog_layer.dart` +
  `game_dialog_views.dart`.
- `GameFeatureButtonData` vẫn `final IconData icon` — mapper
  emit `Icons.percent`/`Icons.people`/`Icons.auto_awesome`/
  `Icons.emoji_events`; vm-test dựng `icon: IconData(0)` ×2.
- `_DialogShareButton` scaffold M27 (ElevatedButton phẳng) vẫn
  đang render nút share trong views cũ.
- `GameFeatureButton`/`Bar`/`Body` chưa tồn tại — chúng **không
  thể** compile với `icon: IconData` vì chúng đọc `data.iconAsset`.

## Vì sao việc này quan trọng ngay bây giờ

- Đây là điểm **atomic** của milestone: `icon: IconData` →
  `iconAsset: String` là breaking-change trên DTO — mọi
  constructor-site (`_feature` mapper), reader-site (`Icon(
  data.icon)` screen cũ), và test-site (`icon: IconData(0)`)
  đổi *cùng lúc*. Không thể tách "đổi DTO" ra khỏi "đổi
  consumer" thành hai bài mà giữ compile-green — đó là lý do
  wire-up gom vào một bài duy nhất.
- `GameScreen` mới là nơi *mọi bài trước hội tụ*: `GameScreen
  Background` (B2), `GameScreenTopBar` (B3), `GameMoneyAmount`
  (B4), `GameAnswerOptionList`/`GameQuestionPanel` (B5),
  `GameDialogLayer` mới (B5), `GameFeatureButtonBar` (bài này)
  — tám file land thành một màn.
- Sau bài này **không còn scaffold nào của M20/M27** trong
  game-screen: `_GameTopBar`, `_GameFeatureButton`, `_GameAnswer
  Button`, `_DialogShareButton`, layer cũ, views cũ — tất cả
  bị xoá hoặc bị thay bằng port senior.

## Bạn đã biết gì

- `AnimationController`×2 + `TickerProviderStateMixin` +
  `didUpdateWidget` + `dispose` (F-38/F-40, Bài 3) — feature
  button dùng y hệt (gradient 9000ms + ripple 520ms).
- `CustomPainter` + `Paint`/`Path`/`drawCircle`/`shouldRepaint`
  (F-39, Bài 3) — painter circle-gradient + 2-vòng-ripple.
- `SvgPicture.asset` + `colorFilter srcIn` (F-42, Bài 2) —
  `widget.data.iconAsset` là String path đến SVG.
- `AnimatedOpacity`/`AnimatedScale`/`AnimatedBuilder` (F-41/
  F-29, Bài 5) — enabled/disabled motion + merge listenable.
- `ChangeNotifierProvider` + `context.read`/`context.watch`
  (F-18/F-17, A-07 — M14) — screen tạo VM y hệt `MenuScreen`.
- `PopScope` + `unawaited` + `SharePlus`/`Clipboard`/`RenderBox`
  (F-27, F-35 — M19/M27) — share-path giữ nguyên từ M27.
- `GameDialogState` sealed + `switch` (A-21, D-26/27 — M20/21)
  — `onShareResult`/dismiss/terminal rules y hệt layer mới B5.
- `localizedTestApp`/`MultiProvider` test-host + fake repos
  (F-14/A-11 — M14+) — `pumpGame` là shape đó cho screen mới.

## Mental model mới — "DTO đổi-shape là giao-dịch nguyên tử"

> **Atomic DTO migration.** `GameFeatureButtonData` là *hợp
> đồng* giữa mapper (emit) và widget (đọc). Đổi
> `final IconData icon` → `final String iconAsset` vỡ hợp đồng
> theo hai chiều cùng lúc — compiler báo đỏ ở *mọi* call-site
> một lượt, không nửa-chừng. Giá trị của việc này: compile
> lỗi **là** bản-đồ-migration — `flutter analyze` liệt kê đúng
> mọi chỗ phải sửa.

Và pattern `Listenable.merge`:

```dart
AnimatedBuilder(
  animation: Listenable.merge([
    _gradientController,
    _rippleController,
  ]),
  // …
)
```

Một `AnimatedBuilder` nghe *hai* controller cùng lúc — gradient
xoay liên tục *và* ripple một-shot cùng trigger rebuild, thay
vì hai `AnimatedBuilder` lồng nhau. `Listenable.merge` trả một
`Listenable` ảo "bất kỳ nguồn nào tick đều fire".

`_semanticLabel` — chi tiết parity: widget **tự tính** label
từ `data.type` qua `l10n.*SemanticLabel` (switch 5-case), *bỏ
qua* `data.semanticLabel` mà mapper emit. Field tồn tại trong
DTO nhưng widget render localized — giữ y hệt senior.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `final String iconAsset` thay `final IconData icon` | DTO field — `String` path qua `AppAssets`, render `SvgPicture.asset` (pipeline B2/B5); data-layer không cần `material.dart` nữa (file mới không import gì) |
| `GameFeatureButtonType.walkAway \|\| GameFeatureButtonType.exitGame =>` | **or-pattern** trong switch-expression — hai case chung nhánh gradient đỏ `[red700, red500]` (D-27 reuse) |
| `colors.map((c) => c.withValues(alpha: 0.3)).toList(growable: false)` | disabled-gradient — map mọi màu sang alpha 0.3 thay vì đổi màu |
| `unawaited(_afterExit((vm) => vm.backToMenu()))` | fire-and-forget `Future` có-ý-thức (D-09 reuse) |
| `_terminalActionPending` flag | re-entrancy guard — double-tap "CHƠI LẠI" chỉ trigger một reset (test 'rapid terminal play again taps only trigger one reset') |

## Flutter cần dùng

| API | Vai trò |
|---|---|
| `ChangeNotifierProvider<GameScreenViewModel>(create: (c) => GameScreenViewModel(…)..startNewGame(), child: …)` | screen tự-new VM — `create` callback đọc repos qua `context.read` (scope M22); `..startNewGame()` cascade khởi phiên |
| `AnnotatedRegion<SystemUiOverlayStyle>(value: .light)` | status-bar sáng — LIGHT mới: declarative overlay-style cho system chrome |
| `Stack` 4 lớp: `Positioned.fill(GameScreenBackground)` + `SafeArea(Column)` + `GameDialogLayer` | composition cuối — background dưới, cột top-bar/body/feature-bar giữa, dialog-layer trên |
| `Listenable.merge([_gradientController, _rippleController])` | một `AnimatedBuilder` nghe hai ticker — LIGHT mới |
| `ui.Gradient.linear(start, end, colors)` trong painter | gradient xoay — `start`/`end` là `center ± direction*radius` theo `cos(rotation)`/`sin(rotation)` (dart:ui `Gradient`, khác `LinearGradient` widget) |
| `ClipOval` + `AnimatedBuilder` + `CustomPaint(painter:)` | painter-background *dưới* icon SVG — `CustomPaint.painter` (không `foregroundPainter` B3) vẽ *sau* child |
| `MediaQuery.disableAnimations` trong `_afterExit` | chờ `dialogMotionLong` cho terminal animate-out — honor reduce-motion (giây-thứ-ba senior honor: sau money+layer) |
| `tester.view.physicalSize`/`tester.ensureVisible`/`find.byWidgetPredicate` | test helpers — pumpGame scroll tới `GameAnswerOption` ngoài viewport (F-14 reuse) |

## Ví dụ độc lập — DTO-migration atomic (DartPad)

```dart
// ISOLATED EXAMPLE — not in project. Vì sao `icon`→`iconAsset`
// phải atomic: không có "nửa-chừng" compile được.
class ButtonData {
  final String iconAsset;      // ← trước là `final IconData icon`
  const ButtonData(this.iconAsset);
}

ButtonData emit() => const ButtonData('icons/a.svg'); // mapper emit
String render(ButtonData d) => 'Svg(${d.iconAsset})'; // widget đọc

void main() {
  print(render(emit())); // Svg(icons/a.svg)
}
// Nếu đổi ButtonData.iconAsset NHƯNG quên emit() → `iconAsset`
// missing-arg compile-error. Quên render() → `d.icon` undefined
// getter. Compiler liệt kê đúng mọi chỗ — đó là bản-đồ-migration,
// không phải gánh nặng. Muốn "an toàn" bằng cách giữ CẢ `icon`
// LẪN `iconAsset` = hai nguồn-sự-thật → càng hỏng hơn.
```

## Android / Compose bridge

**SIMILARITY — `icon: IconData` → `iconAsset: String` ≈
`ImageVector` → `@DrawableRes Int`/path trong DTO.** Compose
DTO đổi từ `Icons.Default.X` sang `R.drawable.x` cũng phá
mọi call-site (constructor + `Icon(imageVector = …)` →
`painterResource`) — breaking-change y hệt, compiler liệt kê
đúng các chỗ sửa.

**IMPORTANT DIFFERENCE — `String` path ≠ resource-id type-safe.**
Kotlin `@DrawableRes Int` fail *compile* khi resource thiếu;
`String iconAsset` chỉ là `String` — gõ sai path compile *xanh*
rồi `SvgPicture.asset` throw runtime. `AppAssets` constants +
asset-dir-khai-đúng (Bài 1) là đệm duy nhất — không có `R.`
generated-class nào gánh.

**DO NOT ASSUME — `TickerProviderStateMixin` ≠
`rememberCoroutineScope` + `animate*AsState`.** Compose
`animateFloatAsState(enabled)` tự-animate khi prop đổi và
không cần dispose; `GameFeatureButton` new *hai* controller
tay, lái `repeat()`/`forward(from:0)`/`reset()`, `dispose()`
tay, và *không* đọc `disableAnimations` (parity cố ý — sheen/
ripple chạy kể cả reduce-motion). `Listenable.merge` cũng không
có tương đương trực tiếp — gần nhất là `derivedStateOf` trên
hai `State<Float>`.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/widgets/game/lifelines/game_feature_button.dart` (211 dòng) | **verbatim-port** — 2 controller dòng 29–41, `Listenable.merge` dòng 86–88, `_GameFeatureButtonPainter` gradient-xoay+2-ripple dòng 162–211, `_semanticLabel` localized dòng 117–125 |
| `lib/widgets/game/lifelines/game_feature_button_bar.dart` (44 dòng) | **verbatim-port** — `DesignFrame` + Row + `GameFeatureButton` lặp |
| `lib/widgets/game/layout/game_screen_body.dart` (63 dòng) | **verbatim-port** — `LayoutBuilder`+`SingleChildScrollView`+`DesignFrame`+Column(money/question/answers) |
| `lib/screens/game_screen.dart` (201 dòng) | **verbatim-port** — `ChangeNotifierProvider` dòng 27–34, `AnnotatedRegion` dòng 76, `Stack` 4 lớp dòng 85–117, `_afterExit` wait dòng 148–169, `_handleUiEvent` share dòng 171–194 |
| `lib/data/game/game_screen_data.dart` + mapper | learner-verified — `iconAsset` đúng shape senior (senior file gốc không imports; learner thêm doc VI) |
| 4 test file (feature5 + flow7 + result8 + screen14) + helpers | **verbatim-port** — `pumpGame` MultiProvider + `MediaQuery` seam + `ensureVisible`/`predicate` finders |

## Build it step by step

Atomic — **tất cả land cùng lúc**.

:::caution[Trạng thái giữa-chừng không compile — cố ý]
Sau **Bước 1** (DTO đổi `icon`→`iconAsset` + mapper emit
`AppAssets`), `flutter analyze` **sẽ đỏ** — và phải đỏ:
screen cũ đọc `data.icon` (getter đã mất) + vm-test cũ truyền
`icon: IconData(0)` (param đã mất). Đây là *bản-đồ-migration*
mà compiler liệt kê — đi hết Bước 1→6 rồi mới analyze. Đừng
hoàn-nguyên giữa chừng vì thấy đỏ; đỏ ở đây là bằng chứng
contract đã đổi đúng. Checkpoint xanh chỉ tồn tại ở cuối bài.
:::

**Bước 1 — DTO + mapper (`icon` → `iconAsset`).**

`lib/data/game/game_screen_data.dart` — đổi field (file mới
không cần `import 'package:flutter/material.dart'` nữa):

```dart
class GameFeatureButtonData {
  final GameFeatureButtonType type;
  final String iconAsset;          // ← was: final IconData icon
  final String semanticLabel;
  final bool isEnabled;

  const GameFeatureButtonData({
    required this.type,
    required this.iconAsset,       // ← was: required this.icon
    required this.semanticLabel,
    this.isEnabled = true,
  });
  // copyWith cũng đổi icon → iconAsset
}
```

`lib/view_models/game/game_screen_presentation_mapper.dart` —
bỏ `import 'package:flutter/material.dart'`, thêm
`import '../../core/app_assets.dart';` và đổi `_feature`:

```dart
    _feature(
      GameFeatureButtonType.fiftyFifty,
      AppAssets.iconGameFiftyFifty,   // ← was: Icons.percent
      // …
    _feature(
      GameFeatureButtonType.audiencePoll,
      AppAssets.iconGameAudience,     // ← was: Icons.people
      // …
    _feature(
      GameFeatureButtonType.aiAssistant,
      AppAssets.iconGameSparkle,      // ← was: Icons.auto_awesome
      // …
      _feature(
        GameFeatureButtonType.walkAway,
        AppAssets.iconGameTrophy,     // ← was: Icons.emoji_events

GameFeatureButtonData _feature(
  GameFeatureButtonType type,
  String icon,                      // ← was: IconData icon
  // …
  return GameFeatureButtonData(
    // …
    iconAsset: icon,                // ← was: icon: icon
```

Ngay sau bước này `analyze` đỏ ở: screen cũ (`Icon(data.icon)`),
vm-test (`icon: IconData(0)` ×2) — compiler *chỉ* đúng các
chỗ phải sửa; đó là bản-đồ-migration.

**Bước 2 — lifeline widgets mới.**

`lib/widgets/game/lifelines/game_feature_button.dart` (211
dòng, verbatim) — hai controller (gradient `9000ms` repeat +
ripple `520ms`):

```dart
        child: AnimatedOpacity(
          duration: _stateMotion,
          opacity: widget.data.isEnabled ? 1 : 0.38,
          child: AnimatedScale(
            duration: _stateMotion,
            scale: widget.data.isEnabled ? 1 : 0.94,
            child: SizedBox.square(
              dimension: _buttonSize,             // 48
              child: ClipOval(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _gradientController,
                    _rippleController,
                  ]),
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _GameFeatureButtonPainter(
                        colors: _gradientColors,
                        rotation: widget.data.isEnabled
                            ? _gradientController.value * math.pi * 2
                            : 0,
                        rippleProgress: _rippleController.value,
                      ),
                      child: child,
                    );
                  },
                  child: Center(
                    child: SvgPicture.asset(
                      widget.data.iconAsset,      // ← String path
                      // …
                      excludeFromSemantics: true,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
```

Painter `_GameFeatureButtonPainter` (dòng 162–211): vẽ
`drawCircle` với `ui.Gradient.linear` xoay theo
`center ± direction*radius` (`cos/sin(rotation)`), rồi hai
vòng ripple `radius*wave` với `delay = index*0.22`,
`wave = ((rippleProgress - delay)/(1-delay)).clamp(0,1)`,
stroke trắng `alpha: 0.5*(1-wave)`.
`_semanticLabel` switch `data.type` → `l10n.*SemanticLabel`
(*không* dùng `data.semanticLabel` — parity).
`_gradientColors`: `walkAway`/`exitGame` → đỏ; còn lại →
`gameLifelineGradient`; `!isEnabled` → `alpha: 0.3`.
`_syncGradientAnimation`: enabled → `repeat()`; disabled →
`stop() + value=0` + `_rippleController.reset()`.

**Parity cố ý:** `GameFeatureButton` *không* đọc
`MediaQuery.disableAnimations` — sheen/ripple/gradient chạy
kể cả reduce-motion (senior verbatim; cùng nhóm với pulse
Bài 3).

`lib/widgets/game/lifelines/game_feature_button_bar.dart`
(44 dòng, verbatim) — `DesignFrame` + `Padding` + `Row(
for … GameFeatureButton …)` — render `data.featureButtons`
từ mapper (3–4 nút: 50:50 / audience / AI, + walkAway chỉ khi `canWalkAway`;
`exitGame` *không* trong bar — nó là nút ✕ top-bar).

**Bước 3 — `lib/widgets/game/layout/game_screen_body.dart`**
(63 dòng, verbatim): `LayoutBuilder` → `Center` →
`SingleChildScrollView` (bảo đảm nội dung scroll được khi
viewport thấp) → `ConstrainedBox(minHeight: maxHeight)` +
`Center` + `DesignFrame` + `Column(min, [GameMoneyAmount,
GameQuestionPanel, GameAnswerOptionList(questionIndex:)])`.
`GameAnswerOptionList` nhận `questionIndex: data.question.
currentQuestionIndex` — **đó là trigger A-39** lái stagger
replay mỗi câu mới.

**Bước 4 — `lib/screens/game_screen.dart` rewrite** (629d →
201d, verbatim senior). Ba đổi-kiến-trúc:

1. `GameScreen` thành `StatelessWidget` chỉ tạo provider —
   toàn bộ state/logic nhảy vào `_GameScreenEventBridge
   State` (VM đọc qua `context.read`/`watch`):
   ```dart
   class GameScreen extends StatelessWidget {
     const GameScreen({super.key});
     @override
     Widget build(BuildContext context) {
       return ChangeNotifierProvider<GameScreenViewModel>(
         create: (context) => GameScreenViewModel(
           userProfileRepository: context.read<UserProfileRepository>(),
           authRepository: context.read<AuthRepository>(),
           profileSyncRepository: context.read<UserProfileSyncRepository>(),
         )..startNewGame(),
         child: const _GameScreenEventBridge(),
       );
     }
   }
   ```
   Test cũ `GameScreen(viewModel: fake)` **không còn** — VM
   sống trong scope (đây là lý do `pumpGame` mới dùng
   `MultiProvider` + `const GameScreen()`).
2. `Stack` bốn lớp trong `body`: `Positioned.fill(
   GameScreenBackground())` → `SafeArea(Column[TopBar,
   Expanded(Body), FeatureButtonBar])` → `GameDialogLayer`.
   `AnnotatedRegion<SystemUiOverlayStyle>.light` bọc ngoài.
3. `_afterExit` — nút "MENU"/"CHƠI LẠI" trên terminal dialog:
   `dismissDialog()` rồi `await Future.delayed(dialogMotionLong)`
   (hoặc `Duration.zero` khi reduce-motion) *trước khi* gọi
   `backToMenu`/`playAgain` — để dialog animate-out xong đã;
   `_terminalActionPending` chặn double-tap.

`_handleUiEvent` giữ share-path M27 nguyên (`SharePlus.instance.
share(ShareParams(…, sharePositionOrigin: box…))` + catch→
`Clipboard`+snackbar) — không đổi.

**Bước 5 — xoá hai file cũ + sửa vm-test + ui-events-test.**

```text
xóa: lib/widgets/game/game_dialog_layer.dart      (239d — layer cũ)
xóa: lib/widgets/game/game_dialog_views.dart      (726d — views cũ + _DialogShareButton scaffold)
```

Hai file này *cuối cùng* không còn ai import (screen cũ đã
rewrite, `game_dialog_layer_test` đã đổi path ở Bài 5).
`game_screen_test` rewrite ở Bước 6 bỏ import `game_dialog_
views.dart`.

`test/game_screen_view_model_test.dart` — hai site:

```dart
// dòng ~607 và ~783:
GameFeatureButtonData(
  type: …,
  iconAsset: 'test/icon.svg',     // ← was: icon: IconData(0)
  …
)
```

và bỏ `import 'package:flutter/material.dart'` (không còn
`IconData`).

`test/menu_screen_ui_events_test.dart` — một dòng: dialog
intro giờ render qua `GameDialogShell` → title HOA:

```dart
expect(find.text('THANG TIỀN THƯỞNG'), findsOneWidget);
// ← was: find.text('Thang tiền thưởng')
```

**Bước 6 — test rewrite + helpers + flow files.**

`test/widgets/game_screen_test_helpers.dart` (mới, không
đếm test) — `pumpGame(tester, {repos?, disableAnimations})`:

```dart
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AppNavigationController>.value(value: navigationController),
        Provider<UserProfileRepository>.value(value: repository),
        Provider<AuthRepository>.value(value: auth),
        Provider<UserProfileSyncRepository>.value(value: profileSync),
      ],
      child: MaterialApp(
        // … localizedTestApp-style delegates + navigatorKey …
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: const GameScreen(),   // screen tự-new VM trong create:
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
```

+ `dismissMoneyLadder` (assert `'MONEY LADDER'` → tap CTA
`'UNDERSTAND'`), `answerState`/`answerOption` predicate-finders,
`fake` repos (`FakeGameProfileRepository`/`FakeAuthRepository`/
`FakeUserProfileSyncRepository` — A-11 reuse).

`test/widgets/game_screen_test.dart` **rewrite** (14→14, same
count, shape mới): `pumpGame` + real-15-question-bank +
`predicate` finders + `ensureVisible` cho ô ngoài viewport +
dialog asserts HOA (vd `GameConfirmWalkAwayDialogView` type-
finder). Không còn `GameScreen(viewModel: …)` — VM nội-bộ.

`test/widgets/game_screen_flow_test.dart` (+7): intro-ladder-
trước-countdown, route-back-không-dismiss-intro, correct→
explanation→advance, wrong→game-over, lifelines-dialog-
behavior, ladder-pauses/resumes-countdown, money-tap→ladder +
route-back→exit.

`test/widgets/game_screen_result_flow_test.dart` (+8):
terminal-không-dismissible+reset, play-again-auto-sync-auth,
menu-action-waits-exit-motion (2500ms+→`GAME OVER` → tap
`MENU` → wait), reduced-motion-play-again-không-wait, rapid-
double-tap-một-reset, all-correct→victory, +2.

`test/widgets/game_feature_button_test.dart` (+5): gradient
colors đúng mapper (`test` thuần), 48px-circle + 24px-icon,
enabled/disabled `_stateMotion` values (opacity/scale),
tap-semantics+call-handler enabled, disabled-không-tap.

**Bước 7 — regression.**

```text
flutter analyze     → No issues found!
flutter test        → +309: All tests passed!
flutter build web   → PASS
```

## Hiểu code — năm chi tiết dễ trượt

1. **Tại sao atomic:** `game_screen_data.dart` không còn
   `import 'package:flutter/material.dart'` *gì cả* sau đổi
   — `IconData` là *lý do duy nhất* data-layer cần material.
   Giữ cả hai field ("an toàn") sẽ kéo material vào DTO mãi
   mãi + hai nguồn-sự-thật icon. Atomic-swap = một nguồn.
2. **`GameScreen(viewModel:)` ctor-override không còn.** Test
   cũ truyền fake-VM qua ctor; bản senior tạo VM *trong*
   `ChangeNotifierProvider.create` — test inject qua
   `MultiProvider` ở `pumpGame` (repo-fakes), không qua ctor.
   Đây là "screen owns its VM" — y hệt `MenuScreen`.
3. **`semanticLabel` field tồn tại nhưng không render.**
   Mapper emit `semanticLabel` vào DTO, nhưng `GameFeatureButton`
   render `l10n.*SemanticLabel` tự-tính từ `type` — senior
   verbatim. Field nằm sẵn cho consumer khác; đừng "dọn" nó.
4. **`transformHitTests` + `IgnorePointer` phối hợp.** Layer
   `IgnorePointer(ignoring: hidden)` + transition
   `transformHitTests: false` — dialog-đang-ra không bắt tap
   *và* khi hidden toàn-layer không chặn game.
5. **Scaffold retire là một lần cuối.** `_DialogShareButton`
   (M27), `_GameTopBar`/`_GameFeatureButton`/`_GameAnswerButton`
   (M20), layer+views cũ — tất cả là *declared scaffolds*:
   sinh ra để giữ compile-green khi chưa có senior-visual,
   chết khi senior-visual land. Đây là lifecycle scaffold
   (A-13) ở quy mô milestone.

## Chạy và quan sát

```text
flutter analyze     → No issues found!
flutter test        → +309: All tests passed!   (289 + 20)
flutter build web   → PASS
```

**309 = 259 + 0 + 4 + 7 + 6 + 13 + 20.** Verify arithmetic:
+4 qzds (B2), +7 timer (B3), +6 money (B4), +13 surfaces+
layer (B5), +20 (B6: feature5 + flow7 + result8; screen_test
14→14 net-0; vm_test 36→36 net-0 chỉ iconAsset; ui_events
7→7 net-0 chỉ HOA; layer-test đã +1 ở B5).

**`REAL_DEVICE_VISUAL_CHECK: NOT_PERFORMED`** — milestone này
kiểm chứng visual *hoàn toàn* bằng widget test + `build web`;
không ai chạy app nhìn pixel thật trên device/emulator.
**`REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED`** (kế thừa
M27) — share-sheet/notification thật không chạy trên thiết
bị trong pipeline này. Ghi verbatim, không claim-đã-làm.

## Thử nghiệm

Giả sử thay vì atomic, bạn **chỉ** đổi `GameFeatureButtonData.
icon → iconAsset` nhưng *giữ* `IconData icon` cũ (hai field
song song) "cho an toàn". Đoán: `flutter analyze` có xanh
không? Và tại sao đó là anti-pattern dù compile được?

<details>
<summary>Đáp án</summary>

**Analyze xanh** (hai field không xung đột) — nhưng là anti-
pattern *hai nguồn-sự-thật*: `GameFeatureButtonData` giờ mang
`icon: IconData` + `iconAsset: String` — ai emit cái nào?
Mapper phải điền *cả hai* (`Icons.percent` + path) → DTO
kéo `material.dart` mãi + mọi widget phải chọn-đọc-một-trong-
hai (nếu widget A đọc `icon`, widget B đọc `iconAsset`, chúng
có thể lệch nhau khi một bên quên update). Atomic-swap giữ
*một* field → compiler báo đỏ đúng-mọi-chỗ-cần-sửa một lượt;
song-song giữ compile-xanh nhưng đẻ bug đồng-bộ. Đây là lý
do "đổi hết hoặc không đổi" — không có trạng-thái-giữa là
điểm *mạnh* của strongly-typed DTO, không phải bất-tiện.
</details>

## Lỗi hay gặp

1. **Đổi DTO trước, sửa consumer sau** — `flutter analyze`
   đỏ giữa-chừng là *đúng* (đó là bản-đồ); đừng hoàn-nguyên
   vì "đỏ" — cứ đi hết các site compiler liệt kê.
2. **Quên bỏ `import material` trong vm-test/mapper** — file
   không còn `IconData`/`Icons.*` → `unused_import` lint.
3. **Giữ `_DialogShareButton`/views cũ "phòng-khi"** — dead
   code; `GameDialogButton` thật đã cover share; xoá để
   không còn hai đường-render.
4. **`const GameScreen()` với fake-VM cũ** — ctor `viewModel:`
   đã mất; phải inject repo qua `MultiProvider` (VM tự-new
   trong `create:`).
5. **Assert title tiếng-Việt-thường** — views `toUpperCase()`
   → test phải assert `'THANG TIỀN THƯỞNG'`/`'MENU'`/
   `'GAME OVER'`; sai-case = finder-miss.
6. **Nghĩ `Listenable.merge` dispose giùm controller** — nó
   chỉ là `Listenable` ảo; hai controller vẫn `dispose()` tay
   trong `dispose()`.

## Tự làm — PRODUCE

Viết một *scratch test* (tạm — xoá sau khi chạy) cho
`GameFeatureButton` assert gradient **đỏ** cho `walkAway`:
pump một `GameFeatureButton` với `GameFeatureButtonData(
type: GameFeatureButtonType.walkAway, iconAsset: '…',
semanticLabel: '', isEnabled: true)` và đọc `_gradientColors`
ra sao? *Gợi ý:* không cần đọc private getter — assert hành
vi public: widget render `CustomPaint` với painter `colors`
là `[red700, red500]`.

:::note[Gợi ý]
`_GameFeatureButtonPainter` là private — đọc qua
`tester.widget<CustomPaint>(…).painter` rồi cast? Không được
(private type). Thay vào đó assert *public*: widget tồn tại +
`data.type == walkAway` và dùng `debugGameCountdownTimerPaint
Progress`-style seam… nhưng ở đây không có seam — vậy assert
được gì công khai?
:::

<details>
<summary><strong>Đáp án</strong></summary>

Không đọc được `_gradientColors` (private getter trên private
`_State`). Nhưng `game_feature_button_test.dart` senior giải
bằng cách assert **ở mức `find.byWidgetPredicate` +
`tester.widget<GameFeatureButton>`** — đọc `widget.data.type`
và `isEnabled` công khai, còn gradient-colors verify qua
`test('uses Compose mapper gradient colors')` — một `test`
*thuần* (không pump) assert trực tiếp `AppTokens.gameLifeline
Gradient`/`red700`/`red500` constants mà senior dùng trong
`_gradientColors` switch. Scratch-test equivalent:

```dart
test('walkAway maps to red lifeline gradient', () {
  // Assert đúng bảng-màu senior chọn — switch walkAway|exitGame
  // → [red700, red500] là contract; painter đọc colors đó.
  expect(AppTokens.red700, const Color(0xFFD32F2F));
  expect(AppTokens.red500, const Color(0xFFF44336));
  // Và switch-logic: walkAway|exitGame → red pair, còn lại →
  // AppTokens.gameLifelineGradient — kiểm chứng bằng đọc
  // _gradientColors là private → assert constants là cách
  // senior chọn (không mở private ra chỉ để test).
});
```

Đây là "test qua public contract": màu là token (A-38), type-
switch là hành-vi — không cần mở private.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao `icon`→`iconAsset` phải atomic thay vì giữ
  cả hai? — **Đáp:** hai field = hai nguồn-sự-thật (mapper
  phải điền cả hai, widget phải chọn-đọc — lệch nhau được);
  atomic giữ một field → compiler liệt kê mọi call-site phải
  sửa, DTO không kéo `material.dart`.
- **Hỏi:** `GameScreen` mới lấy VM từ đâu nếu không qua ctor?
  — **Đáp:** `ChangeNotifierProvider(create:)` trong chính
  screen — `create` đọc repos bằng `context.read` từ scope;
  test inject repo-fakes qua `MultiProvider`, VM tự-new.
- **Hỏi:** `Listenable.merge` làm gì? — **Đáp:** gộp hai
  `Listenable` (gradient + ripple controller) thành một nguồn
  tick — một `AnimatedBuilder` rebuild khi *bất kỳ* cái nào
  fire; không dispose giùm (hai controller vẫn dispose tay).
- **Hỏi:** feature-button có tắt animation khi reduce-motion
  không? — **Đáp:** không — parity cố ý (senior không đọc
  `disableAnimations` ở đây); chỉ money-motion, reveal-blink,
  và dialog-transition honor.
- **Hỏi:** `_afterExit` chờ `dialogMotionLong` để làm gì? —
  **Đáp:** terminal dialog (ended/victory) cần animate-out
  xong trước khi `backToMenu`/`playAgain` reset state — chờ
  300ms (hoặc 0 khi reduce-motion); `_terminalActionPending`
  chặn double-tap.
- **Hỏi:** `exitGame` đâu trong feature-bar? — **Đáp:** không
  có — nó là nút ✕ `GlassIconButton` trên top-bar (`onBackTap:
  showConfirmExit`); mapper không đưa `exitGame` vào
  `featureButtons`.

## Ta cố ý chưa thêm

- `MenuTokens` → `AppTokens` cho menu/onboarding/settings/
  leaderboard — **M29** (FR-32 còn lại).
- `SettingItemData.icon: IconData` → `iconAsset` — **M29**
  (FR-30); pipeline `SvgPicture` đã sẵn.
- `AppAssets` 58-const còn lại + files — **M29** (subset-policy).
- `SettingsDialogShell`/`OnboardingGameButton`/`MenuDialog
  Backdrop`/`LevelProgressCard`/account-row visual — **M29**
  (FR-28-visual/FR-30/FR-32).
- `MenuDialogLayer` + `MenuDialogSettings/Auth/SignOut`
  transport — **M29** (FR-29).
- `game_dialog_shell_header_test.dart` +
  `game_pill_button_glow_test.dart` — senior có, learner không
  port (declared gap — cover gián tiếp qua layer/screen test).
- `disableAnimations`-gate cho pulse + feature-sheen/ripple —
  **không thêm**, parity cố ý.
- REAL-DEVICE verification — `NOT_PERFORMED`, ghi verbatim.

## Checkpoint hoàn thành

- [ ] `GameFeatureButtonData` là `String iconAsset` (không
  `IconData`); file không import `material.dart`; mapper emit
  `AppAssets.*` ×4 và bỏ import material.
- [ ] `lib/widgets/game/lifelines/game_feature_button.dart` +
  `_bar.dart` + `layout/game_screen_body.dart` + rewrite
  `lib/screens/game_screen.dart` (201d) — verbatim.
- [ ] `lib/widgets/game/game_dialog_layer.dart` (cũ) +
  `game_dialog_views.dart` (cũ) **đã xoá** — không ai import.
- [ ] `test/game_screen_view_model_test.dart` ×2 `iconAsset:
  'test/icon.svg'` + bỏ import material;
  `test/menu_screen_ui_events_test.dart` assert HOA.
- [ ] `test/widgets/game_screen_test_helpers.dart` (`pumpGame`
  MultiProvider) + `game_screen_test.dart` (14) +
  `game_screen_flow_test.dart` (7) + `game_screen_result_flow
  _test.dart` (8) + `game_feature_button_test.dart` (5) xanh.
- [ ] `flutter analyze` sạch; `flutter test` **309/309**
  (+20); `flutter build web` PASS.
- [ ] Đọc được trong code: `REAL_DEVICE_VISUAL_CHECK:
  NOT_PERFORMED` — không claim đã verify trên device.

## Tổng kết milestone

Quay lại 5 câu trong `index.md`:

1. `screenDesignWidth = 375` + `DesignFrame` — một khung thiết
   kế cố định, căn giữa; tokens là nguồn-đúng (A-38).
2. `AnimationController` = ticker mình sở hữu (`vsync`,
   `forward/repeat`, `dispose`) vs implicit widget tự-tween
   theo prop (F-38 vs F-41).
3. `CustomPainter` vẽ qua `Canvas`/`Paint`/`Path` trong
   `paint(Canvas, Size)`; `shouldRepaint` quyết skip (F-39).
4. `animationTrigger` int-gate: chỉ `> old` mới animate —
   data-đổi ≠ transition (A-39); `questionIndex` cũng là
   trigger cho answer-stagger.
5. `icon`→`iconAsset` atomic: DTO đổi-shape phá mọi call-site
   cùng lúc — compiler là bản-đồ-migration, giữ-hai-field là
   anti-pattern hai-nguồn-sự-thật.

M28 đóng visual-parity phần game: `309/309`, `flutter analyze`
sạch, `flutter build web` PASS — phần-còn-lại (menu/settings/
onboarding/leaderboard visuals + `MenuDialogLayer`) là M29.
