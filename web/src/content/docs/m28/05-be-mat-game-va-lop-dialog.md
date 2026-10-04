---
title: "Bài 5 · Bề mặt game + lớp dialog — answers, question, dialogs"
description: "Bề mặt game hoàn chỉnh: `GameAnswerOption`/`Colors`/`List` (stagger `CurvedAnimation`+`Interval`, reveal-blink `TweenAnimationBuilder` keyed `label:text:state`, sin-pulse `_blinkOpacity`), `GameQuestionPanel` (lightning `yellow600` `srcIn` ×2 + `AnimatedSwitcher` key `index-text`), `AudiencePollRow` (`LinearProgressIndicator` bo tròn). Subsystem dialog mới: `GameDialogShell` (card trắng + `headerSheen` + `toUpperCase` + dual `iconAsset`/`icon` if-case) + `GameDialogButton`/`GameDialogMoneyRow` (`_coinGutter` balance) + 3 family views + `dialogs/game_dialog_layer.dart` (runtimeType-keyed `AnimatedSwitcher`, `BackdropFilter` blur 16, `IgnorePointer`, dismiss-rules). implicit-family + semantics nâng. +13 test → 289."
sidebar:
  label: "Bài 5 · bề mặt + dialog"
  order: 5
---

## Mục tiêu

- Port bề mặt game hoàn chỉnh: `GameAnswerOption` + `GameAnswer
  OptionColors` + `GameAnswerOptionList`, `GameQuestionPanel`,
  `AudiencePollRow` — các ô đáp án stagger trượt vào, đáp án
  đúng blink, câu hỏi crossfade khi đổi.
- Học **implicit-animation family** (NORMAL): `AnimatedOpacity`/`AnimatedScale`/`AnimatedContainer`/`AnimatedDefaultTextStyle`/`TweenAnimationBuilder` — widget tự tween khi prop
  đổi, không controller nào của mình; và `CurvedAnimation` +
 `Interval` để stagger *trên một* controller (reuse).
- Học **semantics nâng** (LIGHT): `liveRegion`, `value`,
  `onTap` trong `Semantics` + `getSemantics`/`matchesSemantics`
  test API — TalkBack thông báo "Đúng"/"Sai" khi state đổi.
- Port **toàn bộ subsystem dialog mới**: `GameDialogShell`
  (card + header + `toUpperCase`), `GameDialogButton` (bản thật
  của `_DialogShareButton` scaffold M27), `GameDialogMoneyRow`
  (cân bằng coin), 3 family views (`result`/`help`/`confirm`),
  và `dialogs/game_dialog_layer.dart` thay thế layer cũ —
  `AnimatedSwitcher` keyed `runtimeType`, `BackdropFilter` blur,
  `IgnorePointer`, dismiss-rules.
- +13 test → **289/289** (answer 4 + blink 3 + panel 1 +
  money-row 4 + layer 10→11).

## Bạn đang ở đâu

- Cuối Bài 4: `flutter test` **276/276**. `AnimationController`,
  `CustomPainter`, `didUpdateWidget`, `animationTrigger` đã
  học; `SvgPicture.asset`+`srcIn` đã render ở `GlassIconButton`.
- Đáp án hiện render bằng `_GameAnswerButton` scaffold trong
  screen cũ — container trơn, không stagger, không blink, không
  badge khán giả.
- Dialog hiện chạy qua **layer cũ** `lib/widgets/game/game_dialog_layer.dart` (239 dòng) + `game_dialog_views.dart`
  (726 dòng) — monolith M20/M21: card đơn giản, không shell,
  không sheen, không coin-row. Layer-test cũ là bản VI 10 case
  "chưa port case visual senior".
- `GameDialogState` sealed-family đã đầy đủ 9 variant từ M20
  (8 hiển thị + `GameDialogHidden`) — layer mới *switch* trên
  cùng family đó (9 nhánh), chỉ render khác.

## Vì sao việc này quan trọng ngay bây giờ

- Đây là bài **file nhiều nhất** của milestone (10 lib + 5 test)
  nhưng *ít concept mới nhất* — mọi thứ là reuse có kiến trúc:
  `SvgPicture`+`srcIn` (Bài 2), controller/`didUpdateWidget`/
  trigger (Bài 3-4), `AnimatedSwitcher`/`BackdropFilter`/
  `IgnorePointer`/runtimeType-key (M21). Bài tập lớn ở *đọc
  hiểu cấu trúc*, không ở khái niệm.
- Layer mới là điểm nối: nó *render* `GameMoneyLadderDialogView`
  (Bài 4) + các view shell — land cùng lúc để subsystem dialog
  hoàn chỉnh một mạch; `GameScreen` mới ở Bài 6 chỉ việc gắn
  vào layer này.
- Hai `IconData`→`iconAsset` vẫn *chưa* xảy ra — DTO vẫn
  `icon: IconData`; `GameDialogShell` chấp nhận *cả hai* qua
  dual if-case chính vì vậy (icon Material vẫn còn chỗ dùng
  trong shell; `iconAsset` thắng khi cả hai set).

