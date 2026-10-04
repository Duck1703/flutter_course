---
title: "M28 — Visual Parity: Tokens, SVG, CustomPainter, Motion"
description: "6 bài: nền móng — 2 dep (flutter_svg/google_fonts) + 8 asset + `AppTokens`/`AppAssets`/`surfaceGlow`/`DesignFrame` + 6 ARB key (+0) → chrome chung `QzdsGameButton`/`GlassIconButton`/`GameScreenBackground` + SvgPicture colorFilter (+4) → `AnimationController`×2 + `CustomPainter` stadium cho countdown timer (+7) → trigger-based `animationTrigger` cho số tiền đếm nhảy + reduce-motion (+6) → bề mặt game: answers/question/audience-poll + toàn bộ subsystem dialog mới (shell + 3 family + layer runtimeType-keyed) (+13) → hội tụ atomic: `icon`→`iconAsset`, mapper→AppAssets, lifeline SVG/painter, `GameScreen` thin-shell, xoá 2 file cũ, rewrite screen test (+20) → 309/309. Game visual parity converge."
sidebar:
  order: 0
  label: Tổng quan M28
---

# M28 · Visual Parity: Tokens, SVG, CustomPainter, Motion

Cuối M27, app đã **đủ chức năng**: ván chơi chạy trọn bằng DRE
thuần, notification thật, share thật, version thật — **259/259**
test. Nhưng nhìn hai màn hình cạnh nhau, ai cũng thấy: app của
mình *phẳng* — đáp án là container trơn, đồng hồ là text,
lifeline là `IconData` Material, dialog là khung đơn giản. Senior
thì *sống*: countdown pill có thanh tiến trình gradient chạy
quanh viền, số tiền đếm nhảy kèm glitch cyan/magenta, lifeline là
SVG trên nền gradient xoay + ripple, dialog là card trắng viền
gradient với sheen. Milestone này **không thêm tính năng** — nó
xây lại lớp da: port `AppTokens`/`AppAssets`, hai dependency mới
(`flutter_svg`, `google_fonts`), painter + animation thật, và cuối
cùng thay nguyên `GameScreen` bằng bản senior — đóng ba cụm
parity: design tokens + countdown timer; phần bề mặt game;
lifeline visual + iconAsset pipeline.

:::note[Triết lý milestone: "port visual, không cải tiến"]
- Mọi file UI mới là **port verbatim senior** (sau rename
  `ai_millionaire` → `ai_millionaire_course` + comment VI) — 28
  file `lib/` khớp byte với byte + 2 file hội tụ chỉ khác
  doc-comment VI. Khi senior bỏ qua
  `disableAnimations` (pulse của timer, sheen/ripple của feature
  button), ta **cũng bỏ qua** — ghi nhận parity cố ý, không
  "sửa giúp".
- **Tokens trước, widgets sau** — mọi màu/khoảng/duration mới
  đều qua `AppTokens`; không hardcode `Color(0xFF…)` rải rác
.
- **Visual mới không đổi hợp đồng** — `GameScreenViewModel`,
  reducer, DRE stream y nguyên M27; `GameScreenData` chỉ đổi một
  field (`icon: IconData` → `iconAsset: String`) và đổi đó kéo
  theo một đợt migration nguyên tử ở Bài 6.
- **Test đi cùng visual** — mỗi cụm port mang theo test senior
  (countdown, money motion, feature button, dialog layer) hoặc
  test viết lại theo shape mới (game_screen_test 14 case).
:::

## Bản đồ bài học

