## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m18/02 — "Step state: sealed family + chuỗi ARB onboarding" (2 file data mới + 16 key ARB + rename nextButton→gameNextButton; chưa có consumer — VM ở bài 3).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, chạy `flutter gen-l10n` để "sửa" output, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bài này ADDITIVE: data layer + chuỗi — chưa có ai consume `OnboardingStepState` ngoài content data (VM bài 3, UI bài 4).

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/onboarding/onboarding_step_data.dart` (STRICT senior-identical): `enum OnboardingStepType { welcome, notification, ready }` (STRICT đúng 3 — variant `coachmark` của Tự làm chỉ là tạm, phải xoá trước bài 4); `sealed class OnboardingStepState` với `OnboardingStepType get type` + `static const stepOrder = [welcome, notification, ready]`; 3 variant `final class`: `OnboardingWelcomeStep{String? selectedLanguageCode, copyWith, ==/hashCode(Object.hash(type, selectedLanguageCode))}`, `OnboardingNotificationStep{bool isEnabled, int hour, int minute, String get formattedTime (padLeft(2,'0')), copyWith(isEnabled), ==/hashCode}`, `OnboardingReadyStep` không field + `==`/`hashCode` theo type (STRICT equality theo giá trị — VM bài 3 dùng listEquals).
- `lib/data/onboarding/onboarding_content_data.dart`: `int get onboardingQuestionCount => quizQuestions.length;` (STRICT đọc bank thật — không hardcode); `const onboardingLifelineCount = 3;` (STRICT); `onboardingTitleFor(OnboardingStepType, AppLocalizations)` + `onboardingDescriptionFor(...)` — `switch` kiệt hợp 3 arm map sang `l10n.onboarding*Title`/`onboarding*Description` (STRICT).
- `lib/l10n/app_en.arb` + `app_vi.arb`: ~64 keys mỗi file; 16 key onboarding mới STRICT (`nextButton`='Next'/'Tiếp tục' — giá trị senior KHÁC key game cũ, `enableNotificationsButton`, `getStartedButton`, `maybeLaterButton`, `onboardingWelcomeTitle`, `onboardingWelcomeDescription`, `onboardingNotificationTitle`, `onboardingNotificationDescription`, `onboardingNotificationTimeLabel`, `onboardingNotificationTimeHint`, `onboardingReadyTitle`, `onboardingReadyDescription`, `onboardingReadyQuestionsLabel`, `onboardingReadyLifelinesLabel`, `onboardingReadyLadderLabel`, `onboardingSkipIntroButton`); `You''re` escape đúng trong en.
- KEY GAME ĐÃ ĐỔI TÊN: `nextButton` cũ (NEXT/TIẾP) → `gameNextButton` trong cả 2 ARB (STRICT); `lib/screens/game_screen.dart` dùng `l10n.gameNextButton` cho nút TIẾP (STRICT — còn `l10n.nextButton` ở game = DIVERGED, nút hiện "Tiếp tục" thay "TIẾP").
- `lib/l10n/app_localizations*.dart` regenerated: có getter `onboardingWelcomeTitle`, `nextButton`, `gameNextButton`…
- `flutter gen-l10n` exit 0 (đã chạy); `flutter analyze` sạch; `flutter test` → **90/90** (không đổi từ M17).
- KHÔNG có `OnboardingViewModel`/overlay/scope file nào (bài 3–4 — sớm = AHEAD_COMPATIBLE); KHÔNG consumer mới của `OnboardingRepository` (vẫn chỉ contract+impl M14).

INVARIANTS NỀN:
- L10n pipeline M17 (48 key gốc còn nguyên trừ rename); `quizQuestions` bank; settings M16; `OnboardingRepository` contract+impl+stream (M14 — `loadOnboardingCompleted`, `setOnboardingCompleted`, `onboardingCompletedStream`).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m18/02
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
