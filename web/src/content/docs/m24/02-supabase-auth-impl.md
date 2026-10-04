---
title: "Bài 2 · AuthRepositoryImpl trên Supabase + Google v7 (+ Apple appendix)"
description: "GoogleAuthServiceImpl — google_sign_in v7 (initialize một lần + authenticate(scopeHint), KHÔNG legacy signIn); AuthRepositoryImpl seeded từ client.auth.currentUser + onAuthStateChange→guest-on-error + signInWithIdToken/signInWithPassword/signUp/signOut + _sessionFromUser metadata mapping; main conditional DI. APPENDIX: Apple service + _sessionProfileOverride + sha256 nonce. +2 test → 201."
sidebar:
 label: "Bài 2 · Supabase impl + Google v7"
 order: 2
---

## Mục tiêu

- Port 
`GoogleAuthServiceImpl`
 trên **
`google_sign_in`
 v7** — API mới:
 
`GoogleSignIn.instance.initialize(...)`
 đúng một lần rồi
 
`authenticate(scopeHint:)`; KHÔNG tồn tại 
`signIn()`
 legacy.
- Port 
`AuthRepositoryImpl`
 — impl 
`AuthRepository`
 trên Supabase:
 subject seed từ 
`client.auth.currentUser`, listener
 
`onAuthStateChange`
 (lỗi → về Guest), bốn đường sign-in
 (`signInWithIdToken`
 cho Google/Apple, 
`signInWithPassword`,
 
`signUp`), 
`signOut`
 hai lớp, 
`_sessionFromUser`
 map metadata
 phòng thủ.
- Nối 
`main()`
: 
`client == null ? DisabledAuthRepository : AuthRepositoryImpl`

 — cùng dấu 
`?:`
 của leaderboard, + scope nhận 
`AuthRepository`.
- +2 test mapping Apple → suite **199 → 201**.

## Bạn đang ở đâu

- Bài 1: session model + contract + 
`DisabledAuthRepository`
 đã vào;
 suite 199/199. Barrel 
`auth_repository.dart`
 còn thiếu export thứ ba.
- 
`SupabaseClientService.initialize`
 (M23) đã trả 
`SupabaseClient?`

 từ 
`main()`
 — impl remote đã có "ổ cắm".
- Bài này lấp nhánh "configured" của auth: service OAuth + impl
 Supabase + DI + scope, đồng thời port hai fake helper phục vụ test.

## Vì sao việc này quan trọng ngay bây giờ

Contract Bài 1 chỉ là cái vỏ. Câu hỏi thật của bài này: **session
trong stream đến từ đâu?** Câu trả lời của senior gọn đến mức đáng
học thuộc — BA nguồn đổ về MỘT 
`BehaviorSubject`
:

1. **Ctor seed**: 
`client.auth.currentUser`
 — Supabase SDK tự nhớ
 session trên thiết bị (secure storage); mở app lại mà vẫn "đã đăng
 nhập" là nhờ seed này, không phải phép màu.
2. **
`onAuthStateChange`
 listener**: MỌI thay đổi auth phía Supabase
 (signIn/signOut/token refresh/session hết hạn) tự chảy về stream —
 kể cả thay đổi không do app gây ra.
3. **Emit sau mỗi action**: sign-* thành công → map response → 
`_emit`.

Một đầu ra duy nhất = một nguồn truth duy nhất. UI/VM chỉ subscribe

`authStateStream`
 — không cần biết session vừa đổi vì ai.

:::caution[LIVE_AUTH_FLOW: NOT_PERFORMED]
Môi trường khóa không có credential Supabase/Google/Apple — các
đường chạy thật của impl này **không được thực thi ở đây** (giống

`LIVE_SUPABASE_CONNECTIVITY`
 của M23). Code là port verbatim senior;
hành vi được khóa bằng fake ở contract-boundary + test mapping thuần.
Chạy với project riêng là OPTIONAL — Bài 5.
:::

## Bạn đã biết gì

- Contract + model + Disabled impl (Bài 1).
- 
`SupabaseClient`
 từ 
`SupabaseClientService.initialize`
 + 
`client ==
 null ? … : …`
 (M23); 
`SupabaseEnvironment`
 + hai key
 
`GOOGLE_*`.
- 
`BehaviorSubject.seeded`
 + 
`.value`
 + 
`isClosed`;
 
`StreamSubscription`
/
`listen`
/
`onError`
/
`cancel`; 
`unawaited`; 
`try`
/
`on`
/
`catch`
 phân loại exception.
- 
`Map<String, dynamic>`
 đọc phòng thủ; 
