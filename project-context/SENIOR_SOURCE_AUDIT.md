# Senior Source Audit — flutter-accelerator-ai

Evidence-based audit of the reference application. Audited at HEAD
`c8eb860ed9f4dbcda176c8282a9feb4d2d70d1d3` on branch `main` (working tree
clean, ~204 commits). All statements reference repository evidence.

## 1. Product Identity

| Fact | Evidence |
|------|----------|
| Display name | "Flutter Accelerator AI" (`android/app/src/main/AndroidManifest.xml` `android:label`, `ios/Runner/Info.plist`) |
| Dart package | `ai_millionaire` (`pubspec.yaml` line 1) |
| Application ID | `app.ai_millionaire` (`android/app/build.gradle.kts` `applicationId`/`namespace`) |
| iOS bundle ID | `app.aiMillionaire` (`.release-kit/project.env` `IOS_BUNDLE_ID`) |
| Version | `1.0.0+1` (`pubspec.yaml`) |
| Dart SDK | `^3.12.1` (`pubspec.yaml` `environment`) |
| Flutter SDK | `3.44.1` stable per `docs/project-overview-pdr.md`; `.metadata` pins revision `924134a4...` stable |
| Languages | English + Vietnamese (`lib/l10n/app_en.arb`, `app_vi.arb`, generated `app_localizations*.dart`) |
| Orientation | Portrait locked in `main()` via `SystemChrome.setPreferredOrientations` and in `AndroidManifest.xml` `screenOrientation="portrait"` |

**What it is:** a "Who Wants to Be a Millionaire"-style quiz game. A menu hub
leads into a 15-question timed session with a money ladder, safe-haven
levels, three lifelines (50:50, Ask the Audience, Ask AI), walk-away and
exit controls, result dialogs, and result sharing. Local profile stats and
XP/level progression persist on-device; Supabase (when configured) adds
Google/Apple/email auth, remote profile sync, and a top-10 leaderboard.

## 2. Startup Sequence (`lib/main.dart`)

1. `WidgetsFlutterBinding.ensureInitialized()` — binds Flutter engine before
   plugin/async calls.
2. `SystemChrome.setPreferredOrientations([portraitUp])`.
3. `SupabaseEnvironment.fromEnvironment()` — reads compile-time
   `--dart-define` values: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`,
   `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID`
   (`lib/core/supabase_environment.dart`).
4. `SupabaseClientService.initialize()` — calls `Supabase.initialize` only
   when URL+key are non-empty; returns `null` otherwise
   (`lib/services/supabase_client_service.dart`).
5. Explicit repository construction: `UserProfileRepositoryImpl.create()`,
   `OnboardingRepositoryImpl.create()`, `UserSettingsRepositoryImpl.create()`
   (all `SharedPreferences`-backed), then `loadUserSettings()` so locale is
   known before first frame.
6. Conditional construction: `DisabledAuthRepository` /
   `DisabledLeaderboardRepository` / `UserProfileSyncRepositoryDisabled`
   when Supabase is absent, else real Supabase implementations. This is the
   **graceful-degradation seam** — the app is fully playable offline as a
   guest.
7. `AppDependencyScope` wraps `AIMillionaireApp` — a `MultiProvider` of
   `Provider.value` entries for all long-lived dependencies
   (`lib/core/app_dependency_scope.dart`).
8. `AIMillionaireApp.build` wraps `MaterialApp` in a `StreamBuilder` over
   `UserSettingsRepository.userSettingsStream` to set `locale`; home is
   `MenuScreen`; `navigatorKey` comes from `AppNavigationController`.

## 3. Project Structure

```
lib/
  main.dart                 bootstrap + MaterialApp
  core/                     AppDependencyScope (DI), design tokens, asset paths,
                            DRE primitives, SupabaseEnvironment, gradients
  navigation/               AppNavigationController (GlobalKey<NavigatorState>)
  screens/                  menu_screen.dart, game_screen.dart (2 routes only)
  widgets/                  common/, onboarding/, menu/ (profile, settings,
                            leaderboard, auth), game/ (answers, dialogs, layout,
                            lifelines, money, questions, timer), leaderboard/
  view_models/              game/ (dre/, reducer/, bridge/, support/), menu/,
                            onboarding/, settings/, leaderboard/
  repositories/             auth/, leaderboard/, onboarding/, profile/, settings/
  services/                 supabase_client, google_auth, apple_auth,
                            local_notification
  data/                     auth/, game/, leaderboard/, onboarding/, profile/,
                            settings/ — immutable value/DSO models + seed data
  l10n/                     app_en.arb, app_vi.arb, generated localizations
  previews/                 @Preview widget previews + preview fakes
