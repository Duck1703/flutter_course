---
title: "Bài 5 · Header pill, auth dialog & UI event routing"
description: "_ProfileHeader pill tappable (guest 'Khách'+hint vàng / authed username+'Đã đồng bộ' xanh); MenuAuthRequested/MenuSignOutRequested + requestAuthAction route theo session; auth dialog 2 trang (method buttons ↔ email form, validation senior-verbatim, Apple chỉ iOS); sign-out dialog + loading overlay + PopScope. Retire resetProfile + nút reset; MenuSnackBarRequested giữ senior-true — emit site về dialog VMs (FR-11/12). +5 net → 224."
sidebar:
  label: "Bài 5 · auth UI + pill"
  order: 5
---

## Mục tiêu

- Nối **pill tài khoản** trên `_ProfileHeader`: guest hiển thị
  `menuGuestName` ("Khách") + hint vàng `menuGuestSyncHint`;
  authenticated hiển thị `profile.username` + `menuSyncedStatus` xanh —
  tap → `viewModel.requestAuthAction()`.
- Thêm `requestAuthAction()` + hai event `MenuAuthRequested`/
  `MenuSignOutRequested`: **session quyết dialog** — guest → auth
  dialog; authenticated → sign-out dialog. Cùng một tap, hai hành vi.
- Port auth dialog hai trang trong một `AlertDialog` (method buttons
  ↔ email form), validation nguyên văn senior, nút Apple chỉ iOS;
  sign-out dialog + `MenuLoadingOverlay` + `PopScope` chặn back khi
  đang sign-out.
- **Đóng FR-11/FR-12 hoàn chỉnh**: xoá `_ResetButton` +
  `resetProfile()` + dời **emit site** `MenuSnackBarRequested`
  sang dialog VMs (Bài 3–4). Bản thân class `MenuSnackBarRequested`
  **giữ nguyên trong sealed family đúng senior** — senior cũng có
  zero emit sites cho nó.
- +5 test net (3 `requestAuthAction` + ui-events rewrite) → **224/224**.

## Bạn đang ở đâu

- Bài 4: hai dialog VM + `isAuthenticated` đã vào; suite 219/219.
  VM đã "biết" session nhưng UI chưa dùng — pill vẫn tĩnh, chưa có
  event auth, nút reset cũ vẫn còn trên menu.
- Bài này là lớp cuối: event-set đổi → VM route → bridge → hai
  dialog widget + pill — và dọn scaffold cũ trong cùng đợt.

## Vì sao việc này quan trọng ngay bây giờ

Đây là bài biến "session trong VM" thành "người chơi thấy gì". Ba
quyết định đáng học:

**① Pill nói sự thật về session — và giấu username local của guest.**
Guest có `profile.username` trong local (họ tự đặt khi chơi) — nhưng
senior *cố ý* KHÔNG hiển thị nó trên pill khi guest: pill render
`menuGuestName` + hint "Đăng nhập để đồng bộ". Vì sao? Vì username
local là dữ liệu thiết bị; hiển thị nó như "tên tài khoản" sẽ nói
dối người chơi rằng họ đã có tài khoản. Pill là mặt-hàng identity —
nó phải phản ánh SESSION, không phải profile. (Widget test
`'header guest: pill hiển thị tên "Khách" + hint đồng bộ, không lộ
username local'` khóa đúng semantic này.)

**② Một tap, hai dialog — session là router.** `requestAuthAction`
không hard-code "mở dialog đăng nhập": nó đọc `_authState` — guest →
`MenuAuthRequested`, authed → `MenuSignOutRequested`. Người chơi
luôn bấm cùng một pill; app tự đổi nghĩa. Đây là "intent routing":
VM quyết ĐIỀU GÌ xảy ra, bridge quyết LÀM THẾ NÀO (`showDialog`).

