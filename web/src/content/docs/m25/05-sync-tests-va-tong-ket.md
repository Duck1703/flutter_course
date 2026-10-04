---
title: "Bài 5 · Test sync VM-level + tổng kết "
description: "Group 'result profile sync (M25)': authed → sync gọi đúng uid; guest → save vẫn chạy + sync skip; syncError → nuốt + local save intact → 233 → 236. LIVE_PROFILE_SYNC: NOT_PERFORMED — merge/schema/call-path gánh verify. → CONVERGED; divergence còn lại: DRE M26, dialog transport M29, visual M28."
sidebar:
 label: "Bài 5 · sync tests + tổng kết"
 order: 5
---

## Mục tiêu

- Thêm group 
`result profile sync (M25, FR-36)`
 vào
 
`test/game_screen_view_model_test.dart`
 — 3 test khoá call-path:
 authenticated → 
`syncCallCount == 1`
 + 
`lastSyncedSession.uid`;
 guest → 
`syncCallCount == 0`
 + save vẫn 
`1`; 
`syncError`
 → nuốt +
 save intact. Suite **233 → 236**.
- Nói trung thực được 
`LIVE_PROFILE_SYNC: NOT_PERFORMED`
 nghĩa gì,
 cái gì gánh vai trò verify thay (merge thuần ×7, schema ×2, call-path ×3, port senior-verbatim, SQL byte-parity) — và live-run
 OPTIONAL thì nhìn vào đâu.
- Đóng trong fidelity register: seam Disabled → impl thật
 + conditional DI + result-sync branch.
- Chỉ được divergence còn mở sau M25 (không phải của milestone này):
 DRE (M26), 
`MenuDialogLayer`
 transport (M29), visual parity (M28).

## Bạn đang ở đâu

- Cuối Bài 4: toàn bộ production code của M25 đã land —
 
`AppUserData`, merge, impl, DI, 
`_syncSavedGameResult`
 thật.
 Suite **233/233**, chưa có test nào chứng minh đường result→sync.
- 
`game_screen_view_model_test.dart`
 đã có 
`startedVm(async, n,
  {repo, authRepo, syncRepo})`
 + 
`FakeAsync`
 quen thuộc từ M19–M22.
- Senior chứng minh cùng điều này bằng widget test
 (`game_screen_result_flow_test.dart`
: 
`syncCallCount == 1`
 sau
 authenticated result save); learner assert ở tầng VM — cùng ý
 nghĩa, gọn hơn.

## Vì sao việc này quan trọng ngay bây giờ

Không có ba test này, 
`_syncSavedGameResult`
 là code "tin rằng đúng":
stub→thật đổi bốn dòng, không test nào đỏ nếu bạn viết sai — ví dụ
gọi sync trước khi check session, truyền nhầm session, hay nuốt cả
nhánh authed. Ba assert 
`syncCallCount`
/
`lastSyncedSession`
/

`saveCallCount`
 là bằng chứng *nhịp gọi* chứ không phải bằng chứng
mạng — và trong môi trường không credential, đó là bằng chứng mạnh
nhất ta có. Đây cũng là lần cuối nhìn lại toàn pipeline để khóa
 cho register.

## Bạn đã biết gì

- 
`FakeAsync().run((async) { … async.flushMicrotasks() })`
 lái
 chuỗi 
`unawaited`
 future (M19+).
- 
`FakeAuthRepository(initialSession:)`
 seed guest/authed;
 
`FakeUserProfileSyncRepository`
 
`syncCallCount`
/
`lastSyncedSession`
/
 
`syncError`
 (M24 helpers).
- 
`backToMenu()`
 → 
`_emitWithSaveResult`
 → 
`unawaited(
 _saveGameResult)`
 → save → 
`_syncSavedGameResult`
 (M22, Bài 4).
- Toàn bộ semantics merge/state/DI (Bài 1–4).

## Mental model — "test ở đúng tầng, tin ở đúng chỗ"

```text
tầng PURE     : mergeUserProfileForSync — 7 test (Bài 2)
                "luật đúng" — không mạng, không repo
tầng CONTRACT : toUpsertMap ↔ cột / fromMap row — 2 test (Bài 1)
                "payload khớp schema" — không client
tầng CALL-PATH: VM → repo contract — 3 test (Bài 5)
                "gọi đúng lúc, đúng session, nuốt đúng lỗi" — fake
tầng WIRE     : Supabase thật + RLS thật — LIVE_PROFILE_SYNC
                NOT_PERFORMED (không credential) — senior-verbatim +
                SQL byte-parity + impl shape đứng chỗ
```