## Bạn đã biết gì

- `AnimationController` + `SingleTicker…` + `didUpdateWidget` +
 `dispose` (Bài 3-4) — `GameAnswerOptionList` dùng
  y hệt: một controller + `forward(from:0)` khi `questionIndex`
 đổi (chính là trigger!).
- `AnimatedSwitcher` keyed-`runtimeType` + `BackdropFilter` +
  `ImageFilter.blur` + `IgnorePointer` + `Curves.easeIn/OutCubic`
 (M21 layer cũ) — layer mới cùng công nghệ,
  chỉ khác *nội dung* view.
- `SvgPicture.asset` + `ColorFilter.mode(srcIn)` (Bài 2)
  `yellow600` tint cho lightning, `iconGameMoney` không filter
  (giữ màu gốc vàng của file).
- `if (x case final y?)` (Bài 2) — shell dùng *hai lần*:
  `iconAsset` trước, `icon` sau.
- `MediaQuery.disableAnimations` → `Duration.zero` (Bài 4)
  answer-blink, answer-container, layer-transition đều gate;
  `AnimatedSwitcher` duration cũng gate.
- `Semantics(button/enabled/label)` + `ExcludeSemantics` 
 answer-option thêm `value`/`liveRegion`/`onTap` (mới).
- `GameDialogState` sealed 9-case + `switch` exhaustive (M20/M21) — `_dialogBody` switch y hệt layer cũ.

## Mental model mới — "implicit family: widget tự tween" 

> **Implicit-animation widgets.** `AnimatedOpacity`,
> `AnimatedScale`, `AnimatedContainer`, `AnimatedDefaultTextStyle`,
> `TweenAnimationBuilder` — bạn truyền *đích* (`opacity: 0.38`,
> `style:`, `tween: Tween(begin:0, end:1)`) + `duration` +
> `curve`; widget tự sở hữu `AnimationController` nội bộ và
> tween prop cũ→prop mới mỗi lần rebuild. Không `vsync`, không
> `dispose`, không `forward()` — nhưng cũng không "chạy khi
> nào mình bảo": nó chạy *khi prop đổi*.

So sánh trục quyền với Bài 3:

|  | Implicit | Explicit |
| --- | --- | --- |
| Controller | widget tự new | **bạn** new + `vsync` |
| Lái bằng | prop đổi → auto-tween | `forward`/`repeat`/`stop` |
| Dispose | tự | **bạn** `dispose()` |
| Repeat/loop | `TweenAnimationBuilder` re-arm bằng `key` mới | `repeat(reverse:)` |
| Khi nào chọn | prop-drift đơn giản (fade, scale, color) | loop, one-shot gated, nhiều choreography |

`TweenAnimationBuilder` là cầu nối: nó là *implicit* (bạn vẫn
không new controller) nhưng nhận `tween` + `builder` tùy ý —
reveal-blink dùng nó để lái `_blinkOpacity(progress)` custom.

Một trường hợp lai đáng chú ý — `GameAnswerOptionList`: **một**
controller explicit lái *nhiều* `CurvedAnimation` con
với `Interval(start, 1)` khác nhau → bốn ô stagger bằng *một*
ticker, không cần bốn controller:

```dart
final start = math.min(index * 0.1, 0.4);
final animation = CurvedAnimation(
  parent: _controller,
  curve: Interval(start, 1, curve: Curves.easeOutCubic),
);
```

`Interval(0.3, 1)` nghĩa là "con này chỉ chạy trong 70%-cuối
của ticker cha" — ô thứ 4 (start 0.4-cap) vào muộn nhất.

Và **semantics nâng** (LIGHT): `Semantics` không chỉ
`label` — `value:` báo *trạng thái* ("Đã chọn"/"Đúng"/"Sai"),
`liveRegion: true` bảo TalkBack *chủ động đọc* khi node đổi
(đáp án đúng vừa reveal), `onTap:` expose hành động. Test
dùng `tester.getSemantics(finder)` + `matchesSemantics(label:,
value:…)` để assert từng thuộc tính.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
| --- | --- |
| `switch (state) { GameAnswerState.idle => null, … }` | `_stateLabel` — exhaustive enum-switch trả `String?` (idle → không value) — reuse |
| `if (iconAsset case final asset?) … else if (icon case final iconData?)` | reuse — dual if-case trong `_Header`: `iconAsset` thắng, `icon` fallback (IconData vẫn sống tới Bài 6) |
| `'${data.answerLabel}:${data.answerText}:${data.state}'` trong `ValueKey` | key chứa *cả state* — đổi state → widget mới → `TweenAnimationBuilder` re-arm tween từ đầu (kỹ thuật "implicit re-trigger") |
| `math.sin(visibleProgress * math.pi) * 0.34` | `_blinkOpacity` — sin-pulse: 0 → đỉnh ở giữa → 0 trong `visiblePortion` đầu của 1200ms, rồi tắt hẳn |
| `dialog as GameEndedDialog` trong `switch` pattern | pattern `GameEndedDialog()` khớp rồi `as` bóc data — reuse y hệt layer cũ |