**③ Retire gộp vào cùng đợt với replacement — và biết retire CÁI
GÌ.** Xoá `resetProfile()` + nút reset NGAY khi coordinator đã
thay thế — không để hai cơ chế song hành. Với snackbar thì tinh
tế hơn: FR-12 chỉ dời **emit site** sang dialog VMs; class
`MenuSnackBarRequested` **không bị xoá** — senior giữ nó trong
sealed family + giữ cả case xử lý ở bridge dù chính senior cũng
zero emit sites. Event class là *channel contract*, không phải
dead code: contract nói "channel này tồn tại", emit site nói "ai
đang dùng nó". Xoá class là lệch khỏi senior; xoá emit site là
đóng FR-12 — hai việc khác nhau.

## Bạn đã biết gì

- `MenuScreenUiEvent` sealed + bridge `_handleUiEvent` 3-khâu
  (M13/M15); `showSettingsDialog`/`showLeaderboardDialog` transport
  + `MenuLeaderboardDialogScope` (M16/M23 — cùng quy ước: context
  đọc repo → ctor scope → `ChangeNotifierProvider` dialog-scoped VM).
- Dialog VM + sealed `…UiEvent` + `isLoading` (Bài 4);
  `AppLocalizations`/`l10n` + `flutter gen-l10n` (M17).
- `GestureDetector` + `ValueKey` + `Semantics` + `HitTestBehavior`
  (M03/M05); `AlertDialog` + `showDialog` (M16); `TextEditingController`
  + listener (settings dialog M16); `MenuTokens` chrome (M12).

## Mental model — "session → intent → transport → dialog VM"

```text
tap pill → vm.requestAuthAction()
             _authState is AuthSessionAuthenticated
               ? emit MenuSignOutRequested
               : emit MenuAuthRequested
bridge _handleUiEvent switch (kiệt hợp — M15):
  MenuAuthRequested     → showMenuAuthDialog(context)
  MenuSignOutRequested  → showMenuSignOutDialog(context)
show*Dialog: context.read ×3 repo → Scope ctor →
  ChangeNotifierProvider(VM dialog-scoped) → bridge nghe events:
    DismissRequested   → Navigator.pop
    SnackBarRequested  → ScaffoldMessenger (hiện trong menu Scaffold)
```

**UI chỉ render; session quyết mọi thứ.** Pill không tự biết mở cái
gì — nó báo intent; VM đọc session route; widget chỉ build theo
`isAuthenticated`/`isLoading` từ `context.watch`.

**Dialog VM sống trong route.** `showDialog` đẩy route mới → scope
widget trong route tạo `ChangeNotifierProvider` → VM chết cùng route.
Khác senior chỉ ở TRANSPORT: senior đặt `MenuDialogAuth`/`MenuDialogSignOut`
state → `MenuDialogLayer` render in-Stack + callback `onDismiss`/
`onDismissLockChanged` (FR-29 → **M29**); learner giữ
event-một-lần + `showDialog` — cùng semantic, khác cơ chế.

## Dart/Flutter cần dùng — xuất hiện đầu tiên

| Construct | Vai trò |
|---|---|
| `part 'x.dart'` / `part of 'y.dart'` | tách file mà giữ *private cùng-thư-viện*: `_AuthMethodButtons`… ở `menu_auth_dialog_content.dart` vẫn dùng được `_minimumPasswordLength` của file mẹ (private = per-LIBRARY, không phải per-file) |
| `Theme.of(context).platform == TargetPlatform.iOS` | platform gate senior-verbatim — nút Apple chỉ render iOS (Sign in with Apple là yêu cầu App Store khi có OAuth bên-thứ-ba) |
| `AnimatedSwitcher` + `AnimatedCrossFade` | đổi-trang dialog mượt (method buttons ↔ email form; section hiện/ẩn) — composition widget, không phải animation tự viết |
| `PopScope(canPop:)` | chặn back/gesture đóng route khi `isLoading` — listener `DismissRequested` vẫn pop được vì nó đến SAU `_setLoading(false)` |
| `AbsorbPointer` | overlay nuốt mọi pointer event xuống nút bên dưới — lớp thứ hai của single-flight (ở UI) |

