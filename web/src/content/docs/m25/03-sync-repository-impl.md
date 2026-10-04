---
title: "Bài 3 · UserProfileSyncRepositoryImpl — fetch → merge → save → upsert"
description: "Impl thật thay seam no-op: _isSyncing chặn re-entrancy → emit ProfileSyncInProgress → load local → fetch public.users by auth_uuid (maybeSingle) → mergeUserProfileForSync → save local → upsert onConflict auth_uuid → Idle; lỗi → Failed + rethrow; _emit dedupe/isClosed. +0 test → 233."
sidebar:
 label: "Bài 3 · sync repository impl"
 order: 3
---

## Mục tiêu

- Prepend `UserProfileSyncRepositoryImpl` vào
 `lib/repositories/profile/user_profile_sync_repository.dart` —
 cùng file với `UserProfileSyncRepositoryDisabled` đúng senior
 (một file, hai impl, `main()` chọn ở Bài 4).
- Trace được pipeline `syncUserProfile` đúng nhịp senior:
 guard `_isSyncing` → `ProfileSyncInProgress` → `loadUserProfile`
 → `_fetchRemoteProfile` (`from('users').select().eq('auth_uuid',
  uid).maybeSingle()`) → `mergeUserProfileForSync` →
 `saveUserProfile` → `_upsertRemoteProfile` (`upsert(toUpsertMap(),
  onConflict: 'auth_uuid')`) → `ProfileSyncIdle`; bất kỳ lỗi →
 `ProfileSyncFailed(error.toString())` + **rethrow**; `finally`
 mở khoá `_isSyncing`.
- Phân biệt `_isSyncing` (khoá re-entrancy — từ chối *vào) với
 `_requestId` của M23 (stale guard — bỏ *kết quả cũ): hai guard
 khác mục đích, đừng trộn.
- Giải thích `upsert(onConflict:)`: insert nếu chưa có /
 update nếu trùng-`auth_uuid` — một roundtrip thay
 select tồn tại rồi quyết.
- +0 test → suite giữ **233/233**; nói rõ vì sao impl này không có
 unit test trực tiếp.

## Bạn đang ở đâu

- Cuối Bài 2: `AppUserData` + `mergeUserProfileForSync` đủ và đã
 được test kỹ (233/233). Còn thiếu *máy chạy luật*: ai gọi fetch,
 ai gọi merge, ai ghi lên remote, ai emit state.
- `UserProfileSyncRepository` contract + `ProfileSyncStateData` +
 `UserProfileSyncRepositoryDisabled` đã tồn tại từ M24 trong đúng
 file này — bài này thêm impl thật phía trên, Disabled vẫn giữ.
- `SupabaseClient` tồn tại (hoặc null) sau bootstrap M23;
 `UserProfileRepository` (`loadUserProfile`/`saveUserProfile` +
 `userProfileStream`) từ M14. Pipeline mới chỉ ghép những mảnh đã
 có — không dependency mới.

## Vì sao việc này quan trọng ngay bây giờ

Đây là bài "cắm nguồn" của seam M24. Coordinator đã gọi
`syncUserProfile(session)` đúng chỗ hai milestone — giờ lời gọi đó
có thật: đọc local, hỏi remote, merge, ghi hai phía, kể chuyện bằng
`syncStateStream`. Thứ tự trong pipeline là quyết định thiết kế, không
phải chi tiết: **merge trước ghi** (không bao giờ ghi local thô lên
remote, cũng không ghi remote thô đè local), **local save trước
upsert** (nếu upsert fail thì máy vẫn giữ bản merge — lần sau sync
lại đẩy), và **Failed + rethrow** (stream kể lỗi *và* caller vẫn
nhận exception để quyết UI).

## Bạn đã biết gì

- Contract + seam: `UserProfileSyncRepository`, `ProfileSyncIdle/
  InProgress/Failed`, `UserProfileSyncRepositoryDisabled` (M24); `BehaviorSubject.seeded` + `ValueStream.value`;
 `_emit` guard `isClosed` + value-equality (cùng shape
 `AuthRepositoryImpl._emit` M24).
- `from().select().eq().maybeSingle()` Data API (M23);
 `SupabaseClient?` sentinel + conditional DI `?:`.
- `mergeUserProfileForSync` + `AppUserData.fromMap/toUpsertMap/
 fromProfile` (Bài 1–2).
- `try/catch/finally` + `rethrow` + `async/await`;
 `_isLoading`-style single-flight trên dialog VMs (M24/04).

