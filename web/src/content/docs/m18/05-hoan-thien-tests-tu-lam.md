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
