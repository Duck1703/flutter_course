# M29 — Content Draft Manifest

Bộ bài học M29 — *Senior-Alignment Sweep & Course Completion*.
Bảy bài, mỗi bài khớp một implementation batch trong
`02-implementation-evidence.md`. Format theo template M28
(frontmatter `title`/`description`/`sidebar.order`/`sidebar.label`;
sections chuẩn: Mục tiêu → Bạn đang ở đâu → Vì sao → Bạn đã biết
gì → Mental model → Dart/Flutter → Ví dụ độc lập → Android bridge
→ Senior connection → Build it step by step → Hiểu code → Chạy và
quan sát → Thử nghiệm → Lỗi hay gặp → Tự làm PREDICT/DEBUG/PRODUCE
→ Kiểm tra hiểu biết → Ta cố ý chưa thêm → Checkpoint).

Concept-ID mới đề xuất trong milestone này (chưa có trong
`project-context/LEARNER_CONCEPT_REGISTRY.md` — cần đăng ký):

| ID | Tên | Depth | Bài |
|----|-----|-------|-----|
| **A-40** | Senior-alignment pass / fidelity-sweep discipline — đọc senior → diff → port verbatim (rename + comment VI) → verify (analyze/test/grep); deviation phải documented, không "cải tiến lén"; catalogue byte-parity; điều-kiện-xoá = zero-import | NORMAL | 01–07 (chủ đề xuyên) |
| **F-44** | `package:flutter/widget_previews.dart` (SDK) — `@Preview(name:, group:, size:, wrapper:)` trên top-level `Widget` fn; wrapper `Widget Function(Widget)` cung-cấp app-context; preview ≠ test | LIGHT (appendix) | 07 |

## Lesson inventory

| # | File | Concept IDs trích-dẫn | Checkpoint |
|---|------|------------------------|-----------|
| 00 | `lessons/index.md` | A-21, A-38, A-40(new), F-44(new), D-26/27, F-29/30, A-05/09, A-13, A-15, A-23/24, A-35 | — |
| 01 | `lessons/01-nen-mong-assets-tokens-arb.md` | **A-40(new)**, A-38, A-13, D-31, D-01/D-04, F-25 | **309/309** (+0) |
| 02 | `lessons/02-settings-chrome-iconasset.md` | A-40, A-38, F-42, D-27, D-48, A-15, A-37, F-24, A-14 | **313/313** (+4) |
| 03 | `lessons/03-duong-ong-leaderboard.md` | A-23, A-24, D-26/27, D-41, D-42, D-06, A-15, A-20, F-32, F-37, A-40 | **321/321** (+8) |
| 04 | `lessons/04-be-mat-menu.md` | A-40, A-38, F-30, F-39, F-42, A-15/A-17, F-07, D-27, D-04 | **345/345** (+24) |
| 05 | `lessons/05-lop-dialog-menu.md` | **A-21**, A-05/A-09, A-14, D-26/D-27, D-37, D-28, D-05, F-29, F-30, F-27, F-26, F-13(retired-model), A-15, A-40 | **369/369** (+24) |
| 06 | `lessons/06-visual-onboarding.md` | A-38, F-29, F-30, F-41, A-17, A-37, D-27, D-37, F-10/F-11, A-40 | **383/383** (+14) |
| 07 | `lessons/07-hoi-tu-quet-cuoi.md` | **A-40**, **F-44(new)**, A-12, F-20, F-21, A-19, A-16, A-24, A-35, A-13 | **396/396** (+13) |

## Per-lesson chi tiết

### 01 — `01-nen-mong-assets-tokens-arb.md` → 309/309 (+0)

- Nền móng trước pixel: 50/50 asset byte-parity (`diff -rq`),
  `app_assets.dart` verbatim 45 const (kể cả ~10 const senior-
  ship-nhưng-không-reference), `onboarding_design_tokens.dart`
  verbatim (`OnboardingTokens` delegate→`AppTokens`), ARB +11
  senior key / −2 dead key (`questionCounter`, `gameRoomTitle`),
  `flutter gen-l10n` regen.
- Mental model mới **A-40**: đọc → diff → port verbatim →
  verify; verbatim là mặc định, deviation phải documented.
- Concepts: A-40(new), A-38, A-13, D-31, D-01/D-04, F-25.
- Không test mới — nền-móng test-gián-tiếp qua consumer ở các
  bài sau.

### 02 — `02-settings-chrome-iconasset.md` → 313/313 (+4)

- FR-30: `SettingItemData.icon`(IconData)→`iconAsset`(String);
  `_SettingIconBadge` SVG+gradient enabled/disabled; ~11 file
  settings chrome verbatim (shell/card/section/rows×2/account/
  dialog/scope/picker×3); monolith `settings_dialog.dart` 461d
  xoá; `_SettingsTimePickerOverlay` nested overlay +
  `ModalBarrier(dismissible:false)`; FR-31 phụ: sentence-case
  ARB + `.toUpperCase()` render (31 value-diff).