:::tip[Suy luận trước khi đọc model — DERIVE]
Trước khi xem senior sắp pipeline thế nào, hãy tự vẽ nó. Bạn đã có
đủ nguyên liệu: `mergeUserProfileForSync` (Bài 2), Data API
`from().select().eq().maybeSingle()` + `upsert()` (M23/M24),
`BehaviorSubject` stream ba trạng thái (Bài 1 + M24), và ranh giới
repo-local-vs-remote (Bài 1).

1. **Thứ tự ghi.** Sync nghĩa là local và remote phải ra cùng một
   kết quả merge. Ghi local trước hay remote trước? Điều gì xấu xảy
   ra nếu remote thành công nhưng local fail — user thấy dữ liệu nào
   khi mở app lần sau?
2. **Chồng gọi.** User tap liên tục / coordinator + VM cùng kích —
   repo có cần từ chối cuộc gọi thứ hai khi một cuộc đang chạy? Nếu
   có, dùng gì để biết "đang chạy"?
3. **Ba đầu mốc stream.** Stream `syncState` chỉ cần nói ba thứ:
   đang chạy / xong / lỗi. Xếp ba variant đó vào đúng điểm trong
   pipeline bạn vừa vẽ — `Failed` có nên nuốt lỗi hay rethrow?
4. **Hình upsert.** `toUpsertMap()` (Bài 1) đẩy *những field nào*
   lên remote? Field nào cố tình KHÔNG đi lên (và vì sao: không có
   cột, hay không nên ghi đè)?
5. **Chủ nhân merge.** Merge nên sống ở repo sync, ở
   `AppUserData`, hay ở VM? Nêu lý do — ai là kẻ duy nhất thấy đủ
   cả local lẫn remote?

Sau đó đọc model bên dưới và **đối chiếu** — phần khác biệt là bài
học.

<details>
<summary>Đối chiếu sau khi tự thiết kế</summary>

1. **Local trước, remote sau.** Local là nguồn UI đọc khi mở app —
   nếu remote ghi xong mà local fail, lần mở sau app vẫn thấy data cũ
   dù server đã mới: trạng thái tồi tệ nhất. Senior save local trước,
   upsert remote sau.
2. **Có — flag `_isSyncing`.** Cuộc gọi thứ hai `return` ngay;
   cuộc đầu `finally` hạ flag. Từ chối chồng = tránh hai upsert
   chồng giá trị.
3. `InProgress` trước `try`; `Failed(e)` trong `catch` rồi
   **rethrow** — caller (coordinator) cần biết sync hỏng để phản ứng;
   `Idle` khi xong. Nuốt lỗi = UI im lặng dù sync thất bại.
4. Upsert đẩy đúng các cột bảng `users` theo map Bài 1 —
   `username`→`name`, `totalMoneyWon`→`total_money_won`, …
   (tên cột SQL ≠ tên field Dart). `gamesWon` không có cột →
   local-only; `id`/`created_at`/`updated_at` server tự lo.
5. **Repo sync** — chỉ nó thấy cả hai phía (đọc remote, gọi merge
   thuần của Bài 2, ghi cả hai). VM chỉ cần một method
   `syncUserProfile`; `AppUserData` là data, không phải máy điều
   phối.

</details>
:::

## Mental model mới — ba cái cùng lúc

**① "Repo là máy điều phối một pipeline; state stream là bản ghi
ca chạy"** (NORMAL).

```text
syncUserProfile(session)
  ├─ _isSyncing? → return                    (từ chối chồng)
  ├─ _isSyncing = true; emit InProgress
  ├─ try {
  │    local  = await userProfileRepository.loadUserProfile()
  │    remote = await _fetchRemoteProfile(uid)     // maybeSingle
  │    merged = mergeUserProfileForSync(...)       // Bài 2
  │    await saveUserProfile(merged)               // local TRƯỚC
  │    await _upsertRemoteProfile(session, merged) // remote SAU
  │    emit Idle
  │  } catch (e) { emit Failed(e); rethrow; }
  │  finally    { _isSyncing = false; }
```

Mỗi await là một *có thể fail riêng*; stream chỉ kể ba đầu mốc
(InProgress → Idle | Failed). Consumer UI (nếu có, senior cũng không
render) đọc đúng ba trạng thái đó — không cần biết pipeline dài mấy
bước.

