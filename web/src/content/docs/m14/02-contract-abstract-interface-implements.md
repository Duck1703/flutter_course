---
title: "Bài 2 · Contract trong Dart: abstract interface class, implements, factory create()"
description: "Cú pháp contract Dart 3 — abstract interface class vs abstract class, implements vs extends, static Future create() cho construction async. Ví dụ độc lập CounterRepository, rồi viết contract thật."
sidebar:
  label: "Bài 2 · Contract & factory create()"
  order: 2
---

## Mục tiêu

- Dùng được `abstract interface class` + `implements` — và phân biệt
  với `extends`/`abstract class` thường.
- Hiểu vì sao construction async của repo đi qua `static Future
  create()` (pattern factory).
- **Viết file contract thật** `user_profile_repository.dart` — đây
  là file code đầu tiên của M14; vẫn chưa đụng VM hay `ProfileStore`.

## Bạn đang ở đâu

- Milestone: **M14** (bài 2/7).
- Bài 1 đã dựng mental model; bài này học *cú pháp* để viết contract.
- App vẫn chạy `ProfileStore` — file contract mới chỉ *tồn tại*,
  chưa ai gọi. Mọi thay đổi trong bài này là **additive**: analyze
  sạch trước thì sạch sau.

## Bạn đã biết gì

- `class`, method, getter (M02–M04); `abstract`/`final` class
  modifiers (M13/01 — `abstract class MenuUiEvent`).
- `Future`/`async`/`await` (M05) — mọi hàm repo đều async.
- `factory` constructor (M10/02 — `fromMap`) — bài này dùng lại ý
  tưởng "construction đi qua hàm trả instance" cho trường hợp async.

## Dart mới: `abstract interface class`

Dart 3 có modifier `interface` nói rõ "class này là hợp đồng". So sánh
ba thứ dễ nhầm:

```dart
abstract class A {}            // có thể chứa code sẵn (body, field, ctor)
abstract interface class I {}  // abstract + "file khác chỉ implements được"
class C {}                     // class thường
```

- `abstract interface class` = class abstract (không `new` được) **cộng
  hạn chế kế thừa của `interface`**: từ *file khác*, ai dùng nó chỉ được
  `implements` — không `extends`, không `with`. Body/ctor vẫn *khai
  được* (Dart không cấm), nhưng qua `implements` impl không thừa hưởng
  gì — mọi member phải tự viết lại — nên theo convention contract chỉ
  để chữ ký. Ai `implements` nó phải cung cấp đủ member đã hứa —
  compiler kiểm tra.
- `implements` (khác `extends`): impl **không thừa hưởng gì** — nó cam
  kết "tôi có đủ member contract nói". Một class được `implements`
  nhiều interface cùng lúc; `extends` chỉ một.
- `abstract class` nằm giữa: vừa chứa code chia sẻ cho `extends`, vừa
  có thể có abstract method. Dùng `interface` khi ý đồ là *thuần hợp
  đồng* — đúng việc repository cần.

**Android bridge:** `abstract interface class` ≈ `interface` của Kotlin
(không state, không ctor). `implements` ≈ `: Interface`. Khác biệt
nhỏ: Kotlin `interface` cho property + hàm có body mặc định mà impl
*kế thừa được*; Dart `interface` class khai body được nhưng
`implements` không thừa hưởng — member nào cũng phải viết lại, nên
muốn code chia sẻ phải `abstract class` thường.

### Ví dụ độc lập — đọc trước khi gặp bản project

```dart
// Contract: một "bộ đếm" bất kỳ — không nói nó lưu ở đâu.
abstract interface class CounterRepository {
  Future<int> load();
  Future<void> save(int value);
}

// Một impl lưu trong memory — đủ member contract hứa.
class InMemoryCounterRepository implements CounterRepository {
  int _value = 0;

  @override
  Future<int> load() async => _value;

  @override
  Future<void> save(int value) async => _value = value;
}
```

Đọc kỹ: contract không body, impl `implements` + `@override` từng
member. Nếu thiếu `save`, analyzer báo ngay tại class impl — compiler
là người gác contract, không phải con người nhớ.

## Dart mới: `static Future create()` — factory cho async

`SharedPreferences.getInstance()` trả `Future`. Constructor không
`await` được — initializer list chỉ gán giá trị đã có. Muốn *khởi tạo
async* phải đi đường vòng — đây là lý do senior dùng static factory:

