---
title: "Bài 2 · Step state — sealed family + chuỗi ARB onboarding"
description: "Tạo sealed OnboardingStepState (senior-identical), thêm 16 key ARB onboarding senior-verbatim (+ đổi tên key game tránh va chạm), chạy gen-l10n, viết content data file. Checkpoint: gen-l10n exit 0 + analyze clean + 90/90."
sidebar:
  label: "Bài 2 · step state + ARB"
  order: 2
---

## Mục tiêu

- Tạo `lib/data/onboarding/onboarding_step_data.dart` — sealed family
  3 variant **senior-identical**.
- Thêm 16 key onboarding vào cả hai ARB; hiểu vì sao `nextButton`
  cũ đổi tên thành `gameNextButton`.
- Tạo `onboarding_content_data.dart` — title/desc per step qua l10n +
  hai hằng số đọc từ bank thật.

## Bạn đang ở đâu

- Bài 1: mental model overlay — giờ xây *data layer* của nó.
- M15 đã có sealed `GameDialogState`; bài này áp lại đúng kỹ thuật
  cho step model. M17 đã có pipeline ARB/gen-l10n — bài này chỉ thêm
  key.
- Cuối bài: data + chuỗi sẵn sàng; Bài 3 mới có VM dùng chúng.

## Vì sao việc này quan trọng ngay bây giờ

Ba bước mang dữ liệu khác nhau: welcome cần `selectedLanguageCode`,
notification cần `isEnabled`/`hour`/`minute`, ready không cần gì.
Một `enum` thuần chỉ mô tả *loại* bước — không chứa data. Đây lại là
bài toán của `sealed class`: tập variant đóng, mỗi variant mang field
riêng, `switch` kiệt hợp bắt buộc xử lý hết.

## Bạn đã biết gì

- `sealed class`/`final class`/`switch` kiệt hợp + object pattern
  (M15), `copyWith`, `==`/`hashCode` theo giá trị (M04).
- `.arb` + `@key` + `''` escaping + `flutter gen-l10n` (M17, D-31).
- `padLeft(2,'0')` format giờ (D-29, M16).

## Dart cần dùng

- `sealed class` + `static const stepOrder` — thứ tự bước cho
  indicator sau này.
- `copyWith` chỉ đổi field cần đổi (`isEnabled`).
- `Object.hash(type, field…)` cho `hashCode` multi-field.

## Flutter cần dùng

- Không có API widget mới — bài này thuần data + resource.
- `flutter gen-l10n` regenerate `AppLocalizations`.

## Ví dụ độc lập

Không cần — `OnboardingStepState` chính là ví dụ mẫu của sealed
family đã học ở M15; bài này là *áp dụng*, không phải concept mới.

## Android / Compose bridge

- `stepOrder` ≈ `listOf(Step.Welcome, …)` — sealed class Kotlin có
  danh sách cố định tương tự cho stepper.
- "content data file tách chuỗi khỏi widget" ≈ `strings.xml` +
  `stringResource()` — nhưng ARB type-safe hơn nhờ codegen.
- `when (step)` exhaustive trên sealed class Compose ↔ `switch`
  kiệt hợp Dart — cùng lỗi-biên-dịch-khi-thiếu-arm.

## Senior project connection

- `lib/data/onboarding/onboarding_step_data.dart` (senior) — learner
  copy **y nguyên** (đây là file đầu tiên trong khóa không cần rút
  gọn: thiết kế đã đủ gọn cho người mới).
- `onboarding_content_data.dart` (senior) trả `OnboardingHeaderConfig`
  (title + màu + gradient + badge asset). Learner chỉ trả chuỗi —
  header/badge visual là FR-32 (→ M28).
- `onboardingQuestionCount` senior đọc từ `gameSampleQuestions`;
  learner đọc `quizQuestions` — cùng nguyên tắc "đếm từ bank thật".

## Build it step by step

### Bước 1 — `lib/data/onboarding/onboarding_step_data.dart`

Tạo file, copy **y nguyên** từ production (senior-identical). Cụm
xương sống:

```dart
import 'package:flutter/foundation.dart';

enum OnboardingStepType { welcome, notification, ready }

@immutable
sealed class OnboardingStepState {
  const OnboardingStepState();

  OnboardingStepType get type;

  static const stepOrder = [
    OnboardingStepType.welcome,
    OnboardingStepType.notification,
    OnboardingStepType.ready,
  ];
}

final class OnboardingWelcomeStep extends OnboardingStepState {
  final String? selectedLanguageCode;

  const OnboardingWelcomeStep({this.selectedLanguageCode});

  @override
  OnboardingStepType get type => OnboardingStepType.welcome;

  OnboardingWelcomeStep copyWith({String? selectedLanguageCode}) {
    return OnboardingWelcomeStep(
      selectedLanguageCode: selectedLanguageCode ?? this.selectedLanguageCode,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OnboardingWelcomeStep &&
        other.selectedLanguageCode == selectedLanguageCode;
  }

  @override
  int get hashCode => Object.hash(type, selectedLanguageCode);
}
```

