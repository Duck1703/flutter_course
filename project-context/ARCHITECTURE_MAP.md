# Architecture Map — Senior Application

Derived from source, not documentation. All paths relative to
`D:\vibe_coding\flutter\flutter-accelerator-ai`.

## 1. Layer diagram

```
┌──────────────────────────────────────────────────────────────────┐
│ PRESENTATION                                                      │
│  screens/  MenuScreen, GameScreen          (route shells)         │
│  widgets/  common/ onboarding/ menu/ game/ leaderboard/           │
│            (presentation-only; data in, callbacks out)            │
├──────────────────────────────────────────────────────────────────┤
│ PRESENTATION STATE (view_models/, domain-grouped)                 │
│  menu/      MenuScreenViewModel  (ChangeNotifier, dialog state,   │
│             MenuAuthDialogViewModel, MenuSignOutDialogViewModel,  │
│             MenuAuthActionCoordinator, MenuLevelProgress)         │
│  game/      GameScreenViewModel extends DreChangeNotifier         │
│             ├─ dre/    GameState, GameAction, GameEffect,         │
│             │          GameAsyncOp (sealed contracts)             │
│             ├─ reducer/ GameReducer + 4 part files (pure)         │
│             ├─ bridge/ effects handler + result persistence       │
│             └─ game_screen_presentation_mapper.dart               │
│  onboarding/ OnboardingViewModel  settings/ SettingsViewModel     │
│  leaderboard/ LeaderboardDialogViewModel                          │
├──────────────────────────────────────────────────────────────────┤
│ DATA CONTRACTS (repositories/)  — abstract interface class        │
│  AuthRepository        → ValueStream<AuthSessionData>             │
│  UserProfileRepository → ValueStream<UserProfileData>             │
│  UserSettingsRepository→ ValueStream<UserSettingsData>            │
│  OnboardingRepository  → ValueStream<bool>                        │
│  UserProfileSyncRepository → ValueStream<ProfileSyncStateData>    │
│  LeaderboardRepository → Future<LeaderboardSnapshot>              │
├──────────────────────────────────────────────────────────────────┤
│ DATA IMPLEMENTATIONS + SERVICES                                   │
│  Local:  UserProfileRepositoryImpl, UserSettingsRepositoryImpl,   │
│          OnboardingRepositoryImpl  (SharedPreferences + JSON)     │
│  Remote: AuthRepositoryImpl, SupabaseLeaderboardRepository,       │
│          UserProfileSyncRepositoryImpl (SupabaseClient)           │
│  Fallbacks: DisabledAuthRepository, DisabledLeaderboardRepository,│
│          UserProfileSyncRepositoryDisabled                        │
│  Services: SupabaseClientService, GoogleAuthService,              │
│          AppleAuthService, LocalNotificationService               │
├──────────────────────────────────────────────────────────────────┤
│ MODELS (data/) — immutable value objects, hand-rolled             │
│  fromMap/toMap/copyWith/equality; sealed state hierarchies        │
└──────────────────────────────────────────────────────────────────┘
```

## 2. Dependency injection & lifecycle ownership

```
main()
  └─ constructs everything explicitly (no DI framework)
       └─ AppDependencyScope = MultiProvider(Provider.value ×8)
            navigationController, userProfileRepository, authRepository,
            leaderboardRepository, profileSyncRepository,
            onboardingRepository, userSettingsRepository,
            notificationService

Scoped ViewModels (created per surface, disposed with it):
  MenuScreen          → ChangeNotifierProvider<MenuScreenViewModel>
  GameScreen          → ChangeNotifierProvider<GameScreenViewModel>
  OnboardingOverlayScope   → ChangeNotifierProvider<OnboardingViewModel>
                        (only after completion flag loads false)
  MenuAuthDialogScope      → ChangeNotifierProvider<MenuAuthDialogViewModel>
  MenuSignOutDialogScope   → ChangeNotifierProvider<MenuSignOutDialogViewModel>
  MenuLeaderboardDialogScope → ChangeNotifierProvider<LeaderboardDialogViewModel>
  MenuSettingsDialogScope    → ChangeNotifierProvider<SettingsViewModel>
```