- Concepts: A-40, A-38, F-42, D-27, D-48, A-15, A-37, F-24.
- Test: `menu_settings_dialog_test`(6) + `notification_time_
  picker_dialog_test`(3) port; net +4 sau retire learner-test.

### 03 — `03-duong-ong-leaderboard.md` → 321/321 (+8)

- FR-14-residual: `LeaderboardEntryData` +`avatarAsset`/
  `avatarUrl`/`rankAsset`/`LeaderboardRowStyle`; `_Leaderboard
  Record.fromMap→toEntry` 3-mapper deterministic; top-10 +
  `maybeSingle` pinned-current-user; VM `requestId` + refresh-
  giữ-pin + `_profileBackedCurrentLeaderboardEntry` overlay;
  `LeaderboardAvatar` 3-tầng-fallback (http/https whitelist →
  initial → asset); seam `@visibleForTesting entryFromRow`
  (documented deviation).
- Concepts: A-23, A-24, D-26/27, D-41, D-42, D-06, A-15, A-20,
  F-32, F-37, A-40.
- Test: `leaderboard_avatar_test`(5) + `menu_leaderboard_
  dialog_test`(11); net +8.

### 04 — `04-be-mat-menu.md` → 345/345 (+24)

- Menu surface decomposition: `MenuScreenContent` (panelGap +
  LayoutBuilder/`minHeight`/Center), `profile/` 5 file (pill
  guest-vàng/auth-mint, ring-theo-tier + EXP bar hai-kênh,
  avatar 3-tầng-fallback), `GradientCtaButton` preset
  `QzdsGameButton` large+textGlow, `ScreenTop/BottomInset`
  fallback 37/24, `LeaderboardEntryCard` trophy-srcIn +
  `menuLeaderboardEntrySubtitle`; auth dialogs + overlay-scope
  + `LanguageChipRow` + `OnboardingGameButton` **re-port
  verbatim** (bản MenuTokens-era retire).
- Concepts: A-40, A-38, F-30, F-39, F-42, A-15/A-17, F-07,
  D-27, D-04.
- Test: gradient_cta(3) + level_progress_card(12) +
  profile_avatar(5) + content_layout(4) = +24.

### 05 — `05-lop-dialog-menu.md` → 369/369 (+24) — TRỌNG TÂM

- FR-29: `MenuDialogState` sealed 5-variant (`isVisible`,
  `transitionKey=>runtimeType`); `MenuDialogLayer` `Animated
  Switcher` + switch kiệt-hợp → 4 scope keyed; `MenuDialog
  Backdrop` blur+scrim+tap-ngoài/nuốt-trong+`foregroundOverlay`;
  `MenuScreenView` Stack + `PopScope(canPop:!isVisible)` +
  `_dialogDismissLocked` (sign-out `isLoading`→`onDismissLock
  Changed`); `MenuViewModel`→`MenuScreenViewModel` + `dialog
  State` equality-guard; `menu_screen.dart` 87-dòng 2-event
  bridge. **4 event `*Requested` + 3 `showXxxDialog` RETIRE —
  zero `showDialog` trong `lib/`** (grep-verified; chỉ 1
  comment lịch-sử trong `game_session_state_data.dart`).
- Dạy-sâu-sáu-điểm: sealed-state; layer; PopScope; dismiss-
  lock; event-vs-state; vì-sao-dialog-là-state-persistent.
- Concepts: A-21, A-05/A-09, A-14, D-26/D-27, D-37, D-28,
  D-05, F-29, F-30, F-27, F-26, F-13 (mô hình bị retire),
  A-15, A-40.
- Test: `menu_dialog_layer_test`(16) + `menu_screen_view_model
  _test`(22) + `sealed_state_test`(5) cập-nhật; net +24.

### 06 — `06-visual-onboarding.md` → 383/383 (+14)

- FR-32: `OnboardingHeaderConfig` + `onboardingHeaderFor`/
  `onboardingDescriptionFor` (config-per-step, switch kiệt
  hợp); `OnboardingDialogCard` shell+clip+header-màu+badge;
  `OnboardingStepActions` AnimatedSwitcher scale+fade key-mang-
  state; `OnboardingStepIndicator` AnimatedContainer 8↔24;
  `OnboardingOverlay` 3-lớp-AnimatedSwitcher + haze +
  `_SkipIntroLink`-ẩn-ready; `OnboardingOverlayScope` khôi-phục
  chain `FutureBuilder`→`StreamBuilder`→`ChangeNotifierProvider`
  (divergence-M18 converge) + `requestPermission` thật;
  **`menu_tokens.dart` DELETED** (zero-import → xoá, A-38
  chốt).
