---
title: "Bài 1 · Vì sao ProfileStore chưa đủ — repository contract"
description: "Storage primitive vs ranh giới ứng dụng; abstract interface class và implements lần đầu xuất hiện; contract-first cho phép fake."
sidebar:
  label: "Bài 1 · Vì sao ProfileStore chưa đủ"
  order: 1
---

## Mục tiêu

Hiểu vì sao `ProfileStore` — một class storage concrete — không phải
là ranh giới lâu dài của app này, và tự viết **contract** repository
đầu tiên bằng `abstract interface class` + `implements`.

## Bạn đang ở đâu

- Milestone: **M14** (bài 1/4)
- App hiện tại (cuối M13): `MenuViewModel` giữ `ProfileStore` concrete,
  gọi `load()`/`save()`/`reset()` tay, tự quản `MenuLoadState`
  loading/ready/failed.

## Vì sao việc này quan trọng ngay bây giờ

`ProfileStore` làm đúng việc của nó: một key, JSON encode/decode, ba
hàm đọc-ghi. Nhưng nó chỉ là **primitive lưu trữ** — "làm sao để ghi
vào đĩa". Project senior cần thêm một ranh giới khác: **repository**
— "ai được phép đọc/ghi profile, và ai đang nghe khi nó đổi".

Hai vấn đề cụ thể với bản concrete:

1. **VM biết quá nhiều.** `MenuViewModel` ôm trực tiếp
   `ProfileStore` — nghĩa là nó biết tồn tại SharedPreferences, JSON,
   key `'user_profile'`. Muốn test VM mà không chạm prefs? Phải
   `extends ProfileStore` và override hàm — hacky và dễ vỡ.
2. **Dữ liệu đứng yên.** `load()` trả về một snapshot; nếu sau này
   một nơi khác ghi profile (ví dụ sync từ server — senior có), VM
   không hề biết. Ai muốn dữ liệu mới phải tự hỏi lại.

Trong project senior này, ranh giới repository tồn tại vì có nhiều
*impl* cùng tồn tại: impl thật đọc/ghi SharedPreferences, impl fake
cho test, và các bản remote/sync sau này. VM chỉ được phép biết
**contract** — phần "việc gì có thể làm", không phải "làm thế nào".

> Đây là cách *project này* chia ranh giới — repository pattern trong
> Android (interface `XxxRepository` + `XxxRepositoryImpl` inject qua
> Hilt) chính là cùng một ý tưởng. Không phải mọi app Flutter đều
> bắt buộc pattern này — nhưng app senior mà course này dựng lại thì
> dùng nó, và ta học đúng lý do của nó.

## Bạn đã biết gì

- `class`, `abstract class`, method, getter (M02–M04).
- `Future`/`async`/`await` (M05) — mọi hàm repo đều async.
- `SharedPreferences` + `jsonEncode`/`jsonDecode` (M10) — phần impl
  giữ nguyên, chỉ đổi chủ sở hữu.
- Repository pattern từ Android — khái niệm quen; cú pháp Dart là
  phần mới.

## Dart mới: `abstract interface class`

Dart 3 phân biệt rõ "interface" bằng modifier `interface`:

```dart
abstract interface class UserProfileRepository {
  ValueStream<UserProfileData> get userProfileStream;
  Future<UserProfileData> loadUserProfile();
  Future<void> saveUserProfile(UserProfileData userData);
  Future<void> resetUserProfile();
  Future<void> dispose();
}
```

- `abstract interface class` = class chỉ mang **chữ ký** — không
  thân hàm, không constructor. Ai `implements` nó phải cung cấp đúng
  các member này (compiler kiểm tra).
- `implements` (khác `extends`): class impl **không thừa hưởng code**
  — nó cam kết "tôi có đủ các member contract hứa". Một class có thể
  `implements` nhiều interface.
- Khác `abstract class` thường: `abstract class` có thể chứa code sẵn
  cho `extends`; `interface` thuần chữ ký — đúng nghĩa "hợp đồng".

Cùng file đó chứa luôn impl — convention của senior:

```dart
class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl._(this._preferences)
    : _userProfileSubject = BehaviorSubject<UserProfileData>.seeded(
        const UserProfileData(),
      );

  static Future<UserProfileRepositoryImpl> create() async {
    final preferences = await SharedPreferences.getInstance();
    return UserProfileRepositoryImpl._(preferences);
  }
  // ...
}
```

Hai chi tiết cần chú ý:

- **Constructor private `._`**: bên ngoài file không gọi `Impl._(…)`
  được — mọi construction đi qua `create()`.
- **`static Future create()`**: `SharedPreferences.getInstance()` là
  `Future` — constructor không `await` được, nên việc khởi tạo async
  gói trong factory static trả `Future<Impl>`. `main()` sẽ
  `await UserProfileRepositoryImpl.create()`.

## Impl SharedPreferences — hấp thụ ProfileStore

Toàn bộ logic `ProfileStore` chuyển nguyên vào
`UserProfileRepositoryImpl`: cùng key `'user_profile'`, cùng JSON
codec, cùng ba nhánh fallback về `const UserProfileData()` khi key
vắng / JSON hỏng / không phải Map. Khác duy nhất: kết quả không trả
thẳng về mà đi **qua subject** để emit (bài 2 mở nó).

```dart
Future<UserProfileData> loadUserProfile() async {
  final encodedProfile = _preferences.getString(_profileKey);
  if (encodedProfile == null) {
    return _emitUserProfile(const UserProfileData());
  }
  try {
    final decodedProfile = jsonDecode(encodedProfile);
    if (decodedProfile is Map) {
      return _emitUserProfile(
        UserProfileData.fromMap(Map<String, Object?>.from(decodedProfile)),
      );
    }
  } on FormatException {
    return _emitUserProfile(const UserProfileData());
  }
  return _emitUserProfile(const UserProfileData());
}
```

## Xoá file cũ — làm tường minh

Bài này **xoá `lib/data/profile/profile_store.dart`** (và
`test/profile_store_test.dart`, thay bằng `user_profile_repository_
test.dart` ở bài 3). Không giữ lại "phòng khi": mọi call site đã chuyển
sang repo, giữ file chết chỉ nuôi nhầm lẫn. Đây là quy tắc của course —
file bị thay thế phải được xoá tường minh, không biến mất âm thầm.

`reset` cũng đổi tên chuẩn senior: `resetUserProfile() =>
saveUserProfile(const UserProfileData())` — reset vẫn là *ghi đè
mặc định*, không xoá key (đã sửa từ remediation; M14 giữ nguyên).

## Contract-first mở ra fake

Bài test ở sau sẽ thấy: vì VM phụ thuộc `UserProfileRepository`
(contract), test tự viết `FakeUserProfileRepository implements
UserProfileRepository` — chủ đề bài 3.

## Tự kiểm tra

1. `abstract interface class` khác `abstract class` chỗ nào? —
   *Interface thuần chữ ký, không thân hàm/ctor; impl `implements`
   không thừa hưởng code mà cam kết đủ member.*
2. Vì sao `create()` là `static Future` thay vì constructor thường? —
   *`SharedPreferences.getInstance()` là Future; ctor không await
   được nên construction async gói trong factory.*
3. VM nên giữ kiểu `UserProfileRepository` hay
   `UserProfileRepositoryImpl`? — *Contract: VM cần "việc gì làm
   được", không cần biết prefs/JSON — và test mới thay fake được.*

## Ta cố ý chưa thêm

- **Nội dung subject/stream** trong `loadUserProfile` — `_emitUserProfile`
  và `BehaviorSubject` là bài 2.
- **Hai repo còn lại** (settings, onboarding) — bài 3.
- **Mock framework** — không cần; fake viết tay (bài 3).

## Checkpoint hoàn thành

- [ ] `lib/repositories/profile/user_profile_repository.dart` tồn tại
      với `abstract interface class UserProfileRepository` +
      `UserProfileRepositoryImpl` trong cùng file.
- [ ] `lib/data/profile/profile_store.dart` đã bị **xoá**;
      `test/profile_store_test.dart` đã bị xoá.
- [ ] `flutter analyze` sạch sau khi xoá (không còn import mồ côi).
- [ ] Giải thích được: vì sao "storage" và "repository" là hai khái
      niệm khác nhau trong app này.