Consumers use `context.read<T>()` (commands/one-time) and
`context.watch<T>()` (rebuild on `notifyListeners`).

## 3. Menu flow (verified)

```
user taps Start Game
  GradientCtaButton.onTap                     widgets/menu/gradient_cta_button.dart
  → MenuScreenViewModel.requestGame()         view_models/menu/menu_screen_view_model.dart:106
  → emits MenuGameRequested on _events stream
  → _MenuScreenEventBridgeState._handleUiEvent  screens/menu_screen.dart:67
  → AppNavigationController.openGame()          navigation/app_navigation_controller.dart:10
  → Navigator.push(MaterialPageRoute → GameScreen)
```

Profile render path:

```
UserProfileRepositoryImpl.loadUserProfile()
  → SharedPreferences 'user_profile' → jsonDecode → UserProfileData.fromMap
  → BehaviorSubject.add → userProfileStream
  → MenuScreenViewModel._handleUserProfile → notifyListeners
  → context.watch rebuild → MenuProfileHeader/StatsCard/LevelProgressCard
```

## 4. Game flow (DRE) — traced end-to-end

Dispatch pipeline (`core/dre/dre_change_notifier.dart`):

```
dispatch(action)
  → reducer.reduce(state, action) → DreResult{state, effects[], asyncOp}
  → if state changed: notifyListeners()         (context.watch rebuilds)
  → effects → _effects (broadcast StreamController)
  → asyncOp → unawaited executeAsyncOp(op, snapshot)
```

Example: answering a question.

```
tap answer row
  GameAnswerOption.onTap → onAnswerTap
  → GameScreenViewModel.submitAnswer            view_models/game/game_screen_view_model.dart:79
  → dispatch(GameAnswerSubmitted(text))
  → GameReducer._submitAnswer                   reducer/game_reducer_answer_flow.dart
       guard: phase==playing
       state' = copyWith(phase: answeredPending, selectedAnswer, flowToken+1)
       effects = [GamePauseTimer, GameScheduleAnswerReveal(token)]
  → _handleEffect                               bridge/game_screen_view_model_effects.dart
       _pauseTimer(): _timer.cancel()
       _scheduleAnswerReveal: Future.delayed(1500ms)
         → dispatch(GameAnswerRevealElapsed(token))
  → GameReducer._revealAnswer
       guard: token match + phase answeredPending
       correct? moneyEarned = ladder[index].amount (safe haven → guaranteed)
       state' = answeredRevealed (+moneyAnimationTrigger++)
       effects = [GameScheduleExplanation(token)]
  → ..._showExplanation → dialogState = GameExplanationDialog(...)
  → GameDialogLayer rebuilds → GameExplanationDialogView
  → dismiss → _loadNextQuestionOrVictory (phase: playing, next question,
       GameStartTimer) or victory → GameSaveResult asyncOp
  → executeAsyncOp → _saveGameResult            bridge/..._result_persistence.dart
       load profile → level progression (LevelConfig) → save → if authed,
       profileSyncRepository.syncUserProfile(session)
```

Timer path: `GameStartTimer` → `Timer.periodic(1s)` →
`dispatch(GameTimerTicked)` → `_tickTimer` decrements `remainingTime`;
at zero it synthesizes an empty-answer submit (`selectedAnswer: ''` →
counts as wrong after reveal).

## 5. Dialog/navigation model

- Dialogs are **not routes** — both screens render a `Stack`; the top layer
  is `MenuDialogLayer`/`GameDialogLayer` driven by sealed `MenuDialogState`
  /`GameDialogState`, animated with `AnimatedSwitcher` + `BackdropFilter`
  blur (`widgets/menu/menu_dialog_layer.dart`,
  `widgets/game/dialogs/game_dialog_layer.dart`).
