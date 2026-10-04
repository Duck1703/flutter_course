# M19 → M20 HANDOFF

## M19 verdict

**MILESTONE_COMPLETE** — see `11-final-verdict.md`.

## Architecture after M19

```
GameScreen (provider scope + stateful event bridge)
   │  user intent: tap / back / dialog actions
   ▼
GameScreenViewModel extends ChangeNotifier
   │  owns: 6-phase GamePhase machine · 30s Timer.periodic
   │        (pause/resume on dialog) · delayed reveal/explain flows
   │        · flowToken staleness · GameSessionState (immutable,
   │        copyWith) · sealed GameDialogState · uiEvents stream
   ▼
GameScreenPresentationMapper (pure)
   │  state + bank → GameScreenData (per-option flags, timer, ladder)
   ▼
GameScreen renders screenData (context.watch)
   │  dialogs: showDialog scaffold (M21 owns in-Stack layer)
   ▼
AppNavigationController (GlobalKey<NavigatorState>)
   context-free openGame/goBack · PopScope + dialog-route back routing
```

## Counts

- Learner tests: **126/126** (M18 baseline 102 → +24)
- `flutter analyze`: clean; `flutter build web`: pass
- Site pages: **102** (95 → +7 `/m19/` routes); `npm run build` pass
- Sequential replay: 6/6 checkpoints PASS on physical M18 clone

## Register entries closed at M19

FR-05 (game phases) · FR-06 (30s timer) · FR-10 (question model) ·
FR-13 (nav controller) · FR-17 (portrait lock) · FR-18 (question bank)

## Remaining game register entries (M20+)

| ID | Still open | Converges |
|----|-----------|-----------|
| FR-03 | EXP basis + `totalEarnings`/`totalQuestionCount` fields (ladder `earnedAmount` landed) | M22 |
| FR-04 | VM-side result save (nav controller landed; `GameResult` route-pop still transports) | M22 |
| FR-07 | in-Stack `GameDialogLayer` + lifeline dialog variants | M20 + M21 |
| FR-16 | `showDialog` → in-Stack dialog mechanism (game + menu) | M21 |

Plus non-game rows unchanged (FR-01/02/11/12/14/27/28/29/30/31/32).

## Concept-registry delta (M19 taught)

D-33 finite state machine · D-34 immutable `copyWith` update ·
F-27 VM-owned timer/lifecycle · F-28 `PopScope` ·
A-18 session-state→mapper→`GameScreenData` ·
A-19 context-free `navigatorKey` navigation — all TAUGHT.

## Prerequisite-graph status

M19 section appended; nodes closed. M20 requires M19's
session-state/phase nodes (TAUGHT) — clear to proceed.

## Content gaps

None blocking. CONTENT_GAP_REGISTER unchanged by M19.

## M20 prerequisites (verified)

- [x] 6-phase `GamePhase` + sealed `GameDialogState` live in
      `GameSessionState` — lifelines add dialog variants + a
      `usedLifelines`-style field per senior.
- [x] `GameAnswerOptionData.isEliminated` flag already in screen-data
      shape — 50:50 maps onto it.
- [x] Mapper + `screenData` pipeline — lifeline UI state derives
      through it.
- [x] `uiEvents` stream + dialog bridge — lifeline dialogs ride the
      same path until M21.
- [x] `fake_async` timing tests — covers simulated `Future.delayed`
      AI-hint flows.
- [ ] M20 brief must re-inspect senior lifeline source directly
      (50:50 / audience poll / simulated AI / walk-away + exact
      phase + dialog restrictions) — do not assume from this doc.

## POST_PASS_MUTATION_CHECK

**REVERIFIED** — all post-PASS edits (impl NIT, content MINORs/NITs,
2 site-QA content nits) independently re-verified; md5 7/7; rebuild
green. No stale QA.

## M20_READY: **YES**

Gate open: M20 full independent pipeline may begin.
