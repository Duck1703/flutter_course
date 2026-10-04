---
title: "Bài 5 · Bổ sung test parity & tổng kết M21"
description: "4 test còn lại của layer (terminal animate-out, ladder animate-out, terminal chặn tap-outside, cùng-variant-không-re-animate); bảng parity 9 variant đối senior; regression toàn suite; ranh giới M22."
sidebar:
  label: "Bài 5 · parity + tổng kết"
  order: 5
---

## Mục tiêu

- Thêm 4 test cuối cho `GameDialogLayer` — đủ bộ 10 test hành vi
  (port từ senior `game_dialog_layer_test.dart`).
- Đối chiếu bảng parity 9 variant: learner ↔ senior, từng quyết định
  scaffold/defer ghi rõ.
- Chạy regression đầy đủ, chứng minh hành vi game không đổi.
- Đóng gói mental model M21 và vạch rõ ranh giới với M22.

## Bạn đang ở đâu

- Bài 2–4: layer mount, animate, back đúng — nhưng coverage mới chỉ
  ở `Hidden`/`ConfirmExit`/`MoneyLadder`.
- Bài này phủ nốt các variant terminal + case "cùng variant đổi
  payload", rồi khóa milestone.

## Vì sao việc này quan trọng ngay bây giờ

M21 không chỉ "đổi cách render" — nó là **điểm hội tụ kiến trúc**
với senior: mọi refactor sau (M22 persistence, M26 DRE, M28 visual)
đều đứng trên layer này. Bảng parity + test đầy đủ là bằng chứng
"giống senior ở hành vi, khác ở chrome" thay vì cảm giác.

## Bạn đã biết gì

- Toàn bộ Bài 1–4 của M21.
- `pump(duration)` qua boundary animation (Bài 3–4).

## Dart/Flutter cần dùng

Không có construct mới — bài này củng cố: `GameEndedDialog`,
`GameVictoryDialog`, `GameAIAssistantDialog` payload swap, và đọc
`expect(find.byType(AnimatedSwitcher))` sau cùng.

## Senior project connection — bảng parity 9 variant

| Variant | Learner view | Senior widget | Tap-outside | Back | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| `GameDialogHidden` | `SizedBox.expand` (key "hidden") | cùng | — | mở confirm-exit | parity |
| `GameMoneyLadderDialog` | `GameMoneyLadderDialogView` | `GameMoneyLadderDialogView` | chặn | ignore | parity; shell-visual → M28 |
| `GameConfirmExitDialog` | `GameConfirmExitDialogView` | `GameConfirmExitDialogView` | dismiss | dismiss | parity |
| `GameConfirmWalkAwayDialog` | `GameConfirmWalkAwayDialogView` | `GameConfirmWalkAwayDialogView` | dismiss | dismiss | parity |
| `GameExplanationDialog` | `GameExplanationDialogView` | `GameExplanationDialogView` | dismiss | dismiss | parity |
| `GameAudiencePollDialog` | `GameAudiencePollDialogView` | `GameAudiencePollDialogView` | dismiss | dismiss | parity |
| `GameAIAssistantDialog` | `GameAIAssistantDialogView` | `GameAIAssistantDialogView` | dismiss | dismiss | loading↔result cùng key |
| `GameEndedDialog` | `GameEndedDialogView` | `GameEndedDialogView` | chặn | ignore | `_afterExit`; senior +`onShare` → M27 |
| `GameVictoryDialog` | `GameVictoryDialogView` | `GameVictoryDialogView` | chặn | ignore | `_afterExit`; senior +`onShare` → M27 |

Cột "Tap-outside" = `_canDismissFromBackdrop`; cột "Back" =
`_handleRouteBack`. Tên view trùng senior từng chữ (senior cũng gọi
`Game*DialogView`) — khác duy nhất: terminal view senior nhận thêm
`onShare` (`GameShareResultEvent`) — share là **M27** scope, cố ý
không port; shell-visual (gradient/sheen) → M28.

## Build it step by step

### Bước 1 — 4 test cuối

Trong `test/widgets/game_dialog_layer_test.dart`, **thêm** vào cuối
`main()`:

```dart
  testWidgets('dialog kết thúc animate-out xong mới rời cây', (
    tester,
  ) async {
    await _pumpTestSurface(
      tester,
      const _TestSurface(
        dialog: GameEndedDialog(earnedAmount: r'$0'),
      ),
    );
    await tester.pump(MenuTokens.dialogMotionLong);
    expect(find.text('Kết thúc'), findsOneWidget);

    await _pumpTestSurface(
      tester,
      const _TestSurface(dialog: GameDialogHidden()),
    );
    await tester.pump(const Duration(milliseconds: 100));
    // Outgoing còn trong cây suốt exit — nội dung terminal vẫn thấy.
    expect(find.text('Kết thúc'), findsOneWidget);

    await tester.pump(MenuTokens.dialogMotionLong);
    expect(find.text('Kết thúc'), findsNothing);
  });

  testWidgets('thang tiền animate-out xong mới rời cây', (tester) async {
    await _pumpTestSurface(
      tester,
      const _TestSurface(dialog: _moneyLadderDialog),
    );
    await tester.pump(MenuTokens.dialogMotionLong);

    await _pumpTestSurface(
      tester,
      const _TestSurface(dialog: GameDialogHidden()),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Thang tiền thưởng'), findsOneWidget);

    await tester.pump(MenuTokens.dialogMotionLong);
    expect(find.text('Thang tiền thưởng'), findsNothing);
  });

  testWidgets('tap ngoài KHÔNG đóng dialog kết thúc (bắt buộc chọn)', (
    tester,
  ) async {
    var dismissCount = 0;
    await _pumpTestSurface(
      tester,
      _TestSurface(
        dialog: const GameEndedDialog(earnedAmount: r'$0'),
        onDismiss: () => dismissCount++,
      ),
    );
    await tester.pump(MenuTokens.dialogMotionLong);

    await tester.tapAt(const Offset(8, 8));
    await tester.pump();
    expect(dismissCount, 0);
    expect(find.text('Kết thúc'), findsOneWidget);
  });

  testWidgets('cùng variant khác payload KHÔNG re-animate (key = '
      'runtimeType)', (tester) async {
    // AI loading→result: cùng GameAIAssistantDialog → AnimatedSwitcher
    // thấy ValueKey trùng → body đổi in-place, không cross-fade.
    // (`selectedAnswer`/`confidencePercentage`/`explanation` là
    // required — loading cũng truyền đủ, chỉ `isLoading` đổi.)
    await _pumpTestSurface(
      tester,
      const _TestSurface(
        dialog: GameAIAssistantDialog(
          selectedAnswer: '',
          confidencePercentage: 85,
          explanation: '',
          isLoading: true,
        ),
      ),
    );
    await tester.pump(MenuTokens.dialogMotionLong);
    expect(find.text('AI đang suy nghĩ...'), findsOneWidget);

    await _pumpTestSurface(
      tester,
      const _TestSurface(
        dialog: GameAIAssistantDialog(
          selectedAnswer: 'Đáp án A',
          confidencePercentage: 85,
          explanation: 'gợi ý',
        ),
      ),
    );
    // Body swap ngay trong cùng subtree của switcher — không tạo
    // outgoing mới, không cần chờ motion.
    expect(find.text('85%'), findsOneWidget);
    expect(find.text('AI đang suy nghĩ...'), findsNothing);
  });
```

Ba test đầu tài liệu hóa **exit-motion** (terminal + ladder cũng
animate-out) và **tap-lock** của terminal. Test cuối là bằng chứng
cho nguyên tắc key của Bài 3: cùng `runtimeType` → một widget duy
nhất trong cây, không outgoing.

### Bước 2 — Regression toàn suite

```bash
flutter analyze   # sạch
flutter test      # 157/157
flutter build web # PASS
```

**157** = 147 (M20) + 10 layer tests. Không một assertion cũ bị
làm lỏng — các sửa test ở Bài 4 là *đổi cách kiểm* (finder/timing)
cho cơ chế mới, hành vi assert giữ nguyên.

## Thử nghiệm — đoán trước khi chạy

:::note[PREDICT]
Thang tiền đang mở, user bấm back hệ thống. Sau 400ms: (a) ladder
đóng; (b) confirm-exit mở; (c) không gì đổi; (d) route pop về menu?
:::

<details><summary>Đáp án</summary>

