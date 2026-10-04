## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m28/04 — "Trigger-based motion — số tiền đếm nhảy + reduce-motion" (`animationTrigger` int-gate: animate CHỈ khi trigger TĂNG — `> oldTrigger && duration > zero` → `forward(from:0)`; amount đổi không-trigger → `value = 1` snap; interpolated digits `_intAmount`/`_AmountTemplate`/`_formatGrouped`; glitch cyan/magenta `ShaderMask`+`Transform.translate`; `GameMoneyAmount` cha đọc `MediaQuery.disableAnimations → Duration.zero` — honor (khác pulse B3 cố ý bỏ qua); ladder CTA `TextButton.styleFrom`/`shrinkWrap`/`WidgetStatePropertyAll` + ladder dialog `LayoutBuilder`/`FittedBox`; +6 test → 276).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Money/ladder chưa có consumer trong screen là ĐÚNG (BÀI 5–6 wire).

EXPECTED STATE SAU BÀI NÀY:
- `lib/widgets/game/money/game_money_amount_motion.dart` (FILE MỚI, STRICT verbatim ~196 dòng): `class _GameMoneyAmountMotionState extends State<…> with SingleTickerProviderStateMixin` (STRICT Single — một controller); `late final AnimationController _controller` khởi tạo trong `initState` `AnimationController(vsync: this, duration: _motionDuration, value: 1)` (STRICT `value: 1` — mount "đã settle", không nhảy lúc init); `_countStart`/`_countEnd`/`_amountTemplate` state; `didUpdateWidget(covariant old)` — `_controller.duration = _motionDuration` + `shouldAnimate = widget.animationTrigger > oldWidget.animationTrigger && widget.duration > Duration.zero` (STRICT `>` — `!=`/`>=` = DIVERGED: reset-về-0 không phải trigger) → `forward(from: 0)` + update `_countStart`/`_countEnd`/`_amountTemplate`; else `widget.amount != oldWidget.amount → _controller.value = 1` snap; `Duration get _motionDuration => widget.duration == Duration.zero ? Duration.zero : const Duration(milliseconds: 260)` (STRICT `widget.duration` chỉ là zero/non-zero GATE — duration thật cố định 260ms); `build` — `widget.duration == Duration.zero → _amountText(amount: widget.amount)` phẳng; else `AnimatedBuilder(animation: _controller)` → `progress = Curves.easeOutCubic.transform(_controller.value)` + `amount = _displayAmount(progress)` + `intensity = (1-progress).clamp(0,1)` + `Stack(clipBehavior: Clip.none, children: [if (intensity > 0) ..._glitchLayers(amount, intensity), _amountText(key: 'game-money-amount-text', amount: amount)])`; `_displayAmount(progress)` — `value >= 1 → widget.amount` đích-chuỗi; else `_amountTemplate.format(_countStart + delta.round())`; `_AmountTemplate.fromAmount`/`_intAmount`/`_formatGrouped` — interpolated INT digits giữ `prefix`/`suffix` (STRICT — tween chuỗi = DIVERGED); `_glitchLayers` — hai `ShaderMask(blendMode: srcIn, shaderCallback:)` + `Transform.translate` cyan `0x9900E5FF` (3i, -0.8i) + magenta `0x99FF00FF` ngược; `dispose()` — `_controller.dispose()`.
- `lib/widgets/game/money/game_money_amount.dart` (FILE MỚI, STRICT verbatim ~98 dòng): `duration = MediaQuery.of(context).disableAnimations ? Duration.zero : AppTokens.motionMedium` (STRICT cha đọc MediaQuery — con chỉ biết zero/non-zero); `Semantics(button: onTap != null, label: l10n.prizeAmountSemanticLabel(data.amount), onTap: onTap)` + `ExcludeSemantics(GestureDetector(opaque, onTap: onTap, child: _MoneyPill(data: data, duration: duration)))`; `_MoneyPill` — `DecoratedBox` vàng `_yellow500` + 2 `BoxShadow` + `ClipRRect` bọc `Stack` (`Positioned.fill _MoneyPillGlow` + `GameMoneyAmountMotion(data.amount, data.animationTrigger, duration)` giữa).
- `lib/widgets/game/money/game_money_ladder_cta_button.dart` (FILE MỚI, STRICT verbatim ~109 dòng): `TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap, overlayColor: WidgetStatePropertyAll(…))` — CTA 'UNDERSTAND'/'ĐÃ HIỂU' trong ladder dialog (STRICT shrinkWrap bỏ min-48).
- `lib/widgets/game/money/game_money_ladder_dialog.dart` (FILE MỚI, STRICT verbatim ~209 dòng): `LayoutBuilder` + `FittedBox(fit: BoxFit.scaleDown)` co bảng theo chiều cao; title `l10n.moneyLadderTitle.toUpperCase()` (STRICT — nguồn 'THANG TIỀN THƯỞNG' HOA mà test assert sau này); `_LadderItem` private class RIÊNG của file (STRICT không phải `GameDialogMoneyRow` — cái đó BÀI 5; nhầm tên = DIVERGED).
- `test/widgets/game_money_amount_test.dart` (FILE MỚI, STRICT verbatim 6 case): 'renders centered pill-only amount display', 'keeps tap and semantics contract stable' (`prizeAmountSemanticLabel` + `tester.getSemantics`/`matchesSemantics` đầu tiên), 'counts smoothly and glitches when animation trigger increases' (midpoint ≠ đầu/cuối + glitch tồn tại → settle `$2,000` + glitch mất), 'updates amount without glitch when trigger is unchanged', 'updates amount without glitch when trigger resets' (1→0 → snap `$0`), 'skips motion when reduced animations are requested' (`MediaQueryData(disableAnimations: true)` seam → `$2,000` ngay).
- `flutter analyze` sạch; `flutter test` → **276/276** (STRICT 270 + 6).
- KHÔNG ĐƯỢC có (chưa đến): `GameMoneyAmount`/`Ladder*` gọi trong screen/dialog-layer (BÀI 5–6); `game_answer_option*`/`game_question_panel`/`game_audience_poll_row`/dialog-shell+views (BÀI 5); `game_feature_button*`/`game_screen_body`/GameScreen rewrite/iconAsset (BÀI 6); `animationTrigger` sản sinh từ widget (widget chỉ đọc — reducer/VM M19–M26 đã emit); `>=`/`!=` thay `>` trong gate (reset không phải trigger — DIVERGED); assert mid-animation `$1,500` chính xác (brittle — test đúng assert ≠ đầu ≠ cuối); `disableAnimations` đọc trong `_GameMoneyAmountMotion` (cha đọc — DIVERGED tách phát-hiện/phản-ứng); `_LadderItem` dùng `GameDialogMoneyRow` (BÀI 5 shell); `widget.duration` đổi tốc độ đếm (nó chỉ gate — DIVERGED); `forward` không `from: 0` (giá trị cũ sót lại).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- Bài 1–3: tokens + 3 common + timer + topbar; `GameMoneyData.animationTrigger`/`amount` DTO M19 (widget render — không phát); `formatGameMoney` helper M19 (money widget tự `_intAmount` bóc — formatter giữ); `game_screen.dart` monolith + `_GameTopBar` scaffold; layer/views cũ + `_DialogShareButton`; `GameFeatureButtonData.icon: IconData`; M27 chain.

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. Gate `animationTrigger !=`/`>=` = DIVERGED (reset→animate lỗi); assert brittle midpoint-exact = NEEDS_FIX; controller `value` không khởi `1` = mount-glitch DIVERGED.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m28/04
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