- `ValueKey(state.transitionKey)` keys the switcher children.
- `PopScope` intercepts system back: game maps back→confirm-exit or dialog
  dismiss; menu maps back→dialog dismiss.
- Each menu dialog creates its own scoped VM (`*DialogScope`).

## 6. Data flows

Local write (settings toggle):

```
switch row onChanged
  → SettingsViewModel.toggleSetting            view_models/settings/settings_view_model.dart:99
  → _saveSettings(copyWith(...))
  → UserSettingsRepositoryImpl.saveUserSettings
       SharedPreferences.setString('user_settings', jsonEncode(toMap()))
       → _settingsSubject.add(settings)
  → userSettingsStream listeners: VM._handleSettings (notify) AND
    main.dart StreamBuilder (MaterialApp.locale — live locale switch)
```

Remote read (leaderboard):

```
MenuLeaderboardDialogScope creates VM → loadLeaderboard()
  → LeaderboardDialogViewModel.loadLeaderboard (state=Loading, _requestId++)
  → SupabaseLeaderboardRepository.loadLeaderboard
       .from('leaderboard').select('rank,name,avatar_url,level,total_money_won')
       .order(total_money_won desc).order(rank).limit(10)
       + eq('auth_uuid', uid).maybeSingle() for current row
  → LeaderboardSnapshot → LeaderboardPopupSuccess/Empty/Error
  → notifyListeners → MenuLeaderboardDialog renders body variant
```

Remote write (profile sync):

```
after sign-in or game save
  → MenuAuthActionCoordinator._signInAndSync / _saveGameResult
  → UserProfileSyncRepositoryImpl.syncUserProfile(session)
       fetch public.users WHERE auth_uuid = uid
       mergeUserProfileForSync(session, local, remote)   data/profile/app_user_data.dart
       save merged profile locally → upsert public.users onConflict auth_uuid
       syncStateSubject: Idle→InProgress→Idle/Failed
```

## 7. Auth flow

```
MenuAuthDialog → signInWithGoogle()
  → MenuAuthActionCoordinator.signInWithGoogle
  → AuthRepositoryImpl.signInWithGoogle
       GoogleAuthServiceImpl.signIn() → GoogleSignIn.instance.authenticate
       → idToken (+accessToken via authorizationClient)
       → _client.auth.signInWithIdToken(provider: google, ...)
       → _emit(AuthSessionAuthenticated(...))   + onAuthStateChange listener
  → loadAuthState → syncUserProfile(session)
  → VM emits dismiss + snackbar events → dialog scope consumes
```

`DisabledAuthRepository` (no Supabase configured) returns failure results —
app remains fully playable as guest.

## 8. Concurrency & correctness mechanisms

- `flowToken` (int, incremented per async chain) invalidates stale delayed
  callbacks in the game reducer.
- `_requestId` guard in `LeaderboardDialogViewModel` drops stale responses.
- `_isSyncing` flag in `UserProfileSyncRepositoryImpl` prevents reentry.
- `_isDisposed` flags everywhere guard callbacks after dispose.
- `hasSavedResult` in `GameState` prevents double result persistence.
- `SettingsNotificationCoordinator` rolls back scheduling on save failure.
- Broadcast `StreamController`s for UI events; `BehaviorSubject` gives
  current-value reads (`stream.value`) to VMs and widgets.

## 9. Conventions worth noting

- `sealed class` + exhaustive `switch` expressions everywhere for state.
- `part`/`part of` used to split `GameReducer` and the VM bridge files.
- `abstract interface class` for contracts; `final class` for data.
- Repository `create()` static factories for async construction.
- Immutable models: `const` constructors, `copyWith`, `==`/`hashCode`,
  `List/Map/Set.unmodifiable` in `GameState`.
- Defensive parsing: `fromMap` clamps types/ranges, ignores bad values.
