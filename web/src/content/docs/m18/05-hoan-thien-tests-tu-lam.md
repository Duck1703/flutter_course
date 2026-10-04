---
title: "Bài 5 · Hoàn thiện — widget test, regression, tự làm"
description: "Khóa hành vi 'chỉ hiện một lần' bằng widget test trên MenuScreen thật + fake repos: fresh→welcome, đi hết 3 bước→persist+ẩn, skip→persist, completed→không hiện, chip→languageCode persist. Checkpoint: 102/102 + build web."
sidebar:
  label: "Bài 5 · test + tổng hợp"
  order: 5
---

## Mục tiêu

- Viết widget test khóa cả hai chiều của gate: **chưa complete →
  hiện; đã complete → không hiện**.
- Assert được side-effect: `onboardingRepo.value`, `setCallCount`,
  `settingsRepo.value.languageCode`.
- Chạy full regression + web build — đóng M18.

## Bạn đang ở đâu

- Bài 4 xong: overlay render trên menu, VM/scope/data đủ.
- Thiếu duy nhất: test chứng minh "chỉ một lần" — loại hành vi dễ
  hỏng lặng nhất của milestone này.

## Vì sao việc này quan trọng ngay bây giờ

Gate "chỉ hiện một lần" hỏng theo hai hướng đối lập: hiện mãi mãi
(không persist được) hoặc không bao giờ hiện (gate quá chặt). Cả hai
đều trông "vẫn chạy" khi thử tay một lần — chỉ test trên cả hai
trạng thái repo mới bắt được.

## Bạn đã biết gì

- `testWidgets`/`WidgetTester`/`pumpAndSettle` (M08+);
  `ensureVisible` nếu element off-screen.
- `MultiProvider` + `Provider<Contract>.value(fake)` (M14).
- `localizedTestApp` helper — delegates + `locale: vi` (M17).
- Navigation-less overlay: không `Navigator` — assert qua
  `find.text` + repo `value`.

## Dart cần dùng

- `addTearDown(repo.dispose)` — đóng `BehaviorSubject` sau test,
  tránh leak giữa các case.
- Named-arg constructor `FakeOnboardingRepository(initiallyCompleted:)`
  — hai trạng thái đầu-vào của gate.

## Flutter cần dùng

- `pumpAndSettle` — chờ `FutureBuilder` gate + `loadOnboarding()`
  chạy hết (frame đầu `waiting` → `SizedBox.shrink`, chưa có
  overlay để assert).
- `find.text` trên chuỗi **vi** — host ghim `locale: vi` nên
  assertion đọc đúng bản dịch.

## Mental model mới

Không có — bài này áp dụng. Một ý đáng nhớ: **test overlay = test
integration thật** — pump `MenuScreen` với 3 fake repo, vì overlay
là nhánh của `Stack` trong menu, không tách được khỏi host.

## Ví dụ độc lập

Không cần — host `_menuHost` dưới đây chính là mẫu tối thiểu.

## Android / Compose bridge

- ≈ `createComposeRule` + `setContent { MenuScreen() }` với repo
  fake — assert `onNodeWithText` tồn tại/không.
- "Pump màn thật + fake data layer" ≈ Hilt test-override module —
  cùng ý tưởng contract-first M14.

## Senior project connection

Senior có `test/` widget cho onboarding trong suite lớn hơn; pattern
host tương đương (repo fake + pump màn thật). Learner test chọn
`locale: vi` + chuỗi vi — vì assertions đọc bản dịch (khác senior
assert English ở device locale; cùng ý nghĩa kiểm chứng).

## Build it step by step

### Bước 1 — `test/widgets/onboarding_overlay_test.dart`

Host — MultiProvider 3 repo → `MenuScreen` thật:

```dart
Widget _menuHost({
  required FakeOnboardingRepository onboardingRepo,
  required FakeUserSettingsRepository settingsRepo,
}) {
  return localizedTestApp(
    home: MultiProvider(
      providers: [
        Provider<UserProfileRepository>.value(
          value: FakeUserProfileRepository(),
        ),
        Provider<UserSettingsRepository>.value(value: settingsRepo),
        Provider<OnboardingRepository>.value(value: onboardingRepo),
      ],
      child: const MenuScreen(),
    ),
  );
}
```

5 test (copy file production):

1. **fresh → welcome**: `FakeOnboardingRepository()` mặc định `false`
   → `'Chào mừng đến AI Quiz!'` + chip `'English'`/`'Tiếng Việt'` +
   `'Bỏ qua giới thiệu'`.
