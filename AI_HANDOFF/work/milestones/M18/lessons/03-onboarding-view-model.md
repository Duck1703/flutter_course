---
title: "Bài 3 · OnboardingViewModel — list bước như queue"
description: "VM của overlay — senior-identical: List<OnboardingStepState> là queue, currentStep = first, advance = removeAt(0), cạn list → persist. listEquals + List.unmodifiable giữ kỷ luật notify; stream sub tự clear; guarded async chặn double-save. Checkpoint: 7/7 VM test + 97/97 toàn bộ."
sidebar:
  label: "Bài 3 · OnboardingViewModel"
  order: 3
---

## Mục tiêu

- Đọc-trong-giấc `OnboardingViewModel`: state là **queue các bước
  còn lại**, không phải index hay enum.
- Dùng được `listEquals` + `List.unmodifiable` — emit discipline cho
  state dạng list.
- Hiểu hai guard: `_languageSelectionInProgress` (async re-entrancy)
  và `_isDisposed` (sau dispose).
- Viết unit test VM với fake repos — không pump widget.

## Bạn đang ở đâu

- Bài 2: sealed `OnboardingStepState` + ARB keys + content data đã
  có — VM bài này là *consumer đầu tiên* của chúng.
- VM là file **senior-identical** thứ hai của khóa (sau step data) —
  đọc kỹ hơn là gõ lại.

## Vì sao việc này quan trọng ngay bây giờ

Onboarding cần "bước hiện tại + đi tiếp + bỏ qua + kết thúc" — và tự
ẩn khi cờ `onboarding_completed` bật từ *bất kỳ* đâu (kể cả ngoài
VM). Counter/enum sẽ rối ngay: làm sao welcome *nhớ* ngôn ngữ đã
chọn? "Hết bước" persist thế nào? Senior giải bằng một ý tưởng gọn:
**list các bước còn lại là state**.

## Bạn đã biết gì

- `ChangeNotifier` + `notifyListeners` (M11); kỷ luật "chỉ notify
  khi đổi thật" (`value !=` guards M14).
- `StreamSubscription` + cancel trong `dispose` (M13/M14); repo
  `ValueStream` seeded (M14).
- `late final` gán trong thân ctor (D-30, M16); sealed family + object
  pattern (M15).
- `UserSettingsRepository.userSettingsStream.value` + `copyWith(
  languageCode:)` (M16–M17).

## Dart cần dùng

- `listEquals` (`flutter/foundation`) — so list *theo phần tử*; `==`
  mặc định của `List` so reference — khác nhau hoàn toàn (D-32).
- `List.unmodifiable(list)` — emit bản read-only: caller không
  `.add()` được vào state đã phát.
- `List.of(x)..removeAt(0)` — copy rồi consume; cascade `..` (D-18).
- `is! Variant` guard — "chỉ chạy khi đang ở đúng bước".

## Flutter cần dùng

- `ChangeNotifier` + `ChangeNotifierProvider` (provider ở Bài 4 — VM
  không tự biết ai chứa nó; đó là scope).
- `FlutterError.reportError` — báo lỗi async mà không crash (giống
  style senior; `try/catch` + error object ra UI qua
  `completionError`).

## Mental model mới — "steps = queue"

> `_steps` là `List<OnboardingStepState>` — `currentStep =
> _steps.first`; `nextStep`/`skipStep` đều là `removeAt(0)`; cạn
> list → `await _completeOnboarding()` → persist. Mọi biến thể bước
> nằm trong *data* (field của variant), không trong control-flow.

Ba guard quan trọng, mỗi cái trả lời một "chuyện xấu gì nếu thiếu":
- `listEquals` → notify thừa (rebuild không cần thiết).
- `_languageSelectionInProgress` → double-tap chip → hai save lồng
  nhau, race thứ tự.
- `_isDisposed` → `await` trễ về sau `dispose` → set-state trên VM
  chết = `FlutterError`.

## Ví dụ độc lập — queue mini

```dart
class _QueueVm extends ChangeNotifier {
  List<String> _steps = const ['a', 'b', 'c'];
  String? get current => _steps.isEmpty ? null : _steps.first;

  void next() {
    if (_steps.isEmpty) return;
    final remaining = List<String>.of(_steps)..removeAt(0);
    if (listEquals(_steps, remaining)) return;   // không đổi → thôi
    _steps = List.unmodifiable(remaining);       // emit bản mới
    notifyListeners();
  }
}
```

Đó là toàn bộ xương sống — VM thật thêm persist + stream sub +
error surface + seeding.

## Android / Compose bridge

