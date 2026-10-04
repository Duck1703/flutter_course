---
title: "Bài 4 · Dialog VMs, single-flight & MenuViewModel nhận auth"
description: "Hai dialog-scoped VM với sealed UiEvent (Dismiss/SnackBar — snackbar dời từ menu VM xuống dialog VM), _isLoading chặn double-tap, _isDisposed guard. MenuViewModel +AuthRepository (seed/sub/isAuthenticated/loadUserProfile dual); LeaderboardDialogViewModel nhận AuthRepository + switch(authState) → uid. +18 test → 219."
sidebar:
 label: "Bài 4 · dialog VMs + menu auth"
 order: 4
---

## Mục tiêu

- Port hai **dialog-scoped VM** (sống/chết cùng dialog):
 `MenuAuthDialogViewModel` + sealed `MenuAuthDialogUiEvent`, và
 `MenuSignOutDialogViewModel` + sealed `MenuSignOutDialogUiEvent` —
 mỗi family hai variant: `DismissRequested` / `SnackBarRequested`.
- Hiểu ba cơ chế: **single-flight** `_isLoading` (action đang chạy →
 call tiếp trả `false` ngay), guard `_isDisposed` (result về sau
 khi VM chết → không emit/notify), và result→event dịch
 (success → dismiss + snackbar; failure → chỉ snackbar).
- `MenuViewModel` nhận `AuthRepository`: seed `_authState` +
 subscribe + `isAuthenticated` + `loadUserProfile` gọi cả hai repo —
 cùng pattern `_userData` của M14, áp dụng cho session.
- ** closed**: `LeaderboardDialogViewModel` +`AuthRepository`,
 `_currentLeaderboardUserId()` = exhaustive `switch(authState)` —
 authed → `uid`, guest → `null`.
- +18 test (11 auth-dialog VM + 3 sign-out VM + 3 menu-VM auth +
 1 leaderboard) → suite **201 → 219**.

## Bạn đang ở đâu

- Bài 3: coordinator + sync seam đã vào; suite 201/201. Coordinator
 sẵn sàng được "một ai đó" gọi — bài này chính là hai "ai đó".
- `MenuViewModel` đang chỉ biết profile; pill tài khoản vẫn là UI
 tĩnh (Bài 5 mới nối tap → `requestAuthAction` + hai event mới).

## Vì sao việc này quan trọng ngay bây giờ

Ba trụ cột cần hiểu:

**① VM thuộc về dialog, không thuộc màn hình.** Auth dialog chỉ tồn
tại khi đang mở → VM của nó "dialog-scoped": `ChangeNotifierProvider`
trong dialog scope tạo nó và **tự dispose** khi dialog rời cây (cùng
pattern `LeaderboardDialogViewModel` của M23). Hệ quả: mọi cấu hình
"VM sống lâu" — singleton, app-scope — đều sai chỗ cho việc này.

**② Snackbar dời chủ — converge.** Trước M24, `MenuViewModel`
bắn `MenuSnackBarRequested` cho mọi thông báo — nhưng snackbar kết
quả sign-in thuộc về DIALOG (VM dialog mới biết result). Senior giải
quyết gọn: **mỗi dialog VM có event family riêng** —
`MenuAuthDialogSnackBarRequested` / `MenuSignOutDialogSnackBarRequested`
— và **emit site** `MenuSnackBarRequested` trên menu VM retire
(cùng đợt xoá nút reset ở Bài 5). Bản thân class **giữ trong sealed
family đúng senior** — senior cũng có zero emit sites cho nó; chỉ
chỗ phát event đổi chủ. Một lớp event per-surface thay vì một lớp
event toàn cục.

**③ Single-flight + dispose guard = hai lớp an toàn.** Sign-in gọi
network: người dùng có thể bấm hai lần trong 300ms, hoặc đóng dialog
giữa chừng. `_isLoading` chặn concurrent call (trả `false` ngay);
`_isDisposed` chặn emit vào controller đã `close()` (sẽ ném
`StateError`). Không có hai cờ này = crash race hoặc double-call —
đều là bug khó repro.

## Bạn đã biết gì

- `AuthRepository` + `AuthActionResult` + session model (Bài 1–2);
 `MenuAuthActionCoordinator` + guard (Bài 3).
