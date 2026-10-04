---
title: "Bài 5 · Hai repo còn lại + UserSettingsData + UserProfileData parity"
description: "Lặp lại pattern repository cho settings và onboarding (nhận diện, không học mới); UserSettingsData 7 field senior; UserProfileData đạt field set senior với parse phòng thủ đầy đủ."
sidebar:
  label: "Bài 5 · Hai repo còn lại + model parity"
  order: 5
---

## Mục tiêu

- **Nhận diện** (không học mới) pattern repository qua hai repo còn
  lại: `UserSettingsRepository` và `OnboardingRepository`.
- Thêm `UserSettingsData` — model settings 7 field đúng senior.
- Nâng `UserProfileData` lên field set senior:
  `totalEarnings`, `totalQuestionCount`, parse phòng thủ đầy đủ.

Bài này cố tình *ít lý thuyết*: contract/subject/guard đã học — giờ
là lúc thấy pattern lặp lại y hệt. Nếu bạn phải đọc kỹ lại từng
guard, quay lại bài 3–4; đó là tín hiệu bài này đúng chỗ.

## Bạn đang ở đâu

- Milestone: **M14** (bài 5/7).
- `UserProfileRepository` + impl đã xong. Ba repo app-level của
  senior còn hai; model `UserProfileData` còn thiếu field.

## Ba repository của app — nhìn trước

| Repo | Stream | Seed | Key prefs | Consumer thật |
| ------ | -------- | ------ | ----------- | --------------- |
| `UserProfileRepository` | `ValueStream<UserProfileData>` | `const UserProfileData()` | `user_profile` | menu VM (bài 7) |
| `UserSettingsRepository` | `ValueStream<UserSettingsData>` | `const UserSettingsData()` | `user_settings` | settings dialog — M16 |
| `OnboardingRepository` | `ValueStream<bool>` | `false` | `onboarding_completed` | onboarding gate — M18 |

Settings và onboarding **chưa có consumer** — đó là chủ đích của
roadmap ("repo tồn tại, dùng ở M16/M18"), không phải code thừa:
ranh giới được dựng một lần đúng shape thay vì vá dần sau.

## Từng bước

### Bước 1 — `UserSettingsData` (model mới)

Tạo `lib/data/settings/user_settings_data.dart` — 7 field y hệt
senior: `soundEnabled`, `musicEnabled`, `hapticEnabled`,
`notificationEnabled`, `notificationHour`, `notificationMinute`,
`languageCode`. Cấu trúc giống `UserProfileData` (M04): final fields,
`copyWith`, `toMap`, `fromMap`, `==`/`hashCode`.

Hai chi tiết parse cần biết thay vì gõ mò:

```dart
hapticEnabled: map['hapticEnabled'] is bool
    ? map['hapticEnabled'] == true
    : true,
```

`hapticEnabled` vắng/sai kiểu → `true` — senior mặc định **bật**
haptic, khác mọi bool khác (vắng → `false`). Và giờ/phút bị kẹp
`_boundedInt(value, 0, 23/59)` — `notificationHour = 99` trên disk
không được phép vào model.

> `languageCode` giờ chỉ guard non-empty. Senior whitelist nó qua
> `SupportedLanguageData` — bộ từ vựng localization đó đến M17
> (đơn giản hoá tạm — guard non-empty đủ cho M14).

### Bước 2 — `UserSettingsRepository` + impl

`lib/repositories/settings/user_settings_repository.dart` — **cùng
file** chứa contract + impl, y hệt shape profile repo:

```dart
abstract interface class UserSettingsRepository {
  ValueStream<UserSettingsData> get userSettingsStream;
  Future<UserSettingsData> loadUserSettings();
  Future<void> saveUserSettings(UserSettingsData settings);
  Future<void> dispose();
}
```

Impl: `_settingsKey = 'user_settings'`, ctor `._` + `static create()`,
`BehaviorSubject<UserSettingsData>.seeded(const UserSettingsData())`,
`_emitSettings` với hai guard giống hệt `_emitUserProfile`. Gõ ra từ
trí nhớ của bài 4 — nếu phải nhìn lại mỗi dòng thì đó là tín hiệu
bài 4 chưa thấm.

### Bước 3 — `OnboardingRepository` + impl

`lib/repositories/onboarding/onboarding_repository.dart` — repo nhỏ
nhất: `ValueStream<bool>`, seed `false`, key `'onboarding_completed'`,
`prefs.getBool`/`setBool` (không JSON — chỉ một bool). Member:
`onboardingCompletedStream`, `loadOnboardingCompleted()`,
`setOnboardingCompleted()`, `dispose()`.

Đây là repo đầu tiên kiểu `ValueStream<bool>` — nhìn kỹ để thấy
stream state không chỉ dành cho "model lớn": một cờ đơn giản cũng đi
qua cùng một boundary.

### Bước 4 — `UserProfileData` đạt field set senior

Hai field mới — và chúng là *field lưu trữ*, không phải getter tính:

```dart
final String totalEarnings;      // '0 VNĐ' — chuỗi ĐÃ FORMAT
final int totalQuestionCount;    // tổng câu đã trả lời
```

