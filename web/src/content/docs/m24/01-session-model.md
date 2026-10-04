---
title: "Bài 1 · Session model, AuthActionResult & guest mode"
description: "Sealed AuthSessionData (Guest/Authenticated — guest là session thật, không phải null); AuthActionResult — 'session là state, sign-in là action'; AuthRepository contract (authStateStream ValueStream + 6 method); DisabledAuthRepository guest mode trả configurationError; auth ≠ authorization ≠ profile. +6 test → 193 → 199."
sidebar:
 label: "Bài 1 · session model + guest mode"
 order: 1
---

## Mục tiêu

- Giải thích được **hai loại dữ liệu auth khác nhau**: `AuthSessionData`
 trên stream là *state* (bạn là ai — đứng đó cho tới khi đổi), còn
 `AuthActionResult` là *kết quả một hành động* (lần sign-in vừa rồi
 đi thế nào — đọc một lần rồi bỏ).
- Tạo `sealed AuthSessionData` → `AuthSessionGuest` /
 `AuthSessionAuthenticated{uid,email,displayName,photoUrl}` — áp dụng
 sealed union của M15 cho *identity*.
- Tạo contract `AuthRepository` (ValueStream + `loadAuthState` + 4
 sign-in + sign-out + dispose) và impl `DisabledAuthRepository` —
 guest mode khi thiếu dart-define, sign-in trả `failure` mang
 `configurationError` của env.
- Chỉ được ba danh từ hay nhầm: **identity** (auth user),
 **authorization** (RLS server-side — M23), **profile** (dữ liệu app).
- +6 test (2 session model + 4 disabled repo) → suite **193 → 199**.

## Bạn đang ở đâu

- Cuối M23: `flutter test` 193/193. App đã có Supabase client có điều
 kiện + leaderboard remote — nhưng **mọi người chơi đều là guest
 vô danh**: pill trên menu chỉ hiển thị username của profile local,
 không có khái niệm "đã đăng nhập".
- `SupabaseEnvironment` đã đọc sẵn hai key `GOOGLE_WEB_CLIENT_ID`/
 `GOOGLE_IOS_CLIENT_ID` (M23 giữ shape cho đúng milestone này);
 `isGoogleConfigured`/`configurationError` đã tồn tại và chưa ai dùng.
- `rxdart: ^0.28.0` đã trong pubspec từ M14 — `BehaviorSubject` sẵn dùng.

## Vì sao việc này quan trọng ngay bây giờ

Auth bắt đầu bằng **model**, không bằng nút "Đăng nhập". Trước khi có
bất kỳ UI hay provider nào, app phải trả lời được một câu: *"trạng
thái đăng nhập là gì trong code?"*. Nếu trả lời bằng `User?` thì mọi
consumer phải null-check và guest trở thành trường hợp "thiếu dữ liệu"
— trong khi app này *thiết kế* guest là chế độ chơi chính (chơi
offline, leaderboard vẫn xem, chỉ không sync). Senior giải quyết bằng
một sealed union: **guest là một variant chính danh**, không phải
null, không phải lỗi. Mọi nơi khác trong milestone này — repo impl,
coordinator, menu VM, header pill — đều đọc `switch` trên model này.

## Bạn đã biết gì

- `sealed class` + exhaustive `switch` + object pattern
 (M15); `final` class.
- `BehaviorSubject`/`ValueStream`/`.value`/seeded (M14);
 `StreamSubscription` + cancel trong `dispose`.
- `abstract interface class` + `implements` (M14); repo
 contract + impl + fake.
- `SupabaseEnvironment` + `isSupabaseConfigured`/`isGoogleConfigured`/
 `configurationError` + `--dart-define` (M23); conditional DI
 `client == null ? Disabled… : Supabase…`; RLS boundary.
- `==`/`hashCode`/`Object.hash` trên model; `const` ctor +
 named params; `trim().isNotEmpty`.

## Mental model mới — ba cái cùng lúc

**① "Session là state; sign-in là action"** (NORMAL).

```text
authStateStream  = STATE stream: "bạn là AI" — đứng đó cho tới khi
                   đổi; listener mới được replay giá trị hiện tại
                   (BehaviorSubject — y hệt userProfileStream của M14)
AuthActionResult = kết quả MỘT LẦN THỬ: "vừa rồi đi thế nào" —
                   success/failure + message cho snackbar; đọc xong bỏ,
                   KHÔNG ai subscribe nó
```