## Ví dụ độc lập — "một intent, session route" trong 20 dòng

```dart
// Routing theo session — không có UI.
sealed class S { const S(); }
class Guest extends S { const Guest(); }
class Authed extends S { const Authed(); }

sealed class Intent { const Intent(); }
class OpenSignIn extends Intent { const OpenSignIn(); }
class OpenSignOut extends Intent { const OpenSignOut(); }

Intent accountTap(S session) => switch (session) {
      Authed() => const OpenSignOut(),
      Guest() => const OpenSignIn(),
    };
```

`requestAuthAction` là đúng switch này trên `AuthSessionData` thật:
`_authState is AuthSessionAuthenticated ? MenuSignOutRequested() :
MenuAuthRequested()` — ternary vì chỉ hai nhánh, cùng semantics.

## Android / Compose bridge

**SIMILARITY — `remember`/composition-local state + event channel.**
Pill build lại theo `isAuthenticated` ≈ composable đọc `State<Boolean>`;
dialog event → `ScaffoldMessenger` ≈ snackbar `LaunchedEffect`
collect `SharedFlow`. `PopScope` ≈ `BackHandler(enabled = !loading)`.

**IMPORTANT DIFFERENCE — `AlertDialog` chrome, không
`Dialog`-custom-shell của senior.** Senior bọc dialog trong
`SettingsDialogShell` + nút `OnboardingGameButton` (visual parity
M28); learner giữ `AlertDialog` + `MenuTokens` — CÙNG behavior
(validation, gating, events), KHÁC vỏ. Đừng trông chờ pixel-parity
ở M24.

**DO NOT ASSUME — `onCancel == null` là "nút biến mất".** Trong
Material, `onPressed: null` = nút DISABLED (vẫn render, xám) — đúng
ý đồ: đang sign-out thì nút HUỶ không bấm được nhưng vẫn nhìn thấy.
Khác với conditional-render `if (…)`.

## Senior project connection

| Senior @ `main@c8eb860` | Learner khác ở đâu |
|---|---|
| `widgets/menu/menu_profile_header.dart` | pill cùng semantics (tappable, accent theo session, `menuGuestName` che username local, `Semantics` button) — accent map sang `MenuTokens.statGreen`/`accentYellow` |
| `widgets/menu/auth/menu_auth_dialog*.dart` | structure verbatim (2 trang, `_EmailAuthMode`, validation, `showApple` iOS-gate, `_authFadeDuration` 380ms); chrome `AlertDialog`+MenuTokens thay `SettingsDialogShell`/`OnboardingGameButton` → M28 |
| `widgets/menu/auth/menu_sign_out_dialog*.dart` | prompt `signOutPrompt` + 2 nút verbatim; learner `PopScope(canPop:!isLoading)` thay `onDismissLockChanged`+`MenuDialogBackdrop` |
| `widgets/menu/auth/menu_loading_overlay.dart` | verbatim — `AbsorbPointer`+scrim+spinner |
| `view_models/menu/menu_screen_ui_event.dart` | family senior = đúng 2 variant `MenuGameRequested` + `MenuSnackBarRequested` (`menu_screen_ui_event.dart`) — latter giữ class + bridge case (`menu_screen.dart:71`) với **zero emit sites** cả hai bên; `MenuAuthRequested`/`MenuSignOutRequested` là **learner-only transport** (senior lái bằng `MenuDialogAuth`/`MenuDialogSignOut` state — `menu_screen_view_model.dart:98-102`, M29) |
| `lib/l10n/*.arb` | +24 key verbatim; `cancelButton` dùng lại (vi: learner `'HUỶ'` vs senior `'Hủy'` — cosmetic, đã có từ trước) |

## Build it step by step