test/                       unit + widget tests, helpers/ fakes
supabase/                   config.toml + student-setup SQL (schema + RLS)
scripts/kit/                vendored flutter-release-kit (build/run scripts)
.release-kit/project.env    committed, value-free kit contract
config/runtime.env.example  dart-define keys documentation
```

## 4. Dependencies (`pubspec.yaml`) — actual usage

| Package | Version | Used for | Where | Beginner urgency |
|---------|---------|----------|-------|------------------|
| `provider` | ^6.1.5+1 | DI (`MultiProvider`, `Provider.value`) + `ChangeNotifierProvider` for scoped VMs + `context.read/watch` | `core/app_dependency_scope.dart`, all screens/dialog scopes | High — core mechanism |
| `rxdart` | ^0.28.0 | `BehaviorSubject`/`ValueStream` repositories with replayable current value | all repositories, VMs read `.value` | Medium — `.value`/`.stream` pattern |
| `shared_preferences` | ^2.5.5 | JSON persistence for profile, settings, onboarding flag | `repositories/profile`, `settings`, `onboarding` | High |
| `supabase_flutter` | 2.14.2 (pinned) | Auth (Google/Apple/email), `public.users` upsert, `leaderboard` view reads | `services/supabase_client_service.dart`, `repositories/auth`, `leaderboard`, `profile/user_profile_sync` | Later — feature-level |
| `google_sign_in` | ^7.2.0 | Native Google ID/access tokens → Supabase `signInWithIdToken` | `services/google_auth_service.dart` (v7 `GoogleSignIn.instance.authenticate` API) | Later |
| `sign_in_with_apple` | ^8.1.0 | Apple credential with SHA-256 nonce | `services/apple_auth_service.dart` | Later |
| `crypto` | ^3.0.7 | `sha256` of Apple nonce | `services/apple_auth_service.dart` | Later |
| `flutter_local_notifications` | ^22.0.1 | Daily quiz reminder scheduling, permissions | `services/local_notification_service.dart`, manifest receivers | Later |
| `timezone`, `flutter_timezone` | ^0.11.0, ^5.1.0 | `zonedSchedule` calendar times; local tz lookup | same | Later |
| `share_plus` | ^13.1.0 | Share result text; clipboard fallback | `screens/game_screen.dart` `_handleUiEvent` | Medium |
| `package_info_plus` | ^10.1.0 | App version string in settings | `view_models/settings/settings_app_version_loader.dart` | Low |
| `flutter_svg` | ^2.3.0 | `SvgPicture` for SVG icons/decorations | ~10+ widget files | Medium |
| `google_fonts` | ^8.1.0 | Text styles in design tokens | `core/app_design_tokens.dart` | Low |
| `flutter_localizations` + `intl: any` | sdk | `AppLocalizations` delegates; `generate: true` + `l10n.yaml` | `main.dart`, most widgets | Medium |
| `cupertino_icons` | ^1.0.8 | declared; no usage found in `lib/` | — | n/a (probably unused) |
| `flutter_lints` | ^6.0.0 | `analysis_options.yaml` default set | analyzer | Low |
| `flutter_launcher_icons` | ^0.14.4 | launcher icon generation config | pubspec | Low |

No `build_runner`, no codegen packages, no DI framework beyond provider, no
routing package, no HTTP client beyond Supabase SDK.

## 5. Architecture — what is actually implemented

Lean **MVVM** with repository contracts. Not a layered Clean Architecture;
no `domain/usecase` layer; no DI container; navigation is manual.

- **Presentation**: `screens/` are thin shells that install a
  `ChangeNotifierProvider` and host a private `_EventBridge`
  `StatefulWidget` subscribing to the VM's `Stream<UiEvent>`.
  `widgets/` are presentation-only and receive data + callbacks.
- **ViewModels**: `ChangeNotifier` subclasses grouped by domain
  (`menu`, `game`, `onboarding`, `settings`, `leaderboard` dialogs).
  Dialogs own scoped VMs created inside `*DialogScope` widgets.
- **State machines**: `MenuDialogState`, `GameDialogState`,
  `LeaderboardPopupState`, `AuthSessionData`, `ProfileSyncStateData`,
  `OnboardingStepState`, `SettingItemData` are `sealed class` hierarchies
  consumed with Dart 3 `switch` expressions/patterns.
- **DRE core** (`lib/core/dre/`): project-local Redux/MVI-like triplet
  `DreAction`/`DreEffect`/`DreAsyncOp` + `DreReducer` + `DreResult` +
  `DreChangeNotifier` (dispatch → pure reduce → notifyListeners + effects
  stream + async op). Used **only** by the game feature; other VMs are plain
  `ChangeNotifier`. Mixed on purpose (docs call it "optional reducer
  pattern").
- **Repositories**: `abstract interface class` contracts exposing
  `ValueStream<T>` (rxdart `BehaviorSubject.seeded`) + async commands.
  Local impls persist JSON in `SharedPreferences`. Supabase impls talk to
  `public.users` and `public.leaderboard`.
- **Services**: thin platform wrappers (`SupabaseClientService`,
  `GoogleAuthService`, `AppleAuthService`, `LocalNotificationService`).
- **DI**: constructor injection; objects created in `main()` and exposed
  through `AppDependencyScope`. Feature VMs created via
  `ChangeNotifierProvider(create:)`. Testability via fakes implementing the
  same contracts (`test/helpers/`).
- **Error handling**: `AuthActionResult` success/failure value objects;
  repositories throw, VMs catch and emit snackbar UI events; silent-catch
  fallbacks for non-critical paths (e.g., share → clipboard).
- **No caching layer** beyond SharedPreferences; no connectivity handling;
  no offline queue — local-first by construction.

## 6. State management mechanisms (verified)

| Mechanism | Where | Role |
|-----------|-------|------|
| `ChangeNotifier` + `context.watch` | all VMs | primary reactive state |
| `DreChangeNotifier` (custom) | `GameScreenViewModel` only | unidirectional action→state+effects+asyncOp |
| `StreamController.broadcast` UI events | menu/game/dialog VMs | one-shot events (navigate, snackbar, dismiss) |
| rxdart `BehaviorSubject`/`ValueStream` | repositories | replayable persisted state streams |
| `StreamBuilder`/`FutureBuilder` | `main.dart` locale, `OnboardingOverlayScope` gating | async boundaries in UI |
| `setState` | `MenuScreenView` (dismiss lock), `wheel_picker`, `notification_time_picker_dialog`, `menu_leaderboard_dialog` | local ephemeral widget state — sparing |
| `AnimationController`/`TickerProviderStateMixin` | `game_countdown_timer`, `game_feature_button`, `game_money_amount_motion`, `menu_auth_dialog`, `level_progress_card`, `game_answer_option_list` | explicit animations |
| `AnimatedSwitcher`, `AnimatedBuilder`, `FadeTransition` | dialog layers | implicit-ish transitions |

## 7. Navigation (verified)

- No router package. `MaterialApp(home: MenuScreen, navigatorKey: ...)`.
- `AppNavigationController` (`lib/navigation/app_navigation_controller.dart`)
  holds `GlobalKey<NavigatorState>`; `openGame()` pushes
  `MaterialPageRoute<GameScreen>`; `goBack()` pops if `canPop`.
- Exactly two pushed routes: Menu (home) and Game. **Everything else is an
  in-`Stack` overlay/dialog**, not a route: onboarding overlay,
  leaderboard/settings/auth/sign-out dialogs, money ladder, explanation,
  audience poll, AI assistant, confirm exit/walk-away, result dialogs.
- Back handling: `PopScope` on both screens (`canPop: false` in game +
  `onPopInvokedWithResult` routes back presses into confirm-exit or dialog
  dismissal; menu `PopScope` blocks pop while a dialog is visible).
- No deep links, no route arguments, no nested navigators, no guards.

## 8. Data layer (verified flows)

- **Local persistence**: `SharedPreferences`; `UserProfileRepositoryImpl`
  and `UserSettingsRepositoryImpl` store `jsonEncode(toMap())` under keys
  `user_profile`/`user_settings`; `OnboardingRepositoryImpl` stores a bool
  `onboarding_completed`. `fromMap` factories validate/defensive-parse with
  defaults; `UserProfileData.fromMap` even resets a legacy demo profile.
- **Remote**: Supabase `public.users` table (RLS owner-only select/insert/
  update; see `supabase/student-setup/01-setup-database.sql`) and a
  `public.leaderboard` `security_barrier` view exposing ranked rows while
  masking other users' `auth_uuid`. pg_cron heartbeat keeps the free-tier
  project alive.
- **Profile sync**: `UserProfileSyncRepositoryImpl.syncUserProfile` —
  fetch remote row by `auth_uuid`, `mergeUserProfileForSync` (max-merge
  progression, session name/photo precedence, demo-profile purge), save
  merged profile locally, then `upsert(..., onConflict: 'auth_uuid')`.
- **Auth**: `AuthRepositoryImpl` wraps `SupabaseClient.auth`; Google/Apple
  services produce ID tokens exchanged via `signInWithIdToken`; email
  sign-in/up via `signInWithPassword`/`signUp`. Emits into a seeded
  `BehaviorSubject<AuthSessionData>` also fed by `onAuthStateChange`.
- **Game content**: hardcoded `const` question bank —
  `game_sample_easy/medium/hard_questions_data.dart` (5+5+5 = 15 items,
  English, Vietnam-themed) matching the 15-level
  `gameMoneyLadderLevels` table (amounts 1.000→1.000.000 VNĐ, safe havens at
  levels 5, 10, 15).
- **Serialization**: hand-written `toMap`/`fromMap`/`toUpsertMap` — no
  codegen, no json_serializable.
- **Leaderboard data**: `SupabaseLeaderboardRepository.loadLeaderboard`
  selects `rank,name,avatar_url,level,total_money_won` ordered by
  `total_money_won desc`, limit 10; separate `eq('auth_uuid', uid)`
  `.maybeSingle()` for current-user row; `DisabledLeaderboardRepository`
  returns static sample rows (`leaderboardEntries`,
  `currentLeaderboardEntry`).

## 9. Localization

`l10n.yaml`: `arb-dir: lib/l10n`, template `app_en.arb`,
`output-class: AppLocalizations`, `nullable-getter: false`,
`use-escaping: true`. Generated `app_localizations{,_en,_vi}.dart` are
committed to `lib/l10n/`. ~80 keys. `MaterialApp.locale` driven by persisted
`languageCode`; widgets call `AppLocalizations.of(context)`. Quiz content
and repository messages intentionally stay unlocalized (English).

## 10. Platform configuration

- **Android**: Kotlin DSL Gradle. `namespace`/`applicationId`
  `app.ai_millionaire`; Java 17; core library desugaring; multiDex; custom
  gradle property namespace `aimillionaire.unsignedDebug|releaseSigning`
  gating signing; release signing reads `ANDROID_*` env vars. Manifest adds
  `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, and
  flutter_local_notifications receivers.
