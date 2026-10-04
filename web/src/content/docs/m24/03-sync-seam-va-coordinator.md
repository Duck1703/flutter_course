---
title: "Bài 3 · Sync seam + MenuAuthActionCoordinator"
description: "Vì sao contract UserProfileSyncRepository ship ở M24 mà impl để M25: ProfileSyncStateData (Idle/InProgress/Failed) + UserProfileSyncRepositoryDisabled no-op + ctor shape đúng senior. Coordinator giữ chuỗi signIn*→loadAuthState→authenticated-guard→syncUserProfile và signOut→resetUserProfile. +0 test → 201."
sidebar:
 label: "Bài 3 · sync seam + coordinator"
 order: 3
---

## Mục tiêu

- Giải thích được chiến thuật **"contract trước, impl sau"**: M24 ship
 `UserProfileSyncRepository` + `ProfileSyncStateData` + impl
 `UserProfileSyncRepositoryDisabled` (no-op) để *call-site* của
 coordinator đúng ngay hôm nay; `UserProfileSyncRepositoryImpl`
 (merge + upsert `public.users`) là **M25**.
- Port `MenuAuthActionCoordinator` — một lớp duy nhất giữ hai chuỗi:
 `signIn* → loadAuthState → (guard authenticated) → syncUserProfile`
 và `signOut → resetUserProfile` (hành vi nút reset M10 sống lại ở
 đây — converge).
- Hiểu guard quan trọng: repo báo **success nhưng session vẫn guest**
 → trả `failure('Sign in failed: no active session.')` — "sign-in
 không tạo được session thì không tính là đăng nhập".
- Không thêm test mới ở bài này (coverage đến qua dialog VM ở Bài 4)
 → suite giữ **201/201**.

## Bạn đang ở đâu

- Bài 2: `AuthRepositoryImpl` + DI + scope đã vào; suite 201/201.
 `main()` chọn `Disabled`/`Supabase` auth repo theo config.
- Chưa ai GỌI các method sign-*: repo chỉ được fake dùng trong test.
 Bài này dựng nơi gọi đầu tiên — coordinator — và seam sync nó cần.

## Vì sao việc này quan trọng ngay bây giờ

Hai câu hỏi thật của bài này:

**① Vì sao ship một contract mà impl là no-op?** Nghe như "code thừa"
— nhưng đây là cách senior tránh viết lại call-site sau này. Chuỗi
đúng là: sign-in thành công → **đồng bộ profile lên `public.users`**.
Nếu M24 viết coordinator gọi thẳng Supabase, M25 sẽ phải mổ lại mọi
điểm gọi. Thay vào đó: contract + seam + impl no-op được đặt đúng chỗ
TỪ ĐẦU — coordinator của M24 gọi `syncUserProfile(session)` y hệt
senior; lời gọi rơi vào no-op an toàn; M25 chỉ đổi MỘT dòng `main()`
(`Disabled` → `Impl`) mà không sửa coordinator/dialog VM nào. Đây là
cùng tư duy `DisabledLeaderboardRepository` của M23 — seam có ý thức.

**② Vì sao cần coordinator riêng thay vì VM gọi repo?** Vì "sign-in"
thật sự là CHUỖI nhiều bước có thứ tự, và có HAI dialog VM
(`MenuAuthDialogViewModel`, `MenuSignOutDialogViewModel` — Bài 4)
cùng cần nó. Nếu mỗi VM tự viết chuỗi → hai nửa chuỗi trôi dạt.
Coordinator giữ chuỗi một chỗ; VM chỉ lo "single-flight + dịch kết
quả sang event". Đó là phân chia senior: coordinator trả
`AuthActionResult`, VM quyết dismiss/snackbar.

## Bạn đã biết gì

- `AuthSessionData`/`AuthActionResult`/`AuthRepository` (Bài 1); impl + fake (Bài 2).
- `UserProfileRepository` local + `resetUserProfile()` (M14):
 profile local sống trong SharedPreferences, stream là truth.
