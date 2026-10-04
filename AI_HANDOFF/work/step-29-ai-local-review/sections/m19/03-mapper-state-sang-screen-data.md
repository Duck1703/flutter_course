## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m19/03 — "Mapper thuần: state → GameScreenData" (DTO hiển thị + presentation mapper thuần + 4 unit test; game_screen vẫn stub).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. `game_screen.dart` VẪN là stub — mapper chưa có consumer widget (VM bài 4 mới gọi nó).

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/game/game_screen_data.dart` (STRICT): `enum GameAnswerState {idle, selected, correct, incorrect}`; `GameMoneyData{String amount, int animationTrigger}` — amount là String ĐÃ FORMAT (không int); `GameQuestionData{questionText, currentQuestionIndex, totalQuestions, category, difficulty(String), int get displayQuestionNumber => currentQuestionIndex+1}`; `GameAnswerOptionData{answerLabel 'A'..'D', answerText, GameAnswerState state}`; `GameTimerData{totalTime, remainingTime, double get progress (clamp 0..1), String get formattedTime 'mm:ss' clamp}`; `GameScreenData{money, question, List<GameAnswerOptionData> answers, timer}`.
- `lib/view_models/game/support/game_money_formatter.dart`: `formatGameMoney(int)` → `'$20,000'` (dấu phẩy ngăn nghìn).
- `lib/view_models/game/support/game_money_ladder_mapper.dart` (STRICT verbatim senior): `int calculateGameWalkAwayAmount({required guaranteedAmount, required moneyEarned})` = `guaranteedAmount > 0 ? max(guaranteed, moneyEarned) : 0` (không phải moneyEarned−guaranteed); `List<GameMoneyLadderItemData> buildGameMoneyLadderItems({required currentQuestionIndex})` — `gameMoneyLadderLevels.reversed`, `index=level.level`, `amount` formatted, `isCurrent: level == currentQuestionIndex+1`, `isSpecial: isSafeHaven`.
- `lib/view_models/game/game_screen_presentation_mapper.dart` (STRICT): `GameScreenData buildGameScreenPresentation({required List<GameQuizQuestionData> questions, required int questionIndex, required int moneyEarned, required int moneyAnimationTrigger, required Duration totalTime, required Duration remainingTime, required GamePhase phase, required String? selectedAnswer})` — chữ ký FIELD LẺ (không nhận GameSessionState — STRICT); `_answerState`: `answeredPending` → `optionText==selectedAnswer ? selected : idle`; `answeredRevealed` → `correctOption→correct`, `selectedAnswer→incorrect`, else `idle`; mọi phase khác → `idle` (STRICT luật màu — widget KHÔNG tự suy).
- `test/game_screen_presentation_mapper_test.dart` ~4 test (STRICT — không pump widget): playing→idle hết+counter/meta; pending→chỉ ô chọn selected; revealed→xanh/đỏ/idle; timer formattedTime/progress/format tiền.
- `flutter analyze` sạch; `flutter test` → **99/99** (STRICT 95 + 4).
- KHÔNG có `game_screen_view_model.dart`, `app_navigation_controller.dart`, screen mới (bài 4–5 — sớm = AHEAD_COMPATIBLE); KHÔNG `visibleOptionTexts`/`audiencePercentiles`/`usedFeatureButtons`/`featureButtons` trong mapper/DTO (M20 — sớm = AHEAD).

INVARIANTS NỀN:
- `GameSessionState`+`GamePhase`+dialog family+`GameScreenUiEvent` (bài 2); question model + 15-câu bank + `gameMoneyLadderLevels` (bài 2); `game_screen.dart` vẫn stub; menu/settings/onboarding/l10n M14–M18.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m19/03
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
