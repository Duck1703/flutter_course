---
title: "Bài 06 — Onboarding visual: header-config theo bước, overlay ba tầng-AnimatedSwitcher, và cái chết của MenuTokens"
description: "Converge — port toàn bộ visual onboarding của senior: `OnboardingHeaderConfig` (title+color+badgeGradient+badgeAsset per-step) + `onboardingHeaderFor` (switch sealed → cấu hình); `OnboardingDialogCard` (outer gradient shell + clipped white card + header màu theo step + `headerSheen` + badge tròn gradient+SVG); `OnboardingStepActions` (AnimatedSwitcher scale 0.92→1 + fade, switch `OnboardingStepState` → welcome/notification/ready); `OnboardingStepIndicator` (`AnimatedContainer` width 8↔24 + radius đổi); `OnboardingOverlay` (3 lớp: AnimatedSwitcher hidden↔visible → BackdropFilter haze+scrim → card-keyed AnimatedSwitcher + `_SkipIntroLink` ẩn ở ready); `OnboardingOverlayScope` khôi phục chain `FutureBuilder`→`StreamBuilder`→`ChangeNotifierProvider` (divergence đã document nay converge) + `requestPermission` thật. **`menu_tokens.dart` DELETED** — `AppTokens`+`OnboardingTokens` = nguồn duy nhất. +14 test: 383/383."
sidebar:
  order: 6
  label: Visual onboarding
---

# Bài 06 — Onboarding visual: ba lớp animate và một file bị xoá

## Mục tiêu

Sau bài này bạn sẽ:

- Đọc được **config-per-step**: `OnboardingHeaderConfig` gom
  title+màu+badge-gradient+badge-asset thành một object; hàm
  `onboardingHeaderFor` switch trên `OnboardingStepType` trả
  cấu hình — widget không `if (step == welcome) màu-tím` rải
  rác.
- Nhận ra **ba lớp `AnimatedSwitcher` lồng nhau** trong
  `OnboardingOverlay` — mỗi lớp một việc: hiện/ẩn cả overlay,
  đổi card theo-step, đổi actions theo-step — và key nào điều
  khiển lớp nào.
- Hiểu `OnboardingStepIndicator` — `AnimatedContainer` chỉ đổi
  `width` (8↔24) + `borderRadius` — implicit-animation nhỏ
  nhất mà vẫn đủ "step tiến".
- Thấy scope khôi phục **chuỗi ba lớp** `FutureBuilder` →
  `StreamBuilder` → `ChangeNotifierProvider` — divergence đã
  documented từ-M18 nay converge; và `requestPermission` gọi
 **service thật** rồi đưa kết quả-OS vào VM.
- Hiểu **vì sao `menu_tokens.dart` bị xoá ở đây** — nó là shim
  learner tự chế khi visual-senior chưa port; sau bài này
  mọi consumer đọc `AppTokens`/`OnboardingTokens` → file không
 còn import → xoá để giữ **một nguồn token** (chốt hạ).

## Bạn đang ở đâu

Sau Bài 05 menu có dialog-layer đúng senior. Còn một mảng
lớn cuối cùng chưa đồng bộ:

```text
learner (trước bài này):
  onboarding_overlay.dart     card đơn-giản: text + button
       — không header màu, không badge, không indicator-animated
  onboarding_header_*         KHÔNG TỒN-TẠI — title là chuỗi-lẻ
  onboarding_overlay_scope    chain bị đơn-giản-hoá thời M18
       (divergence documented: thiếu FutureBuilder-gate)
  lib/core/menu_tokens.dart   shim learner: ~30 const màu/size
       sao-chép từ AppTokens-era — còn vài consumer onboarding
       + menu sót-lại
senior:
  data/onboarding/onboarding_header_config.dart + content-data
       với onboardingHeaderFor/onboardingDescriptionFor
  widgets/onboarding/ 6 file: overlay (4-class restructure),
       dialog_card, step_actions, step_indicator, game_button,
       overlay_scope (3-builder chain verbatim)
```

 trong danh sách khác-biệt còn lại: *"Onboarding visuals — port
`OnboardingTokens`/card/button/indicator/actions/overlay"*.
Và một residual `MenuTokens`→`AppTokens` retirement đã ghi nhận
từ đợt phân tích: *"course-invented, no senior counterpart"* — đợt xoá
được hẹn ngay khi consumer cuối port.

## Vì sao việc này quan trọng ngay bây giờ

Onboarding là **màn đầu tiên** người dùng mới nhìn thấy — và
là file *phức tạp nhất về overlay composition*: trong cùng một-
Stack nó phải ẩn/hiện toàn bộ, mờ nền, crossfade giữa ba step,
và giữ indicator đồng bộ. Đây cũng là bài **chốt nguồn token**:
sau nó, `MenuTokens` — dư âm duy nhất của kỷ nguyên "learner
tự chế visual" — biến mất hoàn toàn. Nếu milestone trước dạy
"một class token", bài này chứng minh "đúng một hệ thống token-
qua toàn repo".

## Bạn đã biết gì