- `BehaviorSubject.seeded` + `ValueStream`; sealed union +
 exhaustive switch; `typedef Function()` param (Bài 2);
 `is!`/`is` type check + object pattern.
- DI conditional + `AppDependencyScope` provider;
 `debugPrint` có nhãn cho luồng async (qua `unawaited`).

## Mental model mới — "coordinator giữ chuỗi, stream giữ state" 

```text
MenuAuthActionCoordinator  = chỗ DUY NHẤT biết "sau sign-in làm gì"
  ├─ signIn*  → AuthActionResult
  │     success → loadAuthState() → session AUTHENTICATED?
  │         ├─ có   → syncUserProfile(session) → trả result gốc
  │         └─ không → trả failure('Sign in failed: no active session.')
  ├─ signUp   → tương tự NHƯNG success-không-session là HỢP LỆ
  │             (confirm-email) → trả result gốc, chỉ sync khi có session
  └─ signOut  → success → resetUserProfile() (profile local về mặc định)

UserProfileSyncRepository  = seam sync; M24 = Disabled (no-op)
ProfileSyncStateData       = trạng thái job sync (Idle/InProgress/
                             Failed) — stream đã có, CONSUMER đến M25
```

Ba điểm dễ nhầm, khắc ngay:

1. **`loadAuthState()` không phải sign-in lần hai.** Nó là "đọc lại
 session hiện tại" — impl thật đọc `client.auth.currentUser`, fake
 trả `subject.value`. Sau `signIn*` thành công, coordinator hỏi
 lại nguồn truth thay vì TIN result.
2. **Result-success ≠ session-authenticated.** Hai kênh tách bạch
 (Bài 1): repo có thể trả `success` mà stream vẫn guest (impl lỗi, fake script nhầm, hoặc sign-up confirm-email). Guard `session is!
   AuthSessionAuthenticated` là nơi hai kênh được đối chiếu — sign-in
 mà không có session thì BÁO LỖI, không im lặng coi như xong.
3. **Sign-up có nhánh riêng CÓ LÝ DO.** Confirm-email: `success` mà
 guest là kết quả ĐÚNG — user phải check mail trước khi có session.
 Vì thế `signUpWithEmail` không guard-fail: nó trả result gốc và
 CHỈ sync nếu session authenticated. Một guard chung cho cả hai
 sẽ biến luồng hợp lệ thành lỗi giả — đây là khác biệt senior
 verbatim giữa `_signInAndSync` và `signUpWithEmail`.

## Dart/Flutter cần dùng — xuất hiện đầu tiên

| Construct | Vai trò |
|---|---|
| `Future<R> Function()` param | truyền "hành động sign-in" vào `_signInAndSync` — method-tearoff như closure (áp dụng) |
| `x is! T` (negated type test) | guard "không authenticated → fail sớm" — đọc ngược của `is` |
| `switch` expression trả String | `_sessionLabel` cho debug log — |
| `Future<void>` no-op body `async {}` | Disabled impl trả về ngay — method rỗng hợp lệ của contract |

## Ví dụ độc lập — chuỗi 3 bước trong 20 dòng

```dart
// Mini-coordinator: action → reload → guard → follow-up.
class R { final bool ok; const R(this.ok); }
sealed class S { const S(); }
class Guest extends S { const Guest(); }
class Authed extends S { const Authed(); }

Future<R> signInAndSync(
  Future<R> Function() action,
  Future<S> Function() reload,
  Future<void> Function(Authed) sync,
) async {
  final result = await action();          // 1. action
  if (!result.ok) return result;          //    fail → trả luôn
  final s = await reload();               // 2. đọc lại state
  if (s is! Authed) return const R(false);// 3. GUARD
  await sync(s);                          // 4. follow-up đúng session
  return result;
}
```

`_signInAndSync` là đúng shape này với `AuthActionResult`/`AuthSessionData`
thật. Để ý: **bước 3 không thể bỏ** — bỏ nó thì "action success nhưng
state không đổi" lọt qua yên lặng (chính là bug bạn sẽ trồng trong
exercise DEBUG bên dưới).

## Android / Compose bridge