Bài học lớn của milestone không phải "sync chạy được trên máy tôi"
(không ai chạy được ở đây) — là **mỗi tầng có một kiểu bằng chứng
riêng**, và tổng ba tầng deterministic đủ để nói thật: pipeline đúng
theo spec senior; phần duy nhất chưa chứng minh là wire thật, và điều
đó được *ghi nhận* thay vì giả vờ.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
|---|---|
| 
`group('result profile sync (M25, FR-36)', …)`
 | nhóm test theo FR — truy vết register |
| 
`startedVm(async, 3, repo: …, authRepo: …, syncRepo: …)`
 | helper Bài 4 trả công — param tuỳ chọn |
| 
`..syncError = StateError('network down')`
 | script throw trên fake — |
| 
`addTearDown(auth.dispose)`
/
`(sync.dispose)`
 | subject ownership — |

Không construct mới — bài này là composition + honesty.

## Ví dụ độc lập

Ba assert cốt lõi, tự chứa — DartPad-style (bỏ Flutter):

```dart
var saveCalls = 0, syncCalls = 0;
String? lastUid;
Object? syncError;

Future<void> saveAndSync({required String? uid}) async {
  saveCalls++;
  try {
    if (uid != null) {
      syncCalls++;
      lastUid = uid;
      if (syncError != null) throw syncError!;
    }
  } catch (_) {/* nuốt — save đã xong */}
}

Future<void> main() async {
  await saveAndSync(uid: 'user-1');           // authed
  assert(saveCalls == 1 && syncCalls == 1 && lastUid == 'user-1');
  await saveAndSync(uid: null);               // guest
  assert(saveCalls == 2 && syncCalls == 1);
  syncError = StateError('network down');
  await saveAndSync(uid: 'user-1');           // sync throw → nuốt
  assert(saveCalls == 3 && syncCalls == 2);   // đã gọi RỒI mới fail
  print('all assertions hold');
}
```

Đây là xương sống của cả ba shipped test — chú ý case cuối:

`syncCalls == 2`
 nghĩa là sync **đã được gọi rồi mới fail**, không
phải bị skip; fake đếm *lời gọi*, lỗi ở trong thân.

## Android / Compose bridge

**SIMILARITY — fake 
`SyncAdapter`
/mock 
`WorkManager`.** Đếm

`syncCallCount`
 ≈ verify 
`worker.enqueued == 1`; 
`lastSyncedSession`

≈ captor trên input data; 
`syncError`
 ≈ 
`Result.failure()`
 script —
cùng kiểu "không chạm mạng, kiểm nhịp gọi".

**IMPORTANT DIFFERENCE — không 
`InstantTaskExecutorRule`
/coroutine
test.** Chuỗi save→sync ở đây là 
`unawaited`
 microtask +

`Future.delayed`
 — 
`FakeAsync`
 + 
`flushMicrotasks()`
 là đồng hồ ảo;
không cần dispatcher thay thế hay 
`runTest`
 scoping đặc biệt.

**DO NOT ASSUME — guest case là test tách, không phải edge bỏ qua.**
Trên Android có thể bạn chỉ test happy path authed; ở đây guest là
*variant session hợp lệ* (M24) — 
`syncCallCount == 0`
 khi guest là
hành vi được khóa, không phải "không test thì cũng được".

## Senior project connection

| Senior @ 
`main@c8eb860`
 | Dùng để chứng minh |
|---|---|
| 
`test/widgets/game_screen_result_flow_test.dart`
 | senior assert 
`syncCallCount == 1`
 sau authenticated result save ở tầng widget — learner port ngữ nghĩa xuống tầng VM (`startedVm`
 + FakeAsync) |
| 
`test/user_profile_sync_merge_test.dart`
 + 
`test/user_profile_sync_schema_test.dart`
 | 9 test learner port verbatim (Bài 1–2) — assert không bị làm yếu |
| 
`supabase/student-setup/01+02.sql`
 | byte-identical — schema/policies verify được khi có project thật |

## Build it step by step

**Bước 1 — append group vào 
`test/game_screen_view_model_test.dart`
**
(cuối 
`main`, sau group result-persistence M22):