- **SIMILARITY**: queue-of-steps ≈ `MutableStateFlow<List<Step>>` +
  `drop(1)`; `listEquals` ≈ data-class equality guard trước
  `state.value = …`.
- **DIFFERENCE**: `_completedSubscription` subscribe repo stream
  *ngay trong ctor* — VM không đợi ai gọi; Compose tương đương
  `viewModelScope.launch { repo.completed.collect { clear() } }`.
- **DO NOT ASSUME**: "bước tiếp theo" = index++. Đây là queue
  consume — variant còn lại quyết định UI tiếp.

## Senior project connection

`lib/view_models/onboarding/onboarding_view_model.dart` (senior) —
learner copy verbatim (chỉ đổi package import + doc comment). Đây là
lần đầu một file VM không cần rút gọn nào: mọi guard đều có lý do
senior, và bài này là nơi đọc hiểu chúng.

## Build it step by step

### Bước 1 — tạo `lib/view_models/onboarding/onboarding_view_model.dart`

Copy file production (senior-identical). Khi đọc, đặt mắt vào:

```dart
class OnboardingViewModel extends ChangeNotifier {
  final OnboardingRepository _repository;
  final UserSettingsRepository _settingsRepository;
  late final StreamSubscription<bool> _completedSubscription;
  List<OnboardingStepState> _steps = const [];
  Object? _completionError;
  var _isDisposed = false;
  var _languageSelectionInProgress = false;
```

- `late final _completedSubscription` — gán trong ctor private `._`
  vì cần `_repository` sẵn (D-30).
- `loadOnboarding`: `await loadOnboardingCompleted()` → `_isDisposed`
  check → `_setSteps(completed ? const [] : _initialSteps())`.
- `_initialSteps()` seed từ `userSettingsStream.value`: welcome mang
  `languageCode` hiện tại, notification mang `notificationHour/
  Minute` đã lưu — **persisted settings lái luôn nội dung onboarding**.
- `_advanceStep`: `removeAt(0)` trên bản copy; cạn →
  `await _completeOnboarding()` trước khi set rỗng.
- `selectLanguage`: guard `current is! OnboardingWelcomeStep ||
  _languageSelectionInProgress` → `saveUserSettings(copyWith
  (languageCode:))` → `_replaceCurrentStep(Welcome(selected: code))`
  — chip sáng ngay vì state bước mang lựa chọn.
- `onNotificationPermissionResult(granted)`: chỉ chạy ở notification
  step; `true` → `copyWith(isEnabled:true)` + advance; `false` → ở
  lại `isEnabled:false` (user từ chối → vẫn cho qua bằng "Để sau").
- `skipIntro`: persist + `_setSteps(const [])` — ẩn ngay.
- `_handleCompletionChanged`: stream bật `true` từ nguồn khác →
  clear — VM tự dọn mình khỏi màn.
- `dispose`: `_isDisposed = true` + `_completedSubscription.cancel()`
  + `super.dispose()`.

### Bước 2 — `test/onboarding_view_model_test.dart` (7 case)

Fake repos đã có từ M14 (`test/helpers/`). Tạo file test — cụm đầu:

```dart
import 'package:ai_millionaire_course/data/onboarding/onboarding_step_data.dart';
import 'package:ai_millionaire_course/data/settings/supported_language_data.dart';
import 'package:ai_millionaire_course/data/settings/user_settings_data.dart';
import 'package:ai_millionaire_course/view_models/onboarding/onboarding_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_onboarding_repository.dart';
import 'helpers/fake_user_settings_repository.dart';

void main() {
  group('OnboardingViewModel (M18)', () {
    test('load: chưa complete → seed 3 bước từ settings', () async {
      final onboardingRepo = FakeOnboardingRepository();
      final settingsRepo = FakeUserSettingsRepository(
        initialSettings: const UserSettingsData(
          languageCode: 'vi',
          notificationHour: 9,
          notificationMinute: 30,
        ),
      );
      final vm = OnboardingViewModel(
        onboardingRepository: onboardingRepo,
        settingsRepository: settingsRepo,
      );

      await vm.loadOnboarding();

      expect(vm.isVisible, isTrue);
      expect(vm.currentStep, isA<OnboardingWelcomeStep>());
      expect(
        (vm.currentStep as OnboardingWelcomeStep).selectedLanguageCode,
        'vi',
      );

      await vm.nextStep();
      final notification = vm.currentStep as OnboardingNotificationStep;
      expect(notification.hour, 9);
      expect(notification.minute, 30);
      vm.dispose();
    });
```

…copy nguyên file production cho 6 case còn lại: `load` khi đã
complete (steps rỗng), `nextStep` qua 3 bước → `setCallCount==1`,
`skipIntro` persist + ẩn, `selectLanguage` ghi `languageCode` + cập
nhật welcome step, `onNotificationPermissionResult` cả hai nhánh,
`setOnboardingCompleted` từ ngoài → steps tự clear.

