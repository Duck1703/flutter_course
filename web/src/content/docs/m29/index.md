---
title: "M29 — Senior-Alignment Sweep & Course Completion"
description: "7 bài: nền móng đủ — 50 asset + `AppAssets`/`OnboardingTokens` verbatim + 11 ARB key (+0) → settings chrome `iconAsset` + `_SettingIconBadge` + shell/rows/picker (~11 file verbatim) (+4) → leaderboard pipeline `avatarAsset`/`rankAsset`/`LeaderboardRowStyle` + repo mappers + VM snapshot (+8) → bề mặt menu: 4 profile card + `GradientCtaButton` + `MenuScreenContent` + auth dialogs re-port (+24) → **trọng tâm**: `MenuDialogState` sealed 5-variant + `MenuDialogLayer` runtimeType-keyed + `PopScope` + dismiss-lock + 2-event bridge — zero `showDialog` (+24) → onboarding visual đầy đủ + `MenuTokens` DELETED (+14) → hội tụ cuối: `main.dart`/scope/nav verbatim + previews appendix + release-kit doc + 7 test file + đóng (+13) → 396/396. Mọi ACTIVE_TEMPORARY → CONVERGED/REMOVED; `lib/` = subset của senior."
sidebar:
  order: 0
  label: Tổng quan M29
---

# M29 · Senior-Alignment Sweep & Course Completion

Cuối M28, app đã **đẹp ở phần game**: countdown pill, số tiền
đếm nhảy, lifeline SVG, dialog card trắng — **309/309** test.
Nhưng phần còn lại vẫn *ngôn ngữ cũ*: menu là các private
widget trong `menu_screen.dart`, settings dialog là monolith
`settings_dialog.dart` 461 dòng tự chế, leaderboard row là
text phẳng, onboarding là card đơn giản, và — quan trọng nhất —
menu mở dialog bằng **event một lần + `showDialog` route**,
trong khi game đã có in-tree dialog layer từ M21. Milestone
**cuối** này không thêm tính năng mới — nó quét toàn bộ phần
còn lại theo đúng quy trình đối chiếu senior: đọc file
senior → diff → port verbatim → verify bằng test + grep. Sau
M29, `lib/` của learner là **subset của senior** (chỉ thiếu 6
preview catalog cố ý), **zero file learner-only**, mọi hàng
`ACTIVE_TEMPORARY` trong fidelity register sẽ → `CONVERGED`/
`REMOVED` (flip ở canonical sync cuối milestone).

:::note[Triết lý milestone: "sweep cuối — verbatim là mặc định"]
- Mọi file UI/data/widget port là **verbatim senior** (sau
  rename `ai_millionaire` → `ai_millionaire_course` + comment
  VI). Deviation chỉ tồn tại khi *documented*: dart2js int64
  bound, `@visibleForTesting` seams, `final class` convention,
  product rename `AI Millionaire`.
- **Dialog là state, không phải event** — trọng tâm :
  menu chuyển từ 4 event `*Requested` + `showDialog` sang
  `MenuDialogState` sealed render trong `Stack`, đúng pattern
 game đã có từ M21.
- **Một nguồn token duy nhất** — `MenuTokens` (shim learner
  tự chế M14) bị xoá sau khi consumer cuối port; `AppTokens`
 + `OnboardingTokens` là toàn bộ design language.
- **Test senior đi cùng file senior** — mỗi batch port test
  verbatim; test learner viết trước retire hoặc được thay bằng
  canonical senior.
:::

## Bản đồ bài học

