---
title: "Bài 1 · SharedPreferences & ProfileStore"
description: "flutter pub add một plugin, SharedPreferences.getInstance trước runApp, getString/setString/remove, và lớp ProfileStore concrete đầu tiên."
sidebar:
  label: "Bài 1 · SharedPreferences"
  order: 1
---

## Mục tiêu

Thêm plugin `shared_preferences`, hiểu nó là gì dưới lớp API Dart, và
tạo `ProfileStore` — lớp lưu trữ concrete mỏng bọc một key
`'user_profile'` với ba hàm `load`/`save`/`reset`.

## Bạn đang ở đâu

- Milestone: **M10** (bài 1/4)
- App hiện tại: menu tải profile qua `loadDemoProfile()` — một hàm
  `Future.delayed` trả hồ sơ cứng. Dữ liệu chỉ sống trong RAM; tắt app
  là mất hết.

## Vì sao việc này quan trọng ngay bây giờ

Đến hết M09, app của bạn là "vô niệm": mọi state đều chết khi process
đóng. App senior thì khác — mở lên là thấy đúng tiền thưởng, cấp độ,
số ván đã chơi của lần trước. Chênh lệch đó nằm ở **persistence**:
ghi xuống disk, đọc lại khi khởi động.

`SharedPreferences` là lớp persist đơn giản nhất của Flutter — đủ cho
số, chuỗi, bool và một JSON string nhỏ. Nó *không* phải database
(không query, không bảng) — chỉ là key-value bền vững.

## Bạn đã biết gì

- `Future`/`async`/`await` (M05) — mọi API của plugin đều là async.
- `FutureBuilder` + load trong `initState` (M05) — ta sẽ thay nội dung
  `_loadProfile`, giữ nguyên khung render.
- Model bất biến `UserProfileData` (M04) — thứ sẽ được lưu.

## Mental model mới

**Plugin = API Dart + platform channel + code native.** Khi bạn gọi
`SharedPreferences.getInstance()`, Dart không tự đọc file — nó gửi
message qua *platform channel* tới code native của plugin, và plugin
đó gọi `SharedPreferences` thật của Android (hoặc `NSUserDefaults`
trên iOS). Bạn không cần biết chi tiết channel — chỉ cần biết hai
hệ quả:

1. Mọi hàm prefs trả `Future` — đi qua channel mất một nhịp event loop.
2. Phải `WidgetsFlutterBinding.ensureInitialized()` trước khi gọi
   platform call ngoài `runApp` — `main()` của ta đã có sẵn từ M05.

**ProfileStore = một key, một chuỗi JSON, ba hàm.** Không magic: ta
serialize cả profile thành một `Map`, `jsonEncode` thành chuỗi, ghi
vào key `'user_profile'`. Đọc là chiều ngược lại. Bài 2 lo phần JSON;
bài này lo cái "vỏ" storage.

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---------|-------|-------|
| `SharedPreferences.getInstance()` | `await SharedPreferences.getInstance()` | Lấy instance prefs (singleton phía platform); lần đầu mở file |
| `prefs.getString(key)` | `_prefs.getString('user_profile')` | Trả `String?` — `null` nếu chưa từng ghi key đó |
| `prefs.setString(key, v)` | `await _prefs.setString('user_profile', json)` | Ghi; trả `Future<bool>` — false = ghi lỗi |
| `prefs.remove(key)` | `await _prefs.remove('user_profile')` | Xoá hẳn key — khác với ghi chuỗi rỗng |
| constructor nhận dependency | `const ProfileStore(this._prefs)` | Truyền instance vào — class không tự getInstance, để test chèn prefs mock |

## Flutter cần dùng

| Việc | Cách |
|------|------|
| Thêm plugin | `flutter pub add shared_preferences` — thêm dòng vào `pubspec.yaml` + resolve transitive deps |
| Tạo store trước runApp | `final store = ProfileStore(await SharedPreferences.getInstance());` trong `main()` |
| Chuyển store xuống widget | constructor param: `MenuScreen(profileStore: store)` |

## Android / Compose bridge

- SIMILARITY: `SharedPreferences` của Flutter *chính là* Android
  `SharedPreferences` phía dưới (trên Android) — cùng mental model
  key-value đọc/ghi vào file nhỏ, cùng trường hợp dùng "cờ + số đếm +
  chuỗi config". Với Compose ta hay đi thẳng vào DataStore; Flutter
  chưa có bản typed tương đương nên ta tự validate JSON.
