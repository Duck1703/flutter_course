# Curriculum Traceability

Bidirectional map: every senior feature → where it is taught, simplified,
and aligned; every key concept → where introduced/practiced/aligned.
Nothing in `FEATURE_INVENTORY.md` (F1–F15) is silently dropped.

Coverage statuses: **CORE** (full reconstruction target) ·
**ADVANCED** (taught in senior-depth phase) · **APPENDIX** (explained +
optional implement) · **OPTIONAL_TOOLING** (dev tooling awareness only).

## 1. Feature → milestone matrix

| Senior feature | Prereq concepts | First taught | First simplified impl | Senior-aligned impl | Coverage |
|---|---|---|---|---|---|
| F1 Bootstrap & DI scope | async main, MaterialApp, Provider | M01 (shell), M05 (async main) | M05: async main + hand wiring | M12: `AppDependencyScope` parity; M29 review | CORE |
| F2 Menu hub | layout, streams, VM, dialogs | M02 | M02–M03 static + setState | M12 VM via Provider; M22 progression UI; M29 dialog layer | CORE |
| F3 Local profile & progression | models, prefs, repo streams | M04 | M04 model; M10 JSON prefs | M14 contract+BehaviorSubject; M22 LevelConfig + merge into UI | CORE |
| F4 Game session | setState→VM→DRE ladder | M08 | M08–M09 setState session | M19–M21 VM/phases/ladder/dialog layer; M26 DRE | CORE |
| F5 Lifelines | game phases, sets/maps | M20 | M20 (all five implemented) | M26 under DRE | CORE |
| F6 Result dialogs & sharing | dialogs, share plugin | M09 (`showDialog`) | M09–M21 senior layer migration | M21 layer + M27 `share_plus` | CORE |
| F7 Onboarding overlay | repos, streams, sealed steps, l10n | M18 | M18 simplified gating | M29 gating/scope parity reviewed | CORE |
| F8 Settings | repos, switches, sealed items | M16 | M16 persisted switches + time row | M27 notification wiring; M29 dialog-scope parity | CORE |
| F9 Auth (Google/Apple/email) + sign-out | sealed session, Supabase client | M24 | M24a contract + Disabled impl | M24 email+Google; Apple = APPENDIX (iOS-only); M25 sync hook | ADVANCED (Apple = APPENDIX) |
| F10 Leaderboard | contracts, sealed popup state, remote read | M23 | M23 static→remote | M23 `_requestId` guard + states | CORE |
| F11 Local notifications | permissions, tz, scheduling | M27 | M27 real scheduling | M27 (rollback = concept note) | ADVANCED |
| F12 Design system & assets | tokens, assets, SVG, painters | M02 | M02 token-lite + PNGs | M28 tokens/CustomPainter/SVG/glow | ADVANCED |
| F13 Localization | ARB/gen-l10n, settings stream | M17 | M17 (full approach used immediately) | M17 already senior-aligned | CORE |
| F14 Widget previews | widget API maturity | M29 | — | M29: optional preview catalog | OPTIONAL_TOOLING |
| F15 Release kit & platform config | gradle/manifest awareness | M29 | — | M29: explained appendix (`scripts/kit`, `.release-kit`, dart-defines, signing env) | APPENDIX |

## 2. Concept traceability

For each concept: FIRST INTRODUCED → PRACTICED → SENIOR-ALIGNED.