| Đã học | Ở đâu | Nhắc ngắn |
|---|---|---|
| Overlay-scoped VM | M18 | `OnboardingOverlayScope` sở hữu `OnboardingViewModel`; VM + overlay cùng vòng đời |
| Permission-as-state | M27, M29·02 | `requestPermission` gọi service; kết quả-OS → `onNotificationPermissionResult` → step-state đổi |
| Token nguồn duy nhất | M28·01, M29·01 | `OnboardingTokens` delegate→`AppTokens`; giờ `MenuTokens` xoá |
| `AnimatedSwitcher` | M26, M29·05 | crossfade child đổi key — ở đây ×3 lớp |
| `BackdropFilter` + scrim | M29·05 | haze = `dialogHazeBlurSigma` + `OnboardingTokens.hazeScrim` |
| `AnimatedContainer` | M28 | implicit-animate width/radius indicator |
| switch kiệt hợp trên sealed | M29·05 | `OnboardingStepType`/`OnboardingStepState` 3-variant |
| Sweep | M29·01 | verbatim; documented-divergence → converge |

## Mental model củng cố — "animate theo KEY, không theo giá trị"

```text
OnboardingOverlay (lớp 1):
  AnimatedSwitcher ── child: step==null ? shrink('hidden')
                                       : _VisibleOverlay('visible')
  → hiện/ẩn CẢ overlay, duration motionSlow(500)

_OnboardingContent (lớp 2):
  AnimatedSwitcher ── child: OnboardingDialogCard(
                       key: 'onboarding-card-${step.type}')
  → welcome→notification: card CŨ ra, card MỚI vào,
    duration motionEmphasis(400)

OnboardingStepActions (lớp 3 — bên trong card):
  AnimatedSwitcher ── child: _WelcomeActions(key:'…-welcome-$lang') /
                             _NotificationActions('…-$isEnabled') /
                             _ReadyActions('…-ready')
  → actions đổi CÙNG-chuyển-tiếp scale0.92→1+fade,
    duration motionLong
```

Ba lớp, ba key, ba tốc độ — **key là cái nói-"đây là thing
khác"**: cùng key → không animate; khác key → old-out-new-in.
Đổi ngôn ngữ ở welcome (`selectedLanguageCode` nằm trong key)
cũng trigger lớp-3 → actions re-animate nhẹ — chi tiết senior
rất cố ý.

## Dart cần dùng

| Dart | Vai trò ở đây | Xem lại |
|---|---|---|
| `@immutable class OnboardingHeaderConfig` | gói 4-field trình bày cho một step — final fields + const ctor | |
| `switch (type) { welcome => Config(...) … }` | `onboardingHeaderFor` — data→config | |
| `key: ValueKey('onboarding-card-${step.type}')` | key từ enum, không từ instance | |
| `OnboardingWelcomeStep(final selectedLanguageCode)` | object-pattern bind field sealed trong switch | |
| `String.fromCharCode`/`runes` | (liên quan fallback chữ) | đã gặp |

## Flutter cần dùng

| Flutter | Vai trò ở đây | Xem lại |
|---|---|---|
| `AnimatedSwitcher` + `ScaleTransition` + `FadeTransition` | lớp-3 actions | |
| `AnimatedContainer(duration, curve)` | indicator width 8↔24 | |
| `BackdropFilter` + `ClipRect` + `ColoredBox` | haze-overlay | |
| `FutureBuilder` + `StreamBuilder` lồng | scope-gate: future-1-lần rồi stream | reuse |
| `ChangeNotifierProvider(create: … ..load())` | VM-scoped | |
| `SvgPicture.asset(badgeAsset)` | icon-trong-badge | |

## Ví dụ độc lập — config-per-step

```dart
/// VÍ DỤ ĐỘC LẬP — DartPad chạy được.
enum Step { welcome, notification, ready }

class HeaderCfg {
  final String title, color; // demo: String thay Color
  const HeaderCfg(this.title, this.color);
}

HeaderCfg headerFor(Step s) => switch (s) {
  Step.welcome => const HeaderCfg('Chào!', 'purple'),
  Step.notification => const HeaderCfg('Nhắc bạn', 'yellow'),
  Step.ready => const HeaderCfg('Sẵn sàng', 'green'),
};

void main() {
  for (final s in Step.values) {
    final h = headerFor(s);
    print('${s.name}: ${h.title} (${h.color})');
  }
}
```

## Android / Compose bridge

:::note[Android / Compose bridge — "pager-state → header-config"]
- **SIMILARITY**: `onboardingHeaderFor(type)` giống `when(page)
  {0->HeaderCfg("Chào!", Purple)}` trong Compose-pager —
  page→appearance là pure-function.
- **IMPORTANT DIFFERENCE**: `AnimatedContainer` chỉ đổi `width`
  (8↔24) mà *không* đổi `height`: đây là *dot giãn ngang*,
  không phải scale — Compose đối ứng là `animateDpAsState`
  riêng cho width. Đừng port thành `Modifier.animateContentSize`
  — khác chuyển động.
- **DO NOT ASSUME**: đừng nghĩ `FutureBuilder`+`StreamBuilder`
  lồng là thừa — Future trả lời "completed đã đọc từ đĩa chưa"
  (gate lần đầu), Stream trả lời "completed có đang thay đổi
  không" (theo dõi). Một builder không thể làm cả hai.
