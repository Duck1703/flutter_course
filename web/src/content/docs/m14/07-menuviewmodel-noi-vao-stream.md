---
title: "Bài 7 · MenuViewModel nối vào stream — retire MenuLoadState, xoá ProfileStore"
description: "VM seed .value + listen trong ctor, writer chỉ save qua repo, dispose cancel trước close; retire MenuLoadState/load()/_MenuLoading/_MenuErrorState; xoá profile_store.dart cuối cùng khi không còn ai dùng."
sidebar:
  label: "Bài 7 · VM nối stream & retire"
  order: 7
---

## Mục tiêu

- Hoàn tất bước chuyển lớn nhất của M14: `MenuViewModel` sống trên
  repository stream — và dọn đi toàn bộ vòng đời "load tay" của M11.
- Rút bridge `ProfileStore` *sau khi* không còn ai đọc nó — xoá file
  cuối cùng, không phải đầu tiên.
- Chứng minh stream propagation bằng test qua cả cây widget.

## Bạn đang ở đâu

- Milestone: **M14** (bài 7/7) — mọi mảnh đã sẵn: contract (2),
  stream-state (3), impl (4–5), DI theo contract (6). Bài này chỉ
  đổi **ai đọc ai**: VM chuyển từ `ProfileStore` sang
  `UserProfileRepository`.

## Constructor mới — đúng shape senior

```dart
MenuViewModel({required UserProfileRepository userProfileRepository})
  : _userProfileRepository = userProfileRepository,
    _userData = userProfileRepository.userProfileStream.value {
  _userProfileSubscription = _userProfileRepository.userProfileStream
      .listen(_handleUserProfile);
}
```

Đọc kỹ vì cả ba điểm đều là ý đồ:

- **Tham số là CONTRACT** — `UserProfileRepository`, không phải impl.
  `create:` của provider sẽ tra `context.read<UserProfileRepository>()`
  — đúng slot đã đăng ký ở bài 6.
- **`.value` trong initializer list**: `userProfileStream` là
  `ValueStream` — đọc đồng bộ được *trước cả khi ctor body chạy*. VM
  sinh ra đã có profile (tối thiểu bản seeded).
- **`listen` trong ctor body**: subscribe ngay khi VM sinh — mọi emit
  sau của repo chảy vào `_handleUserProfile`. Không `await`: đăng ký
  là đồng bộ, event đến theo thời gian.

## Handler + dispose

```dart
void _handleUserProfile(UserProfileData userData) {
  if (_isDisposed) {
    return;
  }
  final shouldNotify = _userData != userData;
  _userData = userData;
  if (shouldNotify) {
    notifyListeners();
  }
}

@override
void dispose() {
  _isDisposed = true;
  _userProfileSubscription?.cancel();
  _events.close();
  super.dispose();
}
```

- `_isDisposed` guard: emit có thể đến *sau* dispose —
  `ChangeNotifier` đã chết không được notify.
- Compare-before-notify: profile giống hệt thì không rebuild (senior
  `_handleUserProfile` đúng vậy).
- Cancel subscription *trước* khi đóng `_events` — đúng thứ tự dọn
  của senior.

## Writer không còn gán state tay

Data flow đổi triệt để. Trước M14:

```dart
// CŨ — VM tự gán state rồi tự notify, store chỉ là nơi ghi
_profile = _profile.applyGameResult(result);
notifyListeners();
await _store.save(_profile);
```

M14:

```dart
Future<void> applyGameResult(GameResult result) async {
  await _userProfileRepository.saveUserProfile(
    _userData.applyGameResult(result),
  );
}
```

VM chỉ **save qua repo**. Repo emit → `_handleUserProfile` cập nhật
`_userData` + notify. Stream là nguồn truth duy nhất — writer nào
save cũng vậy. (Ở senior, *game* VM save; learner giữ áp kết quả ở
menu tới M19/M22 — cơ chế stream đã là của senior.)

`resetProfile()` tương tự: `resetUserProfile()` → stream cập nhật →
`MenuSnackBarRequested` vẫn bắn. `loadUserProfile()` chỉ delegate:

```dart
Future<void> loadUserProfile() =>
    _userProfileRepository.loadUserProfile();
```

Vẫn gọi một lần lúc `create:` bằng `..loadUserProfile()` — tác dụng
là đọc disk → emit bản đã lưu vào stream.