```dart
  // ------------------------------------------------------------------
  // M25 (FR-36 converge) — result → remote sync: `_syncSavedGameResult`
  // đọc auth session sau save local; senior assert cùng điều này qua
  // `syncRepository.syncCallCount` trong
  // `test/widgets/game_screen_result_flow_test.dart` — ở đây ở tầng VM.
  // ------------------------------------------------------------------
  group('result profile sync (M25, FR-36)', () {
    test('authenticated → save xong gọi syncUserProfile đúng session',
        () {
      FakeAsync().run((async) {
        final repo = FakeUserProfileRepository();
        final auth = FakeAuthRepository(
          initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
        );
        final sync = FakeUserProfileSyncRepository();
        final vm = startedVm(
          async, 3, repo: repo, authRepo: auth, syncRepo: sync);
        addTearDown(vm.dispose);
        addTearDown(auth.dispose);
        addTearDown(sync.dispose);

        vm.backToMenu(); // save → sync
        async.flushMicrotasks();

        expect(repo.saveCallCount, 1);
        expect(sync.syncCallCount, 1);
        expect(sync.lastSyncedSession?.uid, 'user-1');
      });
    });

    test('guest → save local vẫn chạy, sync bị skip (session=guest)',
        () {
      FakeAsync().run((async) {
        final repo = FakeUserProfileRepository();
        final sync = FakeUserProfileSyncRepository();
        final vm = startedVm(async, 3, repo: repo, syncRepo: sync);
        // authRepo mặc định = guest
        addTearDown(vm.dispose);
        addTearDown(sync.dispose);

        vm.backToMenu();
        async.flushMicrotasks();

        expect(repo.saveCallCount, 1);
        expect(sync.syncCallCount, 0);
      });
    });

    test('sync throw → nuốt lỗi + log; save local vẫn thành công '
        '(retry ở lần sync sau — senior cũng catch+print)', () {
      FakeAsync().run((async) {
        final repo = FakeUserProfileRepository();
        final auth = FakeAuthRepository(
          initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
        );
        final sync = FakeUserProfileSyncRepository()
          ..syncError = StateError('network down');
        final vm = startedVm(
          async, 3, repo: repo, authRepo: auth, syncRepo: sync);
        addTearDown(vm.dispose);
        addTearDown(auth.dispose);
        addTearDown(sync.dispose);

        vm.backToMenu();
        async.flushMicrotasks(); // không throw — catch trong VM

        expect(repo.saveCallCount, 1); // local save đã xong
        expect(sync.syncCallCount, 1); // sync ĐÃ được gọi rồi fail
      });
    });
  });
```

**Bước 2 — chạy và đọc:** 
`flutter test
test/game_screen_view_model_test.dart`
 → group mới xanh;

`flutter test`
 → **236/236**. Đóng milestone: 
`flutter analyze`

sạch, 
`flutter build web`
 PASS.

## Hiểu code — ba chi tiết dễ trượt

1. **
`flushMicrotasks()`
 là đồng hồ đủ cho chuỗi này.** 
`_saveGameResult`

 chạy 
`unawaited`
 — mỗi 
`await`
 trong chuỗi (load → save →
 loadAuthState → sync) là một microtask; 
`flushMicrotasks`
 xả hết
 hàng đợi → sau đó mọi 
`…CallCount`
 đã chốt. Không cần 
`elapse`

 vì không 
`Timer`
/
`Future.delayed`
 trong đường save.
2. **
`syncError`
 test assert 
`syncCallCount == 1`, KHÔNG phải 0.**
 Sync được *gọi* rồi mới throw — fake đếm lời gọi. Đây là điểm
 "đã gọi rồi fail" khác với guest "không gọi": hai câu chuyện khác
 nhau, hai số khác nhau.
3. **Assert ở tầng VM, không phải tầng widget.** Senior kiểm cùng
 nhịp qua 
`game_screen_result_flow_test.dart`
 (widget test có
 
`syncCallCount == 1`
 sau save); learner chọn VM-level vì
 
`startedVm`
 đã cho cùng quan sát với ít plumbing — semantics giữ,
 tầng test gọn hơn. Không phải suy yếu: cùng một đường
 
`backToMenu → save → sync`.

## Chạy và quan sát

```text
flutter analyze → No issues found!
flutter test    → +236: All tests passed!   (233 + 3)
flutter build web → PASS
```

:::caution[LIVE_PROFILE_SYNC: NOT_PERFORMED]
Môi trường khóa không có credential Supabase — **không có lần chạy
thật nào** ghi 
`public.users`. Đường verify được gánh bởi: 7 merge
test thuần (luật), 2 schema test (payload↔cột), 3 call-path test
VM-level (nhịp gọi + session + nuốt lỗi), port senior-verbatim qua
toàn bộ file liên quan, và SQL 
`01`
+
`02`
 byte-identical (schema sẵn
sàng khi có project thật). Đường OPTIONAL nếu bạn có project riêng:
chạy 
`01-setup-database.sql`
 + 
`02-verify-database.sql`
 trong SQL