:::

## Senior project connection

| File senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/data/onboarding/onboarding_header_config.dart` | config 4-field verbatim |
| `lib/data/onboarding/onboarding_content_data.dart` | `onboardingHeaderFor`/`onboardingDescriptionFor` + `onboardingQuestionCount` (đọc từ question bank) + `onboardingLifelineCount=3` |
| `lib/widgets/onboarding/onboarding_dialog_card.dart` | shell+clip+header+badge+actions-slot |
| `lib/widgets/onboarding/onboarding_step_actions.dart` | switch-3-variant + key-theo-state |
| `lib/widgets/onboarding/onboarding_step_indicator.dart` | `AnimatedContainer` dot |
| `lib/widgets/onboarding/onboarding_overlay.dart` | 4-class: Overlay/Visible/Content/SkipIntroLink |
| `lib/widgets/onboarding/onboarding_overlay_scope.dart` | FutureBuilder→StreamBuilder→Provider chain + `_requestNotificationPermission` service thật |
| `lib/widgets/onboarding/onboarding_game_button.dart` | leaf dùng chung (Bài 04 re-port) |
| *(deleted)* `lib/core/menu_tokens.dart` | shim xoá — zero-import sau-batch |
| `test/widgets/{onboarding_overlay(6),onboarding_overlay_scope(5)}` + `test/onboarding_app(3)` + `onboarding_view_model(12)` | +14 net |

:::tip[Suy ra trước — config-per-step là data]
Trước khi thấy `OnboardingHeaderConfig`, tự thiết kế nó:

1. Onboarding có bao nhiêu step? Mỗi step cần *những field nào* —
   title, description, icon, animation… — ghi các field bạn đoán ra.
2. Nếu mỗi step cần key-animation riêng (kiểu
   `ValueKey('onboarding-card-<step>')`), config object nên giữ key
   hay giữ step-index?
3. Field nào *không* nên vào config — vì nó không đổi theo step, hoặc
   là derived value? Nêu một cái.
:::
## Build it step by step

### Bước 1 — `OnboardingHeaderConfig`: step→cấu hình một chỗ

```dart
// learner-app/lib/data/onboarding/onboarding_header_config.dart (trọn-ý)
@immutable
class OnboardingHeaderConfig {
  final String title;
  final Color color;
  /// Gradient of the round badge shown above the step description.
  final Gradient badgeGradient;
  /// SVG asset rendered inside the badge.
  final String badgeAsset;
}
```

```dart
// learner-app/lib/data/onboarding/onboarding_content_data.dart (trích)
OnboardingHeaderConfig onboardingHeaderFor(
    OnboardingStepType type, AppLocalizations l10n) => switch (type) {
  OnboardingStepType.welcome => OnboardingHeaderConfig(
    title: l10n.onboardingWelcomeTitle,
    color: OnboardingTokens.purple500,
    badgeGradient: OnboardingTokens.badgeGradient(
        OnboardingTokens.purple500, OnboardingTokens.purple700),
    badgeAsset: AppAssets.iconGameSparkle),
  OnboardingStepType.notification => OnboardingHeaderConfig(
    color: OnboardingTokens.yellow500, /* + iconBellNotification */ …),
  OnboardingStepType.ready => OnboardingHeaderConfig(
    color: OnboardingTokens.accentGreen500,
    /* badge gradient green500→green700 + iconGameTrophy */ …),
};
```

:::note[Config-vs-string rải]
Trước: `Text(step.title, color: step == welcome ? purple : …)`.
Giờ: một config-4-thứ qua **switch kiệt hợp** — thêm step thứ-
4 buộc compiler đòi config mới; ba-variant-switch là contract.
Và `onboardingQuestionCount` *đọc từ question bank* (`gameSample
Questions.length`) — con số trên onboarding **không thể trôi
khỏi game** (comment verbatim).
:::

### Bước 2 — `OnboardingDialogCard`: shell → clip → header màu

Card dùng **cùng mẹo clip** với settings-shell (Bài 02):
outer-gradient `cardShellGradient` bọc white-card có
`clipBehavior: antiAlias` — header màu theo step nằm trong
card bị clip theo đúng radius; thêm `headerSheen` (token từ
Bài 01) cho hiệu ứng sáng trên header; `_OnboardingBadge` là
vòng tròn 64px `badgeGradient` chứa `SvgPicture(badgeAsset)`.

### Bước 3 — `OnboardingStepActions`: key-mang-state

```dart
// learner-app/lib/widgets/onboarding/onboarding_step_actions.dart (trích)
return AnimatedSwitcher(
  duration: OnboardingTokens.motionLong,
  transitionBuilder: (child, animation) {
    final scale = Tween<double>(begin: 0.92, end: 1).animate(animation);
    return FadeTransition(opacity: animation,
        child: ScaleTransition(scale: scale, child: child));
  },
  child: _buildActions(l10n),
);