**SIMILARITY — coordinator ≈ use-case/interactor.** Vai trò
`SignInAndSyncProfile` trong Clean Architecture: ViewModel gọi một
điểm vào duy nhất, orchestration repo ở trong. Ở đây không có DI
framework — coordinator là class thường, VM tự `new` trong ctor.

**IMPORTANT DIFFERENCE — "đọc lại state" qua repo, không qua field
cache.** Android hay cache `currentUser` trong `AuthManager`; ở đây
coordinator gọi `loadAuthState()` — nguồn truth là REPO (Supabase
`currentUser` hoặc subject của fake), không phải biến giữ chỗ nào đó.

**DO NOT ASSUME — `resetUserProfile()` KHÔNG xoá tài khoản.** Nó reset
PROFILE LOCAL (username/level/tiền) về mặc định — "thiết bị về hồ sơ
khách". Tài khoản Supabase vẫn tồn tại; đăng nhập lại khôi phục.
Đây chính là semantics nút "ĐẶT LẠI HỒ SƠ" của M10 được dời đúng chỗ.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `repositories/profile/user_profile_sync_repository_contract.dart` | contract verbatim — `syncStateStream` + `syncUserProfile` |
| `data/profile/profile_sync_state_data.dart` | sealed 3 variant verbatim |
| `repositories/profile/user_profile_sync_repository.dart` | learner CHỈ port `UserProfileSyncRepositoryDisabled`; `UserProfileSyncRepositoryImpl` (merge + upsert `public.users`, `_upsertRemoteProfile`) nằm ở đây — **mục tiêu M25** |
| `view_models/menu/menu_auth_action_coordinator.dart` | coordinator verbatim — kể cả chuỗi `debugPrint('[auth] …')` và guard `'no active session'` |
| `main.dart` | senior chọn `client == null ? Disabled : Impl` cho CẢ sync repo — learner cố ý `UserProfileSyncRepositoryDisabled()` luôn (divergence có chủ đích → M25 đổi một dòng) |

## Build it step by step

**Bước 1 — `lib/data/profile/profile_sync_state_data.dart`** (44
dòng, verbatim): sealed `ProfileSyncStateData` → `ProfileSyncIdle` /
`ProfileSyncInProgress` / `ProfileSyncFailed(message)` — mỗi variant
có `==`/`hashCode`. Stream seeded `Idle`; `InProgress`/
`Failed` do impl thật emit khi upsert chạy — **M25** mới có consumer,
M24 chỉ cần model tồn tại đúng shape.

**Bước 2 — `lib/repositories/profile/user_profile_sync_repository_contract.dart`**
(25 dòng, verbatim):

```dart
abstract interface class UserProfileSyncRepository {
  /// Stream trạng thái sync — seeded ProfileSyncIdle.
  ValueStream<ProfileSyncStateData> get syncStateStream;

  /// Đồng bộ profile local với remote cho phiên authenticated.
  Future<void> syncUserProfile(AuthSessionAuthenticated session);

  Future<void> dispose();
}
```

Đọc kỹ chữ ký: `syncUserProfile` nhận `AuthSessionAuthenticated` —
KHÔNG nhận `AuthSessionData`. Ai gọi phải đã `is`-check trước — đó là
lý do guard của coordinator tồn tại ở dạng `is!` (compile ép bạn có
session thật mới sync được).

**Bước 3 — `lib/repositories/profile/user_profile_sync_repository.dart`**
(34 dòng, verbatim — chỉ phần Disabled):

```dart
export 'user_profile_sync_repository_contract.dart';

class UserProfileSyncRepositoryDisabled implements UserProfileSyncRepository {
  final BehaviorSubject<ProfileSyncStateData> _syncStateSubject;

  UserProfileSyncRepositoryDisabled()
    : _syncStateSubject = BehaviorSubject<ProfileSyncStateData>.seeded(
        const ProfileSyncIdle(),
      );

  @override
  ValueStream<ProfileSyncStateData> get syncStateStream =>
      _syncStateSubject.stream;

  @override
  Future<void> syncUserProfile(AuthSessionAuthenticated session) async {}

  @override
  Future<void> dispose() => _syncStateSubject.close();
}
```

