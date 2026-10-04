---
title: "M24 — Authentication"
description: "5 bài: sealed AuthSessionData + AuthActionResult + guest-mode DisabledAuthRepository → GoogleAuthService v7 + AuthRepositoryImpl trên Supabase (+ Apple appendix) → sync seam (contract trước, impl M25) + MenuAuthActionCoordinator → dialog VMs single-flight + MenuViewModel auth + → header pill + auth/sign-out dialog + retire reset scaffold → 224/224."
sidebar:
 order: 0
 label: Tổng quan M24
---

# M24 · Authentication

Đến M24, mọi người chơi đều là **guest vô danh**: app chạy ngon, nhưng
không có khái niệm "đã đăng nhập" — pill trên menu chỉ hiển thị
username local. Milestone này dựng **identity layer**: sealed session
model, auth repository (Disabled guest-mode ↔ Supabase impl theo
config), coordinator giữ chuỗi sign-in→sync, hai dialog VM, và pill
tài khoản mở đúng dialog theo session — đồng thời đóng **bốn FR**:
 (sign-out reset profile), (snackbar về dialog VMs),
 (account pill + auth routing), (leaderboard uid thật).

:::note[Triết lý milestone: "guest là session thật"]
- `AuthSessionGuest` là variant chính danh trong sealed union —
 không phải null, không phải lỗi. App chạy không cần credential:
 `DisabledAuthRepository` trả guest + failure-message có ý nghĩa.
- Result của action (`AuthActionResult`) và state trên stream
 (`AuthSessionData`) là **hai kênh tách bạch** — coordinator là
 nơi đối chiếu chúng.
- `LIVE_AUTH_FLOW: NOT_PERFORMED` — môi trường không credential;
 impl là senior-verbatim, hành vi khóa bằng fake ở contract
 boundary + pure mapping tests.
:::

## Bản đồ bài học

| Bài | Nội dung | Checkpoint |
|-----|----------|-----------|
| [01](m24/01-session-model) | `AuthSessionData` sealed (Guest/Authenticated — "session là state, sign-in là action"); `AuthActionResult` private-ctor + redirecting; `AuthRepository` contract (ValueStream + 6 method); `DisabledAuthRepository` guest mode trả `configurationError`; auth ≠ authorization ≠ profile | **199/199** (+6: 2 session + 4 disabled) |
| [02](m24/02-supabase-auth-impl) | `GoogleAuthServiceImpl` trên **google_sign_in v7** (`initialize` một lần + `authenticate(scopeHint:)`, không `signIn()` legacy); `AuthRepositoryImpl`: seed `currentUser` + `onAuthStateChange`→guest-on-error + `signInWithIdToken`/`signInWithPassword`/`signUp`/`signOut` + `_sessionFromUser` metadata; DI `main()` + scope; **APPENDIX**: Apple + sha256 nonce | **201/201** (+2 Apple mapping) |
| [03](m24/03-sync-seam-va-coordinator) | "Contract trước impl sau": `ProfileSyncStateData` + `UserProfileSyncRepository` + Disabled no-op — call-site đúng ngay, impl `public.users` để M25; `MenuAuthActionCoordinator` giữ chuỗi `signIn*→loadAuthState→guard→syncUserProfile` + `signOut→resetUserProfile` | **201/201** (+0 — coverage đến Bài 4) |
| [04](m24/04-dialog-vms-va-menu) | `MenuAuthDialogViewModel` + `MenuSignOutDialogViewModel`: sealed `…UiEvent` (Dismiss/SnackBar), `_isLoading` single-flight, `_isDisposed` guard; `MenuViewModel` +AuthRepository (seed/sub/`isAuthenticated`/`loadUserProfile` dual); leaderboard `switch(authState)` → uid | **219/219** (+18: 11+3+3+1) |
| [05](m24/05-auth-ui) | Pill tappable: guest 'Khách'+hint vàng / authed username+'Đã đồng bộ' xanh; `requestAuthAction` route theo session → `MenuAuthRequested`/`MenuSignOutRequested`; auth dialog 2 trang + validation + `showApple` iOS-gate; sign-out dialog + `PopScope`; retire `resetProfile`/reset button + emit site `MenuSnackBarRequested` — class giữ senior-true (12 hoàn chỉnh) | **224/224** (+5 net) |

## Kết quả cuối milestone

- `flutter analyze` sạch · `flutter test` **224/224**
 (193 + 6 + 2 + 0 + 18 + 5) · `flutter build web` PASS.
- Không dart-define: app chạy `DisabledAuthRepository` — pill "Khách"
 → auth dialog mở; method buttons trả snackbar
 `'Supabase is not configured.'`/`'Google sign-in is not configured.'`;
 "Tiếp tục với khách" đóng dialog. Console: `[auth] repository=disabled`.
- Có dart-define (project riêng của học viên, OPTIONAL —
 `LIVE_AUTH_FLOW: NOT_PERFORMED` trong môi trường khóa):
 `AuthRepositoryImpl` bọc Supabase + Google v7 (+ Apple trên iOS) —
 cùng contract, UI không đổi một dòng.