- **iOS**: `Runner.entitlements`, `AuthCredentials.xcconfig.example` for
  `GOOGLE_IOS_REVERSED_CLIENT_ID` (URL scheme in `Info.plist`); `AppDelegate`
  + `SceneDelegate` (modern iOS lifecycle).
- **Web**: present (`web/index.html`, manifest) — notification service
  guards with `kIsWeb`; likely a secondary target.
- **Tooling**: vendored `scripts/kit` (flutter-release-kit) is the only
  supported build/run surface; `.release-kit/project.env` declares runtime
  dart-define scopes and a Gradle-wrapper SHA-256 pin. No CI (`.github`
  absent), no flavors, no build_runner.

## 11. Tests

- `flutter_test` only; ~45 files, ~230+ test/testWidgets declarations.
- `test/helpers/`: hand-written fakes (`FakeAuthRepository`,
  `FakeLeaderboardRepository`, `FakeLocalNotificationService`,
  `FakeProfileSyncRepository`) + a VM test harness. No mockito/build_runner.
- Coverage: reducer unit tests (`game_reducer_test.dart`), VM tests (menu,
  auth dialog, sign-out, settings, onboarding, leaderboard incl.
  stale-request guards), sync merge/schema tests, repository tests via
  `SharedPreferences.setMockInitialValues`, widget tests (game flow,
  dialogs, timer, buttons, leaderboard, settings, onboarding, layout
  constraints), app-level smoke (`widget_test.dart`,
  `onboarding_app_test.dart`) wiring the real `AppDependencyScope`.
- Gaps: no `integration_test/`, no golden tests, no real Supabase tests
  (contract-level only), no coverage tooling config.

## 12. Cross-verification notes / drift

- `docs/codebase-summary.md` lists `menu_screen_top_nav.dart` and
  `menu/profile/avatar_with_level.dart` — **stale names**; actual files are
  `menu_screen_content.dart`-era layout helpers and
  `menu/profile/profile_avatar_image.dart`. Source wins; docs treated as
  secondary evidence only.
- `docs/` also references `Mobile Action Pro` — a sibling/derived product;
  ignore for this audit.
- `cupertino_icons` declared but no usage found in `lib/` (UNVERIFIED
  whether intentionally kept for future use).