- Senior lưu `totalEarnings` là String đã format sẵn —
  `applyGameResult` ghi `formatVnd(nextMoneyWon)`. Getter
  `totalEarningsDisplay` của M04 **sẽ retire ở bài 7** khi UI chuyển
  sang đọc `profile.totalEarnings` — bài này chỉ *thêm* field, chưa
  xoá getter (UI còn đang đọc nó).
- `applyGameResult` giờ ghi cả hai: `totalEarnings: formatVnd(...)`,
  `totalQuestionCount: + result.questionsAnswered`.
- `expForNextLevel` vẫn ở lại — `LevelConfig` của senior tính nó ở M22.

`fromMap` nâng lên đúng độ sâu senior:

- `_stringValue`: chỉ nhận chuỗi **non-empty** sau trim.
- `_intValue`: chỉ nhận `int` **≥ 0** — counter không được âm.
- `_nullableStringValue`: `avatarUrl` không fallback — null là giá
  trị hợp lệ.
- `_moneyFromDisplay`: `totalMoneyWon` hỏng thì khôi phục số từ chuỗi
  `totalEarnings` (`'1.000.000 VNĐ'` → `1000000`) — thứ tự parse
  `totalEarnings` *trước* `totalMoneyWon` là của senior.
- `_isLegacyDemoProfile`: bộ giá trị showcase cũ của senior khớp
  nguyên bộ → trả defaults.

`toMap` học chiêu Dart 3.8 — **null-aware element**:

```dart
'avatarUrl': ?avatarUrl,
```

`?avatarUrl` = "chỉ ghi key này nếu non-null" — `avatarUrl` null thì
key **vắng hẳn** khỏi JSON, không phải `"avatarUrl": null`.

### Bước 5 — test hai repo + model

Ba file test theo cùng mẫu bài 4 (`setMockInitialValues` + `create()`
+ `dispose()`):

- `test/user_settings_repository_test.dart` — persist + emit settings.
- `test/onboarding_repository_test.dart` — `false` mặc định → `true`
  sau `setOnboardingCompleted`.
- Cập nhật `test/user_profile_data_test.dart` — `totalEarnings`/
  `totalQuestionCount` qua `applyGameResult`; `fromMap` với int âm,
  string rỗng, `?avatarUrl` key-vắng.

## Chạy và quan sát

```bash
flutter test
flutter analyze
```

Toàn bộ test phải xanh; app vẫn chạy trên `ProfileStore` (chưa nối).
`flutter run` xác nhận menu đổi ở chỗ duy nhất bạn có thể thấy:
`applyGameResult` giờ cũng cộng `totalQuestionCount` — nhưng UI chưa
đọc field mới, nên *về mắt* mọi thứ y hệt.

## Lỗi hay gặp

- **Copy nhầm `_profileKey`/`'user_profile'`** sang settings repo —
  ba key phải khác nhau, trùng key = hai repo đọc-ghi cùng ô nhớ.
- **`hapticEnabled` vắng → `false`** — sai senior: haptic mặc định
  bật; guard `is bool ? == true : true`.
- **Quên `?` trong `'avatarUrl': ?avatarUrl`** — ghi `null` xuống
  disk làm `fromMap` và JSON khác shape senior.
- **Xoá `totalEarningsDisplay` ở bài này** — UI còn dùng tới bài 7;
  xoá sớm làm analyze đỏ.

## Tự làm

**Nhận diện pattern — viết mà không copy.** Không nhìn file settings
repo, tự viết `OnboardingRepository` + impl từ đầu (đây là repo nhỏ
nhất — `bool`, một key, không JSON). So với bản bạn vừa viết ở Bước 3:

- Member contract nào bạn bỏ sót?
- Guard `_emitCompleted` có đủ hai điều kiện chưa?

Nếu bạn viết được file này mà không nhìn bài 4 — pattern repository
đã thấm; đó là điều kiện chuyển qua bài 6.

## Tự kiểm tra

1. Vì sao `totalEarnings` là field chứ không phải getter tính từ
   `totalMoneyWon`? — *Senior lưu chuỗi đã format làm field; `fromMap`
   còn dùng nó khôi phục `totalMoneyWon` khi key int hỏng.*
2. `?avatarUrl` khác `avatarUrl` trong map literal thế nào? —
   *Null-aware element bỏ key hẳn khi null; cách cũ ghi `null` lên
   disk.*
3. Vì sao settings/onboarding repo tồn tại mà chưa có consumer? —
   *Roadmap: ranh giới dựng một lần đúng shape; consumer đến M16/M18.*

## Ta cố ý chưa thêm

- **Settings/onboarding UI** — M16/M18; repo chỉ là nền.
- **Whitelist `SupportedLanguageData`** — M17.
- **Repo leaderboard/auth/sync** của senior — gắn milestone sau
  (M21–M24).

## Checkpoint hoàn thành

- [ ] `lib/repositories/settings/` + `lib/repositories/onboarding/`
      chứa contract + impl đúng shape profile repo.
- [ ] `user_settings_data.dart` đủ 7 field; `hapticEnabled` vắng →
      `true`; hour/minute bị kẹp khoảng.
- [ ] `UserProfileData` có `totalEarnings`/`totalQuestionCount`;
      `toMap` dùng `?avatarUrl`; `fromMap` đủ guard +
      `_moneyFromDisplay` + `_isLegacyDemoProfile`.
- [ ] `flutter test` + `flutter analyze` xanh; `totalEarningsDisplay`
      **vẫn còn** (retire ở bài 7).
