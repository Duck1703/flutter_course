---
title: "Bài 4 · Overlay scope + overlay UI + Stack trong menu"
description: "Cổng 'chỉ hiện lần đầu': FutureBuilder gate trên loadOnboardingCompleted + ChangeNotifierProvider overlay-scoped; overlay UI (scrim, tap absorber, card, indicator, per-step actions); menu bọc Stack + Positioned.fill; promote LanguageChipRow shared. Checkpoint: analyze clean + 97/97."
sidebar:
  label: "Bài 4 · scope + menu Stack"
  order: 4
---

## Mục tiêu

- Dựng `OnboardingOverlayScope` — cổng FutureBuilder + chủ của
  overlay-scoped VM (tầng lifetime thứ tư).
- Dựng `OnboardingOverlay` — scrim + opaque absorber + card 3 bước
  + indicator + actions.
- Bọc `Stack` quanh body của `menu_screen.dart` — senior host
  pattern `Positioned.fill`.
- Promote `_LanguageChipRow` → `widgets/common/language_chip_row.dart`
  (senior file layout — settings + onboarding cùng dùng).

## Bạn đang ở đâu

- Bài 2: step data + ARB keys + content data.
- Bài 3: `OnboardingViewModel` senior-identical + 7 test xanh.
- Bài này nối VM vào cây: scope gating + overlay render + menu host.
  Cuối bài onboarding *hiện thật* trên app.

## Vì sao việc này quan trọng ngay bây giờ

VM có rồi — nhưng "cổng" quyết định *khi nào overlay được phép tồn
tại* chưa có. Phần khó nhất không phải vẽ card; là **không lé overlay
ra trước khi đọc xong cờ persist**: `BehaviorSubject` seed `false` —
render ngay thì frame đầu chớp onboarding trên máy đã xem rồi. Gate
đúng = UX "chỉ lần đầu" thật sự chỉ hiện lần đầu.

## Bạn đã biết gì

- `didChangeDependencies` + `context.read` + `identical()` guard —
  "lấy dependency đúng một lần" (M14).
- `FutureBuilder` (M05); `ChangeNotifierProvider(create:)` (M12/M16).
- `Stack`/`Positioned.fill`/`HitTestBehavior.opaque` (Bài 1).
- `switch` expression + object pattern `:final f` trên sealed (M15).
- `AppLocalizations.of(context)` (M17).

## Dart cần dùng

- Cascade `..loadOnboarding()` trên kết quả `create:` — tạo xong gọi
  load trong cùng expression.
- `unawaited(...)` bọc call async trong callback sync — nói rõ "cố ý
  không chờ".
- `snapshot.data ?? repo.stream.value` — fallback sang giá trị
  seeded khi Future chưa trả.

## Flutter cần dùng

- `FutureBuilder<bool>` — chờ persist read trước khi quyết hiện.
- `ChangeNotifierProvider<OnboardingViewModel>` — VM sinh/chết cùng
  subtree overlay — scope = lifetime như M16/03.
- `SingleChildScrollView` + `ConstrainedBox(minHeight: maxHeight)` —
  card căn giữa mà vẫn cuộn khi màn thấp.
- `FilledButton`/`TextButton` — learner dùng nút material thay
  `OnboardingGameButton`.

## Mental model mới

Không mới — bài này *áp dụng* gate FutureBuilder (Bài 1) + overlay-scope (Bài 3) vào cây
thật. Câu chốt: **FutureBuilder chặn "chưa đọc xong", VM + stream
sub chặn "đã xong"** — hai lớp cho hai mốc thời gian khác nhau.

## Ví dụ độc lập

Không cần ví dụ riêng — scope mini chính là ví dụ (dưới Bước 2);
phần mới thật sự là wiring, đã trình bày nguyên khối.

## Android / Compose bridge