## Flutter cần dùng

| API | Vai trò |
| --- | --- |
| `TweenAnimationBuilder<double>({key, tween, duration, builder, child})` | reveal-blink: `end` bật-1-khi-correct (hoặc-0), `key` chứa state để re-arm; `builder` nhận `progress` → `_blinkOpacity` |
| `AnimatedContainer(duration, curve, decoration, …)` | ô đáp án đổi `colors.background`/`colors.border` theo state — crossfade `motionMedium` (hoặc zero khi reduce-motion) |
| `CurvedAnimation(parent, curve: Interval(start, 1, easeOutCubic))` | stagger — cắt một đoạn của ticker cha; `start = min(index*0.1, 0.4)` |
| `Opacity`/`Transform.translate`/`Transform.scale` trong `AnimatedBuilder` | answer-list lái opacity + dy `16*(1-v)` + scale `0.98+0.02v` — cùng một `animation` |
| `AnimatedSwitcher(duration, child: keyed)` | question-text crossfade khi `index-text` đổi (reuse); duration gated reduce-motion |
| `BackdropFilter(filter: ImageFilter.blur(sigmaX:16, sigmaY:16))` | scrim mờ sau dialog — reuse, sigma từ `AppTokens.dialogHazeBlurSigma` |
| `IgnorePointer(ignoring: dialog is GameDialogHidden)` | mở/khóa tap xuống game theo state — y hệt layer cũ |
| `LinearProgressIndicator(value, color, backgroundColor, borderRadius)` | `AudiencePollRow` — thanh % khán giả bo `radiusN` (named-param `borderRadius` mới của indicator) |
| `Semantics(liveRegion:, value:, onTap:)` + `getSemantics`/`matchesSemantics` | TalkBack đọc state đổi chủ động; test assert thuộc tính semantics |
| `FittedBox(fit: BoxFit.scaleDown)` | `GameDialogMoneyRow` — amount dài co chữ xuống thay vì tràn (test 'long amount stays centred') |

## Ví dụ độc lập — implicit stagger trên một controller

```dart
// ISOLATED EXAMPLE — not in project. Lai hai pattern senior: một
// controller, Interval cắt đoạn cho từng item.
import 'package:flutter/material.dart';

class StaggerDots extends StatefulWidget {
  const StaggerDots({super.key});
  @override
  State<StaggerDots> createState() => _StaggerDotsState();
}

class _StaggerDotsState extends State<StaggerDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        final a = CurvedAnimation(
          parent: _c,
          curve: Interval(i * 0.15, 1, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: a,
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: CircleAvatar(radius: 8),
          ),
        );
      }),
    );
  }
}
```

`GameAnswerOptionList` y hệt — chỉ khác `Interval(min(i*0.1,
0.4), 1)` + `AnimatedBuilder` lái opacity+translate+scale cùng
lúc thay vì `FadeTransition` đơn.

## Android / Compose bridge

**SIMILARITY — `TweenAnimationBuilder` ≈ Compose `animateFloat
AsState`/`updateTransition`; `AnimatedContainer` ≈ `animate
*AsState` trên color/size; `Interval` ≈ `keyframes`/`spring`
với delay khác nhau.** Compose stagger bằng `LaunchedEffect` +
delay hoặc `Animatable` per-item; Flutter `Interval` trên *một*
controller là cùng ý tưởng "một timeline, nhiều cửa sổ con".

**IMPORTANT DIFFERENCE — `TweenAnimationBuilder` re-arm bằng
`key`, không phải `LaunchedEffect`.** Trong Compose, đổi
`remember { }` key reset animation; Flutter tương đương là
đổi `ValueKey` — senior đặt `'$label:$text:$state'` vào key
của `TweenAnimationBuilder` để mỗi lần state đổi (idle→correct)
widget *mới* ra đời và tween chạy lại từ `begin: 0`. Không có
`LaunchedEffect(state)` — key *là* cơ chế re-trigger.

