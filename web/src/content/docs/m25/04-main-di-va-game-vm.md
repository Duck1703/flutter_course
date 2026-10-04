---
title: "Bài 4 · Một dòng trong main + _syncSavedGameResult thật"
description: "Conditional DI lần 3: supabaseClient == null ? Disabled : Impl(client, userProfileRepository); GameScreenViewModel ctor +authRepository +profileSyncRepository (senior order profile→auth→sync); _syncSavedGameResult stub → thật (loadAuthState → authed → sync; guest skip; lỗi nuốt + log); game_screen create + mọi call-site test compile-forced. +0 → 233."
sidebar:
 label: "Bài 4 · DI + game VM sync"
 order: 4
---

## Mục tiêu

- Đổi 
`main.dart`
: 
`UserProfileSyncRepositoryDisabled()`
 luôn →
 ternary 
`supabaseClient == null ? Disabled : Impl(client,
  userProfileRepository)`
 — **đúng một dòng logic**, lần áp dụng thứ
 ba của conditional DI (leaderboard M23, auth M24, sync M25).
- 
`GameScreenViewModel`
 ctor nhận thêm 
`required authRepository`
 +
 
`required profileSyncRepository`
 theo đúng thứ tự senior
 (profile → auth → sync → 
`{questions}`).
- Thay stub 
`_syncSavedGameResult`
 ("skipped; auth/sync → M25") bằng
 logic thật senior: 
`loadAuthState()`
 → 
`AuthSessionAuthenticated`

 → 
`syncUserProfile`
 + log started/completed; guest → log
 
`skipped; session=guest`; lỗi → nuốt + log 
`failed: $error`.
- 
`game_screen.dart`
 
`create:`
 đọc thêm 
`context.read<AuthRepository>()`

 + 
`context.read<UserProfileSyncRepository>()`; cập nhật **mọi**
 call-site test (compile-forced) + comment cũ nói "LUÔN Disabled".
- +0 test → suite giữ **233/233**; coverage call-path mới vào Bài 5.

## Bạn đang ở đâu

- Cuối Bài 3: 
`UserProfileSyncRepositoryImpl`
 tồn tại cùng file với
 Disabled — nhưng chưa ai *chọn* nó. Suite **233/233**.
- Coordinator M24 đã gọi 
`syncUserProfile(session)`
 sau sign-in —
 hiện rơi vào no-op. Game VM 
`_saveGameResult`
 (M22) gọi
 
`_syncSavedGameResult()`
 — hiện là stub in một dòng log.
- 
`AppDependencyScope`
 đã expose 
`authRepository`
 +
 
`profileSyncRepository`
 qua 
`Provider`
 từ M24 — 
`game_screen.dart`

 chỉ cần 
`context.read`
 hai cái đã có sẵn.
- 
`FakeAuthRepository(initialSession:)`
 + 
`FakeUserProfileSyncRepository`

 (syncCallCount/lastSyncedSession/syncError) đã trong 
`test/helpers/`.

## Vì sao việc này quan trọng ngay bây giờ

Đây là bài rẻ nhất và đắt nhất của milestone: rẻ vì 
`main()`
 đổi đúng
một dòng, đắt vì nó là lần thứ ba pattern 
`client == null ? Disabled
: Impl`
 lặp lại — nếu đến đây bạn vẫn phải tra lại thì pattern chưa
thành phản xạ. Phần còn lại là một quyết định thiết kế tinh tế:
**sync sau kết quả ván là best-effort, không phải bổn phận.** Local
save đã ghi xong thì ván chơi an toàn; sync fail chỉ là "chưa đẩy
lên cloud lần này" — lần sign-in sau coordinator sẽ merge và đẩy.
Nuốt lỗi ở đây KHÔNG mâu thuẫn với 
`rethrow`
 ở repo Bài 3: repo trả
quyền quyết cho caller, và caller *này* quyết nuốt (kèm log) vì đã
có source-of-truth local.

