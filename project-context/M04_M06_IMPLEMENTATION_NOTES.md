# M04–M06 Implementation Notes

Internal engineering record for Step 04 (agent-facing, not lesson content).
Purpose: a future agent must be able to reconstruct *why* the learner app
evolved this way without conversation history. See also `DECISIONS.md`
D15–D17.

## End-of-M03 starting point

- `lib/main.dart`: `void main() { runApp(const AIMillionaireApp()); }` —
  sync bootstrap, `MaterialApp` home `MenuScreen`.
- `lib/screens/menu_screen.dart` (single file, ~480 lines):
  `MenuScreen` `StatefulWidget`; `_MenuScreenState` fields `_soundOn`,
  `_playTapCount`; `initState`/`dispose` log via `debugPrint`; all menu
  values hard-coded inside leaf widgets (`'Khách'`, `'CẤP 1'`,
  `'120 / 400 EXP'`, `'0 VNĐ'`, stats `'0'/'0'/'—'`).
- `lib/core/menu_tokens.dart`: `MenuTokens` static const design tokens.
- `test/`: empty (no tests).
- Zero third-party packages.

## End-of-M04 code state

- NEW `lib/data/profile/user_profile_data.dart` — `UserProfileData`:
  - `final` fields: `username`, `level`, `currentExp`, `expForNextLevel`,
    `totalMoneyWon`, `gamesJoined`, `gamesWon`, `avatarUrl` (`String?`).
  - `const` constructor; **defaults = the exact values M03's menu showed**
    (`'Khách'`, 1, 120, 400, 0, 0, 0, null) so UI looks identical after
    rewiring.
  - `copyWith` (nullable params + `??`), `gainExp(int)` (while-loop
    level-up, cap ×1.5), getters `expPercent` (int, clamped 1–99 for
    `Expanded flex`), `winRateDisplay` (`'—'` when `gamesJoined == 0`),
    `totalEarningsDisplay` (`formatThousands` + `' VNĐ'`),
    `static formatThousands` (dot-grouped), `operator ==` (`identical` +
    `is` + field compare), `hashCode` via `Object.hash`.
- `menu_screen.dart`: `_profile` field `= const UserProfileData()`;
  `_onPlayTap` also does `_profile = _profile.gainExp(10)` (tap = practice
  round demo until real game M08/M09); profile passed through
  `_ProfileHeader`/`_MenuBody`/`_LevelCard`/`_EarningsCard`/`_StatsRow`
  constructor params; `const` moved down accordingly.
- NEW `test/user_profile_data_test.dart` — 10 tests (defaults, copyWith,
  equality/hashCode + const canonicalization, gainExp level-up/under-cap,
  expPercent clamps, winRateDisplay, formatThousands, earnings display).
- Gate: `flutter analyze` clean; `flutter test` 10/10; `flutter build web`
  pass.

## End-of-M05 code state

- NEW `lib/data/profile/demo_profile_loader.dart` — `demoLoadedProfile`
  const (level 3, 250/600 EXP, 150000 money, 4/2 games — deliberately
  different from defaults so loading is *visible*) +
  `Future<UserProfileData> loadDemoProfile({bool fail, Duration delay})`:
  `await Future.delayed(delay)` (default 900ms), `throw StateError` when
  `fail`, returns `demoLoadedProfile`. `delay` param exists for tests.
- `main.dart`: `Future<void> main() async` +
  `WidgetsFlutterBinding.ensureInitialized()` — senior bootstrap shape;
  no await yet (explained in lesson as prepared seam).
- `menu_screen.dart`: `late Future<void> _profileLoadFuture` assigned in
  `initState` from `_loadProfile()`; `_loadProfile` = `await loadDemoProfile()`
  → `if (!mounted) return;` → `setState(_profile = loaded)`; errors
  propagate *through* the Future (no try/catch) → `snapshot.hasError`.
  `_retryLoadProfile` re-assigns a fresh Future inside `setState`.
  `build()` wraps the content Column in `FutureBuilder<void>`:
  `hasError` → `_MenuErrorState(onRetry)`; `connectionState == waiting` →
  `_MenuLoading`; else → existing Column.