Widget _buildActions(l10n) => switch (step) {
  OnboardingWelcomeStep(:final selectedLanguageCode) => _WelcomeActions(
    key: ValueKey('onboarding-actions-welcome-$selectedLanguageCode'),…),
  OnboardingNotificationStep(:final isEnabled) => _NotificationActions(
    key: ValueKey('onboarding-actions-notification-$isEnabled'),…),
  OnboardingReadyStep() => _ReadyActions(
    key: const ValueKey('onboarding-actions-ready'),…),
};
```

:::tip[Key chứa *giá trị*, không chỉ loại]
`…-welcome-$selectedLanguageCode`: chọn ngôn ngữ khác → key
đổi → actions **re-animate** (fade+scale 0.92→1). Đây là khác
biệt với layer-Bài-05 (key=type vì dialog chỉ một instance):
ở đây *cùng variant nhưng khác dữ liệu quan trọng* cũng xứng
animate — key mang phần state liên quan hình ảnh.
:::

### Bước 4 — Indicator: animate nhỏ nhất đủ dùng

```dart
// learner-app/lib/widgets/onboarding/onboarding_step_indicator.dart (trích)
class _OnboardingStepDot extends StatelessWidget {
  final bool isActive;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: AppTokens.motionMedium,
    width: isActive ? OnboardingTokens.indicatorActiveWidth  // 24
                    : OnboardingTokens.indicatorSize,         // 8
    height: OnboardingTokens.indicatorSize,                  // cao cố-định
    decoration: BoxDecoration(
      color: AppTokens.white100.withValues(alpha: isActive ? 1 : 0.3),
      borderRadius: BorderRadius.circular(
        isActive ? AppTokens.spacingXxs : AppTokens.radiusN), // pill↔tròn
    ),
  );
}
```

Chỉ ba biến animate — `width`, `alpha`, `radius` — đủ nói
"step hiện tại nở ngang". `AnimatedContainer` tự tween:
không controller, không setState riêng; dot là thuần hàm của-
`isActive`.

### Bước 5 — `OnboardingOverlay`: ba tầng + skip ẩn ở ready

```dart
// learner-app/lib/widgets/onboarding/onboarding_overlay.dart (trích)
return SizedBox.expand(
  child: AnimatedSwitcher(
    duration: OnboardingTokens.motionSlow,      // 500ms — cả-overlay
    child: step == null
      ? const SizedBox.shrink(key: ValueKey('onboarding-hidden'))
      : _OnboardingVisibleOverlay(
          key: const ValueKey('onboarding-visible'), step: step!, …),
  ),
);
```

```dart
// _OnboardingContent (trích) — lớp-2 keyed-theo-step:
AnimatedSwitcher(
  duration: OnboardingTokens.motionEmphasis,    // 400ms — đổi card
  child: OnboardingDialogCard(
    key: ValueKey('onboarding-card-${step.type}'),
    header: onboardingHeaderFor(step.type, l10n),
    description: onboardingDescriptionFor(step.type, l10n),
    actions: OnboardingStepActions(step: step, …))),
OnboardingStepIndicator(currentStepType: step.type),
if (step.type != OnboardingStepType.ready)      // skip ẩn ở bước-cuối
  _SkipIntroLink(label: l10n.onboardingSkipIntroButton, onTap: onSkipIntro),
```

:::note[Haze ở đây khác dialog ở chỗ nào]
Overlay *không* dùng `MenuDialogBackdrop`: nó có
`GestureDetector(onTap:(){})` — **tap ngoài nuốt hết**, không
dismiss (onboarding không đóng bằng chạm ngoài; chỉ đi tiếp/
skip). Scrim là `OnboardingTokens.hazeScrim` — token riêng,
không phải `dialogHazeScrim`: hai lớp mờ khác nhau theo thiết
kế.
:::

### Bước 6 — Scope: khôi phục chain ba lớp + permission thật

```dart
// learner-app/lib/widgets/onboarding/onboarding_overlay_scope.dart (trích)
return FutureBuilder<bool>(
  future: completionFuture,                     // cờ đọc-từ-đĩa — 1 lần
  builder: (context, snapshot) {
    if (snapshot.connectionState != ConnectionState.done)
      return const SizedBox.shrink();           // chưa-đọc → ẩn
    if (snapshot.data ?? repository.onboardingCompletedStream.value)
      return const SizedBox.shrink();           // đã-hoàn-thành → ẩn
    return StreamBuilder<bool>(
      stream: repository.onboardingCompletedStream,
      initialData: repository.onboardingCompletedStream.value,
      builder: (context, snapshot) {
        if (snapshot.data ?? false) return const SizedBox.shrink();
        return ChangeNotifierProvider<OnboardingViewModel>(
          create: (_) => OnboardingViewModel(…)..loadOnboarding(),
          child: const _OnboardingOverlayConnector());
      });
  });