Hai thứ này hay bị gộp thành một `Future<User?>` — và đó là lúc bug
bắt đầu: sign-in "thành công" nhưng stream không đổi, hay UI lắng
nghe thứ không ai emit. Tách chúng ra rõ ràng ngay từ contract:
`authStateStream` giữ phiên, các method `signIn*` trả `AuthActionResult`.

**② "Guest là một session thật"**.

`AuthSessionGuest` không phải `null` và không phải `Error`: nó là
variant đầy đủ trong sealed family. Stream seed `AuthSessionGuest()`
ngay từ ctor nên mọi consumer luôn đọc được state hợp lệ — không cần
loading/auth-null branch nào. Đăng nhập = chuyển variant; đăng xuất =
về lại variant đó. Và vì family là `sealed`, `switch` trên nó được
compiler kiểm kiệt hợp: nếu sau này thêm variant thứ ba (ví dụ
"session hết hạn"), mọi switch quên xử lý là **lỗi biên dịch** —
đúng quà của /.

**③ Ba danh từ khác nhau** (awareness — gạt lầm lần kinh
điển của auth):

| Danh từ | Là gì | Sống ở đâu |
|---|---|---|
| **Identity** (auth user) | "bạn là ai" — uid + email + tên do provider cấp | `AuthSessionData` — milestone này |
| **Authorization** | "bạn được làm gì" — quyền trên dữ liệu | RLS policies phía SERVER (M23); client không quyết |
| **Profile** | dữ liệu game của bạn (username, level, EXP…) | `UserProfileData` local SharedPreferences; `public.users` remote (M25) |

`uid` của `AuthSessionAuthenticated` chính là sợi nối ba thứ:
nó đi vào query `.eq('auth_uuid', uid)` của leaderboard (Bài
4) và sẽ là khóa ngoại khi ghi `public.users` (M25). Đăng nhập xong
không có nghĩa profile "tự có" — profile là thứ khác, sync sang nó là
bước riêng (coordinator ở Bài 3).

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `sealed class X` + `final class V extends X` | union đóng cho session — áp dụng lại cho identity |
| `bool get isAuthenticated => this is AuthSessionAuthenticated` | getter tiện cho UI thay `is` lặp lại |
| `class R { const R._(...); const R.success(m) : this._(...); }` | private ctor `._` + **redirecting ctor** — `success`/`failure` là hai tên gọi vào cùng một ctor thật |
| `ValueStream<T> get` | kiểu stream "luôn có `.value`" — |
| `abstract interface class` | contract repo — |
| `?? 'fallback'` trên `configurationError` | env error → message mặc định — |

Redirecting ctor (`: this._(...)`) là construct mới ở đây:
`AuthActionResult._` là ctor private thật sự khởi tạo field;
`AuthActionResult.success`/`failure` chỉ là tên đẹp **chuyển hướng**
vào nó với `isSuccess` nướng sẵn. Kết quả: bên ngoài không tạo được
`AuthActionResult(isSuccess: …)` tự do — chỉ qua hai cửa đúng nghĩa.
Đây là "value-type kết quả" thay vì `bool` + `String` rời hoặc throw:
VM đọc `result.isSuccess` để quyết dismiss/hiện snackbar (Bài 4), và
`message` luôn đi kèm — không cần try/catch quanh lời gọi sign-in.

## Ví dụ độc lập

Hai chục dòng, tách khỏi app — một sealed union mini + hai impl của
cùng contract (DartPad chạy được):

```dart
sealed class DoorState { const DoorState(); }
final class DoorClosed extends DoorState { const DoorClosed(); }
final class DoorOpen extends DoorState {
  final String byWhom;
  const DoorOpen(this.byWhom);
}

abstract interface class DoorRepository {
  DoorState get state;
  String tryOpen(String key); // ACTION → message, không đổi state ở impl tĩnh
}

class LockedDoorRepository implements DoorRepository {
  @override
  DoorState get state => const DoorClosed(); // "guest mode"
  @override
  String tryOpen(String key) => 'Door is unavailable.';
}

void main() {
  final DoorRepository door = LockedDoorRepository();
  final label = switch (door.state) {         // kiệt hợp — compiler kiểm
    DoorClosed() => 'đang đóng',
    DoorOpen(:final byWhom) => 'mở bởi $byWhom',
  };
  print('$label → ${door.tryOpen('key-1')}');
  // → đang đóng → Door is unavailable.
}
```