## Retire `MenuLoadState` — không còn gì để loading

Toàn bộ surface này biến mất khỏi `lib/`:

- `enum MenuLoadState { loading, ready, failed }`
- `MenuViewModel.loadState`, `_setLoadState`, method `load()`
- `_MenuLoading` (`CircularProgressIndicator` "Đang tải hồ sơ…")
- `_MenuErrorState` (icon lỗi + nút "THỬ LẠI")
- `switch (viewModel.loadState) { … }` trong `build`

Vì sao dám xoá? Vì senior không có surface này — repo seeded bằng
`BehaviorSubject` nên *luôn* có giá trị để render; `loadUserProfile()`
chỉ nạp bản lưu vào stream chứ không phải điều kiện hiển thị. Menu
giờ render `userData` trực tiếp — frame đầu thấy seed, emit sau tự
cập nhật. (Abstraction tạm M11 giờ đã được thay bằng
cơ chế thật của senior.)

## `menu_screen.dart` đổi tương ứng

```dart
create: (context) => MenuViewModel(
  userProfileRepository: context.read<UserProfileRepository>(),
)..loadUserProfile(),
```

và trong build: mọi `viewModel.profile` → `viewModel.userData` (getter
đổi tên theo senior `MenuScreenViewModel.userData`),
`profile.totalEarningsDisplay` → `profile.totalEarnings` (field đã
format sẵn — bài 5). Xoá nhánh `loadState` switch khỏi `build`.

**Giờ mới xoá file cũ:** khi không còn import nào tới
`ProfileStore` — rút entry `Provider<ProfileStore>.value` khỏi
`MultiProvider` + field `profileStore` khỏi scope và `main()`, rồi
xoá `lib/data/profile/profile_store.dart` và
`test/profile_store_test.dart`. Đây là thứ tự đúng: migrate → rút
bridge → xoá. (Bài 1 của chuỗi cũ xoá file đầu tiên — đó là lỗi
sequencing đã sửa: checkpoint "analyze sạch" chỉ có
nghĩa khi không còn ai dùng file bị xoá.)

## Test chứng minh stream propagation

Hai lớp test mới/cập nhật đáng đọc vì chúng chứng minh đúng điều M14
hứa:

```dart
// menu_view_model_test.dart — fake repo lái VM, không cần Flutter/prefs
final repo = FakeUserProfileRepository();
final vm = MenuViewModel(userProfileRepository: repo);
await repo.saveUserProfile(const UserProfileData(username: 'An'));
await pumpEventQueue();
expect(vm.userData.username, 'An');
expect(notifies, 1);          // seed khác 'An' → đúng một notify
```

```dart
// menu_provider_scope_test.dart — qua cả cây widget
await repo.saveUserProfile(const UserProfileData(username: 'Stream'));
await tester.pump();
await tester.pump();
expect(find.text('Stream'), findsOneWidget);
```

`pumpEventQueue()` / pump thứ hai là chi tiết thực tế: `subject.add`
đưa event vào queue — listener nhận ở microtask kế; test phải flush
queue trước khi assert. `menu_ui_events_test.dart` cũng cập nhật:
`MenuViewModel(store: makeStore())` → `MenuViewModel(
userProfileRepository: FakeUserProfileRepository())` — fake thay
`makeStore` ở mọi test VM.

## Chạy và quan sát

```bash
flutter analyze      # sạch — không còn import mồ côi
flutter test         # toàn bộ xanh
flutter run          # menu render profile; chơi ván → tiền/EXP cập
                     # nhật khi pop về — không ai gọi "reload"
```

Đây là khoảnh khắc M14 hứa: menu tự cập nhật khi *bất kỳ ai*
`saveUserProfile` — VM không còn poll hay load tay.

## Lỗi hay gặp

- **`ProviderNotFoundException` sau khi rút bridge** — một `read<
  ProfileStore>()` còn sót trong `menu_screen`/`main` → grep trước
  khi xoá file.
- **VM không nhận emit** — quên `..loadUserProfile()` ở `create:`,
  hoặc `listen` gắn vào `.stream` thay vì dùng getter contract
  (`userProfileStream` đã là stream — không `.stream` lần nữa).
- **Test flakey thiếu `pumpEventQueue()`** — subject emit qua
  microtask; assert ngay sau `save` có thể chạy trước khi listener
  nhận.