```

```dart
// _requestNotificationPermission (trích) — quyền THẬT qua service:
final granted = await notificationService.requestPermission();
await viewModel.onNotificationPermissionResult(granted);
// catch → reportError + onNotificationPermissionResult(false)
```

:::caution[Vì sao cần cả Future lẫn Stream?]
- `FutureBuilder` trả lời câu-*một lần*: "đã đọc xong cờ chưa"
  → gate overlay khởi động.
- `StreamBuilder` trả lời câu-*liên tục*: "cờ có vừa lật không"
  (ví dụ complete từ nơi khác) → ẩn overlay ngay.
Bản đơn giản-M18 chỉ giữ-Stream → overlay nháy hiện rồi mới ẩn
khi future-resolve-xong (flash-1-frame). Chain ba lớp là câu
trả lời: future gate đọc, stream theo dõi, provider-scoped-VM —
divergence documented từ-M18 **converge tại đây**.
:::

### Bước 7 — `menu_tokens.dart` bị xoá

```bash
grep -rn "menu_tokens\|MenuTokens" lib/   # → trống trước khi xoá
rm lib/core/menu_tokens.dart              # điều-kiện-xoá: zero-import
```

```text
sau bài này:
  AppTokens        — foundations (màu, spacing, motion, gradient…)
  OnboardingTokens — delegate→AppTokens + giá-trị-chỉ-onboarding
  MenuTokens       — KHÔNG-TỒN-TẠI (đã-là-shim-thời-tạm-M14→M29·05)
```

:::caution[Xoá file cũng là port]
Trong sweep, *không có file* cũng phải khớp senior:
senior không có `menu_tokens.dart` → learner không được có.
Điều kiện an toàn là grep-zero-import — không phải "chắc ai
cũng dời rồi". Đây là REMOVED-row cuối cùng của token-drift.
:::

## Hiểu code — 6 chi tiết dễ trượt

**1. `step.type` trong key, không phải `step`** — card-key
`'onboarding-card-${step.type}'`: cùng welcome khác language
→ lớp-2 *không*-animate (type giống) nhưng lớp-3 *có* (key
chứa language). Ba mức độ-"khác" tách đúng ba lớp.

**2. `_SkipIntroLink` ẩn ở `ready`** — comment verbatim:
*"primary action already ends the flow"* — nút finish ở step
cuối đã là escape hatch; để skip link = hai đường thoát trùng
ngữ nghĩa.

**3. `SizedBox.shrink` khi `step==null`** — overlay vẫn mount
(nó nằm trong-Stack màn menu) nhưng render rỗng — `Animated
Switcher` cần child-*tồn tại* để fade; null child không animate
được, shrink keyed animate được.

**4. `snapshot.data ?? repository...value`** — future-stream
đều có fallback về `.value`: future lỗi/null → dùng trị hiện
tại của stream; không crash khi snapshot thiếu.

**5. `context.read` trong `didChangeDependencies`** — scope
đọc repo *không watch* (chỉ cần instance một lần); `identical`
guard chặn reload khi dependency lặp — y hệt `_attachViewModel`
ở-Bài-05.

**6. `OnboardingTokens.hazeScrim` ≠ `AppTokens.dialogHazeScrim`**
— hai lớp mờ khác alpha theo thiết kế: onboarding mờ nhẹ hơn
(dialog đậm hơn). "Token riêng" không phải trùng lặp mà là
ngữ nghĩa khác — đúng-.

## Chạy và quan sát

```bash
cd learner-app
flutter test test/widgets/onboarding_overlay_test.dart \
             test/widgets/onboarding_overlay_scope_test.dart \
             test/onboarding_app_test.dart \
             test/onboarding_view_model_test.dart
# 6 + 5 + 3 + 12 = 26 → net +14 (retire learner-predecessor)
flutter test                      # 383/383 (+14)
grep -rn "MenuTokens" lib/        # trống — file đã-xoá
ls lib/core/                      # không-còn menu_tokens.dart
```

Quan sát (chạy app lần đầu hoặc xoá flag): overlay mờ hiện
500ms → card welcome tím fade vào; chọn ngôn ngữ → actions
nháy nhẹ (key đổi); next → card vàng crossfade; đồng ý quyền
→ OS-dialog thật → step-ready-xanh; indicator dot đang dùng
nở ngang 8→24; skip intro biến mất ở step cuối.

## Thử nghiệm

| Thử | Dự đoán | Thực tế |
|---|---|---|
| Bỏ `key: 'onboarding-card-${step.type}'` | chuyển step trông sao? | `AnimatedSwitcher` thấy cùng-`OnboardingDialogCard`-type → không crossfade; nội dung hốt nhiên đổi giữa chừng |
| `indicatorActiveWidth` = `indicatorSize` | indicator ra-sao? | ba dot giống hệt — không còn tín hiệu step; visual-state *là* width khác |
| Để `_SkipIntroLink` hiện cả ở ready | UX ra-sao? | hai đường thoát song song: nút finish + link-skip cùng nghĩa — senior giấu cố ý |
| Bỏ `FutureBuilder`, giữ `StreamBuilder` | lần đầu mở app? | stream-initialData-false → overlay hiện ngay rồi ẩn khi future trả true → **flash-1-frame** — chính lý do chain ba lớp tồn tại |

## Lỗi hay gặp

| Lỗi | Vì sao | Sửa |
|---|---|---|
| Overlay nháy rồi biến | thiếu `FutureBuilder`-gate | chain Future→Stream→Provider |
| Card không đổi màu theo step | quên `onboardingHeaderFor` — hardcode màu | config-per-step qua switch |
| Quyền không xin được / skip-ngay | gọi `onNotificationPermissionResult(true)` cứng | service thật `requestPermission()` rồi truyền kết quả-OS |
| `MenuTokens` vẫn import đâu đó | sót consumer | `grep -rn MenuTokens lib/` → 0 rồi mới xoá |
| `AnimatedContainer` không động | đổi child thay vì đổi property | implicit-animate chỉ chạy khi-*property của container*-đổi (width/radius) — không phải khi widget con đổi |

## Tự làm

**PREDICT** — Bạn đổi `key: ValueKey('onboarding-card-${step
.type}')` thành `ValueKey('onboarding-card')` (key cố định).
Chuyện gì xảy ra ở welcome→notification, và lớp naò vẫn animate?

