---
title: "Bài 4 · UserProfileRepositoryImpl: SharedPreferences + subject"
description: "Impl đầu tiên của contract: ctor private + create(), BehaviorSubject.seeded, _emitUserProfile guard, load/save/reset/dispose — và test repo độc lập với app."
sidebar:
  label: "Bài 4 · Impl profile repository"
  order: 4
---

## Mục tiêu

- Viết `UserProfileRepositoryImpl` vào cùng file contract — hấp thụ
  toàn bộ logic `ProfileStore` vào shape mới.
- Hiểu *từng dòng* của emit-path: vì sao kết quả đi "qua subject"
  chứ không trả thẳng.
- Chứng minh impl hoạt động bằng **repo test riêng** — trước cả khi
  app dùng nó.

## Bạn đang ở đâu

- Milestone: **M14** (bài 4/7).
- Contract (bài 2) + stream-state (bài 3) đã xong. Bài này chỉ *thêm*
  impl — **app vẫn chạy `ProfileStore`**, VM chưa biết repo tồn tại.
  Đó là trình tự cố ý: chứng minh impl đúng trước, nối dây sau.

## Bạn đã biết gì

- `SharedPreferences` + `jsonEncode`/`jsonDecode` (M10) — logic
  `ProfileStore` chuyển nguyên sang, chỉ đổi chủ sở hữu.
- `implements`/`@override` (bài 2); `BehaviorSubject`/`ValueStream`/
  `.value`/`isClosed`/`close` (bài 3).
- `setMockInitialValues` cho prefs test (M10).

## Từng bước

### Bước 1 — class impl + ctor private + `create()`

Trong `user_profile_repository.dart`, **dưới contract**:

```dart
class UserProfileRepositoryImpl implements UserProfileRepository {
  static const _profileKey = 'user_profile';   // CÙNG key ProfileStore

  final SharedPreferences _preferences;
  final BehaviorSubject<UserProfileData> _userProfileSubject;

  UserProfileRepositoryImpl._(this._preferences)
    : _userProfileSubject = BehaviorSubject<UserProfileData>.seeded(
        const UserProfileData(),
      );

  static Future<UserProfileRepositoryImpl> create() async {
    final preferences = await SharedPreferences.getInstance();
    return UserProfileRepositoryImpl._(preferences);
  }
}
```

Cần thêm `import 'package:shared_preferences/shared_preferences.dart';`
và `import 'dart:convert';` đầu file.

Đọc kỹ: subject được **seed `const UserProfileData()`** — profile
mặc định — nên stream *luôn* có giá trị từ giây đầu. Đây là dòng
code giết `MenuLoadState` ở bài 7: không còn khoảng "chưa có dữ
liệu".

### Bước 2 — getter stream + emit guard

```dart
  @override
  ValueStream<UserProfileData> get userProfileStream =>
      _userProfileSubject.stream;

  UserProfileData _emitUserProfile(UserProfileData userData) {
    if (!_userProfileSubject.isClosed &&
        _userProfileSubject.value != userData) {
      _userProfileSubject.add(userData);
    }
    return userData;
  }
```

- `_subject.stream` trả `ValueStream` — caller chỉ đọc/listen.
- Hai guard đều cần: `isClosed` chặn crash khi emit đến sau dispose;
  `value != userData` chặn event thừa cho một "đổi" không đổi
  (nhờ `==`/`hashCode` đầy đủ của model M04 — so *giá trị*).
- Hàm `return userData` dù emit hay không — `loadUserProfile` cần trả
  profile về bất kể emit.

### Bước 3 — load/save/reset/dispose

```dart
  @override
  Future<UserProfileData> loadUserProfile() async {
    final encodedProfile = _preferences.getString(_profileKey);
    if (encodedProfile == null) {
      return _emitUserProfile(const UserProfileData());
    }
    try {
      final decodedProfile = jsonDecode(encodedProfile);
      if (decodedProfile is Map) {
        return _emitUserProfile(
          UserProfileData.fromMap(
            Map<String, Object?>.from(decodedProfile),
          ),
        );
      }
    } on FormatException {
      return _emitUserProfile(const UserProfileData());
    }
    return _emitUserProfile(const UserProfileData());
  }

  @override
  Future<void> saveUserProfile(UserProfileData userData) async {
    final didSave = await _preferences.setString(
      _profileKey,
      jsonEncode(userData.toMap()),
    );
    if (!didSave) {
      throw StateError('Failed to save user profile.');
    }
    _emitUserProfile(userData);
  }

  @override
  Future<void> resetUserProfile() =>
      saveUserProfile(const UserProfileData());

  @override
  Future<void> dispose() => _userProfileSubject.close();
```