`??`
/nullable;
 
`static`
 method; 
`typedef`
 (mới — gloss bên dưới).

## Mental model mới — "idToken là hộ chiếu, Supabase session là visa"

Sign-in OAuth với Supabase luôn là **hai chặng**, và trộn hai chặng
là lỗi thiết kế kinh điển:

```text
CHẶNG 1 — provider (Google/Apple):   xin "hộ chiếu" = idToken
   GoogleAuthService.signIn() → GoogleAuthTokens{idToken, accessToken?}
   (idToken = JWT provider ký, chứng minh "đây là user X của Google")

CHẶNG 2 — Supabase:                  đổi hộ chiếu lấy "visa" = session
   client.auth.signInWithIdToken(provider: OAuthProvider.google,
     idToken: tokens.idToken, accessToken: tokens.accessToken)
   → AuthResponse{session, user} → _sessionFromUser → emit
```

Vì sao tách? Vì chặng 1 là chuyện của package nền tảng (mở sheet
chọn tài khoản, hứng cancel/exception riêng), còn chặng 2 là chuyện
của backend (verify chữ ký, cấp session). Service bọc chặng 1 sau
contract 
`GoogleAuthService`
 trả 
`GoogleAuthTokens?`
 — repo chỉ thấy
token, không thấy API của 
`google_sign_in`. Đó là cùng lý do lớp
service tồn tại: **package thay đổi thì chỉ service đổi** (v6→v7 là
bằng chứng sống — xem dưới).

## Dart/Flutter cần dùng — xuất hiện đầu tiên

| Construct | Vai trò |
|---|---|
| 
`GoogleSignIn.instance.initialize(clientId:, serverClientId:)`
 | **v7** (guided): khởi tạo singleton một lần — 
`clientId`
 = iOS client id, 
`serverClientId`
 = **Web client id** mà Supabase verify idToken bằng |
| 
`GoogleSignIn.instance.authenticate(scopeHint:)`
 | **v7**: mở flow chọn tài khoản → 
`GoogleSignInAccount`
 |
| 
`account.authentication.idToken`
 | idToken cho Supabase (nullable — check trước khi dùng) |
| 
`account.authorizationClient.authorizationForScopes(scopes)`
 / 
`authorizeScopes`
 | lấy accessToken cho scope đã xin — best-effort |
| 
`GoogleSignInException`
 + 
`GoogleSignInExceptionCode.canceled`
 | package ném typed exception — repo map 
`canceled`
 → message |
| 
`client.auth.signInWithIdToken(provider:, idToken:, accessToken:, nonce:)`
 | Supabase đổi idToken provider → session (guided) |
| 
`client.auth.signInWithPassword(email:, password:)`
 / 
`signUp`
 / 
`signOut`
 | email auth trực tiếp |
| 
`client.auth.onAuthStateChange`
 | 
`Stream<AuthState>`
 — mọi đổi auth server-side emit về (applied) |
| 
`AuthException`
 / 
`AuthResponse`
 / 
`User.userMetadata`
 | type của 
`supabase_flutter`
 cho auth |
| 
`typedef Name = ReturnType Function(params)`
 | đặt tên cho chữ ký hàm — seam inject hàm vào ctor (dùng ở appendix) |

**V7 khác v6 ra sao** (quan trọng — đừng Google rồi chép code cũ):
v6 dùng 
`GoogleSignIn(scopes:).signIn()`
 trên instance tự tạo. v7 bỏ
hẳn API đó: phải 
`initialize`
 trên 
`GoogleSignIn.instance`
 **đúng một
lần** rồi 
`authenticate(scopeHint:)`. Impl giữ cờ 
`_isInitialized`

chặn gọi 
`initialize`
 hai lần — v7 yêu cầu vậy. Trong code learner
không có 
`signIn()`
 nào của package (grep chỉ thấy trong comment) —
nếu gặp tutorial dùng 
`GoogleSignIn().signIn()`, đó là v6, bỏ.

## Ví dụ độc lập — hai chặng trong 20 dòng

```dart
// Mô phỏng "token provider → session backend" không cần package.
class ProviderTokens { final String idToken; const ProviderTokens(this.idToken); }

abstract interface class ProviderService {
  Future<ProviderTokens?> signIn(); // null = user cancel
}

class FakeProvider implements ProviderService {
  @override
  Future<ProviderTokens?> signIn() async => const ProviderTokens('fake-jwt');
}

Future<String> signIn(ProviderService p, {required bool backendUp}) async {
  final tokens = await p.signIn();          // CHẶNG 1: provider
  if (tokens == null) return 'cancelled';   // user bấm huỷ → KHÔNG gọi backend
  if (!backendUp) return 'backend failed';  // CHẶNG 2: đổi idToken lấy session
  return 'session of ${tokens.idToken}';
}
```

