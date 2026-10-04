## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m20/04 — "Hỏi AI và Dừng cuộc chơi: async mô phỏng + kết quả chốt" (AI 700ms loading→kết quả trong MỘT dialog; walk-away → phase victory nhưng resolvedResult.won=false; host ListenableBuilder live-read; bar hoàn thiện).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. AI là MÔ PHỎNG (Future.delayed + 85% fixed + aiHintMessage — senior cũng mô phỏng, KHÔNG có AI thật). `showDialog`+`ListenableBuilder` host là quá độ — `GameDialogLayer` trong Stack là M21. `resolvedResult` là interim carrier — VM-side save là M22.

EXPECTED STATE SAU BÀI NÀY:
- SEALED 9 VARIANT (STRICT đủ): thêm `GameConfirmWalkAwayDialog({required String currentAmount})` + `GameAIAssistantDialog({required String selectedAnswer, required int confidencePercentage, required String explanation, bool isLoading = false})` — `GameDialogState` = 9 variant khớp senior.
- VM (STRICT): `static const _aiAssistantDelay = Duration(milliseconds: 700)`; `_showAIAssistant` — `token = flowToken + 1` + `_stopTimer()` + emit `{...used, aiAssistant}` + `dialogState: GameAIAssistantDialog(selectedAnswer: '', confidencePercentage: 0, explanation: '', isLoading: true)` + `_emitEvent(GameDialogRequested())` + `_schedule(_aiAssistantDelay, token, _onAIAssistantElapsed)`; `_onAIAssistantElapsed` — guard `dialogState is! GameAIAssistantDialog → return` (STRICT — thiếu = kết quả trễ mở lại dialog đã đóng) + emit kết quả `selectedAnswer: question.correctOption, confidencePercentage: 85, explanation: question.explanation.aiHintMessage` — KHÔNG `_emitEvent` thứ hai (STRICT — một route hai nội dung); `_showConfirmWalkAway` guard `phase==playing && _walkAwayAmount>0` + stopTimer + `GameConfirmWalkAwayDialog(currentAmount: formatGameMoney(amount))` + event; `showConfirmWalkAway()` public wrapper; `confirmWalkAway` — emit `phase: victory` + `remainingTime: Duration.zero` + `resolvedResult: GameResult(questionsAnswered: index+1, correctAnswers: index, won: false, earnedAmount: amount)` (STRICT `won:false` — walk-away không phải thắng) + `GameVictoryDialog` + event; `buildGameResult()` = `_state.resolvedResult ?? GameResult(... won: false, earnedAmount: _walkAwayAmount(_state))` fallback (STRICT đọc bản chốt, không suy từ phase); `_endGame`/victory-arm/`backToMenu` cũng set `resolvedResult` tường minh; `handleFeatureClick` hai arm `aiAssistant→_showAIAssistant()` + `walkAway→_showConfirmWalkAway()` đã nối.
- MAPPER (STRICT): `_buildFeatureButtons` giờ `[fiftyFifty, audiencePoll, aiAssistant(Icons.auto_awesome, 'Ask AI')]` + `if (canWalkAway) buttons.add(walkAway(Icons.emoji_events, 'Walk Away'))` — walkAway chỉ HIỆN khi `canWalkAway` (guaranteedAmount>0), riêng guard bấm `_walkAwayAmount>0` (STRICT hai điều kiện khác nhau cố ý).
- HOST LIVE-READ (STRICT): `_GameDialogHost` giờ nhận `viewModel:` + `l10n:` (KHÔNG còn `dialog:` snapshot); `GameDialogState get dialog => viewModel.dialogState` + `ListenableBuilder(listenable: viewModel, builder: → AlertDialog(...))` bọc — emit thứ hai (AI result) rebuild route đang mở KHÔNG cần event mới; call-site `_showCurrentDialog` truyền `viewModel: viewModel, l10n: AppLocalizations.of(dialogContext)`; `_GameDialogAction` thêm `confirmWalkAway` + dispatch arm `→ viewModel.confirmWalkAway()` trong `_showCurrentDialog` switch.
- UI ARMS (STRICT): `_title` + `walkAwayTitle`/`aiAssistantTitle`; `_content` + `GameConfirmWalkAwayDialog` (message `walkAwayMessage` + `currentAmount`) + `GameAIAssistantDialog` (isLoading → `CircularProgressIndicator`+`aiThinkingMessage` : result → chip `selectedAnswer` + `'85%'` + `explanation`); `_actions` + walk-away `[keepPlayingButton→close(), confirmWalkAwayButton→close(confirmWalkAway)]` + AI `isLoading ? const [] : [understandButton→close()]` (STRICT loading KHÔNG có nút — chỉ back/dismiss).
- TEST (STRICT): `sealed_state_test` đủ 9 arm (poll+walkAway+AI); VM test +4 (AI loading→elapse(700ms)→kết quả correctOption/85/hint; đóng giữa loading → kết quả trễ bị bỏ dialogState vẫn Hidden; walk-away: trước haven nút ẩn+bấm tay chặn, sau 5 đúng → `GameConfirmWalkAwayDialog('$20,000')` → `confirmWalkAway` → `phase==victory` + `buildGameResult()=={won:false, earned:20000}` + walkAway KHÔNG ghi used); mapper assert đầy đủ (`canWalkAway:true` → 4 type theo thứ tự; not-playing → không walkAway); widget +2 (AI tap auto_awesome → loading → pump(800ms) → chip đúng + '85%' + hint; walk-away sau haven → confirm → 'Chúc mừng' + won=false, `find.descendant` cho `$20,000` trong AlertDialog); test bar cũ sửa `Icons.auto_awesome findsNothing → findsOneWidget`.
- `flutter analyze` sạch; `flutter test` → **147/147** (STRICT 141 + 4VM + 2widget); bar có 3 nút luôn (50:50, poll, AI) + nút walk-away hiện sau safe haven.
- KHÔNG `GameDialogLayer`/Stack layer (M21); KHÔNG VM-side save/`hasSavedResult`/`GameSaveResult` async op (M22); KHÔNG AI network call thật (không có milestone nào — senior cũng mô phỏng); KHÔNG `GameShareResultEvent` (M27).

INVARIANTS NỀN:
- Bar 2 nút bài 3 + `_feature`/`_buildFeatureButtons`/`_labelFor`; `handleFeatureClick`+`_canUseFeature` thứ tự (bài 3); `_useFiftyFifty`/`_showAudiencePoll`/`_audiencePollItems` (bài 3); `_GameScreenEventBridge` + post-frame + `action==null` re-open routing + `PopScope` (M19); `resolvedResult` field + `clearResolvedResult` flag (bài 2); VM timer/flowToken/`_schedule`/`dismissDialog` router (M19); menu/settings/onboarding/l10n M14–M18.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m20/04
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
