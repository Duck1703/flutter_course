---
title: "Bài 07 — Hội tụ & quét cuối: `main.dart` verbatim, previews appendix, release-kit, và gì thì CHƯA kiểm chứng"
description: "Sweep chốt: `main.dart`/`app_dependency_scope.dart`/`app_navigation_controller.dart` verbatim — bootstrap order (ensureInitialized→orientation→env→`[auth]` log→Supabase init→repo create→loadSettings→3-way ternary DI), `MultiProvider` 8 `Provider.value` contract-keyed, `StreamBuilder`→`MaterialApp.locale` derived-state, theme `ColorScheme.fromSeed(Colors.deepPurple)` light, `navigatorKey`. Previews appendix: `package:flutter/widget_previews.dart` (SDK) — `@Preview(name:,group:,size:,wrapper:)` + `previewGameApp`/`previewLayerApp` + fake-repo deps; port 6/12 file (3 catalog + 3 support), 6 catalog còn lại = declared gap (mới). `docs/release-kit-walkthrough.md` giải thích `scripts/kit`+`.release-kit` — KHÔNG chạy. Hoàn tất: ARB parity 119-key, chỉ khác product-name. 7 file test senior port + canonical re-ports → 396/396. Caveats verbatim: `REAL_DEVICE_*`/`LIVE_*` = NOT_PERFORMED. Structure audit: zero learner-only file trong `lib/`."
sidebar:
  order: 7
  label: Hội tụ & quét cuối
---

# Bài 07 — Hội tụ & quét cuối: verbatim đến tận `main()`, và nói rõ phần chưa kiểm chứng

## Mục tiêu

Sau bài này — và sau cả milestone — bạn sẽ:

- Đọc được **toàn bộ bootstrap** của app như một chuỗi có thứ
  tự: `ensureInitialized` → orientation → env → log → Supabase
  init → repo create → `loadUserSettings` → 3-way ternary DI →
  `runApp(AppDependencyScope)` — và hiểu vì sao thứ tự đó
 verbatim.
- Nắm **conditional DI một chỗ**: `client == null ? Disabled… :
  Impl…` ×3 (auth/leaderboard/profileSync) — `SupabaseClient?`
 null là sentinel, cấu hình quyết định impl.
- Thấy `MaterialApp` cuối cùng khớp senior: `locale` từ
 `StreamBuilder` trên `userSettingsStream`, theme seed
  `Colors.deepPurple` (light — senior dùng light, không dark),
 `navigatorKey`, `debugShowCheckedModeBanner:false`.
- Biết **previews appendix**: `@Preview` của SDK
  `package:flutter/widget_previews.dart` — khai báo trên top-
  level-function, wrapper = `Widget Function(Widget)` cung cấp
 app-context; port subset có chủ đích 6/12 file (LIGHT).
- Hiểu release-kit walkthrough: `scripts/kit` vendored toolkit
  + `.release-kit/project.env` — *giải thích*, **không chạy**
  (không keystore/secret trong course).
- Nói thẳng **phần chưa kiểm chứng**: `REAL_DEVICE_*`/`LIVE_*`
  = `NOT_PERFORMED` — milestone kiểm chứng bằng `analyze` +
  widget/unit test + `build web`, không device thật, không
  Supabase-live.

## Bạn đang ở đâu

Sáu bài trước đã converge mọi surface. Còn hai việc cuối:

```text
1. Những file "đỉnh-cây" chưa đối chiếu verbatim:
   main.dart (bootstrap order, theme, locale, log prefix),
   app_dependency_scope.dart (8 Provider.value),
   app_navigation_controller.dart (navigatorKey contract)
   → M29 port verbatim; cũng là lúc nhìn-lại TOÀN app.

2. Những thứ "vẫn còn khác senior — và được phép khác":
   - level_config dart2js int64 bound
   - @visibleForTesting seams (entryFromRow, loadAppVersion)
   - `final class` convention + doc-comment VI
   - appTitle/share-message = "AI Millionaire" (product rename)
   - 6/12 preview files (3/9 catalog) — declared gap
   - generated lib/l10n/*.dart (tool output)
```

Và phía test: 7 file test senior còn thiếu (`widget_test`,
`apple_auth_service_test`, `surface_glow_gradient_test`,
`dialog_shell_header_test`, `pill_button_glow_test`,
`leaderboard_dialog_view_model_async_test` + canonical
re-ports của VM tests) + async-harness — đưa **383 → 396**.

