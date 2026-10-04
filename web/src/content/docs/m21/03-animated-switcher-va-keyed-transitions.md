---
title: "Bài 3 · AnimatedSwitcher & ValueKey — transition theo variant"
description: "Thêm AnimatedSwitcher + ValueKey(runtimeType) + transitionBuilder fade/slide + disableAnimations vào layer skeleton. Vì sao đổi variant thì animate, đổi payload cùng variant (AI loading→kết quả) thì không."
sidebar:
  label: "Bài 3 · keyed transitions"
  order: 3
---

## Mục tiêu

- Thêm `AnimatedSwitcher` vào `GameDialogLayer` (duration/reverse
  300ms, `easeOutCubic`/`easeInCubic`, `transitionBuilder` fade+slide).
- Giải thích được vì sao key = `ValueKey(dialog.runtimeType)` là đúng:
  variant khác → swap animate; cùng variant khác payload → đổi
  in-place, không re-animate.
- Honor `MediaQuery.disableAnimations` → `Duration.zero` (a11y).
- Thêm 3 test: keyed-fade + backdrop key, reduced-motion tức thì,
  outgoing lingers trong exit motion.

## Bạn đang ở đâu

- Bài 2: layer skeleton swap thô — `Hidden` → `SizedBox.shrink()`,
  variant → backdrop+view. Đổi variant = đổi child tức thì, không
  motion, và nút bấm vẫn đúng nhờ callback.
- Bài này bọc child đó trong `AnimatedSwitcher` — chỉ thêm motion,
  không đổi rule nào của Bài 2.

## Vì sao việc này quan trọng ngay bây giờ

Dialog game không "mở" kiểu route (push + transition route) — nó là
đổi child trong `Stack`. Không có transition, dialog chỉ "bật" — xấu
và khác senior. `AnimatedSwitcher` là widget sinh ra cho đúng việc
này: **child đổi → cross-fade + slide giữa child cũ và mới.**

Cái senior thêm là *key theo variant*: `ValueKey(runtimeType)`. Nhờ
đó máy biết "dialog A đổi sang dialog B" (animate) vs "vẫn dialog A
nhưng nội dung trong nó đổi" (không animate). Không có key phân biệt,
AnimatedSwitcher coi hai `SizedBox.expand` là cùng một child và
không animate gì cả.

## Bạn đã biết gì

- `ValueKey`/`Key` cơ bản (M08/M15 — item trong ListView).
- `Animation<double>` tồn tại, `Duration`, `Curves` (đã thấy trong
  `AnimatedOpacity` M20).
- `MediaQuery.of(context)` đọc cấu hình hệ thống (M17 responsive).
- Sealed switch kiệt hợp (Bài 2 vừa dùng).

## Dart cần dùng — xuất hiện đầu tiên

| Construct | Vai trò | Depth |
|---|---|---|
| `ValueKey(Type)` — `ValueKey(dialog.runtimeType)` | identity theo *kiểu* của variant | mới — CORE |
| `AnimatedSwitcher(duration/reverseDuration/switchInCurve/switchOutCurve/transitionBuilder)` | swap child có animation | mới — CORE |
| `FadeTransition` + `Transform.translate` + `AnimatedBuilder` | transition composite senior | mới |
| `MediaQuery.of(context).disableAnimations` | a11y — `Duration.zero` | mới |

### `ValueKey(runtimeType)` — key là tuyên bố danh tính

Trong `AnimatedSwitcher`, key của child trả lời câu hỏi: *"child mới
này có phải 'cùng chỗ' với child cũ không?"*

- `ValueKey(dialog.runtimeType)` → `ValueKey(GameConfirmExitDialog)`
  khác `ValueKey(GameEndedDialog)` → switcher animate swap.
- Hai `GameAIAssistantDialog` (loading và result) → **cùng
  `runtimeType`** → cùng `ValueKey` → switcher coi là *cùng child*,
  chỉ rebuild — AI đổi "đang suy nghĩ" → kết quả **không** fade out/in
  lại. Đây là case-vàng của senior: mutation *trong* variant không
  animate; đổi *giữa* variant mới animate.