- IMPORTANT DIFFERENCE: mọi thao tác đều `async` và **không có
  `apply()` kiểu fire-and-forget** — `setString` trả `Future<bool>`,
  quên `await` là ghi "lỡ" khi process chết ngay sau đó.
- DO NOT ASSUME: prefs là database. Nó không query được, không nên chứa
  list lớn — vượt quá vài chục KB là đến lúc cần giải pháp khác (course
  không đi tới đó).

## Senior project connection

- `flutter-accelerator-ai/lib/repositories/profile/user_profile_repository.dart` —
  `UserProfileRepositoryImpl` dùng *đúng* key `'user_profile'`,
  `getString` → `jsonDecode` → `fromMap`, `setString(jsonEncode(toMap()))`,
  và ném `StateError` khi `setString` trả false — `ProfileStore` của ta
  là bản sao trung thực phần thô ấy.
- Khác biệt cố ý: senior bọc storage trong **interface**
  `UserProfileRepository` + phát thay đổi qua `BehaviorSubject`
  (rxdart). Cả hai lớp đó — contract và stream — đều là M14; M10 chỉ
  cần lớp concrete để thấy dữ liệu chạy.
- `lib/main.dart` của senior `await` tạo toàn bộ repositories trước
  `runApp` — cùng chỗ ta `await getInstance()` hôm nay.

## Build it step by step

### Bước 1 — Thêm plugin

```bash
flutter pub add shared_preferences
```

Lệnh này thêm `shared_preferences: ^2.5.5` vào `dependencies` trong
`pubspec.yaml` và kéo theo các package transitive (ffi, path_provider…).
Đó là lý do `pub get` báo "Changed 17 dependencies".

### Bước 2 — File `ProfileStore` mới

```dart
// lib/data/profile/profile_store.dart — FILE MỚI
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'user_profile_data.dart';

/// Lưu/nạp `UserProfileData` qua `SharedPreferences` — M10.
class ProfileStore {
  /// Key duy nhất trong prefs — cùng key senior dùng.
  static const String _profileKey = 'user_profile';

  final SharedPreferences _prefs;

  const ProfileStore(this._prefs);

  /// Đọc profile đã lưu — mọi nhánh xấu đều về mặc định.
  Future<UserProfileData> load() async {
    final encoded = _prefs.getString(_profileKey);
    if (encoded == null) {
      return const UserProfileData();
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is Map) {
        return UserProfileData.fromMap(Map<String, Object?>.from(decoded));
      }
    } on FormatException {
      // Chuỗi không phải JSON — rơi xuống default.
    }
    return const UserProfileData();
  }

  /// Ghi profile — `await` bắt buộc (fire-and-forget có thể mất ghi).
  Future<void> save(UserProfileData profile) async {
    final didSave = await _prefs.setString(
      _profileKey,
      jsonEncode(profile.toMap()),
    );
    if (!didSave) {
      throw StateError('Không ghi được hồ sơ.');
    }
  }

  /// Đặt lại profile — GHI default đè lên key (đúng semantics
  /// `resetUserProfile()` = `saveUserProfile(const UserProfileData())`
  /// của senior), không xoá key.
  Future<void> reset() => save(const UserProfileData());
}
```

`toMap`/`fromMap` chưa tồn tại — bài 2 viết chúng; đọc bài này cứ hiểu
"map ↔ JSON" là chi tiết của model.

### Bước 3 — `main()` tạo store một lần

```dart
// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final profileStore = ProfileStore(await SharedPreferences.getInstance());
  runApp(AIMillionaireApp(profileStore: profileStore));
}
```

Và `AIMillionaireApp`/`MenuScreen` nhận `profileStore` qua constructor
— bài 4 nối phần truyền xuống UI. Nhận ra đây chính là chỗ `await` mà
M05 đã "giữ sẵn" trong `main()`.

## Hiểu code

- **Vì sao `ProfileStore` nhận `SharedPreferences` qua constructor
  thay vì tự gọi `getInstance()`?** Hai lý do: `getInstance()` là async
  nên ctor đồng bộ không chứa được nó (nếu tự gọi thì phải async-factory
  — senior làm `create()` kiểu đó); và ctor-nhận-dependency cho phép
  test truyền prefs mock trực tiếp. "Đẩy dependency vào qua ctor" là
  mầm của DI mà M12 sẽ hệ thống hoá.