Ba kết quả tách bạch (cancel / backend fail / success) chính là ba
nhánh 
`AuthActionResult`
 của 
`signInWithGoogle`
 — service trả 
`null`

cho cancel, repo map exception cho phần còn lại.

## Android / Compose bridge

**SIMILARITY — giống Credential Manager + FirebaseAuth exchange.**
Đây chính là 
`GetCredentialRequest`
 (Google ID option → idToken) rồi

`FirebaseAuth.signInWithCredential(GoogleAuthProvider.getCredential
(idToken))`
: provider token → backend session, cùng hai chặng.

**IMPORTANT DIFFERENCE — singleton v7, không builder.** Android quen

`GoogleSignIn.getClient(activity, options)`
 trả client mỗi lần; v7 của

`google_sign_in`
 là 
`GoogleSignIn.instance`
 — initialize một lần,

`authenticate`
 mọi lần sau. Gọi 
`initialize`
 lần hai là lỗi → cờ

`_isInitialized`
 trong impl.

**DO NOT ASSUME — 
`serverClientId`
 KHÔNG phải Android client id.**
Đây là bẫy cấu hình kinh điển: 
`serverClientId`
 nhận **Web client id**
(của OAuth client loại "Web application" trong Google Cloud) vì
Supabase verify idToken với audience đó — Android/iOS client id sẽ
làm verify fail. Learner đọc nó từ 
`GOOGLE_WEB_CLIENT_ID`

(dart-define — không commit giá trị).

:::tip[Suy luận trước khi đọc code — DERIVE]
File sắp đọc dài 317 dòng. Đừng đọc như "đáp án" — hãy tự thiết kế
khung của nó trước trên giấy / file nháp. Dùng những gì đã có:
contract `AuthRepository` + `AuthActionResult` (Bài 1), sealed
`AuthSessionData` (Bài 1), `SupabaseClient` và ternary DI (M23),
`BehaviorSubject` seeded (Bài 1 đã thấy trong impl Disabled).

1. **Bề mặt API công khai.** Liệt kê method mà repo auth phải expose
   để `main()`, VM và UI dùng được: luồng session hiện tại (stream
   hay getter?), đăng nhập email, đăng nhập Google, đăng xuất. Viết
   chữ ký bạn cho là đúng cho từng cái — kiểu trả về là gì:
   `Future<void>`, `Future<AuthActionResult>`, hay throw?
2. **Ma trận session-variant.** Với mỗi API ở (1): khi thành công
   thì stream phát variant nào của `AuthSessionData`? Khi user hủy
   giữa chừng? Khi lỗi mạng? Variant nào là trạng thái "mặc định
   an toàn" khi không biết lỗi là gì?
3. **Ranh giới SDK vs abstraction.** Trong chuỗi Google-sign-in hai
   chặng, việc nào thuộc `google_sign_in` (plugin), việc nào thuộc
   Supabase SDK, và việc nào thuộc *repo* — phần abstraction của riêng
   app? Gạch một đường: bên trái là thư viện, bên phải là code của
   bạn.
4. **Hai nguồn phát session.** Constructor impl cần phát session từ
   *hai* nguồn: cái gì đã sót lại từ lần chạy trước, và cái gì đến
   trong tương lai. Dự đoán cơ chế cho mỗi nguồn trước khi đọc.
5. **Lỗi nào throw, lỗi nào trả.** Nhìn contract `AuthActionResult`:
   trường hợp nào xứng đáng là giá trị trả về, trường hợp nào là
   exception? Nêu tiêu chí bạn dùng để phân loại.

Sau đó mới đọc năm cụm bên dưới và **đối chiếu** — khác biệt là bài
học, giống nhau là bằng chứng bạn suy luận đúng hướng. 317 dòng còn
lại là *plumbing*: port cơ khí, không phải phần phải suy ra.

<details>
<summary>Đối chiếu sau khi tự thiết kế</summary>

1. API: `authStateChanges` (Stream), `currentSession` (getter),
   `signInWithEmail`, `signInWithGoogle`, `signInWithApple`,
   `signOut` — tất cả trả `Future<AuthActionResult>` trừ
   stream/getter.
2. Thành công → `AuthSessionAuthenticated`; hủy giữa chừng → giữ
   session cũ (không phát gì); lỗi → `AuthActionResult.failure`
   *và* stream vẫn giữ variant cũ; onError của listener →
   `AuthSessionGuest` (mặc định an toàn = guest).