| Concept | First introduced | Practiced in | Senior alignment |
|---------|------------------|--------------|------------------|
| Dart syntax/classes/ctors/named params | M01–M02 | every milestone | — |
| Null safety (`?`,`!`,`??`,`late`) | M04 | M05+ everywhere | M14 defensive `fromMap` parity |
| `final`/`const` immutability | M01/M04 | all models | M04/M14 `copyWith`+`==` |
| Collections + collection-if/for | M02, M08 | models, lists, lifelines | M20 sets/maps |
| `enum` (+fields) | M08–M09 | phases, types | M19 `GamePhase` parity |
| `Future`/`async`/`await`/`Future.delayed` | M05 | M09, M10, M22 | M25 sync ops |
| `Stream`/`StreamBuilder`/`StreamSubscription` | M06 | M13, M14, M17 | M24 `onAuthStateChange` |
| `Widget`/`StatelessWidget`/`build`/`BuildContext` | M01–M02 | everywhere | — |
| `StatefulWidget`/`setState`/lifecycle | M03 | M08–M10 | senior sparing usage noted |
| Layout constraints (Col/Row/Stack/Expanded/SafeArea) | M02 | M18, M21 overlays | — |
| `ListView`/keys (`ValueKey`) | M08 | M15/M21 keyed swaps | — |
| `Navigator` push/pop, `MaterialPageRoute` | M07 | game/menu flow | M19 `AppNavigationController` |
| `PopScope` back handling | M09 aware, M19 intro | M21 | M21/M29 senior rules |
| `showDialog` → in-Stack dialog layer | M09 → M21 | M16, M21 | M21 (game), M29 (menu) |
| `Provider`/`MultiProvider`/`read`/`watch`/`ChangeNotifierProvider` | M12 | all later milestones | M12 `AppDependencyScope` parity |
| `ChangeNotifier`/`notifyListeners`/`ListenableBuilder` | M11 | M11–M28 | VM pattern everywhere |
| Broadcast `StreamController` UI events | M13 | dialogs/VMs | senior parity immediate |
| `abstract interface class` contracts | M14 | repos | senior parity immediate |
| rxdart `BehaviorSubject`/`ValueStream` | M14 | repos/session/sync streams | senior parity immediate |
| `SharedPreferences` + `jsonEncode`/`toMap`/`fromMap` | M10 | M14–M18 | defensive parsing parity |
| `sealed class` + exhaustive `switch`/patterns | M15 | dialogs, events, states | senior idiom everywhere |
| `Timer.periodic` + dispose | M09 | M19 | effect-driven timer (M26) |
| `FutureBuilder` | M05 | M18 gating | senior gating shown (M29 note) |
| `AnimatedSwitcher`/implicit anim | M21 | M21, M28 | dialog layers parity |
| `AnimationController`/`vsync`/`AnimatedBuilder` | M28 | polish | senior parity subset |
| `CustomPainter` | M28 | countdown ring | senior parity subset |
| `BackdropFilter`/blur/gradients | M21–M28 | dialog layer, tokens | parity subset |
| Localization (ARB/`AppLocalizations`/`MaterialApp.locale`) | M17 | M18 copy | senior parity immediate |
| `String.fromEnvironment`/dart-defines | M23 | M23–M25 | senior parity |
| Supabase init/query/upsert/RLS awareness | M23–M25 | leaderboard, auth, sync | senior parity |
| `google_sign_in`/`sign_in_with_apple` | M24 | auth | Google core; Apple appendix |
| `flutter_local_notifications`/`timezone`/`flutter_timezone` | M27 | settings wiring | senior parity subset |
| `share_plus`/`package_info_plus` | M27 | result share/version | senior parity |
| DRE (`DreChangeNotifier`/reducer/effects/asyncOp/`flowToken`) | M26 | game only | senior parity (capstone) |
| `part`/`part of`, `extension` | M26 (explain) | optional | senior organization noted |
| `test()`/`flutter_test` unit tests | M04 | M10, M14, M22, M25, M26 | senior test conventions |
| `testWidgets`/`WidgetTester` (`pump`,`tap`,`find`) | M08 | M09, M12, M17, M18, M21 | senior widget-test parity |
| `pump(duration)` virtual time | M19 | M19–M21 | senior timer tests |
| Fake repos / `setMockInitialValues` | M10, M14 | M14+ VM/repo tests | `test/helpers/` parity |
| `AppLocalizations`-aware widget tests | M17 | M17+ | senior parity |

## 3. Explicitly deferred or appendix-only content

| Content | Where it lands | Why |
|---------|----------------|-----|
| Apple sign-in | M24 appendix lesson | iOS-only; core path teaches email+Google |
| `SettingsNotificationCoordinator` rollback | M27 concept note | correctness nuance; simplified impl acceptable |
| `_sessionProfileOverride`, `_requestId`, `flowToken` guards | M23–M26 as they arise (explain + test) | correctness details need running app context |
| `part`/`part of` organization | M26 explain | organization, not semantics |
| Widget previews (`lib/previews/`) | M29 OPTIONAL_TOOLING | dev tooling, not app behavior |
| Release kit / signing / xcconfig | M29 APPENDIX | ops surface, not Flutter knowledge |
| Web target specifics | noted M27 (`kIsWeb`) | secondary target in senior app |
| `cupertino_icons` (declared, unused in senior) | — | explicitly excluded: no senior usage |

## 4. Invariants to preserve during lesson generation

- Every "First taught" milestone for a CORE feature must precede its
  "Senior-aligned" milestone — never introduce the senior form first.
- APPENDIX/OPTIONAL items must appear as clearly-labeled appendices, not
  silently dropped.
- If lesson work reveals a feature can't be taught in its mapped
  milestone, record the remap in `DECISIONS.md` and update this file.
