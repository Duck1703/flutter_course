## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m19/05 — "Màn hình mới: provider + event bridge + PopScope" (GameScreen stateless tạo scope VM, bridge subscribe uiEvents → showDialog/pop, PopScope route back vào VM, AppNavigationController + navigatorKey, khóa dọc; game chơi được thật).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. `showDialog` là SCAFFOLD CỐ Ý tới M21 (`GameDialogLayer` trong Stack là bài sau) — không tính thiếu; `openGame` trả `Future<GameResult?>` (pop-result transport, retire M22) — không tính diverge.

EXPECTED STATE SAU BÀI NÀY:
- `lib/screens/game_screen.dart` REBUILT (STRICT không còn stub): `class GameScreen extends StatelessWidget` với `final GameScreenViewModel? viewModel` (test-injection); build → VM tiêm ? `ChangeNotifierProvider.value(value: vm)` : `ChangeNotifierProvider(create: (_) => GameScreenViewModel()..startNewGame())`, child `_GameScreenEventBridge` (STRICT 2 nhánh + `..startNewGame()` trong create).
- `_GameScreenEventBridge` Stateful (STRICT — widget duy nhất giữ lifecycle): `_navigationController`, `_viewModel`, `_uiEventSubscription`, `_dialogOpen` — KHÔNG field game nào khác trong State; `didChangeDependencies` → `context.read<AppNavigationController>()` + `_attachViewModel(context.read<GameScreenViewModel>())` (STRICT read ở didChangeDependencies không phải build); `_attachViewModel` guard `==` idempotent + cancel sub cũ + `viewModel.uiEvents.listen(_handleUiEvent)` + `addPostFrameCallback`: VM `phase==notStarted && dialogState is Hidden` → `startNewGame()` (cho VM tiêm test), else dialog mở sẵn → `_showCurrentDialog()` (broadcast không buffer — STRICT catch-up); `dispose` cancel sub.
- `_handleUiEvent` (STRICT): `GameNavigateToMenuEvent → _navigationController?.goBack(_viewModel?.buildGameResult())`; `GameDialogRequested → addPostFrameCallback → unawaited(_showCurrentDialog())` (STRICT post-frame — push route giữa didChangeDependencies = crash).
- `_showCurrentDialog` (STRICT): `_dialogOpen` chống chồng; `dialogState is Hidden → return`; `showDialog<_GameDialogAction>(barrierDismissible: false, builder: _GameDialogHost(dialog, l10n))`; `action == null` (back pop dialog) → ladder/Ended/Victory → MỞ LẠI dialog, còn lại → `dismissDialog()` (STRICT nhánh null — thiếu = terminal dialog thoát chui); action switch → `dismiss`/`backToMenu`/`playAgain` method VM.
- `_handleRouteBack` (STRICT theo dialogState): `GameDialogHidden → showConfirmExit()`; `GameMoneyLadderDialog | GameEndedDialog | GameVictoryDialog → BỎ QUA` (bắt buộc nút); còn lại → `dismissDialog()`. `PopScope(canPop: false, onPopInvokedWithResult: (didPop,_) { if (!didPop) _handleRouteBack(); })` bọc Scaffold (STRICT — KHÔNG WillPopScope).
- `_GameDialogHost` trả `Navigator.pop(_GameDialogAction.x)` — dialog widget THUẦN không gọi VM (STRICT enum action → bridge biên dịch); switch kiệt hợp variant: ladder render items (đảo, isCurrent/isSpecial đánh dấu), explanation render question/correctAnswer/explanation, terminal render earnedAmount + nút.
- `lib/navigation/app_navigation_controller.dart` (STRICT): `GlobalKey<NavigatorState> navigatorKey`; `Future<GameResult?> openGame()` push `MaterialPageRoute<GameResult>(GameScreen())`; `void goBack<T extends Object?>([T? result])` — `if (_navigator.canPop()) _navigator.pop(result)`; `_navigator` getter throw `StateError` khi chưa attach (STRICT `GameResult?` result transport — M22 mới retire).
- `lib/main.dart` (STRICT): `await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])` trong `main()` trước `runApp`; `AppNavigationController()` tạo + truyền vào `AppDependencyScope` (field `navigationController` REQUIRED mới); `MaterialApp(navigatorKey: context.read<AppNavigationController>().navigatorKey, ...)` — vẫn trong StreamBuilder locale của M17.
- `menu_screen.dart`: `Navigator.push(MaterialPageRoute(...))` → `await navigationController.openGame()` (STRICT); `applyGameResult` giữ nguyên.
- `test/widgets/game_screen_test.dart` REWRITTEN ~10 widget test (STRICT): harness `Provider<AppNavigationController>.value(value: nav, child: localizedTestApp(navigatorKey: nav.navigatorKey, home: GameScreen(viewModel: vm)))` — `localizedTestApp` đã được mở rộng nhận `navigatorKey` param; coverage intro ladder→playing+timer, tap→pending→reveal→explanation→next, back theo variant (intro/terminal bỏ qua, không-dialog→confirm-exit, confirm→đóng), ✕→confirm-exit→THOÁT→GameResult, victory/gameOver dialog.
- `flutter analyze` sạch; `flutter test` → **126/126** (STRICT 116 + 10); `flutter run` game chơi được: intro → 15 câu → pause khi dialog → victory/gameOver.
- KHÔNG `GameDialogLayer`/`Stack` dialog layer (M21); KHÔNG lifeline bar (M20); KHÔNG share (M27).

INVARIANTS NỀN:
- `GameScreenViewModel` + 17 test (bài 4); data+mapper (bài 2–3); StreamBuilder locale `main.dart` (M17); onboarding overlay scope trong menu Stack (M18 — vẫn còn); settings M16; `localizedTestApp` (M17 — giờ có navigatorKey param); fake repos M14.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m19/05
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