3. Plugin `google_sign_in` = chặng 1 (UI chọn tài khoản, lấy
   idToken); Supabase = chặng 2 (verify idToken, tạo session);
   repo = gọi hai chặng + map kết quả sang `AuthSessionData` +
   `AuthActionResult` — phần mapping/emit là abstraction của app.
4. Nguồn 1: `client.auth.currentUser` đọc session sót lại → seed
   `BehaviorSubject`. Nguồn 2: `onAuthStateChange.listen` phát
   các thay đổi tương lai.
5. Lỗi *dự đoán được* trong flow bình thường (sai mật khẩu, hủy) →
   `AuthActionResult`; lỗi *hạ tầng không lường trước* → throw/emit
   guest. Tiêu chí senior: caller phải xử lý được giá trị trả về —
   exception dành cho thứ không ai xử lý được.

</details>
:::

## Đọc impl — 
`AuthRepositoryImpl`
 theo nhịp

Port verbatim 
`lib/repositories/auth/supabase_auth_repository.dart`

(317 dòng). Năm cụm cần hiểu:

**① Ctor — seed + listener** (`:49-58`):

```dart
_authStateSubject = BehaviorSubject<AuthSessionData>.seeded(
  _sessionFromUser(client.auth.currentUser),   // nguồn 1: session sót lại
) {
  _authSubscription = _client.auth.onAuthStateChange.listen(
    (state) => _emit(
      _applySessionProfileOverride(_sessionFromUser(state.session?.user)),
    ),
    onError: (_) => _emit(const AuthSessionGuest()),  // nguồn 2: listener
  );
}
```


`currentUser`
 có thể null → 
`_sessionFromUser(null)`
 = 
`AuthSessionGuest`

— app mở lần đầu/khách đều khởi động guest. 
`onError`
 của listener
cũng về Guest: stream lỗi ≠ app chết — session rơi về trạng thái an
toàn nhất. (Lỗi ở đây hiếm — chủ yếu là hàng phòng thủ của senior.)

**② Google — hai chặng rõ rệt** (`:78-104`):

```dart
final tokens = await _googleAuthService.signIn();          // chặng 1
if (tokens == null) {
  return const AuthActionResult.failure('Sign in was cancelled.');
}
final response = await _client.auth.signInWithIdToken(     // chặng 2
  provider: OAuthProvider.google,
  idToken: tokens.idToken,
  accessToken: tokens.accessToken,
);
_emit(_sessionFromAuthResponse(response));                  // nguồn 3
return const AuthActionResult.success('Signed in successfully.');
```

Catch theo thứ tự cụ thể→chung: 
`GoogleSignInException`
 (cancel →
'Sign in was cancelled.', còn lại → description) → 
`AuthException`

(→ 
`error.message`) → 
`catch (error)`
 mọi thứ khác. 
`tokens == null`

là đường cancel *không exception* của service — hai đường cancel cùng
một message.

**③ Email — 
`signInWithPassword`
 trực tiếp** (`:135-151`): 
`email:
email.trim()`
 rồi 
`_emit(_sessionFromAuthResponse(response))`. Và

`signUp`
 (`:158-180`) có nhánh đáng nhớ: **đăng ký có thể không tạo
session** (project bật confirm-email) → 
`_sessionFromActiveSession`

chỉ lấy 
`response.session`; session guest thì trả 
`success`
 kèm
message 
`'Check your email to confirm your account.'`
 — success mà
không authenticated, một edge case hợp lệ mà coordinator Bài 3 xử lý
đúng (chỉ sync khi có session).

**④ 
`_sessionFromUser`
 — map User → session phòng thủ** (`:253-282`):

```dart
static AuthSessionData _sessionFromUser(User? user) {
  if (user == null) return const AuthSessionGuest();
  final metadata = user.userMetadata ?? const <String, dynamic>{};
  final displayName =
      _metadataString(metadata, 'full_name') ?? _metadataString(metadata, 'name');
  final photoUrl =
      _metadataString(metadata, 'avatar_url') ?? _metadataString(metadata, 'picture');
  return AuthSessionAuthenticated(
    uid: user.id, email: user.email,
    displayName: displayName, photoUrl: photoUrl,
  );
}
```


`userMetadata`
 là map tự do của provider — key tùy nguồn (`full_name`

hay 
`name`; 
`avatar_url`
 hay 
`picture`), giá trị có thể thiếu/không
phải String. 
`_metadataString`
 chỉ nhận 
`String`
 non-blank — còn lại

