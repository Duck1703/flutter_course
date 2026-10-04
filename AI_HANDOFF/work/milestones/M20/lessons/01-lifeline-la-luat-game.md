---
title: "Bài 1 · Lifeline là luật game, không phải cờ widget"
description: "Mental model của M20: quyền trợ giúp là rule nghiệp vụ do state sở hữu — 'dùng một lần' là một Set, không phải bool trên nút. Checkpoint: hiểu model — chưa code."
sidebar:
  label: "Bài 1 · lifeline = luật"
  order: 1
---

## Mục tiêu

- Kể ra được 5 loại feature của màn chơi senior: `fiftyFifty`,
  `audiencePoll`, `aiAssistant`, `walkAway`, `exitGame` — và loại
  nào "dùng một lần", loại nào không.
- Giải thích được vì sao "đã dùng hay chưa" phải sống trong
  `GameSessionState` (một `Set<GameFeatureButtonType>`), chứ không
  phải `bool _fiftyUsed` trong widget.
- Đọc được thứ tự guard của senior `_canUseFeature` và nói được
  mỗi lớp chặn cái gì.

## Bạn đang ở đâu

- M19 xong: game đã chạy trên máy trạng thái 6 phase trong
  `GameScreenViewModel`; state bất biến `copyWith`; timer VM sở
  hữu; dialog đi qua `dialogState` + `GameDialogRequested`.
- Điều còn thiếu so với senior: **thanh lifeline dưới đáp án**.
  Trong "Ai là triệu phú" đó là 50:50, hỏi khán giả, hỏi AI —
  mỗi cái dùng đúng một lần — cộng thêm Dừng cuộc chơi (walk-away)
  và Thoát.
- Bài này chỉ dựng mental model — code bắt đầu ở Bài 2.

## Vì sao việc này quan trọng ngay bây giờ

Cách "nhanh" mà người mới hay nghĩ tới: thêm `bool _fiftyUsed =
false` vào `_GameScreenState`, tap xong `setState(() =>
_fiftyUsed = true)`. Hỏng ở ba chỗ:

1. **Trạng thái lạc chủ.** Bài 1 của M19 đã lập luận: mọi thứ
   "là đúng hay sai của ván game" thuộc `GameSessionState`. Nút
   50:50 đã dùng là *fact của ván*, không phải fact của widget —
   chơi lại (`playAgain`) phải reset nó cùng cả ván, và test phải
   đọc được nó mà không cần pump màn hình.
2. **Guard lệch UI.** Nếu widget tự quyết "enabled hay không",
   hai nơi cùng quyết một việc — nút hiển thị enabled nhưng VM
   từ chối (hoặc ngược lại) là bug kinh điển. Senior giải bằng
   **hai lớp phòng thủ**: button data mang `isEnabled` *đã được
   mapper suy ra*, và VM vẫn kiểm lại `_canUseFeature` trước khi
   làm gì. Tap nút disabled = no-op hoàn toàn.
3. **Rule bị rải rác.** "50:50 xóa 2 ô sai nào?" — nếu widget tự
   random ẩn ô, logic game tràn vào UI. Senior giữ *mọi* quyết
   định lifeline trong VM + hàm thuần: widget chỉ render kết quả.

## Bạn đã biết gì

- Máy trạng thái + phase guard `phase != GamePhase.playing →
  return` (M19, A-18).
- State bất biến + `copyWith` + cờ `clear*` (M19, D-34).
- Dialog đi qua `dialogState` + `GameDialogRequested` event
  (M19); mapper thuần `buildGameScreenPresentation` (A-20).
- `Future.delayed` cơ bản (M05, D-09); `Timer.periodic` do VM
  sở hữu (M19, D-33).

## Mental model mới — "quyền trợ giúp là tập đã-tiêu"

Senior mô hình hóa "dùng một lần" bằng một **`Set`**: tập các
nút *đã* dùng.

```text
usedFeatureButtons = {}                    # đầu ván
tap 50:50   → {_canUseFeature?} → ok → emit {fiftyFifty}   ← ghi vào Set
tap 50:50   → contains(fiftyFifty) → từ chối, không làm gì
tap poll    → emit {fiftyFifty, audiencePoll}
sang câu 2  → Set GIỮ NGUYÊN (đã dùng là cả ván, không reset)
playAgain   → startNewGame → Set mới rỗng (ván mới tính lại)
```

Ba ý đồng thời:

- **`Set` chứa *type*, không chứa index.** "Đã dùng 50:50" là đúng
  một fact duy nhất → `Set<GameFeatureButtonType>` — không cần
  `Map`, không cần `List` (không có thứ tự, không trùng).
- **Guard đọc, mutation ghi.** `_canUseFeature` chỉ *đọc* Set;
  từng method feature mới *ghi* vào Set. Nút `walkAway` và
  `exitGame` **không** ghi vào Set — đó không phải "quyền dùng
  một lần" mà là hành động kết thúc/điều hướng (senior loại
  chúng khỏi nhánh single-use ngay trong `_canUseFeature`).
- **`_canUseFeature` có thứ tự, và thứ tự ấy là semantics**:
  kiểm `phase == playing` **trước** (không đang chơi → mọi nút
  chết, kể cả exit) → walk-away riêng cần `_walkAwayAmount > 0`
  → exit luôn `true` → còn lại tra `!used.contains(type)`.

## Dart cần dùng — `Set<T>` (xuất hiện đầu tiên)

