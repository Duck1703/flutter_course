---
title: "Bài 5 · Test lifeline, regression, và tự làm"
description: "Bản đồ test M20 (helper/VM/mapper/widget), PRODUCE lifeline thứ 6, DEBUG double-use, PREDICT phase-guard — regression toàn cục + build web."
sidebar:
  label: "Bài 5 · test + tổng kết"
  order: 5
---

## Mục tiêu

- Đọc được bản đồ test của M20: mỗi tầng (helper thuần → VM →
  mapper → widget) chứng minh một mặt khác nhau, không chồng lấp.
- Vận dụng pattern lifeline để *tự sản xuất* một nút thứ 6
  (exercise, không merge).
- Debug được bug "quên check used" — lý do `_canUseFeature`
  tồn tại.
- Regression toàn cục: full suite + `flutter build web`.

## Bạn đang ở đâu

- Sau Bài 4: **147/147**, analyze sạch — năm feature senior
  (`fiftyFifty`, `audiencePoll`, `aiAssistant`, `walkAway`,
  `exitGame`) đã hoạt động đúng semantics.
- Bài này không thêm feature — nó *chốt* milestone: nhìn lại test
  pyramid, tự làm, verify build.

## Vì sao việc này quan trọng ngay bây giờ

Lifeline là chỗ bug "im lặng" dễ sống nhất: nút nhấn hai lần vẫn
*trông* đúng nếu không có test single-use; poll % sai tổng vẫn
render đẹp. M20 có **21 test mới** phủ đúng các hỏng đó — bài
này chỉ ra *tại sao* từng tầng test tồn tại, để bạn viết được
bộ tương tự cho feature tiếp theo.

## Bản đồ test M20

| Tầng | File | Chứng minh | Không chứng minh |
| --- | --- | --- | --- |
| Helper thuần | `game_lifeline_helper_test.dart` (5) | toán 50:50/poll đúng, không mutate bank | UI, timing |
| VM | `game_screen_view_model_test.dart` (+10 → 27) | guard, single-use, percentiles, AI 700ms + guard hủy, walk-away gating + `resolvedResult`, timer pause/resume | pixel render |
| Mapper | `game_screen_presentation_mapper_test.dart` (+2 → 6) | `featureButtons` set + `isEnabled`, blank→idle, percentile lookup | VM transition |
| Widget | `widgets/game_screen_test.dart` (+4 → 14) | bar render, ô trống nhìn-thấy-không-tap, dialog poll/AI/walk-away end-to-end | toán poll |
| Sealed | `sealed_state_test.dart` (5, mở rộng) | exhaustive switch đủ 9 variant | behavior |

:::note[Nguyên tắc phân tầng]
Toán → test hàm thuần (rẻ nhất). Quyết định phase/guard → test
VM bằng `FakeAsync` (không pump). Hình dáng DTO → test mapper.
Nhìn-thấy-được → test widget. Trùng lặp tầng = test chậm và
fragile không cần thiết.
:::

## PREDICT — trả lời trước khi chạy

Đọc `_canUseFeature` + `_useFiftyFifty` rồi trả lời:

1. Bấm 50:50 **hai lần liên tiếp** — `visibleOptionTexts` sau lần
   hai là gì? *(Giữ nguyên `['A0','W0_1','','']` — lần hai bị
   `used.contains` chặn trước khi chạy helper.)*
2. Bấm 50:50 trong lúc `answeredRevealed` — có gì xảy ra?
   *(Không gì — phase gate `!= playing` chặn trước cả check
   used.)*
3. Dùng 50:50 rồi poll cùng một câu — poll hiện mấy ô 0%?
   *(Hai — `_audiencePollItems` build từ `visibleOptionTexts`,
   ô `''` → `0%`.)*

## DEBUG — bug "quên check used"

Ai đó viết `_useFiftyFifty` thế này (thiếu guard):

```dart
void _useFiftyFifty() {
  // BUG: không add vào usedFeatureButtons
  _emit(_state.copyWith(
    visibleOptionTexts: applyGameFiftyFifty(
      questions[_state.questionIndex],
    ),
  ));
}
```

- **Triệu chứng:** tap 50:50 → 2 ô xóa; tap lại → helper chạy
  *lại* trên `question.options` gốc → vẫn `['A0','W0_1','','']`
  (vô hại trông bề ngoài!) nhưng nút vẫn enabled → tap lần ba
  vẫn "chạy". Test nào bắt? *(`xóa 2 ô sai … single-use` assert
  `usedFeatureButtons` chứa type + `isEnabled` false — fail ngay.)*
- **Bài học:** ghi used-set nằm *trong* method feature, không
  phải trong guard — guard chỉ đọc. Cả hai phải đi cùng nhau.

## Tự làm (PRODUCE) — lifeline thứ 6 skeleton

:::note[Bài tập]
Thêm skeleton `secondChance` — "trả lời sai vẫn được chơi tiếp"
— theo đúng shape đã học (enum + guard + used-write + nút
disabled sau dùng). **Không** cần logic "cho chọn lại" — chỉ
cần skeleton compile + test single-use pass.
:::

<details><summary>Gợi ý trước khi xem đáp án</summary>

- Enum: `GameFeatureButtonType` thêm value → mọi switch kiệt hợp
  đỏ analyzer ngay (đó là lý do sealed/exhaustive tồn tại).
- `_canUseFeature`: `secondChance` đi nhánh `!used.contains` —
  không cần sửa gì nếu nó là lifeline thường.