## Vì sao việc này quan trọng ngay bây giờ

Bài 07 là **chữ ký của sweep**: những file đỉnh cây (`main`,
DI-scope, nav) là chỗ "một dòng khác = hành vi app khác" —
thứ tự-`await`-sai = repo chưa load khi-UI-đọc; theme-seed-sai
= mọi mặc định-Material lệch; locale không theo stream = đổi
ngôn ngữ không áp. Verbatim ở đây không phải trung thành hình
thức — nó là bảo đảm duy nhất rằng app khởi động đúng như
senior sau hàng tá bài dạy. Và phần "nói rõ chưa kiểm chứng"
cũng là dạy: *kỹ thuật viên không claim điều mình chưa chạy.*

## Bạn đã biết gì

| Đã học | Ở đâu | Nhắc ngắn |
|---|---|---|
| `WidgetsFlutterBinding.ensureInitialized` + async main | M05+ | `main()` async đầy đủ — plugin/repo cần binding trước `runApp` |
| Async bootstrap ordering | M05, M14 | Thứ tự `await` trong `main` là contract: binding → env → client → repo → seed-load → runApp |
| `MultiProvider` + contract-keyed `Provider.value` | M14 | `AppDependencyScope` expose 8 contract — `context.read<Contract>()` đọc impl |
| Conditional DI by configuration | M23 | `client == null ? Disabled : Impl` — một chỗ duy nhất chọn impl |
| Locale = derived state ở app-root | M17 | `StreamBuilder(userSettingsStream)` → `MaterialApp.locale` — UI-follow-state |
| `AppNavigationController` + `GlobalKey<NavigatorState>` | M19 | Điều hướng context-free qua `navigatorKey` gắn `MaterialApp` |
| Service-contract platform boundary | M27 | `LocalNotificationService` contract→impl→plugin→OS — cùng một chỗ DI |
| Sweep discipline | M29·01 | Verbatim mặc định, deviation documented |
| Scaffold lifecycle | xuyên khoá | Mọi interim (MenuTokens, `*Requested` events, showXxxDialog, dark seed, adapted scope) đã retire — không còn scaffold nào đứng |

## Mental model mới — "`@Preview`: catalog là file, không phải app" (LIGHT)

```text
Senior lib/previews/          = 12 file:
  3 support:  preview_fixtures.dart (wrapper fns)
              preview_sample_data.dart (fake data)
              preview_app_dependencies.dart (fake repos)
  9 catalog:  common_, game_controls_, game_dialog_,
              leaderboard_, menu_auth_, menu_settings_,
              menu_widget_, onboarding_widget_,
              provider_shell_ _widget_previews.dart

Learner port 6/12 file:
  cả 3 support + 3 catalog
  (common, menu_widget, onboarding_widget)
  → 6 catalog còn thiếu = DECLARED GAP (brief: appendix
    subset — không phải defect)
```

Mỗi preview là **top-level function trả `Widget`**, đánh dấu
bằng annotation của **SDK** (không package ngoài):

```dart
// learner-app/lib/previews/menu_widget_previews.dart (trích)
import 'package:flutter/widget_previews.dart';   // ← SDK, Flutter 3.41+

@Preview(
  name: 'Menu profile header',
  group: 'Menu',
  size: Size(390, 120),
  wrapper: previewGameApp,          // ← Widget Function(Widget)
)
Widget menuProfileHeaderPreview() {
  return MenuProfileHeader(
    data: previewProfile,           // ← fixture từ preview_sample_data
    isAuthenticated: true,
    onAccountTap: previewNoop,
    onSettingsTap: previewNoop,
  );
}
```

- **`wrapper`**: `previewGameApp`/`previewLayerApp` bọc child
  trong `MaterialApp` + `AppLocalizations.delegates` + nền —
  vì widget preview render ngoài app, không kế thừa delegate.
- **`size`**: khung cố định để xem component ở đúng tỷ lệ.
- **`group`**: nhóm trên previewer-UI.
- Chạy bằng `flutter widget-preview start` — một *development-
  tool*, không ship trong app build.