:::note[Gợi ý]
`AnimatedSwitcher` lớp-2 so-key để quyết fade; lớp-3 ở *trong*
card.
:::

<details>
<summary>Đáp án</summary>

Lớp-2 *mất*-animate: cùng key → switcher coi như cùng card →
header/description đổi không fade (pop-instant). Lớp-3-vẫn
animate (key actions đổi) → actions-fade+scale trong card tĩnh
— cảm giác "chữ nhảy nền đứng". Đó là dấu hiệu key sai tầng.

</details>

**DEBUG** — Tester: "lần đầu cài app onboarding hiện rồi tắt
ngay dù chưa hoàn thành". `future` + `stream` đều có. Mắt xích
nào gãy?

:::note[Gợi ý]
`initialData` của StreamBuilder lấy ở đâu — và stream-*.value*
lúc đầu là gì?
:::

<details>
<summary>Đáp án</summary>

`initialData: repository.onboardingCompletedStream.value` —
nếu repo-seed `value=false` trước khi đọc đĩa xong, StreamBuilder
trả false ngay → provider-mount-VM → overlay hiện; sau đó
stream đẩy true → shrink. `FutureBuilder`-gate phải-*chặn*
StreamBuilder khởi tạo đến khi `connectionState==done`: nếu ai
đó bỏ gate-(hoặc dùng-`snapshot.data`-sai) → flash. Kiểm thứ
tự đúng-3-lớp.

</details>

**PRODUCE** — Viết `onboardingDescriptionFor` tương tự
`onboardingHeaderFor` — nhưng lưu ý khác biệt: nó trả-`String`,
không config. Khi nào một bước cần config, khi nào chỉ cần
chuỗi?

:::note[Gợi ý]
Đếm field: header = title+color+gradient+asset (4 thứ) vs
description = 1 thứ.
:::

<details>
<summary>Đáp án</summary>

```dart
String onboardingDescriptionFor(Step t, AppLocalizations l10n) =>
  switch (t) {
    OnboardingStepType.welcome => l10n.onboardingWelcomeDescription,
    OnboardingStepType.notification =>
      l10n.onboardingNotificationDescription,
    OnboardingStepType.ready => l10n.onboardingReadyDescription,
  };
```

Luật ngón tay: **config khi ≥2 thuộc tính trình bày đi cùng
nhau** (title+màu+badge là một bộ); chỉ-1-field → hàm switch-
string đủ — config-1-field chỉ là bọc thừa. Senior tách đúng
hai hàm vì đúng hai mức đó.
</details>

## Kiểm tra hiểu biết

**H: Ba `AnimatedSwitcher` khác nhau ở gì?** — Tầng-1 (`motion
Slow` 500): hiện/ẩn cả overlay keyed-'hidden/visible'; tầng-2
(`motionEmphasis` 400): đổi card keyed-'card-{type}'; tầng-3
(`motionLong`): đổi actions keyed-'actions-{type-state}'.
Mỗi lớp một key một tốc độ một-"đơn vị thay đổi".

**H: `OnboardingStepIndicator` sao không dùng controller?** —
Dot chỉ đổi ba property (`width`,`alpha`,`radius`) khi `isActive`
đổi — `AnimatedContainer` implicit tween đủ; controller chỉ
cần khi animate có sequence/loop/trigger phức tạp (-vs-
).

**H: `menu_tokens.dart` vì sao không-"giữ lại dự phòng"?** —
Vì nó là shim có nguồn khác đúng (`AppTokens`/`OnboardingTokens`);
giữ shim = hai nguồn token → drift quay lại. Xoá khi zero-
import là *conclude* của nguyên tắc: một hệ thống một nguồn.

**H: Scope chain ba lớp có phải over engineering?** — Không:
mỗi builder một câu hỏi không thể gộp — Future="đã đọc xong
chưa", Stream="cờ có đang đổi không", Provider="VM-sống ở đâu".
Đơn giản hoá = flash-1-frame hoặc overlay kẹt hiện.

## Ta cố ý chưa thêm

- **Không port `onboardingHeaderFor` thành config class khác** —
  đã verbatim; không thêm field senior không có (ví dụ
  `subtitleColor`).
- **Onboarding-*test-app* (`onboarding_app_test` 3-case)** đã
  port nhưng mức smoke — không viết thêm scenario tự chế.
- **Badge-asset chỉ-3-icon** (sparkle/bell/trophy) — verbatim;
  không gắn asset đẹp hơn.