**② "_isSyncing là khoá cửa; finally là chìa — khác _requestId"**
(vs).

M23 `_requestId`: cho phép gọi chồng, nhưng *kết quả cũ* bị loại khi
về muộn (leaderboard refresh — bản mới hơn thắng). M25 `_isSyncing`:
**từ chối lời gọi thứ hai ngay tại cửa** — vì sync là một
*write*-pipeline, chạy chồng nghĩa là hai upsert đua nhau và một
merge đọc local đã cũ. Guard phải mở trong `finally` để throw cũng
không khoá mãi. So với `_isLoading` của dialog VM (M24): cùng ý tưởng
single-flight, khác nơi đứng — đây là repo, không phải VM.

**③ "Upsert: một câu lệnh, hai vai — và rethrow vì caller quyết"**
(NORMAL).

`upsert(payload, onConflict: 'auth_uuid')`: không có row trùng
`auth_uuid` → INSERT; đã có → UPDATE đúng hàng đó. Không cần
select-check-existence — chính lượt `maybeSingle` ở đầu pipeline chỉ
để *merge*, không để quyết insert/update. RLS đứng sau: policy
`users_insert_own`/`users_update_own` yêu cầu
`(select auth.uid()) = auth_uuid` — upsert của bạn chỉ chạm được
row của mình. Và `rethrow`: repo emit `Failed` *rồi vẫn ném
lại* — coordinator/dialog VM quyết hiển thị gì; nuốt lỗi trong repo
sẽ biến mọi failure thành "sync im lặng không chạy".

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| `.upsert(map, onConflict: 'auth_uuid')` | insert-or-update keyed unique column — ** mới** |
| `var _isSyncing = false` + `finally { _isSyncing = false }` | re-entrancy guard — ** mới** |
| `_emit(state)` `!isClosed && value != state` | dedupe + dispose-safe emit — / reuse |
| `maybeSingle()` → `Map?` → `AppUserData.fromMap` | 0-or-1 row → DTO — reuse |
| `rethrow` (không `throw error`) | giữ nguyên stack trace gốc — |
| `// ignore_for_file: prefer_initializing_formals` | senior giữ ctor gán tay — verbatim |

## Ví dụ độc lập

Hai mươi lăm dòng — pipeline + guard thu nhỏ, DartPad chạy được:

```dart
var _syncing = false;
final log = <String>[];

Future<void> sync({required bool failFetch}) async {
  if (_syncing) { log.add('rejected (in-flight)'); return; }
  _syncing = true;
  log.add('InProgress');
  try {
    await Future<void>.delayed(Duration.zero);
    if (failFetch) throw StateError('network');
    log.add('fetched→merged→saved→upserted');
    log.add('Idle');
  } catch (e) {
    log.add('Failed($e)');
    rethrow;
  } finally {
    _syncing = false;
  }
}

Future<void> main() async {
  final a = sync(failFetch: false);   // không await — mô phỏng chồng
  await sync(failFetch: false);       // vào khi a đang giữ khoá
  await a;
  try { await sync(failFetch: true); } catch (_) {}
  print(log);
  // [InProgress, rejected (in-flight), fetched→merged→saved→upserted,
  //  Idle, InProgress, Failed(Bad state: network)]
}
```

Map trực tiếp: `log` ↔ `syncStateStream`, `_syncing` ↔ `_isSyncing`,
`rethrow` giữ đúng vai trò — caller `main` vẫn `catch` được lỗi dù
stream đã kể `Failed`.

## Android / Compose bridge

**SIMILARITY — `Mutex`/`@Synchronized` + `StateFlow`.** `_isSyncing`
≈ `mutex.isLocked` check trước khi vào (hoặc `synchronized` trên
sync block); `syncStateStream` seeded ≈ `MutableStateFlow(IDLE)` —
listener mới được replay trạng thái hiện tại giống `StateFlow.value`.

**IMPORTANT DIFFERENCE — `_isSyncing` là `bool`, không phải
suspend-lock.** Dart đơn luồng (event loop): giữa hai `await` không
ai chen vào, nên một `bool` đủ — không cần `Mutex` thật. Nhưng guard
chỉ chặn *re-entry từ cùng isolate*: hai app-instance (hai máy) vẫn
có thể sync đồng thời — lúc đó RLS + merge deterministic gánh phần
hội tụ.

