# 05 — Milestone Fidelity Matrix (Atlas + Flux)

Every milestone M01–M13 audited against the senior source across F1–F15.
"Convergence milestone" = the roadmap milestone where the simplification is
scheduled to reach senior parity.

| Milestone | Course goal | Learner implementation | Website lessons | Senior evidence | Fidelity classification | Severity | Convergence milestone | Finding IDs |
|---|---|---|---|---|---|---|---|---|
| M01 — Flutter orientation & first run | project anatomy, `main`→`runApp`→`MaterialApp`, tooling | minimal `main`+`MaterialApp`+`MenuScreen` | 3, all labelled | `lib/main.dart` (full bootstrap incl. portrait lock, Supabase, DI, l10n) | TEMPORARY_VALID_SIMPLIFICATION | LOW | theme/l10n/di incremental M12–M17; **portrait lock: none explicit → FD-07** | FD-07 |
| M02 — Widget composition & static layout | menu 3-region layout, tokens, cards, CTA | `MenuTokens`, header/level/earnings/leaderboard-entry/stats/CTA | 4, labelled | `menu_screen_view.dart`, `menu_screen_content.dart`, `AppTokens`, `stats_card.dart` (identical stat triple) | TEMPORARY_VALID_SIMPLIFICATION | — | M22 progress UI, M23 leaderboard tap, M28 tokens/polish, M29 parity | — |
| M03 — StatefulWidget & setState | ephemeral state, rebuild model, lifecycle | `_soundOn`, `_playTapCount` demo state in `_MenuScreenView` | 3; **m03/01 contains wrong senior claim** | `menu_screen.dart` (Stateless) + `menu_screen_view.dart` (Stateful, dismiss-lock only) + VM-owned `dialogState` | MATCH mechanics + **DEVIATION** in teaching claim | **MEDIUM** | claim fix = content remediation; scaffolds removal implicit M16/M29 → FD-02 | FD-01, FD-02 |
| M04 — Immutable data models & first unit test | `UserProfileData` const model, `copyWith`, `==`/`hashCode` | 8-field subset + invented `expForNextLevel` + invented defaults + `gainExp` | 4; m04/01 explicitly lists senior's extra fields + names `LevelConfig`/M22 | `user_profile_data.dart` (9 fields, '0XFF', zeros, `totalEarnings` string, `totalQuestionCount`, guards, legacy purge) | TEMPORARY_VALID_SIMPLIFICATION | MEDIUM (field-parity mapping implicit only) | M14 (contract), M22 (LevelConfig removes `expForNextLevel` concept); defaults/fields parity not explicitly scheduled → FD-04 | FD-04 |
| M05 — Asynchronous Dart: Future | Future/async/await, demo loader, `FutureBuilder`, async `main` | `loadDemoProfile` + `demoLoadedProfile` + FutureBuilder loading/error/retry | 3, labelled | `main.dart` awaits; `onboarding_overlay_scope.dart` `FutureBuilder` (verified) | TEMPORARY_VALID_SIMPLIFICATION | LOW (loader now dead code → FD-03) | M10 prefs, M14 repo | FD-03 |
| M06 — Streams & StreamBuilder | Stream vs Future, `StreamBuilder`, listen/cancel | `menuSessionTicker` + `_SessionTickerCard` | 3, labelled | senior `ValueStream`s + `initialData:.value` pattern verified | MATCH (concept) + invented UI surface | MEDIUM (removal unscheduled → FD-02) | ticker removal implicit M14/M29 | FD-02 |
| M07 — Navigation: push/pop | route stack, `push`/`pop`, GameScreen route | direct `Navigator.push(MaterialPageRoute)`, AppBar back | 3; m07/03 reads real `AppNavigationController` | `app_navigation_controller.dart` (quoted verbatim in lesson), senior `PopScope`+confirm-exit (deferred M19/M21) | TEMPORARY_VALID_SIMPLIFICATION | — | M19 nav-controller parity; M21 PopScope | — |
| M08 — Mini-quiz answer flow | `QuizQuestion` model, select/submit/reveal visuals, widget test | `QuizQuestion{question,options,correctIndex}`, 4-question const bank | 4, labelled | `game_quiz_question_data.dart` (richer shape), `game_answer_option*` widgets | TEMPORARY_VALID_SIMPLIFICATION | LOW (full question shape not explicitly scheduled → FD-11) | M19/M20 implicit (explanation data needed by dialogs) | FD-11 |
| M09 — Full game session | phase machine, countdown, reveal, end dialogs, restart | `GamePhase`(3)+`GameEndReason`, `Timer.periodic` 15s, `AlertDialog`, `popUntil`(later removed at M10) | 4, labelled | `game_session_state_data.dart` (6 phases, sealed dialogs), `game_reducer_*`, 30s timer | TEMPORARY_VALID_SIMPLIFICATION | MEDIUM (roadmap text promised "money amount per question"/"reveal delay"/explanation dialog — not shipped; recorded in impl notes + D18, roadmap unamended → FD-12) | M19 (ladder, pending/reveal, guaranteed, PopScope), M20 lifelines, M21 dialogs, M26 DRE | FD-12 |
| M10 — SharedPreferences & JSON | persistence, `GameResult` route-result, apply+reset | `ProfileStore` (same key/format/StateError-throw verified), `GameResult`, `applyGameResult`, `_ResetButton` | 4; m10/03 explicitly states senior does NOT use route-result | `user_profile_repository.dart` (same key `'user_profile'`, same throw); `_saveGameResult` 3-step parity verified | TEMPORARY_VALID_SIMPLIFICATION | MEDIUM | M14 repository contract+stream; M22 policy real rules; reset UX converges M24 sign-out; `clear()`-vs-write-default detail → FD-05 | FD-02 (button), FD-05 |
| M11 — ChangeNotifier & ListenableBuilder | VM extraction, menu-only (D20) | `MenuViewModel`+`MenuLoadState`+`load`/`applyGameResult`/`resetProfile` | 3, all verified claims | `menu_screen_view_model.dart` — same ChangeNotifier+ctor shape; senior owns streams not load-states | TEMPORARY_VALID_SIMPLIFICATION | MEDIUM (load-state surface is course-invented; senior-seeded-streams mental model differs → FD-06) | M14 (VM subscribes to `userProfileStream`) | FD-06 |
| M12 — Provider & AppDependencyScope | `Provider.value`, `read`/`watch`, screen-scoped provider | `AppDependencyScope` 1×`Provider.value`; `MenuScreen`→`ChangeNotifierProvider(create:read..load)` — **shape identical to senior** | 3, all claims verified | `app_dependency_scope.dart` MultiProvider×8 `.value`; `menu_screen.dart` provider block | MATCH (pattern) + DEFERRED (7 deps) | — | M14/M16/M19/M23–M25 add real deps | — |
| M13 — One-shot VM events | broadcast `StreamController`, event classes, State bridge | `MenuUiEvent`(abstract)+2 events, `_events.broadcast`, bridge in `_MenuScreenView` with identical lifecycle, `unawaited` | 3, all verified | `menu_screen_ui_event.dart` (sealed), `menu_screen_view_model.dart` (same ctor/`events`/`requestGame`), `menu_screen.dart` bridge (identical lifecycle) | TEMPORARY_VALID_SIMPLIFICATION | LOW (FD-09 snackbar-emit nuance) | M15 sealed; M19 nav controller; M29 bridge-widget form; M24 snackbar-emitting dialog VMs | FD-09 |

## Classification totals

- MATCH (elements): substantial — M12 provider pattern, event lifecycle,
  stats triple, persistence key/format, VM ctor shape.
- TEMPORARY_VALID_SIMPLIFICATION: all 13 milestones (each has at least one
  labelled simplification).
- DEVIATION: 1 (FD-01, lesson claim).
- INVENTED_BEHAVIOR: 0 as *unlabelled* product claims; all inventions are
  labelled scaffolds — but 4 survive without explicit removal milestones
  (FD-02).
- MISSING_SENIOR_BEHAVIOR (in-scope, no valid deferral): portrait lock
  (FD-07), question-model full shape scheduling (FD-11) — both LOW;
  M09 scope items drift (FD-12 — MEDIUM).
- UNVERIFIED: 0.

## Severity totals (draft for artifact 10)

CRITICAL 0 · HIGH 0 · MEDIUM 5 (FD-01, FD-02, FD-04, FD-06, FD-12) ·
LOW 4 (FD-03, FD-05, FD-07, FD-09, FD-11 → 5 LOW) · INFO 1 (FD-10).