- FR đóng: (sign-out → `resetUserProfile` qua coordinator;
 `_ResetButton`/`resetProfile()`/`resetProfileButton` đã xoá),
 (emit site `MenuSnackBarRequested` retire — class +
 bridge case giữ senior-true, zero emit sites; snackbar auth phát
 từ dialog VMs), (pill tappable + `requestAuthAction` +
 hai dialog), (leaderboard VM nhận `AuthRepository`,
 `switch(authState)` → uid).
- FR mở mới: sync impl Disabled (FR mới → M25); transport
 `showDialog` giữ nguyên → M29; icon pipeline re-eval → M28.

## Điều milestone này cố ý chưa làm

| Chưa làm | Milestone sở hữu | Vì sao |
|---|---|---|
| `UserProfileSyncRepositoryImpl` — merge local↔remote + upsert `public.users` + emit `syncStateStream` | **M25** | M24 chỉ ship seam + Disabled no-op; `main()` cố ý `Disabled()` luôn (senior chọn conditional — đổi một dòng khi impl vào) |
| `DreChangeNotifier`/`asyncOp` + cancel thật | **M26** | single-flight `_isLoading` + `_isDisposed` đủ cho dialog; DRE là lớp chung sau |
| `MenuDialogLayer` + `MenuDialogAuth`/`MenuDialogSignOut` state + `onDismissLockChanged`/`MenuDialogBackdrop` | **M29** | : transport `showDialog` + `PopScope` giữ — cùng scaffold settings/leaderboard |
| `SettingsDialogShell`/`OnboardingGameButton`/icon-pipeline visual parity | **M28** | chrome `AlertDialog`+MenuTokens đủ cho behavior; polish gộp đợt visual |
| Realtime auth/session cross-device | — | senior không dùng; `onAuthStateChange` listener đã đủ cho in-app |
| OTP / magic-link / password-recovery / account-linking | — | senior không có; khóa không ôm — bốn đường sign-in senior là đủ |
| Verify provider sống (Google/Apple/Supabase auth thật) | — | `LIVE_AUTH_FLOW: NOT_PERFORMED` — không credential trong môi trường; deterministic fakes là đường PASS |

## Checkpoint tổng kết

- [ ] `flutter analyze` sạch; `flutter test` **224/224**;
 `flutter build web` xanh.
- [ ] Grep `lib/` không có `.env`, không credential, không token —
 chỉ 4 dart-define NAME (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`,
 `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID`) + placeholder
 `<your-…>`; test literals là fixture giả.
- [ ] Tap pill khi guest → auth dialog (Google/Email/Continue-as-guest;
 Apple ẩn trên non-iOS); tap khi authenticated → sign-out dialog;
 sign-out success → profile về mặc định + pill về "Khách".
- [ ] `switch` trên `AuthSessionData`/`MenuScreenUiEvent`/dialog
 `…UiEvent` đều kiệt hợp — xoá một case là lỗi biên dịch.
- [ ] Test đọc đúng: 193 → +6 model/disabled (B01) → +2 Apple mapping
 (B02) → +0 seam (B03) → +18 VM (B04: 11+3+3+1) → +5 net
 routing+widget (B05) = **224**.

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** Sealed session union áp dụng cho identity;
 `AuthActionResult` value-type + redirecting ctor; auth
 state stream reuse `BehaviorSubject`; `signInWithIdToken`
 hai chặng provider→backend; `google_sign_in` v7
 init-once+authenticate; `onAuthStateChange` subscription; auth≠authorization≠profile; sha256 nonce appendix; coordinator + post-sign-in sync seam.
2. **Giải thích được?** Vì sao guest là variant không phải null; vì
 sao result-success ≠ session-authenticated và guard `is!` tồn
 tại; vì sao sign-up cho phép success không session (confirm-email)
 mà sign-in thì không; vì sao sync contract ship trước impl; vì
 sao snackbar sống ở dialog VM chứ không ở menu VM; vì sao pill
 che username local của guest.
3. **Viết lại không copy?** Tự làm: DEBUG trồng bug xoá guard →
 test "no active session" đỏ (Bài 3) + PRODUCE scratch
 sign-out-failure behavior test (Bài 4) + PREDICT env/DI ternary/
 showApple-gate/session-routing (Bài 2/3/5).
4. **Nếu … thì sao?** Thiếu `SUPABASE_URL` → `DisabledAuthRepository`
 → sign-in trả `configurationError` qua snackbar, dialog ở lại;
 repo báo success mà stream guest → guard trả `'no active session'`;
 bỏ `if (showApple)` → widget test `findsNothing` đỏ; sign-out
 fail → profile giữ nguyên (`resetUserProfile` chỉ chạy khi success).
5. **Cần ở đâu sau?** M25 đổi một dòng `main()` → sync impl thật
 ghi `public.users` + emit `ProfileSyncInProgress/Failed`; M26 đưa
 DRE vào thay single-flight tay; M28 thay chrome AlertDialog bằng
 `SettingsDialogShell`/`OnboardingGameButton` + icon assets; M29
 đổi event+`showDialog` sang `MenuDialogAuth`/`MenuDialogSignOut`
 state trong `MenuDialogLayer`.