| Bài | Nội dung | Checkpoint |
|-----|----------|-----------|
| [01](/m28/01-nen-mong-tokens-assets/) | 2 dep đúng pin senior (`flutter_svg ^2.3.0`, `google_fonts ^8.1.0`) + 2 asset-dir + 7 SVG + 1 PNG; `AppAssets` **subset** 8 const (còn lại → M29, tránh dangling refs); `surfaceGlow` + `AppTokens` (375 design-width, motion/typography `GoogleFonts.beVietnamPro`) + `DesignFrame` (CORE — tokens là nguồn đúng duy nhất); 6 ARB key semantics mới + regen | **259/259** (+0) |
| [02](/m28/02-chrome-chung-pill-kinh-nen/) | `QzdsGameButton` (pill gradient + `if (icon case final iconData?)` — mới) + `GlassIconButton` (`SvgPicture.asset` + `ColorFilter.mode(srcIn)` — mới) + `GameScreenBackground` (ảnh cover + overlay gradient); test `qzds_game_button_test` 4 case | **263/263** (+4) |
| [03](/m28/03-custompainter-animationcontroller-dong-ho/) | `AnimationController`×2 + `vsync`/`TickerProviderStateMixin` (CORE) — pulse 1↔1.08 ở ≤20%, progress tween 1s; `CustomPainter` stadium `Path` + `computeMetrics`+`extractPath` + gradient `Paint` + `shouldRepaint` (CORE); `didUpdateWidget` sync; `GameScreenTopBar` host đầu tiên | **270/270** (+7) |
| [04](/m28/04-trigger-motion-so-tien-nhay/) | `animationTrigger` int-gate — animation chỉ chạy khi trigger *tăng*; money motion: interpolated digits + `Curves.easeOutCubic.transform` + glitch `ShaderMask`/`Transform`; `MediaQuery.disableAnimations` → `Duration.zero` (reuse); ladder CTA + ladder dialog support | **276/276** (+6) |
| [05](/m28/05-be-mat-game-va-lop-dialog/) | `GameAnswerOption` + colors + list (stagger `Interval`, reveal-blink `TweenAnimationBuilder`); `GameQuestionPanel` (lightning SVG ×2, `AnimatedSwitcher`); `GameAudiencePollRow`; subsystem dialog hoàn chỉnh: `GameDialogShell` + 3 family views + layer mới (`AnimatedSwitcher` keyed `runtimeType`, `BackdropFilter` scrim, `IgnorePointer`, dismiss-rules); semantics nâng `liveRegion`/`value`/`getSemantics` (LIGHT) | **289/289** (+13) |
| [06](/m28/06-hoi-tu-iconasset-atomic-swap/) | **Atomic swap**: `GameFeatureButtonData.icon`→`iconAsset` + mapper→`AppAssets` + vm-test 2-site (cùng lúc — compile-forced); `GameFeatureButton`/bar SVG + painter ripple (`Listenable.merge`); `GameScreenBody`; `GameScreen` thin-shell senior; **xoá** `game_dialog_layer.dart` cũ + `game_dialog_views.dart`; rewrite `game_screen_test` (14→14) + helpers + flow(7) + result-flow(8) + feature-button(5); `menu_screen_ui_events_test` HOA | **309/309** (+20) |

## Kết quả cuối milestone

- `flutter analyze` sạch · `flutter test` **309/309**
  (259 + 0 + 4 + 7 + 6 + 13 + 20) · `flutter build web` PASS.
- Visual parity phần game senior đúng: countdown pill + pulse,
  số tiền đếm nhảy + glitch, answers trượt vào + blink đáp án
  đúng, lifeline SVG gradient-xoay + ripple, dialog card + scrim
  mờ + `DesignFrame` 375.
- 28 file `lib/` là **verbatim-port senior** (diff 0 sau rename) + 2 file hội tụ (doc-comment VI: data/mapper);
  2 file hội tụ (`game_screen_data.dart`, mapper) khác senior chỉ
  ở doc-comment VI; `app_assets.dart` là subset cố ý.
- **`REAL_DEVICE_VISUAL_CHECK: NOT_PERFORMED`** — mọi kiểm chứng
  visual gánh bởi widget test + `flutter build web`; không ai chạy
  app nhìn pixel thật trên thiết bị. **`REAL_DEVICE_PLATFORM_CHECK:
  NOT_PERFORMED`** kế thừa từ M27 — hai dòng này ghi verbatim ở
  Bài 6 + manifest, không claim đã làm.