Map trực tiếp sang production: `DoorClosed` ↔ `AuthSessionGuest`,
`DoorOpen(byWhom)` ↔ `AuthSessionAuthenticated(uid,…)`,
`tryOpen` ↔ `signInWithGoogle` trả `AuthActionResult`,
`LockedDoorRepository` ↔ `DisabledAuthRepository`. Một contract, một
impl "không mở được" mà vẫn trả lời lịch sự — cùng shape.

## Android / Compose bridge

**SIMILARITY — Kotlin `sealed class` ≈ Dart `sealed`.** Bạn đã viết
`sealed class UiState { object Guest : UiState(); data class Authed(
val uid: String) : UiState() }` — `AuthSessionData` là cùng cái đó,
với `when` kiệt hợp ↔ `switch` kiệt hợp. `AuthActionResult` đóng vai
`sealed class Result`/`Either` thu nhỏ thành một value-type hai field.

**IMPORTANT DIFFERENCE — không `FirebaseUser?`.** Firebase Auth trả
`currentUser` nullable — guest = null. Ở đây guest là *variant*
(`AuthSessionGuest`), nên `switch` buộc bạn nêu rõ guest-case thay
vì trôi qua `?:`. Hệ quả: không có `NullPointerException`-equivalent
nào ở đường guest — compiler ép bạn xử lý nó.

**DO NOT ASSUME — sign-in KHÔNG trả session.** API Android quen thuộc
`signIn(): Task<AuthResult>` trả user trong kết quả. Ở đây
`signInWith*` trả `AuthActionResult` (message), còn *ai bạn là* phải
đọc từ `authStateStream`/`loadAuthState()` — hai kênh, hai vai trò.
Đừng chờ result mang session; coordinator Bài 3 chính là nơi nối hai
kênh đó.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/data/auth/auth_session_data.dart` | learner port nguyên văn — cùng sealed family, `isAuthenticated` getter, `==`/`hashCode` đủ field |
| `lib/repositories/auth/auth_repository_contract.dart` | `AuthActionResult` + contract — verbatim |
| `lib/repositories/auth/disabled_auth_repository.dart` | guest impl — verbatim, kể cả chuỗi `'Sign in is unavailable.'` fallback |
| `lib/repositories/auth/auth_repository.dart` | barrel 3 export — một import lộ contract + cả hai impl |

## Build it step by step

**Bước 1 — `lib/data/auth/auth_session_data.dart`** (58 dòng, verbatim
senior — comment Việt giữ sẵn):

```dart
@immutable
sealed class AuthSessionData {
  const AuthSessionData();

  /// `true` khi phiên hiện tại là authenticated.
  bool get isAuthenticated => this is AuthSessionAuthenticated;
}

final class AuthSessionGuest extends AuthSessionData {
  const AuthSessionGuest();

  @override
  bool operator ==(Object other) => other is AuthSessionGuest;

  @override
  int get hashCode => 0;
}

final class AuthSessionAuthenticated extends AuthSessionData {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const AuthSessionAuthenticated({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });
  // + == / hashCode so trên cả 4 field (D-05 — verbatim senior)
}
```

`uid` là field **bắt buộc duy nhất**: một session authenticated luôn
có identity tối thiểu là uid; email/tên/ảnh do provider quyết (có
thể thiếu — xem `_sessionFromUser` ở Bài 2). `import 'package:flutter/
foundation.dart'` cho `@immutable`.

**Bước 2 — `lib/repositories/auth/auth_repository_contract.dart`**
(60 dòng, verbatim):