- **SIMILARITY**: scope ≈ `LaunchedEffect(repo.loadCompleted())` +
  `if (loaded && !done) { Overlay() }`; provider-in-overlay ≈ nested
  `viewModel()` scoped theo composition.
- **DIFFERENCE**: không dialog/route/window — một widget trong
  `Stack`; "đóng" = steps cạn (state), không `dismiss()`.
- **DO NOT ASSUME**: `Positioned.fill` = `match_parent` + z-order —
  nó chỉ là "con chiếm hết Stack"; hiển thị vẫn do bạn render nó.

## Senior project connection

- Senior `onboarding_overlay_scope.dart`: giống hệt, *cộng thêm* một
  `StreamBuilder` lồng trong `FutureBuilder` + `_requestNotificationPermission`
  gọi `LocalNotificationService` thật. Learner bỏ lớp StreamBuilder
  (VM đã tự subscribe) và mô phỏng grant (M27).
- Senior `onboarding_overlay.dart`: `BackdropFilter` blur +
  `AnimatedSwitcher` + `OnboardingTokens` gradient/badge +
  `OnboardingGameButton` — learner giữ scrim + opaque absorber +
  card cuộn + indicator tĩnh + nút Material.
- Senior `lib/widgets/common/language_chip_row.dart`: file shared
  settings/onboarding — learner promote đúng vị trí đó.
- Senior `menu_screen_view.dart:95`: `Positioned.fill(child:
  OnboardingOverlayScope())` — learner `menu_screen.dart` giờ giống
  hệt về cấu trúc.

## Build it step by step

### Bước 1 — promote `LanguageChipRow` lên `widgets/common/`

Bước welcome cần hàng chip ngôn ngữ — đã tồn tại dưới tên private
`_LanguageChipRow` trong `settings_dialog.dart` (M16). Senior đặt
widget này ở `lib/widgets/common/language_chip_row.dart`:

1. Tạo `lib/widgets/common/language_chip_row.dart` — class
   `LanguageChipRow` public, thân chip y hệt `_LanguageChipRow`
   (đối chiếu file production).
2. `settings_dialog.dart`: thêm `import
   '../../common/language_chip_row.dart';`; đổi `_LanguageChipRow(`
   → `LanguageChipRow(`; **xóa** nguyên class `_LanguageChipRow` cuối
   file; xóa import `supported_language_data.dart` (giờ thừa).
3. `flutter analyze` sạch; `flutter test` vẫn 97/97 — refactor thuần,
   không đổi behavior.

### Bước 2 — `lib/widgets/onboarding/onboarding_overlay_scope.dart`

> **Lưu ý trạng thái trung gian**: file này import
> `onboarding_overlay.dart` — tạo ở Bước 3. `flutter analyze` giữa
> hai bước sẽ báo thiếu file — đó là điều bình thường, compile sạch
> lại sau Bước 3.

Scope = cổng + chủ VM (đúng shape senior, rút gọn đã register):

```dart
class _OnboardingOverlayScopeState extends State<OnboardingOverlayScope> {
  OnboardingRepository? _repository;
  Future<bool>? _completionFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final repository = context.read<OnboardingRepository>();
    if (identical(_repository, repository)) {
      return;
    }

    _repository = repository;
    _completionFuture = repository.loadOnboardingCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final repository = _repository;
    final completionFuture = _completionFuture;

    if (repository == null || completionFuture == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<bool>(
      future: completionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        if (snapshot.data ?? repository.onboardingCompletedStream.value) {
          return const SizedBox.shrink();
        }

        return ChangeNotifierProvider<OnboardingViewModel>(
          create: (_) => OnboardingViewModel(
            onboardingRepository: repository,
            settingsRepository: context.read<UserSettingsRepository>(),
          )..loadOnboarding(),
          child: const _OnboardingOverlayConnector(),
        );
      },
    );
  }
}
```