- Key KHÔNG phải "id duy nhất toàn app" — nó chỉ có nghĩa *trong một
  parent* (ở đây là child của AnimatedSwitcher). Cùng key ở hai màn
  khác nhau là vô hại.

## Mental model mới — "state variant → transition identity"

```text
dialogState đổi variant      →  ValueKey mới  →  AnimatedSwitcher
                                                    swap animate
dialogState đổi payload      →  cùng ValueKey →  child giữ nguyên,
  (cùng variant)                                 chỉ rebuild body
```

Nghĩ về `runtimeType` key như "tên vai" trong kịch: vai khác → diễn
viên mới lên sân khấu (transition); cùng vai đổi lời thoại → cùng
diễn viên, đổi nội dung.

## Android / Compose bridge

```text
SIMILARITY:           `AnimatedContent(targetState, label)` trong
                      Compose — targetState đổi → animate swap.
IMPORTANT DIFFERENCE: Flutter AnimatedSwitcher phân biệt child bằng
                      KEY + runtimeType của widget, không bằng một
                      targetState value bạn khai báo. Muốn kiểm soát
                      khi nào "đổi", bạn kiểm soát key.
DO NOT ASSUME:        `key != data`. Gắn `ValueKey(payload)` (ví dụ
                      amount) sẽ animate lại mỗi khi số tiền đổi —
                      sai senior: key = loại dialog, không phải dữ
                      liệu trong nó.
```

## Build it step by step

### Bước 1 — Bọc child bằng `AnimatedSwitcher`

Trong `lib/widgets/game/game_dialog_layer.dart`, **thay** `build()`:

```dart
  @override
  Widget build(BuildContext context) {
    final canDismissFromBackdrop = _canDismissFromBackdrop(dialog);
    // Reduced-motion (accessibility): senior đọc
    // `MediaQuery.disableAnimations` → duration 0 = swap tức thì.
    final motionDuration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : MenuTokens.dialogMotionLong;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: dialog is GameDialogHidden,
        child: AnimatedSwitcher(
          duration: motionDuration,
          reverseDuration: motionDuration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: _buildTransition,
          child: _layerChild(canDismissFromBackdrop),
        ),
      ),
    );
  }
```

Khác skeleton ở ba chỗ: (a) đọc `disableAnimations` → `Duration.zero`;
(b) `AnimatedSwitcher` bọc child; (c) child giờ đi qua `_layerChild` —
trả `SizedBox.expand` CÓ `ValueKey` để switcher phân biệt được.

### Bước 2 — `_layerChild` với key theo variant

**Thêm** method (thay cho phần thân cũ trong `build`):

```dart
  /// Key = `runtimeType` của variant — ĐÂY là thứ báo cho
  /// `AnimatedSwitcher` biết "dialog đã đổi" (swap) hay "vẫn dialog
  /// cũ, chỉ khác nội dung" (không swap).
  Widget _layerChild(bool canDismiss) {
    return dialog is GameDialogHidden
        ? const SizedBox.expand(key: ValueKey('game-dialog-hidden'))
        : SizedBox.expand(
            key: ValueKey(dialog.runtimeType),
            child: _DialogBackdrop(
              onDismiss: canDismiss ? onDismiss : () {},
              child: _dialogBody(),
            ),
          );
  }
```

Hai key quan trọng: `ValueKey('game-dialog-hidden')` cho trạng thái
trống (chuỗi, không phải type — vì `Hidden` → không có body) và
`ValueKey(dialog.runtimeType)` cho mọi variant thật.
`SizedBox.expand` (thay `SizedBox.shrink` của skeleton) để child
luôn full-size — transition slide/fade cần vùng đầy đủ để vẽ.

### Bước 3 — `_buildTransition` (fade + slide)