**DO NOT ASSUME — upsert ≠ INSERT OR REPLACE ngây thơ.** SQLite
`REPLACE` xoá hẳn rồi chèn (mất `created_at`, kích trigger xoá);
Postgres `ON CONFLICT DO UPDATE` cập nhật tại chỗ — `updated_at`
trigger chạy, `created_at` giữ. `onConflict: 'auth_uuid'` chỉ định
cột conflict, không phải primary key `id`.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/repositories/profile/user_profile_sync_repository.dart` | `UserProfileSyncRepositoryImpl` + `UserProfileSyncRepositoryDisabled` trong MỘT file — learner verbatim (impl prepend lên trên, Disabled giữ nguyên) |
| `lib/repositories/profile/user_profile_sync_repository_contract.dart` | contract không đổi một ký tự — impl mới thoả đúng seam M24 |
| `lib/view_models/menu/menu_auth_action_coordinator.dart` | caller thật của `syncUserProfile` — đã đúng từ M24, không rewire |

## Build it step by step

**Bước 1 — `lib/repositories/profile/user_profile_sync_repository.dart`**:
thêm import rồi prepend impl (verbatim senior — Disabled giữ y phía
dưới; file bắt đầu bằng `// ignore_for_file:
prefer_initializing_formals`):

```dart
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/profile/app_user_data.dart';      // MỚI
import '../../data/auth/auth_session_data.dart';
import '../../data/profile/profile_sync_state_data.dart';
import '../../data/profile/user_profile_data.dart';
import 'user_profile_repository.dart';               // MỚI
import 'user_profile_sync_repository_contract.dart';

export 'user_profile_sync_repository_contract.dart';

class UserProfileSyncRepositoryImpl implements UserProfileSyncRepository {
  final SupabaseClient _client;
  final UserProfileRepository _userProfileRepository;
  final BehaviorSubject<ProfileSyncStateData> _syncStateSubject;
  var _isSyncing = false;

  UserProfileSyncRepositoryImpl({
    required SupabaseClient client,
    required UserProfileRepository userProfileRepository,
  })  : _client = client,
        _userProfileRepository = userProfileRepository,
        _syncStateSubject = BehaviorSubject<ProfileSyncStateData>.seeded(
          const ProfileSyncIdle(),
        );

  @override
  ValueStream<ProfileSyncStateData> get syncStateStream =>
      _syncStateSubject.stream;