| Cú pháp | Ví dụ | Nghĩa |
|---|---|---|
| `Set<T>` | `Set<GameFeatureButtonType>` | Tập hợp không trùng, không thứ tự |
| literal rỗng | `const {}` — trong ngữ cảnh `Set` | Tập rỗng (`{}` có kiểu suy ra từ biến nhận) |
| copy-add | `{...old, x}` | **Set mới** = tất cả phần tử cũ + `x` |
| membership | `set.contains(x)` → `bool` | `x` có trong tập không |
| đóng băng | `Set.unmodifiable(set)` | Set chỉ-đọc — ném lỗi nếu ai `.add` |

:::note[Vì sao không `.add(x)` trực tiếp?]
State của ta là **bất biến** (D-34): `usedFeatureButtons` được gói
bằng `Set.unmodifiable` — gọi `.add` trên nó sẽ **ném lỗi runtime**.
Muốn "thêm" phải tạo Set mới `{...old, x}` rồi `copyWith` — giống
hệt cách list-state emit ở D-32 (`List.unmodifiable`), chỉ khác
collection type.
:::

## Ví dụ độc lập

Trước khi đụng app, nhìn `Set`-as-state trong một ví dụ tối thiểu
chạy được bằng `dart run`:

```dart
enum Coupon { freeShip, discount10 }

class Wallet {
  const Wallet({required this.usedCoupons});
  final Set<Coupon> usedCoupons; // tập ĐÃ DÙNG — bất biến

  bool canUse(Coupon c) => !usedCoupons.contains(c);

  Wallet use(Coupon c) {
    if (!canUse(c)) return this;       // guard: đã dùng → trả nguyên
    return Wallet(usedCoupons: {...usedCoupons, c}); // Set MỚI
  }
}

void main() {
  var w = const Wallet(usedCoupons: {});
  w = w.use(Coupon.freeShip);
  print(w.canUse(Coupon.freeShip));  // false — đã khóa
  print(w.usedCoupons.length);       // 1
  w.use(Coupon.freeShip);            // no-op, Set vẫn 1 phần tử
}
```

Đây chính là pattern `usedFeatureButtons` ở Bài 3–4: guard đọc
`contains`, mutation trả object mới với `{...old, x}`.

## Android / Compose bridge

- **SIMILARITY:** tương đương `Set<LifelineType>` trong
  `GameUiState` của ViewModel senior-side Android; `set + x` của
  Kotlin ≡ `{...set, x}` của Dart (cả hai đều tạo bản copy).
- **IMPORTANT DIFFERENCE:** Kotlin `setOf()` mặc định immutable;
  Dart `Set` mặc định *mutable* — phải tự gói `Set.unmodifiable`
  ở boundary state.
- **DO NOT ASSUME:** `.add()` trả `bool` ở Dart — nhưng bạn
  *không bao giờ được gọi nó* trên field state; nó chỉ tồn tại
  trên Set mutable thường.

## Senior project connection

- `lib/view_models/game/dre/game_dre_state.dart` —
  `GameState.usedFeatureButtons` (Set trên immutable state —
  learner copy nguyên field này).
- `lib/view_models/game/reducer/game_reducer_feature_flow.dart` —
  `_canUseFeature` (thứ tự guard verbatim ở Bài 3) + ba chỗ ghi
  `usedFeatureButtons + {type}` (chỉ 3 lifeline, không gồm
  walk-away/exit).
- `lib/data/game/game_screen_data.dart` — `GameFeatureButtonType`
  (5 giá trị) + `GameFeatureButtonData.isEnabled` (mapper suy ra —
  Bài 3).

## Thử nghiệm — đoán trước khi chạy

Trong ví dụ `Wallet` ở trên, đổi guard thành kiểm tra **trước**
khi `use` bị gọi — tức bỏ hẳn `_used.contains`, chỉ giữ
`remaining > 0`. **Đoán:** gọi `w.use()` hai lần liên tiếp thì
`remaining` còn bao nhiêu? *(Đáp án: 0 — không có sổ đã-dùng,
"quyền" tái sử dụng vô hạn miễn còn tiền. Đây là toàn bộ lý do
`usedFeatureButtons` tồn tại: sổ Set biến quyền một-lần thành
luật không-thể-phá.)*

## Ta cố ý chưa thêm

- Nút lifeline trong senior vẽ bằng `CustomPainter` + icon SVG —
  learner dùng `IconData` phẳng ở milestone này (**FR-34**, hội
  tụ M28 với visual parity pass). Hành vi giữ nguyên, chỉ độ
  sâu visual được dời.
- Dialog vẫn `showDialog` — layer `GameDialogLayer` trong `Stack`
  là **M21** (FR-07).
- VM vẫn `ChangeNotifier` — DRE (`DreChangeNotifier` + reducer
  thuần) là **M26**.

## Kiểm tra hiểu biết

1. Vì sao `usedFeatureButtons` là `Set` chứ không phải
   `Map<GameFeatureButtonType, bool>`? *(Gợi ý: hai trạng thái của
   map key vắng/false là một, Set chỉ có "có"/"không".)*
2. Ở phase `answeredRevealed`, bấm nút exit có được không? Đọc lại
   thứ tự `_canUseFeature` để trả lời. *(Không — phase gate chạy
   trước mọi nhánh khác.)*
3. `walkAway` không ghi vào `usedFeatureButtons` — vậy làm sao
   senior ngăn "walk-away hai lần"? *(Phase đổi sang `victory` sau
   xác nhận → phase gate chặn mọi feature kế tiếp.)*

## Checkpoint hoàn thành

- [ ] Vẽ được trên giấy: 5 feature type, cái nào ghi vào Set,
  cái nào không — và vì sao.
- [ ] Nói được thứ tự 4 lớp của `_canUseFeature` theo đúng senior.
- [ ] Ví dụ `Wallet` chạy được và `canUse` trả `false` sau khi `use`.