**Bước 1 — `lib/view_models/menu/menu_screen_ui_event.dart`** — đổi
event-set: **giữ `MenuSnackBarRequested`** nguyên vị trí senior
(ngay sau `MenuGameRequested`) — emit site của nó đã retire cùng
`resetProfile()` (FR-12), còn class + `message` payload là channel
contract giữ nguyên. **Thêm** `MenuAuthRequested` +
`MenuSignOutRequested` (hai doc-comment ghi FR-28 + FR-29→M29) —
hai variant này là learner-only transport cho `showDialog`.

**Bước 2 — `lib/view_models/menu/menu_view_model.dart`** — thêm
`requestAuthAction()` (senior-tên) và **xoá `resetProfile()`** (đã
move sang `coordinator.signOut` — FR-11):

```dart
/// Ý định "người chơi bấm pill tài khoản" — M24 (FR-28). SESSION
/// quyết dialog: authenticated → sign-out; mọi session khác → auth.
void requestAuthAction() {
  _events.add(
    _authState is AuthSessionAuthenticated
        ? const MenuSignOutRequested()
        : const MenuAuthRequested(),
  );
}
```

**Bước 3 — `test/sealed_state_test.dart`** — describe-switch kiệt hợp:
**giữ case `MenuSnackBarRequested() => 'snackbar'`** + hai expect
(`describe(const MenuSnackBarRequested('hi'))` và `.message`
payload — variant vẫn trong family), thêm `MenuAuthRequested() =>
'auth'` + `MenuSignOutRequested() => 'sign-out'` + hai `expect`
tương ứng (compile-level closure của event-set 6 variant — đây
chính là phần thưởng của sealed: compiler chỉ điểm cần sửa).

**Bước 4 — `lib/widgets/menu/auth/` 6 file** (verbatim structure
senior, chrome MenuTokens):

- `menu_loading_overlay.dart` (18 dòng): `AbsorbPointer` +
  `ColoredBox(Color(0x8C000000))` + `CircularProgressIndicator` —
  nuốt tap + scrim + spinner.
- `menu_auth_dialog.dart` (234 dòng) + `part 'menu_auth_dialog_content.dart'`
  (331 dòng): `_MenuAuthDialogState` giữ 3 `TextEditingController`
  + `_emailAuthMode` + `_showEmailForm` + `_errorText` (ephemeral —
  đúng chỗ StatefulWidget); `AnimatedSwitcher` đổi hai trang;
  `showApple = Theme.of(context).platform == TargetPlatform.iOS`.
- `menu_auth_dialog_scope.dart` (136 dòng): `showMenuAuthDialog`
  đọc 3 repo từ context → `MenuAuthDialogScope` ctor →
  `ChangeNotifierProvider` → `_MenuAuthDialogBridge` (attach ở
  `didChangeDependencies`, guard `==`, cancel ở `dispose`; event
  switch → pop / snackbar; `isLoading` → `Positioned.fill` overlay).
- `menu_sign_out_dialog.dart` (102 dòng): `AlertDialog` key
  `'menu-sign-out-dialog'`, title `accountTitle`, prompt
  `signOutPrompt`, nút đỏ `signOutButton` + nút `cancelButton`
  (`onPressed: onCancel` — null khi loading → disabled).
- `menu_sign_out_dialog_scope.dart` (127 dòng): tương tự + `PopScope(
  canPop: !viewModel.isLoading)` bọc — barrier/back không đóng được
  giữa chừng.

Validation verbatim (trong `_MenuAuthDialogState`):

```dart
// sign-in:   email.trim() rỗng || password rỗng → enterEmailPasswordError
//            !email.contains('@')              → enterValidEmailError
// register:  + confirm rỗng    → confirmPasswordError
//            + password < 6    → passwordMinLengthError  (_minimumPasswordLength)
//            + password != cf  → passwordsDoNotMatchError
```