So với `ProfileStore.load()` (M10): cùng key, cùng JSON codec, cùng
ba nhánh fallback — **khác duy nhất**: kết quả đi qua
`_emitUserProfile` để vừa trả về vừa phát lên stream. `save` ghi disk
*trước*, emit *sau* — ghi thất bại thì throw, không emit giá trị
chưa tồn tại trên disk. `reset` = ghi defaults đè key (semantics
senior — không `prefs.remove`).

### Bước 4 — test repo độc lập

`test/user_profile_repository_test.dart` — chứng minh disk + stream
mà không cần chạy app:

```dart
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('load emits defaults onto empty prefs', () async {
    final repo = await UserProfileRepositoryImpl.create();
    final profile = await repo.loadUserProfile();
    expect(profile, const UserProfileData());
    expect(repo.userProfileStream.value, const UserProfileData());
    await repo.dispose();
  });

  test('save persists + emits — late listener still sees it', () async {
    final repo = await UserProfileRepositoryImpl.create();
    await repo.saveUserProfile(
      const UserProfileData(username: 'Lan'),
    );

    final seen = <UserProfileData>[];
    repo.userProfileStream.listen(seen.add);   // subscribe MUỘN
    await pumpEventQueue();
    expect(seen.single.username, 'Lan');       // replay — bài 3 đã hứa
    await repo.dispose();
  });
}
```

`pumpEventQueue()` (của `flutter_test`) flush hết event/microtask đang
chờ — `subject.add` đưa event vào queue, listener nhận ở microtask kế;
test phải flush queue trước khi assert. Bạn sẽ gặp lại nó ở bài 7.

## Chạy và quan sát

```bash
flutter test test/user_profile_repository_test.dart
flutter analyze
```

Test xanh = impl đã đúng *trước khi app dùng nó*. App chạy vẫn y hệt
(vẫn `ProfileStore`) — kiểm chứng bằng `flutter run`: menu hiển thị
như cũ. Đây là "viết → chứng minh → mới nối dây".

## Lỗi hay gặp

- **`Missing concrete implementation`** — impl thiếu member contract
  (bài 2 đã nói): analyzer chỉ ngay dòng class.
- **Gọi `UserProfileRepositoryImpl(...)` không `._`** — ctor public
  không tồn tại; chỉ `await create()`.
- **Test không `dispose()`** — subject sống sót qua test → test
  group có thể treo. Repo test nên `await repo.dispose()` cuối ca.
- **Emit trước khi save thành công** — thứ tự `await setString` rồi
  mới `_emit` là có chủ đích: đảo thứ tự phát state chưa persist.

## Tự làm

**Tự viết — không copy.** Viết thêm một test trong
`user_profile_repository_test.dart`:

- `load` khi prefs chứa JSON **corrupt** (`setString('user_profile',
  '{bad')` trực tiếp lên prefs) — profile trả về là gì? Stream nhận
  emit nào? (Nhớ `fromMap` phòng thủ của M14/bài 5 — nếu bạn chưa
  qua bài 5, dự đoán theo `ProfileStore` M10.)

<details><summary><strong>Đáp án</strong></summary>

`jsonDecode` ném `FormatException` → nhánh `on` trả
`_emitUserProfile(const UserProfileData())` → `load` trả defaults,
stream `.value` = defaults, không crash. Test:

```dart
test('load survives corrupt json', () async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_profile', '{bad');
  final repo = await UserProfileRepositoryImpl.create();
  expect(await repo.loadUserProfile(), const UserProfileData());
  await repo.dispose();
});
```

</details>

## Tự kiểm tra

1. Vì sao `save` emit *sau* `await setString`? — *Stream phải phản
   ánh disk; emit trước khi ghi thành công phát state không thật.*
2. `_emitUserProfile` guard `value !=` để làm gì? — *Chặn event thừa
   khi giá trị không đổi — nhờ `==` của model nên đây là so giá trị.*
3. Vì sao subject seed `const UserProfileData()`? — *Stream luôn có
   giá trị → không còn "khoảng chưa có dữ liệu" — nền cho retire
   `MenuLoadState` ở bài 7.*

## Ta cố ý chưa làm

- **Chưa nối VM/Provider** — repo tồn tại nhưng chưa ai trong app
  gọi; việc đó ở bài 6–7.
- **Chưa xoá `ProfileStore`** — VM còn đang dùng nó.

## Checkpoint hoàn thành

- [ ] `UserProfileRepositoryImpl` đủ 5 member contract trong cùng
      file; ctor `._` private, `create()` await prefs.
- [ ] `flutter test test/user_profile_repository_test.dart` xanh —
      gồm ca late-listener replay.
- [ ] `flutter analyze` sạch; `flutter run` vẫn hiển thị menu cũ
      (app chưa chuyển — đúng trình tự).