- **Giữ `MenuLoadState` "phòng khi"** — abstraction không còn ai
  dùng là nợ kỹ thuật; senior không có nó, course xoá tường minh.

## Tự làm

**Giải thích data flow — không nhìn code.** Từ khoảnh khắc user bấm
CHƠI xong một ván và `applyGameResult(result)` được gọi, mô tả đủ
bảy bước dữ liệu chảy tới UI — ai gọi ai, qua stream nào, notify ở
đâu. Sau đó:

1. Viết một widget test mới chứng minh *late subscriber*: pump
   `MenuScreen` qua `AppDependencyScope` với fake đã `save` sẵn
   `'Huy'` *trước khi* pump — UI hiển thị 'Huy' ngay frame đầu.
   Vì sao không cần emit nào thêm?

<details><summary><strong>Đáp án</strong></summary>

Data flow: `MenuViewModel.applyGameResult` → `repo.saveUserProfile`
→ impl `setString` disk + `_emitUserProfile` → `BehaviorSubject.add`
→ `userProfileStream` emit → `_handleUserProfile` → `_userData =
mới` + `notifyListeners()` → `context.watch<MenuViewModel>` rebuild
→ `_ProfileHeader` render tên mới.

Late-subscriber test: fake `seeded`/`save` trước pump → ctor VM đọc
`.value == 'Huy'` ngay trong initializer — render frame đầu đã có
'Huy' mà không cần emit nào. Đây chính là lý do `MenuLoadState`
retire được.

```dart
testWidgets('menu shows saved profile on first frame', (t) async {
  final repo = FakeUserProfileRepository(
    initialProfile: const UserProfileData(username: 'Huy'),
  );
  await t.pumpWidget(AppDependencyScope(
    userProfileRepository: repo,
    userSettingsRepository: FakeUserSettingsRepository(),
    onboardingRepository: FakeOnboardingRepository(),
    child: const MaterialApp(home: MenuScreen()),
  ));
  expect(find.text('Huy'), findsOneWidget);
});
```

</details>

## Tự kiểm tra

1. Vì sao `.value` đọc được trong initializer list? — *`ValueStream`
   expose giá trị hiện tại đồng bộ; subject seeded nên giá trị tồn
   tại ngay khi ctor chạy.*
2. `applyGameResult` mất `notifyListeners` — ai báo UI? — *Repo emit
   → `_handleUserProfile` → notify. Writer không tự gán state.*
3. Vì sao xoá `profile_store.dart` ở *bài cuối* chứ không đầu
   milestone? — *File chỉ xoá khi không còn consumer; xoá sớm phá
   vỡ mọi checkpoint giữa.*

## Ta cố ý chưa thêm

- **`sealed` cho event/state** — M15; `MenuUiEvent` vẫn `abstract` +
  `is`-check.
- **Load settings/onboarding vào VM** — consumer của hai repo đó là
  M16/M18.
- **`authRepository` trong `loadUserProfile`** — senior gọi cả hai
  repo; learner chưa có auth (M24).

## Checkpoint hoàn thành — kết M14

- [ ] `MenuViewModel` ctor nhận `UserProfileRepository`, seed `.value`,
      `listen` trong ctor; `dispose` có `_isDisposed` + cancel + close.
- [ ] `MenuLoadState`, `load()`, `loadState`, `_MenuLoading`,
      `_MenuErrorState` không còn trong `lib/`.
- [ ] `menu_screen.dart` render `viewModel.userData`; scope và
      `main()` không còn `ProfileStore`; `profile_store.dart` +
      `profile_store_test.dart` đã xoá.
- [ ] `applyGameResult`/`resetProfile` chỉ gọi repo — không gán
      `_userData` tay.
- [ ] `flutter analyze` + `flutter test` xanh: fake repo lái VM,
      repo impl persist qua disk, widget test thấy UI đổi khi repo
      emit.
