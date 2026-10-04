---
title: "M10 — Lưu local: SharedPreferences & JSON"
description: Plugin SharedPreferences, toMap/fromMap phòng thủ, GameResult trả về qua pop, áp kết quả vào profile đúng một lần, và nút reset.
sidebar:
  label: Tổng quan M10
  order: 0
---

## Kết quả sau milestone này

Tiến trình người chơi **sống sót qua việc đóng/mở lại app**:

- Mở app → menu tải profile **đã lưu** từ `SharedPreferences` (thay hồ
  sơ demo cứng của M05).
- Chơi một ván → về menu → thẻ **Đã chơi / Thắng / Tổng thưởng / EXP**
  cập nhật theo kết quả ván chơi — và được **ghi xuống disk** ngay.
- Đóng hẳn app, mở lại → stats vẫn còn nguyên.
- Nút **ĐẶT LẠI HỒ SƠ** mới trên menu → xoá dữ liệu đã lưu, quay về
  profile mặc định.

Đây là lần đầu app có **state vượt quá một lần chạy** — và cũng là lần
đầu `main()` thật sự `await` một platform call trước `runApp`.

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [SharedPreferences & ProfileStore](/m10/01-sharedpreferences-va-profile-store/) | Plugin & platform channel, `getInstance`, `getString`/`setString`/`remove`, lớp lưu trữ concrete |
| 2 | [JSON & parse phòng thủ](/m10/02-json-tomap-frommap/) | `jsonEncode`/`jsonDecode`, `Map<String, Object?>`, `toMap`, `fromMap` với `is int`/`is String`, `FormatException` |
| 3 | [GameResult qua pop()](/m10/03-game-result-qua-pop/) | `push<T>`/`pop(result)`, dialog trả action, đóng gói kết quả phiên chơi |
| 4 | [Áp kết quả & reset](/m10/04-ap-ket-qua-va-reset/) | `applyGameResult` trên model, apply-once, `await` khi persist, nút reset + test |

## Khái niệm được giới thiệu

- **Dart:** `dart:convert` (`jsonEncode`/`jsonDecode`),
  `Map<String, Object?>`, pattern `toMap`/`fromMap`, type guard
  `is int`/`is String`, bắt `FormatException`.
- **Flutter:** `flutter pub add` một plugin (`shared_preferences`),
  `Navigator.push<T>` trả `Future<T?>`, `pop(result)` mang dữ liệu về,
  `await showDialog<T>` nhận action.
- **Kiến trúc:** `ProfileStore` — lớp lưu trữ *concrete* đầu tiên
  (chưa phải Repository; contract + stream sẽ đến ở M14); chính sách
  tiến trình (`applyGameResult`) nằm trên model.

## Tiêu chí hoàn thành

- Chơi một ván rồi về menu → stats thay đổi; **đóng hẳn và mở lại app**
  → stats vẫn còn.
- JSON hỏng/thiếu field trong prefs → app vẫn mở với profile mặc định,
  không crash.
- `flutter test` xanh, gồm test round-trip `setMockInitialValues` và
  test "VỀ MENU → đã chơi = 1 trên disk".
- Vẫn chưa có: Repository contract, stream phát profile, settings —
  đó là M14/M16.

## Tổng kết M10 — tự kiểm tổng hợp

- **Tôi học được gì?** `SharedPreferences`, `jsonEncode`/`jsonDecode`,
  `fromMap`/`toMap`, `setMockInitialValues`, `factory` ctor (M10/02).
- **Tôi giải thích được gì?** `fromMap` phòng thủ — corrupt data về
  defaults chứ không crash (bài Tự làm); vì sao `factory` cho phép
  logic trước khi object tồn tại.
- **Tôi viết được gì không copy?** Test `reset()` + corrupt-json —
  viết test để *chứng minh* fallback chứ không tin lời.
- **Nếu X đổi thì sao?** Quên `setMockInitialValues` trong test —
  chuyện gì xảy ra? (MissingPluginException/prefs lẫn nhau giữa test.)
- **Concept cần lại sau:** prefs+codec — hấp thụ vào
  `UserProfileRepositoryImpl` M14; `factory` → `static create()` M14;
  `fromMap` phòng thủ → parity với senior ở M14.