Hai variant còn lại — `OnboardingNotificationStep`
(`isEnabled`/`hour`/`minute` + `formattedTime` dùng `padLeft` +
`copyWith(isEnabled)`) và `OnboardingReadyStep` (không field) — copy
nguyên file production `lib/data/onboarding/
onboarding_step_data.dart`. `==`/`hashCode` theo giá trị là *bắt
buộc*: VM ở Bài 3 dùng `listEquals` để quyết notify hay không —
thiếu equality, mọi emit đều "khác".

### Bước 2 — 16 key ARB onboarding (senior-verbatim)

Thêm vào `lib/l10n/app_en.arb` (giá trị en của senior):

```json
  "nextButton": "Next",
  "enableNotificationsButton": "Enable Notifications",
  "getStartedButton": "Get Started",
  "maybeLaterButton": "Maybe Later",
  "onboardingWelcomeTitle": "Welcome to AI Quiz!",
  "onboardingWelcomeDescription": "Test your knowledge with AI questions, earn rewards, and climb the leaderboard. Pick a language to begin.",
  "onboardingNotificationTitle": "Your Daily Reminder",
  "onboardingNotificationDescription": "One reminder a day so you never miss a round. No spam — change the time or turn it off anytime.",
  "onboardingNotificationTimeLabel": "Daily reminder time",
  "onboardingNotificationTimeHint": "Change it in Settings",
  "onboardingReadyTitle": "You''re All Set!",
  "onboardingReadyDescription": "Your first round is waiting. Good luck!",
  "onboardingReadyQuestionsLabel": "questions",
  "onboardingReadyLifelinesLabel": "lifelines",
  "onboardingReadyLadderLabel": "prize ladder",
  "onboardingSkipIntroButton": "Skip intro",
```

`app_vi.arb` tương ứng (giá trị vi của senior): `nextButton: "Tiếp
tục"`, `enableNotificationsButton: "Bật thông báo"`,
`getStartedButton: "Bắt đầu"`, `maybeLaterButton: "Để sau"`,
`onboardingWelcomeTitle: "Chào mừng đến AI Quiz!"`,
`onboardingWelcomeDescription: "Kiểm tra kiến thức với câu hỏi AI,
kiếm thưởng và leo bảng xếp hạng. Chọn ngôn ngữ để bắt đầu."`,
`onboardingNotificationTitle: "Nhắc bạn mỗi ngày"`,
`onboardingNotificationDescription: "Một nhắc nhở mỗi ngày để bạn
không bỏ lỡ ván chơi. Không spam, đổi giờ hoặc tắt bất cứ lúc nào."`,
`onboardingNotificationTimeLabel: "Giờ nhắc mỗi ngày"`,
`onboardingNotificationTimeHint: "Đổi trong Cài đặt"`,
`onboardingReadyTitle: "Bạn đã sẵn sàng!"`,
`onboardingReadyDescription: "Ván đầu tiên đang chờ bạn. Chúc may
mắn!"`, `onboardingReadyQuestionsLabel: "câu hỏi"`,
`onboardingReadyLifelinesLabel: "trợ giúp"`,
`onboardingReadyLadderLabel: "thang thưởng"`,
`onboardingSkipIntroButton: "Bỏ qua giới thiệu"`.

### Bước 3 — đổi tên key game tránh va chạm

`nextButton` **đã tồn tại** trong ARB từ M17 với `"NEXT"`/`"TIẾP"`
cho nút chuyển câu của game — trùng tên key senior của onboarding
(`"Next"`/`"Tiếp tục"`). Giải quyết đúng như production:

1. Trong cả hai ARB, **đổi tên** key game cũ `nextButton` →
   `gameNextButton` giữ nguyên giá trị `"NEXT"`/`"TIẾP"`; key
   `nextButton` mới mang giá trị senior ở Bước 2.
2. `lib/screens/game_screen.dart`: đổi `l10n.nextButton` →
   `l10n.gameNextButton` (chỗ nút TIẾP).
3. `flutter analyze` — không còn `nextButton` nào chỉ game.

Nếu quên bước này: game button sẽ hiện "Tiếp tục" thay vì "TIẾP" —
test `find.text('TIẾP')` bắt được ngay ở checkpoint.

### Bước 4 — `flutter gen-l10n`

```powershell
cd learner-app
flutter gen-l10n
```

`AppLocalizations` giờ có `onboardingWelcomeTitle`, `nextButton`,
`gameNextButton`… (64 key mỗi ngôn ngữ).

### Bước 5 — `lib/data/onboarding/onboarding_content_data.dart`

