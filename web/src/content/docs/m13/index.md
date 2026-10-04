---
title: "M13 — Event một-lần từ ViewModel"
description: Event ≠ state, StreamController.broadcast trên VM, event bridge trong State (subscribe ở didChangeDependencies, cancel ở dispose), SnackBar qua ScaffoldMessenger, và unawaited.
sidebar:
  label: Tổng quan M13
  order: 0
---

## Kết quả sau milestone này

`MenuViewModel` có thêm **kênh event một-lần** chạy song song với
`ChangeNotifier`:

- `StreamController<MenuUiEvent>.broadcast()` trên VM + getter
  `events` — VM "bắn" `MenuGameRequested` khi người chơi bấm BẮT ĐẦU
  CHƠI, và `MenuSnackBarRequested('Đã đặt lại hồ sơ.')` khi reset xong.
- `_MenuScreenViewState` trở thành **event bridge**: subscribe vào
  `didChangeDependencies`, guard khi VM không đổi, cancel ở `dispose`,
  và biến event thành hành động UI (Navigator.push / SnackBar).
- `_onPlayTap` không còn `Navigator.push` trực tiếp — chỉ gọi
  `viewModel.requestGame()` và để bridge lo điều hướng.

Hành vi app nhìn từ ngoài vẫn y hệt — milestone này đổi *ai quyết
định điều hướng*, không đổi điều hướng.

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [Event ≠ state](/m13/01-event-khong-phai-state/) | Event classes, `StreamController.broadcast`, `requestGame()` — vì sao SnackBar/điều hướng không thể là state |
| 2 | [Event bridge trong State](/m13/02-event-bridge-trong-state/) | `StreamSubscription`, subscribe ở `didChangeDependencies`, guard VM-đổi, cancel ở `dispose`, `unawaited` |
| 3 | [SnackBar event & test](/m13/03-snackbar-event-va-test/) | `ScaffoldMessenger` từ bridge, VM test event, widget test SnackBar |

## Khái niệm được giới thiệu

- **Dart:** `abstract`/`final class` event classes, event mang field
  (`message`), `StreamController<T>.broadcast()`, `StreamSubscription`
  + `cancel()`, `unawaited()`.
- **Flutter:** event-bridge pattern (`didChangeDependencies` subscribe,
  `dispose` cancel, identity guard), `ScaffoldMessenger.of(context)`.
- **Kiến trúc:** state-vs-event — `ChangeNotifier` giữ "đúng cho tới
  khi đổi", stream giữ "vừa xảy ra một lần".

## Tiêu chí hoàn thành

- `lib/view_models/menu/menu_ui_event.dart` tồn tại với
  `MenuUiEvent`/`MenuGameRequested`/`MenuSnackBarRequested`.
- `MenuViewModel` có `_events` broadcast + `events` getter;
  `requestGame()` và `resetProfile()` bắn event; `dispose()` đóng
  controller.
- `_MenuScreenViewState` subscribe hợp lệ: `didChangeDependencies` →
  guard `==` → cancel trước khi thay → cancel ở `dispose`.
- `_onPlayTap` gọi `requestGame()` — **không** `Navigator.push` trực
  tiếp; `unawaited(_openGame())` trong handler.
- `flutter test` xanh gồm: VM test event, widget test SnackBar, widget
  test CTA→GameScreen.
- Vẫn chưa có: `sealed class` event (M15), navigation controller
  (D20), repository/rxdart (M14), event từ màn game (M19).

## Tổng kết M13 — tự kiểm tổng hợp

- **Tôi học được gì?** Event một-lần vs state; `StreamController.
  broadcast` cho event; `events` channel của VM; `stream.first` bắt
  event trong test.
- **Tôi giải thích được gì?** VM bắn event chứ không Navigator/
  SnackBar — widget quyết định hiển thị; broadcast không replay nên
  listener trễ bỏ lỡ (bài Tự làm — đối lập BehaviorSubject M14).
- **Tôi viết được gì không copy?** Dự đoán late-listener trên
  broadcast stream và giải thích — đây là chìa mở "state vs event"
  của M14.
- **Nếu X đổi thì sao?** `events` đổi thành `BehaviorSubject` — màn
  mở lại thấy snackbar cũ bay ra (state khi cần event = bug).
- **Concept cần lại sau:** broadcast-event → `events` channel M14
  (vẫn giữ, song song `userProfileStream`); `stream.first` — mọi
  event test sau; subscription trong `didChangeDependencies` → VM
  `listen` ctor M14.