```dart
  /// Senior `_buildTransition`: fade + slide-up nhẹ; thang tiền trượt
  /// xa hơn (`spacingMd` thay `spacingSm`) — "bảng lớn vào từ xa".
  Widget _buildTransition(Widget child, Animation<double> animation) {
    final slideOffset = child.key == const ValueKey<Type>(GameMoneyLadderDialog)
        ? MenuTokens.spacingMd
        : MenuTokens.spacingSm;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final progress = animation.value.clamp(0, 1).toDouble();

        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0, slideOffset * (1 - progress)),
            transformHitTests: false,
            child: child,
          ),
        );
      },
    );
  }
```

Ba chi tiết cần hiểu:

- **`child.key == ValueKey<GameMoneyLadderDialog>`** — transition
  nhìn key của *child đang trượt* để quyết slide xa hay gần. Ladder
  trượt `spacingMd`(16), dialog thường `spacingSm`(12).
- **`AnimatedBuilder(animation:, child:)`** — pattern "rebuild mỗi
  tick nhưng giữ nguyên con": `child` ngoài builder được truyền vào
  lại, không bị build lại — chỉ Transform/Fade bọc ngoài đổi theo
  `animation.value`.
- **`transformHitTests: false`** — tap tính theo vị trí *đích*, không
  theo vị trí đang trượt; nếu không, trong lúc dialog đang slide lên,
  nút "lệch" khỏi chỗ bạn nhìn thấy và tap hụt.

### Bước 4 — Thêm 3 test transition

Trong `test/widgets/game_dialog_layer_test.dart`, **thêm** vào
`main()` (trước `}`):

```dart
  testWidgets('layer dùng keyed fade transitions (AnimatedSwitcher + '
      'backdrop-filter key)', (tester) async {
    await _pumpTestSurface(
      tester,
      const _TestSurface(dialog: GameDialogHidden()),
    );
    expect(find.text('Thoát trò chơi?'), findsNothing);

    await _pumpTestSurface(
      tester,
      const _TestSurface(
        dialog: GameConfirmExitDialog(guaranteedAmount: r'$0'),
      ),
    );

    expect(find.byType(AnimatedSwitcher), findsOneWidget);
    expect(find.byType(FadeTransition), findsWidgets);
    await tester.pump(MenuTokens.dialogMotionLong);

    expect(find.text('Thoát trò chơi?'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('game-dialog-backdrop-filter')),
      findsOneWidget,
    );
  });

  testWidgets('reduced-motion: outgoing dialog biến mất NGAY', (
    tester,
  ) async {
    await _pumpTestSurface(
      tester,
      const _TestSurface(
        disableAnimations: true,
        dialog: GameConfirmExitDialog(guaranteedAmount: r'$0'),
      ),
    );
    expect(find.text('Thoát trò chơi?'), findsOneWidget);

    await _pumpTestSurface(
      tester,
      const _TestSurface(
        disableAnimations: true,
        dialog: GameDialogHidden(),
      ),
    );

    // Duration.zero → outgoing rời cây ngay, cả backdrop cũng mất.
    expect(find.text('Thoát trò chơi?'), findsNothing);
    expect(
      find.byKey(const ValueKey('game-dialog-backdrop-filter')),
      findsNothing,
    );
  });

  testWidgets('dismiss: outgoing dialog còn trong cây suốt exit '
      'motion', (tester) async {
    await _pumpTestSurface(
      tester,
      const _TestSurface(
        dialog: GameConfirmExitDialog(guaranteedAmount: r'$0'),
      ),
    );
    await tester.pump(MenuTokens.dialogMotionLong);
    expect(find.text('Thoát trò chơi?'), findsOneWidget);

    await _pumpTestSurface(
      tester,
      const _TestSurface(dialog: GameDialogHidden()),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Thoát trò chơi?'), findsOneWidget); // đang fade out

    await tester.pump(MenuTokens.dialogMotionLong);
    expect(find.text('Thoát trò chơi?'), findsNothing);
  });
```

Điểm mấu chốt của test 3: **outgoing child vẫn trong cây suốt exit
motion** — `pump(100ms)` sau khi đổi sang `Hidden` vẫn thấy text
(dialog đang fade out), chỉ sau khi reverse duration xong mới mất.
Test này tài liệu hóa hành vi mà bản route cũ "miễn phí" nhờ
`Navigator.pop` transition — trong in-tree ta phải tự giữ nó.

