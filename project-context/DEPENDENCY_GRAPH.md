# Dependency Graph — Technical & Learning Order

Derived from real imports and runtime wiring in the senior app. This is a
**prerequisite map**, not the course milestone roadmap — it shows what must
logically precede what so the learner project always compiles and each
concept has its dependencies taught first.

## 1. Technical dependency graph (code level)

```
Dart core ─────────────────────────────────────────────────────────┐
  │  syntax, null safety, collections, enums, async/Future         │
  ▼                                                                │
Flutter widgets (Stateless/Stateful, build, context)               │
  │                                                                │
  ├──► Design tokens & assets          core/app_design_tokens.dart │
  │      core/app_assets.dart, onboarding_design_tokens,           │
  │      surface_glow_gradient                                     │
  │                                                                │
  ├──► Data models (immutable, copyWith, ==, toMap/fromMap)        │
  │      lib/data/**                                               │
  │      ├─ sealed classes + switch (GameDialogState,              │
  │      │   MenuDialogState, AuthSessionData, OnboardingStepState,│
  │      │   SettingItemData, LeaderboardPopupState,               │
  │      │   ProfileSyncStateData)                                 │
  │      └─ seed data (game questions, money ladder, leaderboard)  │
  │                                                                │
  ├──► Repository contracts (abstract interface class)             │
  │      repositories/**/contract files                            │
  │      │                                                         │
  │      ├──► Local impls: SharedPreferences + rxdart              │
  │      │      BehaviorSubject (ValueStream)                      │
  │      │      profile / settings / onboarding repos              │
  │      │                                                         │
  │      └──► Remote impls: SupabaseClient                         │
  │             auth / leaderboard / profile-sync repos            │
  │             ├─ GoogleAuthService, AppleAuthService             │
  │             └─ SupabaseEnvironment (dart-defines)              │
  │                                                                │
  ├──► Provider DI: AppDependencyScope + context.read/watch        │
  │      core/app_dependency_scope.dart                            │
  │      │                                                         │
  │      ├──► ViewModels: ChangeNotifier + notifyListeners         │
  │      │      + StreamController UI events + subscription mgmt   │
  │      │      menu / onboarding / settings / leaderboard /       │
  │      │      auth-dialog / sign-out-dialog VMs                  │
  │      │      │                                                  │
  │      │      └──► DRE (game only): DreChangeNotifier,           │
  │      │             GameReducer (pure), effects, asyncOp,       │
  │      │             presentation mapper, flowToken guards       │
  │      │                                                         │
  │      └──► Navigation: AppNavigationController                  │
  │             (GlobalKey<NavigatorState>, push/pop)              │
  │                                                                │
  ├──► Screens: MenuScreen (home) → GameScreen (push)              │
  │      + in-Stack dialog layers + PopScope back handling         │
  │                                                                │
  └──► Platform services: LocalNotificationService                 │
         (flutter_local_notifications + timezone), share_plus,     │
         package_info_plus                                         │
                                                                 │
Cross-cutting (introduced when needed):                            │
  Localization (l10n.yaml + ARB + AppLocalizations)                │
  Widget previews (lib/previews/, @Preview)                        │
  Release kit (scripts/kit, .release-kit/project.env)              │
```

## 2. Feature-level dependency order (what requires what)

```
F1 bootstrap/DI scope
  └─► F2 menu shell (needs: widgets, Provider, streams)
        ├─► F3 local profile repo (menu renders it; game writes it)
        ├─► F7 onboarding overlay (needs: F3-style prefs repo, F13 l10n
        │     for copy, F11 for the permission step)
        ├─► F10 leaderboard dialog (needs: repo contract; static fallback
        │     first, Supabase later)
        ├─► F8 settings dialog (needs: F3-style prefs repo, F13 for
        │     language row, F11 for notification rows)
        ├─► F9 auth + sign-out dialogs (needs: auth contract, sealed
        │     session model, sync repo; real providers last)
        └─► F4 game session (needs: models, reducer-lite state, nav push)
              ├─► F5 lifelines (needs F4 phases/dialogs)
              └─► F6 result dialogs + share + persistence→sync (needs F3)
```

## 3. Concept prerequisite chain (learning order skeleton)

```
Dart syntax & null safety
→ Widgets & composition (Stateless → Stateful → setState)
→ Layout basics (Column/Row/Stack/SafeArea/Expanded/ConstrainedBox)
→ Callback-driven widget APIs
→ Futures/async-await
→ Immutable data models + copyWith + equality + sealed classes
→ Streams & StreamBuilder; StreamSubscription lifecycle
→ Provider (read/watch, ChangeNotifierProvider, MultiProvider)
→ ChangeNotifier ViewModel pattern + UI-event streams
→ SharedPreferences + JSON serialization + repository contract
→ Repository streams (BehaviorSubject) feeding VMs
→ Imperative navigation + PopScope + in-Stack dialog layer
→ Game feature: plain-ChangeNotifier version FIRST
   → then DRE reducer refactor as the "senior" step
→ Supabase: env config → auth contract → real providers → sync → leaderboard
→ Platform services (notifications, share) — appendices
→ Polish: animations, CustomPainter, blur/glow, previews — appendices
```

## 4. Hard prerequisite edges (cannot be reordered)

- Game **persistence** requires `UserProfileRepository` (F3) — game result
  calls `userProfileRepository.saveUserProfile`.
- **Profile sync** requires both local profile repo and an authenticated
  session — only reachable after auth contract exists.
- **Leaderboard remote** requires Supabase client; the disabled/static
  repository intentionally removes that edge for early learning.
- **Settings language switching** requires `userSettingsStream` +
  `MaterialApp.locale` wiring + ARB generation.
- **Onboarding** requires onboarding repo + settings repo (language
  preselect) + notification service (permission step).
- Game **DRE** requires: sealed classes, Streams, ChangeNotifier, Timer
  management — it is a capstone refactor, not a starting point.
- `PopScope` back-interception requires understanding Navigator first.

## 5. Safe simplification ladder (each rung still compiles)

```
v0  static widgets only (menu look, game look) — no state
v1  setState counters / toggles inside one screen
v2  ChangeNotifier + Provider VM for menu profile (fake repo)
v3  SharedPreferences repos + streams (F3, onboarding flag)
v4  push navigation Menu→Game + PopScope
v5  game loop as plain VM: question→answer→reveal→next (no lifelines)
v6  lifelines + dialogs-as-state + timer
v7  result persistence + level progression
v8  settings + localization switch
v9  auth contract + Disabled impl; then real Supabase auth
v10 leaderboard (static → remote), profile sync
v11 notifications, share, previews, release kit (appendices)
```

This ladder is the raw material for future curriculum milestones — the
milestone plan itself is a separate supervised phase.