- Button: `_buildFeatureButtons` thêm `_feature(...)` entry —
  nhớ IconData (`Icons.favorite`?).
- Method `_useSecondChance`: skeleton chỉ cần ghi used-set +
  `// TODO: hiệu ứng thật — không có trong senior M20`.

</details>

<details><summary>Đáp án</summary>

```dart
// enum GameFeatureButtonType { ..., exitGame, secondChance }

// Trong _buildFeatureButtons (sau aiAssistant):
//   _feature(GameFeatureButtonType.secondChance, Icons.favorite,
//       'Second Chance', canPlay, usedFeatureButtons),

// Trong handleFeatureClick:
//   case GameFeatureButtonType.secondChance: _useSecondChance();

// void _useSecondChance() {
//   _emit(_state.copyWith(usedFeatureButtons: {
//     ..._state.usedFeatureButtons,
//     GameFeatureButtonType.secondChance,
//   }));
//   // TODO: hiệu ứng "chọn lại" — senior không có feature này;
//   // skeleton chỉ chứng minh shape single-use.
// }
```

Test single-use: tap hai lần → `usedFeatureButtons` chứa type +
lần hai no-op (assert `visibleOptionTexts` không đổi nếu method
có mutation). `_labelFor` switch + `_GameDialogState`… không —
dialog không liên quan; chỉ `_labelFor` cần arm mới (trả label
l10n hoặc literal — exercise được phép literal vì không merge).

**Vì sao chỉ skeleton?** Exercise này kiểm bạn nắm *vị trí* của
mỗi mảnh: enum → guard (miễn phí) → mapper entry → VM method →
used-write → test. Hiệu ứng thật là scope khác — và quan trọng:
senior không có feature này, nên nó **không** merge vào app;
đây là bài tập tư duy, xóa sau khi làm xong nếu muốn.

</details>

## Regression + build cuối milestone

```bash
flutter analyze            # sạch
flutter test               # 147/147
flutter build web --release  # √ Built build\web
```

126 test M19 phải còn nguyên trong 147 — lifeline không được
phá flow cũ (timer, reveal, explanation, back-routing, transport
kết quả về profile).

## Tổng kết M20 — ván game đã "đủ trợ giúp"

| Trước M20 | Sau M20 |
| --- | --- |
| Không lifeline | 3 nút bar (50:50, poll, AI) + walk-away có điều kiện + exit |
| `options` render trực tiếp | `visibleOptionTexts` = state riêng, 50:50 ghi đè |
| Kết quả suy từ phase | `resolvedResult` chốt tại transition — walk-away `won:false` đúng |
| Dialog snapshot | Host `ListenableBuilder` live — AI loading→result một route |

Mental model cần giữ từ milestone này: **"dùng một lần" là Set
trên state bất biến; guard đọc, mutation ghi; mọi ý định đi qua
`handleFeatureClick`**. Cùng pattern sẽ gặp lại ở bất kỳ
feature-gate nào (settings, premium, quyền…).

## Ta cố ý chưa thêm (toàn milestone)

- **`GameFeatureButton` painter + SVG** — **M28**.
- **`GameDialogLayer` in-`Stack`** — **M21** (milestone
  ngay sau — cùng `dialogState` nguồn, chỉ đổi cơ chế hiển thị).
- **`GameShareResultEvent`/SharePlus** — chưa assign.
- **DRE** (`DreChangeNotifier` + reducer + effects) — **M26**:
  `handleFeatureClick`/`_canUseFeature` sẽ trở thành dispatch +
  pure reducer; shape method giữ nguyên nên migration đó là
  cơ học.
- **VM-side save** (`GameSaveResult` async + repository) —
  **M22**; `resolvedResult` là interim carrier cho route-pop
  transport.
- **Real notification permission, auth, leaderboard, onboarding
  parity** — M23/M24/M27/M28 theo roadmap.

## Kiểm tra hiểu biết cuối milestone

1. Năm feature: cái nào ghi `usedFeatureButtons`, cái nào không,
   và *tại sao*? *(3 lifeline ghi; walkAway/exit không — chúng
   kết thúc/điều hướng, phase gate đã chặn tái dụng.)*
2. `Set` + `{...old, x}` + `Set.unmodifiable` — mô hình bất biến
   này quen thuộc với discipline nào của M18/M19? *(`List.unmodifiable`
   emit + `copyWith` — cùng nguyên tắc, khác collection.)*
3. `audiencePercentiles` keyed bằng text — điều gì xảy ra "miễn
   phí" khi 50:50 chạy trước poll? *(Ô `''` không có key → items
   của nó 0% — không cần code riêng.)*
4. `isLoading` trên *variant* vs mở hai route — senior chọn cái
   nào và vì sao? *(Một variant hai hình + host live-read —
   không route-switch giữa chừng.)*
5. Kể hai guard chồng trong luồng AI và hỏng tương ứng nếu thiếu.
   *(Token `_schedule` → stale-ván callback; `is!
   GameAIAssistantDialog` → kết quả trễ mở lại dialog đã đóng.)*

## Checkpoint hoàn thành

- [ ] `flutter analyze` sạch; `flutter test` = **147/147**;
  `flutter build web` xanh.
- [ ] Vẽ được sơ đồ test pyramid của M20 + nói tại sao poll %
  test ở helper chứ không ở widget.
- [ ] Tự làm: skeleton `secondChance` compile + single-use test
  pass (không merge vào app).
- [ ] Giải thích được câu senior: "walk-away là victory-phase
  với `isWin:false`".
