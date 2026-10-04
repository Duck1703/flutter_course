# 03 — File-Level Traceability (Flux)

Relationship: **DIRECT** (matches senior shape for current stage) ·
**SIMPLIFIED** (labelled subset, convergence mapped) ·
**DEFERRED** (senior feature not yet introduced, milestone mapped) ·
**NO_VALID_MAPPING** (invented, unlabelled, or no convergence).

| Learner file | Senior file / symbol | Relationship | Evidence / note |
|---|---|---|---|
| `lib/main.dart` | `lib/main.dart` | SIMPLIFIED | same `main`→`runApp`→`MaterialApp` skeleton; missing portrait lock, navigatorKey, l10n, Supabase, 7 deps — roadmap M01 note "all wired later"; orientation lock has **no owning milestone** (→ FD-07) |
| `lib/core/app_dependency_scope.dart` | `lib/core/app_dependency_scope.dart` | SIMPLIFIED | same class name + `Provider.value` style; 1 vs 8 entries; doc cites senior file; grows via M14/M19/M16/… |
| `lib/core/menu_tokens.dart` | `lib/core/app_design_tokens.dart` `AppTokens` | SIMPLIFIED | labelled subset; M28 consolidation |
| `lib/data/profile/user_profile_data.dart` | `lib/data/profile/user_profile_data.dart` | SIMPLIFIED | field subset + invented `expForNextLevel`, invented defaults, missing `totalEarnings`/`totalQuestionCount`/legacy-purge/guards — labelled "rút gọn"; parity gap partially unmapped (→ FD-04) |
| `lib/data/profile/demo_profile_loader.dart` | — (none) | TEMPORARY_VALID → now **dead code** | labelled demo; expired at M10 but still shipped in `lib/` (→ FD-03) |
| `lib/data/profile/profile_store.dart` | `repositories/profile/user_profile_repository.dart` | SIMPLIFIED | same `'user_profile'` key, same JSON format, same `StateError`-on-false (verified line 70); `clear()`=remove vs senior `resetUserProfile`=write-default (→ FD-05); contract+BehaviorSubject explicitly mapped to M14 |
| `lib/data/menu_session_ticker.dart` | — (none) | TEMPORARY_VALID (course-only) | labelled teaching source; removal unscheduled (→ FD-02) |
| `lib/data/game/quiz_question.dart` | `lib/data/game/game_quiz_question_data.dart` | SIMPLIFIED | `correctIndex:int` vs senior `correctOption:String`; missing id/category/language/difficulty/explanation; labelled; model parity implicit at M19/M20 (→ FD-11) |
| `lib/data/game/quiz_questions.dart` | `lib/data/game/game_sample_questions_data.dart` | SIMPLIFIED | 4-question const bank; labelled |
| `lib/data/game/game_session_state.dart` | `lib/data/game/game_session_state_data.dart` | SIMPLIFIED | 3 vs 6 phases (doc cites senior file); `GameEndReason` invented (senior uses sealed `GameDialogState`); converges M15+M19/M21 |
| `lib/data/game/game_result.dart` | `view_models/game/bridge/game_screen_view_model_result_persistence.dart` (params) | SIMPLIFIED | doc explicitly says senior does NOT use route-result; converges M19 (nav controller) + M22 (VM-side save) |
| `lib/screens/menu_screen.dart` | `lib/screens/menu_screen.dart` + `widgets/menu/menu_screen_view.dart` | SIMPLIFIED | same entry-shape (Stateless→provider→stateful bridge); invented UI elements + missing dialogs/settings/leaderboard-tap/onboarding — labelled diffs; M16/M23/M24/M29 |
| `lib/screens/game_screen.dart` | `lib/screens/game_screen.dart` | SIMPLIFIED | setState session vs DRE VM; 15s vs 30s (commented); AlertDialog vs dialog layer; free back vs PopScope+confirm-exit; converges M19–M21, M26 |
| `lib/view_models/menu/menu_view_model.dart` | `lib/view_models/menu/menu_screen_view_model.dart` | SIMPLIFIED | same ChangeNotifier+ctor-injection+broadcast-events shape; learner owns store+load-state+applyGameResult+resetProfile vs senior stream-subscription VM — converges M14 |
| `lib/view_models/menu/menu_ui_event.dart` | `lib/view_models/menu/menu_screen_ui_event.dart` | SIMPLIFIED | identical member shapes; `abstract` vs `sealed` labelled + M15; learner's snackbar event is emitted (senior never emits menu-level snackbar — → FD-09) |

## Senior files evidenced (read this audit)

34 files directly inspected, incl.: `main.dart`, `app_dependency_scope.dart`,
`app_navigation_controller.dart`, `menu_screen.dart`, `menu_screen_view.dart`,
`menu_screen_content.dart`, `menu_profile_header.dart`, `stats_card.dart`,
`menu_level_progress.dart`, `menu_dialog_state.dart`,
`menu_screen_view_model.dart`, `menu_screen_ui_event.dart`,
`menu_auth_action_coordinator.dart`, `user_profile_repository.dart`,
`user_profile_data.dart`, `game_screen.dart`, `game_session_state_data.dart`,
`game_quiz_question_data.dart`, `level_config.dart`,
`game_screen_view_model.dart`, `…_result_persistence.dart`,
`onboarding_overlay_scope.dart`, `pubspec.yaml`, `AGENTS.md`, plus directory
listings for `widgets/menu/{auth,leaderboard,profile,settings}`,
`repositories/{auth,leaderboard,settings,onboarding,profile}`,
`view_models/{game,settings,onboarding,leaderboard}`, `core/dre`, `l10n`.

## NO_VALID_MAPPING rows

None at file level — every learner file either maps to a senior file or is
an explicitly labelled course-only scaffold. Findings about *mapping
completeness* (not existence) are FD-02/FD-04/FD-07/FD-11.