Lỗi hiển thị qua `_AnimatedAuthSection(visible: errorText != null)`;
gõ tiếp → `_handleEmailFormChanged` xoá error. `_canSubmitEmailForm`
gate nút submit (register cần thêm confirm non-empty) — kiểm client
trước khi gọi VM, VM vẫn có failure-path riêng.

**Bước 5 — `lib/screens/menu_screen.dart`** — surgery:

- import 2 scope auth; `create:` đã có `authRepository` (Bài 4).
- bridge `_handleUiEvent`: **giữ case `MenuSnackBarRequested`**
  (senior parity — arm vẫn dịch sang `ScaffoldMessenger.showSnackBar`
  dù hiện zero emit sites; senior `menu_screen.dart:71` giữ y
  hệt), thêm `MenuAuthRequested() → unawaited(_openAuthDialog())` +
  `MenuSignOutRequested() → unawaited(_openSignOutDialog())`.
- `_openAuthDialog() => showMenuAuthDialog(context)` /
  `_openSignOutDialog() => showMenuSignOutDialog(context)` — mirror
  `_openSettings`/`_openLeaderboard`.
- `_ProfileHeader` +`isAuthenticated` + `onAccountTap`: bọc pill bằng
  `Semantics(button: true, label: l10n.accountSemanticLabel)` +
  `GestureDetector(key: ValueKey('menu-profile-pill'),
  behavior: HitTestBehavior.opaque, onTap: onAccountTap)`;
  `accent = isAuthenticated ? MenuTokens.statGreen :
  MenuTokens.accentYellow` (viền avatar + màu subtitle); tên
  `isAuthenticated ? profile.username : l10n.menuGuestName`;
  subtitle `isAuthenticated ? l10n.menuSyncedStatus :
  l10n.menuGuestSyncHint`.
- build(): `_ProfileHeader(profile: viewModel.userData,
  isAuthenticated: viewModel.isAuthenticated,
  onAccountTap: viewModel.requestAuthAction,
  onSettingsTap: viewModel.requestSettings)`.
- `_MenuBody`: **xoá `_ResetButton`** + doc-comment ghi FR-11 retire.

**Bước 6 — ARB + gen.** `lib/l10n/app_en.arb` + `app_vi.arb`: +24 key
verbatim senior (pill: `accountSemanticLabel`, `menuGuestName`,
`menuGuestSyncHint`, `menuSyncedStatus`, `syncProgressTitle`,
`syncProgressDescription`; dialog: `signInWithGoogleButton`,
`signInWithAppleButton`, `signInWithEmailButton`,
`continueAsGuestButton`, `emailFieldLabel`, `passwordFieldLabel`,
`confirmPasswordFieldLabel`, `backButton`, `signInButton`,
`createAccountButton`, `enterEmailPasswordError`,
`enterValidEmailError`, `confirmPasswordError`,
`passwordMinLengthError`, `passwordsDoNotMatchError`, `accountTitle`,
`signOutPrompt`, `signOutButton`) và **xoá `resetProfileButton`** —
rồi `flutter gen-l10n`.

**Bước 7 — test.** `menu_view_model_test`: −2 ca reset/snackbar
retired, +3 `requestAuthAction` (guest→`MenuAuthRequested`;
authed→`MenuSignOutRequested`; **re-route theo session hiện tại** —
guest→sign-in→tap→sign-out event). `menu_screen_ui_events_test.dart`
viết lại → 7 testWidgets: play→GameScreen; leaderboard row→dialog;
**header guest hiển thị 'Khách'+hint, che username local**;
guest pill→auth dialog mở với method buttons (**Apple ẩn trên
non-iOS** — `findsNothing`); 'Tiếp tục với khách'→dialog đóng;
authed pill→sign-out dialog; **sign-in thất bại → snackbar phát TỪ
DIALOG VM hiện trong menu Scaffold, dialog vẫn mở** (FR-12).

## Chạy và quan sát