```dart
class PrefsCounterRepository implements CounterRepository {
  PrefsCounterRepository._(this._preferences);   // ctor PRIVATE

  final SharedPreferences _preferences;

  /// Construction async: chờ prefs rồi mới gọi ctor private.
  static Future<PrefsCounterRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return PrefsCounterRepository._(preferences);
  }

  @override
  Future<int> load() async => _preferences.getInt('counter') ?? 0;

  @override
  Future<void> save(int value) async =>
      _preferences.setInt('counter', value);
}
```

Ba chi tiết đều có ý đồ:

- **`._` private ctor**: bên ngoài file không `PrefsCounterRepository._()`
  được — mọi construction *bắt buộc* đi qua `create()`, nên không ai
  vô tình dựng impl mà chưa có prefs.
- **`create()` là `static`**: nó thuộc class chứ không thuộc instance —
  bạn đang *tạo* instance, chưa có instance để gọi method.
- Caller viết `await PrefsCounterRepository.create()` — đây là "async
  factory" của senior (họ cũng có thể dùng `factory` ctor thay `static`,
  nhưng static rõ ràng hơn: `factory` ctor bắt buộc `return` instance
  của class đó; `static create()` đọc như một hàm khởi tạo thường).
  Gọi nhớ lại M10/02: `factory` cho quyền `return` tùy ý — ở đây quyền
  đó được dùng để *await trước khi tồn tại object*.

## Từng bước: viết contract thật

### Bước 1 — thêm package `rxdart`

Contract trả `ValueStream<T>` — kiểu của rxdart, SDK thuần không có:

```yaml
# pubspec.yaml — trong dependencies:
  rxdart: ^0.28.0
```

```bash
flutter pub get
```

`ValueStream` là gì chính là nội dung **bài 3** — bước này chỉ cần biết
nó là "một `Stream` luôn biết giá trị hiện tại". Đừng bỏ qua cũng đừng
đào sâu sớm.

### Bước 2 — viết contract file

Tạo `lib/repositories/profile/user_profile_repository.dart` — senior
đặt contract và impl **cùng một file**; bài này chỉ viết contract
(impl tới bài 4):

```dart
import 'package:rxdart/rxdart.dart';

import '../../data/profile/user_profile_data.dart';

/// Contract của repository profile — M14.
/// VM phụ thuộc CONTRACT này, không phải impl cụ thể.
abstract interface class UserProfileRepository {
  /// Stream state profile — `ValueStream` = Stream luôn biết giá trị
  /// hiện tại qua `.value` (mở kỹ ở bài 3).
  ValueStream<UserProfileData> get userProfileStream;

  /// Đọc profile từ disk vào stream; trả về profile đã emit.
  Future<UserProfileData> loadUserProfile();

  /// Ghi profile rồi emit lên stream.
  Future<void> saveUserProfile(UserProfileData userData);

  /// Reset = GHI profile mặc định đè key (không xoá key).
  Future<void> resetUserProfile();

  /// Đóng subject — ownership thủ công vì subject không tự dọn.
  Future<void> dispose();
}
```

Đọc kỹ từng member — đây là *toàn bộ* khả năng VM được phép dùng:
một stream để nghe, ba hàm để đọc-ghi, một dispose cho lifecycle.
Không `getString`, không `jsonDecode` — chi tiết storage bị khoá
ngoài contract.

### Bước 3 — kiểm tra

```bash
flutter analyze
```

Phải sạch: file contract tự đứng được (chỉ import model + rxdart);
app chưa ai gọi nó nên không có gì vỡ. **`ProfileStore` vẫn còn nguyên
và VM vẫn đang dùng nó** — đúng ý đồ.

## Lỗi hay gặp

- **"Missing concrete implementation"** — nếu bạn tự thử
  `implements UserProfileRepository` mà bỏ sót member, analyzer bắt
  ngay. Đây là contract đang làm việc, không phải lỗi.
- **`extends` thay `implements`** — chú ý ranh giới file: *từ file
  khác*, `extends` một `interface class` là lỗi compile; nhưng trong
  **cùng file** với contract thì `extends` vẫn hợp lệ — analyzer không
  cứu được. Impl của project nằm chung file với contract, nên senior
  giữ `implements` bằng convention chứ không nhờ compiler bắt.
- **Gọi `create()` không `await`** — `create()` trả
  `Future<Impl>`; bỏ `await` là cầm Future chứ không phải Impl.

## Tự làm

**Tự viết — không copy.** Viết một contract nhỏ ngoài project (trong
đầu hoặc file scratch):