Editor → 
`flutter run --dart-define=SUPABASE_URL=<your-project-url>
--dart-define=SUPABASE_PUBLISHABLE_KEY=<your-publishable-key>`
 →
đăng nhập → mở Table Editor xem row 
`public.users`
 có 
`auth_uuid`

của bạn + level/exp vừa merge, console in 
`[sync] upserting
public.users …`
 và 
`[game] result profile sync started/completed`

sau ván. Đây là hướng dẫn đường đi, không phải kết quả đã verify.
:::

## Thử nghiệm

Đoán 
`repo.saveCallCount`
 / 
`sync.syncCallCount`
 /

`sync.lastSyncedSession?.uid`
 cho bốn kịch bản 
`backToMenu()`
 trong
cùng setup (`startedVm(async, 3, …)`), trước khi đối chiếu shipped
test:

(a) authed 
`uid: 'user-1'`, sync bình thường;
(b) authed, 
`syncError = StateError('x')`;
(c) guest (authRepo mặc định);
(d) authed 
`uid: 'user-2'`, gọi 
`backToMenu()`
 **hai lần**.

<details>
<summary>Đáp án</summary>

- a → 
`1 / 1 / 'user-1'`
 (shipped test 1).
- b → 
`1 / 1 / 'user-1'`
 — đã gọi rồi fail, 
`lastSyncedSession`
 vẫn
 được ghi trước throw (shipped test 3).
- c → 
`1 / 0 / null`
 (shipped test 2).
- d → 
`1 / 1 / 'user-2'`
 — 
`hasSavedResult`
 trên state chặn save lần
 hai (idempotence M22): 
`backToMenu`
 thứ hai không chạy
 
`_saveGameResult`
 → cả save lẫn sync không lặp. Đây là tính năng
 M22 bảo vệ M25 miễn phí.
</details>

## Lỗi hay gặp

1. **
`flushMicrotasks()`
 trước 
`backToMenu()`.** Chuỗi chưa bắt đầu
 — đúng thứ tự là gọi action rồi flush (như shipped test).
2. **Assert 
`syncCallCount == 0`
 cho ca syncError.** Fake đếm lời
 gọi — throw nằm *sau* đếm; ca đó là 
`== 1`.
3. **Quên 
`addTearDown`
 cho auth/sync fake.** Mỗi fake giữ một
 
`BehaviorSubject`
 — không dispose → leak cảnh báo trong suite.
4. **Tưởng test này chứng minh "remote đã ghi".** Không — nó chứng
 minh *call-path đúng*; wire thật là 
`LIVE_PROFILE_SYNC`

 (NOT_PERFORMED — caution trên). Đừng viết docstring quá tay.
5. **Copy cả group sang file mới thay vì append.** Group sống cùng
 
`startedVm`
/extension 
`currentCorrectOption`
 — tách file là tự
 tạo boilerplate; senior cũng giữ trong cùng file VM test.

## Tự làm — PREDICT

Không trồng bug mới — đọc kỹ 
`_syncSavedGameResult`
 và trả lời:

| # | Nếu … | Test nào đỏ? Assert nào? |
|---|---|---|
| a | xoá 
`await profileSyncRepository.syncUserProfile(session)`
 | ? |
| b | xoá toàn bộ 
`try/catch`
 của 
`_syncSavedGameResult`
 (body thẳng) | ? |
| c | đổi 
`syncUserProfile(session)`
 thành truyền 
`AuthSessionAuthenticated(uid: 'hardcoded')`
 | ? |

<details>
<summary>Đáp án + giải thích</summary>

- a → 
`'authenticated → save xong gọi syncUserProfile đúng session'`

 ĐỎ tại 
`expect(sync.syncCallCount, 1)`
 (Actual 0); ca syncError
 cũng ĐỎ cùng assert. Guest test vẫn xanh (0 == 0 — bẫy xanh một nửa).
- b → **không test nào đỏ** (đã verify bằng cách chạy thật): lỗi
 
`StateError`
 lan lên catch ngoài của 
`_saveGameResult`
 → log đổi
 thành 
`'Failed to save game result: Bad state: network down'`

 thay 
`'[game] result profile sync failed: …'`
 — assert chỉ đếm
 call nên suite xanh, nhưng **log kể sai**: "save result failed"
 trong khi save thành công. Bài học: catch ngoài là dự phòng, inner
 catch là *ngữ nghĩa*; test không bắt được khác biệt đó — đây là
 giới hạn của assert đếm call và lý do log cần giữ đúng từ.
- c → 
`'authenticated → … đúng session'`
 ĐỎ tại
 