  @override
  Future<void> syncUserProfile(AuthSessionAuthenticated session) async {
    if (_isSyncing) {
      return;
    }

    _isSyncing = true;
    _emit(const ProfileSyncInProgress());

    try {
      final localProfile = await _userProfileRepository.loadUserProfile();
      final remoteProfile = await _fetchRemoteProfile(session.uid);
      final mergedProfile = mergeUserProfileForSync(
        session: session,
        localProfile: localProfile,
        remoteProfile: remoteProfile,
      );

      await _userProfileRepository.saveUserProfile(mergedProfile);
      await _upsertRemoteProfile(session, mergedProfile);
      _emit(const ProfileSyncIdle());
    } catch (error) {
      _emit(ProfileSyncFailed(error.toString()));
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  Future<AppUserData?> _fetchRemoteProfile(String authUuid) async {
    final data = await _client
        .from('users')
        .select()
        .eq('auth_uuid', authUuid)
        .maybeSingle();

    if (data == null) {
      return null;
    }
    return AppUserData.fromMap(data);
  }

  Future<void> _upsertRemoteProfile(
    AuthSessionAuthenticated session,
    UserProfileData profile,
  ) async {
    final appUser = AppUserData.fromProfile(session: session, profile: profile);
    debugPrint(
      '[sync] upserting public.users '
      'level=${profile.level} exp=${profile.currentExp} '
      'games=${profile.gamesJoined} '
      'questions=${profile.totalQuestionCount} '
      'money=${profile.totalMoneyWon}',
    );

    await _client
        .from('users')
        .upsert(appUser.toUpsertMap(), onConflict: 'auth_uuid');
  }

  void _emit(ProfileSyncStateData state) {
    if (!_syncStateSubject.isClosed && _syncStateSubject.value != state) {
      _syncStateSubject.add(state);
    }
  }

  @override
  Future<void> dispose() => _syncStateSubject.close();
}
```

Comment của `UserProfileSyncRepositoryDisabled` cập nhật: không còn
là impl duy nhất — nó là nhánh `main()` chọn khi thiếu dart-define
("senior cũng giữ class này trong cùng file với impl thật").

**Bước 2 — cập nhật hai doc comment** (không đổi code):

- `user_profile_sync_repository_contract.dart`: bỏ khung "impl để
 M25" → "main chọn `UserProfileSyncRepositoryImpl` (merge + upsert
 `public.users`, M25) khi đủ cấu hình".
- `data/profile/profile_sync_state_data.dart`: "M24 port … chỉ khai
 báo" → "M25 bắt đầu được emit thật bởi
 `UserProfileSyncRepositoryImpl`".

**Bước 3 — không test mới.** `flutter analyze` + `flutter test` giữ
233. Vì sao impl không có unit test? `UserProfileSyncRepositoryImpl`
cần `SupabaseClient` *concrete* — không fake trong-process được như
contract-fake; senior cũng không có repo-level test cho nó. Mảnh
kiểm chứng nằm ở: merge thuần (Bài 2 — 7 test), payload/schema
(Bài 1 — 2 test), và call-path VM-level (Bài 5 — 3 test qua
`FakeUserProfileSyncRepository`). Đường live là OPTIONAL
(`LIVE_PROFILE_SYNC` — caution Bài 5).

## Hiểu code — ba chi tiết dễ trượt

1. **Local save TRƯỚC remote upsert là thứ tự cố ý.** Nếu upsert
 fail (mất mạng, RLS chặn), profile merge đã an toàn trên đĩa —
 lần sign-in/ván sau sync lại đẩy lên. Đảo thứ tự = có thể ghi
 remote rồi crash trước khi lưu local: hai phía lệch nhau ngay.
2. **`_emit` không emit hai lần cùng state.** `value != state` nhờ
 `==` trên variants (Idle/InProgress/Failed đều có equality);
 hai sync liên tiếp không spam `InProgress`/`Idle` trùng.
 `isClosed` guard chặn add-sau-dispose.
3. **`rethrow` ≠ nuốt.** Stream nói "Failed" cho listener, exception
 vẫn bay tới caller — coordinator M24 giữ contract này khi quyết
 dialog/snackbar; game VM Bài 4 *chọn* nuốt vì result đã lưu.
 Hai tầng quyết định khác nhau trên cùng một lỗi.

## Chạy và quan sát

```text
flutter analyze → No issues found!
flutter test    → +233: All tests passed!   (giữ nguyên — impl chưa
                  có consumer test; call-path coverage ở Bài 5 +3)
```

`flutter run` không thay đổi gì quan sát được — `main()` vẫn khởi
tạo `UserProfileSyncRepositoryDisabled()` cho đến Bài 4 đổi ternary.
Impl mới chỉ "tồn tại", chưa được chọn.

## Thử nghiệm

Đoán chuỗi `syncStateStream` mà một `UserProfileSyncRepositoryImpl`
phát ra trong ba kịch bản (subject seed `ProfileSyncIdle`):

(a) `syncUserProfile` thành công một lần;
(b) `_fetchRemoteProfile` throw;
(c) hai lần gọi `syncUserProfile` chồng nhau (lần hai vào khi lần
một đang await).

<details>
<summary>Đáp án</summary>

- (a) `Idle(seed) → InProgress → Idle` — Idle cuối *được* emit vì
 khác giá trị hiện tại (InProgress).
- (b) `Idle → InProgress → Failed('…')` + exception `rethrow` tới
 caller; `_isSyncing` mở lại trong `finally` — lần gọi sau chạy
 bình thường.
- (c) lần hai return ngay — stream **không thêm emit nào**
 (`_isSyncing` chặn trước `_emit`); tổng chuỗi chỉ
 `Idle → InProgress → Idle` của lần một.
</details>

## Lỗi hay gặp

1. **Gọi `syncUserProfile` với `AuthSessionData`.** Chữ ký đòi
 `AuthSessionAuthenticated` — type-level precondition của M24;
 caller phải `is`-check trước (coordinator + game VM đều làm vậy).
2. **Quên `finally` → `_isSyncing` kẹt `true` sau throw:** mọi sync
 sau bị từ chối im lặng — bug "sync chết một lần rồi không bao giờ
 chạy nữa", khó nhìn vì không crash.
3. **Upsert trước local save** — crash giữa chừng để remote và local
 lệch; senior ghi local trước vì đĩa là source-of-truth gần nhất.
4. **Bỏ `rethrow` "cho sạch".** Caller (coordinator) mất tín hiệu
 fail — dialog báo thành công giả; emit Failed chỉ phục vụ
 observer, không thay exception.
5. **Tưởng `maybeSingle` throw khi 0 row.** `single()` mới throw;
 `maybeSingle` trả `null` → nhánh "remote null" của merge.
6. **Emit lại `Idle` ở đầu sync** — không cần: dedupe của `_emit`
 tự chặn, và InProgress là điểm mở ca.

## Tự làm — PREDICT

Không chạy code. Cho script sau trên `UserProfileSyncRepositoryImpl`
(giả sử `SupabaseClient` mock lý tưởng có thể script), viết ra giấy
chuỗi emit + kết quả:

| # | Kịch bản |
|---|---|
| a | `syncUserProfile(s)` OK; ngay sau đó `syncUserProfile(s)` lần hai (lần một đã xong) |
| b | `dispose()` rồi `syncUserProfile(s)` (giả sử nó chạy được) — `_emit` có crash không? |
| c | `saveUserProfile` throw (sau khi merge xong) — remote upsert có chạy không? `syncStateStream.value` cuối? |

<details>
<summary>Đáp án</summary>

- a → lần hai chạy bình thường (khoá đã mở trong `finally`); chuỗi:
 `Idle → InProgress → Idle → InProgress → Idle` — InProgress lần
 hai ĐƯỢC emit vì giá trị hiện tại là Idle (dedupe chỉ chặn trùng
 *liên tiếp).
- b → **không crash**: `isClosed` guard chặn `.add` trên subject đã
 đóng; `_emit` im lặng bỏ qua — pipeline vẫn chạy hết, `rethrow`
 nếu lỗi. (Đây là lý do guard tồn tại — dispose giữa ca sync là
 chuyện có thật.)
- c → `_upsertRemoteProfile` KHÔNG chạy (nằm sau dòng throw trong
 `try`); stream: `Idle → InProgress → Failed(<error>)` +
 `rethrow`; `_isSyncing` mở lại. Merged profile đã được tính nhưng
 chưa ghi đâu cả — hai phía vẫn nhất quán "chưa sync".
</details>

## Kiểm tra hiểu biết

- **Hỏi:** `_isSyncing` khác `_requestId` (M23) ở bản chất nào? —
 **Đáp:** `_isSyncing` từ chối *vào* (write pipeline không được
 chồng); `_requestId` cho chồng nhưng loại *kết quả cũ* (read/refresh
 — bản mới thắng). Hai guard cho hai loại race khác nhau.
- **Hỏi:** vì sao emit `Failed` rồi vẫn `rethrow`? — **Đáp:** stream
 cho observer (UI/status), exception cho caller quyết hành vi;
 nuốt lỗi biến fail thành silent-no-op.
- **Hỏi:** `onConflict: 'auth_uuid'` nghĩa gì, và RLS đứng đâu? —
 **Đáp:** insert khi chưa có row trùng `auth_uuid`, update khi đã
 có — một roundtrip; RLS policy `users_*_own` bắt `auth.uid() =
  auth_uuid` nên client chỉ ghi được row của chính mình.

## Ta cố ý chưa thêm

- `main()` đổi `UserProfileSyncRepositoryDisabled()` → ternary —
 **Bài 4** (đúng một dòng, đúng pattern).
- Game VM `_syncSavedGameResult` thật — **Bài 4**.
- Unit test cho impl — không có fake `SupabaseClient` in-process;
 coverage đi đường merge/schema/VM-level (Bài 5 nói rõ).
- UI render `syncStateStream` — senior không render; stream là
 observability channel, consumer thật (nếu cần) là việc sau.
- Retry/backoff cho `Failed` — senior không có; lần sync kế
 (sign-in / ván sau) là "retry" tự nhiên.

## Checkpoint hoàn thành

- [ ] `user_profile_sync_repository.dart` chứa
 `UserProfileSyncRepositoryImpl` (guard → InProgress → load →
 fetch `maybeSingle` → merge → save → `upsert(onConflict:
  'auth_uuid')` → Idle; catch Failed+rethrow; finally mở khoá) +
 `UserProfileSyncRepositoryDisabled` cùng file.
- [ ] Hai doc comment (contract + `ProfileSyncStateData`) nói đúng
 thực trạng M25 — không còn "impl để sau".
- [ ] `flutter analyze` sạch; `flutter test` **233/233**.
- [ ] Giải thích được: thứ tự save trước upsert, `_isSyncing` vs
 `_requestId`, và tại sao impl không có unit test trực tiếp.
