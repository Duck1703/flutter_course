---
title: "M05 — Dart bất đồng bộ: Future"
description: Future<T>, async/await, FutureBuilder — profile được tải bất đồng bộ với trạng thái loading / lỗi / dữ liệu.
sidebar:
  label: Tổng quan M05
  order: 0
---

## Kết quả sau milestone này

Mở app giờ hiện **"Đang tải hồ sơ…"** khoảnh khắc → menu hiện ra với profile
đã tải (cấp 3, 250/600 EXP, 150.000 VNĐ — khác hồ sơ mặc định của M04).
Đường lỗi được dựng sẵn: nếu tải thất bại, một trạng thái lỗi với nút
**THỬ LẠI** xuất hiện và retry chạy lại đúng quy trình.

`main()` chuyển thành `Future<void> main() async` + `ensureInitialized` —
đúng shape bootstrap của app senior.

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [Đồng bộ vs bất đồng bộ + Future/async/await](/m05/01-future-async-await/) | `Future<T>` ≠ `T`, event loop, `async`, `await`, `Future.delayed`, `throw`, test async |
| 2 | [FutureBuilder: loading → data/error](/m05/02-futurebuilder/) | `late` field, `initState` khởi động tải, `ConnectionState`, `hasError`, `mounted`, stable-Future |
| 3 | [async main() & cấu trúc bootstrap](/m05/03-async-main/) | `Future<void> main() async`, `WidgetsFlutterBinding.ensureInitialized`, lý do & khi nào cần |

## Khái niệm được giới thiệu

- **Dart:** `Future<T>`, `async`, `await`, `Future.delayed`, `throw` +
  `StateError`, `try`/`catch`, `late` (dùng thật), `unawaited` (nhắc tới).
- **Flutter:** `FutureBuilder`, `AsyncSnapshot`, `ConnectionState.waiting`,
  `hasError`/`hasData`, `CircularProgressIndicator`, `mounted` sau `await`.
- **Tư duy:** Future là *việc đang chạy*, không phải kết quả; `await` tạm
  dừng hàm async — không đóng băng UI.

## Tiêu chí hoàn thành

- Mở app: trạng thái loading hiện trước, sau ~900ms menu xuất hiện với
  profile đã tải (level 3, tiền 150.000 VNĐ, stats 4/2/50%).
- `THỬ LẠI` ở trạng thái lỗi kích hoạt tải lại qua `setState`.
- Không có Future nào được tạo trực tiếp trong `build()` — field
  `late Future<void> _profileLoadFuture` giữ tham chiếu ổn định.
- `flutter test` xanh, gồm test async (`await` trong test, `throwsStateError`).
- Bạn giải thích được: `Future<T>` là "lời hứa sẽ có T (hoặc lỗi)", không
  phải bản thân `T`.

## Tổng kết M05 — tự kiểm tổng hợp

- **Tôi học được gì?** `Future<T>`, `async`/`await`, `FutureBuilder`,
  `WidgetsFlutterBinding.ensureInitialized` (và biết `unawaited` tồn
  tại — học ở M11).
- **Tôi giải thích được gì?** Vì sao Future trong `build` là bug
  (rebuild tạo Future mới); `await` pause trong hàm vs `then` callback
  không pause (bài Tự làm).
- **Tôi viết được gì không copy?** Một `Future<int>` giả lập load và
  tiêu thụ nó bằng `await` + `.then` — so được hai bản chất "chờ".
- **Nếu X đổi thì sao?** Đổi `await` thành `.then` trong `main` —
  `runApp` có chờ không? (Không — `then` không pause hàm gọi.)
- **Concept cần lại sau:** `Future`/`await` — mọi repo M14; Future
  trong initState — M06/M11; `unawaited` — M13 event handler.
