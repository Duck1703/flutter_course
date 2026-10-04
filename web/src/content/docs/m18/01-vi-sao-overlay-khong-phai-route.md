---
title: "Bài 1 · Vì sao onboarding là overlay, không phải route"
description: "Mental model của M18: onboarding hiện trên menu như một lớp widget trong Stack — visibility là state đọc từ repo, không phải một route được push. Checkpoint: hiểu được vì sao senior chọn Stack + Positioned.fill."
sidebar:
  label: "Bài 1 · overlay ≠ route"
  order: 1
---

## Mục tiêu

- Giải thích được vì sao onboarding *không* được `Navigator.push`/
  `showDialog`: nó là lớp widget đè trong `Stack` của menu.
- Nhận ra pattern "visibility = state": một cờ persist
  (`onboarding_completed`) quyết định widget có render hay không.
- Đọc được sơ đồ gating: đọc cờ → chưa xong thì hiện; xong thì không
  bao giờ hiện lại.

## Bạn đang ở đâu

- M14–M17 xong: ba repository + `BehaviorSubject`/`ValueStream`,
  settings persist (kể cả `languageCode`), l10n pipeline sống —
  đổi `MaterialApp.locale` không cần restart.
- `OnboardingRepository` đã tồn tại từ M14 (`loadOnboardingCompleted`,
  `setOnboardingCompleted`, `onboardingCompletedStream`) nhưng chưa
  có consumer — M18 là lần đầu nó được dùng thật.
- Bài này chỉ dựng mental model; code bắt đầu ở Bài 2.

## Vì sao việc này quan trọng ngay bây giờ

App cần màn "chào mừng" chỉ hiện đúng một lần — *trên* màn menu.
Cách dễ nghĩ nhất là `Navigator.push` một route mới. Nhưng route có
nghĩa là một màn hình *tồn tại* trong stack: back button quay lại
được, và nó *che khuất* menu phía sau thay vì nằm trong cây của nó.
Senior không làm vậy — onboarding của senior là widget trong `Stack`
của menu. Nếu bạn bỏ qua "vì sao", Bài 4 sẽ chỉ là copy code.

## Bạn đã biết gì

- `Stack` xếp lớp widget (dùng trong card/badge ở các bài trước).
- `Positioned.fill` = con chiếm hết vùng `Stack`.
- `HitTestBehavior.opaque` — nuốt tap trên vùng "trống" (F-23, M16).
- Repository stream + `BehaviorSubject` seeded value (M14).
- `FutureBuilder` chờ một `Future` (F-10).
- `GameDialogState` render-by-state (A-14, M15) — cùng ý tưởng.

## Mental model mới — "visibility là state, không phải route"

> Route hỏi *"đi đâu tiếp theo"*; overlay hỏi *"đang hiện hay ẩn"*.
> Khi câu trả lời là một cờ trong repository, UI đúng nghĩa là một
> widget render-theo-giá-trị — `Positioned.fill` trong `Stack`.

Đây là cùng mental model M15: UI render *vì* state, không *sau khi*
một hành động điều hướng xảy ra. "Đóng onboarding" = set cờ trong
repo → stream emit → widget tự biến mất — không có `pop`.

## Ví dụ độc lập

```dart
// Không phải code app — chỉ để thấy model:
Stack(
  children: [
    MenuContent(),                    // lớp dưới — luôn render
    if (showOnboarding)               // ← visibility = state
      const Positioned.fill(child: OnboardingOverlay()),
  ],
)
```

`showOnboarding` là `!onboardingCompleted` — giá trị đọc từ repo.
Không `push`, không `pop`, không barrier của `showDialog`.

## Android / Compose bridge

- **SIMILARITY**: Compose hiển onboarding bằng `if (state) { Box
  overlay }` bên trong màn — cùng ý tưởng visibility-by-state.
- **DIFFERENCE**: overlay Flutter này *không* nằm trong route stack —
  back button/`PopScope` không "đóng" nó; thứ đóng nó là state.
- **DO NOT ASSUME**: "màn hình đầu tiên" ≠ route đầu tiên. Senior
  vẫn vào menu như thường — overlay chỉ là lớp vẽ đè trong menu.

## Senior project connection

- `lib/widgets/menu/menu_screen_view.dart` (senior): `Positioned.fill
  (child: OnboardingOverlayScope())` trong `Stack` của menu —
  learner M18 làm đúng vậy.
- `onboarding_overlay.dart` (senior): `BackdropFilter` blur + haze
  scrim + `AnimatedSwitcher` — learner giữ scrim + tap-absorber, bỏ
  phần hiệu ứng (FR-32 → parity M28).
- Gating chain senior `FutureBuilder → StreamBuilder → Provider`:
  learner giữ `FutureBuilder` + `Provider`, bỏ `StreamBuilder` trong
  vì VM tự subscribe stream (EXPLAIN_ONLY — giải thích, chủ động
  rút gọn, đã register).

## Chạy và quan sát

Chưa có code mới — hành động quan sát: mở `lib/screens/
menu_screen.dart`, lần từ `Scaffold → body` xuống `Container`
(gradient) → `SafeArea` → `Center` → `ConstrainedBox` → `Column`,
tự hỏi "nếu đặt overlay ở đây, cấu trúc `Stack` phải trông thế
nào?" — Bài 4 trả lời bằng code thật.

## Kiểm tra hiểu biết

1. Vì sao `Navigator.push` là lựa chọn sai cho onboarding?
2. "Đóng" overlay bằng cách nào nếu nó không phải route?
3. `HitTestBehavior.opaque` giải quyết vấn đề gì ở đây?

## Ta cố ý chưa thêm

- `BackdropFilter`/`AnimatedSwitcher`/badge gradient (FR-32 → M28).
- Permission thật cho thông báo (FR-27 → M27).
- Nhạy ứng back-button — senior cũng không gate back; overlay chỉ
  hút tap.

## Checkpoint hoàn thành

Trả lời được 3 câu trên + nói ra được chỗ chèn `Stack` trong
`menu_screen.dart`. Sang [Bài 2](/m18/02-step-state-sealed-onboarding/)
— model 3 bước + chuỗi ARB.
