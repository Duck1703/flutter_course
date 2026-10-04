# M07–M09 Implementation Notes

Internal engineering record for Step 05 (agent-facing, not lesson content).
Purpose: a future agent must be able to reconstruct *why* the learner app
evolved this way without conversation history. See also `DECISIONS.md` D18.

## End-of-M06 starting point

- `lib/main.dart`: `Future<void> main() async` +
  `WidgetsFlutterBinding.ensureInitialized()`; `MaterialApp` home
  `MenuScreen`.
- `lib/screens/menu_screen.dart` (~600 lines): `MenuScreen`
  `StatefulWidget`; `_profile` (`UserProfileData`) + `gainExp(10)` on play
  tap; `FutureBuilder<void>` loading/error/retry; `_SessionTickerCard`
  with `StreamBuilder` over `menuSessionTicker()`; `_onPlayTap` at M06
  only did `setState` EXP demo — **no navigation existed**.
- `lib/core/menu_tokens.dart`: design tokens (unchanged).
- `test/`: 3 pure-Dart files, 15 tests. No `test/widgets/` dir.
- Zero third-party packages.

## End-of-M07 code state

- NEW `lib/screens/game_screen.dart` — `GameScreen` `StatelessWidget`
  placeholder: `Scaffold` + `AppBar('Phòng chơi')` + same gradient
  background/`SafeArea`/`ConstrainedBox`/`MenuTokens` styling as menu;
  body = static quiz layout preview (counter row, `_QuestionCard`,
  4 inert option rows, `_SubmitButton`) — no interaction, no state.
- `menu_screen.dart`: added `import '../screens/game_screen.dart'`;
  `_onPlayTap` now does `Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const GameScreen()))` in addition to
  the `gainExp(10)` demo (kept intentionally — real result handoff is M10+).
- No test changes at M07 (widget tests arrive M08; the route-flow test
  was added retroactively inside M08's test file).
- Gate: analyze clean; 15/15; build web pass.

## End-of-M08 code state

- NEW `lib/data/game/quiz_question.dart` — `QuizQuestion`: `final String
  question; final List<String> options; final int correctIndex;` const
  constructor + `bool isCorrect(int index)`. No `Difficulty` yet.
- NEW `lib/data/game/quiz_questions.dart` — `const quizQuestions` bank,
  4 questions about concepts actually taught (StatefulWidget, setState,
  Future, copyWith).
- `game_screen.dart` → `StatefulWidget`. `_GameScreenState` fields (M08
  version): `_questionIndex`, `_selectedIndex` (`int?`), `_submitted`,
  `_quizFinished`, `_correctCount`; getters `_question`, `_isLastQuestion`.
  Handlers: `_selectAnswer` (guard `_submitted`), `_submitAnswer`
  (score on lock), `_nextQuestion` (last → finished panel), `_restart`.
  `_AnswerVisualState { idle, selected, correct, wrong, dimmed }` top-
  level private enum; `_optionState(i)` derives visual state. Body used
  `Spacer` to pin `_SubmitButton`. Finished → inline result panel
  ('Đúng X/4 câu' + CHƠI LẠI) — *this panel was removed again in M09*.
- NEW `test/quiz_questions_test.dart` — bank integrity (≥3 questions,
  options ≥2, correctIndex in range, unique questions).
- NEW `test/widgets/game_screen_test.dart` — first widget tests:
  `pumpGameScreen` helper (`MaterialApp` wrapper), `correctOptionOf`,
  `answerCorrectly`; 6 tests (first-question render, select icon, correct
  feedback, wrong feedback, TIẾP→câu 2, menu→game→back route flow).
- Gate: analyze clean; 25/25; build web pass.

## End-of-M09 code state (current on-disk state)

- NEW `lib/data/game/game_session_state.dart` — `enum GamePhase
  { answering, revealing, finished }` + `enum GameEndReason
  { wrongAnswer, timeout, victory }` (doc comments note senior has 6
  phases; file mirrors senior `data/game/` placement).
- `game_screen.dart` (~580 lines) — full local session:
  - `_GameScreenState` fields: `_questionIndex`, `_selectedIndex`,
    `_correctCount`, `GamePhase _phase`, `GameEndReason? _endReason`,
    `int _secondsLeft`, `Timer? _timer`; `static const secondsPerQuestion
    = 15` (senior uses 30 — D18).
  - `initState` → `_startTimer()`; `dispose` → `_timer?.cancel()`.
    `_startTimer` always cancels first + resets `_secondsLeft`.
    `_onTick` guards `phase != answering`, decrements in `setState`,
    `_finish(timeout)` at 0.
  - Transitions: `_selectAnswer`/`_submitAnswer` (cancel timer →
    `revealing` + score), `_advanceAfterReveal` (wrong → `finish
    (wrongAnswer)`; last-correct → `finish(victory)`; else next question
    + restart timer), `_finish` (cancel timer → `finished` +
    `_showResultDialog()`), `_restart` (reset all → `answering` + timer).
  - `_showResultDialog`: `showDialog<void>(barrierDismissible: false)` →
    `AlertDialog` (title/color via `_endReason` ternary; `switch` on
    `GameEndReason?` incl. `case null` for `_dialogTitle`/`_resultText`).
    Actions: CHƠI LẠI = `Navigator.of(dialogContext).pop()` + `_restart()`;
    VỀ MENU = `Navigator.of(context).popUntil((r) => r.isFirst)`.
  - `_QuizBody` gained `secondsLeft` + `revealed` params; header Row =
    counter + `Spacer` + timer icon/text (red ≤5s, cyan else). Body
    content wrapped in `Expanded` + `SingleChildScrollView`
    (`_SubmitButton` pinned below) — **this replaced M08's `Spacer`**
    after the victory test caught a real 7 px `RenderFlex` overflow.
  - Inline M08 result panel deleted — dialog replaces it.
- `test/widgets/game_screen_test.dart` — extended to 11 tests (+5):
  game-over dialog, CHƠI LẠI reset, victory loop (asserts
  `textContaining('Đúng 4/4 câu')` — bare `'4/4'` collides with the
  `'Câu 4/4'` counter behind the dialog), timeout via
  `pump(Duration(seconds:16))`, VỀ MENU double-route pop
  (`pump(800ms)` — sequential exit animations ~150+300 ms). New shared
  helper `unmount(tester)` = `pumpWidget(const SizedBox())` — required
  because a live `Timer` left pending fails the test.
- Gate: analyze clean; 29/29 (18 unit + 11 widget); build web pass.

## Intentional simplifications (vs senior)

- `GamePhase` 3 values vs senior's 6 (`notStarted`, `playing`,
  `answeredPending`, `answeredRevealed`, `gameOver`, `victory`) — no
  waiting/lifeline-pending phases exist yet.