`null`. Đây là defensive mapping áp dụng lại cho auth.

**⑤ 
`_emit`
 + 
`dispose`
** (`:206-210`, 
`:284-288`): emit chỉ khi

`!isClosed && value != state`
 — compare-before-add (cùng kỷ luật

`_handleUserProfile`
 của menu VM); 
`dispose`
 cancel subscription rồi
close subject — hai thứ cần dọn theo đúng thứ tự.


`signOut`
 (`:186-204`): 
`client.auth.signOut()`
 → xoá

`_sessionProfileOverride`
 → emit Guest → 
`googleAuthService.signOut()`

**best-effort trong try lồng** — xoá phiên Google phía thiết bị nhưng
lỗi ở đây KHÔNG được làm kết quả sign-out thất bại (user đã ra rồi).

## APPENDIX — đường Apple (đọc tham khảo, không nằm trên đường bắt buộc)

:::note[APPENDIX — không phải core path]

`sign_in_with_apple`
 + 
`crypto`
 được port đủ để giữ senior parity
(nút Apple chỉ render trên iOS — Bài 5). Phần này **đọc để biết,
không phải học sâu**: trên web/Android nút không tồn tại theo thiết kế.
:::

- 
`lib/services/apple_auth_service.dart`
 (112 dòng, verbatim):
 
`AppleAuthTokens{idToken,rawNonce,email?,givenName?,familyName?}`
 +
 getter 
`displayName`
 (join given+family, bỏ qua phần rỗng — Apple
 chỉ trả tên/email **lần đăng nhập đầu tiên**, không trả lại sau đó);
 
`AppleCredentialRequester`
 là 
`typedef`
 seam — test có thể inject
 hàm request giả.
- **Sha256 nonce (awareness)**: 
`signIn()`
 tạo 
`rawNonce`
 16
 byte 
`Random.secure()`
 → base64url; gửi Apple 
`sha256.convert(
  utf8.encode(rawNonce))`; trả 
`rawNonce`
 gốc cho repo. Supabase gọi
 
`signInWithIdToken(nonce: tokens.rawNonce)`
 — server tự hash lại và
 đối chiếu hash nhúng trong idToken → chống replay (không ai dùng
 lại token cũ được).
- 
`lib/repositories/auth/supabase_auth_repository.dart`
 phần Apple:
 
`signInWithIdToken(provider: OAuthProvider.apple, idToken:, nonce:)`

 → 
`_sessionFromAppleAuthResponse`
 → top-level
 
`authSessionFromAppleAuthResponse(response, tokens, {fallbackUser})`

 — enrich session bằng 
`tokens.email`
/
`tokens.displayName`
 khi
 Supabase thiếu (lần đầu); đồng thời lưu 
`_sessionProfileOverride`

 và 
`_applySessionProfileOverride`
 vá nó vào mọi emit sau (vì
 listener/
`loadAuthState`
 đọc lại từ Supabase sẽ mất các field
 first-login đó). 
`signOut`
 xoá override. Hàm top-level tồn tại để
 test gọi trực tiếp **không cần SupabaseClient** — seam test.

## Build it step by step

**Bước 1 — 
`pubspec.yaml`
** thêm ba pin đúng senior, rồi

`flutter pub get`
:

```yaml
  google_sign_in: ^7.2.0
  sign_in_with_apple: ^8.1.0
  crypto: ^3.0.7
```

**Bước 2 — 
`lib/services/google_auth_service.dart`
** (101 dòng, verbatim). Trục v7:

```dart
class GoogleAuthTokens {
  final String idToken;
  final String? accessToken;
  const GoogleAuthTokens({required this.idToken, this.accessToken});
}

abstract interface class GoogleAuthService {
  Future<GoogleAuthTokens?> signIn();   // null = user cancel
  Future<void> signOut();
}

class GoogleAuthServiceImpl implements GoogleAuthService {
  static const _scopes = ['email', 'profile'];
  final SupabaseEnvironment _environment;
  var _isInitialized = false;                 // v7: initialize MỘT lần

  Future<GoogleAuthTokens?> signIn() async {
    await _initialize();
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw StateError('Google sign-in is not supported on this platform.');
    }
    final account = await GoogleSignIn.instance.authenticate(scopeHint: _scopes);
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.trim().isEmpty) {
      throw StateError('Google did not return an ID token.');
    }
    final authorization =
        await account.authorizationClient.authorizationForScopes(_scopes) ??
        await account.authorizationClient.authorizeScopes(_scopes);
    return GoogleAuthTokens(idToken: idToken, accessToken: authorization.accessToken);
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: _emptyToNull(_environment.googleIosClientId),
      serverClientId: _emptyToNull(_environment.googleWebClientId),
    );
    _isInitialized = true;
  }
}
```