- **`load()` trả Future dù thân hàm "chỉ đọc"?** Vì `getString` là
  đồng bộ nhưng ta giữ chữ ký async: storage thật sau này (M14+) sẽ
  async, và call site `await` hôm nay không phải sửa.
- **`save` ném `StateError` khi `didSave` là false** — y hệt senior.
  Ghi lỗi là sự kiện hiếm nhưng thật; nuốt im lặng thì stats "mất"
  không dấu vết. Ném lên để caller (bài 4) quyết định.

## Chạy và quan sát

- `flutter pub get` → resolve xong; `flutter analyze` sẽ báo
  `toMap`/`fromMap` chưa tồn tại — bình thường, bài 2 bù.
- Chưa chạy app được trọn vẹn — đây là bài nền.

## Lỗi hay gặp

1. **Gọi `getInstance()` trước `ensureInitialized()`** — lỗi platform
   channel chưa sẵn sàng. Luôn `ensureInitialized()` dòng đầu `main()`.
2. **`setString` không `await`** — compile vẫn qua (Future bị bỏ lơ),
   nhưng app thoát giữa chừng → ghi chưa chạm disk. Hãy để ý dấu
   `await` trong `save`.
3. **Dùng `setString(key, '')` để "xoá"** — chuỗi rỗng vẫn là một giá
   trị: `load` sẽ `jsonDecode('')` → `FormatException` → may mắn về
   default, nhưng key vẫn nằm lì trong prefs. `remove()` mới là xoá.

## Kiểm tra hiểu biết

1. Vì sao `ProfileStore.load()` đọc xong còn phải `try/on FormatException`
   thay vì tin chuỗi đã lưu? — *Chuỗi trong prefs có thể do version cũ,
   lỗi ghi, hoặc tester sửa tay; storage là dữ liệu ngoài tầm kiểm soát
   của compiler, phải validate khi đọc.*
2. `prefs.getString` là đồng bộ (trả `String?`, không Future) — vậy
   `load()` có cần là `async`? — *Không bắt buộc, nhưng nên: chữ ký
   async giữ call site `await store.load()` đúng cho mọi implementation
   tương lai (đọc file, DB, network).*
3. Senior có `static Future<UserProfileRepositoryImpl> create()` —
   pattern đó giải quyết vấn đề gì? — *Cho phép `await getInstance()`
   trước khi có object: constructor đồng bộ không chứa await được.*

## Tự làm (PREDICT)

Sau khi `ProfileStore` đã nối vào app: chơi một ván xong (profile được
save), rồi **kill và mở lại app**. Với từng thứ sau, dự đoán **giữ hay
reset** — và nói vì sao:

1. `username`, `level`, EXP, tiền thắng, số ván (profile);
2. `_playTapCount` (đếm bấm PLAY);
3. `_soundOn` (cờ âm thanh);
4. Đồng hồ phiên `Stream.periodic` (số giây);
5. Trạng thái đang tải (loading → done).

Sau đó thử thật: chơi một ván, kill app (stop + run lại), đối chiếu.

**Câu nâng:** `_soundOn` và `_playTapCount` đang reset sau restart —
nếu muốn chúng cũng sống sót, đâu là thay đổi *nhỏ nhất* về mặt kiến
trúc? (Chỉ nêu hướng, không implement — quyết định đó chính là bản
chất của "chọn cái gì xứng đáng persist".)

:::note[Gợi ý]
Chỉ những gì đi qua `ProfileStore` mới sống sót — storage là một key
duy nhất chứa một model duy nhất. Mọi `State` field không được ghi vào
prefs đều chết theo process. Với câu nâng: `ProfileStore` đọc/ghi gì,
và hai field kia hiện sống ở đâu?
:::

<details><summary>Đáp án</summary>

1. **Giữ** — chúng là field của `UserProfileData`, object được
   `toMap`/`jsonEncode`/`setString` và `fromMap` lại khi load.
2. **Reset** — `int _playTapCount` là State-field thuần UI, không nằm
   trong model → chết theo process.
3. **Reset** — `_soundOn` cũng là State-field; nó *nên* persist (đó là
   preference thật), nhưng hiện chưa đi qua store → reset.
4. **Reset** — stream bắt đầu lại từ `initialData` (subscription mới
   khi widget vào cây); giây "phiên" theo định nghĩa là phiên mới.
5. **Reset** — loading là vòng đời `FutureBuilder`, luôn bắt đầu lại.