:::note[Previews ≠ test]
`@Preview` **không assert gì** — nó là "xem widget cô lập".
Test assert-behavior (`expect(find…)`); preview chỉ hiển thị.
Vai trò của catalog: soi-visual-nhanh-khi-port (dev-tooling),
không thay thế-396-test. Đây là lý do senior để nó ở appendix
và course port subset.
:::

## Dart / Flutter cần dùng

| Dart/Flutter | Vai trò ở đây | Xem lại |
|---|---|---|
| `await` chuỗi trong-`main()` | bootstrap ordering |, |
| `client == null ? Disabled() : Impl(client:)` | conditional DI sentinel | |
| `MultiProvider([Provider<T>.value(value:)…])` | 8 contract expose | |
| `StreamBuilder(stream, initialData: stream.value)` | locale-derived |, |
| `MaterialApp(locale:, navigatorKey:, theme: ColorScheme.fromSeed(deepPurple))` | app-root verbatim | |
| `GlobalKey<NavigatorState>` + `navigatorKey.currentState` | context-free nav |, |
| `debugPrint('[auth] …')` | bootstrap-log-prefix senior | verbatim |
| `@Preview(name:, group:, size:, wrapper:)` | SDK widget-previews | mới |

## Ví dụ độc lập — sentinel-null chọn impl

```dart
/// VÍ DỤ ĐỘC LẬP — DartPad chạy được.
abstract class Repo { String get tag; }
final class DisabledRepo implements Repo { String get tag => 'disabled'; }
final class RemoteRepo implements Repo {
  final String client; const RemoteRepo(this.client);
  String get tag => 'remote:$client';
}

class Client { const Client(); }

Repo build(Client? client) =>
    client == null ? DisabledRepo() : RemoteRepo('supabase');

void main() {
  print(build(null).tag);               // disabled
  print(build(const Client()).tag);     // remote:supabase
}
```

## Android / Compose bridge

:::note[Android / Compose bridge — "main() là Hilt-module tay"]
- **SIMILARITY**: `AppDependencyScope` + ternary-DI giống
  `Application.onCreate` + `@Provides`-by-build-type — chọn
  impl một chỗ, inject-by-contract.
- **IMPORTANT DIFFERENCE**: `Provider.value` **không gọi
  dispose** — các impl này sống cùng app (không per screen);
  đó là lý do dùng `.value` (đã tạo sẵn ở main) thay-`create:`.
- **DO NOT ASSUME**: đừng nghĩ `Colors.deepPurple`-light-seed
  là tự chọn — senior đổi từ dark sang light; learner từng
  dark seed riêng. Theme seed là verbatim decision, ảnh hưởng
  mọi-Material default không token hoá.
:::

## Senior project connection