- **`lib/core/dre` giữ nguyên** — thư mục DRE-engine đã verbatim
  từ M26 và cũng tồn tại ở senior; bài này chỉ xoá `MenuTokens`,
  không đụng file nào đã khớp.

## Checkpoint hoàn thành

- [x] `OnboardingHeaderConfig` + `onboardingHeaderFor`/
      `onboardingDescriptionFor` — config-per-step, switch
      kiệt hợp; `onboardingQuestionCount` đọc từ question bank.
- [x] `OnboardingDialogCard` — shell+clip+header màu+badge
      gradient+SVG; `OnboardingStepActions` — switch-sealed +
      key-mang-state; `OnboardingStepIndicator` —
      `AnimatedContainer` 8↔24.
- [x] `OnboardingOverlay` — 2-lớp-`AnimatedSwitcher` (+1 trong `OnboardingStepActions`) +
      `BackdropFilter`+`hazeScrim`+`_SkipIntroLink`-ẩn ở ready;
      tap ngoài nuốt (không dismiss).
- [x] `OnboardingOverlayScope` — chain `FutureBuilder`→
      `StreamBuilder`→`ChangeNotifierProvider` khôi phục;
 `requestPermission` service thật → VM-result.
- [x] **`lib/core/menu_tokens.dart` DELETED** — zero-import
      điều kiện xoá; `AppTokens`+`OnboardingTokens` = nguồn duy
 nhất (chốt).