Câu nâng: đưa `_soundOn`/`_playTapCount` (nếu xứng đáng) **vào model
persisted** — `UserProfileData` thêm field, `toMap`/`fromMap` thêm key,
State đọc từ profile thay vì field riêng. Đó là đáp án đúng hướng —
persist nằm ở *model*, không phải "gọi setString ở chỗ khác". (Course
cố ý không làm: `soundOn` đúng ra sẽ thuộc settings repository —
M14+; bài chỉ yêu cầu nhận ra *hướng*.)

</details>

## Ta cố ý chưa thêm

- **Interface `ProfileRepository` + `BehaviorSubject` stream** — senior
  có cả hai; là M14, cần M12 (Provider) làm chỗ đặt trước.
- Nhiều key/prefs (settings, onboarding…) — M16/M18.
- `int.tryParse` cho dữ liệu string-hoá — profile ta lưu thuần typed
  JSON nên `is int` đủ; `tryParse` sẽ xuất hiện nếu phải đọc legacy
  string (senior có `_moneyFromDisplay` xử lý đúng ca đó — ta bỏ qua,
  đây là lựa chọn có chủ đích, không phải thiếu sót).

## Checkpoint hoàn thành

- [ ] `pubspec.yaml` có `shared_preferences` và `pub get` sạch.
- [ ] `lib/data/profile/profile_store.dart` tồn tại với
  `load`/`save`/`reset` (ghi đè mặc định — không xoá key).
- [ ] `main()` `await SharedPreferences.getInstance()` và truyền
  `ProfileStore` vào `AIMillionaireApp`.
- [ ] Hiểu vì sao phải `await setString` và vì sao `remove` khác
  `setString('')`.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m10/01 — "SharedPreferences & ProfileStore".

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, đọc `pubspec.yaml`, chạy `git status`, `git diff`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. LƯU Ý ĐẶC BIỆT của bài này: `flutter analyze` sẽ báo `toMap`/`fromMap` chưa tồn tại — ĐÚNG, bài sau bù; đừng đánh BEHIND vì lỗi đó, chỉ ghi nhận nó là chờ bài sau.

EXPECTED STATE SAU BÀI NÀY:
- `pubspec.yaml` có `shared_preferences` trong `dependencies` (STRICT — plugin đầu tiên của course).
- `lib/data/profile/profile_store.dart` tồn tại (STRICT path): `class ProfileStore` với `static const String _profileKey = 'user_profile'` (STRICT key), `final SharedPreferences _prefs`, `const ProfileStore(this._prefs)` (STRICT ctor nhận dependency — KHÔNG tự gọi getInstance bên trong).
- Ba method: `Future<UserProfileData> load()` (getString → null→`const UserProfileData()` → try jsonDecode → `is Map` → `UserProfileData.fromMap(Map<String, Object?>.from(decoded))` → `on FormatException` → default; STRICT mọi nhánh xấu về default, không bao giờ trả null), `Future<void> save(UserProfileData)` (`await _prefs.setString(_profileKey, jsonEncode(profile.toMap()))` + `if (!didSave) throw StateError(...)`; STRICT await + StateError), `Future<void> reset() => save(const UserProfileData())` (STRICT reset=ghi default đè, KHÔNG remove()).
- `import 'dart:convert'` + `import 'package:shared_preferences/shared_preferences.dart'` + import `user_profile_data.dart` có mặt.
- `main()` trong `lib/main.dart`: `WidgetsFlutterBinding.ensureInitialized()` dòng đầu → `final profileStore = ProfileStore(await SharedPreferences.getInstance());` → `runApp(AIMillionaireApp(profileStore: profileStore))` (STRICT: instance tạo một lần trước runApp, sau ensureInitialized).
- `AIMillionaireApp` + `MenuScreen` đã nhận `profileStore` qua constructor param (STRICT signature đổi; phần dùng bên trong menu là bài 4 — chấp nhận nếu menu chỉ nhận, chưa dùng).
- Menu vẫn load profile demo cũ (M05) ở bài này — chưa nối store vào `_loadProfile` là đúng.

INVARIANTS NỀN:
- `UserProfileData` (M04) nguyên vẹn (toMap/fromMap chưa cần — bài 2); game + dialog M09; `Future<void> main() async` của M05; 28 test xanh (trừ phần chờ toMap/fromMap compile).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (đã có repository interface/stream/Provider) → `AHEAD_RISKY` nếu đảo lộn cấu trúc bài tới; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m10/01
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
