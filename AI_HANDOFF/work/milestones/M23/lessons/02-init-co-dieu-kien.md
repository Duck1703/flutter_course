---
title: "Bài 2 · Init có điều kiện & DI theo cấu hình"
description: "SupabaseClientService.initialize trả null khi thiếu cấu hình → main() chọn Disabled…/Supabase… bằng một dấu ? duy nhất → AppDependencyScope nhận LeaderboardRepository. Contract không biết dữ liệu sống ở đâu — impl chọn theo config, không theo UI. Port cụm repository, sửa main+scope+3 test call-site → 171/171."
sidebar:
  label: "Bài 2 · init có điều kiện + DI"
  order: 2
---

## Mục tiêu

- Viết `SupabaseClientService.initialize(env) → SupabaseClient?` —
  thiếu cấu hình trả `null`, đủ cấu hình `Supabase.initialize` rồi
  trả `supabase.client`.
- Tạo cụm repository: contract `LeaderboardRepository` +
  `LeaderboardSnapshot`, model `LeaderboardEntryData` +
  `LeaderboardPopupState` 4 variant, hai impl
  `DisabledLeaderboardRepository`/`SupabaseLeaderboardRepository`
  (mổ xẻ query ở Bài 3).
- Nối `main()`: `env → client? → client == null ? Disabled… :
  Supabase…` → `AppDependencyScope` thêm `LeaderboardRepository`.
- Sửa 3 test call-site bắt buộc theo ctor mới → suite vẫn **171/171**.

## Bạn đang ở đâu

- Bài 1: `SupabaseEnvironment` + predicates đã vào; dart-define là
  cơ chế config duy nhất; `supabase_flutter` đã resolve.
- `main()` hiện tạo 3 repo local + `AppNavigationController` rồi
  đưa vào `AppDependencyScope` — chưa biết gì về Supabase.
- Bài này tạo *toàn bộ file* của tầng repository leaderboard
  (production verbatim), còn hiểu sâu chuỗi query + test là Bài 3.

## Vì sao việc này quan trọng ngay bây giờ

Khóa học chạy **không có credential** — môi trường này cũng vậy
(`LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED`). Nếu `main()` gọi
`Supabase.initialize` vô điều kiện thì app crash/ngẹt ngay khi
thiếu dart-define — tức là mọi learner chưa tạo project đều không
chạy được app. Senior giải quyết bằng **khởi tạo có điều kiện**:
thiếu config → `null` → repo impl tĩnh → app sống bình thường,
bảng xếp hạng vẫn mở được với số liệu mẫu. Đây là lý do "config là
plumbing, không phải state" ở Bài 1 quan trọng: *thiếu config không
phải lỗi — nó là một nhánh hợp lệ.*

## Bạn đã biết gì

- `SupabaseEnvironment.fromEnvironment()` + `isSupabaseConfigured`
  (Bài 1 — D-40).
- Contract `abstract interface class` + impl + fake (M14 — D-19,
  A-06, A-11).
- `AppDependencyScope` MultiProvider + `Provider<CONTRACT>.value`
  (M14 — A-07, F-21).
- `Future`/`async`/`await`, `try` quanh await (D-09); ternary `?:`;
  `unawaited` (D-17 — gặp lại ở Bài 5).
- `main()` bootstrap ordering (M05 — F-20, A-12).

## Mental model mới — "contract không biết dữ liệu sống ở đâu" (**A-23/A-24**, NORMAL)

M14 đã dạy DI bằng contract: UI/VM gọi `UserProfileRepository`,
không biết impl nào ngồi dưới. M23 nâng nó lên một bậc:

```text
CÙNG một kiểu LeaderboardRepository — BA impl trong đời nó:

  DisabledLeaderboardRepository   (dữ liệu tĩnh — app unconfigured)
  SupabaseLeaderboardRepository   (Data API remote — app configured)
  FakeLeaderboardRepository       (test — Bài 3)

AI chọn? → main(), bằng MỘT dấu ? duy nhất:
  supabaseClient == null ? const DisabledLeaderboardRepository()
                         : SupabaseLeaderboardRepository(client: c)

AI KHÔNG chọn? → mọi widget/VM: chúng chỉ context.read<LeaderboardRepository>()
```