**DO NOT ASSUME — `liveRegion` không giống
`LiveRegionMode.polite` của Android.** Android `accessibility
LiveRegion` trên View báo TalkBack đọc khi nội dung đổi; Flutter
`Semantics(liveRegion: true)` cũng đánh dấu node — nhưng nó chỉ
có tác dụng khi *semantics của node đổi* (ở đây `value:` đổi
từ null → "Đúng"). `liveRegion` trên node-idle = vô nghĩa —
senior gate `data.state != GameAnswerState.idle`. Và không
phải mọi animation đều honor reduce-motion: `AnimatedContainer`
duration bị gate bằng tay (`Duration.zero`), không tự động.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
| --- | --- |
| `lib/widgets/game/answers/game_answer_option.dart` (193 dòng) | **verbatim-port** — `TweenAnimationBuilder` keyed `label:text:state` dòng 41–47, `_blinkOpacity` sin-pulse dòng 131–139, semantics `liveRegion`/`value` dòng 29–36, `AnimatedContainer` gated dòng 74–78 |
| `lib/widgets/game/answers/game_answer_option_colors.dart` (45 dòng) | **verbatim-port** — `GameAnswerOptionColors.fromState` bốn state color set (idle/selected/correct/incorrect) |
| `lib/widgets/game/answers/game_answer_option_list.dart` (95 dòng) | **verbatim-port** — `SingleTicker…` + `Interval(min(i*0.1,0.4),1)` stagger dòng 59–61, `forward(from:0)` on `questionIndex` dòng 43 |
| `lib/widgets/game/questions/game_question_panel.dart` (151 dòng) | **verbatim-port** — `AnimatedSwitcher` key `index-text` dòng 80–83, lightning `yellow600 srcIn` ×2 dòng 144–148, count badge `${display}/${total}` |
| `lib/widgets/game/lifelines/game_audience_poll_row.dart` (46 dòng) | **verbatim-port** — `LinearProgressIndicator` + `borderRadius` cho poll row |
| `lib/widgets/game/dialogs/game_dialog_shell.dart` (221 dòng) | **verbatim-port** — shell card + `headerSheen` + `title.toUpperCase()` dòng 186 + dual icon-if-case dòng 197–213; `GameDialogButton`→`QzdsGameButton` dòng 90–98; `GameDialogMoneyRow._coinGutter` dòng 112 |
| `lib/widgets/game/dialogs/game_result_dialogs.dart` (156), `game_help_dialogs.dart` (223), `game_confirm_dialogs.dart` (134) | **verbatim-port** — `_ResultShell` (share `toUpperCase` + `iconGameTrophy`), help (sparkle/audience icon + `AudiencePollRow`), confirm (`primaryText`/`secondaryText` HOA) |
| `lib/widgets/game/dialogs/game_dialog_layer.dart` (191 dòng) | **verbatim-port** — `AnimatedSwitcher` + `ValueKey(dialog.runtimeType)` dòng 93, `_buildTransition` ladder-slide dòng 64–76, `_DialogBackdrop` blur+`DesignFrame` dòng 162–188, `_canDismissFromBackdrop` dòng 54–60 |
| 5 test file (answer 4 + blink 3 + panel 1 + money-row 4 + layer 11) | **verbatim-port** — layer test thay bản VI 10-case bằng senior 11-case |

## Build it step by step

Bài này port 10 file lib + 5 test — chia bốn cụm. Toàn bộ
**verbatim senior**; dưới đây chỉ trích vùng đáng đọc.

**Bước 0 — derive: ma trận dialog → view → dismiss (trước khi mở
senior).**

Đừng mở file senior vội — tự điền bảng này vào giấy trước. Bạn đã có
mọi dữ kiện: `GameDialogState` 9 variant (M20/M21) và tên các view
family vừa đọc ở phần trên:

| Variant `GameDialogState` | View nào render? | Tap nền có đóng được? |
| --- | --- | --- |
| `GameMoneyLadderDialog` | ? | ? |
| `GameEndedDialog` | ? | ? |
| `GameVictoryDialog` | ? | ? |
| `GameExplanationDialog` | ? | ? |
| `GameAIAssistantDialog` | ? | ? |
| `GameAudiencePollDialog` | ? | ? |
| `GameConfirmExitDialog` | ? | ? |
| `GameConfirmWalkAwayDialog` | ? | ? |
| `GameDialogHidden` | *(không view)* | ? |

Hai câu hỏi quyết định:

1. Nhóm variant nào *không được* đóng khi tap nền — và vì sao về mặt
   game (đã kết thúc rồi, hoặc đang xem bảng tiền, thì dismiss vô
   nghĩa)?
2. `AnimatedSwitcher` key bằng gì cho `_layerChild` — index hay
   `runtimeType`? Nếu hai dialog *cùng loại* nối tiếp nhau, key
   `runtimeType` có đủ để replay transition không?

Đến Bước 3, mở `game_dialog_layer.dart` và so bảng của bạn với
`_canDismissFromBackdrop` + `_dialogBody` — đánh dấu mọi ô sai. Bảng
đúng → phần còn lại là công việc gõ; bảng sai → bạn vừa bắt được lỗ
hiểu *trước* khi 191 dòng cuốn qua.

**Bước 1 — answers (3 file).**

`lib/widgets/game/answers/game_answer_option_colors.dart` (45
dòng) — `GameAnswerOptionColors.fromState(state)` trả bộ
`{background, border, textStyle…}` cho `idle`/`selected`/
`correct`/`incorrect`; tách màu ra class riêng để option-widget
chỉ render.

`lib/widgets/game/answers/game_answer_option.dart` (193 dòng) —
vùng trung tâm:

```dart
    return Semantics(
      container: true,
      button: true,
      enabled: effectiveOnTap != null,
      label: l10n.optionSemanticLabel(data.answerLabel, data.answerText),
      value: _stateLabel(data.state, l10n),
      liveRegion: data.state != GameAnswerState.idle,
      onTap: effectiveOnTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          // …
          child: TweenAnimationBuilder<double>(
            key: ValueKey(
              '${data.answerLabel}:${data.answerText}:${data.state}',
            ),
            tween: Tween(
              begin: 0,
              end: _shouldBlink && !disableAnimations ? 1 : 0,
            ),
            duration: _shouldBlink && !disableAnimations
                ? _answerRevealBlinkDuration   // 1200ms
                : Duration.zero,
            builder: (context, progress, child) {
              final blinkOpacity = _blinkOpacity(progress);
              return Stack(
                children: [
                  child!,
                  if (blinkOpacity > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          key: _answerRevealBlinkKey,
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withValues(alpha: blinkOpacity),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
            child: AnimatedContainer(
              duration: disableAnimations
                  ? Duration.zero
                  : AppTokens.motionMedium,
              curve: Curves.easeOutCubic,
              // … decoration dùng colors.background/border …
```

`_blinkOpacity` (dòng 131–139) là sin-pulse: chỉ "hiện" trong
`_answerRevealBlinkVisiblePortion` đầu của 1200ms, `sin(π·x)·0.34`
→ blink lên rồi tắt một lần, không lặp. `effectiveOnTap` null
khi `answerLabel`/`answerText` rỗng (50:50 xoá ô → ô câm hoàn
toàn: không tap, không badge).

`lib/widgets/game/answers/game_answer_option_list.dart` (95
dòng) — stagger-list (đã trích ra file riêng): một controller
`motionSlow`, `didUpdateWidget` `forward(from:0)` khi
`questionIndex` đổi — **`questionIndex` đóng vai
`animationTrigger`** (reuse): câu mới → replay stagger.

**Bước 2 — question panel + poll row (2 file).**

`lib/widgets/game/questions/game_question_panel.dart` (151
dòng) — `_buildQuestionSurface` là **hai lớp gradient viền**
(`gameQuestionStrokeGradient` ngoài + `gameQuestionGradient`
trong, cách nhau `_panelBorderWidth`); `_buildQuestionText`
là `AnimatedSwitcher` gated-reduce-motion, child keyed
`ValueKey('${index}-${text}')` để crossfade khi đổi câu;
`_buildCountBadge` render `'${data.displayQuestionNumber}/${
data.totalQuestions}'` (vd `1/15`) kẹp hai `_lightningIcon()`
— `SvgPicture.asset(AppAssets.iconGameLightning, colorFilter:
ColorFilter.mode(AppTokens.yellow600, BlendMode.srcIn))` — đây
là chỗ `srcIn` *đổi màu thật* (không phải trắng lên trắng như
Bài 2).

`lib/widgets/game/lifelines/game_audience_poll_row.dart` (46
dòng) — một hàng của poll khán giả: `Text(item.option)` +
`LinearProgressIndicator(value, color: qzdsPurple500,
backgroundColor: black12, borderRadius: radiusN)` +
`Text(item.percentage)` — đọc `GameAudiencePollItemData` đã
có từ M20; consumer ở `GameAudiencePollDialogView` bên dưới.

**Bước 3 — dialog subsystem (5 file).**

`lib/widgets/game/dialogs/game_dialog_shell.dart` (221 dòng) —
khung chung của mọi dialog game:

- `GameDialogShell({title, iconAsset, icon, …})` — card ngoài
  gradient viền + card trắng `white100` trong + `_Header`:
  `title.toUpperCase()` + overlay `headerSheen` (Bài 1) +
  dual if-case `iconAsset`-thắng-`icon`-fallback.
- `GameDialogButton` = `SizedBox(width: infinity)` bọc
  `QzdsGameButton(lightShadow: true)` — **bản thật thay
  `_DialogShareButton` scaffold M27** (scaffold đó retire ở
  Bài 6 cùng views cũ).
- `GameDialogMoneyRow` — `SvgPicture.asset(AppAssets.iconGame
  Money)` coin trái + `Flexible(FittedBox(scaleDown, Text))`
  + `SizedBox(width: _coinGutter)` phải — `_coinGutter =
  iconLg + spacingXs` *bằng đúng* coin+gap để amount căn giữa
  dù có coin lệch trái (test assert `center.dx` bằng nhau).

`lib/widgets/game/dialogs/game_result_dialogs.dart` (156 dòng)
— `GameEndedDialogView`/`GameVictoryDialogView` đều đi qua
`_ResultShell` → `GameDialogShell`; victory có
`iconAsset: AppAssets.iconGameTrophy`; nút share
`l10n.shareResultButton.toUpperCase()` — nơi `GameShareResult`
M27 cắm vào `onShareResult` (Bài 6 wire).