(`signIn`
 trên contract trả 
`GoogleAuthTokens?`
 — 
`null`
 khi user
cancel; impl ném exception cho lỗi thật. 
`_emptyToNull`
 biến 
`''`

thành 
`null`
 — env chưa set → không truyền clientId rỗng.)

**Bước 3 — 
`lib/repositories/auth/supabase_auth_repository.dart`
**
(317 dòng, verbatim — đã mổ ở trên). Bao gồm 
`AuthRepositoryImpl`
 +
top-level 
`authSessionFromAppleAuthResponse`
 (appendix seam).

**Bước 4 — 
`lib/services/apple_auth_service.dart`
** (112 dòng,
verbatim — APPENDIX: port để compile 
`main()`, không cần đọc sâu).

**Bước 5 — barrel 
`lib/repositories/auth/auth_repository.dart`
** —
thêm export thứ ba: 
`export 'supabase_auth_repository.dart';`.

**Bước 6 — 
`lib/core/app_dependency_scope.dart`
** — thêm field +
ctor + provider (giữa 
`leaderboardRepository`
 và

`navigationController`):

```dart
import '../repositories/auth/auth_repository_contract.dart';

  /// M24: repo phiên đăng nhập — conditional như leaderboard.
  final AuthRepository authRepository;
  // ctor: required this.authRepository,
  // providers:
  Provider<AuthRepository>.value(value: authRepository),
```

**Bước 7 — 
`lib/main.dart`
** — chen khối auth vào đúng chỗ (sau
leaderboard ternary, trước 
`navigationController`):

```dart
  debugPrint(
    '[auth] repository=${supabaseClient == null ? 'disabled' : 'supabase'}',
  );
  // ...
  final AuthRepository authRepository = supabaseClient == null
      ? DisabledAuthRepository(environment: supabaseEnvironment)
      : AuthRepositoryImpl(
          client: supabaseClient,
          googleAuthService: GoogleAuthServiceImpl(
            environment: supabaseEnvironment,
          ),
          appleAuthService: AppleAuthServiceImpl(),
        );
```

Cùng một dấu 
`?:`
 của : thiếu config → Disabled (guest + failure
messages); đủ config → impl Supabase bọc hai service OAuth.

**Bước 8 — 
`test/helpers/fake_auth_repository.dart`
** (164 dòng, verbatim senior). Ba nút điều khiển mỗi method:

`…Result`
 (result trả ngay) / 
`…Session`
 (session emit vào subject
khi result success — mô phỏng "repo thật emit sau sign-in") /

`…Completer`
 (giữ future đang chờ để test single-flight — Bài 4);

`…CallCount`
 + 
`lastEmail`
/
`lastPassword`
 cho assert. 
`initialSession`

ctor seed subject (mặc định 
`AuthSessionGuest()`).

**Bước 9 — sửa 4 test call-site (compile-forced).** Ctor

`AppDependencyScope`
 giờ 
`required authRepository`
 — bốn file dựng
scope thêm arg:

```dart
// test/menu_provider_scope_test.dart,
// test/menu_screen_ui_events_test.dart (hàm appUnderTest),
// test/widgets/game_screen_test.dart,
// test/widgets/menu_leaderboard_dialog_test.dart:
  authRepository: FakeAuthRepository(),
// + import 'helpers/fake_auth_repository.dart' (hoặc đường tương đương)
```

**Bước 10 — nối 2 test mapping Apple** vào

`test/supabase_auth_repository_test.dart`
 (thêm imports

`services/apple_auth_service.dart`
 + 
`package:supabase_flutter/
supabase_flutter.dart`; group 
`'authSessionFromAppleAuthResponse
(senior mapping)'`
 — trong file shipped group này đứng ĐẦU 
`main()`,
trước hai group session/disabled của Bài 1):

```dart
  test('Apple auth response preserves first-login profile fields', () {
    final session = authSessionFromAppleAuthResponse(
      AuthResponse(
        user: const User(
          id: 'apple-user',
          appMetadata: <String, dynamic>{},
          userMetadata: <String, dynamic>{},
          aud: 'authenticated',
          createdAt: '2026-06-28T00:00:00Z',
        ),
      ),
      const AppleAuthTokens(
        idToken: 'id-token', rawNonce: 'raw-nonce',
        email: 'apple@example.com', givenName: 'Apple', familyName: 'Player',
      ),
    );
    expect(session, const AuthSessionAuthenticated(
      uid: 'apple-user',
      email: 'apple@example.com',
      displayName: 'Apple Player',
    ));
  });
```

