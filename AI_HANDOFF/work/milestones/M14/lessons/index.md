---
title: "M14 — Repository contract, BehaviorSubject & ValueStream"
description: "abstract interface class + implements, rxdart BehaviorSubject.seeded, ValueStream + .value, ba repository SharedPreferences, MultiProvider theo contract, và MenuViewModel nối vào stream thay MenuLoadState."
sidebar:
  label: Tổng quan M14
  order: 0
---

## Kết quả sau milestone này

`ProfileStore` concrete của M10 được thay bằng kiến trúc repository
đúng shape senior:

- **Ba contract** `abstract interface class`: `UserProfileRepository`,
  `UserSettingsRepository`, `OnboardingRepository` — cùng file với
  impl `UserProfileRepositoryImpl`, `UserSettingsRepositoryImpl`,
  `OnboardingRepositoryImpl` (SharedPreferences-backed).
- Mỗi impl giữ một **`BehaviorSubject.seeded`** của rxdart và expose
  **`ValueStream<T>`** — state stream luôn biết giá trị hiện tại qua
  `.value`.
- `MenuViewModel` phụ thuộc vào **contract**: seed đồng bộ qua
  `.value`, subscribe `userProfileStream` ngay trong constructor.
  `MenuLoadState`, `load()` tay, `_MenuLoading`, `_MenuErrorState`
  **retire** — stream-seeded nên không còn "khoảng chưa có dữ liệu".
- `AppDependencyScope` thành **`MultiProvider`** đăng ký ba repo dưới
  kiểu contract — test có thể thay impl thật bằng `Fake*`.
- `UserProfileData` đạt field set senior: thêm `totalEarnings`
  (String đã format) và `totalQuestionCount`, `fromMap` parse phòng
  thủ đầy đủ.

Menu giờ tự cập nhật khi bất kỳ ai `saveUserProfile` — không ai cần
gọi "reload" nữa.

## Các bài học

| # | Bài | Khái niệm chính |
|---|-----|-----------------|
| 1 | [Vì sao ProfileStore chưa đủ](/m14/01-vi-sao-profilestore-chua-du/) | Storage primitive vs ranh giới ứng dụng; `abstract interface class`, `implements`; contract-first; xoá `profile_store.dart` |
| 2 | [RxDart: BehaviorSubject & ValueStream](/m14/02-rxdart-behavior-subject-valuestream/) | `rxdart` package, subject seeded, `.value` vs `.stream`, replay, `isClosed`, `dispose` |
| 3 | [Ba repository & MultiProvider](/m14/03-ba-repository-va-multiprovider/) | Impl SharedPreferences, `Provider<Contract>.value`, `create()` bootstrap, `UserProfileData` parity, fake repo |
| 4 | [MenuViewModel nối vào stream](/m14/04-menuviewmodel-noi-vao-stream/) | `.value` + `listen` trong ctor, state stream ≠ event stream, retire `MenuLoadState`, widget test stream propagation |

## Khái niệm được giới thiệu

- **Dart:** `abstract interface class`, `implements`, `Future<void>`
  delegate, null-aware element `'key': ?value` trong map literal.
- **RxDart:** `BehaviorSubject<T>.seeded`, `ValueStream<T>`,
  `.value`, `isClosed`, `close()`.
- **Flutter/DI:** `MultiProvider`, provider đăng ký theo kiểu
  *interface*, `create()` factory async cho dependency.
- **Kiến trúc:** repository contract, state stream vs event stream,
  fake repository cho test (contract-first payoff).

## Tiêu chí hoàn thành

- `lib/repositories/` chứa 3 cặp contract+impl; `pubspec.yaml` có
  `rxdart: ^0.28.0`.
- `MenuViewModel` nhận `UserProfileRepository` qua ctor, seed bằng
  `.value`, subscribe trong ctor, cancel + `_isDisposed` ở dispose.
- `MenuLoadState`, `_MenuLoading`, `_MenuErrorState`,
  `profile_store.dart` không còn trong `lib/`.
- `AppDependencyScope` là `MultiProvider` của 3 `Provider<Contract>.value`.
- `test/helpers/fake_user_profile_repository.dart` lái được VM test
  không cần Flutter/prefs.
- `flutter test` xanh — gồm test repo impl (disk + stream) và widget
  test chứng minh UI cập nhật khi repo emit.
- Vẫn chưa có: sealed event/UI state (M15), settings UI (M16),
  onboarding flow (M18), `GameViewModel`/nav controller (M19).