`lib/widgets/game/dialogs/game_help_dialogs.dart` (223 dòng) —
`GameExplanationDialogView` (`iconGameSparkle`), `GameAIAssistant
DialogView` (`_LoadingBody`/`_AIAssistantBody` + sparkle),
`GameAudiencePollDialogView` (`iconGameAudience` + list
`AudiencePollRow` — consumer của Bước 2).

`lib/widgets/game/dialogs/game_confirm_dialogs.dart` (134 dòng)
— `GameConfirmExitDialogView` (`exitGameTitle`),
`GameConfirmWalkAwayDialogView` — cặp nút
`primaryText`/`secondaryText` đều `.toUpperCase()` →
`"XÁC NHẬN DỪNG"`/`"CHƠI TIẾP"` trên VI.

`lib/widgets/game/dialogs/game_dialog_layer.dart` (191 dòng) —
**file thay thế**: cùng vai trò layer cũ nhưng render bằng
subsystem mới:

```dart
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: dialog is GameDialogHidden,
        child: AnimatedSwitcher(
          duration: motionDuration,        // zero khi reduce-motion
          reverseDuration: motionDuration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: _buildTransition,
          child: _layerChild(context, l10n, canDismissFromBackdrop),
        ),
      ),
    );
```

```dart
    return dialog is GameDialogHidden
        ? const SizedBox.expand(key: ValueKey('game-dialog-hidden'))
        : SizedBox.expand(
            key: ValueKey(dialog.runtimeType),   // key theo LOẠI dialog
            child: _DialogBackdrop(…),
          );
```

`_buildTransition` — `FadeTransition` + `Transform.translate`
(`transformHitTests: false`), slide-offset `spacingMd` riêng
cho `GameMoneyLadderDialog` (key `ValueKey<Type>(GameMoneyLadder
Dialog)`), `spacingSm` cho phần còn lại.
`_canDismissFromBackdrop` = `dialog is! GameMoneyLadderDialog
&& !_isTerminalDialog(dialog)` — money-ladder + ended/victory
**không** đóng khi tap nền.
`_DialogBackdrop` = `ClipRect` + `BackdropFilter(ImageFilter.blur(16,16))` + `ColoredBox(dialogHazeScrim)` + `Stack`(
`Positioned.fill(GestureDetector)` dismiss + `SafeArea`→
`Center`→**`DesignFrame`**→child) — dialog cũng nằm trong
khung 375.

**Bước 4 — năm test file.**

- `test/widgets/game_answer_option_test.dart` (+4): pill+badge
  audience; `liveRegion`/`value` chỉ khi non-idle
  (`matchesSemantics`); ô rỗng không tap không badge; disabled
  semantics khi `onTap` null.
- `test/widgets/game_answer_option_reveal_blink_test.dart` (+3):
  blink giữ 1200ms tổng nhưng chỉ hiện-`visiblePortion`; không
  blink khi `incorrect`; skip khi `MediaQueryData(disableAnimations: true)`.
- `test/widgets/game_question_panel_test.dart` (+1): surface
  gradient + badge `1/15` + hai lightning.
- `test/widgets/game_dialog_money_row_test.dart` (+4): amount
  `center.dx` ≈ row `center.dx` trong exit/walk-away/result
  dialog + amount dài co chữ vẫn giữa.
- `test/widgets/game_dialog_layer_test.dart` (**thay thế**,
  10→11): bản senior đầy đủ — keyed fade, reduced motion xoá
  ngay-outgoing, dismiss giữ outgoing trong exit, terminal+
  money ladder animate out trước khi remove, ladder fit không
  scroll, acknowledge-dismiss, action-buttons-fill-width,
  outside-tap-rules ×2. Ba case visual senior (shell width/
  shadow/compact-fit) mà file VI cũ từng ghi "→ M28 không
  port" giờ được cover.

**Bước 5 — verify.**

```text
flutter analyze  → No issues found!
flutter test test/widgets/game_answer_option_test.dart \
             test/widgets/game_answer_option_reveal_blink_test.dart \
             test/widgets/game_question_panel_test.dart \
             test/widgets/game_dialog_money_row_test.dart \
             test/widgets/game_dialog_layer_test.dart  → xanh
flutter test     → +289: All tests passed!
```

## Hiểu code — năm chi tiết dễ trượt

1. **Layer mới ≠ layer cũ chỗ *file*, không chỗ *kỹ thuật*.**
   `AnimatedSwitcher` + `runtimeType`-key + `BackdropFilter` +
   `IgnorePointer` + reduce-motion-`Duration.zero` đều đã có ở
   layer cũ (M21) — cái mới là *nội dung*: `_dialogBody` giờ
   trả view shell trắng-`headerSheen`-uppercase thay card cũ,
   và layer bọc `DesignFrame`. File cũ `widgets/game/game_
   dialog_layer.dart` + `game_dialog_views.dart` **vẫn còn
   trên đĩa** sau bài này — Bài 6 mới xoá (screen cũ còn dùng).
