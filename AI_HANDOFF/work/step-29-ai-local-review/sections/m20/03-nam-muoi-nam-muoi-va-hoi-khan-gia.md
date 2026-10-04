## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m20/03 — "50:50 và Hỏi khán giả: từ state tới thanh nút" (nối 2 lifeline đầu xuyên stack: mapper đọc state mới + sản xuất featureButtons 2 nút; VM guard + mutation; bar + dialog poll + ô trống; AI/walk-away là BÀI 4 — chưa chấm).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Bar ở checkpoint này chỉ có **2 nút** (fiftyFifty + audiencePoll); arm `aiAssistant`/`walkAway` trong `handleFeatureClick` đang `break` có chủ đích — BÀI 4 mới nối. `GameFeatureButton` dùng IconData phẳng + AnimatedOpacity (visual painter/SVG đến M28) — không tính diverge.

EXPECTED STATE SAU BÀI NÀY:
- DATA (STRICT): `GameScreenData` có `required featureButtons` (đã thêm — mapper giờ truyền); `GameAudiencePollDialog extends GameDialogState({required List<GameAudiencePollItemData> items})` variant thứ 7 — `GameDialogState` giờ 7 variant.
- MAPPER `buildGameScreenPresentation` (STRICT): chữ ký +4 named-required `visibleOptionTexts, audiencePercentiles, usedFeatureButtons, canWalkAway`; `_buildAnswers` đọc `visibleOptionTexts[index]` (KHÔNG `question.options` trực tiếp) + `answerLabel: String.fromCharCode(65+i)` + `audiencePercentile: audiencePercentiles?[optionText]`; `_answerState` check `optionText.isEmpty → idle` TRƯỚC mọi arm (lớp phòng thủ 1); `_buildFeatureButtons` trả đúng 2 nút: `fiftyFifty` (`Icons.percent`, '50:50') + `audiencePoll` (`Icons.people`, 'Ask the Audience'), `isEnabled = canPlay && !used.contains(type)` qua `_feature` (STRICT list 2 — AI/walk-away chưa vào); `import material.dart` cho Icons.
- VM `game_screen_view_model.dart` (STRICT): `screenData` truyền đủ 4 arg mới + `canWalkAway: _state.guaranteedAmount > 0` (STRICT gate hiện-nút dùng guaranteed); `startNewGame` seed `visibleOptionTexts: questions.first.options` (STRICT — thiếu → RangeError); `_loadNextQuestionOrVictory` emit `visibleOptionTexts: questions[index+1].options` + `clearAudiencePercentiles: true` — `usedFeatureButtons` KHÔNG reset khi sang câu (STRICT dùng-một-lần cả ván); `submitAnswer` guard `answerText.isEmpty` (đã có từ M19, giờ là lớp phòng thủ 3 sống).
- VM lifeline API (STRICT): `handleFeatureClick(GameFeatureButtonData button)` — `!button.isEnabled → return` + `!_canUseFeature(type) → return` (hai lớp belt-and-suspenders) → switch: `fiftyFifty→_useFiftyFifty()`, `audiencePoll→_showAudiencePoll()`, `aiAssistant|walkAway→break` (BÀI 4), `exitGame→showConfirmExit()`; `_canUseFeature` thứ tự (STRICT): `phase != playing → false` trước → `walkAway → _walkAwayAmount(_state) > 0` → `exitGame → true` → `!used.contains(type)`; `_useFiftyFifty` emit `visibleOptionTexts: applyGameFiftyFifty(question)` + `usedFeatureButtons: {...used, fiftyFifty}` — KHÔNG `_stopTimer` (STRICT — không dialog nên timer chạy tiếp); `_showAudiencePoll` — `buildGameAudiencePoll` + `_stopTimer()` + emit `audiencePercentiles` + `usedFeatureButtons` + `dialogState: GameAudiencePollDialog(items: _audiencePollItems(_state, percentiles))` + `_emitEvent(GameDialogRequested())` (STRICT pause timer vì có dialog); `_audiencePollItems` build từ `visibleOptionTexts` — ô `''` → `0%` (STRICT).
- UI `game_screen.dart` (STRICT): `_GameFeatureBar(buttons: data.featureButtons, onPressed: viewModel.handleFeatureClick)` dưới lưới đáp án — render DATA-DRIVEN không hardcode nút; `_GameFeatureButton` = `Semantics(button, enabled, label)` + `GestureDetector(onTap: isEnabled ? onPressed : null)` + `AnimatedOpacity(0.38 khi disabled)` + `Icon(data.icon)` (IconData phẳng — KHÔNG painter/SVG); `_labelFor` switch type → `l10n.*SemanticLabel` keys; `_AnswerOption` `onTap: option.answerText.isEmpty ? null : onTap` (lớp phòng thủ 2 — ô trống VẪN RENDER, không `SizedBox.shrink`); `_content` arm `GameAudiencePollDialog(:items)` = label + `LinearProgressIndicator(value: progress)` + `'NN%'`; `_title` arm → `l10n.audienceHelpTitle`; `_actions` arm → `[understandButton → close()]` (STRICT kiệt hợp — thiếu arm là compile error).
- TEST (STRICT): `sealed_state_test` thêm arm `GameAudiencePollDialog` (7 variant); `game_screen_presentation_mapper_test` builder +4 param + ~2 test mới (ô rỗng→idle + percentile lookup; featureButtons 2 nút + used→disabled); `game_screen_view_model_test` +~6 test (50:50 xóa+single-use+ô rỗng không submit; reset sang câu texts mới nhưng used giữ; poll→dialog 4 items+68% easy+timer pause+dismiss resume; non-playing chặn mọi feature); `test/widgets/game_screen_test.dart` +2 test (bar 2 nút, tap % xóa 2 ô + nút tắt; poll dialog 4 hàng + ĐÃ HIỂU đóng); `pumpGameScreen` helper đã cập nhật `..startNewGame()` trên VM tiêm (STRICT — thiếu = RangeError frame đầu).
- `flutter analyze` sạch; `flutter test` → **141/141** (STRICT 131 + 6VM + 2mapper + 2widget).
- KHÔNG có `_showAIAssistant`/`_showConfirmWalkAway`/`confirmWalkAway`/`resolvedResult` set (bài 4 — sớm = AHEAD); KHÔNG nút `aiAssistant`/`walkAway` trong bar (Icons.auto_awesome/emoji_events absent = ĐÚNG); `GameDialogState` chưa có 2 variant kia (bài 4 — có sớm = switch đỏ); KHÔNG `ListenableBuilder` trong `_GameDialogHost` (bài 4 — snapshot `dialog:` vẫn đúng).

INVARIANTS NỀN:
- 4 field lifeline + `copyWith` 3-cờ (bài 2); `GameFeatureButtonType` 5 giá trị + `GameFeatureButtonData` + `audiencePercentile` (bài 2); helper thuần + 5 test (bài 2); 12 key ARB (bài 2); VM guards + timer + flowToken + dismissDialog router + `buildGameResult` (M19); `_GameScreenEventBridge` + `PopScope` + `action==null` re-open (M19); menu/settings/onboarding/l10n M14–M18.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint (3+ nút bar, AI flow, walk-away) → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m20/03
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
