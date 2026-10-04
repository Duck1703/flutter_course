---
title: "M06 — Stream & StreamBuilder"
description: Stream<T> = chuỗi giá trị theo thời gian, StreamBuilder rebuild theo event, subscription/cancel — menu có đồng hồ phiên cập nhật live.
sidebar:
  label: Tổng quan M06
  order: 0
---

## Kết quả sau milestone này

Menu có thêm thẻ **"Thời gian phiên"** đếm giây trực tiếp — `1s, 2s, 3s…`
cập nhật mỗi giây mà **không hề gọi `setState`**: một `Stream<int>` phát
event mỗi giây, `StreamBuilder` nghe và tự rebuild đúng chỗ đó. Đây là lần
đầu UI "chạy một mình" theo dòng dữ liệu.

Song song đó bạn hiểu subscription: ai nghe, nghe kiểu gì, huỷ thế nào —
và nhìn thấy trước chỗ `ValueStream` của senior sẽ đáp vào (M14).

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [Stream ≠ Future: chuỗi giá trị theo thời gian](/m06/01-stream-la-gi/) | `Stream<T>`, `Stream.periodic`, subscription mental model, `take`/`emitsInOrder` test |
| 2 | [StreamBuilder trong menu](/m06/02-streambuilder-trong-menu/) | `stream`/`initialData`/`snapshot.data`, stable-stream field, rebuild theo event |
| 3 | [listen, cancel & StreamController](/m06/03-listen-cancel-streamcontroller/) | `StreamSubscription`, `listen`, `cancel`, `StreamController` + `.broadcast()` (learning example), bridge đến senior |

## Khái niệm được giới thiệu

- **Dart:** `Stream<T>`, `Stream.periodic`, `StreamSubscription`,
  `stream.listen(...)`, `subscription.cancel()`, `stream.take(n)`,
  `stream.first`, `StreamController`, `StreamController.broadcast`
  (concept-level), single-subscription vs broadcast.
- **Flutter:** `StreamBuilder`, `initialData`, `AsyncSnapshot` với stream.
- **Matcher test:** `emitsInOrder`.

## Tiêu chí hoàn thành

- Menu có thẻ "Thời gian phiên" đếm lên mỗi giây, không `setState`.
- `Stream<int> _sessionTicker` là field ổn định — không tạo stream trong
  `build()`.
- Bạn giải thích được khác biệt cốt lõi: `Future` = một kết quả về sau;
  `Stream` = nhiều event theo thời gian.
- `flutter test` vẫn xanh (15 test), gồm `emitsInOrder` cho ticker.
- Bạn đọc được `userProfileStream`/`ValueStream`/`_events.broadcast` của
  senior mà không sợ — dù M14 mới tái hiện chúng.

## Tổng kết M06 — tự kiểm tổng hợp

- **Tôi học được gì?** `Stream<T>`, `StreamController`,
  `StreamSubscription`, `StreamBuilder`, `cancel()` trong `dispose`.
- **Tôi giải thích được gì?** Single-subscription vs broadcast; ai sở
  hữu subscription thì ai cancel (bài Tự làm — `setState() after
  dispose`).
- **Tôi viết được gì không copy?** Dự đoán đúng output của chuỗi
  `add`/`listen`/`cancel` trên broadcast stream (bài Tự làm).
- **Nếu X đổi thì sao?** Listener subscribe sau `add(1)` trên
  broadcast — nhận `1` không? (Không — không replay; đối lập
  BehaviorSubject ở M14.)
- **Concept cần lại sau:** subscription-ownership — VM M13/M14;
  broadcast → event bridge M13; `StreamController` → `BehaviorSubject`
  M14 (cùng vai trò "controller", khác semantics).