| File senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/main.dart` | verbatim: order, `[auth]` prefix, 3-ternary DI, theme deepPurple-light, locale-stream |
| `lib/core/app_dependency_scope.dart` | verbatim 8 `Provider.value` |
| `lib/navigation/app_navigation_controller.dart` | verbatim: `openGame`/`goBack`/`_push`/`_pop` + `StateError` unattached |
| `lib/previews/` (12 file) | nguồn appendix: learner port 6/12 |
| `scripts/kit/` + `.release-kit/` | chủ đề của `docs/release-kit-walkthrough.md` — KHÔNG copy |
| 7 test-file senior (widget_test 11, apple_auth 2, surface_glow 5, dialog_shell_header 3, pill_button_glow 3, leaderboard_async 4 + canonical vm-test re-ports) | +13 net |
| `lib/l10n/app_{en,vi}.arb` | đóng: 119-key-parity |

:::note[Capstone tự khép — không cần mở repo senior]
Bài này (và cả khoá) tự đủ: mọi đoạn verbatim senior cần port đều
được trích trong bài. Khoá học *tham chiếu* senior để đảm bảo độ trung
thực, nhưng learner không cần truy cập repo đó — nếu một bước bảo bạn
"đối chiếu senior", dùng đúng đoạn trích trong bài.

Previews ở phần appendix là **tuỳ chọn**: port 6/12 file; 6 catalog
còn lại là declared gap đã ghi — bỏ qua không làm hỏng course.
:::

## Build it step by step

### Bước 1 — `main()`: bootstrap là chuỗi-`await`-có thứ tự

```dart
// learner-app/lib/main.dart (trích — verbatim senior)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();          // 1 binding
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);                // 2 orientation
  final supabaseEnvironment = SupabaseEnvironment.fromEnvironment();
  debugPrint('[auth] config supabase=${env.isSupabaseConfigured} '
             'google=${env.isGoogleConfigured}');     // 3 env+log
  final supabaseClient =
      await SupabaseClientService.initialize(supabaseEnvironment);
  debugPrint('[auth] repository='
      '${supabaseClient == null ? 'disabled' : 'supabase'}');
  final userProfileRepository = await UserProfileRepositoryImpl.create();
  final onboardingRepository = await OnboardingRepositoryImpl.create();
  final userSettingsRepository = await UserSettingsRepositoryImpl.create();
  await userSettingsRepository.loadUserSettings();    // 4 seed TRƯỚC runApp
  // … authRepository / leaderboardRepository /
  //   profileSyncRepository — 3-ternary (Bước 2)
  runApp(AppDependencyScope(/* 8 provider */ child: AIMillionaireApp()));
}
```

:::caution[Vì sao `loadUserSettings()` phải trước `runApp`]
`userSettingsStream` là `BehaviorSubject` seeded — `MaterialApp
.locale` đọc `stream.value` ở frame đầu. Nếu load-sau-runApp,
frame đầu render ngôn ngữ mặc định rồi nhảy — "locale-flicker".
Senior-`await`-trước để seed đã có khi cây widget dựng — đây là
lý do bootstrap order là-*contract*, không phải phong cách.
:::

### Bước 2 — Conditional DI: 3-ternary một chỗ

```dart
// learner-app/lib/main.dart (trích)
final authRepository = supabaseClient == null
    ? DisabledAuthRepository(environment: supabaseEnvironment)
    : AuthRepositoryImpl(client: supabaseClient, /* google/apple svc */);
final leaderboardRepository = supabaseClient == null
    ? const DisabledLeaderboardRepository()
    : SupabaseLeaderboardRepository(client: supabaseClient);
final profileSyncRepository = supabaseClient == null
    ? UserProfileSyncRepositoryDisabled()
    : UserProfileSyncRepositoryImpl(
        client: supabaseClient,
        userProfileRepository: userProfileRepository);
```

Một câu hỏi — "**Supabase có cấu hình không**" — quyết ba impl.
`SupabaseClient?` null là sentinel: không cần class-`MaybeClient`,
không cần flag riêng. Và đây là điểm — lặp lại từ-M23: UI/VM
**không biết**-impl nào — `context.read<AuthRepository>()` nhận
gì cũng được; test/preview đổi impl không đụng call site.

### Bước 3 — `AppDependencyScope`: 8-contract `Provider.value`

```dart
// learner-app/lib/core/app_dependency_scope.dart (trích)
return MultiProvider(
  providers: [
    Provider<AppNavigationController>.value(value: navigationController),
    Provider<UserProfileRepository>.value(value: userProfileRepository),
    Provider<AuthRepository>.value(value: authRepository),
    Provider<LeaderboardRepository>.value(value: leaderboardRepository),
    Provider<UserProfileSyncRepository>.value(value: profileSyncRepository),
    Provider<OnboardingRepository>.value(value: onboardingRepository),
    Provider<UserSettingsRepository>.value(value: userSettingsRepository),
    Provider<LocalNotificationService>.value(value: notificationService),
  ],
  child: child,
);
```

`.value` (không-`create:`) vì impl đã tồn tại ở-`main` và sống
cùng app — Provider chỉ-*đặt nó vào cây*, không sở hữu vòng đời.
Tám contract = tám-"chân cắm" mọi-VM/scope của course read qua-
`context.read<T>()`.

### Bước 4 — `MaterialApp`: locale-derived + theme-senior

```dart
// learner-app/lib/main.dart (trích — AIMillionaireApp.build)
final settingsStream =
    context.read<UserSettingsRepository>().userSettingsStream;
