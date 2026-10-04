---
title: "Bài 6 · DI theo contract: MultiProvider, bootstrap, fake repositories"
description: "Provider<Contract>.value — đăng ký theo interface; MultiProvider vs nested provider; main() bootstrap ×3 + loadUserSettings; FakeUserProfileRepository — contract trả nợ. Bridge state: ProfileStore vẫn song hành."
sidebar:
  label: "Bài 6 · DI theo contract & MultiProvider"
  order: 6
---

## Mục tiêu

- Hiểu **DI theo contract** thực tế (không lý thuyết SOLID): đăng ký
  `Provider<UserProfileRepository>` — kiểu *interface* — chứ không
  phải `Provider<UserProfileRepositoryImpl>`.
- Dùng `MultiProvider`, hiểu nó chỉ là shortcut của provider lồng nhau.
- Viết `FakeUserProfileRepository` — thu hoạch đầu tiên của
  contract-first.

## Bạn đang ở đâu

- Milestone: **M14** (bài 6/7).
- Ba repo + impl đã tồn tại; scope app vẫn chỉ có một
  `Provider<ProfileStore>.value` của M12. Bài này đưa repo vào cây —
  **nhưng `ProfileStore` vẫn song hành** vì VM chưa migrate (bài 7
  mới đổi). Cuối bài app chạy bình thường — trên đường cũ — với repo
  đã sẵn sàng trong scope.

## Bạn đã biết gì

- `Provider.value`, `context.read<T>()`, `AppDependencyScope` (M12).
- `MultiProvider` — M12 nhắc tên trong danh sách "cố ý chưa thêm"
  (và bài Tự làm M12/03 để bạn lồng Provider tay); bài này là
  **first use + teaching đầy đủ**.
- `implements` contract (bài 2) — fake repo chỉ là `implements`
  lần nữa, lần này trong `test/`.

## Mental model: DI theo contract

`MenuViewModel` (bài 7) sẽ hỏi: *"cho tôi một `UserProfileRepository`"*
— nó nói **capability**, không nói impl. Khi scope đăng ký:

```dart
Provider<UserProfileRepository>.value(value: userProfileRepository)
```

kiểu đăng ký là **contract**. Bất kỳ ai `context.read<
UserProfileRepository>()` nhận instance đang ngồi đó — app thật là
`UserProfileRepositoryImpl`, test đặt `FakeUserProfileRepository` vào
đúng slot đó mà không sửa một widget nào.

Ngược lại — hướng sai:

```dart
Provider<UserProfileRepositoryImpl>.value(...)   // đăng ký theo impl
// → context.read<UserProfileRepository>() KHÔNG tìm thấy:
//   provider tra theo ĐÚNG kiểu đã đăng ký.
```

Đây là "bad dependency direction": consumer buộc biết impl → test
phải dựng impl thật (cần prefs) → contract vô nghĩa. Đăng ký theo
contract là toàn bộ điểm của DI ở app này.

**Android bridge:** đây là `@Binds`/`@Provides` của Hilt — bạn bind
`UserProfileRepositoryImpl` *vào kiểu* `UserProfileRepository`, module
trả impl, consumer chỉ thấy interface. Provider không phải DI
framework đầy đủ (không graph, không scope) — nó là service-locator
qua widget tree; đủ cho shape senior.

## `MultiProvider` — shortcut, không phải ma thuật

M12 đã có `Provider<ProfileStore>.value`. Ba repo mới nếu viết thẳng
sẽ là ba tầng lồng:

```dart
Provider<UserProfileRepository>.value(
  value: ...,
  child: Provider<UserSettingsRepository>.value(
    value: ...,
    child: Provider<OnboardingRepository>.value(
      value: ...,
      child: child,
    ),
  ),
)
```

`MultiProvider` viết gọn đúng cái đó — **không** thay đổi semantics:

```dart
return MultiProvider(
  providers: [
    Provider<UserProfileRepository>.value(value: userProfileRepository),
    Provider<UserSettingsRepository>.value(value: userSettingsRepository),
    Provider<OnboardingRepository>.value(value: onboardingRepository),
    Provider<ProfileStore>.value(value: profileStore),   // BRIDGE — xem dưới
  ],
  child: child,
);
```