- Concepts: A-38, F-29, F-30, F-41, A-17, A-37, D-27, D-37,
  F-10/F-11, A-40.
- Test: overlay(6) + scope(5) + app(3) + vm(12); net +14.

### 07 — `07-hoi-tu-quet-cuoi.md` → 396/396 (+13)

- `main.dart`/`app_dependency_scope.dart`/`app_navigation_
  controller.dart` verbatim: bootstrap-order (`ensureInit`→
  orientation→env→`[auth]`log→Supabase-init→repo→seed-load→
  runApp), 8-`Provider.value`, conditional-DI 3-ternary,
  `StreamBuilder`→`MaterialApp.locale`, theme-`deepPurple`-
  light, `navigatorKey`+`StateError`.
- Previews appendix: SDK `widget_previews` — `@Preview` +
  wrapper-fns + fake-repo-deps; port 6/12 file (3 catalog +
  3 support); 6 catalog còn-thiếu = declared-gap (**F-44**).
- `docs/release-kit-walkthrough.md`: `scripts/kit` +
  `.release-kit` giải-thích — KHÔNG-chạy/không-vendor.
- FR-31 đóng: 119-key-parity, chỉ-khác-product-name. 7 test-
  file senior + canonical re-ports + async-harness.
- Structure-audit: zero-learner-only-file trong `lib/`.
- Caveats verbatim: `REAL_DEVICE_PLATFORM_CHECK`,
  `REAL_DEVICE_VISUAL_CHECK`, `LIVE_SUPABASE_CONNECTIVITY`,
  `LIVE_AUTH_FLOW`, `LIVE_PROFILE_SYNC` = `NOT_PERFORMED`.
- Concepts: A-40, F-44(new), A-12, F-20, F-21, A-19, A-16,
  A-24, A-35, A-13.
- Test: widget_test(11)+apple_auth(2)+surface_glow(5)+
  dialog_shell_header(3)+pill_button_glow(3)+leaderboard_
  async(4)+canonical-re-ports; net +13.

## Checkpoint sequence

```text
309 →(01:+0) 309 →(02:+4) 313 →(03:+8) 321 →(04:+24) 345
    →(05:+24) 369 →(06:+14) 383 →(07:+13) 396
net +87 test sau-M28
```

## Verify-state khi viết xong

- `grep -rn "MenuSettingsRequested\|MenuLeaderboardRequested\|
  MenuAuthRequested\|MenuSignOutRequested\|showDialog\|
  MenuTokens" learner-app/lib/` → **zero call-site** (chỉ 1
  comment-lịch-sử `game_session_state_data.dart:189`).
- Mọi code-excerpt trong bài đã đối-chiếu file-thật trên-đĩa
  (nguồn trích: `lib/view_models/menu/menu_dialog_state.dart`,
  `lib/widgets/menu/menu_dialog_layer.dart`,
  `menu_dialog_backdrop.dart`, `menu_screen_view.dart`,
  `lib/view_models/menu/menu_screen_view_model.dart`,
  `lib/screens/menu_screen.dart`, `lib/data/settings/setting_
  item_data.dart`, `lib/view_models/settings/settings_item_
  factory.dart`, `lib/widgets/menu/settings/*.dart`,
  `lib/data/leaderboard/leaderboard_entry_data.dart`,
  `lib/repositories/leaderboard/leaderboard_repository.dart`,
  `lib/view_models/leaderboard/leaderboard_dialog_view_model.
  dart`, `lib/widgets/leaderboard/leaderboard_{avatar,row}.
  dart`, `lib/widgets/menu/menu_screen_content.dart`,
  `gradient_cta_button.dart`, `profile/level_progress_card.
  dart`, `profile/profile_avatar_image.dart`,
  `leaderboard/leaderboard_entry_card.dart`,
  `menu/screen_top_inset.dart`, `lib/data/onboarding/
  onboarding_header_config.dart`, `onboarding_content_data.
  dart`, `lib/widgets/onboarding/onboarding_{overlay,overlay_
  scope,step_indicator,step_actions,dialog_card}.dart`,
  `lib/view_models/onboarding/onboarding_view_model.dart`,
  `lib/main.dart`, `lib/core/app_dependency_scope.dart`,
  `lib/navigation/app_navigation_controller.dart`,
  `lib/core/{app_assets,onboarding_design_tokens}.dart`,
  `lib/previews/*`, `docs/release-kit-walkthrough.md`).
- Frontmatter `sidebar.order` 0–7 khớp M28-index-style.
- Concept-IDs: mọi-ID-cũ đã-đối-chiếu-registry (TAUGHT/
  INTRODUCED/REINFORCED — không-PLANNED); A-40 + F-44 là
  **đề-xuất-mới** cần-append-registry khi-accept.