```dart
class AuthActionResult {
  final bool isSuccess;
  final String message;

  const AuthActionResult._({required this.isSuccess, required this.message});

  const AuthActionResult.success(String message)
    : this._(isSuccess: true, message: message);

  const AuthActionResult.failure(String message)
    : this._(isSuccess: false, message: message);
}

abstract interface class AuthRepository {
  ValueStream<AuthSessionData> get authStateStream;
  Future<AuthSessionData> loadAuthState();
  Future<AuthActionResult> signInWithGoogle();
  Future<AuthActionResult> signInWithApple();
  Future<AuthActionResult> signInWithEmail({
    required String email,
    required String password,
  });
  Future<AuthActionResult> signUpWithEmail({
    required String email,
    required String password,
  });
  Future<AuthActionResult> signOut();
  Future<void> dispose();
}
```

Đọc bề mặt contract: đúng 1 stream + 1 loader + 4 action + dispose.
Không `currentUser` getter, không `User?` — consumer nào cần "bây
giờ là ai" đọc `authStateStream.value`.

**Bước 3 — `lib/repositories/auth/disabled_auth_repository.dart`**
(78 dòng, verbatim). Khúc trục:

```dart
class DisabledAuthRepository implements AuthRepository {
  final SupabaseEnvironment _environment;
  final BehaviorSubject<AuthSessionData> _authStateSubject;

  DisabledAuthRepository({required SupabaseEnvironment environment})
    : _environment = environment,
      _authStateSubject = BehaviorSubject<AuthSessionData>.seeded(
        const AuthSessionGuest(),
      );

  @override
  ValueStream<AuthSessionData> get authStateStream => _authStateSubject.stream;

  @override
  Future<AuthSessionData> loadAuthState() async => _authStateSubject.value;

  // Mọi sign-* → _unavailableResult('… sign-in'):
  String get _unavailableMessage {
    return _environment.configurationError ?? 'Sign in is unavailable.';
  }

  AuthActionResult _unavailableResult(String action) {
    debugPrint('[auth] $action unavailable: $_unavailableMessage');
    return AuthActionResult.failure(_unavailableMessage);
  }

  @override
  Future<AuthActionResult> signOut() async {
    return const AuthActionResult.success('Signed out successfully.');
  }

  @override
  Future<void> dispose() => _authStateSubject.close();
}
```

`// ignore_for_file: prefer_initializing_formals` ở đầu file — senior
viết ctor gán tay (`_environment = environment`) và giữ nguyên.

**Bước 4 — `lib/repositories/auth/auth_repository.dart`** (barrel, 5 dòng — version Bài 1 xuất 2 file; Bài 2 thêm dòng thứ ba):

```dart
export 'auth_repository_contract.dart';
export 'disabled_auth_repository.dart';
// Bài 2 thêm: export 'supabase_auth_repository.dart';
```

**Bước 5 — `test/supabase_auth_repository_test.dart`** — file mới,
hai group đầu (group Apple-mapping thêm ở Bài 2; tên file đặt theo
impl chủ của thư mục auth — allow-list "hoặc gộp vào repo test"):

```dart
import 'package:ai_millionaire_course/core/supabase_environment.dart';
import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/repositories/auth/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthSessionData (sealed session model)', () {
    test('isAuthenticated phân biệt guest ↔ authenticated', () {
      const AuthSessionData guest = AuthSessionGuest();
      const AuthSessionData authed = AuthSessionAuthenticated(uid: 'u1');
      expect(guest.isAuthenticated, isFalse);
      expect(authed.isAuthenticated, isTrue);
    });

    test('equality: guest == guest; authed so trên uid+profile fields', () {
      expect(const AuthSessionGuest(), const AuthSessionGuest());
      expect(
        const AuthSessionAuthenticated(
          uid: 'u1', email: 'a@b.c', displayName: 'A', photoUrl: 'p',
        ),
        const AuthSessionAuthenticated(
          uid: 'u1', email: 'a@b.c', displayName: 'A', photoUrl: 'p',
        ),
      );
      expect(
        const AuthSessionAuthenticated(uid: 'u1'),
        isNot(const AuthSessionAuthenticated(uid: 'u2')),
      );
      expect(
        const AuthSessionAuthenticated(uid: 'u1'),
        isNot(const AuthSessionGuest()),
      );
    });
  });

  group('DisabledAuthRepository (guest mode khi thiếu config)', () {
    DisabledAuthRepository makeRepo({
      String supabaseUrl = '',
      String publishableKey = '',
      String googleWebClientId = '',
      String googleIosClientId = '',
    }) {
      final repo = DisabledAuthRepository(
        environment: SupabaseEnvironment(
          supabaseUrl: supabaseUrl,
          publishableKey: publishableKey,
          googleWebClientId: googleWebClientId,
          googleIosClientId: googleIosClientId,
        ),
      );
      addTearDown(repo.dispose);
      return repo;
    }

    test('stream seed AuthSessionGuest ngay từ đầu', () {
      final repo = makeRepo();
      expect(repo.authStateStream.value, const AuthSessionGuest());
      expect(repo.authStateStream.value.isAuthenticated, isFalse);
    });

    test('sign-in trả failure = configurationError của env', () async {
      final repo = makeRepo();
      final result = await repo.signInWithGoogle();
      expect(result.isSuccess, isFalse);
      expect(result.message, 'Supabase is not configured.');
      expect(repo.authStateStream.value, const AuthSessionGuest());
    });

    test('đủ cấu hình (configurationError null) → fallback message', () async {
      final repo = makeRepo(
        supabaseUrl: 'https://example.supabase.co',
        publishableKey: 'publishable-key',
        googleWebClientId: 'web-client-id',
      );
      final result = await repo.signInWithEmail(
        email: 'a@b.c', password: 'password',
      );
      expect(result.isSuccess, isFalse);
      expect(result.message, 'Sign in is unavailable.');
    });

    test('signOut luôn success — "đăng xuất khỏi guest" là no-op', () async {
      final repo = makeRepo();
      final result = await repo.signOut();
      expect(result.isSuccess, isTrue);
      expect(result.message, 'Signed out successfully.');
    });
  });
}
```