## Bạn đã biết gì

- Conditional DI 
`supabaseClient == null ? Disabled… : Impl…`
 một
 điểm chọn duy nhất trong 
`main()`
 (M23/24);
 
`SupabaseClient?`
 null sentinel; dart-define env.
- 
`_saveGameResult`
 + 
`_emitWithSaveResult`
 + 
`unawaited`
 boundary —
 VM sở hữu persistence (M22); save xảy ra một lần nhờ
 
`hasSavedResult`.
- 
`AuthRepository.loadAuthState()`
 → 
`AuthSessionData`; 
`is
 AuthSessionAuthenticated`
 check trước khi gọi sync (M24, contract Bài 3).
- 
`context.read<T>()`
 provider lookup trong 
`create:`.
- Fake repos 
`…CallCount`/
`lastSyncedSession`/
`syncError`.

## Mental model mới — hai cái cùng lúc

**① "Conditional DI: một dòng, lần ba — cùng một dáng"** (reinforcement).

```text
leaderboard (M23): client == null ? DisabledLeaderboardRepository()
                                  : SupabaseLeaderboardRepository(client)
auth        (M24): client == null ? DisabledAuthRepository(env)
                                  : AuthRepositoryImpl(client, google, apple)
sync        (M25): client == null ? UserProfileSyncRepositoryDisabled()
                                  : UserProfileSyncRepositoryImpl(client,
                                        userProfileRepository)
```

Ba repo, một câu hỏi ("có client không?"), một chỗ quyết (`main()`).
Điểm học lần này không phải ternary — là nhận ra *quyết định đã xong
từ M23* và mỗi remote repo mới chỉ thêm một nhánh cùng dáng. Đó là
lý do "contract trước impl sau" của M24 trả lãi ở đây: call-site
đúng từ lâu, đổi DI là lật công tắc.

**② "Save là bổn phận, sync là best-effort"** (NORMAL).

```text
_saveGameResult (M22):          _syncSavedGameResult (M25):
  load profile                    loadAuthState()
  +money / +exp / +stats          ├─ AuthSessionAuthenticated →
  saveUserProfile  ← BỔN PHẬN     │   syncUserProfile(session) → started/completed
  ─────────────────────           ├─ Guest → 'skipped; session=guest'
  await _syncSavedGameResult()    └─ lỗi → 'failed: $error' (nuốt + log)
     ← BEST-EFFORT, trong cùng try — nhưng catch RIÊNG của nó
```

Hai tầng bắt lỗi: 
`_syncSavedGameResult`
 tự nuốt lỗi của nó (sync
fail không được kéo "save result" xuống theo — dù catch ngoài của

`_saveGameResult`
 vẫn đỡ được nếu nó ném). Guest path không phải lỗi
— in 
`skipped; session=guest`
 rồi về. Và nhớ: 
`unawaited`
 ở

`_emitWithSaveResult`
 nghĩa là toàn bộ chuỗi chạy *ngoài* đường UI
— log 
`[game]`
 là cách duy nhất nhìn thấy nó.

## Dart cần dùng / Dart mới

| Construct | Vai trò |
| --- | --- |
| `cond ? DisabledImpl() : RemoteImpl(client, dep)` | conditional DI — (reuse lần 3) |
| `required this.authRepository` giữa hai required khác | ctor field ordering senior: profile → auth → sync → `{questions}` |
| `context.read<AuthRepository>()` trong `create:` | lấy repo từ scope vào VM |
| `if (session is AuthSessionAuthenticated)` | type check hẹp → gọi sync |
| `try/catch` nuốt + `debugPrint` | best-effort secondary op |

Không construct mới — bài này là *wiring*: mọi mảnh đã học, giờ nối
đúng chỗ. Phần "khó" là discipline: đổi ctor 
`required`
 → **mọi**
call-site phải đi cùng commit (compile-forced), và stub-comment cũ
phải chết cùng lúc (comment nói "M25 sẽ làm" trong khi M25 đang làm
là nợ honesty).