- Cùng `context.read<T>()` tra như cũ — MultiProvider chỉ gom list.
- Nó **không** dispose object `Provider.value` — ownership vẫn ở
  `main()` (repo sống cùng app; `dispose()` dành cho test).
- `Provider<Contract>.value` vs `create:` — `.value` cho object *đã
  tồn tại* (main tạo rồi đưa vào); `create:` khi provider tự sở hữu
  vòng đời (như `ChangeNotifierProvider` của `MenuViewModel`).

> **BRIDGE — trạng thái chuyển tiếp:** entry `Provider<ProfileStore>
> .value` giữ nguyên vì `MenuScreen` còn `context.read<ProfileStore>()`
> cho VM cũ. Nó biến mất ở bài 7 cùng `profile_store.dart`. Đừng bỏ
> nó bây giờ — app sẽ `ProviderNotFoundException` lúc chạy.

## `main()` — bootstrap đúng shape senior

```dart
final userProfileRepository = await UserProfileRepositoryImpl.create();
final userSettingsRepository = await UserSettingsRepositoryImpl.create();
final onboardingRepository = await OnboardingRepositoryImpl.create();
await userSettingsRepository.loadUserSettings();
runApp(AppDependencyScope(
  userProfileRepository: userProfileRepository,
  userSettingsRepository: userSettingsRepository,
  onboardingRepository: onboardingRepository,
  profileStore: profileStore,          // BRIDGE — vẫn truyền tới bài 7
  child: const AIMillionaireApp(),
));
```

- Ba `await create()` vì `getInstance()` là Future (bài 2).
- `loadUserSettings()` chạy **trước** `runApp` — senior làm vậy để
  settings sẵn sàng trước frame đầu (settings lái locale ở app
  senior). Profile **không** load ở đây: `MenuScreen` gọi
  `..loadUserProfile()` khi tạo VM (bài 7). Onboarding chưa ai load
  — gate M18 sẽ lo.
- `AppDependencyScope` đổi ctor: ba field kiểu **contract** + giữ
  field `profileStore` tạm thời; `build` trả `MultiProvider` như trên.

## `FakeUserProfileRepository` — contract trả nợ

Vì VM sẽ phụ thuộc contract, test `implements` nó bằng một subject
in-memory — không SharedPreferences, không mock framework.
`test/helpers/fake_user_profile_repository.dart`:

```dart
class FakeUserProfileRepository implements UserProfileRepository {
  final BehaviorSubject<UserProfileData> _subject;
  var saveCallCount = 0;
  var loadCallCount = 0;

  FakeUserProfileRepository({
    UserProfileData initialProfile = const UserProfileData(),
  }) : _subject = BehaviorSubject<UserProfileData>.seeded(initialProfile);

  @override
  ValueStream<UserProfileData> get userProfileStream => _subject.stream;

  /// Giá trị hiện tại — tiện cho assert.
  UserProfileData get value => _subject.value;

  @override
  Future<UserProfileData> loadUserProfile() async {
    loadCallCount++;
    return _subject.value;
  }

  @override
  Future<void> saveUserProfile(UserProfileData userData) async {
    saveCallCount++;
    _subject.add(userData);
  }

  @override
  Future<void> resetUserProfile() =>
      saveUserProfile(const UserProfileData());

  @override
  Future<void> dispose() => _subject.close();
}
```

Đọc kỹ:

- Fake **không ghi disk** — chỉ `add` lên subject. Đủ cho VM-level
  test: điều VM cần là "emit đúng state mới", không phải "ghi file".
- `saveCallCount`/`loadCallCount` cho assert hành vi ("VM gọi repo")
  mà không nhìn vào trong. Đúng pattern senior — `test/widgets/
  game_screen_test_helpers.dart` có `FakeGameProfileRepository` cùng
  shape, kèm `saveCallCount`.
- Hai fake còn lại (`FakeUserSettingsRepository`,
  `FakeOnboardingRepository`) cùng mẫu — chúng cần tồn tại vì
  `AppDependencyScope` mới nhận ba field contract; test dựng scope
  phải truyền đủ ba.
