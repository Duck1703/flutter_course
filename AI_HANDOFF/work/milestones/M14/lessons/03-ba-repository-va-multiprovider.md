---
title: "Bài 3 · Ba repository & MultiProvider"
description: "UserSettingsRepository + OnboardingRepository, AppDependencyScope thành MultiProvider đăng ký theo contract, bootstrap create()/loadUserSettings(), UserProfileData đạt field set senior, fake repository cho test."
sidebar:
  label: "Bài 3 · Ba repository & MultiProvider"
  order: 3
---

## Mục tiêu

Dựng nốt hai repo còn lại, nâng `AppDependencyScope` lên
`MultiProvider` đúng cơ chế senior, nâng `UserProfileData` lên đủ
field set senior — và gặp `FakeUserProfileRepository`, thu hoạch đầu
tiên của contract-first.

## Bạn đang ở đâu

- Milestone: **M14** (bài 3/4)
- `UserProfileRepository` + impl đã có (bài 1–2); scope hiện chỉ
  chứa một `Provider<ProfileStore>` sắp retire.

## Ba repository của app

Senior đặt ba repo app-level; learner có đủ cả ba trong M14 — mỗi cái
một file chứa contract + impl, cùng shape:

| Repo | Stream | Seed | Key prefs | Consumer thật |
|------|--------|------|-----------|---------------|
| `UserProfileRepository` | `ValueStream<UserProfileData>` | `const UserProfileData()` | `user_profile` | menu VM (bài 4) |
| `UserSettingsRepository` | `ValueStream<UserSettingsData>` | `const UserSettingsData()` | `user_settings` | settings dialog — M16 |
| `OnboardingRepository` | `ValueStream<bool>` | `false` | `onboarding_completed` | onboarding gate — M18 |

Settings và onboarding repo **chưa có consumer** — đó là chủ đích của
roadmap ("repo tồn tại, dùng ở M16/M18"), không phải code thừa: ranh
giới được dựng một lần đúng shape thay vì vá dần sau.

`UserSettingsData` mới nằm ở `lib/data/settings/user_settings_data.dart`
— 7 field y hệt senior: `soundEnabled`, `musicEnabled`, `hapticEnabled`,
`notificationEnabled`, `notificationHour`, `notificationMinute`,
`languageCode`. Một chi tiết parse cần biết: `hapticEnabled` vắng/sai
kiểu → `true` (senior mặc định bật haptic — không phải `false` như
mọi bool khác).

> `languageCode` giờ chỉ guard non-empty. Senior whitelist nó qua
> `SupportedLanguageData` — bộ từ vựng localization đó đến ở M17
> (register FR-26 — simplification tạm, được đăng ký đúng quy tắc).

## `MultiProvider` — nhiều entry, đăng ký theo CONTRACT

Scope app không còn là một `Provider<ProfileStore>.value` đơn lẻ:

```dart
return MultiProvider(
  providers: [
    Provider<UserProfileRepository>.value(value: userProfileRepository),
    Provider<UserSettingsRepository>.value(value: userSettingsRepository),
    Provider<OnboardingRepository>.value(value: onboardingRepository),
  ],
  child: child,
);
```

- `MultiProvider` chỉ là shortcut của provider bọc các provider lồng
  nhau trong một widget — thay vì viết ba tầng `Provider.value`.
- **Điểm mấu chốt:** đăng ký `Provider<UserProfileRepository>` theo
  kiểu *interface*, không phải `Provider<UserProfileRepositoryImpl>`.
  Widget tra `context.read<UserProfileRepository>()` — nó nhận bất kỳ
  impl nào đang ngồi dưới (thật trong app, fake trong test). Đây là
  cơ chế `AppDependencyScope` của senior (senior có 8 entry; ta có
  đúng 3 repo đang tồn tại).
- `Provider.value` vẫn không dispose — `main()` sở hữu repo suốt đời
  app.

## `main()` — bootstrap đúng shape senior

```dart
final userProfileRepository = await UserProfileRepositoryImpl.create();
final userSettingsRepository = await UserSettingsRepositoryImpl.create();
final onboardingRepository = await OnboardingRepositoryImpl.create();
await userSettingsRepository.loadUserSettings();
runApp(AppDependencyScope(...));
```

- Ba `await create()` vì `SharedPreferences.getInstance()` là Future.
- `loadUserSettings()` chạy **trước** `runApp` — senior làm vậy để
  state settings thật sẵn sàng trước frame đầu (ở app senior, settings
  lái cả locale). Profile **không** load ở đây: menu VM gọi
  `..loadUserProfile()` khi được tạo (bài 4). Onboarding không ai load
  ở main — gate M18 sẽ lo.

## `UserProfileData` đạt field set senior (FR-19)

Hai field mới — và chúng là *field lưu trữ*, không phải getter tính
toán:

```dart
final String totalEarnings;      // '0 VNĐ' — chuỗi ĐÃ FORMAT
final int totalQuestionCount;    // tổng câu đã trả lời
```

- Senior lưu `totalEarnings` là String đã format sẵn — `applyGameResult`
  ghi `formatVnd(nextMoneyWon)`. Getter `totalEarningsDisplay` của M04
  **retire**: UI đọc `profile.totalEarnings` trực tiếp.
