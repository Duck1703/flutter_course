---
title: "M18 — Onboarding: overlay lần chạy đầu"
description: "5 bài: mental model overlay-không-route → sealed step state + ARB keys → OnboardingViewModel senior-identical → scope gating + menu Stack → widget test + regression. Kết quả: onboarding 3 bước persist một lần, chọn ngôn ngữ đổi locale live."
sidebar:
  order: 0
  label: Tổng quan M18
---

# M18 · Onboarding — overlay lần chạy đầu

App mở lần đầu → màn menu hiện một **lớp phủ** 3 bước: chào mừng +
chọn ngôn ngữ, hỏi thông báo, sẵn sàng chơi. Xong (hoặc "Bỏ qua
giới thiệu") → cờ `onboarding_completed` persist → không bao giờ hiện
lại. Chọn ngôn ngữ trong onboarding **đổi locale toàn app ngay** nhờ
dây chuyền M17.

## Bản đồ bài học

| Bài | Nội dung | Checkpoint |
|-----|----------|-----------|
| [01](/m18/01-vi-sao-overlay-khong-phai-route/) | Vì sao overlay trong `Stack` mà không phải route; visibility = state | hiểu model — chưa code |
| [02](/m18/02-step-state-sealed-onboarding/) | sealed `OnboardingStepState` + 16 key ARB + `gameNextButton` rename + content data | `gen-l10n` exit 0, analyze sạch, 90/90 |
| [03](/m18/03-onboarding-view-model/) | **CORE**: `OnboardingViewModel` — queue bước, `listEquals`, guarded async | VM test 7/7 → 97/97 |
| [04](/m18/04-overlay-scope-va-menu-stack/) | `OnboardingOverlayScope` gating + overlay UI + menu `Stack` + shared `LanguageChipRow` | analyze sạch, 97/97 |
| [05](/m18/05-hoan-thien-tests-tu-lam/) | Widget test overlay + full regression + tự làm | **102/102** + build web |

## Kết quả sau M18

- Cài mới → overlay 3 bước trên menu; hoàn thành/bỏ qua → persist +
  ẩn vĩnh viễn; chọn ngôn ngữ đổi locale live (không restart).
- `OnboardingRepository` (từ M14) có consumer đầu tiên — đúng shape
  senior.
- VM overlay-scoped: tầng lifetime thứ tư (app → screen → dialog →
  overlay).

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** Onboarding là widget trong `Stack` của menu —
   visibility là state (`!onboardingCompleted`), không phải route;
   `OnboardingViewModel` giữ queue `List<OnboardingStepState>`;
   `FutureBuilder` gate chặn render trước khi persist đọc xong;
   VM tự subscribe stream để clear khi cờ bật từ nguồn khác.
2. **Giải thích được?** Vì sao không `Navigator.push`; vì sao
   `listEquals` cần `==` theo giá trị trên variant; vì sao
   `_languageSelectionInProgress` đặt trước `await`; vì sao menu
   test hosts cần `{'onboarding_completed': true}`.
3. **Viết lại không copy?** Tự làm: test "skip ở bước notification
   vẫn persist" + variant `OnboardingCoachmarkStep` (Bài 2).
4. **Nếu … thì sao?** Xóa FutureBuilder gate → overlay chớp trên máy
   đã xem; quên `List.unmodifiable` → state bẩn không qua notify;
   back button → overlay không đóng (không phải route).
5. **Cần ở đâu sau?** M21 dialog layer cùng model "render-by-state
   trong Stack"; M27 permission thật thay simulated grant;
   M28 visual parity.

## Còn lại sau M18

- Nút "Bật thông báo" mô phỏng granted — permission
  thật + lịch hẹn → M27.
- Visual onboarding rút gọn (không blur/AnimatedSwitcher/
  badge/gradient/header-config; scope bỏ StreamBuilder trong) →
  parity pass M28.
- Key onboarding đã đổ bộ (16 key senior-verbatim); còn
  quiz-bank/repo strings + casing convention.