`expect(sync.lastSyncedSession?.uid, 'user-1')`
 (Actual
 
`'hardcoded'`); ca syncError vẫn xanh (không assert uid). Nói
 cách khác: hai assert của test 1 khóa hai chiều khác nhau —
 nhịp gọi và đúng đối tượng.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** ba tầng bằng chứng deterministic của M25 là gì, và tầng
 nào thiếu? — **Đáp:** pure merge (7) + payload/schema (2) +
 call-path VM (3); thiếu wire thật vì 
`LIVE_PROFILE_SYNC:
  NOT_PERFORMED`
 — ghi nhận, không giả vờ.
- **Hỏi:** vì sao ca 
`syncError`
 assert 
`syncCallCount == 1`
 mà không
 phải 
`== 0`
? — **Đáp:** fake đếm *lời gọi*; throw xảy ra trong thân
 
`syncUserProfile`
 sau khi 
`syncCallCount++`
 và 
`lastSyncedSession`

 đã ghi — "đã gọi rồi fail" ≠ "bị skip".
- **Hỏi:** converge nghĩa là gì ở mức file? — **Đáp:**
 
`UserProfileSyncRepositoryDisabled`
 không còn là impl duy nhất:
 impl thật trong cùng file + 
`main()`
 chọn theo 
`supabaseClient`
 +
 
`_syncSavedGameResult`
 thật — seam M24 thành đường remote thật.

## Ta cố ý chưa thêm

- 
`DreChangeNotifier`
/
`asyncOp`
 thay 
`try/catch`
+
`unawaited`
 tay —
 **M26**.
- 
`MenuDialogLayer`
 + 
`MenuDialogAuth`
/
`MenuDialogSignOut`
 state thay
 event+
`showDialog`
 — **M29** (còn ACTIVE).
- Visual parity: 
`SettingsDialogShell`
/
`OnboardingGameButton`
/icon
 pipeline/
`LevelProgressCard`
 — **M28** (32/34).
- Version text 
`v$appVersion`
 + notification permission/scheduling —
 **M27** (residual).
- UI consumer 
`syncStateStream`
 — senior không render; giữ là
 observability channel.
- Multi-tab/realtime sync — senior không có.

## Checkpoint hoàn thành

- [ ] 
`test/game_screen_view_model_test.dart`
 có group
 
`result profile sync (M25, FR-36)`
 đủ 3 test xanh.
- [ ] 
`flutter analyze`
 sạch; 
`flutter test`
 **236/236**;
 
`flutter build web`
 PASS.
- [ ] Nói được không lắp bắp: 
`LIVE_PROFILE_SYNC: NOT_PERFORMED`,
 và điều gì được/chưa được chứng minh.
- [ ] Kể được đã converge thế nào (seam → impl + DI + result
 branch) và divergence nào còn mở ở milestone nào (M26/M27/M28/M29).

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** Boundary DTO 
`AppUserData`; merge policy ba
 lớp — session-wins identity / leader progression / max totals /
 gamesWon-local / demo-normalize; pipeline repo
 
`_isSyncing`
 → InProgress → fetch 
`maybeSingle`
 → merge → save →
 
`upsert(onConflict: 'auth_uuid')`
 → Idle, Failed+rethrow; conditional DI lần ba; post-save best-effort sync
 
`_syncSavedGameResult`.
2. **Giải thích được?** Vì sao local save trước remote upsert; vì
 sao repo 
`rethrow`
 còn game VM nuốt; vì sao 
`_isSyncing`
 ≠
 
`_requestId`; vì sao username có thể remote khi local là leader;
 vì sao 
`gamesWon`
/
`email`
 không lên 
`public.users`.
3. **Viết lại không copy?** Tự làm: DEBUG xoá
 
`_withoutDemoProgression`
 → test demo đỏ tại 
`expect(level, 1)`

 Actual 12 (Bài 2) + PRODUCE scratch VM test authed→sync (Bài 4)
 + PREDICT emit-sequence/DI/failing-assert (Bài 1/3/5).
4. **Nếu … thì sao?** Remote null → chỉ đắp danh tính session;
 profile demo cũ → normalize về rỗng trước merge; 
`upsert`
 fail →
 
`Failed`
 + rethrow (coordinator) hoặc nuốt+log (game VM); thiếu
 dart-define → 
`Disabled`
 no-op, app guest không đổi.
5. **Cần ở đâu sau?** M26 đưa DRE/
`asyncOp`
 vào đường save+sync;
 M27 version text + notification; M28 visual parity; M29
 
`MenuDialogLayer`
 thay 
`showDialog`. Sync của M25 là điểm tựa:
 mọi write remote sau đều theo shape
 
`fetch → merge → save → upsert`
 này.
