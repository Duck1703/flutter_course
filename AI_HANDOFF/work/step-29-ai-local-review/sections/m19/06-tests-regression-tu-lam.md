## 🤖 AI Local — Kiểm tra project sau bài này (TỔNG HỢP M19)

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m19/06 — TỔNG HỢP M19 (full regression: analyze + 126/126 + build web; toàn bộ game đã chuyển từ widget-State sang VM-owned state machine).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter build web` READ-ONLY (chỉ verify). Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. M19 = rebuild xuyên-stack: semantic cũ phải còn nguyên (menu nhận result, profile cộng EXP, settings lái locale, onboarding chỉ hiện một lần) — kiểm cả phía "người dùng không nhận ra đã đổi".

EXPECTED STATE SAU BÀI NÀY (đỉnh M19 — mọi lớp phải còn nguyên):
- DATA (bài 2): `GamePhase` 6 giá trị; `GameDialogState` sealed 6 variant; `GameScreenUiEvent` + 2 event; `GameSessionState` 9 field + `initial` + `copyWith`/`clearSelectedAnswer`; `GameQuizQuestionData` 8 field + `GameQuestionExplanationData` + `GameQuestionDifficulty`; bank `gameSample*` 15 câu; `gameMoneyLadderLevels` 15 + safe-haven 5/10/15; `GameResult.earnedAmount`; `applyGameResult` dùng `earnedAmount`; ARB key mới (`moneyLadderTitle`, `exitGame*`, `aiExplanationsTitle`, `understandButton`, `congratulationsTitle`, `youEarnedLabel`, `playAgainButton`, `menuButton` — không còn key cũ); file cũ `quiz_question*`/`quiz_questions*` + test cũ ĐÃ XOÁ.
- MAPPER (bài 3): `game_screen_data.dart` (GameAnswerState, GameMoneyData String-amount, GameQuestionData, GameAnswerOptionData, GameTimerData clamp+mm:ss); `support/game_money_formatter.dart`; `support/game_money_ladder_mapper.dart` (`calculateGameWalkAwayAmount` + `buildGameMoneyLadderItems` reversed); `game_screen_presentation_mapper.dart` chữ ký field lẻ + `_answerState` phase→màu.
- VM (bài 4): `GameScreenViewModel extends ChangeNotifier` — 3 const delay/time; `questions` injectable; `_events` broadcast; `Timer?`/`_isDisposed`/`_state`; `screenData`/`uiEvents`/`dialogState`/`state`; `submitAnswer`/`showMoneyLadder`/`showConfirmExit`/`startNewGame` (token đơn điệu)/`dismissDialog` router/`_onRevealElapsed`/`_onExplanationElapsed`/`_loadNextQuestionOrVictory`/`_endGame`/`_startTimer`/`_stopTimer`/`_tick`/`_schedule`(token+disposed guard)/`dispose`/`buildGameResult` switch — tất cả như checkpoint bài 4.
- SCREEN (bài 5): `GameScreen` stateless + injection; `_GameScreenEventBridge` (didChangeDependencies read + `_attachViewModel` idempotent + post-frame start/dialog-catchup + `_dialogOpen` + `_handleUiEvent` post-frame + `_showCurrentDialog` với nhánh `action==null` re-open/dismiss + `_handleRouteBack` theo variant + `PopScope canPop:false`); `_GameDialogHost` trả enum action; `lib/navigation/app_navigation_controller.dart` (navigatorKey + `openGame` → `Future<GameResult?>` + `goBack` canPop-guard); `main.dart` portraitUp + controller trong `AppDependencyScope` + `MaterialApp.navigatorKey`; `menu_screen.dart` `await openGame()`.
- TEST: `game_sample_questions_test` (7), `sealed_state_test` viết lại (6 variant), `game_screen_presentation_mapper_test` (4), `game_screen_view_model_test` (17 FakeAsync), `test/widgets/game_screen_test.dart` mới (~10 widget + nav-controller harness); `fake_async` trong dev-deps; `localizedTestApp` có param `navigatorKey`.
- `flutter analyze` sạch; `flutter test` → **126/126** (STRICT); `flutter build web` thành công.
- Tự làm `GameRatingDialog` (OPTIONAL — có thì variant + `showRating` + nhánh dismiss + test; KHÔNG tính thiếu nếu không làm).
- SEMANTIC CŨ GIỮ NGUYÊN (STRICT regression): menu `openGame` + `applyGameResult` nhận `GameResult` áp profile (EXP/tiền cập nhật); settings dialog + `languageCode` lái locale (M17 test vẫn xanh); onboarding overlay gate FutureBuilder vẫn hiện đúng một lần (M18 test vẫn xanh); `onboarding_completed: true` trong test host còn nguyên.

INVARIANTS NỀN — chưa đến, KHÔNG được có:
- KHÔNG `GameDialogLayer`/dialog trong `Stack` (M21); KHÔNG lifeline (`visibleOptionTexts`, `audiencePercentiles`, `usedFeatureButtons`, `featureButtons`, `GameConfirmWalkAwayDialog`/`GameAudiencePollDialog`/`GameAIAssistantDialog`) (M20); KHÔNG `GameShareResultEvent`/share (M27); KHÔNG VM-side save profile / `hasSavedResult` / `openGame` trả `Future<void>` (M22); KHÔNG `DreChangeNotifier`/reducer/action/effect (M26).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`/`AHEAD_RISKY` theo mức; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. M20 gắn lifelines vào cùng state machine — chưa chấm.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m19/06
PROJECT_ALIGNMENT: ON_TRACK | NEEDS_FIX | DIVERGED | BLOCKED
COURSE_POSITION: ON_TRACK | BEHIND | AHEAD_COMPATIBLE | AHEAD_RISKY
READY_FOR_NEXT_LESSON: YES | YES_AFTER_FIXES | NO
VERIFICATION_PERFORMED:
WHAT_MATCHES:
GAPS:
AHEAD_OF_COURSE:
DIVERGENCES:
REQUIRED_FIXES_BEFORE_CONTINUING:
EVIDENCE: file/symbol → observation
FILES_MODIFIED_BY_REVIEW: NONE
```