Test hai (verbatim senior): 
`userMetadata`
 có 
`full_name`
 +

`avatar_url`
 + 
`email`
 của Supabase → mapping giữ **Supabase
metadata** (ưu tiên) — 
`displayName: 'Supabase Player'`,

`photoUrl`
 avatar của Supabase chứ không phải của Apple. Chỉ dùng

`AuthResponse`
/
`User`
 data class — không 
`SupabaseClient`, không
network (đúng seam top-level).

## Hiểu code — hai câu hỏi hay hỏi

- **Vì sao 
`authenticate`
 cần 
`supportsAuthenticate`
 check trước?**
 v7 không hỗ trợ authenticate trên mọi platform (web dùng flow khác)
 — impl ném 
`StateError`
 rõ thay vì để package ném mơ hồ. Repo bắt
 nó trong 
`catch`
 chung → 'Sign in failed: …'.
- **
`accessToken`
 để làm gì nếu Supabase chỉ cần idToken?** Theo tài
 liệu Supabase, 
`signInWithIdToken`
 nhận 
`accessToken`
 tùy chọn để
 provider-side lookups; impl lấy best-effort (`authorizationForScopes`

 rồi fallback 
`authorizeScopes`) — không có cũng không sao.

## Chạy và quan sát

```text
flutter pub get → OK (google_sign_in 7.2.0, sign_in_with_apple, crypto)
flutter analyze → No issues found!  (sau Bước 9; sót call-site báo
                  'required parameter missing' ngay)
flutter test test/supabase_auth_repository_test.dart → 8/8 xanh
flutter test    → +201: All tests passed!   (199 + 2)
flutter run     → "[auth] repository=disabled" trong console — không
                  dart-define nên nhánh Disabled vẫn chạy; pill chưa
                  làm gì (UI = Bài 5).
```

## Thử nghiệm

Đoán: 
`FakeAuthRepository`
 mặc định 
`signInResult`
 là success VÀ

`signInSession`
 là 
`AuthSessionAuthenticated(uid:'user-1')`
 — nếu
gọi 
`signInWithGoogle()`
 rồi đọc 
`authStateStream.value`, được gì?
Và nếu script 
`signInResult`
 failure thì sao?

<details>
<summary>Đáp án</summary>

Success → 
`_emitSessionIfSuccessful`
 add 
`signInSession`
 vào subject
→ 
`.value`
 là 
`AuthSessionAuthenticated(uid: 'user-1')`. Failure →
không emit gì → 
`.value`
 vẫn 
`initialSession`
 (mặc định Guest). Đây
chính là cơ chế test sẽ dựng "repo báo success NHƯNG session vẫn
guest" — canh bẫy cho guard của coordinator (Bài 4, Tự làm DEBUG).
</details>

## Lỗi hay gặp

1. **Chép code 
`google_sign_in`
 v6.** 
`GoogleSignIn().signIn()`
 không
 còn tồn tại — v7 bắt 
`initialize`
 + 
`authenticate`. Tutorial cũ =
 nguồn bug số một của bài này.
2. **Gọi 
`initialize`
 lặp lại.** v7 chỉ cho một lần — 
`_isInitialized`

 guard tồn tại vì thế; tự viết service mà quên cờ sẽ nhận lỗi
 platform channel.
3. **Truyền iOS/Android client id vào 
`serverClientId`.** Phải là
 Web client id — sai audience → Supabase verify idToken fail.
 (Và giá trị thật đi qua dart-define, không commit.)
4. **Bỏ qua 
`tokens == null`.** Cancel không phải exception — đó là
 null-result của service; 
`await`
 xong mà dùng luôn 
`tokens.idToken`

 → null-deref compile error hoặc crash.
5. **
`try/catch`
 nuốt 
`AuthException`
 chung chung.** Repo phân loại:
 
`GoogleSignInException`
 (có code cancel) → 
`AuthException`
 (có
 message) → generic. Bắt 
`Exception`
 một cục sẽ mất nhánh cancel
 message sạch.
6. **Coi 
`userMetadata`
 là typed.** Nó là 
`Map<String,dynamic>`
 của
 provider — đọc thẳng 
`metadata['full_name']`
 gán vào 
`String?`

 mà không qua 
`_metadataString`
 sẽ crash khi giá trị không phải
 String.

## Tự làm — PREDICT