2. **`ValueKey('…:$state')` là cơ chế re-trigger của blink.**
   Không có key này, `TweenAnimationBuilder` giữ identity qua
   state đổi và tween `0→0`/`1→0` không replay — key chứa
   state nghĩa là "state mới = widget mới = tween mới từ 0".
3. **`_coinGutter` là *cân bằng*, không phải padding.** Trừ
   đúng `iconLg + spacingXs` ở phải để tổng lệch trái (coin +
   gap) bằng lệch phải → amount text thực sự ở giữa row —
   test `center.dx`-so sánh là bằng chứng.
4. **`iconAsset` thắng `icon` trong shell.** `_Header` có
   `if (iconAsset case …) else if (icon case …)` — thứ tự
   quyết định ưu tiên: asset-path luôn được render nếu cả hai
   set. Đây là cầu nối chuyển tiếp: `IconData` vẫn tồn tại
   trong DTO tới Bài 6.
5. **Answer-list `questionIndex` = money `animationTrigger`.**
 Cùng pattern: prop-int báo "context mới" → `forward(from:0)`
   replay. Khác chỗ: questionIndex *là* data có
   nghĩa (số câu), trigger money là counter thuần tín hiệu.

## Chạy và quan sát

```text
flutter analyze  → No issues found!
flutter test <5 test file>  → xanh (4+3+1+4+11 case)
flutter test     → +289: All tests passed!   (276 + 13)
```

Các widget này vẫn *chưa* vào `GameScreen` thật — screen cũ
vẫn render scaffold M20 và layer cũ. Bài này chứng minh chúng
đúng *độc lập*; Bài 6 wire chúng vào màn.

## Thử nghiệm

Trong `game_answer_option.dart`, bỏ `${data.state}` khỏi
`ValueKey` (giữ `'$label:$text'`). Đoán: test
`'skips reveal blink when reduced animations…'` và test blink
thường có đỏ không? Vì sao?

<details>
<summary>Đáp án</summary>

Test **'keeps total duration but shortens visible correct
blink'** (trong `reveal_blink_test`) **đỏ.** Khi option đi
`idle → correct` với key giữ nguyên (`label:text`), widget
`TweenAnimationBuilder` *giữ identity* — tween `end` đổi
`0→1` nhưng `begin` vẫn `0` nên nó *sẽ* animate (implicit
vẫn chạy khi end đổi)… **nhưng** trong kịch bản *correct →
idle → correct* (câu sau cũng correct cùng label) hoặc khi
parent rebuild với cùng text khác state, widget giữ nguyên
`progress=1` từ lần trước — `end: 1` không đổi → **không
blink lại**. Test senior pump option vào `correct` hai lần
liên tiếp/qua state trung gian và assert blink *replay* —
không có `state` trong key, tween không re-arm → FAIL. Key
chứa state là cách duy nhất "implicit mà vẫn re-trigger" —
đây là bản chất: implicit animation chỉ chạy khi *prop
trong cùng một widget* đổi, không chạy khi bạn cần *context
mới*.
</details>

## Lỗi hay gặp

1. **Xoá file cũ ngay bây giờ** — `widgets/game/game_dialog_layer.dart` (cũ) + `game_dialog_views.dart` vẫn được screen
   cũ + `game_dialog_layer_test` cũ import; xoá sớm = compile
   đỏ. Bài 6 xoá *sau khi* screen rewrite.
2. **`icon` thay `iconAsset` trong `_Header` mới** — nhầm
   thứ tự if-case → `IconData` render khi asset đã có; `iconAsset`
   phải là nhánh *đầu*.
3. **Quên `transformHitTests: false` trong transition** — dialog
   đang trượt ra vẫn bắt tap ở vị trí cũ; senior set `false`
   để outgoing không chặn gesture.
4. **`liveRegion: true` không gate state** — idle cũng live
   làm TalkBack đọc mỗi rebuild; gate `state != idle` như senior.
5. **Assert text tiếng Việt *thường* cho title** — views gọi
   `.toUpperCase()` → phải assert HOA (`"THANG TIỀN THƯỞNG"`,
   `"XÁC NHẬN DỪNG"`); Bài 6 sửa đúng chỗ này trong
   `menu_screen_ui_events_test`.

## Tự làm — PREDICT

Trong `game_answer_option_list.dart`, đổi `math.min(index *
0.1, 0.4)` thành `index * 0.2` (bỏ cap). Với 4 ô đáp án,
ô cuối (index 3) có `Interval` bắt đầu ở đâu? Ô đó còn
animate được không nếu `start` vượt 1.0? Trace `_controller`
0→1 và nói ô cuối hiện khi nào.

:::note[Gợi ý]
`Interval(start, end)` cắt `[start, end]` của ticker cha;
`start` ≥ 1 nghĩa là cửa sổ con bắt đầu *sau khi* cha xong.
:::

<details>
<summary><strong>Đáp án</strong></summary>