(Các chuỗi `'https://example.supabase.co'`, `'publishable-key'`,
`'web-client-id'` là fixture giả — không phải credential thật.)

## Hiểu code — ba chi tiết dễ trượt

1. **`signOut` trên Disabled trả success.** Nghe ngược ("chưa đăng
 nhập sao đăng xuất thành công?") nhưng đúng: "đăng xuất khỏi guest"
 là no-op vô hại — trả failure chỉ làm UI hiện lỗi giả. Guest mode
 phải chơi được trọn vẹn.
2. **`_unavailableMessage` ưu tiên `configurationError` của env.** App
 chưa cấu hình Supabase → `'Supabase is not configured.'`; đủ
 Supabase nhưng thiếu Google → `'Google sign-in is not configured.'`;
 đủ hết (edge case: impl disabled bị chọn tay) → fallback
 `'Sign in is unavailable.'`. UI chỉ hiển thị message — không biết
 lý do phía dưới, và không cần biết.
3. **`loadAuthState` ở Disabled trả `.value` ngay** — không có nguồn
 nào khác để "đọc lại". Ở impl Supabase (Bài 2) nó đọc
 `client.auth.currentUser` rồi emit — cùng chữ ký, khác nguồn.
 Đó là lý do coordinator Bài 3 gọi `loadAuthState()` sau sign-in:
 "repo ơi, cập nhật session rồi trả tôi cái mới nhất".

## Chạy và quan sát

```text
flutter analyze → No issues found!
flutter test test/supabase_auth_repository_test.dart → 6/6 xanh
flutter test    → +199: All tests passed!   (193 + 6)
```

Đọc số: 193 (cuối M23) + 6 test mới = **199**. Chưa có test nào cho
`AuthRepositoryImpl` — impl đó + provider services là Bài 2.

## Thử nghiệm

Đoán trước rồi viết `expect` kiểm chứng: với
`makeRepo(publishableKey: 'k', googleWebClientId: 'w')` (chỉ thiếu
`supabaseUrl`), `signInWithGoogle()` trả message gì — Supabase hay
Google error?

<details>
<summary>Đáp án</summary>

`'Supabase is not configured.'` — `configurationError` check theo
THỨ TỰ (M23 Bài 1): thiếu Supabase báo Supabase trước dù Google đã
đủ. `isSupabaseConfigured` vẫn false vì `supabaseUrl` rỗng.
</details>

## Lỗi hay gặp

1. **Coi guest như `null`/`error` cần guard.** `AuthSessionGuest` là
 variant đầy đủ — viết `if (session == null)` là dấu hiệu quên
 model: không có null nào ở đây, `switch` kiệt hợp ép bạn xử lý
 đúng hai case.
2. **Đọc "bạn là ai" từ `AuthActionResult`.** Result chỉ có
 `isSuccess`/`message` — muốn biết session thì `authStateStream.value`
 hoặc `loadAuthState()`. Trộn hai kênh = bug của Bài 3 sẽ khoét.
3. **Kỳ vọng sign-in trên Disabled đổi stream.** Nó không bao giờ
 emit — chỉ trả `failure` message. Test thứ hai assert thêm
 `value == AuthSessionGuest()` sau call đúng để khóa hành vi đó.
4. **Quên `dispose` subject.** `BehaviorSubject.close()` trong
 `dispose()` — test gọi qua `addTearDown(repo.dispose)`; bỏ quên
 → leak cảnh báo trong test.
5. **Khai kiểu stream là `Stream<AuthSessionData>` trong contract.**
 Phải `ValueStream` — cái `.value` mà `loadAuthState` và mọi
 consumer dựa vào chỉ tồn tại trên `ValueStream`.

## Tự làm — PREDICT

Không chạy test. Với từng env dưới đây, viết ra giấy hai giá trị:
`repo.authStateStream.value.isAuthenticated` và
`(await repo.signInWithGoogle()).message`:

| # | `SupabaseEnvironment` truyền vào `makeRepo` |
|---|---|
| a | *(tất cả rỗng)* |
| b | `supabaseUrl` + `publishableKey` đủ, không Google |
| c | đủ cả bốn field |

<details>
<summary>Đáp án</summary>

- a → `false` / `'Supabase is not configured.'`
- b → `false` / `'Google sign-in is not configured.'` — env đủ
 Supabase nên `configurationError` nhảy sang nhánh Google.
- c → `false` / `'Sign in is unavailable.'` — `configurationError`
 `null` → rơi vào fallback. Lưu ý `isAuthenticated` **luôn** false:
 Disabled seed guest và không bao giờ đổi — đó là điểm của impl.

</details>

## Kiểm tra hiểu biết

- **Hỏi:** `authStateStream` và `AuthActionResult` khác nhau căn bản
 thế nào? — **Đáp:** stream là *state* (ai đang đăng nhập — replay, sống lâu); result là *outcome một lần* của action (đọc xong bỏ —
 VM dùng quyết dismiss/snackbar).
- **Hỏi:** vì sao `AuthSessionGuest` tồn tại thay vì `null`? —
 **Đáp:** guest là chế độ chơi hợp lệ; variant chính danh khiến mọi
 `switch` phải xử lý guest rõ ràng và stream luôn có giá trị hợp lệ
 để seed.
- **Hỏi:** `uid`, `authorization` và `profile` liên quan ra sao? —
 **Đáp:** `uid` là identity do provider cấp; authorization = RLS
 server-side quyết quyền trên dữ liệu (M23); profile là dữ liệu app
 gắn với uid đó — ba thứ khác nhau, `auth_uuid` là sợi nối.

## Ta cố ý chưa thêm

- `AuthRepositoryImpl` + `GoogleAuthService`/`AppleAuthService` —
 **Bài 2** (export thứ ba của barrel cũng đợi ở đó).
- `UserProfileSyncRepository` + `MenuAuthActionCoordinator` — **Bài 3**.
- Dialog VMs, `MenuViewModel` auth sub, `requestAuthAction` — **Bài 4**.
- Pill/dialog UI + ARB + xoá reset scaffold — **Bài 5**.
- `UserProfileSyncRepositoryImpl` (merge + upsert `public.users`) —
 **M25**; `MenuDialogLayer`/OTP/magic-link — senior không có / M29.

## Checkpoint hoàn thành

- [ ] `lib/data/auth/auth_session_data.dart` có sealed
 `AuthSessionData` + 2 variant + `isAuthenticated`.
- [ ] `auth_repository_contract.dart` có `AuthActionResult`
 (`.success`/`.failure`) + contract đủ 8 member.
- [ ] `disabled_auth_repository.dart` seed `AuthSessionGuest`,
 sign-* trả `failure(configurationError ?? 'Sign in is unavailable.')`,
 `signOut` success.
- [ ] `flutter analyze` sạch; `flutter test` **199/199**.
- [ ] Giải thích được: vì sao "guest là session thật" và vì sao
 sign-in không trả session trong `AuthActionResult`.