## Chạy và quan sát

```bash
flutter analyze   # sạch
flutter test      # 153/153 (150 + 3 transition tests)
```

Trong app chưa thấy gì khác — layer vẫn chưa mount (Bài 4). Nhưng
test mới đã chứng minh: swap animate khi variant đổi, tức thì khi
`disableAnimations`, và outgoing tồn tại suốt exit.

## Thử nghiệm — đoán trước khi chạy

:::note[PREDICT]
`GameAIAssistantDialog(isLoading:true)` → đổi thành
`GameAIAssistantDialog(isLoading:false, selectedAnswer:'A')`. Có
fade-swap không? Tại sao? Nếu đổi `ValueKey(runtimeType)` thành
`ValueKey('${runtimeType}-$isLoading')` thì chuyện gì khác?
:::

<details><summary>Đáp án</summary>

Không fade — cùng `runtimeType` → cùng `ValueKey` → switcher coi là
cùng child, chỉ rebuild body (`isLoading` switch trong view). Nếu
gắn `isLoading` vào key: loading→result là HAI key khác nhau →
switcher animate swap → dialog AI "nhấp nháy" fade out-in giữa chừng
— sai senior (senior giữ transition mượt vì key chỉ theo loại).

</details>

## Lỗi hay gặp

- **Assert `findsNothing` ngay sau dismiss** — outgoing child sống
  trong cây tới hết `reverseDuration`; test phải pump qua motion.
  (Suite `game_screen_test.dart` cần `pump(400)` không `pump(300)`
  — controller reverse khởi động một frame sau swap-build; Bài 4 sửa.)
- **Key sai loại identity** — `ValueKey(payload)` làm dialog animate
  lại mỗi khi data đổi; `ValueKey(index)` sụp khi thêm/bớt variant.
- **`transformHitTests: true`** (mặc định) — nút "nhảy" khỏi ngón
  tay trong lúc slide.

## Tự làm (DEBUG)

:::note[Bài tập]
Bug được gieo: `SizedBox.expand(key: const ValueKey('dialog'))` cho
MỌI variant (thay `runtimeType`). Đổi `ConfirmExit` → `Ended` trong
test — predict + chạy: có animate không? Nội dung có đổi không?
:::

<details><summary>Đáp án</summary>

Không animate (key trùng → cùng child slot) — NHƯNG nội dung vẫn
đổi đúng, vì `_dialogBody()` đọc `dialog` mới. Hậu quả tinh vi:
function đúng, motion sai — test assert-text vẫn pass, chỉ test
transition-type mới bắt được. Đây là lý do `runtimeType` được chọn:
đúng một key per variant, khỏi trùng, khỏi sót.

</details>

## Kiểm tra hiểu biết

1. `ValueKey(runtimeType)` — vì sao KHÔNG dùng `ObjectKey(dialog)`?
   *(Hai instance cùng type khác payload vẫn "cùng dialog" —
   ObjectKey phân biệt theo identity → mỗi emit copyWith mới lại
   animate.)*
2. `disableAnimations` → duration nào? Vì sao không `if` bỏ hẳn
   switcher? *(`Duration.zero`; giữ switcher để code-path thống nhất
   — cùng widget tree, chỉ không motion.)*
3. `transitionBuilder` trả gì, nhận gì? *(Nhận child + animation,
   trả widget bọc child — FadeTransition/Transform ở đây.)*

## Ta cố ý chưa thêm

- Layer vẫn chưa mount trong `game_screen.dart` — Bài 4 mới cắt
  scaffold route.
- `transitionKey`/`GlobalKey` của senior — roadmap chỉ cần
  `runtimeType`; senior phức tạp hơn cho case riêng.
- Curve khác / stagger — senior chỉ `easeOutCubic`/`easeInCubic`.

## Checkpoint hoàn thành

- [ ] `flutter analyze` sạch.
- [ ] `flutter test` **153/153** (3 test transition mới).
- [ ] Giải thích được "cùng variant → không re-animate" bằng key.