- [ ] Mô tả được toàn bộ data flow writer→repo→subject→VM→UI mà
      không nhìn code (bài Tự làm).

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m14/07 — "MenuViewModel nối vào stream — retire MenuLoadState, xoá ProfileStore" (bài cuối M14 — GATE của cả milestone: VM sống trên repo stream, toàn bộ vòng đời load-tay được dọn).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter build web`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chấm TOÀN BỘ trạng thái M14 (repo architecture hoàn chỉnh) theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. RETIRE LIST quan trọng: `MenuLoadState`, `load()`, `loadState`, `_MenuLoading`, `_MenuErrorState`, `ProfileStore` không còn — còn sót = DIVERGED, không phải "an toàn thêm".

EXPECTED STATE SAU BÀI NÀY:
- `MenuViewModel` ctor: `MenuViewModel({required UserProfileRepository userProfileRepository}) : _userProfileRepository = ..., _userData = userProfileRepository.userProfileStream.value { _userProfileSubscription = _userProfileRepository.userProfileStream.listen(_handleUserProfile); }` (STRICT: tham số CONTRACT + `.value` trong initializer + `listen` trong ctor body, không await); field `_userProfileRepository`, `_userData`, `StreamSubscription? _userProfileSubscription`, `bool _isDisposed`.
- `void _handleUserProfile(UserProfileData userData)`: `if (_isDisposed) return;` → `shouldNotify = _userData != userData` → gán → `if (shouldNotify) notifyListeners();` (STRICT guard disposed + compare-before-notify).
- `dispose`: `_isDisposed = true;` → `_userProfileSubscription?.cancel();` → `_events.close();` → `super.dispose();` (STRICT thứ tự).
- `applyGameResult` chỉ `await _userProfileRepository.saveUserProfile(_userData.applyGameResult(result));` (STRICT — KHÔNG gán `_userData` tay, KHÔNG notify tay; repo emit lo). `resetProfile()` → `resetUserProfile()` + vẫn `_events.add(MenuSnackBarRequested('Đã đặt lại hồ sơ.'))`. `loadUserProfile()` → delegate `_userProfileRepository.loadUserProfile()`.
- RETIRED (STRICT — không còn trong lib/): `enum MenuLoadState`, `vm.loadState`, `_setLoadState`, method `load()`, widget `_MenuLoading`, `_MenuErrorState`, `switch (viewModel.loadState)` trong build.
- `menu_screen.dart`: `create: (context) => MenuViewModel(userProfileRepository: context.read<UserProfileRepository>())..loadUserProfile()` (STRICT đọc contract từ scope); mọi `viewModel.profile` → `viewModel.userData`; UI đọc `profile.totalEarnings` (field đã format — `totalEarningsDisplay` đã retire).
- `AppDependencyScope` + `main()` KHÔNG còn `ProfileStore` (STRICT — bridge rút sau khi không ai đọc); `lib/data/profile/profile_store.dart` + `test/profile_store_test.dart` ĐÃ XOÁ (STRICT — còn sót = DIVERGED); không còn import nào tới ProfileStore (grep `ProfileStore` trong lib/ chỉ nên ra 0 hit ngoài comment lịch sử).
- Tests: `menu_view_model_test.dart` dùng `FakeUserProfileRepository` (thay `makeStore`): `MenuViewModel(userProfileRepository: repo)` → `await repo.saveUserProfile(UserProfileData(username: 'An'))` → `await pumpEventQueue()` → `vm.userData.username == 'An'` + notify đúng 1 lần (STRICT pattern); `menu_provider_scope_test.dart` dựng scope 3 repo fake, test emit → `tester.pump()` ×2 → `find.text('Stream')` (STRICT propagation qua cây widget); `menu_ui_events_test.dart` cũng dùng fake repo.
- `flutter analyze` → "No issues found!" (không còn import mồ côi); `flutter test` → "All tests passed!"; `flutter build web` → thành công; app: menu render profile ngay, chơi xong pop về → tiền/EXP cập nhật mà không ai gọi reload.

INVARIANTS NỀN:
- Ba repo contract+impl (profile/settings/onboarding) bài 4–5; MultiProvider đăng ký theo contract bài 6 (trừ entry ProfileStore đã rút); `UserSettingsData` + `UserProfileData` parity; event channel `MenuUiEvent` + broadcast `_events` + bridge `_handleUiEvent`/`_attachViewModel` M13 nguyên vẹn; `MenuViewModel` vẫn extends ChangeNotifier; game M09 + route-result M10.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (sealed events, settings consumer, navigation controller) → `AHEAD_COMPATIBLE`; thiếu bắt buộc hoặc retire-list còn sót → `BEHIND`/`DIVERGED` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m14/07
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