(c) — `_handleRouteBack` nhánh `GameMoneyLadderDialog` trả ngay:
senior chặn back trên ladder (intro lẫn mid-game). Đóng ladder chỉ
bằng nút ĐÃ HIỂU → `dismissDialog()`. Đây là chỗ "back ≠ dismiss"
khác hẳn mental model route — bảng parity cột Back ghi rõ.

</details>

## Lỗi hay gặp

- **Assert terminal text bằng `findsNothing` ngay sau swap** —
  outgoing lingers, phải pump qua `dialogMotionLong`.
- **Quên `_moneyLadderDialog` shared const** — test ladder cần
  payload đầy đủ `items`; dùng fixture chung của file, không khai
  lại.

## Tự làm (PRODUCE)

:::note[Bài tập production — không merge]
Trên một **nhánh riêng** (`git checkout -b exercise/m21-sound-dialog`):
thêm variant thứ 10 `GameSoundSettingsDialog extends GameDialogState`
(chỉ cần `volume: double`), view `_GameDialogCard` có `Slider`, map
vào `_dialogBody()` của layer, và 2 test: render + tap-outside
dismiss được. Đây là exercise kiến trúc — **không merge** vào course
(không phải senior target); giá trị là đi đủ pipeline
state→view→layer→test một mình.
:::

<details><summary>Đáp án</summary>

```dart
// state file: final class GameSoundSettingsDialog extends
//   GameDialogState { final double volume; const
//   GameSoundSettingsDialog({required this.volume}); }
// views: GameSoundSettingsDialogView(data:, onDismiss:,
//   onVolumeChanged:) — _GameDialogCard + Slider(value:onChanged:)
// layer _dialogBody: GameSoundSettingsDialog() =>
//   GameSoundSettingsDialogView(data: dialog as ..., onDismiss:...)
```

Compile switch kiệt hợp sẽ *bắt* bạn thêm arm — đúng thiết kế
sealed. Back rule: thuộc nhánh dismiss mặc định (không phải ladder/
terminal) nên back đóng được miễn phí — nhận ra "policy mặc định
đúng" là dấu hiệu hiểu bảng.

</details>

## Kiểm tra hiểu biết

1. Tại sao test "cùng variant" assert `findsOneWidget` thay vì đo
   opacity? *(Bằng chứng đơn giản nhất cho "không re-animate": không
   có outgoing child — hai instance chỉ tồn tại khi switcher swap.)*
2. M21 đóng những khoảng senior-parity nào? *(dialog cơ chế
   route → in-tree; nâng lên 9-variant in-Stack; share
   vẫn M27 — *không* đóng ở đây.)*
3. Ranh giới M21/M22: nút MENU của terminal dialog hiện làm gì, và
   M22 sẽ đổi gì? *(Giờ: `goBack(GameResult)` — transport M10.
   M22: VM tự `GameSaveResult` vào repository trước khi pop; UI
   không còn mang result.)*

## Tổng kết M21 — mental model giữ lại

```text
GameDialogState (VM) ──render──> GameDialogLayer (Stack child cuối)
                                   │ Positioned.fill + IgnorePointer
                                   │ AnimatedSwitcher + ValueKey(type)
                                   │ _DialogBackdrop (blur + tap rule)
                                   └─ view theo variant (callback)
system back → PopScope(veto) → _handleRouteBack → VM quyết theo state
```

- Dialog không còn "đẻ ra route" — nó là **projection** của state
  trong cây; lifetime = lifetime của màn.
- Back không "đóng cái đang mở" — back là input cho máy trạng thái
  với bảng quyết định rõ ràng.
- Transition identity = `runtimeType` — một key per variant, payload
  đổi không animate lại.
- Terminal action chờ exit-motion (`_afterExit`) — không cắt giữa
  animation.

Những thứ *cố ý* chưa có: shell visual senior (M28), share (M27),
menu dialog layer (M29), persistence (M22 — bài tiếp theo).

## Checkpoint hoàn thành

- [ ] `flutter test` **157/157**, `flutter analyze` sạch,
  `flutter build web` PASS.
- [ ] Bảng parity 9 variant tự giải thích được không nhìn tài liệu.
- [ ] Nói được vì sao `GameDialogRequested` chết và ai thay nó.