| Bài | Nội dung | Checkpoint |
|-----|----------|-----------|
| [01](/m29/01-nen-mong-assets-tokens-arb/) | 50 asset senior ship đủ (5 dir); `app_assets.dart` **verbatim 45 const** — kể cả ~10 const senior ship nhưng không reference (byte-parity); `onboarding_design_tokens.dart` verbatim (`OnboardingTokens` delegate→`AppTokens`); +11 ARB key senior, −2 dead key learner; `gen-l10n` regen. ** mới**: quy trình đối chiếu senior | **309/309** (+0) |
| [02](/m29/02-settings-chrome-iconasset/) | `SettingItemData.icon`→`iconAsset` + `_SettingIconBadge` SVG badge (enabled/disabled gradient); `SettingsDialogShell`/`SettingsCard`/`SettingsSection`/`SettingSwitchRow`/`SettingTimePickerRow`/`SettingsAccountRow`/`MenuSettingsDialog`/scope/`NotificationTimePickerDialog`/`TimePickerWheels`/`WheelPicker` verbatim; monolith `settings_dialog.dart` 461d xoá; : ARB sentence-case + `.toUpperCase()` tại render | **313/313** (+4) |
| [03](/m29/03-duong-ong-leaderboard/) | `LeaderboardEntryData` +`avatarAsset`/`avatarUrl`/`rankAsset`/`LeaderboardRowStyle`; `_LeaderboardRecord.toEntry` + `_avatarAsset`/`_rankAsset`/`_rowStyle` mappers; VM snapshot (pinned current-user row, refresh không đổi pin); `LeaderboardAvatar` ring màu theo rank + `Image.network` http-guard; list/popup/row/dialog/scope verbatim; seam `@visibleForTesting entryFromRow` | **321/321** (+8) |
| [04](/m29/04-be-mat-menu/) | Profile cards ×4 (`MenuProfileHeader`/`EarningsCard`/`LevelProgressCard`/`StatsCard`) + `ProfileAvatarImage`; `GradientCtaButton` (`QzdsGameButton` large + `textGlow`); `MenuScreenContent` (panelGap + LayoutBuilder center); `ScreenTop/BottomInset`; auth dialogs + `OnboardingOverlayScope` + `LanguageChipRow` **re-port verbatim** (trước là MenuTokens-era adaptations); `OnboardingGameButton` leaf dùng chung | **345/345** (+24) |
| [05](/m29/05-lop-dialog-menu/) | **Trọng tâm** — `MenuDialogState` sealed 5-variant; `MenuDialogLayer` `AnimatedSwitcher` keyed `transitionKey`(runtimeType); `MenuDialogBackdrop` blur+scrim+`DesignFrame`; `MenuScreenView` `PopScope(canPop: !isVisible)` + `_dialogDismissLocked`; `MenuViewModel`→`MenuScreenViewModel` + `dialogState` thay 4 dialog-events; `menu_screen.dart` 87-dòng 2-event bridge (`MenuGameRequested`/`MenuSnackBarRequested`); 4 event class + 3 `showXxxDialog` fns **RETIRED** — zero `showDialog` trong `lib/` | **369/369** (+24) |
| [06](/m29/06-visual-onboarding/) | `OnboardingHeaderConfig` + `onboardingHeaderFor` (config-per-step); `OnboardingDialogCard` (header màu theo step + `headerSheen` + badge gradient+asset); `OnboardingStepActions` (switch sealed → welcome/notification/ready); `OnboardingStepIndicator` `AnimatedContainer` width 8↔24; `OnboardingOverlay` `BackdropFilter` haze + `AnimatedSwitcher` + `_SkipIntroLink`; scope khôi phục `FutureBuilder`→`StreamBuilder`→Provider chain; **`menu_tokens.dart` DELETED** | **383/383** (+14) |
| [07](/m29/07-hoi-tu-quet-cuoi/) | `main.dart`/`app_dependency_scope.dart`/`app_navigation_controller.dart` verbatim (theme `Colors.deepPurple` light, log prefix `[auth]`, bootstrap order, bỏ `goBack<T>` superset); previews appendix: `preview_fixtures`/`preview_sample_data`/`preview_app_dependencies` + 3 catalog (mới — `package:flutter/widget_previews.dart` của SDK); `docs/release-kit-walkthrough.md` (giải thích `scripts/kit`+`.release-kit`, KHÔNG chạy); 7 file test senior + harness; đóng (−3 key learner-only đã retire); structure audit: **zero learner-only file** | **396/396** (+13) |

## Kết quả cuối milestone

- `flutter analyze` sạch · `flutter test` **396/396**
  (309 + 0 + 4 + 8 + 24 + 24 + 14 + 13) · `flutter build web` PASS.
- **`lib/` là subset của senior**: zero file learner-only; thiếu
  đúng 6 preview catalog chưa port (brief-scoped). `test/` có
  đủ mọi file senior + test learner bổ sung (course-added
  coverage: `sealed_state_test`, `localization_switch_test`,
  `menu_provider_scope_test`, `repositories/*`, `helpers/`).