No-op an toàn: stream seed Idle và KHÔNG bao giờ đổi (không ai emit
InProgress/Failed) — UI sync-progress sẽ là chuyện của M25 khi impl
thật emit.

**Bước 4 — `lib/view_models/menu/menu_auth_action_coordinator.dart`**
(154 dòng, verbatim). Trục `_signInAndSync` (`:103-129`):

```dart
Future<AuthActionResult> _signInAndSync(
  String label,
  Future<AuthActionResult> Function() signIn,
) async {
  final result = await signIn();
  debugPrint('[auth] $label repository result '
      'success=${result.isSuccess} message="${result.message}"');
  if (!result.isSuccess) return result;

  final session = await _authRepository.loadAuthState();
  debugPrint('[auth] $label session=${_sessionLabel(session)}');
  if (session is! AuthSessionAuthenticated) {
    return const AuthActionResult.failure(
      'Sign in failed: no active session.',
    );
  }

  await _profileSyncRepository.syncUserProfile(session);
  debugPrint('[auth] $label profile sync completed');
  return result;
}
```

Và `signOut` (`:134-146`): `result.isSuccess` →
`_userProfileRepository.resetUserProfile()` — : hành vi nút
reset M10 sống lại đúng nghĩa "sign-out → thiết bị về hồ sơ khách",
không còn là nút bấm trên menu.

`signUpWithEmail` (`:69-101`) — khác ở chỗ: `success` nhưng session
guest (confirm-email) vẫn trả `result` gốc; chỉ `if (session is
AuthSessionAuthenticated)` mới sync. Log `[auth]` đủ ở mỗi nhịp:
requested → repository result → session → sync completed — nhìn log
là thấy chuỗi chạy tới đâu khi debug (không in email/password —
chỉ `emailPresent`/`emailHasAt`/`passwordMeetsMinimum` boolean).

**Bước 5 — `lib/core/app_dependency_scope.dart`** — thêm field + ctor
+ provider (cạnh `authRepository`):

```dart
import '../repositories/profile/user_profile_sync_repository.dart';

  /// M24: seam sync profile → remote. M24 = Disabled no-op;
  /// impl thật (upsert public.users) là M25.
  final UserProfileSyncRepository profileSyncRepository;
  // ctor: required this.profileSyncRepository,
  // providers:
  Provider<UserProfileSyncRepository>.value(value: profileSyncRepository),
```