Điểm mới so với M14: **impl được chọn theo CẤU HÌNH build, không
phải theo trạng thái UI**. Không có `if (configured)` nào trong
widget — điểm rẽ duy nhất sống ở bootstrap, nơi quyết định đúng một
lần. Đây là DI làm đúng việc của nó: đổi *nguồn* mà không đổi một
dòng UI (A-24: *conditional DI by configuration*).

:::note[Null là "sentinel" của senior]
`initialize` trả `SupabaseClient?` — `null` chính là tín hiệu
"chưa cấu hình". Không có class `SupabaseNotConfigured` nào: senior
chỉ dùng nullable + một `?:`. (Brief từng ghi tên sentinel đó —
grep repo senior: không tồn tại; nullable chính là sentinel.)
:::

## Dart/Flutter cần dùng — xuất hiện đầu tiên

| Construct | Vai trò |
|---|---|
| `Supabase.initialize(url:, publishableKey:)` | SDK `supabase_flutter` (F-31, LIGHT): mở kênh REST/realtime tới project; trả `Supabase` object |
| `supabase.client` → `SupabaseClient` | object gọi query (`from(...)`) — chỉ tồn tại khi đã initialize |
| `abstract interface class LeaderboardRepository` | contract — D-19 áp dụng lại |
| `x == null ? implA : implB(x)` | chọn impl theo cấu hình tại bootstrap — pattern A-24 |

`Supabase.initialize` là hàm `static async` của SDK: gọi nó = mở
kết nối tới project (URL + publishable key). `supabase.client` là
`SupabaseClient` — handle mà repository remote sẽ cầm để query.
Không cần hiểu sâu SDK: với app này nó là "ổ cắm mạng" mà Bài 3
cắm query vào.

## Ví dụ độc lập — một contract, ba nguồn

15 dòng cho thấy pattern trước khi gặp bản production:

```dart
abstract interface class ScoreRepository {
  Future<int> topScore();
}

class FakeScoreRepository implements ScoreRepository {
  @override
  Future<int> topScore() async => 999; // script test
}

class RemoteScoreRepository implements ScoreRepository {
  final Object channel; // "SupabaseClient" tượng trưng
  const RemoteScoreRepository(this.channel);
  @override
  Future<int> topScore() async => /* await channel.query */ 0;
}

void main() {
  final Object? channel = null; // "supabaseClient == null"
  final ScoreRepository repo =
      channel == null ? FakeScoreRepository()
                      : RemoteScoreRepository(channel);
  // phía dưới: mọi code chỉ biết `repo.topScore()` — không `if` nữa
}
```