- `ChangeNotifier` + `notifyListeners` + `context.watch` (M11);
 `StreamController.broadcast` cho event một lần vs `BehaviorSubject`
 cho state (M13/ — **đối lập replay**, VM này dùng đúng broadcast);
 `StreamSubscription` attach/cancel.
- Dialog-scoped VM + `ChangeNotifierProvider` trong scope widget
 (M23 leaderboard dialog — cùng shape); sealed event family.
- `Completer` scripting trong fake (`signInCompleter`… — Bài 2) để
 mô phỏng "call đang chờ" khi test single-flight.

## Mental model — "VM dịch result thành event, bridge dịch event
thành UI"

```text
dialog VM:   action → coordinator → AuthActionResult
               success → emit DismissRequested + SnackBarRequested(msg)
               failure → emit SnackBarRequested(msg)   (dialog Ở LẠI)
             + _isLoading: true → notifyListeners (UI hiện overlay)
             + _isDisposed: mọi emit/notify đều bị chặn

menu VM:     authStateStream ─(seed+subscribe)→ _authState
               isAuthenticated = _authState.isAuthenticated
               (Bài 5: requestAuthAction route theo session này)

leaderboard VM: authStateStream.value ─switch─→ uid? / null
               → repo.loadLeaderboard(currentUserId: …)
```