- [x] `flutter analyze` clean · `flutter test` **383/383**
      (+14: overlay 6 + scope 5 + app 3 + vm 12 − retire).

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m29/06 — "Onboarding visual: header-config theo bước, overlay ba-tầng-AnimatedSwitcher, và cái chết của MenuTokens" (`OnboardingHeaderConfig` title+color+badgeGradient+badgeAsset per-step + `onboardingHeaderFor`/`onboardingDescriptionFor`/`onboardingQuestionCount`(đọc-từ-bank)/`onboardingLifelineCount=3`; `OnboardingDialogCard` outer-gradient + clipped-white-card + header-màu-step + `headerSheen` + badge-64-gradient-SVG; `OnboardingStepActions` AnimatedSwitcher scale-0.92→1+fade switch-3-variant key-mang-state; `OnboardingStepIndicator` `AnimatedContainer` width-8↔24+radius; `OnboardingOverlay` 4-class 3-lớp-switcher (hidden↔visible motionSlow → haze → card-keyed motionEmphasis) + `_SkipIntroLink` ẩn-ở-ready + tap-ngoài-NUỐT không-dismiss + `OnboardingTokens.hazeScrim`≠`dialogHazeScrim`; `OnboardingOverlayScope` khôi-phục FutureBuilder→StreamBuilder→Provider chain (divergence-documented-M18 → converge) + `requestPermission` service-THẬT; **`menu_tokens.dart` XOÁ** zero-import-guard; +14 → 383).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `grep`/`findstr` cho `MenuTokens`/`menu_tokens`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. "Animate theo KEY không theo giá-trị" — ba-lớp-ba-key-ba-tốc-độ là contract visual.

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/onboarding/onboarding_header_config.dart` (FILE MỚI STRICT verbatim): `@immutable class OnboardingHeaderConfig` 4-final `String title`/`Color color`/`Gradient badgeGradient`/`String badgeAsset` const-ctor.
- `lib/data/onboarding/onboarding_content_data.dart` (STRICT): `onboardingHeaderFor(OnboardingStepType type, AppLocalizations l10n)` switch-kiệt-hợp `welcome → Config(l10n.onboardingWelcomeTitle, OnboardingTokens.purple500, badgeGradient(purple500→purple700), AppAssets.iconGameSparkle) / notification → (yellow500, iconBellNotification) / ready → (accentGreen500, iconGameTrophy)` + `onboardingDescriptionFor` + `onboardingQuestionCount` đọc `gameSampleQuestions.length` (STRICT derived-từ-bank — literal-hardcode = DIVERGED trôi-số) + `onboardingLifelineCount = 3`.
- `lib/widgets/onboarding/` 6-FILE (STRICT verbatim):
  - `onboarding_dialog_card.dart` — outer `cardShellGradient` + white-card `clipBehavior: antiAlias` (cùng-mẹo-settings-shell) + header-màu-theo-step + `headerSheen` + `_OnboardingBadge` 64 `badgeGradient` + `SvgPicture.asset(badgeAsset)` + actions-slot;
  - `onboarding_step_actions.dart` — `AnimatedSwitcher(duration: OnboardingTokens.motionLong, ScaleTransition(0.92→1)+FadeTransition)` + `_buildActions` switch `OnboardingWelcomeStep(:final selectedLanguageCode) → _WelcomeActions(key: 'onboarding-actions-welcome-$selectedLanguageCode') / OnboardingNotificationStep(:final isEnabled) → _NotificationActions(key: 'onboarding-actions-notification-$isEnabled') / OnboardingReadyStep() → _ReadyActions(key: 'onboarding-actions-ready')` (STRICT key-CHỨA-giá-trị-state — khác-Bài-05-key=type: đổi-ngôn-ngữ → re-animate actions);
  - `onboarding_step_indicator.dart` — `_OnboardingStepDot` `AnimatedContainer(duration: AppTokens.motionMedium, width: isActive ? indicatorActiveWidth(24) : indicatorSize(8), height: indicatorSize, color white100 alpha isActive?1:0.3, radius isActive?spacingXxs:radiusN)` (STRICT width-only animate — height-đổi/scale = DIVERGED chuyển-động);
  - `onboarding_overlay.dart` — 4-class `OnboardingOverlay`/`_OnboardingVisibleOverlay`/`_OnboardingContent`/`_SkipIntroLink`: lớp-1 `SizedBox.expand(AnimatedSwitcher(duration: OnboardingTokens.motionSlow, child: step == null ? SizedBox.shrink(key:'onboarding-hidden') : _VisibleOverlay(key:'onboarding-visible', step: step!)))` (STRICT shrink-keyed không-null-child); lớp-2 `_OnboardingContent` `AnimatedSwitcher(motionEmphasis, child: OnboardingDialogCard(key: ValueKey('onboarding-card-${step.type}')))` + haze `ClipRect`/`BackdropFilter`/`ColoredBox(OnboardingTokens.hazeScrim)` + `GestureDetector(onTap: () {})` tap-ngoài-nuốt (STRICT KHÔNG-dismiss — onboarding không-đóng-bằng-chạm-ngoài) + `OnboardingStepIndicator` + `if (step.type != ready) _SkipIntroLink` (STRICT ẩn-ở-step-cuối);
  - `onboarding_overlay_scope.dart` — `FutureBuilder<bool>(future: completionFuture)` gate `connectionState != done → shrink` + `data ?? stream.value → done → shrink` → `StreamBuilder<bool>(stream: onboardingCompletedStream, initialData: .value)` → `ChangeNotifierProvider(create: OnboardingViewModel(..)..loadOnboarding())` + `_OnboardingOverlayConnector` + `_requestNotificationPermission` gọi `notificationService.requestPermission()` THẬT → `viewModel.onNotificationPermissionResult(granted)` + catch→reportError+result(false) (STRICT 3-builder-chain — M18-đơn-giản-hoá chỉ-Stream = BEHIND; `context.read` + `identical`-guard);
  - `onboarding_game_button.dart` — leaf dùng-chung (Bài-04 re-port).
- `lib/core/menu_tokens.dart` — **ĐÃ XOÁ** (STRICT: `grep -rn "MenuTokens\|menu_tokens" lib/` → TRỐNG trước-xoá; file-còn = retire-incomplete; import-sót = compile-đỏ).
- `test/widgets/` `onboarding_overlay_test.dart` 6 + `onboarding_overlay_scope_test.dart` 5 + `test/onboarding_app_test.dart` 3 + `onboarding_view_model_test.dart` 12 (net +14 retire learner-predecessors).
- `flutter analyze` sạch; `flutter test` → **383/383** (STRICT 369 + 14).
- KHÔNG ĐƯỢC có (chưa đến): previews/`@Preview`/`lib/previews/` (BÀI 07); `main.dart`/`app_dependency_scope`/`app_navigation_controller` verbatim-final (BÀI 07 — có-thể-khác-literal còn); `docs/release-kit-walkthrough.md` (BÀI 07); 7-test-file-senior (`widget_test`/`apple_auth`/`surface_glow`/`dialog_shell_header`/`pill_button_glow`/`leaderboard_async`) (BÀI 07); `MenuTokens` (XOÁ-ngay — không-phải-chưa-đến); `MenuDialogBackdrop`-dùng-trong-onboarding (onboarding haze RIÊNG — KHÔNG-tái-dùng-backdrop-menu).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- Bài 05: `MenuDialogState`-5-variant/layer/backdrop/view-Stack-`Positioned.fill(OnboardingOverlayScope)`-slot-đã-có/zero-`showDialog`/lock/2-event → 369; Bài 04: menu-surface; Bài 02: `headerSheen`-token-dùng-lại; Bài 01: `OnboardingTokens` (nay-được-consume-đầy-đủ) + `AppAssets.icon*`; M18 `OnboardingViewModel`/`OnboardingStepType`/`OnboardingStepState`-3-variant/`completedStream`/skip-API (VM-KHÔNG-đổi — chỉ visual+scope); M27 `LocalNotificationService.requestPermission`-contract (scope-gọi-service-không-plugin-trực-tiếp); `AppTokens.motionMedium/dialogHaze*`-token-nguồn-duy-nhất (MenuTokens-gone → AppTokens+OnboardingTokens hai-nguồn-chính-thức).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. `menu_tokens.dart` còn/`MenuTokens`-import-sót = NEEDS_FIX; scope-thiếu-FutureBuilder-gate = BEHIND-M18-đơn-giản; tap-ngoài-dismiss-onboarding = DIVERGED (senior-nuốt); `_SkipIntroLink` hiện-ở-ready = DIVERGED; `AnimatedContainer` đổi-height/scale = DIVERGED; `onboardingQuestionCount` hardcode = DIVERGED.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m29/06
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