Với từng tổ hợp dart-define lúc 
`flutter run`
 (đúng project riêng —
placeholders, OPTIONAL vì 
`LIVE_AUTH_FLOW: NOT_PERFORMED`), viết ra
giấy: impl nào 
`main()`
 tạo cho 
`authRepository`, và

`authStateStream.value`
 khi app vừa mở:

| # | dart-define |
|---|---|
| a | *(không truyền)* |
| b | 
`SUPABASE_URL`
 + 
`SUPABASE_PUBLISHABLE_KEY`, không 
`GOOGLE_*`
 |
| c | đủ cả bốn 
`SUPABASE_*`
 + 
`GOOGLE_*`
 |

<details>
<summary>Đáp án</summary>

- a → 
`DisabledAuthRepository(environment:)`
 → seed 
`AuthSessionGuest`.
- b → 
`AuthRepositoryImpl`
 — 
`isSupabaseConfigured`
 true nên client
 tồn tại; impl vẫn tạo được dù thiếu Google (service chỉ đọc env khi
 gọi; nút Google sẽ trả failure 
`'Google sign-in is not configured.'`

 qua… đường riêng — nhưng session mở đầu vẫn seed từ
 
`currentUser`, thường là Guest lần đầu).
- c → 
`AuthRepositoryImpl`
 đầy đủ; Google sign-in có thể hoạt động
 với project của học viên.
- Chung: console in 
`[auth] repository=disabled|supabase`
 — kiểm chứng
 nhánh DI bằng log, không cần đoán.

</details>

## Kiểm tra hiểu biết

- **Hỏi:** ba nguồn cấp session vào 
`_authStateSubject`
 là gì? —
 **Đáp:** seed ctor từ 
`client.auth.currentUser`; listener
 
`onAuthStateChange`
 (kể cả 
`onError → Guest`); 
`_emit`
 sau mỗi
 sign-*/loadAuthState thành công.
- **Hỏi:** hai "chặng" của Google sign-in và ai sở hữu mỗi chặng? —
 **Đáp:** chặng 1 
`GoogleAuthService`
 → 
`GoogleAuthTokens`
 (package
 v7, init-once + authenticate); chặng 2 
`client.auth.signInWithIdToken`

 → Supabase session → 
`_emit`
 (repo sở hữu).
- **Hỏi:** 
`signUp`
 thành công nhưng không authenticated — hợp lệ
 không? — **Đáp:** hợp lệ (confirm-email): 
`_sessionFromActiveSession`

 trả Guest → result 
`success('Check your email to confirm your
  account.')`; coordinator Bài 3 chỉ sync khi session authenticated.

## Ta cố ý chưa thêm

- 
`UserProfileSyncRepository`
 + coordinator gọi 
`syncUserProfile`
 —
 **Bài 3** (call-site đã sẵn trong impl: coordinator sẽ gọi).
- Dialog VMs dùng repo này — **Bài 4**; nút/UI — **Bài 5**.
- 
`UserProfileSyncRepositoryImpl`
 (merge + upsert 
`public.users`,
 senior 
`user_profile_sync_repository.dart:16`) — **M25**.
- Realtime, OTP/magic-link/recovery/account-linking — senior không
 có, khóa cũng không.
- Chạy provider thật — OPTIONAL + phụ thuộc môi trường (Bài 5 nói
 cú pháp lệnh với placeholder; không bắt buộc, không được verify
 trong môi trường này).

## Checkpoint hoàn thành

- [ ] 
`pubspec.yaml`
 có 
`google_sign_in ^7.2.0`, 
`sign_in_with_apple
  ^8.1.0`, 
`crypto ^3.0.7`; 
`flutter pub get`
 xanh.
- [ ] 
`google_auth_service.dart`
 dùng 
`GoogleSignIn.instance
.initialize`
 + 
`authenticate(scopeHint:)`
 — grep không có
 
`GoogleSignIn().signIn()`
 legacy.
- [ ] 
`supabase_auth_repository.dart`
 có đủ: seed 
`currentUser`,
 
`onAuthStateChange`
 (onError→Guest), 
`signInWithIdToken`,
 
`signInWithPassword`, 
`signUp`
 confirm-email branch, 
`signOut`

 hai lớp, 
`_sessionFromUser`
 + 
`_metadataString`.
- [ ] 
`main()`
 có 
`[auth] repository=`
 print + ternary auth DI;
 
`AppDependencyScope`
 +
`authRepository`
 + provider contract.
- [ ] 
`test/helpers/fake_auth_repository.dart`
 tồn tại; 4 call-site
 truyền 
`authRepository:`; 
`flutter analyze`
 sạch; 
`flutter test`

 **201/201**.