Vì sao snackbar ở *dialog* VM mà vẫn hiện trong *menu* Scaffold? Vì
`ScaffoldMessenger` lan tỏa lên `MaterialApp` — snackbar bắn từ
route/dialog vẫn render ở Scaffold gần nhất phía dưới (widget test
Bài 5 khóa hành vi này: "snackbar phát TỪ DIALOG VM hiện trong menu
Scaffold, dialog vẫn mở — ").

## Dart/Flutter cần dùng — xuất hiện đầu tiên

| Construct | Vai trò |
|---|---|
| `StreamController<T>.broadcast()` | event một lần — listener đến trễ không nhận event cũ (đúng bản chất event; đối lập `BehaviorSubject` replay của state) |
| `_events.isClosed` | check controller đã close trước `add` — emit vào controller đã close ném `StateError` |
| named-param closure `action: _authActions.signInWithGoogle` | tear-off method làm `Future<AuthActionResult> Function()` |
| `case Variant(final field)` trong `switch(event)` | object pattern bóc `message` của `SnackBarRequested` |

## Ví dụ độc lập — single-flight trong 20 dòng

```dart
class Gate {
  var busy = false;
  var calls = 0;

  Future<bool> run(Future<void> Function() work) async {
    if (busy) return false;      // single-flight: đang chạy → từ chối
    busy = true;
    try {
      calls++;
      await work();
      return true;
    } finally {
      busy = false;              // finally: lỗi cũng phải mở cổng lại
    }
  }
}
```

`finally` là điểm cốt lõi: đặt `busy = false` sau `await` thường thì
exception làm cổng kẹt đóng mãi — mọi call sau trả `false` vô tận.
Cờ `_isLoading` của hai dialog VM đi cùng `notifyListeners()` để UI
hiện overlay chặn tap (Bài 5), nhưng **cờ này mới là nguồn truth** —
overlay chỉ là hậu quả hiển thị.

## Android / Compose bridge

**SIMILARITY — `MutableSharedFlow` event + `StateFlow` state.** Cặp
`events` (broadcast, one-shot) ↔ `_events` của dialog VM đúng vai trò
`SharedFlow` cho snackbar/navigation event; `_isLoading` + notify ↔
`MutableStateFlow<Boolean>`. `ChangeNotifier` ≈ `ViewModel` với
`LiveData`, nhưng notify thủ công.

**IMPORTANT DIFFERENCE — không `viewModelScope`.** Không có coroutine
scope tự huỷ: race "result về sau dispose" phải chặn bằng cờ
`_isDisposed` kiểm tay (và cancel subscription trong `dispose()`).
Kotlin nhờ structured concurrency; ở đây kỷ luật nằm ở hai guard.

**DO NOT ASSUME — `StreamController.broadcast` KHÔNG replay.** Nếu
listener attach sau khi event đã `add`, event đó MẤT — khác hẳn
`BehaviorSubject`/StateFlow giữ latest. Event một lần muốn vậy;
cần "giá trị mới nhất" thì dùng state stream, đừng dùng broadcast.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `view_models/menu/menu_auth_dialog_view_model.dart` | verbatim — `_runAuthAction(label, failurePrefix, action)`, `continueAsGuest`, hai cờ guard |
| `view_models/menu/menu_sign_out_dialog_view_model.dart` | verbatim — `signOut()` cùng skeleton, `'Sign out failed: $error'` |
| `view_models/menu/menu_screen_view_model.dart` | `MenuViewModel` port: auth seed+sub + `isAuthenticated` + `loadUserProfile` gọi cả hai repo + `requestAuthAction` (Bài 5 nối event) |
| `view_models/leaderboard/leaderboard_dialog_view_model.dart` | ctor +`AuthRepository`, `_currentLeaderboardUserId` switch |
| `test/menu_auth_dialog_view_model_test.dart` | 10 ca verbatim + 1 ca learner-add (guard test) |

## Build it step by step

**Bước 1 — `lib/view_models/menu/menu_auth_dialog_view_model.dart`**
(165 dòng, verbatim). Sealed event family trên cùng file:

```dart
sealed class MenuAuthDialogUiEvent { const MenuAuthDialogUiEvent(); }

final class MenuAuthDialogDismissRequested extends MenuAuthDialogUiEvent {
  const MenuAuthDialogDismissRequested();
}

final class MenuAuthDialogSnackBarRequested extends MenuAuthDialogUiEvent {
  final String message;
  const MenuAuthDialogSnackBarRequested(this.message);
}
```

VM ctor nhận BA repo và tự dựng coordinator trong initializer —
`MenuAuthDialogViewModel({required authRepository, required
userProfileRepository, required profileSyncRepository}) :
_events = StreamController<…>.broadcast(),
_authActions = MenuAuthActionCoordinator(…)`. Bốn method public
`signInWithGoogle/Apple/Email` + `signUpWithEmail` đều bọc
`_runAuthAction(label, failurePrefix, action)`; `continueAsGuest()`
chỉ `_emitDismissRequested()` — "vào chơi không cần tài khoản" là
dismiss thuần, không gọi repo nào.

Trục `_runAuthAction` (`:105-136`):

```dart
if (_isLoading) return false;
_setLoading(true);
debugPrint('[auth] $label started');
try {
  final result = await action();
  if (_isDisposed) return false;
  if (result.isSuccess) _emitDismissRequested();
  _emitSnackBar(result.message);
  return result.isSuccess;
} catch (error) {
  _emitSnackBar('$failurePrefix: $error');
  return false;
} finally {
  _setLoading(false);
}
```

Thứ tự event khi success: **dismiss TRƯỚC snackbar** — dialog đóng
rồi snackbar vẫn hiện được (ScaffoldMessenger lan tỏa). Failure:
chỉ snackbar, dialog mở lại cho thử lần nữa.

**Bước 2 — `lib/view_models/menu/menu_sign_out_dialog_view_model.dart`**
(111 dòng, verbatim): cùng skeleton — `MenuSignOutDialogUiEvent`
+ `Dismiss`/`SnackBar` variants; `signOut()` chạy qua coordinator
(coordinator lo `resetUserProfile()`); exception prefix
`'Sign out failed: '`.

**Bước 3 — `lib/view_models/menu/menu_view_model.dart`** — chen auth
(y hệt pattern `_userData`; bản Bài 4 chưa có `requestAuthAction`):

```dart
// import '../../data/auth/auth_session_data.dart';
// import '../../repositories/auth/auth_repository_contract.dart';

  MenuViewModel({
    required UserProfileRepository userProfileRepository,
    required AuthRepository authRepository,          // MỚI
  }) : _userProfileRepository = userProfileRepository,
       _authRepository = authRepository,              // MỚI
       _userData = userProfileRepository.userProfileStream.value,
       _authState = authRepository.authStateStream.value {   // seed
    _userProfileSubscription = _userProfileRepository.userProfileStream
        .listen(_handleUserProfile);
    _authStateSubscription = _authRepository.authStateStream   // subscribe
        .listen(_handleAuthState);
  }

  final AuthRepository _authRepository;
  StreamSubscription<AuthSessionData>? _authStateSubscription;
  AuthSessionData _authState;

  /// True khi phiên authenticated — lái pill Bài 5.
  bool get isAuthenticated => _authState.isAuthenticated;

  Future<void> loadUserProfile() async {
    await _userProfileRepository.loadUserProfile();
    await _authRepository.loadAuthState();   // fan-out cả hai (senior)
  }

  void _handleAuthState(AuthSessionData authState) {
    if (_isDisposed) return;
    final shouldNotify = _authState != authState;
    _authState = authState;
    if (shouldNotify) notifyListeners();
  }
  // dispose: _authStateSubscription?.cancel();
```

`requestAuthAction()` + hai event mới để **Bài 5** — nó cần
`MenuAuthRequested`/`MenuSignOutRequested` chưa tồn tại (cùng đợt
`resetProfile()` retire — emit site `MenuSnackBarRequested` đi
theo, class giữ nguyên trong family).

**Bước 4 — `lib/view_models/leaderboard/leaderboard_dialog_view_model.dart`**
— : ctor thêm `required AuthRepository authRepository` (giữa
leaderboard và userProfile — đúng thứ tự senior), field, và thay
`_currentLeaderboardUserId()`:

```dart
String? _currentLeaderboardUserId() {
  return switch (_authRepository.authStateStream.value) {
    AuthSessionAuthenticated(:final uid) => uid,
    AuthSessionGuest() => null,
  };
}
```

`(:final uid)` là object-pattern bóc field — authed thì uid đi xuống
`loadLeaderboard(currentUserId:)` (repo remote query thêm hàng của
người chơi), guest → `null` → hàng "bạn" rơi về profile local.

**Bước 5 — `lib/widgets/menu/leaderboard/menu_leaderboard_dialog_scope.dart`**
— thêm `final AuthRepository authRepository` + `required` + truyền
vào `create:`; `showLeaderboardDialog` đọc thêm
`context.read<AuthRepository>()` trước khi dựng scope.

**Bước 6 — `lib/screens/menu_screen.dart`** — `create:` truyền repo:

```dart
create: (context) => MenuViewModel(
  userProfileRepository: context.read<UserProfileRepository>(),
  authRepository: context.read<AuthRepository>(),    // MỚI
)..loadUserProfile(),
```

**Bước 7 — test compile-forced.** Các call-site bị chữ ký mới ép:
`test/menu_view_model_test.dart` `makeVm(repo, {authRepository})` +
`authRepository ?? FakeAuthRepository()`; `test/view_models/
leaderboard/leaderboard_dialog_view_model_test.dart` `createViewModel`
+`authRepository`; `test/widgets/menu_leaderboard_dialog_test.dart`
hai `MenuLeaderboardDialogScope(...)` +`authRepository: FakeAuthRepository()`;
`test/widgets/onboarding_overlay_test.dart` MultiProvider thêm
`Provider<AuthRepository>.value` + `Provider<UserProfileSyncRepository>.value`
(auth bắt buộc vì `MenuScreen.create` đọc; sync mirror app-scope).

**Bước 8 — hai file test mới.**
`test/menu_auth_dialog_view_model_test.dart` (404 dòng, 11 test —
verbatim senior + 1 ca learner): Google/Apple/email ×(success→
sync+dismiss+snackbar / failure→no-dismiss-no-sync), single-flight
qua completer, email sign-up có session→sync / không session→
dismiss không sync (confirm-email), dispose giữa chừng→không notify,
và ca guard `'success without session → failure "no active session"'`
(fake `signInSession: AuthSessionGuest()` — đúng bug Bài 3).
`test/menu_sign_out_dialog_view_model_test.dart` (167 dòng, 3 test):
success → `resetUserProfile` áp dụng (profile về mặc định) + Guest
emit + dismiss+snackbar (core); failure → dialog ở lại +
profile giữ + session vẫn authed; duplicate-tap single-flight.

**Bước 9 — `menu_view_model_test.dart`** thêm group M24, ba test
auth-state: seed guest→`isAuthenticated` false; seed authed→true;
emit authed→flip+notify một lần. (Ba test `requestAuthAction` đến
Bài 5 cùng method.)

## Hiểu code — hai quyết định thiết kế

1. **Vì sao VM tự `new` coordinator thay vì inject sẵn?** Vì senior
 định vị coordinator là *detail của dialog VM*: ctor VM nhận BA
 repo (shape cố định để M25 không đổi signature khi sync impl
 thật vào) rồi dựng coordinator bên trong. Test vẫn script đủ mọi
 hành vi qua ba repo — không mất khả năng test, mà call-site gọn.
2. **`return false` hai nơi trong `_runAuthAction` — khác nhau gì?**
 `if (_isLoading) return false` = "đang bận, từ chối call" (call
 thứ hai); `if (_isDisposed) return false` sau `await` = "VM chết
 rồi, nuốt kết quả" (call thứ nhất về trễ). Cùng `false` nhưng
 ngữ nghĩa khác — một chặn *vào*, một chặn *ra*.

## Chạy và quan sát

```text
flutter analyze → No issues found!   (sót call-site → required-param)
flutter test test/menu_auth_dialog_view_model_test.dart      → 11/11
flutter test test/menu_sign_out_dialog_view_model_test.dart  → 3/3
flutter test    → +219: All tests passed!   (201 + 11 + 3 + 3 + 1)
```

Đếm đúng: file auth-dialog VM +11, sign-out VM +3, menu VM auth-state
+3, leaderboard VM +1 → +18. `requestAuthAction` test và pill
UI là Bài 5 (+5 net).

## Thử nghiệm

Đoán: test `'duplicate social taps are blocked while Apple sign in
loads'` script `appleSignInCompleter` — call 1 đang chờ, call 2 được
gọi. `secondSignIn` trả gì, `appleSignInCallCount` mấy, `isLoading`?

<details>
<summary>Đáp án</summary>

`secondSignIn == false` ngay lập tức (single-flight chặn vào),
`appleSignInCallCount == 1` (repo chỉ bị gọi một lần — call 2 chết
ở guard, không đến repo), `isLoading == true` cho tới khi completer
complete → call 1 trả `true`, `isLoading` về `false`. Đây là lý do
fake có `…Completer`: mô phỏng "call đang treo" mà không cần network.
</details>

## Lỗi hay gặp

1. **Bắn snackbar từ menu VM cho kết quả sign-in.** Result sống ở
 dialog VM — menu VM không biết gì về call vừa chạy — mỗi
 surface tự lo event của nó.
2. **`_setLoading` quên guard `==`.** `_setLoading` chỉ notify khi
 giá trị ĐỔI (`_isLoading == isLoading → return`) — gọi
 `notifyListeners` vô điều kiện sẽ spam rebuild.
3. **Emit sau `dispose()`.** `_emitSnackBar`/`_emitDismissRequested`
 có guard `_isDisposed || _events.isClosed` — bỏ guard sẽ ném
 `StateError: Cannot add event after closing` khi result về trễ.
4. **Dùng `BehaviorSubject` cho dialog events.** Event một lần phải
 broadcast — listener attach sau khi dialog mở sẽ được replay event
 cũ nếu subject (dismiss dialog lần hai ngay khi mở — bug khó chịu).
5. **`switch(authState)` viết `if/else` thay exhaustive.** Sealed
 switch ép xử lý đủ variant — dùng `switch` expression đúng
 vì vậy; `if (is AuthSessionAuthenticated)` bỏ sót variant tương
 lai âm thầm.
6. **Gọi `syncUserProfile` từ VM thay vì coordinator.** Sync là bước
 của CHUỖI (Bài 3) — VM gọi trực tiếp repo sync là copy nửa chuỗi,
 mất guard `loadAuthState`.

## Tự làm — PRODUCE (bắt buộc)

Viết MỘT behavior-test mới cho `MenuSignOutDialogViewModel` trong
file scratch `test/m24_signout_exercise_test.dart` (xoá sau exercise —
không tính suite 224). Yêu cầu phải chứng minh được **cả ba**:

1. Fake script `signOutResult` là **failure**(`'Sign out failed.'`)
 và `initialSession` là `AuthSessionAuthenticated(uid: 'u-9')`.
2. Sau `await vm.signOut()`: result `false`; **profile KHÔNG bị
 reset** (assert `userProfileStream.value` giữ nguyên — seed sẵn
 profile khác default trước khi tạo VM); `signOutCallCount == 1`.
3. `SnackBarRequested` emit đúng `'Sign out failed.'` và KHÔNG có
 `DismissRequested` (dialog ở lại).

Gợi ý: mirror shape `createViewModel` của
`menu_sign_out_dialog_view_model_test.dart` (ba repo + VM + addTearDown);
profile khác default seed qua `SharedPreferences.setMockInitialValues`
+ `UserProfileRepositoryImpl.create()` rồi `saveUserProfile`.

<details>
<summary>Đáp án mẫu</summary>

```dart
import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/repositories/auth/auth_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_sign_out_dialog_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_profile_sync_repository.dart';

void main() {
  test('sign-out failure keeps dialog, session and profile', () async {
    SharedPreferences.setMockInitialValues({});
    final profile = await UserProfileRepositoryImpl.create();
    addTearDown(profile.dispose);
    await profile.saveUserProfile(
      const UserProfileData(username: 'Keeper', level: 9),
    );

    final auth = FakeAuthRepository(
      initialSession: const AuthSessionAuthenticated(uid: 'u-9'),
      signOutResult: const AuthActionResult.failure('Sign out failed.'),
    );
    addTearDown(auth.dispose);
    final sync = FakeUserProfileSyncRepository();
    addTearDown(sync.dispose);

    final vm = MenuSignOutDialogViewModel(
      authRepository: auth,
      userProfileRepository: profile,
      profileSyncRepository: sync,
    );
    addTearDown(vm.dispose);

    final events = <MenuSignOutDialogUiEvent>[];
    final sub = vm.events.listen(events.add);
    addTearDown(sub.cancel);

    final didSignOut = await vm.signOut();
    await pumpEventQueue();

    expect(didSignOut, isFalse);
    expect(auth.signOutCallCount, 1);
    expect(profile.userProfileStream.value.username, 'Keeper');
    expect(
      events.whereType<MenuSignOutDialogSnackBarRequested>()
          .single.message,
      'Sign out failed.',
    );
    expect(
      events.whereType<MenuSignOutDialogDismissRequested>(),
      isEmpty,
    );
  });
}
```

Chạy `flutter test test/m24_signout_exercise_test.dart` → xanh →
xoá file. Điểm chính: `coordinator.signOut` chỉ `resetUserProfile()`
khi result success — fake failure khiến profile 'Keeper' sống sót,
và VM giữ dialog mở (không DismissRequested).
</details>

## Kiểm tra hiểu biết

- **Hỏi:** success → VM emit event nào, theo thứ tự nào? — **Đáp:**
 `DismissRequested` rồi `SnackBarRequested(message)` — đóng trước,
 báo sau; snackbar vẫn hiện vì ScaffoldMessenger lan tỏa.
- **Hỏi:** `_isLoading` và `isLoading`-overlay khác nhau thế nào? —
 **Đáp:** cờ trong VM là nguồn truth chặn double-call; overlay UI
 (Bài 5) chỉ hiển thị theo cờ qua `context.watch` — bỏ overlay vẫn
 chặn được call, bỏ cờ thì overlay không còn ý nghĩa.
- **Hỏi:** đóng ở đâu và bằng cơ chế gì? — **Đáp:**
 `LeaderboardDialogViewModel` +`AuthRepository` +
 `_currentLeaderboardUserId()` exhaustive `switch` — authed → uid
 vào `currentUserId`, guest → null (hàng "bạn" rơi về profile
 local); test assert `lastCurrentUserId == 'auth-uid-1'`.

## Ta cố ý chưa thêm

- `MenuAuthRequested`/`MenuSignOutRequested` events +
 `requestAuthAction()` + retire `resetProfile` + emit site
 `MenuSnackBarRequested` — **Bài 5** (cùng đợt event-set đổi;
 class `MenuSnackBarRequested` giữ nguyên senior-true).
- Widget dialog + scope + pill tap + ARB — **Bài 5**.
- `MenuDialogLayer`/`MenuDialogState` transport của senior — **M29**
 (learner giữ event một lần + `showDialog` — còn mở).
- `UserProfileSyncRepositoryImpl` — **M25**.

## Checkpoint hoàn thành

- [ ] Hai dialog VM + hai sealed event family tồn tại; mỗi VM có
 `_isLoading` single-flight + `_isDisposed` guard + result→event
 dịch đúng (success: dismiss+snackbar; failure: snackbar).
- [ ] `MenuViewModel` seed/sub `authStateStream`, `isAuthenticated`,
 `loadUserProfile` fan-out; `LeaderboardDialogViewModel` + scope
 nhận `AuthRepository` + `switch(authState)` → uid/null.
- [ ] `menu_screen.dart` `create:` truyền `AuthRepository`; các
 call-site test bị chữ ký ép đã cập nhật.
- [ ] `flutter analyze` sạch; `flutter test` **219/219**
 (201 + 11 + 3 + 3 + 1).
- [ ] PRODUCE exercise: scratch sign-out-failure test chạy xanh,
 assert đủ profile-preserved + không dismiss + callCount; file đã
 xoá.