2. **đi hết 3 bước**: `Tiếp tục` → `'Nhắc bạn mỗi ngày'` → `Bật
   thông báo` → `'Bạn đã sẵn sàng!'` → `Bắt đầu` →
   `onboardingRepo.value == true` + overlay biến mất.
3. **skip intro**: `Bỏ qua giới thiệu` → persist + ẩn ngay.
4. **đã complete**: `initiallyCompleted: true` → không text
   onboarding nào.
5. **chọn ngôn ngữ**: tap `'English'` → `settingsRepo.value
   .languageCode == 'en'` — dây chuyền M17 ăn ngay trong onboarding.

### Bước 2 — regression đầy đủ

```powershell
flutter analyze
flutter test          # 102/102 (+5 widget test)
flutter build web
```

## Hiểu code

- `await tester.pumpAndSettle()` sau `pumpWidget` — FutureBuilder
  phải done + `loadOnboarding()` phải xong trước khi welcome render;
  thiếu nó là false-fail kinh điển.
- Assert hai phía: `find.text` (UI) **và** `repo.value`/`saveCallCount`
  (persist) — test chỉ UI sẽ bỏ lỡ "hiện đúng nhưng không lưu".
- Test 4 không tap gì cả: giá trị của nó là *vắng mặt* — chứng minh
  gate đóng được, không chỉ mở được.

## Chạy và quan sát

Ngoài suite: mở DevTools/đổi prefs → `onboarding_completed: false` →
hot-restart → overlay hiện; đi `Bỏ qua giới thiệu` → restart → menu
trần. Đó là vòng "reinstall" bằng tay.

## Thử nghiệm

Xóa `'onboarding_completed': true` khỏi `setMockInitialValues` trong
`menu_screen_ui_events_test.dart` rồi chạy — test "ĐẶT LẠI HỒ SƠ" đỏ
vì overlay nuốt tap. Hoàn nguyên. Bài học: flag test-host phản ánh
*trạng thái thật* của máy đã qua onboarding — không phải trick.

## Lỗi hay gặp

- `pump()` một lần rồi assert → overlay chưa render (Future chưa
  done) → false-fail. Dùng `pumpAndSettle`.
- Tap text off-viewport → `ensureVisible` trước.
- Quên `addTearDown(repo.dispose)` → subject mở giữa các test.
- Assert chuỗi en trên host `locale: vi` → findsNothing — assertion
  phải đọc cùng locale với host.

## Tự làm — skip ở bước notification vẫn persist (PRODUCE)

**Đề bài.** Viết test thứ 6: "Bỏ qua giới thiệu ở bước notification
vẫn persist". Tap `Tiếp tục` (welcome → notification) rồi `Bỏ qua
giới thiệu`. Xác nhận `onboardingRepo.setCallCount == 1` và overlay
ẩn.

Đây là case production quan trọng: skip phải persist bất kể đang ở
bước nào — một refactor VM khiến skip chỉ hoạt động ở bước 1 sẽ lọt
qua 5 test hiện có.

:::note[Gợi ý]

- Giống test skip-intro nhưng chèn một `tap('Tiếp tục')` +
  `pumpAndSettle` ở giữa.
- `skipIntro` của VM không quan tâm step hiện tại — chỉ cần `_steps`
  không rỗng.
:::

<details><summary>Đáp án</summary>

```dart
testWidgets('skip intro ở bước notification vẫn persist', (t) async {
  final onboardingRepo = FakeOnboardingRepository();
  final settingsRepo = FakeUserSettingsRepository();
  addTearDown(onboardingRepo.dispose);
  addTearDown(settingsRepo.dispose);

  await t.pumpWidget(_menuHost(
    onboardingRepo: onboardingRepo,
    settingsRepo: settingsRepo,
  ));
  await t.pumpAndSettle();

  await t.tap(find.text('Tiếp tục'));
  await t.pumpAndSettle();
  expect(find.text('Nhắc bạn mỗi ngày'), findsOneWidget);

  await t.tap(find.text('Bỏ qua giới thiệu'));
  await t.pumpAndSettle();

  expect(onboardingRepo.setCallCount, 1);
  expect(find.text('Bỏ qua giới thiệu'), findsNothing);
});
```

</details>

## Kiểm tra hiểu biết

1. Vì sao test pump `MenuScreen` thật thay vì chỉ `OnboardingOverlay`?
2. `pumpAndSettle` chờ cái gì ở đây cụ thể?
3. Hai chiều của gate cần hai test nào?
4. Assert `repo.value` thêm gì so với chỉ assert `find.text`?

## Ta cố ý chưa thêm

- Test golden/screenshot — visual parity là phạm vi M28.
- Test permission deny path qua UI — nút learner luôn simulated-grant;
  nhánh deny đã cover ở VM unit test (Bài 3).
- Test locale flip live trong onboarding → l10n switch — đã có
  `localization_switch_test` (M17) khóa dây chuyền; ở đây chỉ assert
  persist `languageCode`.

## Checkpoint hoàn thành

`flutter analyze` sạch; `flutter test` **102/102**; `flutter build
web` pass. Xóa prefs → overlay hiện; hoàn thành → restart → không
hiện lại; chọn ngôn ngữ → locale đổi live.

**M18 xong** — Phase E khép: app local giàu tính năng (settings +
localization + onboarding). Phase F (M19+) rebuild game ở độ sâu
senior.

## 🤖 AI Local — Kiểm tra project sau bài này (TỔNG HỢP M18)

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m18/05 — TỔNG HỢP M18 (widget test khóa gate "chỉ hiện một lần" trên MenuScreen thật + fake repos; suite 102/102 + build web).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test` (kể cả file riêng), `flutter build web` READ-ONLY (chỉ verify). Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Test overlay = integration test thật: pump `MenuScreen` với 3 fake repo — overlay là nhánh Stack của menu, không tách host.