```dart
import '../../l10n/app_localizations.dart';
import '../game/quiz_questions.dart';
import 'onboarding_step_data.dart';

int get onboardingQuestionCount => quizQuestions.length;

/// Help lifelines available in a round: 50:50, audience poll, and AI
/// assistant. Walk away and exit are controls, not lifelines.
const onboardingLifelineCount = 3;

String onboardingTitleFor(OnboardingStepType type, AppLocalizations l10n) {
  return switch (type) {
    OnboardingStepType.welcome => l10n.onboardingWelcomeTitle,
    OnboardingStepType.notification => l10n.onboardingNotificationTitle,
    OnboardingStepType.ready => l10n.onboardingReadyTitle,
  };
}

String onboardingDescriptionFor(
  OnboardingStepType type,
  AppLocalizations l10n,
) {
  return switch (type) {
    OnboardingStepType.welcome => l10n.onboardingWelcomeDescription,
    OnboardingStepType.notification => l10n.onboardingNotificationDescription,
    OnboardingStepType.ready => l10n.onboardingReadyDescription,
  };
}
```

## Hiểu code

- `onboardingQuestionCount` là getter đọc `quizQuestions.length` —
  lời hứa "N câu hỏi" trên bước ready không thể lệch game (senior
  comment: "the onboarding promise cannot drift from the game").
- `switch` expression trên `OnboardingStepType` kiệt hợp — thiếu
  variant là lỗi biên dịch, không phải bug runtime.
- `stepOrder` là `static const` trên *base class* — thứ tự UI
  (indicator) nằm cùng chỗ với định nghĩa tập variant.

## Chạy và quan sát

```powershell
flutter gen-l10n   # exit 0 — lần này AppLocalizations có 64 key
flutter analyze    # sạch
flutter test       # vẫn 90/90 — chưa có consumer mới của data
```

## Thử nghiệm

Đổi `onboardingReadyTitle` trong `app_vi.arb` thành `"Sẵn sàng!"`,
chạy `flutter gen-l10n`, mở `app_localizations_vi.dart` tìm getter —
thấy giá trị mới. Đổi lại sau khi quan sát.

## Lỗi hay gặp

- JSON thiếu dấu phẩy trước key mới → gen-l10n báo parse error —
  đọc kỹ thông báo, thường là `,` cuối entry trước đó.
- `You''re` trong en ARB: `''` là escape của nháy đơn (D-31) — đừng
  "sửa" thành `'` đơn.
- Thêm key chỉ một phía ARB → hai file lệch key-set → getter thiếu
  ở một locale.

## Tự làm — thêm variant thứ 4 (PRODUCE)

**Đề bài.** Thêm `OnboardingCoachmarkStep` vào sealed family + 2 key
ARB (`onboardingCoachmarkTitle` en/vi tự viết) + arm mới trong
`onboardingTitleFor`/`onboardingDescriptionFor`.

Ràng buộc quan trọng:

- **Không** chạm `stepOrder` (indicator đếm nó — thêm vào sẽ hiện 4
  chấm cho flow 3 bước).
- Exercise này chỉ sống trong phạm vi Bài 2: **xóa variant trước khi
  sang Bài 4** — `switch (step)` của overlay kiệt hợp, variant thừa
  sẽ thành lỗi biên dịch (đó cũng là bằng chứng sealed family hoạt
  động).

:::note[Gợi ý]

- Variant không field: `final class OnboardingCoachmarkStep extends
  OnboardingStepState { const …; @override type => coachmark; }` +
  `==`/`hashCode` theo `type` giống `OnboardingReadyStep`.
- Thêm `OnboardingStepType.coachmark` vào enum (nhưng *không* vào
  `stepOrder`).

:::

<details><summary>Đáp án</summary>

```dart
enum OnboardingStepType { welcome, notification, ready, coachmark }

final class OnboardingCoachmarkStep extends OnboardingStepState {
  const OnboardingCoachmarkStep();

  @override
  OnboardingStepType get type => OnboardingStepType.coachmark;

  @override
  bool operator ==(Object other) => other is OnboardingCoachmarkStep;

  @override
  int get hashCode => type.hashCode;
}
```

và arm `OnboardingStepType.coachmark => l10n.onboardingCoachmarkTitle`
trong hai hàm `*For`.
</details>

## Kiểm tra hiểu biết

1. Vì sao `==`/`hashCode` theo giá trị là bắt buộc cho step data?
2. `nextButton` va chạm thế nào và cách giải là gì?
3. `onboardingQuestionCount` đọc từ đâu — vì sao không hardcode?

## Ta cố ý chưa thêm

- `OnboardingHeaderConfig` (màu/gradient/badge per step — FR-32).
- ICU plurals, placeholder `{count}` trong label — senior cũng tách
  số và nhãn thành chip riêng.
- L10n cho quiz-bank / repo error (FR-31 — vẫn literal, có chủ đích).

## Checkpoint hoàn thành

`flutter gen-l10n` exit 0; `flutter analyze` sạch; `flutter test`
**90/90**. Hai file data mới tồn tại; 64 key mỗi ARB; game vẫn hiện
"TIẾP". Sang [Bài 3](/m18/03-onboarding-view-model/) — VM.