## Hiểu code

- `_advanceStep` persist *trước* `_setSteps(remaining)` khi cạn: nếu
  save fail (`_completeOnboarding` return false), bước cuối *vẫn
  hiện* — không "ăn" bước khi chưa persist được.
- `_setCompletionError` notify riêng → UI có thể hiện lỗi mà không
  đụng steps.
- `_replaceCurrentStep` check `_steps.first == step` trước — no-op
  nếu "đổi" thành giá trị cũ (equality việc của Bài 2 trả nợ ở đây).

## Chạy và quan sát

```powershell
flutter analyze                              # sạch
flutter test test/onboarding_view_model_test.dart   # 7/7
flutter test                                 # 97/97
```

## Thử nghiệm

Trong test "seed 3 bước", đổi `initialSettings` thành
`notificationHour: 21, notificationMinute: 45` rồi chạy lại — assertion
`hour: 9` phải **đỏ**; sửa assert thành 21/45 → xanh. Đây là cách
kiểm chứng seeding thật sự chạy qua `userSettingsStream.value`.

## Lỗi hay gặp

- Quên `List.unmodifiable` → caller `.add()` vào list đã emit →
  state bẩn không qua notify.
- `selectLanguage` thiếu `_languageSelectionInProgress` → double-tap
  chip lưu hai lần.
- Thiếu `_isDisposed` check sau `await` → notify trên VM đã dispose
  = `FlutterError` trong test ("A ChangeNotifier was used after
  being disposed").
- `await` trong vòng test mà không `vm.dispose()` → leak subject —
  mọi test đều `dispose()` cuối.

## Tự làm — gỡ guard re-entrancy (DEBUG)

**Đề bài.** Trên bản copy của VM (không sửa production — hoặc sửa
rồi revert), xóa guard `_languageSelectionInProgress` + khối
`finally`. Viết test gọi `vm.selectLanguage(en)` và
`vm.selectLanguage(vi)` **liền nhau không await**. Sau đó khôi phục
guard.

:::note[Gợi ý]

- Không có guard: cả hai call đều qua `saveUserSettings` →
  `saveCallCount == 2`, và thứ tự hoàn tất phụ thuộc timing.
- Với guard: call thứ hai return sớm vì flag vẫn `true` trong khi
  call đầu còn `await` → `saveCallCount == 1`.
- Câu hỏi kèm: tại sao flag đặt `true` *trước* `await` chứ không
  sau? (Sau `await` thì call thứ hai đã lọt qua rồi.)

:::

<details><summary>Đáp án</summary>

```dart
// đầu file test cần: import 'dart:async';  (cho `unawaited`)
test('double selectLanguage không await → chỉ một save', () async {
  final settingsRepo = FakeUserSettingsRepository();
  final vm = OnboardingViewModel(
    onboardingRepository: FakeOnboardingRepository(),
    settingsRepository: settingsRepo,
  );
  await vm.loadOnboarding();

  unawaited(vm.selectLanguage(SupportedLanguageData.english));
  unawaited(vm.selectLanguage(SupportedLanguageData.vietnamese));
  await Future<void>.delayed(Duration.zero);

  expect(settingsRepo.saveCallCount, 1);
  vm.dispose();
});
```

Khi đã gỡ guard: test này **đỏ** (`saveCallCount == 2`) — bằng chứng
guard làm việc. Revert guard → xanh lại.
</details>

## Kiểm tra hiểu biết

1. `currentStep` lấy từ đâu — vì sao không phải index?
2. `listEquals` khác `==` của List ở điểm nào?
3. `_handleCompletionChanged` xử lý tình huống gì — ai có thể bật
   cờ ngoài VM?
4. Vì sao `_advanceStep` persist *trước* khi set list rỗng?

## Ta cố ý chưa thêm

- `LocalNotificationService` — nút "Bật thông báo" *mô phỏng* grant
  ở scope (Bài 4); permission thật + lịch hẹn → M27 (FR-27).
- `OnboardingUiEvent`/navigation side-channel — senior không có:
  hoàn thành = steps cạn, UI tự ẩn.
- Reducer/`onboarding_phase` machine — đó là phong cách M19 cho
  game; step queue ở đây đủ và đúng senior.

## Checkpoint hoàn thành

`flutter analyze` sạch; `test/onboarding_view_model_test.dart` 7/7;
`flutter test` **97/97**. Sang [Bài 4](/m18/04-overlay-scope-va-menu-stack/)
— scope + overlay + `Stack` trong menu.