## 🤖 AI Local — Kiểm tra project sau bài này (TỔNG HỢP M21)

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m21/05 — TỔNG HỢP M21 (4 test layer cuối → đủ bộ 10; bảng parity 9 variant đối senior; regression toàn suite 157/157 + build web; ranh giới M22).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`, `flutter build web` READ-ONLY (chỉ verify), `grep`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Exercise `GameSoundSettingsDialog` variant thứ 10 (trên nhánh riêng, KHÔNG merge) — có trên nhánh exercise là OK, có trong main/app code = AHEAD_RISKY. Không tính thiếu nếu không làm exercise.

EXPECTED STATE SAU BÀI NÀY (đỉnh M21 — toàn bộ layer phải nguyên vẹn):
- `test/widgets/game_dialog_layer_test.dart` (STRICT đủ ~10 test): 4 test mới — (a) `GameEndedDialog`→Hidden: `pump(100ms)` vẫn 'Kết thúc' (outgoing lingers), `pump(dialogMotionLong)` mới mất; (b) ladder→Hidden tương tự với 'Thang tiền thưởng' (fixture `_moneyLadderDialog` chung, không khai lại); (c) tap-outside KHÔNG đóng terminal: `tapAt(8,8)` → `dismissCount == 0` + 'Kết thúc' vẫn thấy; (d) cùng-variant-khác-payload KHÔNG re-animate: `GameAIAssistantDialog(isLoading:true)`→`isLoading:false` cùng runtimeType → '85%' hiện + 'AI đang suy nghĩ...' mất NGAY không cần pump duration (không outgoing).
- PARITY TABLE — kiểm chứng hành vi từng variant (semantic, đối chiếu code): Hidden→SizedBox.expand(key 'game-dialog-hidden'), back→confirm-exit; MoneyLadder→tap-outside CHẶN + back IGNORE (nút ĐÃ HIỂU duy nhất); ConfirmExit/WalkAway/Explanation/AudiencePoll/AIAssistant→dismiss cả 2 chiều; Ended/Victory→tap CHẶN + back IGNORE + `_afterExit` chờ motion.
- CƠ CHẾ (STRICT): `grep "GameDialogRequested" lib/` → 0 trong code; `grep "showDialog" lib/screens/game_screen.dart` → 0 call; `GameScreenUiEvent` còn 1 variant `GameNavigateToMenuEvent`; `PopScope(canPop:false)` + `onPopInvokedWithResult` → `_handleRouteBack` 3 nhánh; `Stack` cuối = `GameDialogLayer` trực tiếp đọc `viewModel.dialogState` (không qua event); `_afterExit` + `_terminalActionPending` + `unawaited`.
- REGRESSION (STRICT): `flutter analyze` sạch; `flutter test` → **157/157** (= 147 M20 + 10 layer); `flutter build web` PASS; KHÔNG một assertion cũ bị làm lỏng — sửa test Bài 4 là đổi CÁCH KIỂM (finder AlertDialog→view type, timing 300→400) không phải bỏ assert.
- HÀNH VI GAME GIỮ NGUYÊN (semantic): ✕ mở confirm-exit in-tree (không push route — back stack/URL không đổi); back trên confirm đóng; back trên game mở confirm; terminal dialog CHƠI LẠI/MENU animate-out xong mới pop; AI loading→kết quả cùng dialog không nhấp nháy; lifelines M20 hoạt động (poll pause timer, 50:50 single-use, walk-away `won:false`).
- KHÔNG ĐƯỢC có (chưa đến): `onShare`/`GameShareResultEvent` trong Ended/Victory view (M27 — senior có nhưng cố ý không port); VM-save/`GameSaveResult`/`hasSavedResult` thay transport (M22); level config/menu progress (M22); Supabase/leaderboard/auth/sync (M23–M25); DRE/reducer (M26); shell gradient/sheen/SVG (M28); menu dialog layer (M29); `GameDialogLayer` dùng cho menu settings (M29).

INVARIANTS NỀN:
- M20 đỉnh: 147 test nền còn nguyên, 5 lifelines, `resolvedResult`, `visibleOptionTexts`, mapper +4 params, feature bar; `GameDialogState` 9 variant; M19 VM/timer/flowToken/`_schedule`/`buildGameResult`/`PopScope` nền (giờ mở rộng); l10n/onboarding/settings/profile M14–M18; transport `goBack(GameResult)` M10 còn sống (retire M22).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`/`AHEAD_RISKY`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. Hai cơ chế dialog song song (layer + showDialog sót lại) = NEEDS_FIX.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m21/05
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