- `applyGameResult` giờ ghi cả hai: `totalEarnings: formatVnd(...)`,
  `totalQuestionCount: + result.questionsAnswered`.
- `expForNextLevel` vẫn ở lại — register FR-01, retire M22 khi
  `LevelConfig` đến.

`fromMap` được nâng lên đúng độ sâu senior:

- `_stringValue`: chỉ nhận chuỗi **non-empty** sau trim — `''` trên
  disk nghĩa là "không có dữ liệu".
- `_intValue`: chỉ nhận `int` **≥ 0** — counter không được âm.
- `_nullableStringValue`: field nullable (avatarUrl) không có fallback
  — null là giá trị hợp lệ.
- `_moneyFromDisplay`: nếu `totalMoneyWon` hỏng, khôi phục số từ chuỗi
  `totalEarnings` (`'1.000.000 VNĐ'` → `1000000`).
- `_isLegacyDemoProfile`: bộ giá trị showcase cũ của senior (username
  `'TÀU HỦ ĐI CHILL'`…) khớp nguyên bộ → trả về defaults.

`toMap` cũng học chiêu mới của Dart 3.8 — **null-aware element**:

```dart
'avatarUrl': ?avatarUrl,
```

`?avatarUrl` = "chỉ ghi key này nếu giá trị non-null" — `avatarUrl`
null thì key **vắng hẳn** khỏi JSON, không phải `"avatarUrl": null`.
Đây là semantics senior.

## `FakeUserProfileRepository` — contract trả nợ

Vì VM phụ thuộc contract, test `implements` nó bằng một subject
in-memory — không SharedPreferences, không mock framework:

```dart
class FakeUserProfileRepository implements UserProfileRepository {
  final BehaviorSubject<UserProfileData> _subject;
  var saveCallCount = 0;

  FakeUserProfileRepository({
    UserProfileData initialProfile = const UserProfileData(),
  }) : _subject = BehaviorSubject<UserProfileData>.seeded(initialProfile);

  @override
  ValueStream<UserProfileData> get userProfileStream => _subject.stream;

  @override
  Future<void> saveUserProfile(UserProfileData userData) async {
    saveCallCount++;
    _subject.add(userData);
  }
  // ...loadUserProfile/resetUserProfile/dispose tương tự
}
```

- Nằm ở `test/helpers/` — đúng nơi senior để fake (`test/widgets/
  game_screen_test_helpers.dart` có `FakeGameProfileRepository`
  cùng pattern, kèm `saveCallCount` đếm số lần save).
- VM test giờ không cần prefs mock: `MenuViewModel(userProfileRepository:
  FakeUserProfileRepository(initialProfile: ...))`.
- Impl thật vẫn được test riêng bằng `setMockInitialValues` +
  `create()` — hai lớp test hai mục đích: repo test chứng minh disk +
  stream; VM test chứng minh VM nghe repo đúng.

## Tự kiểm tra

1. Vì sao `Provider<UserProfileRepository>.value` chứ không phải
   `Provider<UserProfileRepositoryImpl>`? — *Đăng ký theo contract:
   consumer chỉ biết interface; test đặt fake vào cùng slot mà không
   sửa cây widget.*
2. Vì sao `loadUserSettings()` ở `main()` mà `loadUserProfile()` lại
   ở VM? — *Senior cần settings (locale) trước frame đầu; profile gắn
   với màn menu nên VM menu lo — phân chia trách nhiệm của senior.*
3. `'avatarUrl': ?avatarUrl` khác `'avatarUrl': avatarUrl` thế nào? —
   *Null-aware element bỏ key hẳn khi null; cách cũ ghi `null` xuống
   disk.*
4. Vì sao `totalEarnings` là field String thay vì getter tính từ
   `totalMoneyWon`? — *Senior lưu chuỗi đã format như một field — và
   `fromMap` còn dùng nó để khôi phục `totalMoneyWon` khi key int hỏng.*

## Ta cố ý chưa thêm

- **Settings/onboarding UI** — M16/M18; repo chỉ là nền.
- **Whitelist `SupportedLanguageData`** cho `languageCode` — M17
  (FR-26).
- **Repo cho leaderboard/auth/sync** — senior có, nhưng chúng gắn
  milestone sau (M21–M24); M14 chỉ dựng 3 repo roadmap chỉ định.

## Checkpoint hoàn thành

- [ ] `lib/repositories/settings/` + `lib/repositories/onboarding/`
      chứa contract + impl theo đúng shape profile repo.
- [ ] `app_dependency_scope.dart` dùng `MultiProvider`, ba entry đăng
      ký theo kiểu contract.
- [ ] `main()` `await create()` ×3 + `await loadUserSettings()`.
- [ ] `UserProfileData` có `totalEarnings`/`totalQuestionCount`;
      `toMap` dùng `?avatarUrl`; `fromMap` guard non-empty/≥0 +
      `_moneyFromDisplay` + purge demo cũ.
- [ ] `test/helpers/` có ba `Fake*Repository` `implements` contract.