- Zero `showDialog` trong `lib/` (grep sạch — chỉ còn một
  comment lịch sử), zero `MenuTokens`, zero 4 interim event
  class, zero `showXxxDialog` route fn.
- Những phần đã **CONVERGED hết**: menu dialog layer,
  `iconAsset` settings, ARB parity (119 key mỗi bên,
  chỉ khác product-name), onboarding visual + scope
  chain, residuals leaderboard/menu dialog/popup, và
  `_SettingsAccountRow` auth chrome.
- Deviation còn lại = **documented, không phải
  ACTIVE_TEMPORARY**: `level_config` 2⁵³−1 (dart2js), seam
  `@visibleForTesting entryFromRow`, `final class` convention,
  doc-comment VI, `appTitle`+share-message rename, 6/12 preview
  catalogs, `lib/l10n/*.dart` generated.
- **`REAL_DEVICE_PLATFORM_CHECK: NOT_PERFORMED` ·
  `REAL_DEVICE_VISUAL_CHECK: NOT_PERFORMED` ·
  `LIVE_SUPABASE_CONNECTIVITY / LIVE_AUTH_FLOW /
  LIVE_PROFILE_SYNC: NOT_PERFORMED`** — milestone này kiểm
  chứng bằng `analyze` + widget/unit test + `build web`; không
  ai chạy device thật hay gọi Supabase live. Ghi verbatim,
  không claim đã làm.

## Bảng còn nợ (deferred)

| Còn nợ | Owner |
|---|---|
| 6 preview catalog senior (`game_controls`/`game_dialog`/`leaderboard`/`menu_auth`/`menu_settings`/`provider_shell` `*_widget_previews.dart`) | — declared gap theo brief: previews là appendix, port subset 6/12 file |
| `GoogleFonts` runtime-fetch (font không bundle) | — parity cố ý kế thừa M28 |
| Pulse/sheen/ripple/auth-size không honor `disableAnimations` | — parity cố ý, verbatim senior |
| Release-kit `scripts/kit` + `.release-kit` | — giải thích tại `docs/release-kit-walkthrough.md`; course không vendor, không chạy |
| `REAL_DEVICE_*` / `LIVE_*` flags | — `NOT_PERFORMED`, ghi verbatim Bài 7 + manifest |

## Câu hỏi tổng kết (trả lời được 5 câu này là xong M29)

1. Vì sao dialog phải là **state** (`MenuDialogState`) chứ
   không phải event một lần `MenuSettingsRequested`? —
   *Dialog tồn tại qua nhiều frame: nó render, nhận back-press,
   nhận dismiss-lock, animate-in/out — event stream bắn một
   lần không giữ được những thứ đó. "Đang hiển thị dialog X"
   là trạng thái; chỉ điều hướng ra ngoài (`MenuGameRequested`)
   và hiệu ứng hết mình (`SnackBar`) mới xứng event.*
2. `ValueKey(state.transitionKey)` trong `MenuDialogLayer`
   khác `ValueKey(dialog.runtimeType)` của game-layer ở chỗ
 nào? — *Cùng ý tưởng key theo loại; menu bọc sẵn
   trong getter `transitionKey => runtimeType` trên base class
   — call-site gọn hơn, semantics giống hệt: variant đổi →
   crossfade, cùng variant → không re-animate.*
3. `_dialogDismissLocked` cần khi nào và luồng của nó? —
   *Khi sign-out đang `isLoading`: scope con báo lên view qua
   `onDismissLockChanged(bool)` → view khoá `PopScope`-dismiss
   và backdrop-dismiss → dialog không thể đóng giữa chừng
   async. Khoá sống ở view (widget state), nguồn sự thật sống
   ở dialog-VM.*
4. Sau M29 `MenuTokens` đi đâu? — *Bị xoá: nó là shim learner
   tự chế khi senior-visual chưa port; sau L06 mọi consumer đã
   đọc `AppTokens`/`OnboardingTokens` → file không còn ai
 import, xoá để giữ đúng một nguồn token.*
5. "Verbatim là mặc định" nghĩa gì trong sweep này?
   *Đọc senior → diff → port nguyên bản (sau rename + comment
   VI) → verify test + grep. Deviation chỉ được tồn tại khi
   documented có lý do (dart2js, product rename, test seam);
   còn lại mọi khác biệt là ACTIVE_TEMPORARY phải converge
   hoặc remove — không có vùng xám "hơi khác chút".*
