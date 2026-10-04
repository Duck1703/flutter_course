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

| # | Bài | Khái niệm chính | Tải concept |
|---|-----|-----------------|-------------|
| 1 | [Vì sao ProfileStore chưa đủ](/m14/01-vi-sao-profilestore-chua-du/) | Repository mental model: storage vs boundary, dependency direction | 1 lớn — thuần lý thuyết, không sửa code |
| 2 | [Contract: abstract interface class, implements, factory create()](/m14/02-contract-abstract-interface-implements/) | Cú pháp contract Dart 3; async factory; viết contract thật | 2 Dart concepts — ví dụ độc lập trước |
| 3 | [Stream cho state: BehaviorSubject & ValueStream](/m14/03-stream-state-behavior-subject-value-stream/) | `.seeded`/`.value`/`isClosed`/`close`, replay, state vs event | 1 concept-family — ví dụ độc lập |
| 4 | [UserProfileRepositoryImpl](/m14/04-user-profile-repository-impl/) | Impl đầu tiên + repo test riêng (additive, app vẫn ProfileStore) | Vận dụng — không concept mới |
| 5 | [Hai repo còn lại + model parity](/m14/05-hai-repo-con-lai-va-model-parity/) | Settings/onboarding repo (lặp pattern); `UserSettingsData`; `UserProfileData` FR-19 | Lặp pattern + data model |
| 6 | [DI theo contract: MultiProvider & fake](/m14/06-di-theo-contract-multiprovider-va-fake/) | `Provider<Contract>.value`, `MultiProvider`, bootstrap, fake repo | 1 lớn (DI) + fake |
| 7 | [MenuViewModel nối stream & retire](/m14/07-menuviewmodel-noi-vao-stream/) | `.value`+`listen` ctor, retire `MenuLoadState`, xoá `profile_store.dart` CUỐI | Vận dụng + tích hợp |

:::note[Vì sao bảy bài?]
Bốn bài cũ nhồi mọi concept nặng (contract + subject + DI + VM
rewire) vào quá ít trang, và bài 1 đòi `flutter analyze` sạch ngay
sau khi xoá `profile_store.dart` — điều không thể khi VM còn dùng nó.
Chuỗi mới tách từng concept một, mọi bước đều **additive** cho tới
bài 7 — checkpoint `analyze` sạch ở mọi trang, và file cũ chỉ bị xoá
khi không còn ai dùng.
:::

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

## Tổng kết M14 — tự kiểm tổng hợp

Trước khi qua M15, tự trả lời (không nhìn lại bài):

- **Tôi học được gì?** Nêu được 5 member của contract
  `UserProfileRepository` và vì sao từng cái tồn tại.
- **Tôi giải thích được gì?** Vì sao `save` emit qua subject thay vì
  trả thẳng; vì sao scope đăng ký theo contract; vì sao
  `MenuLoadState` retire được.
- **Tôi viết được gì không copy?** Một `abstract interface class` +
  impl seeded-subject cho một domain mới (đã làm ở bài 5 Tự làm).
- **Nếu X đổi thì sao?** Nếu impl đổi từ SharedPreferences sang
  remote API — file nào phải sửa, file nào *không*? (VM/scope/widget
  không đổi — đó là điểm của contract.)
- **Concept nào cần lại sau?** `BehaviorSubject`/`ValueStream` (mọi
  repo sau), DI theo contract (mọi `AppDependencyScope` sau),
  `implements`+`create()` (mọi service async).
