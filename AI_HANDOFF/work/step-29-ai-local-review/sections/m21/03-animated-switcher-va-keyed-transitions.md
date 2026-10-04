## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m21/03 — "AnimatedSwitcher & ValueKey — transition theo variant" (bọc child layer bằng AnimatedSwitcher + ValueKey(dialog.runtimeType) + transitionBuilder fade/slide + disableAnimations; chỉ thêm motion, KHÔNG đổi rule Bài 2; vẫn chưa mount).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Layer VẪN chưa mount trong `game_screen.dart` (BÀI 4) — app chạy không đổi, chỉ test riêng chứng minh motion.

EXPECTED STATE SAU BÀI NÀY:
- `lib/widgets/game/game_dialog_layer.dart` `build()` (STRICT): `final motionDuration = MediaQuery.of(context).disableAnimations ? Duration.zero : MenuTokens.dialogMotionLong;` + `Positioned.fill → IgnorePointer(ignoring: dialog is GameDialogHidden) → AnimatedSwitcher(duration: motionDuration, reverseDuration: motionDuration, switchInCurve: Curves.easeOutCubic, switchOutCurve: Curves.easeInCubic, transitionBuilder: _buildTransition, child: _layerChild(canDismissFromBackdrop))` — switcher bọc TRONG IgnorePointer, backdrop rules giữ nguyên.
- `_layerChild(bool canDismiss)` (STRICT): hidden → `const SizedBox.expand(key: ValueKey('game-dialog-hidden'))`; variant → `SizedBox.expand(key: ValueKey(dialog.runtimeType), child: _DialogBackdrop(onDismiss: canDismiss ? onDismiss : (){}, child: _dialogBody()))` — key theo `runtimeType` KHÔNG phải payload/index/ObjectKey (sai key = dialog animate lại khi data đổi); `SizedBox.expand` (KHÔNG shrink — transition cần vùng full để vẽ).
- `_buildTransition(Widget child, Animation<double> animation)` (STRICT): `slideOffset = child.key == const ValueKey<Type>(GameMoneyLadderDialog) ? MenuTokens.spacingMd : MenuTokens.spacingSm` (ladder trượt xa hơn); `AnimatedBuilder(animation:, child:, builder:)` với `progress = animation.value.clamp(0,1).toDouble()`; `FadeTransition(opacity: animation, child: Transform.translate(offset: Offset(0, slideOffset*(1-progress)), transformHitTests: false, child: child))` — `transformHitTests: false` (STRICT — nút bấm theo vị trí đích, không lệch khi đang trượt).
- `_dialogBody()`/`_canDismissFromBackdrop`/`_isTerminalDialog`/`_DialogBackdrop` KHÔNG đổi so với Bài 2 (STRICT — chỉ thêm motion).
- `test/widgets/game_dialog_layer_test.dart` (STRICT +3 test → đủ ~6): keyed-fade — pump Hidden→ConfirmExit, `find.byType(AnimatedSwitcher) findsOneWidget` + `find.byType(FadeTransition) findsWidgets` + `pump(dialogMotionLong)` → 'Thoát trò chơi?' + `find.byKey(ValueKey('game-dialog-backdrop-filter'))` (backdrop có key này trong `_DialogBackdrop`); reduced-motion — `_TestSurface(disableAnimations: true)` ConfirmExit→Hidden → outgoing biến mất NGAY (text + backdrop key đều findsNothing, không cần pump duration); outgoing lingers — ConfirmExit→Hidden sau entry, `pump(100ms)` vẫn thấy text (đang fade out), `pump(dialogMotionLong)` mới mất.
- `flutter analyze` sạch; `flutter test` → **153/153** (STRICT 150 + 3).
- KHÔNG ĐƯỢC có (chưa đến): layer mount/`PopScope`/`_handleRouteBack`/`_afterExit`/xóa `GameDialogRequested`/`showDialog`/`_GameDialogHost` trong `game_screen.dart` (BÀI 4); `ValueKey` theo payload như `ValueKey('${runtimeType}-$isLoading')` (DIVERGED — AI loading→result sẽ fade-out-in, sai senior); `onShare` (M27); shell visual (M28).

INVARIANTS NỀN:
- Toàn bộ Bài 2: 9 view + callback tên senior + `_GameDialogCard` + backdrop ClipRect/BackdropFilter/opaque + tap-outside rules; `_GameDialogHost`/`showDialog`/`_dialogOpen`/`GameDialogRequested` trong màn + VM CÒN NGUYÊN (cắt BÀI 4); `GameDialogState` 9 variant; M19–M20 lifeline/VM/timer; M14–M18 nền.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m21/03
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