## Ví dụ độc lập

Hai mươi dòng — "caller chọn nuốt, contract cho phép ném",
DartPad chạy được:

```dart
abstract interface class SyncRepo {
  Future<void> sync(String uid); // contract: được phép throw
}

class Remote implements SyncRepo {
  @override
  Future<void> sync(String uid) async => throw StateError('offline');
}

Future<void> afterSave(SyncRepo repo, {required bool authed}) async {
  try {
    if (authed) {
      await repo.sync('u1');           // throw → catch dưới
      print('completed');
      return;
    }
    print('skipped; session=guest');
  } catch (e) {
    print('failed: $e');               // nuốt — save đã xong trước đó
  }
}

Future<void> main() async {
  await afterSave(Remote(), authed: false); // skipped; session=guest
  await afterSave(Remote(), authed: true);  // failed: Bad state: offline
  print('app vẫn sống');
}
```

Đây là hai vai trò đối lập trên cùng contract Bài 3: 
`Remote.sync`

được quyền 
`rethrow`
 (repo không giấu lỗi), 
`afterSave`
 được quyền

`catch`
+nuốt (caller quyết UX). 
`_syncSavedGameResult`
 là 
`afterSave`

của production.

## Android / Compose bridge

**SIMILARITY — 
`WorkManager`
 fire-and-forget.** 
`_syncSavedGameResult`

giống 
`OneTimeWorkRequest`
 enqueue sau khi Room write xong: local DB
là truth, sync chạy "khi tiện", fail thì retry tự nhiên lần sau —
không block UI, không crash flow.

**IMPORTANT DIFFERENCE — không retry/backoff.** WorkManager tự retry
với policy; ở đây "retry" là *lần sync kế tiếp* (sign-in sau, ván
sau) — merge idempotent nên chạy lại vô hại. Đừng thêm vòng retry
trong VM — senior không có, và merge+upsert chạy lại là an toàn.

**DO NOT ASSUME — guest path không phải error path.** 
`skipped;
session=guest`
 là log bình thường của chế độ guest hợp lệ (M24:
guest là session thật) — không phải failure cần snackbar.

## Senior project connection

| Senior @ `main@c8eb860` | Dùng để chứng minh |
| --- | --- |
| `lib/main.dart` | cùng ternary `supabaseClient == null ? Disabled : Impl(client, userProfileRepository)` — learner đổi một dòng M24 divergence → converge |
| `lib/view_models/game/bridge/game_screen_view_model_result_persistence.dart` | `_syncSavedGameResult` verbatim (learner inline vào VM — learner không có bridge/part structure): `loadAuthState` → authed → sync + started/completed; guest → `skipped; session=guest`; catch → `failed: $error` |
| `lib/view_models/game/game_screen_view_model.dart` ctor | thứ tự `required userProfileRepository, authRepository, profileSyncRepository, {questions}` |
| `lib/screens/game_screen.dart` | `create:` đọc `context.read<AuthRepository>()` + `context.read<UserProfileSyncRepository>()` |

## Build it step by step

**Bước 1 — 
`lib/main.dart`
** — thay khối "M24: LUÔN Disabled":

```dart
  // Sync repo vào CÙNG pattern điều kiện —
  // thiếu cấu hình → `UserProfileSyncRepositoryDisabled` (no-op);
  // đủ cấu hình → `UserProfileSyncRepositoryImpl` (fetch `public.users`
  // → merge local↔remote → lưu local → upsert `onConflict: auth_uuid`)
  // đúng senior.
  final UserProfileSyncRepository profileSyncRepository =
      supabaseClient == null
      ? UserProfileSyncRepositoryDisabled()
      : UserProfileSyncRepositoryImpl(
          client: supabaseClient,
          userProfileRepository: userProfileRepository,
        );
```

**Bước 2 — 
`lib/view_models/game/game_screen_view_model.dart`
** —
ctor + hai field + stub → thật:

```dart
  /// Repository phiên đăng nhập — M25: `_syncSavedGameResult` đọc
  /// session hiện tại qua `loadAuthState()` đúng senior.
  final AuthRepository authRepository;

  /// Repository đồng bộ profile — M25: upsert `public.users` sau khi
  /// save local khi session là authenticated; Disabled no-op khi
  /// unconfigured.
  final UserProfileSyncRepository profileSyncRepository;

  GameScreenViewModel({
    required this.userProfileRepository,
    required this.authRepository,
    required this.profileSyncRepository,
    this.questions = gameSampleQuestions,
  }) : _state = GameSessionState.initial(timePerQuestion: timePerQuestion);
```

và thay stub bằng (verbatim senior bridge, inline — learner không
có cấu trúc 
`part`):

```dart
  /// Senior `_syncSavedGameResult`: đọc auth
  /// session rồi chỉ sync qua `profileSyncRepository` khi
  /// `AuthSessionAuthenticated`; guest skip (log `skipped;
  /// session=guest`). Lỗi sync nuốt + log — kết quả ván đã an toàn
  /// trên đĩa; sync lần sau (sign-in / ván sau) sẽ đẩy lại.
  Future<void> _syncSavedGameResult() async {
    try {
      final session = await authRepository.loadAuthState();

      if (session is AuthSessionAuthenticated) {
        debugPrint('[game] result profile sync started');
        await profileSyncRepository.syncUserProfile(session);
        debugPrint('[game] result profile sync completed');
        return;
      }

      debugPrint('[game] result profile sync skipped; session=guest');
    } catch (error) {
      debugPrint('[game] result profile sync failed: $error');
    }
  }