```dart
// Viết contract cho một "đồng hồ bấm giờ" lưu best-lap:
abstract interface class StopwatchRepository {
  // Thêm: stream bestLap (ValueStream<int>), load(), saveLap(int),
  // dispose() — tự đặt tên member.
}
```

1. Viết một `InMemoryStopwatchRepository implements` nó — tối thiểu
   đủ member.
2. Thử `extends` thay `implements` trong cùng file — analyzer có báo
   không? Vì sao (không)? — *Cấm `extends` chỉ áp dụng khi file khác
   dùng contract; trong cùng file vẫn hợp lệ.*
3. Vì sao `dispose()` nằm *trong contract* chứ không chỉ ở impl? —
   *Ai giữ kiểu contract (VM/test teardown) vẫn cần gọi được; member
   không khai trong contract thì consumer không thấy.*

## Tự kiểm tra

1. `abstract interface class` khác `abstract class` chỗ nào? —
   *Interface cấm `extends` từ file khác (chỉ `implements` được);
   body/ctor vẫn khai được nhưng impl `implements` không thừa hưởng —
   phải tự viết đủ member.*
2. Vì sao `create()` là `static Future` thay vì ctor thường? —
   *`SharedPreferences.getInstance()` là Future; ctor không await
   được nên construction async gói trong factory static.*
3. Vì sao ctor `._` private? — *Mọi construction buộc qua `create()`
   — không ai dựng impl thiếu prefs.*

## Ta cố ý chưa thêm

- **`ValueStream`/`BehaviorSubject` mở đâu** — bài 3.
- **Impl** `UserProfileRepositoryImpl` — bài 4.
- **Hai repo còn lại** — bài 5; **đăng ký provider** — bài 6.

## Checkpoint hoàn thành

- [ ] `pubspec.yaml` có `rxdart: ^0.28.0`; `flutter pub get` sạch.
- [ ] `lib/repositories/profile/user_profile_repository.dart` tồn
      tại, chứa `abstract interface class UserProfileRepository`
      đủ 5 member.
- [ ] `flutter analyze` sạch — và `ProfileStore` **vẫn còn** (chưa
      đến lúc xoá).
- [ ] Nói được khi nào `implements` vs `extends`; vì sao
      construction async cần `static Future create()`.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m14/02 — "Contract trong Dart" (file code đầu tiên của M14: contract repository + thêm rxdart; mọi thứ additive — app chưa ai gọi contract).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. LƯU Ý: bài này ADDITIVE — `ProfileStore` vẫn còn và VM vẫn dùng nó (đúng ý đồ); contract chưa có impl và chưa ai gọi.

EXPECTED STATE SAU BÀI NÀY:
- `pubspec.yaml` có `rxdart: ^0.28.0` trong dependencies (STRICT — dep mới duy nhất của bài; lockfile tương ứng); `flutter analyze` → "No issues found!".
- `lib/repositories/profile/user_profile_repository.dart` tồn tại (STRICT path + tên — y hệt senior): import `package:rxdart/rxdart.dart` + `../../data/profile/user_profile_data.dart`; chứa `abstract interface class UserProfileRepository` (STRICT: abstract interface class — KHÔNG abstract class thường).
- Contract đủ đúng 5 member (STRICT chữ ký): `ValueStream<UserProfileData> get userProfileStream;` + `Future<UserProfileData> loadUserProfile();` + `Future<void> saveUserProfile(UserProfileData userData);` + `Future<void> resetUserProfile();` + `Future<void> dispose();` — contract KHÔNG chứa body/impl (chỉ signature + doc).
- Chưa có `UserProfileRepositoryImpl` trong file (bài 4 — có sẵn cũng OK nếu learner đọc trước, nhưng không bắt buộc); chưa có `Provider<UserProfileRepository>` trong scope (bài 6).
- `lib/data/profile/profile_store.dart` VẪN CÒN và `MenuViewModel` vẫn nhận `ProfileStore` (STRICT — xoá sớm = DIVERGED); `_profile`/`loadState`/`applyGameResult` nguyên vẹn.

INVARIANTS NỀN:
- Event channel M13 (MenuUiEvent + broadcast + requestGame/resetProfile-emit); bridge M13/02; Provider scope M12 (Provider<ProfileStore>.value); persistence M10; game M09.

Mục (STRICT) phải đúng; mục khác chấm semantic (doc comment). Code vượt checkpoint (đã có impl+provider+MultiProvider) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m14/02
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