`_OnboardingOverlayConnector` = `context.watch<OnboardingViewModel>()`
→ `OnboardingOverlay(step: vm.currentStep, …)` — callback map thẳng
vào VM (`unawaited` cho async). Điểm khác senior tại đây:
`onEnableNotifications` gọi `viewModel.onNotificationPermissionResult(true)`
— *mô phỏng* granted; permission thật qua `LocalNotificationService`
→ M27.

### Bước 3 — `lib/widgets/onboarding/onboarding_overlay.dart`

UI rút gọn senior: scrim `ColoredBox` đen 70% +
`GestureDetector opaque` hút tap + card giữa màn (cuộn được) +
3 chấm `stepOrder` + `switch (step)` chọn actions. Đọc file
production — ba cụm xương sống:

```dart
// Lớp nền: nuốt mọi tap — overlay "chặn" menu mà không cần route.
return GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap: () {},
  child: ColoredBox(color: Colors.black.withValues(alpha: 0.7), …
```

```dart
// Indicator tĩnh — duyệt stepOrder, sáng chấm của step.type.
for (final stepType in OnboardingStepState.stepOrder) ...[
  Container(…color: stepType == currentStepType ? accentYellow : track…),
  if (stepType != OnboardingStepState.stepOrder.last) SizedBox(width: …),
]
```

```dart
// Actions theo variant — object pattern bóc field đúng chỗ (M15):
switch (step) {
  OnboardingWelcomeStep(:final selectedLanguageCode) => _WelcomeActions(
    selectedLanguageCode: selectedLanguageCode,
    onLanguageSelected: onLanguageSelected,   // → vm.selectLanguage
    onNextStep: onNextStep, l10n: l10n),
  OnboardingNotificationStep s => _NotificationActions(step: s, …),
  OnboardingReadyStep() => _ReadyActions(onFinish: onFinish, …),
}
```

- `_WelcomeActions`: `LanguageChipRow` (shared, Bước 1) +
  `FilledButton` `l10n.nextButton`.
- `_NotificationActions`: preview giờ (`step.formattedTime` +
  `onboardingNotificationTimeLabel/Hint`); `isEnabled` → `Tiếp tục`;
  chưa → `Bật thông báo` + `Để sau`.
- `_ReadyActions`: 3 fact chip (`onboardingQuestionCount`,
  `onboardingLifelineCount`, `'↑'`/ladder) + `getStartedButton`.
- Cuối card: `TextButton` `onboardingSkipIntroButton` luôn có mặt.

### Bước 4 — menu bọc `Stack`

`menu_screen.dart` — `body` giữ gradient + SafeArea + ConstrainedBox,
đổi `child: Column(…)` thành:

```dart
child: Stack(
  children: [
    Column( /* …_ProfileHeader / _MenuBody / _PlayButton y nguyên… */ ),
    const Positioned.fill(child: OnboardingOverlayScope()),
  ],
),
```

+ `import '../widgets/onboarding/onboarding_overlay_scope.dart';`

### Bước 5 — 3 test host menu phải "đã xem onboarding"

Test cũ pump `MenuScreen` với repo thật trên prefs mock `{}` — giờ
overlay hiện và **hút mọi tap** xuống nút bên dưới. Đúng hiện thực
"menu ở trạng thái post-onboarding", thêm cờ vào 4 điểm:

```dart
// menu_screen_ui_events_test.dart (1 chỗ), menu_provider_scope_test.dart
// (2 chỗ), game_screen_test.dart (1 chỗ):
SharedPreferences.setMockInitialValues(
  const {'onboarding_completed': true},
);
```

## Hiểu code

- `snapshot.data ?? repository.onboardingCompletedStream.value`:
  Future xong rồi thì tin `data`; nếu hi hữu null, fallback đúng giá
  trị hiện tại của stream — không để cờ "giả".
- Scope `return const SizedBox.shrink()` ba lần: chưa có repo, chưa
  done, đã complete — "không render" là tài nguyên rẻ nhất.