`index * 0.2` với index 3 → `start = 0.6` (vẫn < 1 — animate
được, chỉ vào muộn hơn). Nhưng nếu list có 6 ô (index 5) →
`start = 1.0` → `Interval(1.0, 1)` là cửa sổ rỗng: `animation.value` = 0 mãi (hoặc clamp ở cuối) — ô đó **không bao giờ
hiện** (opacity 0 vĩnh viễn). Cap `min(…, 0.4)` chính là
bảo đảm "ô cuối cùng — dù index bao nhiêu — luôn còn 60%
timeline để vào". Đây là lý do senior chọn cap thay vì
`index * 0.1` trần: số ô đáp án có thể đổi (ít hơn 4 khi
50:50 xoá bớt — dù ở đây list giữ 4 ô với text rỗng), cap
giữ stagger an toàn cho mọi độ dài.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** `TweenAnimationBuilder` khác `AnimationController`
  ở chỗ nào? — **Đáp:** implicit — không `vsync`/`dispose`/
  `forward`; nó tween khi `tween.end` hoặc `key` đổi; explicit
  controller chạy khi *bạn* bảo (`forward`/`repeat`).
- **Hỏi:** `Interval(0.4, 1)` trên `_controller` nghĩa là gì?
  — **Đáp:** animation-con chỉ map đoạn 40%→100% của ticker
  cha — ô ở `start=0.4` bắt đầu fade-in khi cha đã qua 40%
  `motionSlow`; stagger trên một ticker duy nhất.
- **Hỏi:** `ValueKey(dialog.runtimeType)` khác `ValueKey
  (dialog)` ở chỗ nào? — **Đáp:** key theo *loại* (Type) —
  hai `GameEndedDialog` data khác nhau cùng một key → switcher
  không coi là dialog mới (không re-animate khi chỉ data đổi);
 key theo instance sẽ animate mỗi data-update (reuse).
- **Hỏi:** `GameDialogButton` khác `_DialogShareButton` scaffold
  M27 ở đâu? — **Đáp:** nó bọc `QzdsGameButton` thật (gradient
  + `lightShadow` + `surfaceGlow`) thay vì `ElevatedButton`
  phẳng — scaffold retire ở Bài 6.
- **Hỏi:** `_canDismissFromBackdrop` chặn dialog nào? — **Đáp:**
  `GameMoneyLadderDialog` + terminal (`GameEndedDialog`/
  `GameVictoryDialog`) — tap nền không đóng được; `onDismiss`
  cho các dialog còn lại.
- **Hỏi:** `_stateLabel` trả `String?` — `idle` về `null` có
  nghĩa gì? — **Đáp:** `Semantics.value` = null → không báo
  trạng thái khi idle; `liveRegion` cũng gate `!= idle` nên
  TalkBack im lặng tới khi reveal.

## Ta cố ý chưa thêm

- Wire các widget này vào `GameScreen` — **Bài 6**; screen cũ
  vẫn chạy scaffold M20 + layer cũ bên dưới.
- `GameFeatureButton`/`GameFeatureButtonBar` (lifeline SVG +
  painter ripple) — **Bài 6** vì `GameFeatureButtonData.icon`
  → `iconAsset` chưa xảy ra (file đó đọc `iconAsset`, không
  compile được với DTO hiện tại).
- `game_screen_body.dart`/`game_screen.dart` mới — **Bài 6**
  (atomic swap).
- Xoá `widgets/game/game_dialog_layer.dart` cũ +
  `game_dialog_views.dart` — **Bài 6** (screen cũ còn import).
- `game_dialog_shell_header_test.dart`,
  `game_pill_button_glow_test.dart` (senior có, learner không
  port) — declared gap: hành vi header/glow cover gián tiếp
  qua layer-test + screen-test.
- `GameFeatureButtonData.semanticLabel` render — field đã có
  từ mapper nhưng widget render `l10n.*SemanticLabel` tự tính
  theo `type` (parity senior — field chỉ là data).

## Checkpoint hoàn thành

- [ ] 10 file lib tồn tại verbatim: `answers/`×3,
  `questions/game_question_panel.dart`,
  `lifelines/game_audience_poll_row.dart`, `dialogs/`×5.
- [ ] `game_dialog_layer.dart` **mới** ở `widgets/game/dialogs/`
  — *không* đụng file cũ `widgets/game/game_dialog_layer.dart`
  (hai file cùng tên tồn tại ở hai thư mục tới Bài 6).
- [ ] `TweenAnimationBuilder` key = `'$label:$text:$state'`;
  `_blinkOpacity` sin-pulse `*0.34` trong `visiblePortion`.
- [ ] Layer: `ValueKey(dialog.runtimeType)`, `IgnorePointer`
  gate `GameDialogHidden`, `_canDismissFromBackdrop` chặn
  ladder+terminal, `_DialogBackdrop` blur16+`DesignFrame`.
- [ ] 5 test file xanh (answer4+blink3+panel1+moneyrow4+
  layer11); `flutter analyze` sạch; `flutter test` **289/289**
  (+13).