```text
flutter gen-l10n → OK (l10n regenerate sau khi sửa ARB)
flutter analyze  → No issues found!
flutter test     → +224: All tests passed!   (219 + 5 net)
flutter run      → pill "Khách" + hint vàng; tap → auth dialog mở
                   với Google/Email/Tiếp tục-với-khách (Apple ẩn);
                   bấm method → snackbar 'Supabase is not configured.'
                   (Disabled repo), dialog ở lại; Continue-as-guest
                   → đóng. Console: [auth] repository=disabled.
```

:::caution[LIVE_AUTH_FLOW: NOT_PERFORMED]
Môi trường khóa không có credential — **đường đăng nhập thật chưa
được thực thi** (kế thừa M23). OPTIONAL, phụ thuộc môi trường, chỉ
cho học viên có project Supabase+Google riêng:

```text
flutter run \
  --dart-define=SUPABASE_URL=<your-project-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-publishable-key> \
  --dart-define=GOOGLE_WEB_CLIENT_ID=<your-web-client-id>
```

(iOS thêm `GOOGLE_IOS_CLIENT_ID`; Apple sign-in cần máy Apple + cấu
hình dev account.) **Đây là placeholder** — điền giá trị của project
bạn, không commit, không dán vào bài làm. Khóa vẫn pass mà không
chạy bước này. Xác nhận bằng log `[auth] repository=supabase` +
snackbar thành công sau sign-in Google.
:::

## Thử nghiệm

Đoán trước rồi kiểm chứng: trong `menu_auth_dialog.dart`, **xoá gate
`if (showApple)`** để nút Apple render luôn → `flutter test
test/menu_screen_ui_events_test.dart` — test nào đỏ và assert gì?

<details>
<summary>Đáp án</summary>

`'bấm pill khi guest → MenuAuthRequested → auth dialog mở với các
nút phương thức (Apple ẩn trên non-iOS)'` đỏ tại assert
`find.text(l10n.signInWithAppleButton) → findsNothing` — test
platform không phải iOS nên gate chính là thứ giữ nút ẩn. Đây là ca
"iOS-gated path covered by code inspection + findsNothing assert"
trong ledger — bỏ gate và platform-thật vẫn thấy nút, sai yêu cầu
App Store.
</details>

## Lỗi hay gặp

1. **Hiển thị `profile.username` cho guest trên pill.** Senior cố ý
   che — guest chưa có tài khoản, username local chỉ là dữ liệu
   thiết bị. Đổi `isAuthenticated ? username : menuGuestName` thành
   luôn-username là sai semantic + fail widget test header.
2. **Mở dialog trực tiếp từ `onTap` của pill.** Pill →
   `requestAuthAction` (intent) → bridge `showDialog` — tắt event,
   widget tự mở dialog là phá "VM quyết ĐIỀU GÌ / widget quyết THẾ
   NÀO" và lỡ mất session-routing.
3. **Validation gọi VM trước khi check.** `_submitEmailSignIn` gọi
   `_validateEmailForm()` trước — fail sớm hiển thị `errorText` trong
   dialog; bỏ validate → mọi typo thành network call thật + snackbar
   lỗi server thay vì lỗi form.
4. **Render nút Apple không gate.** Chỉ iOS — `showApple` gate là
   yêu cầu, không phải polish (App Store bắt có Sign in with Apple
   khi app có OAuth khác; các nền tảng khác không render).
5. **Quên `flutter gen-l10n` sau sửa ARB.** `l10n.menuGuestName` là
   generated getter — sửa ARB mà không regen thì code không thấy
   getter mới (analyze đỏ).
6. **Emit `MenuSnackBarRequested` từ menu VM nữa.** Class vẫn nằm
   trong sealed family + bridge vẫn có case (senior parity — cả hai
   bên zero emit sites); nhưng **viết emit site mới** cho nó là mở
   lại FR-12 — snackbar auth phát từ dialog VM,
   `SettingsSnackBarRequested` của settings cũng cùng pattern.

## Tự làm — PREDICT (routing theo session)

