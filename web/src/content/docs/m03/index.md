---
title: "M03 — Tương tác: StatefulWidget & setState"
description: Tách Widget khỏi State, dùng setState cho state UI cục bộ, và hiểu vòng đời State cơ bản.
sidebar:
  label: Tổng quan M03
  order: 0
---

## Kết quả sau milestone này

Màn hình menu trở nên **tương tác**: icon trong header bật/tắt trạng thái âm
thanh (icon và chữ mô tả đổi theo), nút "BẮT ĐẦU CHƠI" bấm được và đếm số lần
bấm hiển thị ngay trên màn hình. Chưa có điều hướng, chưa có logic game —
mục tiêu là nắm vững **state cục bộ**.

Bạn cũng sẽ thấy một hiện tượng quan trọng: **state sống sót qua Hot Reload**
nhưng bị reset bởi Hot Restart — và giải thích được vì sao.

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [StatelessWidget vs StatefulWidget](/m03/01-stateless-va-stateful/) | Widget/State split, `createState`, `setState` đầu tiên, `GestureDetector`, callback `VoidCallback` |
| 2 | [setState và mô hình rebuild](/m03/02-setstate-va-rebuild/) | `setState` làm gì (và không làm gì), closure `() {}`, đếm bấm trên CTA |
| 3 | [Lifecycle, callback & state ở đâu](/m03/03-lifecycle-callbacks-va-state-ownership/) | `initState`/`dispose`, `debugPrint`, data-down-events-up, state ownership |

## Khái niệm được giới thiệu

- **Dart:** field `bool`/`int` trong class, lambda/closure `() { }`,
  `VoidCallback`, toán tử `!` (phủ định) và `++`, toán tử ba ngôi `?:`,
  nội suy `'$var'` trong chuỗi.
- **Flutter:** `StatefulWidget`, `State<T>`, `createState()`, `setState`,
  `initState`, `dispose`, `mounted` (nhắc tới), `GestureDetector`, vì sao
  `build` chạy lại.

## Tiêu chí hoàn thành

- Bấm CTA thấy màn hình đổi (số lần bấm tăng).
- Toggle âm thanh đổi cả hai chiều: icon **và** dòng mô tả.
- Bạn giải thích được: "biến đổi bởi code của bạn; `setState` chỉ báo cho
  Flutter rằng State này cần rebuild" — và vì sao bỏ `setState` thì UI đứng im.

## Tổng kết M03 — tự kiểm tổng hợp

- **Tôi học được gì?** `StatefulWidget` = Widget + `State<T>` tách
  rời; `setState`; data-down/events-up; callback `VoidCallback`.
- **Tôi giải thích được gì?** Vì sao Widget immutable nhưng app vẫn
  đổi; ai sở hữu `_soundOn`; `initState`/`dispose`/`didChangeDependencies`.
- **Tôi viết được gì không copy?** Một widget con nhận value +
  callback (bài Tự làm `_MuteDot`) — không nhìn `_ProfileHeader`.
- **Nếu X đổi thì sao?** Nếu `_toggleMuted` đổi field không qua
  `setState` — field đổi nhưng UI đứng im. Đây là lỗi đầu tiên của
  "state không báo framework".
- **Concept cần lại sau:** `setState` → nền cho `ChangeNotifier` M11;
  ownership/callback → M12 Provider; `initState`/`dispose` → M06
  stream, M14 subscription.