- Hai lớp test hai mục đích: repo test (bài 4–5) chứng minh disk +
  stream của impl thật; VM test (bài 7) dùng fake chứng minh VM nghe
  contract đúng — không chồng lấn, không thay thế nhau.

## Từng bước

1. Viết ba file fake trong `test/helpers/` (theo mẫu trên).
2. Sửa `app_dependency_scope.dart`: thêm import ba repo, ctor nhận
   ba field contract + `profileStore`, `build` trả `MultiProvider`
   4 entry (thứ tự không quan trọng — provider tra theo kiểu).
3. Sửa `main()`: ba `await create()` + `loadUserSettings()` + truyền
   đủ bốn dependency vào scope.
4. Cập nhật `test/menu_provider_scope_test.dart` (và bất kỳ test nào
   dựng `AppDependencyScope`): truyền ba fake + `ProfileStore()` —
   compile trước khi migrate.
5. `flutter analyze` + `flutter test` + `flutter run`.

## Chạy và quan sát

App chạy **y hệt trước** — đó là điểm của bridge state: repo đã nằm
trong cây nhưng chưa ai đọc. Kiểm chứng repo thật sự nằm trong scope
bằng một dòng tạm trong `MenuScreen.build`:

```dart
// debugPrint(context.read<UserProfileRepository>().userProfileStream
//     .value.username);
```

in ra `0XFF` (seed mặc định) → xoá dòng debug. Đừng giữ nó — đây chỉ
là kiểm tra dây đã thông.

## Lỗi hay gặp

- **`ProviderNotFoundException`** — tra `read<Impl>` khi đăng ký
  `Provider<Contract>` (hoặc ngược lại). Provider tra *đúng kiểu*
  đăng ký — đây là lý do đăng ký theo contract và đọc theo contract.
- **Bỏ `Provider<ProfileStore>` sớm** — `MenuScreen` cũ vẫn đọc nó →
  exception lúc mở menu. Bridge entry chỉ được rút ở bài 7.
- **`Provider.value` vs `create:` nhầm** — `.value` cho instance đã
  tồn tại (main tạo); `create:` để provider tự tạo + tự dispose.
  Repo app-scoped dùng `.value`.
- **Fake không seeded** — `FakeUserProfileRepository()` nhưng
  `_subject` không seed → `.value` ném; giữ `.seeded(initialProfile)`.

## Tự làm

**Tự wire — không copy.** Viết `FakeOnboardingRepository` trong
`test/helpers/` (contract `OnboardingRepository` của bài 5 —
`ValueStream<bool>` seed `false`). Sau đó trả lời:

1. Trong `AppDependencyScope`, đổi `Provider<UserProfileRepository>`
   thành `Provider<UserProfileRepositoryImpl>` — dự đoán lỗi xảy ra
   khi nào: compile hay runtime?
2. Vì sao fake cần `BehaviorSubject` riêng mà không `extends`
   `UserProfileRepositoryImpl`?

<details><summary><strong>Đáp án</strong></summary>

1. Compile vẫn qua (`Impl` là subtype) — lỗi xảy ra **runtime**:
   `context.read<UserProfileRepository>()` không tìm thấy provider
   đăng ký theo `Impl` → `ProviderNotFoundException`. Provider tra
   theo kiểu đăng ký chính xác.
2. `extends` kéo theo ctor private `._`, prefs, disk logic — fake
   không muốn cái đó. `implements` chỉ cam kết chữ ký: fake tự giữ
   subject in-memory, bỏ hết SharedPreferences.
</details>

## Tự kiểm tra

1. Vì sao `Provider<UserProfileRepository>.value` chứ không phải
   `Provider<UserProfileRepositoryImpl>`? — *Đăng ký theo contract:
   consumer chỉ biết interface; test đặt fake vào cùng slot.*
2. `MultiProvider` thay đổi gì so với ba `Provider` lồng nhau? —
   *Không gì về semantics — chỉ gom list cho gọn; `read<T>` giống
   hệt.*
3. `loadUserSettings()` ở `main` mà `loadUserProfile()` ở VM — vì
   sao? — *Senior cần settings (locale) trước frame đầu; profile gắn
   vòng đời màn menu — phân chia của senior.*

## Ta cố ý chưa làm