- NEW widgets `_MenuLoading` (`CircularProgressIndicator` + label) and
  `_MenuErrorState` (icon + retry pill via `GestureDetector`+`Container`,
  matching course CTA style).
- NEW `test/demo_profile_loader_test.dart` — 3 tests: success value,
  `throwsStateError`, `Duration.zero` delay.
- Design note: `FutureBuilder<void>` renders the *load lifecycle* while
  `_profile` (State field) remains the single source of truth that
  `gainExp` can keep mutating — deliberate hybrid; mutating
  `snapshot.data` would fight the stream of truth.
- Gate: analyze clean; 13/13 tests; build web pass.

## End-of-M06 code state (current on-disk state)

- NEW `lib/data/menu_session_ticker.dart` —
  `Stream<int> menuSessionTicker({Duration step})` returns
  `Stream<int>.periodic(step, (tick) => tick + 1)` (lazy; emits 1,2,3…/s).
- `menu_screen.dart`: `final Stream<int> _sessionTicker = menuSessionTicker()`
  stable field; passed as `ticker:` through `_MenuBody` to new
  `_SessionTickerCard` containing `StreamBuilder<int>(stream:, initialData:0,
  builder:)` rendering `'${snapshot.data ?? 0}s'`. Card placed after
  `_StatsRow` inside `_MenuBody`'s Column.
- NEW `test/menu_session_ticker_test.dart` — 2 tests: `emitsInOrder([1,2,3])`
  on `take(3)` (real-time ~3s), `await stream.first` = 1.
- Gate: analyze clean; 15/15 tests; build web pass.

## Intentional simplifications (vs senior)

- `UserProfileData` has 8 fields (senior: more incl. `totalEarnings` String,
  `totalQuestionCount`); no `fromMap`/`toMap` until M10.
- `expForNextLevel` is a stored field; senior derives thresholds from
  `LevelConfig` (M22).
- `demo_profile_loader` is a teaching loader, NOT a repository — no
  contract, no stream, no prefs until M10/M14.
- `FutureBuilder<void>` + state-field profile instead of
  `FutureBuilder<UserProfileData>` driving data — keeps `gainExp` mutation
  coherent; documented in lesson M05-02.
- Session ticker is observational only; no StreamController in app yet.
  `listen`/`cancel`/`broadcast` taught as labeled learning example
  (M06-03) — real manual subscription arrives with VM in M11–M14.
- `async main` + `ensureInitialized` adopted as prepared bootstrap shape;
  no pre-runApp awaits exist yet (documented honestly in M05-03).

## Deferred concepts (firewall upheld)

No Navigator, no persistence, no Provider/ChangeNotifier, no rxdart/
BehaviorSubject, no sealed classes, no widget tests (`testWidgets` is M08),
no Supabase/networking. Zero new dependencies — `flutter_test` (SDK) only.

## Verification commands (all PASS at Step 04 end)

- `cd learner-app && flutter pub get`
- `flutter analyze` → No issues found
- `flutter test` → +15: All tests passed
- `flutter build web` → Built build\web
- `cd web && npm run build` → 30 pages (m01–m06 routes + roadmap + start)

## Assumptions for M07 (Navigator)

- `_profile` mutation happens through `setState` + `gainExp`; nothing
  depends on the menu staying mounted — but `_loadProfile`'s `mounted`
  guard becomes load-bearing once a second route exists.
- `_SessionTickerCard`'s `StreamBuilder` will cancel when the menu subtree
  unmounts under navigation — intended behavior; revisit if M07 wants the
  ticker to persist.
- `_profile` is not shared across routes; M07's game screen must not
  assume access to it (real profile handoff lands M09/M10+).