- `GameEndReason` enum instead of senior's richer dialog-state data.
- 15 s/question vs senior's 30 s (D18) — same mechanism, faster tests.
- `showDialog`/`AlertDialog` standard instead of senior's state-driven
  in-Stack dialog layer (M21 by design).
- Wrong answer = immediate game over; **no money ladder** (senior's
  question-value progression deferred — needs more game architecture).
- No lifelines, no question difficulty, no multi-player framing.
- All session state widget-local `setState` — deliberate; the file's
  size/complexity is the motivation for M11+ VM extraction.
- Navigation stays anonymous imperative routes; no named routes,
  `navigatorKey`, or `AppNavigationController` wrapper yet.

## Deferred concepts (firewall upheld)

No persistence (`SharedPreferences` is M10), no `ChangeNotifier`/
`ListenableBuilder` (M11), no Provider/`read`/`watch` (M12), no
repositories/contracts (M14), no rxdart/`BehaviorSubject` (M14), no
sealed classes or DRE/reducer (M15+/M26), no Supabase/network, no
`pumpAndSettle` (menu's infinite ticker stream would never settle —
noted in M09-04), no golden tests, no `fake_async` package.
Zero dependencies added — still `flutter_test` (SDK) only.

## Verification commands (all PASS at Step 05 end)

- `cd learner-app && flutter pub get`
- `flutter analyze` → No issues found
- `flutter test` → +29: All tests passed
- `flutter build web` → Built build\web
- `cd web && npm run build` → 44 pages (m01–m09 routes + roadmap + start)
- Senior repo `git status --porcelain` → clean (read-only upheld)

## Assumptions for M10 (persistence)

- `_correctCount`/`gamesJoined`/`gamesWon` are not yet written back to
  `_profile` — the menu's EXP demo (`gainExp` on play tap) is still the
  only profile mutation; M10 is where real session results should land
  (decision needed then: what a finished game contributes).
- `GameScreen` receives no data via route args yet — profile access
  across routes + result return (`push<T>` Future) is untapped course
  material (roadmap M10/M14).
- `secondsPerQuestion` is a const — difficulty/length config does not
  exist.
- The `popUntil(isFirst)` back-to-menu assumes menu is always the bottom
  route — revisit when named routes or deeper stacks arrive (M14).
