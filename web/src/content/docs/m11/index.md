---
title: "M11 — ChangeNotifier & ListenableBuilder"
description: Vì sao setState không scale, tách state menu vào MenuViewModel extends ChangeNotifier, rebuild bằng ListenableBuilder, và tự sở hữu vòng đời VM.
sidebar:
  label: Tổng quan M11
  order: 0
---

## Kết quả sau milestone này

State "to" của menu — profile và vòng đời tải — rời khỏi
`_MenuScreenState` và chuyển vào **`MenuViewModel extends
ChangeNotifier`**:

- `MenuScreen` còn giữ đúng *ephemeral state*: toggle âm thanh, đếm số
  lần bấm, session ticker.
- UI rebuild qua **`ListenableBuilder`** nghe `notifyListeners()` —
  không còn `setState` cho profile/loadState.
- `FutureBuilder` + `_profileLoadFuture` được thay bằng enum
  **`MenuLoadState { loading, ready, failed }`** trong VM.
- Ai tạo VM thì người đó `dispose()` — State tạo trong `initState`,
  huỷ trong `dispose` (M12 sẽ để Provider lo phần này).

Hành vi app **giữ nguyên hệt M10** — milestone này là refactor kiến
trúc, không phải feature mới. Đó là điểm: đổi nền móng mà người dùng
không nhận ra.

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [Vì sao setState không scale](/m11/01-vi-sao-setstate-khong-scale/) | Nỗi đau prop-drilling + state rải rác; `ChangeNotifier` là gì; tạo `MenuViewModel` |
| 2 | [notifyListeners & ListenableBuilder](/m11/02-notifylisteners-va-listenablebuilder/) | Getter che field private, compare-before-notify, `ListenableBuilder` thay `FutureBuilder` |
| 3 | [Sở hữu VM & unit test](/m11/03-so-huu-vm-va-test/) | Tạo/dispose VM trong State, `unawaited`, test VM không cần widget, đếm notify |

## Khái niệm được giới thiệu

- **Dart:** `extends ChangeNotifier`, `notifyListeners()`, private
  `_field` + getter public, `@override dispose` trên VM, `unawaited`.
- **Flutter:** `ListenableBuilder` — rebuild theo listenable, không qua
  `setState`; switch expression trên enum để chọn UI state.
- **Kiến trúc:** ranh giới *state thuộc VM* (profile, loadState) vs
  *state thuộc widget* (toggle, counter, ticker, điều hướng).

## Tiêu chí hoàn thành

- `menu_view_model.dart` tồn tại, `extends ChangeNotifier`, không import
  `material.dart` (chỉ `foundation`).
- `_MenuScreenState` không còn `_profile`/`_profileLoadFuture`; UI đọc
  `_viewModel.profile` trong `ListenableBuilder`.
- `flutter test` xanh gồm nhóm `MenuViewModel` (load/apply/reset/notify).
- Vẫn chưa có: Provider (M12), event stream một-lần (M13),
  `GameViewModel` (M19 — `GameScreen` giữ `setState` cố ý).

## Tổng kết M11 — tự kiểm tổng hợp

- **Tôi học được gì?** `ChangeNotifier`, `notifyListeners`,
  `ListenableBuilder`, tách VM khỏi `State`, `MenuLoadState`.
- **Tôi giải thích được gì?** `setState` → `notifyListeners` là cùng
  ý tưởng "báo dirty" nhưng state giờ sống ngoài widget; VM test được
  mà không cần pump widget.
- **Tôi viết được gì không copy?** Test `addListener` đếm notify —
  và chứng minh quên `notifyListeners` = UI đứng im (bài Tự làm).
- **Nếu X đổi thì sao?** `applyGameResult` gán field nhưng quên
  notify — field đổi, UI đứng im: đây là "silent state" mà
  `BehaviorSubject` (M14) tự khắc phục bằng emit.
- **Concept cần lại sau:** `ChangeNotifier` → `ChangeNotifierProvider`
  M12 → VM vẫn là nó ở M14; `notifyListeners` → so với subject emit
  M14; `MenuLoadState` → retire M14 khi stream seed sẵn.