- **Chưa migrate `MenuViewModel`** — bài 7; `ProfileStore` entry là
  bridge có chủ đích, không phải quên dọn.
- **`create:` provider cho repo** — repo là `.value` app-scoped;
  `create:` chỉ dùng cho đối tượng provider tự sở hữu.

## Checkpoint hoàn thành

- [ ] `app_dependency_scope.dart` là `MultiProvider` với ba
      `Provider<Contract>.value` + entry `ProfileStore` bridge.
- [ ] `main()` `await create()` ×3 + `await loadUserSettings()` —
      vẫn truyền `profileStore`.
- [ ] `test/helpers/` có ba `Fake*Repository` `implements` contract;
      `menu_provider_scope_test.dart` (và test dựng scope) đã cập
      nhật ctor mới.
- [ ] `flutter analyze` + `flutter test` xanh; app chạy bình thường
      trên đường cũ.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m14/06 — "DI theo contract: MultiProvider, bootstrap, fake repositories" (repo vào scope theo KIỂU CONTRACT + main() bootstrap ×3 + ba fake trong test/helpers; ProfileStore entry vẫn song hành làm bridge — VM chưa migrate).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. BRIDGE STATE: `Provider<ProfileStore>.value` PHẢI còn trong MultiProvider (VM cũ còn đọc nó — bỏ sớm = ProviderNotFoundException); app chạy trên đường cũ — repo trong scope nhưng chưa ai đọc.

EXPECTED STATE SAU BÀI NÀY:
- `lib/core/app_dependency_scope.dart`: `AppDependencyScope` ctor nhận `userProfileRepository` (kiểu `UserProfileRepository`) + `userSettingsRepository` (`UserSettingsRepository`) + `onboardingRepository` (`OnboardingRepository`) + `profileStore` (`ProfileStore`, tạm) (STRICT ba field kiểu CONTRACT — không phải Impl); `build` trả `MultiProvider(providers: [Provider<UserProfileRepository>.value(...), Provider<UserSettingsRepository>.value(...), Provider<OnboardingRepository>.value(...), Provider<ProfileStore>.value(...)], child: child)` (STRICT đăng ký theo contract + entry ProfileStore bridge; `.value` không `create:`).
- `lib/main.dart`: `await UserProfileRepositoryImpl.create()` + `await UserSettingsRepositoryImpl.create()` + `await OnboardingRepositoryImpl.create()` (STRICT ×3); `await userSettingsRepository.loadUserSettings();` trước runApp (STRICT — settings sẵn sàng trước frame đầu; KHÔNG gọi `loadUserProfile` ở đây — VM lo); truyền đủ 4 dep vào `AppDependencyScope` kể cả `profileStore`.
- `test/helpers/fake_user_profile_repository.dart` + `fake_user_settings_repository.dart` + `fake_onboarding_repository.dart` tồn tại (STRICT 3 file): `implements` contract tương ứng, `BehaviorSubject.seeded(initial/defaults)` in-memory, KHÔNG SharedPreferences; profile fake có `saveCallCount`/`loadCallCount` + `value` getter; `dispose()` → `_subject.close()`.
- `test/menu_provider_scope_test.dart` (và mọi test dựng `AppDependencyScope`/`scopedMenu`) đã cập nhật ctor: truyền ba fake + `ProfileStore()` (STRICT compile trước migrate).
- `flutter analyze` + `flutter test` xanh; `flutter run` menu y hệt (repo sẵn trong scope, chưa ai đọc — đúng).
- KHÔNG có `Provider<...Impl>` trong scope (đăng ký theo impl = bad direction); KHÔNG có dòng debug `context.read<UserProfileRepository>()...` sót lại trong `menu_screen.dart`.

INVARIANTS NỀN:
- Ba repo contract+impl bài 4–5; `UserSettingsData`/`UserProfileData` parity bài 5; `ChangeNotifierProvider<MenuViewModel>` vẫn tạo VM từ `context.read<ProfileStore>()` (chưa đổi — bài 7 mới đổi); event bridge M13; game M09.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (VM đã migrate sang repo/ProfileStore đã xoá) → `AHEAD_COMPATIBLE` hoặc đã qua bài 7 (xác nhận trong COURSE_POSITION); thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m14/06
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
