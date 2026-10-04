## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m20/02 — "Nền data lifeline: state, dialog, helper thuần" (4 field state + enum/DTO nút + 3 helper thuần + 12 key ARB — KHÔNG đổi hành vi runtime; sealed variant + UI đến bài 3/4).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, chạy `flutter gen-l10n` để "sửa" output, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bài này ADDITIVE-ONLY: không variant sealed mới (chúng cần arm UI — đến bài 3/4), không `featureButtons` trên `GameScreenData` (đổi signature — bài 3), không method VM mới. Runtime y hệt M19 là ĐÚNG.

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/game/game_session_state_data.dart`: `final class GameAudiencePollItemData{option, percentage(String 'NN%'), progress(double 0..1)}` mới; `GameSessionState` thêm 4 field (STRICT): `List<String> visibleOptionTexts` (ctor gói `List.unmodifiable`), `Map<String,int>? audiencePercentiles` (gói `Map.unmodifiable` khi non-null — key = TEXT đáp án), `Set<GameFeatureButtonType> usedFeatureButtons` (gói `Set.unmodifiable`), `GameResult? resolvedResult`; `initial()` seed `visibleOptionTexts: const [], audiencePercentiles: null, usedFeatureButtons: const {}`; `copyWith` thêm 3 param + 2 cờ mới `clearAudiencePercentiles`, `clearResolvedResult` (tổng 3 cờ clear); `import 'game_screen_data.dart'` cho `GameFeatureButtonType`.
- `lib/data/game/game_screen_data.dart`: `enum GameFeatureButtonType {fiftyFifty, audiencePoll, aiAssistant, walkAway, exitGame}` (STRICT 5 giá trị); `class GameFeatureButtonData{GameFeatureButtonType type, IconData icon, String semanticLabel, bool isEnabled = true}` + `copyWith({bool? isEnabled})` (STRICT `IconData` — KHÔNG `String iconAsset`, learner chưa có SVG pipeline M28); `GameAnswerOptionData` thêm `final int? audiencePercentile` + `copyWith({answerText, state, audiencePercentile, clearAudiencePercentile})` (STRICT flag pattern); `GameScreenData` CHƯA có `featureButtons` (STRICT — có sớm = AHEAD vì phá signature trước mapper).
- `lib/view_models/game/support/game_lifeline_helper.dart` (STRICT verbatim): `List<String> applyGameFiftyFifty(question)` — DETERMINISTIC giữ `correctOption` + ô sai ĐẦU `firstWhere`, còn lại `''` (KHÔNG Random); `Map<String,int> buildGameAudiencePoll(question)` — đúng 68/52/42 theo easy/medium/hard, `_splitWrongAudience` 50%/32%/phần-dư tổng=100, map-comprehension keyed bằng text; `List<GameAudiencePollItemData> buildGameAudiencePollItems(answers)` — `audiencePercentile ?? 0` → `'$value%'` + `value/100`.
- `test/game_lifeline_helper_test.dart` (STRICT ~5 test): fifty-fifty giữ đúng+sai-đầu → `['W1','CORRECT','','']`; không mutate bank; poll easy 68 + wrongs [16,10,6] + tổng 100; medium 52/hard 42; items label+'NN%'+progress+null→0.
- ARB: 12 key mới cả 2 file (STRICT): `fiftyFiftySemanticLabel, askAudienceSemanticLabel, askAiSemanticLabel, walkAwaySemanticLabel, exitGameSemanticLabel, walkAwayTitle, walkAwayMessage, confirmWalkAwayButton, keepPlayingButton, aiAssistantTitle, audienceHelpTitle, aiThinkingMessage`; `AppLocalizations` regenerated có getter.
- `test/sealed_state_test.dart` KHÔNG đổi — `GameDialogState` vẫn 6 variant (STRICT — variant poll/AI/walk-away chưa thêm).
- `flutter analyze` sạch; `flutter test` → **131/131** (STRICT 126 + 5 helper).
- KHÔNG có `handleFeatureClick`/`_canUseFeature`/`_useFiftyFifty`/`_showAudiencePoll` trong VM (bài 3); KHÔNG `GameAudiencePollDialog`/`GameConfirmWalkAwayDialog`/`GameAIAssistantDialog` variant (bài 3/4 — có sớm = compile đỏ vì switch kiệt hợp thiếu arm → DIVERGED); KHÔNG lifeline bar trong `game_screen.dart` (bài 3); KHÔNG `resolvedResult` set ở đâu ngoài field (bài 4 mới dùng).

INVARIANTS NỀN:
- GameSessionState+phase+dialog-6+event+copyWith/clearSelectedAnswer (M19); VM + timer + flowToken + `buildGameResult` switch (M19); mapper + `GameAnswerOptionData` cũ (M19); menu/settings/onboarding/l10n M14–M18; `fake_async` dev-dep (M19).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m20/02
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