**Bước 6 — `lib/main.dart`** — chen sau khối auth (nhớ comment "LUÔN
Disabled" đúng shipped):

```dart
  // M24: sync repo LUÔN là Disabled — `UserProfileSyncRepositoryImpl`
  // (merge + upsert `public.users`) là M25. Seam này giữ call-site
  // `coordinator.syncUserProfile` đã đúng mà không fake kết quả sync.
  final UserProfileSyncRepository profileSyncRepository =
      UserProfileSyncRepositoryDisabled();
```

+ `profileSyncRepository: profileSyncRepository,` vào
`AppDependencyScope(...)`.

**Bước 7 — `test/helpers/fake_profile_sync_repository.dart`** (41
dòng, verbatim): seeded `ProfileSyncIdle`; `syncUserProfile` tăng
`syncCallCount` + ghi `lastSyncedSession` + throw `syncError` nếu
script — fake này là cách DUY NHẤT quan sát được coordinator đã gọi
sync với đúng session (impl disabled thật không ghi nhận gì).

**Bước 8 — bốn call-site `AppDependencyScope`** thêm
`profileSyncRepository: FakeUserProfileSyncRepository(),` (compile-forced):
`test/menu_provider_scope_test.dart`, `test/menu_screen_ui_events_test.dart`
(hàm `appUnderTest`), `test/widgets/game_screen_test.dart` (`menuApp`),
`test/widgets/menu_leaderboard_dialog_test.dart` — + import
`helpers/fake_profile_sync_repository.dart`.

## Hiểu code — đọc lại nhịp chuỗi

Trace `signInWithGoogle` thành công có session:
`[auth] google sign-in repository result success=true …` →
`[auth] google sign-in session=authenticated` →
`[auth] google sign-in profile sync completed` → VM nhận result
success. Trace session-guest-sau-success (ca guard):
`… success=true` → `… session=guest` → return failure — KHÔNG có dòng
"sync completed". Ba dòng log kể đúng câu chuyện — khi chạy thật
(LIVE_AUTH_FLOW) đây là điểm đọc đầu tiên.

## Chạy và quan sát

```text
flutter analyze → No issues found!   (sót call-site → required-param error)
flutter test    → +201: All tests passed!  — giữ nguyên: seam mới
                  chưa có consumer test; coverage của coordinator đến
                  qua dialog VM ở Bài 4 (+11/+3).
```

`flutter run` → log DI không đổi (`[auth] repository=disabled`) —
`main()` chưa gọi coordinator (VM dialog mới tạo nó ở Bài 4).

## Thử nghiệm

Đoán `syncStateStream.value` của `UserProfileSyncRepositoryDisabled()`
sau khi gọi `syncUserProfile(session)` — và vì sao.

<details>
<summary>Đáp án</summary>

Vẫn `ProfileSyncIdle` — body `async {}` không emit gì. Stream tồn tại
để consumer M25 subscribe cùng contract; Disabled chỉ giữ "giá trị
hợp lệ mặc định". Đúng tinh thần `DisabledAuthRepository` seed Guest.
</details>

## Lỗi hay gặp

1. **Tin `AuthActionResult.success` là "đã đăng nhập".** Result chỉ
 nói action không lỗi — guard đọc lại session mới là bản án. Bỏ
 guard = bug lặng (exercise dưới).
2. **Gọi `syncUserProfile` với `AuthSessionData`.** Chữ ký đòi
 `AuthSessionAuthenticated` — compiler bắt ngay; `is`/`is!` check
 không phải formalism, nó là type-level precondition.
3. **Áp guard sign-in cho sign-up.** Success không session của
 sign-up (confirm-email) là hợp lệ — nhánh riêng của
 `signUpWithEmail` tồn tại đúng vì thế.
4. **Gọi `resetUserProfile()` kể cả khi sign-out fail.** Chuỗi chỉ
 chạy `if (result.isSuccess)` — sign-out fail thì profile giữ nguyên
 (test Bài 4 khóa điều này: "failed sign out … preserves profile").
5. **Đặt impl sync thật vào `main()` sớm.** `main()` cố ý LUÔN
 Disabled ở M24 — đổi sớm sẽ gọi `public.users` khi RLS/schema
 chưa theo kịp (M25 mới làm).

## Tự làm — DEBUG + PREDICT (bắt buộc, ca trồng bug thật)

**Setup** — tạo file scratch `test/m24_coordinator_guard_exercise_test.dart`
(chỉ để exercise — sẽ xoá sau, không tính vào suite 224):

```dart
import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_auth_action_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_profile_sync_repository.dart';

void main() {
  test('repo báo success nhưng session vẫn guest → failure', () async {
    SharedPreferences.setMockInitialValues({});
    final profile = await UserProfileRepositoryImpl.create();
    addTearDown(profile.dispose);

    // Fake trả success VÀ emit Guest — "sign-in không tạo session".
    final auth = FakeAuthRepository(
      signInSession: const AuthSessionGuest(),
    );
    addTearDown(auth.dispose);
    final sync = FakeUserProfileSyncRepository();
    addTearDown(sync.dispose);

    final coordinator = MenuAuthActionCoordinator(
      authRepository: auth,
      userProfileRepository: profile,
      profileSyncRepository: sync,
    );

    final result = await coordinator.signInWithGoogle();

    expect(result.isSuccess, isFalse);
    expect(result.message, 'Sign in failed: no active session.');
    expect(sync.syncCallCount, 0);
  });
}
```

Chạy `flutter test test/m24_coordinator_guard_exercise_test.dart` →
xanh. Giờ **trồng bug**: trong `menu_auth_action_coordinator.dart`,
thay guard + sync (`:120-127`) bằng:

```dart
    if (session is AuthSessionAuthenticated) {
      await _profileSyncRepository.syncUserProfile(session);
    }
```

**PREDICT trước khi chạy**: test đỏ hay xanh? `result.isSuccess`
nhận gì? `syncCallCount`? `result.message`?

<details>
<summary>Đáp án + giải thích</summary>

Test ĐỎ tại `expect(result.isSuccess, isFalse)` — Expected: `false`,
Actual: `true`. Coordinator bỏ guard → repo báo success → trả
success ngay dù `session` là `AuthSessionGuest`; `syncCallCount`
vẫn `0` (nhánh `is` mới cũng skip Guest → assert đó vẫn qua — bẫy
"test xanh một nửa"). Message trả `'Signed in successfully.'` thay
`'Sign in failed: no active session.'`.

Root cause: hai kênh result-vs-session lệch nhau (Bài 1) và không còn
ai đối chiếu. Đây chính là bug lớp "silent success": VM Bài 4 sẽ
dismiss dialog + báo "Signed in successfully." trong khi app vẫn
guest — user tưởng đã đăng nhập. Trong suite thật, test
`'success without session → failure "no active session" (guard)'`
(`menu_auth_dialog_view_model_test.dart:374`, vào ở Bài 4) bắt đúng
ca này với cùng script `signInSession: AuthSessionGuest()`.

Khôi phục guard + `syncUserProfile(session)` nguyên văn, chạy lại
scratch test → xanh, rồi **xoá file scratch** để suite giữ số đếm
milestone.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao `syncUserProfile` nhận `AuthSessionAuthenticated`
 thay vì `AuthSessionData`? — **Đáp:** sync chỉ có nghĩa với phiên
 thật; kiểu hẹp ép caller `is`-check trước khi gọi — precondition
 ở type level, không phải convention.
- **Hỏi:** hai chỗ sign-in và sign-up khác nhau thế nào trong việc
 xử lý "success nhưng guest"? — **Đáp:** sign-in → failure
 `'no active session'` (không session = không đăng nhập); sign-up →
 trả result gốc + chỉ sync nếu authenticated (confirm-email hợp lệ).
- **Hỏi:** `resetUserProfile()` được gọi từ đâu trong M24, và nó
 thay thế cái gì? — **Đáp:** `MenuAuthActionCoordinator.signOut()`
 sau sign-out success — semantics nút "ĐẶT LẠI HỒ SƠ" M10, giờ là
 converge (Bài 5 mới xoá nút vật lý).

## Ta cố ý chưa thêm

- `UserProfileSyncRepositoryImpl` — merge local↔remote + upsert
 `public.users` + emit InProgress/Failed lên `syncStateStream`:
 **M25** (khi đó `main()` đổi một dòng `Disabled` → `Impl`).
- Dialog VM tiêu thụ coordinator — **Bài 4**; UI gọi chúng — **Bài 5**.
- Consumer của `syncStateStream` (progress UI/sync status) — **M25+**.
- Realtime sync, conflict resolution nâng cao — senior không có.

## Checkpoint hoàn thành

- [ ] `profile_sync_state_data.dart` sealed 3 variant;
 contract + `UserProfileSyncRepositoryDisabled` (seed `ProfileSyncIdle`,
 `syncUserProfile` no-op) tồn tại.
- [ ] `menu_auth_action_coordinator.dart` có `_signInAndSync` với
 guard `is! AuthSessionAuthenticated → failure('Sign in failed: no
  active session.')`, sign-up branch riêng, `signOut → resetUserProfile()`.
- [ ] `AppDependencyScope` + `main()` có `profileSyncRepository`
 (LUÔN `UserProfileSyncRepositoryDisabled()`); 4 call-site truyền
 `FakeUserProfileSyncRepository()`.
- [ ] `flutter analyze` sạch; `flutter test` **201/201**.
- [ ] DEBUG exercise: trồng bug → scratch test đỏ đúng
 `isSuccess` assert → khôi phục → xanh → file scratch đã xoá.