Không chạy test. `requestAuthAction` được gọi ba lần liên tiếp với
`_authState` lần lượt là: `AuthSessionGuest` →
`AuthSessionAuthenticated(uid: 'u7')` → `AuthSessionGuest` (sau
sign-out). Viết ra giấy ba event theo thứ tự listener nhận được.
Sau đó đối chiếu test `'requestAuthAction route theo session HIỆN
TẠI'` trong `menu_view_model_test.dart`.

<details>
<summary>Đáp án</summary>

`MenuAuthRequested` → `MenuSignOutRequested` → `MenuAuthRequested`.
Routing đọc `_authState` TẠI THỜI ĐIỂM tap — không phải session lúc
VM tạo. Test kia khóa đúng chuỗi này (guest → sign-in → tap →
sign-out event) chứng minh VM route theo stream mới nhất, không
cache quyết định.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao guest pill không hiển thị `profile.username`? —
  **Đáp:** username local là dữ liệu thiết bị, không phải identity
  tài khoản; pill phản ánh SESSION (guest → `menuGuestName` + hint
  đồng bộ), authed mới hiển thị username + `menuSyncedStatus`.
- **Hỏi:** `requestAuthAction` trả/emit gì và ai quyết định? —
  **Đáp:** emit `MenuSignOutRequested` nếu `_authState` authed,
  ngược lại `MenuAuthRequested`; VM quyết intent, bridge dịch sang
  `showMenuAuthDialog`/`showMenuSignOutDialog`.
- **Hỏi:** FR-11 và FR-12 đóng bằng những thay đổi vật lý nào ở bài
  này? — **Đáp:** FR-11: xoá `_ResetButton` + `resetProfile()` +
  `resetProfileButton` key — semantics đã ở `coordinator.signOut`.
  FR-12: emit site `MenuSnackBarRequested` cùng retire với
  `resetProfile()` — class + bridge case **giữ nguyên senior-true**
  (zero emit sites cả hai codebase); snackbar auth phát từ dialog
  VMs qua `…DialogSnackBarRequested`.

## Ta cố ý chưa thêm

- `MenuDialogLayer`/`MenuDialogAuth`/`MenuDialogSignOut` state +
  `SettingsDialogShell`/`OnboardingGameButton`/`MenuDialogBackdrop`
  chrome — **M29** (transport) + **M28** (visual parity).
- `UserProfileSyncRepositoryImpl` + consumer `syncStateStream` —
  **M25**.
- Realtime auth/session cross-device; OTP/magic-link/password-
  recovery/account-linking — senior không có, khóa không ôm.
- iOS Apple button path — gated theo thiết kế; cần máy Apple thật
  để chạy end-to-end (`LIVE_AUTH_FLOW` placeholder).

## Checkpoint hoàn thành

- [ ] `MenuScreenUiEvent` 6 variant: `MenuSnackBarRequested` giữ
  trong family đúng senior (zero emit sites — chỉ emit site đã
  retire); `MenuAuthRequested`/`MenuSignOutRequested` có mặt;
  `sealed_state_test` describe kiệt hợp đủ 6 case.
- [ ] `requestAuthAction()` route theo `_authState`; `resetProfile()`
  + `_ResetButton` + `resetProfileButton` đã xoá.
- [ ] `_ProfileHeader` tappable (key `menu-profile-pill`, Semantics,
  accent theo session, che username khi guest); bridge +2 case;
  `_openAuthDialog`/`_openSignOutDialog`; 6 file `widgets/menu/auth/`
  tồn tại với validation + `showApple` gate + `PopScope`.
- [ ] ARB +24 −1 trên cả en/vi; `flutter gen-l10n` chạy lại.
- [ ] `flutter analyze` sạch; `flutter test` **224/224**.
- [ ] Đọc hiểu caveat: `LIVE_AUTH_FLOW: NOT_PERFORMED` — đường
  provider thật chưa chạy; smoke test chỉ là placeholder optional.