- `ChangeNotifierProvider` nằm *trong* builder — VM chỉ tồn tại khi
  overlay tồn tại: đó là nghĩa của overlay-scoped (dispose tự động
  khi subtree rời cây → sub cancel → không leak).

## Chạy và quan sát

```powershell
flutter analyze   # sạch (sau Bước 3)
flutter test      # 97/97 — overlay chưa có test riêng (Bài 5)
```

Chạy app thật (xóa prefs / `flutter run` lần đầu): overlay welcome
hiện trên menu; tap quanh card bị nuốt; chọn "English" → toàn app
đổi ngôn ngữ ngay (dây chuyền M17).

## Thử nghiệm

Trong scope, tạm đổi `if (snapshot.data ?? …)` thành chỉ
`if (snapshot.data ?? false)` rồi pump test host `initiallyCompleted:
true` — overlay vẫn ẩn đúng vì `snapshot.data == true`. Giờ
thử chiều ngược: persist `đang ghi` mà UI phải theo —
`?? stream.value` là đai an toàn cho khoảnh khắc Future chưa
trả; stream sub trong VM lo phần clear sau đó.

## Lỗi hay gặp

- `loadOnboardingCompleted()` gọi trong `build` → gọi lại mỗi frame —
  phải cache Future trong `State` (senior: `didChangeDependencies` +
  identical-guard).
- Bỏ FutureBuilder gate → seeded `false` của subject đọc trước persist
  → overlay chớp một frame trên máy đã xem.
- Đặt scope trên Provider repo (ngoài `MaterialApp`/trên
  `AppDependencyScope`) → `context.read<OnboardingRepository>` throw.
- Quên cập nhật test hosts → overlay hút tap, test menu hỏng lặng.

## Tự làm — dự đoán trước khi chạy (PREDICT + VERIFY)

**Đề bài.** Trong `onboarding_overlay_test` host, đổi fake thành
`initiallyCompleted: true` và *dự đoán bằng văn bản* trước khi chạy:
overlay hiện frame đầu rồi mất, hay không bao giờ hiện? Chạy test
"đã complete từ trước" của Bài 5 để kiểm chứng.

:::note[Gợi ý]

Future xuất phát từ `loadOnboardingCompleted()` — câu hỏi thật sự:
"có frame nào render subtree trước khi Future done không?" —
`connectionState != done → SizedBox.shrink()` trả lời.
:::

<details><summary>Đáp án</summary>

Không bao giờ hiện: `FutureBuilder` trả `SizedBox.shrink()` cho đến
khi `done`; khi done, `snapshot.data == true` → `SizedBox.shrink()`
tiếp. Subtree chứa Provider + overlay không hề được tạo — đó là
"gate" đúng nghĩa, không phải "hiện rồi ẩn".
</details>

## Kiểm tra hiểu biết

1. Hai lớp gate ("chưa đọc xong" vs "đã xong") do ai đảm nhiệm?
2. Tại sao scope phải nằm *dưới* `AppDependencyScope`?
3. `onEnableNotifications` hiện làm gì — phần senior thiếu ở đâu?
4. Vì sao promote `LanguageChipRow` thay vì copy thêm một bản?

## Ta cố ý chưa thêm

- `BackdropFilter`/`AnimatedSwitcher`/badge/`OnboardingGameButton`
  (visual parity đến M28).
- `LocalNotificationService` permission thật (M27).
- `OnboardingHeaderConfig` color/badge per step — learner chỉ
  title/desc.
- Replay sau reset-profile — senior cũng không liên kết hai cờ.

## Checkpoint hoàn thành

`flutter analyze` sạch; `flutter test` **97/97**; chạy app thật →
overlay hiện, tap bị chặn, language chips đổi locale. Sang
[Bài 5](/m18/05-hoan-thien-tests-tu-lam/) — widget test + regression.