`Object? channel = null` đóng vai `supabaseClient == null`: điểm rẽ
duy nhất. Map sang leaderboard: `FakeScoreRepository` →
`DisabledLeaderboardRepository` (cùng vai trò "impl tĩnh khi không
remote"), `RemoteScoreRepository` → `SupabaseLeaderboardRepository`.

## Android / Compose bridge

**SIMILARITY — đây là "module chọn impl" bạn đã làm trong Hilt/Koin.**
Chọn `DisabledLeaderboardRepository` hay `SupabaseLeaderboardRepository`
theo config y hệt `@Provides fun provideRepo(buildConfig): Repo =
if (configured) RemoteRepo(client) else FakeRepo()` — quyết định một
lần ở composition root, phía dưới ai cũng chỉ thấy interface.

**IMPORTANT DIFFERENCE — không có DI framework.** `main()` tự đóng vai
graph: khởi tạo tay, chọn impl bằng `?:`, rồi đẩy vào
`AppDependencyScope` (Provider) thay vì `@Inject`/module. "Composition
root" ở đây là 10 dòng code thường, không phải annotation.

**DO NOT ASSUME — đừng tìm `isDebug`/`BuildConfig.FLAVOR`.** Config
đến từ `--dart-define` (compile-time, đọc qua `String.fromEnvironment`
— Bài 1), không phải biến Gradle sinh ra. App Flutter không có khái
niệm build-variant mặc định: "flavor" ở đây là *có truyền
dart-define hay không*, và cả hai nhánh phải chạy an toàn từ cùng một
binary source. Cũng đừng chờ một `Result`/`Either` bọc kết quả init —
`SupabaseClient?` nullable chính là sentinel: `null` = chưa cấu hình.

## Build it step by step

**Bước 1 — `lib/services/supabase_client_service.dart`** (verbatim
senior):

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_environment.dart';

class SupabaseClientService {
  const SupabaseClientService._();

  static Future<SupabaseClient?> initialize(
    SupabaseEnvironment environment,
  ) async {
    if (!environment.isSupabaseConfigured) {
      return null; // thiếu config → null, KHÔNG throw, KHÔNG init
    }

    final supabase = await Supabase.initialize(
      url: environment.supabaseUrl,
      publishableKey: environment.publishableKey,
    );

    return supabase.client;
  }
}
```

**Bước 2 — `lib/repositories/leaderboard/leaderboard_repository_contract.dart`**
(verbatim senior):

```dart
abstract interface class LeaderboardRepository {
  /// `currentUserId` là auth uid (null = guest) để impl remote lấy
  /// thêm hàng của chính họ.
  Future<LeaderboardSnapshot> loadLeaderboard({String? currentUserId});
}

class LeaderboardSnapshot {
  final List<LeaderboardEntryData> entries;
  final LeaderboardEntryData? currentEntry;

  const LeaderboardSnapshot({required this.entries, this.currentEntry});
}
```

`LeaderboardSnapshot` = kết quả một lần tải: danh sách top (đã sort)
+ hàng của người chơi hiện tại *nếu có*. Snapshot — không phải
stream: mỗi `loadLeaderboard` là một ảnh chụp; muốn mới thì gọi
lại (Bài 4 `refresh()` làm đúng việc đó).

**Bước 3 — `lib/data/leaderboard/leaderboard_entry_data.dart`.**
Port file đầy đủ (132 dòng): `LeaderboardEntryData{rank, name,
level, score, avatarUrl?, isCurrentUser}` + `enum
LeaderboardPopupMessage{empty, loadError, loading}` + `sealed class
LeaderboardPopupState` với 4 variant `LeaderboardPopupSuccess`
(`entries`/`currentEntry`/`isRefreshing`), `LeaderboardPopupEmpty`,
`LeaderboardPopupError`, `LeaderboardPopupLoading` + dữ liệu tĩnh
`leaderboardEntries` (6 hàng) + `currentLeaderboardEntry` (rank 125,
`isCurrentUser: true`).

:::note[Vì sao file này vào ở Bài 2 chứ không phải Bài 4]
Contract ở Bước 2 `import` nó — phải tồn tại ngay bây giờ. Bốn
`LeaderboardPopup*` variant ở cuối file là state của DIALOG — Bài 4
VM emit chúng, Bài 5 UI switch trên chúng. Tạo trọn file verbatim
ngay từ đầu thay vì vá từng mảng.
:::

:::caution[Khác senior có chủ đích — register]
`LeaderboardEntryData` learner **không** có `avatarAsset`,
`rankAsset`, `style` (`LeaderboardRowStyle`) — ba field pipeline
asset/SVG của senior → M28. `avatarUrl` GIỮ lại vì nó là dữ liệu
remote, không phải asset.
:::

**Bước 4 — `lib/repositories/leaderboard/leaderboard_repository.dart`.**
Port file đầy đủ (161 dòng): hằng `_leaderboardView`/`_leaderboardColumns`/
`_topEntryCount`, `SupabaseLeaderboardRepository` với chuỗi query
senior + `_loadCurrentEntry` + seam `@visibleForTesting entryFromRow`,
`DisabledLeaderboardRepository` trả static snapshot, `_LeaderboardRecord`
mapper phòng thủ. **Bài 3 mổ xẻ từng mắt xích** — bước này chỉ cần
file vào đúng chỗ + `export 'leaderboard_repository_contract.dart';`
ở đầu (để ai import repo cũng thấy contract + snapshot).

**Bước 5 — `lib/core/app_dependency_scope.dart`** — thêm repo thứ tư:

```dart
import '../repositories/leaderboard/leaderboard_repository_contract.dart';

  /// M23: repo bảng xếp hạng — `main()` chọn impl theo CẤU HÌNH.
  final LeaderboardRepository leaderboardRepository;
  // ctor: required this.leaderboardRepository,
  // providers:
  Provider<LeaderboardRepository>.value(value: leaderboardRepository),
```

Đăng ký dưới kiểu CONTRACT — điểm mấu chốt để test đổi impl mà
không sửa UI (A-07 nhắc lại lần thứ n).

**Bước 6 — `lib/main.dart`** — chen khối M23 vào bootstrap, đúng
thứ tự senior:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final supabaseEnvironment = SupabaseEnvironment.fromEnvironment();
  debugPrint(
    '[supabase] config supabase=${supabaseEnvironment.isSupabaseConfigured} '
    'google=${supabaseEnvironment.isGoogleConfigured}',
  );
  final supabaseClient = await SupabaseClientService.initialize(
    supabaseEnvironment,
  );
  final userProfileRepository = await UserProfileRepositoryImpl.create();
  final userSettingsRepository = await UserSettingsRepositoryImpl.create();
  final onboardingRepository = await OnboardingRepositoryImpl.create();
  final LeaderboardRepository leaderboardRepository =
      supabaseClient == null
      ? const DisabledLeaderboardRepository()
      : SupabaseLeaderboardRepository(client: supabaseClient);
  final navigationController = AppNavigationController();
  await userSettingsRepository.loadUserSettings();
  runApp(
    AppDependencyScope(
      userProfileRepository: userProfileRepository,
      userSettingsRepository: userSettingsRepository,
      onboardingRepository: onboardingRepository,
      leaderboardRepository: leaderboardRepository, // mới
      navigationController: navigationController,
      child: const AIMillionaireApp(),
    ),
  );
}
```

+ imports: `core/supabase_environment.dart`,
`services/supabase_client_service.dart`,
`repositories/leaderboard/leaderboard_repository.dart`.

**Bước 7 — sửa 3 test call-site (bắt buộc để compile).** Ctor
`AppDependencyScope` giờ `required leaderboardRepository` — ba file
test dựng scope phải truyền:

```dart
// test/menu_provider_scope_test.dart, test/menu_screen_ui_events_test.dart,
// test/widgets/game_screen_test.dart — thêm vào AppDependencyScope(...):
leaderboardRepository: const DisabledLeaderboardRepository(),
// + import 'package:ai_millionaire_course/repositories/leaderboard/leaderboard_repository.dart';
```

`flutter analyze` chỉ đúng ba chỗ nếu sót — đó là compiler làm
việc thay checklist.

## Hiểu code — thứ tự bootstrap có chủ đích

1. `fromEnvironment()` đọc dart-define — đồng bộ, tức thì.
2. `debugPrint('[supabase] config …')` in hai predicate — cửa sổ
   debug đầu tiên khi "app không lên remote" (senior in `[auth]` —
   learner chưa có auth nên đổi tag).
3. `await SupabaseClientService.initialize(...)` — ĐIỂM RẼ duy
   nhất: `null` hay `SupabaseClient`.
4. Ba repo local create y như cũ — không bị ảnh hưởng.
5. Ternary chọn impl leaderboard → gắn vào scope → `runApp`.

`Supabase.initialize` nằm SAU `ensureInitialized` — bắt buộc vì SDK
Flutter cần binding trước khi mở kênh platform.

## Chạy và quan sát

```text
flutter analyze   → No issues found!  (sau Bước 7; sót call-site
                    sẽ báo ngay 'required parameter missing')
flutter test      → +171: All tests passed!  (không test mới —
                    chỉ compile-forced arg)
flutter run       → app chạy bình thường; console in
                    "[supabase] config supabase=false google=false"
```

`supabase=false` là *đúng* — không dart-define nào được truyền nên
app chạy impl tĩnh. Menu trông y hệt — vì chưa có consumer nào của
`LeaderboardRepository` (dialog = Bài 5). Đó chính là điểm: DI đổi
bên dưới, mặt nước phẳng lặng.

## Thử nghiệm

Không sửa code — chỉ đọc và đoán: nếu bỏ `await` trước
`SupabaseClientService.initialize(...)`, dòng ternary nhận được
`SupabaseClient?` hay `Future<SupabaseClient?>`? `flutter analyze`
báo gì?

<details>
<summary>Đáp án</summary>

`supabaseClient` trở thành `Future<SupabaseClient?>` — ternary
`== null` luôn false (Future không null) và nhánh
`SupabaseLeaderboardRepository(client: supabaseClient)` lỗi kiểu:
`Future` không gán cho `SupabaseClient` được → analyze báo lỗi
argument type ngay. Một `await` quyết định cả nhánh DI.
</details>

## Lỗi hay gặp

1. **Gọi `Supabase.initialize` vô điều kiện trong `main()`.** Thiếu
   dart-define → init với URL rỗng → crash/exception ngay khởi
   động — mất luôn fallback. Luôn qua `SupabaseClientService` có
   gate `isSupabaseConfigured`.
2. **Rẽ nhánh impl trong widget/VM.** `if (kIsConfigured) read<A>()
   else read<B>()` là phản-pattern: scope chỉ đăng ký MỘT contract;
   điểm chọn impl thuộc về `main()`.
3. **Đăng ký `Provider<SupabaseLeaderboardRepository>`.** Phải là
   `Provider<LeaderboardRepository>` — kiểu contract; đăng ký kiểu
   impl thì test/UI buộc chết vào remote impl, mất khả năng đổi.
4. **Quên sửa 3 test call-site.** `AppDependencyScope` ctor mới là
   `required` — sót một file → analyze đỏ + test file đó không
   compile.
5. **Tưởng `null` client là lỗi cần try/catch.** `null` là sentinel
   hợp lệ — đừng bọc `initialize` trong try/catch "phòng hờ" rồi nuốt
   mất nhánh Disabled.

## Tự làm — PREDICT

Không chạy app. Trả lời cho HAI kịch bản khởi chạy:

| | A: không dart-define | B: đủ `SUPABASE_URL` + `SUPABASE_PUBLISHABLE_KEY` |
|---|---|---|
| `isSupabaseConfigured` | ? | ? |
| `supabaseClient` | ? | ? |
| impl trong scope | ? | ? |
| `context.read<LeaderboardRepository>()` trả | ? | ? |

<details>
<summary>Đáp án</summary>

- A: `false` → `null` → `const DisabledLeaderboardRepository()` →
  đọc ra đúng impl tĩnh đó (dữ liệu 6 hàng + hàng rank 125).
- B: `true` → `SupabaseClient` (sau `Supabase.initialize`) →
  `SupabaseLeaderboardRepository(client:)` → đọc ra remote impl.
- Cả hai: **widget không đổi một dòng** — cùng `context.read<
  LeaderboardRepository>()`; chỉ object dưới contract khác. Đó là
  toàn bộ ý nghĩa của A-24.

</details>

## Kiểm tra hiểu biết

- **Hỏi:** "sentinel" báo chưa-cấu-hình của senior là gì? — **Đáp:**
  `SupabaseClient?` = `null` từ `initialize`; không có class
  sentinel riêng.
- **Hỏi:** ai chọn giữa Disabled/Supabase impl và ở đâu? — **Đáp:**
  `main()` tại `supabaseClient == null ? … : …` — một lần lúc
  bootstrap; UI/VM chỉ đọc contract từ scope.
- **Hỏi:** vì sao provider đăng ký `LeaderboardRepository` chứ
  không phải `SupabaseLeaderboardRepository`? — **Đáp:** đăng ký
  theo kiểu contract để impl đổi được (Disabled/Supabase/Fake) mà
  consumer không biết — DI theo A-07.

## Ta cố ý chưa thêm

- Chuỗi query `from().select().order().limit()` + `maybeSingle()` +
  row mapping — **Bài 3** mổ xẻ.
- `LeaderboardDialogViewModel` dùng 4 state variant — **Bài 4**.
- Consumer thật của repo (dialog + menu row) — **Bài 5**.
- `AuthRepository`/`SupabaseAuthRepository` + `DisabledAuthRepository`
  của senior (cùng nhánh `?:` trong `main.dart` senior) — **M24**.
- Realtime subscriptions — ngoài scope (senior cũng không dùng cho
  bảng này).

## Checkpoint hoàn thành

- [ ] Bốn file mới tồn tại: `services/supabase_client_service.dart`,
  `repositories/leaderboard/leaderboard_repository_contract.dart`,
  `data/leaderboard/leaderboard_entry_data.dart`,
  `repositories/leaderboard/leaderboard_repository.dart`.
- [ ] `main()` có đủ: env → `[supabase] config` print → conditional
  `initialize` → ternary chọn impl → `leaderboardRepository` vào
  `AppDependencyScope`.
- [ ] Ba test file truyền `leaderboardRepository: const
  DisabledLeaderboardRepository()` + import đúng.
- [ ] `flutter analyze` sạch; `flutter test` **171/171**.
- [ ] `flutter run` (không dart-define) chạy được; console có
  `supabase=false`.