EXPECTED STATE SAU BÀI NÀY:
- `test/widgets/onboarding_overlay_test.dart` (STRICT file): host `_menuHost({required FakeOnboardingRepository, required FakeUserSettingsRepository})` → `localizedTestApp(home: MultiProvider(providers: [Provider<UserProfileRepository>.value(FakeUserProfileRepository()), Provider<UserSettingsRepository>.value(settingsRepo), Provider<OnboardingRepository>.value(onboardingRepo)], child: const MenuScreen()))` (STRICT pump màn thật + 3 fake + `locale: vi` host); `addTearDown(repo.dispose)` cho fakes; `pumpAndSettle` sau `pumpWidget` (STRICT — FutureBuilder gate cần settle).
- 5 test case STRICT (tên có thể khác, hành vi phải đúng):
  1. fresh repo → welcome hiện: `find.text('Chào mừng đến AI Quiz!')` + chip `'English'`/`'Tiếng Việt'` + `'Bỏ qua giới thiệu'`.
  2. đi hết 3 bước → `onboardingRepo.value == true` (persist) + overlay biến mất.
  3. skip intro → persist + ẩn ngay.
  4. `FakeOnboardingRepository(initiallyCompleted: true)` → KHÔNG text onboarding nào (gate đóng — test vắng mặt).
  5. tap chip `'English'` → `settingsRepo.value.languageCode == 'en'` (dây chuyền M17 trong onboarding).
- `flutter analyze` sạch; `flutter test` → **102/102** (STRICT 97 + 5); `flutter build web` thành công.
- Tự làm (OPTIONAL): test thứ 6 "skip ở notification vẫn persist" (`setCallCount == 1` sau skip giữa chừng) — có thì ghi nhận, không có KHÔNG tính thiếu.

INVARIANTS NỀN — toàn M18 phải còn nguyên:
- `OnboardingStepState` sealed + `stepOrder` + equality (bài 2); `onboarding_content_data.dart` (`onboardingQuestionCount`→`quizQuestions.length`, `onboardingTitleFor`/`DescriptionFor` switch); 64-key ARB + `gameNextButton` rename + game screen `l10n.gameNextButton`; `OnboardingViewModel` queue + guards + `isVisible` + `selectLanguage` (bài 3); `OnboardingOverlayScope` FutureBuilder+identical-gate+`snapshot.data ?? stream.value`+`SizedBox.shrink`×3+`ChangeNotifierProvider` overlay-scoped (bài 4); `OnboardingOverlay` opaque absorber + per-step actions + `LanguageChipRow` shared (bài 4); `menu_screen.dart` `Stack`+`Positioned.fill(child: OnboardingOverlayScope())`; `onboarding_completed: true` trong 3 test host (4 chỗ); `localizedTestApp` + l10n M17; settings M16.
- KHÔNG: `BackdropFilter`/`AnimatedSwitcher`/`LocalNotificationService` (M27/M28); onboarding không phải route/dialog — không `Navigator.push`/`showDialog` cho nó (STRICT nếu thấy route-based onboarding = DIVERGED).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (visual parity M28, permission M27, reducer M19) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. M19+ rebuild game engine — chưa chấm.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m18/05
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