return StreamBuilder(
  stream: settingsStream,
  initialData: settingsStream.value,
  builder: (context, snapshot) {
    final selectedLocale =
        _selectedLocaleFor(snapshot.data?.languageCode);
    return MaterialApp(
      locale: selectedLocale,                    // ← null → hệ-thống
      onGenerateTitle: (c) =>
          AppLocalizations.of(c).appTitle,       // "AI Millionaire"
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorKey: navigationController.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple),       // ← LIGHT senior
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  },
);
```

:::note[Theme: từ dark seed sang deepPurple-light]
Learner từng dark seed riêng (M14-era). Senior dùng
`ColorScheme.fromSeed(seedColor: Colors.deepPurple)` — light.
Vì sao an toàn đổi mà không vỡ visual? — mọi pixel senior grade
đọc-`AppTokens`/`OnboardingTokens`, không đọc-`Theme.of`-cho
màu chủ đạo; theme seed chỉ ảnh hưởng-Material default sót
(thumb/switch/ripple-tone) — mà widget test verify. Đây là
bằng chứng thực tế của-: token hoá đúng → theme đổi không
lan sóng.
:::

### Bước 5 — `AppNavigationController`: contract tối thiểu

```dart
// learner-app/lib/navigation/app_navigation_controller.dart (trích)
class AppNavigationController {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<void> openGame() async =>
      _push(MaterialPageRoute<void>(builder: (_) => const GameScreen()));
  void goBack() => _pop();

  NavigatorState get _navigator {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      throw StateError('…navigatorKey is not attached to a Navigator.');
    }
    return navigator;
  }
}
```

Chỉ-`openGame`+`goBack`+`_push`/`_pop` — **tối thiểu cần thiết**:
controller không biết gì về dialog (dialog đã là state-Bài-05),
không generic-`goBack<T>`-superset. Nếu ai gọi khi navigator
chưa attach → `StateError`-rõ ràng thay vì null im lặng — fail-
loud-early.

### Bước 6 — Previews appendix: 6/12 file, gap được ghi

```bash
ls lib/previews/
# common_widget_previews.dart   menu_widget_previews.dart
# onboarding_widget_previews.dart
# preview_fixtures.dart         preview_sample_data.dart
# preview_app_dependencies.dart
# — thiếu 6 catalog senior: game_controls/game_dialog/
#   leaderboard/menu_auth/menu_settings/provider_shell (gap
#   declared theo brief — appendix subset, không-defect)
```

`preview_app_dependencies.dart` cung cấp **fake repo thật**:
`PreviewOnboardingRepository implements OnboardingRepository`
với `BehaviorSubject<bool>.seeded(completed)` — preview có
thể toggle-"đã hoàn thành"/"chưa" mà không đĩa. `preview_sample_
data.dart` cung cấp `previewProfile`, `previewNoop`, fixtures
cho settings/game/answer/feature/poll/ladder.

```bash
flutter widget-preview start   # mở previewer — dev tool
```

### Bước 7 — Release-kit: giải thích, không chạy

`docs/release-kit-walkthrough.md` (course-doc, không app file)
giải thích hai mảng senior:

```text
scripts/kit/         — vendored flutter-release-kit (bash,
                       project-agnostic): debug/release build,
                       hot-reload, beta pipeline
.release-kit/        — project.env COMMITTED: dart-define names
                       (SUPABASE_URL, GOOGLE_WEB_CLIENT_ID…)
config/runtime.env   — GITIGNORED: giá-trị thật (secrets)
```

:::caution[Vì sao không copy, không chạy]
(1) Senior repo là tham chiếu read only — brief yêu cầu-*hiểu*,
không-*thực thi*; (2) course không có keystore/credential —
và không nên có; (3) learner app dùng-`--dart-define`-trực tiếp
(đúng pattern senior cho course scale). Doc ghi rõ: học viên
muốn dùng thật thì-`install.sh`-vào repo-*riêng*. Và luật bất
biến: **không bao giờ commit secret**.
:::

### Bước 8 — đóng + test cuối + structure-audit

```text
FR-31 (l10n parity) — ĐÓNG:
  +11 key (Bài 01) + 3 key-rename-settled
    leaderboardSubtitle→menuLeaderboardEntrySubtitle   (Bài 04)
    menuExpProgress→menuExpToNextLevel                 (Bài 04)
    notificationTimeTitle→notificationTimeSetting      (đã-tồn-tại)
  = 119 key mỗi-bên; chỉ-khác: appTitle + share-message
    = "AI Millionaire" vs "Flutter Accelerator AI"
    (product-rename — documented intentional)

7 test-file senior + async-harness → net +13 → 396/396.

