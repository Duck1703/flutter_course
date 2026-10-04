---
title: "M20 — Lifelines & nút feature"
description: "5 bài: lifeline-là-luat (Set dùng-một-lần) → data + helper thuần → 50:50 + hỏi khán giả → AI mô phỏng + walk-away → tests + regression. Kết quả: thanh lifeline senior hoạt động đầy đủ, mỗi quyền dùng một lần do VM sở hữu."
sidebar:
  order: 0
  label: Tổng quan M20
---

# M20 · Lifelines & nút feature

M19 đã cho màn chơi một máy trạng thái đúng senior. M20 bổ sung
mảng cuối còn thiếu của màn chơi: **thanh lifeline** — 50:50 xóa
hai ô sai, hỏi khán giả mở dialog phần trăm theo độ khó, hỏi AI
hiện loading 700ms rồi gợi ý, dừng cuộc chơi mang tiền về, và
thoát giữa ván. Tất cả đi qua một điểm: `handleFeatureClick` →
`_canUseFeature` → mutation ghi `usedFeatureButtons`.

:::note[AI là mô phỏng — và senior cũng vậy]
"Trợ lý AI" của senior không gọi mạng: `Future.delayed(700ms)`
rồi trả `correctOption` + độ tin cậy cố định 85% +
`question.explanation.aiHintMessage`. Learner giữ đúng hành vi
đó — không phải phiên bản "rút gọn" của một tích hợp thật.
:::

## Bản đồ bài học

| Bài | Nội dung | Checkpoint |
|-----|----------|-----------|
| [01](/m20/01-lifeline-la-luat-game/) | Lifeline là luật game: `GameFeatureButtonType`, `Set` dùng-một-lần, `_canUseFeature` mental model (D-35) | hiểu model — chưa code |
| [02](/m20/02-du-lieu-va-helper-lifeline/) | Nền data: 4 field state + item poll + DTO nút + `audiencePercentile`; helper thuần + test; ARB +12 (sealed variant đi kèm UI ở Bài 3/4) | analyze sạch, **131/131** |
| [03](/m20/03-nam-muoi-nam-muoi-va-hoi-khan-gia/) | 50:50 + poll xuyên stack: mapper `featureButtons`, VM guard/mutation, bar widget, ô trống, poll dialog | **141/141** |
| [04](/m20/04-hoi-ai-va-dung-cuoc-choi/) | AI 700ms một-route-hai-hình (`ListenableBuilder` host), walk-away → victory + `resolvedResult{won:false}` | **147/147** |
| [05](/m20/05-tests-regression-tu-lam/) | Test pyramid, PREDICT/DEBUG, PRODUCE lifeline-6 skeleton, regression + build web | **147/147** + build |

## Kết quả sau M20

- Thanh lifeline dưới đáp án hoạt động: `%` xóa 2 ô sai
  (deterministic — giữ đúng + sai-đầu), `people` mở poll theo độ
  khó (easy 68/medium 52/hard 42), `auto_awesome` loading→kết quả
  AI, `emoji_events` hiện sau safe haven để dừng cuộc có tiền.
- "Dùng một lần" là `Set<GameFeatureButtonType>` trên state
  bất biến — widget chỉ render `isEnabled`, VM vẫn kiểm lại.
- Ô bị xóa vẫn *hiển thị* nhưng không tap được — ba lớp phòng
  thủ: mapper `idle`, widget `onTap:null`, VM `isEmpty` guard.
- Kết quả ván được *chốt* trong `resolvedResult` tại transition —
  walk-away đúng `won:false` dù phase là `victory`.

## Điều milestone này cố ý chưa làm

- Nút lifeline là `IconData` phẳng, chưa có painter/SVG của
  senior — **FR-34**, hội tụ M28.
- Dialog vẫn `showDialog` — `GameDialogLayer` trong `Stack` là
  **M21** (FR-07; host `ListenableBuilder` là cầu nối sẵn).
- VM chưa là DRE — **M26**; `resolvedResult` là interim carrier,
  save-site thật trong VM là **M22** (FR-04).
- `GameShareResultEvent` — chưa assign (FR-33).

## Checkpoint tổng kết

- [ ] `flutter analyze` sạch; `flutter test` **147/147**;
  `flutter build web` xanh.
- [ ] Chơi thử: 50:50 mờ sau dùng + 2 ô trống giữ chỗ; poll đúng
  68% cho câu easy; AI đổi loading→kết quả sau ~0.7s; walk-away
  chỉ hiện sau Q5; exit/poll dialog pause timer.
- [ ] Giải thích được `resolvedResult.won == false` dù phase
  `victory`, và vì sao `usedFeatureButtons` sống cả ván.

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** `Set<T>` immutable làm sổ "dùng-một-lần" (D-35);
   hai lớp guard (`button.isEnabled` → `_canUseFeature`); sealed
   variant đi kèm UI arm; emit-2-lần một route (loading→result);
   `resolvedResult` tách domain-result khỏi phase.
2. **Giải thích được?** Vì sao 50:50 deterministic mà không
   `Random`; vì sao walk-away `won:false` dù vào `victory`; vì
   sao thêm sealed variant mà không thêm arm là lỗi compile;
   vì sao `canWalkAway` (hiện nút) khác `_canUseFeature` (cho
   bấm); vì sao `_useFiftyFifty` không pause timer.
3. **Viết lại không copy?** Tự làm: skeleton lifeline thứ 6
   (Bài 5) + DEBUG "quên check used".
4. **Nếu … thì sao?** Bỏ guard `is!` → kết quả AI trễ mở lại
   dialog đã đóng; quên `usedFeatureButtons` ghi → lifeline tái
   dùng vô hạn; bỏ `resolvedResult` → walk-away bị tính `won`.
5. **Cần ở đâu sau?** M21 thay `showDialog` bằng `GameDialogLayer`
   trong `Stack` (host `ListenableBuilder` là cầu nối sẵn); M22
   persist `resolvedResult` qua repository; M28 painter/SVG cho
   nút (FR-34).