```

Cập nhật luôn hai comment trong file: doc class (M22 → "+M25
authRepository + profileSyncRepository … 
`_syncSavedGameResult`
 đọc
session và upsert 
`public.users`
 khi authenticated") và doc

`_saveGameResult`
 ("nhánh sync 
`_syncSavedGameResult`
 (M25)" — không
còn "stub").

**Bước 3 — 
`lib/screens/game_screen.dart`
** — 
`create:`
 + 2 import:

```dart
create: (context) => GameScreenViewModel(
  userProfileRepository: context.read<UserProfileRepository>(),
  authRepository: context.read<AuthRepository>(),
  profileSyncRepository:
      context.read<UserProfileSyncRepository>(),
),
```

**Bước 4 — call-site test (compile-forced, một hơi đổi hết):**

- 
`test/game_screen_view_model_test.dart`
: 
`startedVm`
 thêm
 
`{FakeAuthRepository? authRepo, FakeUserProfileSyncRepository?
  syncRepo}`
 truyền xuống ctor (`authRepo ?? FakeAuthRepository()`/
 
`syncRepo ?? FakeUserProfileSyncRepository()`); 4 chỗ
 
`GameScreenViewModel(`
 còn lại truyền hai fakes; +2 import helpers.
- 
`test/widgets/game_screen_test.dart`
: 
`pumpGameScreen`
 thêm cùng
 hai param tuỳ chọn + truyền xuống ctor (Bài 5 dùng cho widget
 level — đồng bộ với 
`startedVm`).

Sót một chỗ → 
`required`
-param compile error (đó là tính năng, không
phải phiền): analyzer bắt buộc cập nhật toàn bộ.

**Bước 5 — 
`lib/core/app_dependency_scope.dart`
** — comment field

`profileSyncRepository`
: bỏ "M24 … LUÔN là

`UserProfileSyncRepositoryDisabled`
" → "M25: Disabled (no-op) khi
thiếu dart-define, 
`UserProfileSyncRepositoryImpl`
 (merge + upsert

`public.users`) khi đủ — chọn ở 
`main()`
 cùng pattern auth".

## Hiểu code — ba chi tiết dễ trượt

1. **
`loadAuthState()`
 chứ không đọc 
`authStateStream.value`.**
 Senior chọn loader — "repo ơi, cập nhật rồi trả tôi cái mới
 nhất" (M24/01 semantics); trong impl thật nó đọc
 
`client.auth.currentUser`, không chỉ replay subject.
2. **
`if (session is AuthSessionAuthenticated)`
 — không dùng
 
`session.isAuthenticated`.** Getter trả 
`bool`, nhưng nhánh cần
 *kiểu hẹp* 
`AuthSessionAuthenticated`
 để truyền vào
 
`syncUserProfile(AuthSessionAuthenticated)` —
`is`
 vừa check vừa
 promote. 
`isAuthenticated`
 dùng khi chỉ cần bool; đây cần type.
3. **Catch của 
`_syncSavedGameResult`
 nuốt lỗi CỦA NÓ — và catch
 ngoài 
`_saveGameResult`
 là lớp dự phòng.** Nếu bạn xoá catch
 trong, lỗi sync bay lên catch ngoài → log đổi thành 
`'Failed to
   save game result: …'`
 dù save đã xong — test vẫn xanh (assert chỉ
 đếm call) nhưng log kể sai chuyện. Hai catch, hai ý đồ: inner
 = "sync fail riêng", outer = "không crash vì persistence".

## Chạy và quan sát

```text
flutter analyze → No issues found!   (sót call-site → required-param error)
flutter test    → +233: All tests passed!  — giữ nguyên: wiring không
                  đổi hành vi test cũ; coverage mới ở Bài 5 (+3)
```


`flutter run`
 (không dart-define): console vẫn

`[auth] repository=disabled`, sync DI rơi nhánh Disabled — app guest
không đổi một pixel. Có dart-define của project riêng (OPTIONAL):

`AuthRepositoryImpl`
 + 
`UserProfileSyncRepositoryImpl`
 cùng được
chọn — sign-in → coordinator → fetch/merge/upsert 
`public.users`,
console 
`[sync] upserting public.users …`
 +

`[game] result profile sync started/completed`
 sau mỗi ván.

## Thử nghiệm

Đoán impl được chọn cho 
`profileSyncRepository`
 với từng env:

(a) không dart-define; (b) đủ 
`SUPABASE_URL`
 + publishable key;
(c) đủ Supabase nhưng thiếu 
`GOOGLE_WEB_CLIENT_ID`.

<details>
<summary>Đáp án</summary>

- a → 
`UserProfileSyncRepositoryDisabled` —
`supabaseClient == null`

 vì 
`isSupabaseConfigured`
 false; console 
`[auth] repository=disabled`.
- b → 
`UserProfileSyncRepositoryImpl`
 — client tồn tại.
- c → **vẫn 
`Impl`
** — sync chỉ phụ thuộc Supabase client, không
 phụ thuộc Google config; thiếu Google chỉ làm 
`AuthRepositoryImpl`

 báo 
`configurationError`
 khi bấm nút Google (email sign-in vẫn đi).
 Đây là điểm hay nhầm: ternary nhìn 
`supabaseClient`, không nhìn
 
`isGoogleConfigured`.
</details>

## Lỗi hay gặp

1. **Đổi ctor rồi commit khi chưa cập nhật hết call-site.** Sáu chỗ
 tạo VM trong test + một 
`create:`
 — analyzer bắt hết, nhưng đừng
 "fix lát": 
`?? FakeAuthRepository()`
 mặc định trong helper giữ
 test cũ nguyên semantics guest.
2. **Đọc session bằng 
`authStateStream.value`
 thay
 
`loadAuthState()`.** Cùng kết quả trong fake, khác semantics trong
 impl thật — senior chọn loader, giữ verbatim.
3. **Để 
`_syncSavedGameResult`
 throw.** Nó chạy trong 
`unawaited` —
 lỗi bị nuốt là *quyết định có ý thức*; throw ra sẽ thành
 unhandled-async-error, và inner catch tồn tại đúng để kể
 
`failed:`
 thay vì để outer catch nói sai "save result" failed.
4. **Gọi sync không check 
`is AuthSessionAuthenticated`.**
 
`syncUserProfile`
 đòi kiểu hẹp — bypass check = compile error
 (tốt) hoặc cast mù (tệ — crash thành 
`failed:`
 log ngay).
5. **Cập nhật sót comment "LUÔN Disabled".** Comment nói dối sau
 khi converge là nợ honesty — Bước 5 + doc 
`_saveGameResult`
 là
 phần của cùng thay đổi, không phải phụ.

## Tự làm — PRODUCE (bắt buộc, có đáp án)

Viết file scratch 
`test/m25_result_sync_exercise_test.dart`
 — một
test chứng minh chuỗi **result-save → sync** ở tầng VM (sẽ xoá sau, không tính suite 236; shipped equivalent vào Bài 5):

**Yêu cầu:**
1. 
`FakeAsync`
 + VM đã 
`startNewGame`
 + 
`dismissDialog`
 (qua intro);
 profile fake trống; auth fake seed
 
`AuthSessionAuthenticated(uid: 'user-1')`; sync fake mặc định.
2. Gọi 
`vm.backToMenu()`
 rồi 
`async.flushMicrotasks()`.
3. Assert: 
`repo.saveCallCount == 1`, 
`sync.syncCallCount == 1`,
 
`sync.lastSyncedSession?.uid == 'user-1'`.

<details>
<summary>Đáp án (một lời giải)</summary>

```dart
import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/data/game/game_quiz_question_data.dart';
import 'package:ai_millionaire_course/view_models/game/game_screen_view_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_profile_sync_repository.dart';
import 'helpers/fake_user_profile_repository.dart';

void main() {
  test('authed → result save → sync gọi đúng session', () {
    FakeAsync().run((async) {
      final repo = FakeUserProfileRepository();
      final auth = FakeAuthRepository(
        initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
      );
      final sync = FakeUserProfileSyncRepository();
      final vm = GameScreenViewModel(
        userProfileRepository: repo,
        authRepository: auth,
        profileSyncRepository: sync,
        questions: [
          for (var i = 0; i < 3; i++)
            GameQuizQuestionData(
              id: i,
              question: 'Q$i?',
              options: ['A$i', 'B$i', 'C$i', 'D$i'],
              correctOption: 'A$i',
              category: 'T',
              language: 'vi',
              difficulty: GameQuestionDifficulty.easy,
              explanation: const GameQuestionExplanationData(
                explainForTrueAnswer: 'x',
                explainForWrongAnswers: {},
                aiHintMessage: 'h',
              ),
            ),
        ],
      )
        ..startNewGame()
        ..dismissDialog();
      addTearDown(vm.dispose);
      addTearDown(auth.dispose);
      addTearDown(sync.dispose);

      vm.backToMenu();       // → _emitWithSaveResult → _saveGameResult
      async.flushMicrotasks(); // → load → save → _syncSavedGameResult

      expect(repo.saveCallCount, 1);
      expect(sync.syncCallCount, 1);
      expect(sync.lastSyncedSession?.uid, 'user-1');
    });
  });
}
```

Chạy 
`flutter test test/m25_result_sync_exercise_test.dart`
 → xanh.
Kiểm chứng thêm: đổi 
`initialSession`
 về 
`AuthSessionGuest()`
 →

`syncCallCount`
 thành 
`0`
 → test ĐỎ tại assert thứ hai — bạn vừa tự
tái hiện case guest của Bài 5. Xong thì **xoá file scratch**.
</details>

## Kiểm tra hiểu biết

- **Hỏi:** vì sao lỗi sync trong 
`_syncSavedGameResult`
 được nuốt
 còn repo lại 
`rethrow`
? — **Đáp:** repo giữ contract "ném cho
 caller quyết"; caller này (game VM) quyết nuốt vì local save đã
 xong — sync là best-effort, lần sign-in/ván sau merge đẩy lại.
- **Hỏi:** 
`is AuthSessionAuthenticated`
 vs 
`isAuthenticated`
 khác
 nhau ở đâu? — **Đáp:** getter trả 
`bool`; 
`is`
 vừa check vừa
 promote sang 
`AuthSessionAuthenticated`
 — kiểu hẹp mà
 
`syncUserProfile`
 đòi.
- **Hỏi:** 
`main()`
 ternary lần ba này chứng minh pattern gì? —
 **Đáp:** — một điểm chọn impl duy nhất theo 
`client == null`;
 seam contract trước (M24) khiến việc thay impl chỉ là đổi một
 dòng DI, không call-site nào đổi.

## Ta cố ý chưa thêm

- Test 
`result profile sync`
 group — **Bài 5** (+3): coverage cố ý
 tách khỏi bước wiring (giống seam M24/03 → coverage M24/04).
- DRE (`DreChangeNotifier`/
`asyncOp`) cho 
`_syncSavedGameResult` —
 **M26**; hiện 
`try/catch`
 + 
`unawaited`
 đủ.
- UI hiển thị 
`ProfileSyncInProgress/Failed`
 — senior không render;
 observability qua log.
- Retry-on-failure có policy — senior không có (xem bridge Android).
- Sign-in flow trực tiếp kiểm upsert — coordinator path đã đúng từ
 M24; xác minh live là OPTIONAL (`LIVE_PROFILE_SYNC`
 — Bài 5).

## Checkpoint hoàn thành

- [ ] 
`main.dart`
 có ternary 
`supabaseClient == null ?
  UserProfileSyncRepositoryDisabled() : UserProfileSyncRepositoryImpl(
  client: …, userProfileRepository: …)`
 và comment M25.
- [ ] 
`GameScreenViewModel`
 ctor đủ 3 required theo thứ tự senior;
 
`_syncSavedGameResult`
 đúng ba nhánh (authed sync / guest skip /
 catch nuốt); doc class + doc 
`_saveGameResult`
 đã bỏ chữ "stub".
- [ ] 
`game_screen.dart`
 
`create:`
 đọc cả ba repo; mọi call-site
 test truyền hai fakes (`startedVm`, 
`pumpGameScreen`
 có param
 tuỳ chọn).
- [ ] 
`app_dependency_scope.dart`
 comment field sync nói đúng điều
 kiện — không còn "LUÔN".
- [ ] 
`flutter analyze`
 sạch; 
`flutter test`
 **233/233**.

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m25/04 — "Một dòng trong main + _syncSavedGameResult thật" (conditional DI lần 3 cho sync repo; GameScreenViewModel ctor +authRepository +profileSyncRepository theo thứ tự senior profile→auth→sync; stub → logic thật: loadAuthState → authed → sync + guest skip + lỗi nuốt; game_screen create + mọi call-site compile-forced; +0 test → 233).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Coverage call-path (3 test) là BÀI 5 — chưa có test mới ở đây là ĐÚNG.

EXPECTED STATE SAU BÀI NÀY:
- `lib/main.dart` (STRICT — đúng một dòng logic, converge từ divergence M24): `final UserProfileSyncRepository profileSyncRepository = supabaseClient == null ? UserProfileSyncRepositoryDisabled() : UserProfileSyncRepositoryImpl(client: supabaseClient, userProfileRepository: userProfileRepository);` — cùng dáng leaderboard/auth ternary; comment cũ "M24: LUÔN Disabled" ĐÃ THAY (còn comment nói dối = honesty debt); ternary nhìn `supabaseClient` KHÔNG `isGoogleConfigured` (thiếu Google → vẫn Impl — đúng).
- `lib/view_models/game/game_screen_view_model.dart` (STRICT): ctor `GameScreenViewModel({required this.userProfileRepository, required this.authRepository, required this.profileSyncRepository, this.questions = gameSampleQuestions})` — thứ tự senior profile → auth → sync → `{questions}`; field `final AuthRepository authRepository` + `final UserProfileSyncRepository profileSyncRepository` + doc comments cập nhật (không còn "stub"/"M25 sẽ làm" — comment nói dối = nợ).
  `_syncSavedGameResult()` THẬT (STRICT verbatim): `try { final session = await authRepository.loadAuthState(); if (session is AuthSessionAuthenticated) { debugPrint('[game] result profile sync started'); await profileSyncRepository.syncUserProfile(session); debugPrint('[game] result profile sync completed'); return; } debugPrint('[game] result profile sync skipped; session=guest'); } catch (error) { debugPrint('[game] result profile sync failed: $error'); }` — STRICT: `loadAuthState()` KHÔNG `authStateStream.value` (senior chọn loader "cập nhật rồi trả mới nhất"); `is AuthSessionAuthenticated` check+promote KHÔNG `.isAuthenticated` getter (cần kiểu hẹp cho chữ ký sync); inner catch nuốt+log (sync best-effort — save đã xong; ném ra = unhandled-async trong unawaited + log outer sai "save result failed").
- `lib/screens/game_screen.dart` (STRICT): `create:` đọc thêm `context.read<AuthRepository>()` + `context.read<UserProfileSyncRepository>()` truyền ctor — +2 import.
- `lib/core/app_dependency_scope.dart` (STRICT doc): field `profileSyncRepository` comment bỏ "LUÔN Disabled" → "M25: Disabled khi thiếu dart-define, Impl khi đủ — chọn ở main()".
- TEST call-site compile-forced (STRICT): `test/game_screen_view_model_test.dart` — `startedVm` + `{FakeAuthRepository? authRepo, FakeUserProfileSyncRepository? syncRepo}` tuỳ chọn truyền `authRepo ?? FakeAuthRepository()` / `syncRepo ?? FakeUserProfileSyncRepository()`; mọi `GameScreenViewModel(` còn lại truyền 2 fakes; `test/widgets/game_screen_test.dart` — `pumpGameScreen` + cùng 2 param tuỳ chọn; +import helpers. Sót 1 chỗ → required-param compile error (tính năng).
- `flutter analyze` sạch; `flutter test` → **233/233** (STRICT — giữ nguyên). `flutter run` no dart-define → `[auth] repository=disabled` + sync Disabled — guest app không đổi pixel.
- KHÔNG ĐƯỢC có (chưa đến): group `result profile sync` trong game VM test (BÀI 5 +3); retry/backoff trong `_syncSavedGameResult` (DIVERGED — "retry" là lần sync kế tiếp, merge idempotent); `DreChangeNotifier`/`asyncOp` thay try/catch+unawaited (M26); gọi `syncUserProfile` không is-check/cast mù; `_syncSavedGameResult` throw ra ngoài; đọc `authStateStream.value` thay `loadAuthState()`; UI consumer `syncStateStream`; skip sync bằng `isAuthenticated` bool rồi truyền session cũ.

INVARIANTS NỀN — phải CÒN NGUYÊN:
- Bài 1–3: AppUserData + merge + impl trong cùng file Disabled; M24 đỉnh (coordinator, auth repos, dialog VMs, pill, events — coordinator gọi syncUserProfile không đổi); M22 `_saveGameResult` + `_emitWithSaveResult` + `hasSavedResult` + `unawaited` boundary (chuỗi vẫn ngoài đường UI); `main()` ternary leaderboard (M23) + auth (M24) nguyên; FakeAuthRepository/FakeUserProfileSyncRepository helpers (M24).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. `_syncSavedGameResult` còn stub log-only = BEHIND. Comment "LUÔN Disabled" còn sót sau khi đổi ternary = NEEDS_FIX (honesty debt).

OUTPUT (đúng format; mục trống → "None"):
LESSON: m25/04
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