Structure audit:
  lib/  — zero learner-only file; mọi-file-có-tương-ứng-senior
          trừ previews/-subset (declared gap)
  test/ — senior-coverage + learner-added
          (sealed_state, localization_switch, menu_provider_scope,
           repositories/*, helpers/)
  generated lib/build/ — removed
```

## Hiểu code — 6 chi tiết dễ trượt

**1. `[auth]` prefix log ở main** — debugPrint hai lần: config
rồi impl chọn. Log để-*đọc khi triển khai*: biết ngay app này
chạy disabled hay supabase mà không mở code. Verbatim cả format.

**2. `Provider.value` vs `ChangeNotifierProvider(create:)`** —
scope dùng-`.value` vì impl sống cùng app; dialog scope dùng-
`create:` vì-VM-sinh chết cùng dialog. Cùng-Provider-hai-vai
trò vòng đời — nhầm-`.value`-cho-dialog-VM = VM-không bao giờ
dispose (leak), nhầm-`create:`-cho-app-repo = repo bị tạo mới
mỗi lần subtree dựng.

**3. `navigatorKey.currentState` có thể null** — `_navigator`
throw-`StateError`-rõ thay vì-`!`-crash mập mờ. Lỗi-"chưa attach"
= lỗi setup (quên gắn key vào-`MaterialApp`) — đáng bị đỏ ngay.

**4. `initialData: stream.value`** — BehaviorSubject đã seed
cho frame đầu giá trị thật; StreamBuilder vẫn theo dõi đổi
sau (đổi ngôn ngữ trong settings → `MaterialApp.locale`-đổi →
toàn app relocalize). Đây chính là — lặp lại ở nơi quan
trọng nhất.

**5. `onGenerateTitle` không dùng-`title:`** — title cần context
(l10n); `onGenerateTitle(context)` được gọi với context hợp lệ.
`appTitle`-của learner là-"AI Millionaire" — *intentional*-
deviation (product-name), không phải chưa port.

**6. `flutter test` 396 nhưng caveat-NOT_PERFORMED-vẫn đứng** —
kiểm chứng được ghi-*đúng phạm vi*: analyze-clean + widget/unit
pass + build-web-pass **≠** "đã chạy trên device" hay "đã gọi-
Supabase-live". Ghi-verbatim-NOT_PERFORMED-là phần của bảo
đảm chất lượng: báo cáo sai phạm vi là divergence tệ hơn mọi
deviation-code.

## Chạy và quan sát

```bash
cd learner-app
flutter analyze && flutter test && flutter build web
# clean · 396/396 (+13) · PASS
diff ../flutter-accelerator-ai/lib/main.dart lib/main.dart
diff ../flutter-accelerator-ai/lib/core/app_dependency_scope.dart lib/core/app_dependency_scope.dart
diff ../flutter-accelerator-ai/lib/navigation/app_navigation_controller.dart lib/navigation/app_navigation_controller.dart
# → chỉ-khác-comment-VI/rename-package — logic verbatim
find lib -type f -name "*.dart" | wc -l          # so-cấu-trúc
comm -23 <(cd ../flutter-accelerator-ai && find lib -type f | sort) \
         <(find lib -type f | sort)              # senior-có-learner-không
# → chỉ-còn-6-preview-catalog + (0 file khác)
comm -13 <(...) <(...)                           # learner-có-senior-không
# → trống = zero learner-only file
```

## Thử nghiệm

| Thử | Dự đoán | Thực tế |
|---|---|---|
| Bỏ `await userSettingsRepository.loadUserSettings()` | Frame đầu ra-sao? | `stream.value`=default → `locale=null`→fallback rồi nhảy sau load → locale-flicker 1-frame |
| Đổi `Provider.value` → `create:(c)=>userProfileRepository` | App chạy? | Repo bị tạo thừa mỗi subtree build / cũ mất giá trị seeded — `.value` cho impl có sẵn là đúng vai |
| `navigatorKey` không gắn vào-MaterialApp | `openGame()` ra-sao? | `StateError` — fail-loud đúng thiết kế; `!`-crash sẽ mập mờ hơn |
| Đổi seed thành `Colors.green` mà không sửa token | Visual vỡ? | Không vỡ đa phần — pixel đọc-`AppTokens`; chỉ-Material default lệch. Đó là điểm của token hoá |

## Lỗi hay gặp

| Lỗi | Vì sao | Sửa |
|---|---|---|
| `@Preview` không nhận | import-sai (`package:widget_previews`-ngoài) | `import 'package:flutter/widget_previews.dart'` — của SDK |
| Preview trắng/không chữ | thiếu-`wrapper` | bọc `previewGameApp`/`previewLayerApp` — preview không kế thừa-MaterialApp-app |
| `StateError …navigatorKey` | key chưa gắn-`MaterialApp.navigatorKey` | verbatim dòng-`navigatorKey:`-trong-build |
| Theme light làm text khó đọc | code đọc-`Theme.of`-cho màu chủ đạo thay-token | mọi visual senior đọc-`AppTokens`; chỗ đọc theme là divergence cần sửa |
| Claim-"app chạy được trên máy thật" sau-396-pass | phạm vi kiểm chứng sai | NOT_PERFORMED-ghi-verbatim; chỉ claim analyze/test/build-web |

## Tự làm

**PREDICT** — Một dev thêm `Provider<LeaderboardDialogViewModel>
.value(value: LeaderboardDialogViewModel(...))` vào
`AppDependencyScope` "cho tiện". Sai ở đâu?

:::note[Gợi ý]
Nghĩ về vòng đời: scope app sống bao lâu vs dialog-VM-nên sống
bao lâu ?
:::

<details>
<summary>Đáp án</summary>

Sai vai vòng đời: `LeaderboardDialogViewModel` phải-*sinh chết
cùng dialog* (tạo trong-`MenuLeaderboardDialogScope` qua
`create:`) — đặt nó ở app scope = một-VM-tồn tại suốt app, bắn
notify cho dialog đã unmount, giữ state không cần thiết, và-
`_requestId`/loading state lẫn giữa hai lần mở. App scope chỉ
chứa impl-*sống cùng app* (repo, service, nav-controller); VM-
thuộc scope ngắn tương ứng.
</details>

**DEBUG** — CI-báo `flutter build web` PASS nhưng review flag:
"`@Preview` import-error khi-`flutter analyze`". Code đã import-
`package:flutter/widget_previews.dart`. Nguyên nhân thường gặp?

:::note[Gợi ý]
SDK-version — `widget_previews.dart` xuất hiện ở-Flutter mới
nào?
:::

<details>
<summary>Đáp án</summary>

`package:flutter/widget_previews.dart` chỉ tồn tại ở-Flutter-
SDK-đủ mới (3.41+ — senior-ghi-verified-on-disk). CI-pin-SDK-cũ
→ package không tồn tại → import-error. Sửa bằng nâng-SDK-CI
(hoặc gate file nếu course muốn support cũ — course chọn nâng,
vì senior yêu cầu nền tảng mới).
</details>

**PRODUCE** — Viết một-`@Preview`-cho-`GradientCtaButton`-
với label tuỳ chọn (không dùng default-l10n), group-'Menu'.

:::note[Gợi ý]
Nhớ-`wrapper`-cung cấp-MaterialApp+l10n; `size`-cho-CTA-full-
width.
:::

<details>
<summary>Đáp án</summary>

```dart
// lib/previews/menu_widget_previews.dart (thêm)
@Preview(
  name: 'Gradient CTA — custom label',
  group: 'Menu',
  size: Size(390, 96),
  wrapper: previewGameApp,
)
Widget gradientCtaCustomPreview() {
  return const GradientCtaButton(
    label: 'CHƠI NGAY',
    onTap: previewNoop,
  );
}
```

Truyền-`label`-rõ để không phụ thuộc-`startGameButton`-mặc định;
`previewNoop`-là fixture-`VoidCallback`-rỗng đã có.
</details>

## Kiểm tra hiểu biết

**H: Vì sao-`main.dart`-là file cuối được verbatim, không phải
đầu tiên?** — Vì nó tham chiếu-*mọi*impl: repo-class/service-
class/nav-key/theme. Port nó sớm = compile đỏ hàng loat trước
khi các impl tồn tại; sweep đi từ lá lên gốc (leaf-widget →
composition → scope → app-root).

**H: `Provider.value`-và-`create:`-khác nhau thế nào về vòng
đời?** — `.value`-đặt instance có sẵn vào cây-*không dispose*
(sống cùng app); `create:`-cho-Provider sở hữu instance-*và
dispose-khi-subtree-unmount* (dialog/overlay-scoped-VM).

**H: -"đóng"-nghĩa là gì cụ thể?** — ARB-parity: mọi key-
senior tồn tại ở learner (+11), mọi key learner only đã xoá hoặc
rename-theo-senior (−5: 2-dead ở-Bài-01 + 3-rename); value-diff-
duy nhất còn lại là product name intentional (`AI Millionaire`
appTitle + share-messages) — documented, không phải thiếu.

**H: `NOT_PERFORMED`-có nghĩa-"chưa làm"-hay-"đã fail"?** — Chưa
làm-*có chủ đích và được ghi*: device-real/live-Supabase nằm
ngoài phạm vi course (không hardware/shared-backend). Claim
đúng là-"analyze-clean+396-test+web-build-pass"; claim thêm
là divergence báo cáo.

**H: `AppNavigationController`-vì sao không biết dialog?** — Vì-
dialog đã là-*state trong màn* (Bài-05): back mở dialog do-
`PopScope`+VM-lo, không route pop. Controller chỉ lo route level
(openGame, goBack) — tách bạch hai tầng điều hướng.

## Ta cố ý chưa thêm

- **6-preview catalog còn thiếu** — `game_controls`/`game_dialog`/
  `leaderboard`/`menu_auth`/`menu_settings`/`provider_shell`
  `*_widget_previews.dart`: declared-gap-theo-brief (appendix-
 subset); port tiếp khi cần bằng cùng mẫu-.
- **Release kit không vendor** — chỉ walkthrough; học viên tự
  cài vào repo riêng nếu muốn.
- **`GoogleFonts`-runtime-fetch** — parity cố ý kế thừa-M28:
  font fetch lúc chạy, không bundle asset font.
- **Pulse/sheen/ripple không honor-`disableAnimations`** — bản
  chất verbatim senior (senior không gate); documented-parity.
- **`REAL_DEVICE_*`/`LIVE_*`** — `NOT_PERFORMED`-cố ý; không
  claim đã chạy device/live.

## Checkpoint hoàn thành

- [x] `main.dart` verbatim: bootstrap-order + `[auth]`-log +
      3-ternary-DI + theme-`deepPurple`-light + locale-stream +
      `debugShowCheckedModeBanner:false`.
- [x] `app_dependency_scope.dart` verbatim: 8-`Provider.value`
      contract-keyed.
- [x] `app_navigation_controller.dart` verbatim: `openGame`/
      `goBack` + `StateError`-unattached.
- [x] `lib/previews/` appendix: 3-support + 3-catalog;
      6-catalog gap được ghi declared.
- [x] `docs/release-kit-walkthrough.md`: `scripts/kit` +
      `.release-kit` giải thích — KHÔNG-chạy, không vendor.
- [x] **đóng**: 119-key-parity; chỉ khác product name-
      intentional.
- [x] Structure-audit: **zero-learner-only-file** trong `lib/`;
      `test/` = senior-coverage + learner-added.
- [x] Caveats-ghi-verbatim: `REAL_DEVICE_PLATFORM_CHECK /
      REAL_DEVICE_VISUAL_CHECK / LIVE_SUPABASE_CONNECTIVITY /
      LIVE_AUTH_FLOW / LIVE_PROFILE_SYNC = NOT_PERFORMED`.
- [x] `flutter analyze` clean · `flutter test` **396/396**
      (+13) · `flutter build web` PASS.

## Sau-M29 — đọc kỳ cuối

```text
lib/        = subset-senior (thiếu-đúng-6-preview-catalog)
test/       = senior-coverage + learner-added-coverage
tokens      = AppTokens + OnboardingTokens (MenuTokens REMOVED)
dialogs     = 100% in-tree state-driven (zero showDialog)
features-đóng = notifications + iconAsset + onboarding
              + residual leaderboard/menu/settings
deviations  = chỉ-documented (dart2js, seam, rename, subset,
              convention, generated)
chưa-kiểm   = REAL_DEVICE_*/LIVE_* = NOT_PERFORMED (ghi-rõ)
```

-kết luận: sweep không phải-"làm cho giống" — nó là-"đọc
đối chiếu port kiểm chứng ghi chú". Cái còn lại không giống là
những chỗ-*được chọn khác và ghi rõ tại sao* — và đó là định
nghĩa của một parity sweep hoàn chỉnh.