- **Khớp senior**: AppTokens + countdown; phần bề mặt game
  (game + dialog game — phần onboarding/settings/menu visual
  vẫn M29); lifeline SVG + painter + iconAsset.

## Bảng còn nợ (deferred)

| Còn nợ | Owner |
|---|---|
| `AppAssets` constants còn lại (~58 const: avatars, decorations, leaderboard, settings icons) + asset files tương ứng | **M29** — thêm cùng widget dùng chúng, tránh dangling refs (chính sách subset ở Bài 1) |
| `MenuTokens` → `AppTokens` migration ở menu/onboarding/settings/leaderboard widgets | **M29** — phạm vi phần còn lại |
| `SettingsDialogShell`/`OnboardingGameButton`/`MenuDialogBackdrop`/account-row auth visual/`LevelProgressCard` | **M29** (visual) |
| `SettingItemData.icon: IconData` → `iconAsset` | **M29** — pipeline `SvgPicture` đã sẵn từ M28 |
| `MenuDialogLayer` + `MenuDialogSettings/Auth/SignOut` state transport | **M29** |
| `game_dialog_shell_header_test.dart`, `game_pill_button_glow_test.dart` (senior có, learner chưa port) | — declared gap: senior coverage nhỏ hơn ở hai file này; hành vi header/glow đã được cover gián tiếp qua `game_dialog_layer_test` + `game_screen_test` |
| `GoogleFonts` runtime-fetch (font không bundle trong assets) | — parity cố ý, verbatim senior; offline lần đầu render fallback font hệ thống (senior cũng vậy) |
| Pulse timer + sheen/ripple feature-button *không* honor `MediaQuery.disableAnimations` | — parity cố ý, verbatim senior (reduce-motion chỉ honor ở: money motion→`Duration.zero`, reveal-blink→tắt, dialog transition→0ms) |
| `REAL_DEVICE_VISUAL_CHECK` / `REAL_DEVICE_PLATFORM_CHECK` | — `NOT_PERFORMED`, ghi verbatim L06 |

## Câu hỏi tổng kết (trả lời được 5 câu này là xong M28)

1. Vì sao `AppTokens.screenDesignWidth = 375` + `DesignFrame` mà
   không phải `MediaQuery` responsive? — *Senior thiết kế một
   khung 375pt cố định, căn giữa; mọi spacing/size đọc từ token,
   không đo màn hình — app mobile-first, web hiển thị cột giữa.*
2. `AnimationController` khác `AnimatedOpacity`/`AnimatedContainer`
   ở chỗ nào về ownership? — *Explicit: mình sở hữu controller —
   `vsync` ticker, `forward/reverse/repeat`, `dispose` bắt buộc.
   Implicit: widget tự sở hữu controller nội bộ — mình chỉ đổi
   `duration`/`opacity`/`curve`.*
3. `CustomPainter` vẽ ở đâu trong cây widget và vì sao cần
   `shouldRepaint`? — *`CustomPaint` là `RenderObject` tự vẽ qua
   `Canvas`; `shouldRepaint` để Flutter skip repaint khi delegate
   không đổi gì — painter thuần mà stateless về widget.*
4. Vì sao số tiền không animate mỗi khi `amount` đổi mà cần
   `animationTrigger`? — *`amount` đổi vì nhiều lý do (load lại,
   reset game) — chỉ transition *mới* xứng animation; trigger tăng
   đơn điệu đánh dấu "vừa có transition", widget gate
   `> oldWidget.animationTrigger`.*
5. Swap `icon: IconData` → `iconAsset: String` vì sao phải làm
   atomic một bài thay vì rải hai bài? — *Field DTO đổi phá mọi
   constructor + reader cùng lúc: mapper emits, vm-test dựng,
   screen cũ đọc `data.icon`. Không có trạng thái nửa chừng nào
   compile được — hoặc đổi hết, hoặc không đổi (compile-forced
   atomicity).*
