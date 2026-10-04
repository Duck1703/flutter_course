---
title: "Bài 02 — Settings chrome: `iconAsset`, `_SettingIconBadge`, và cái chết của monolith"
description: "Converge: `SettingItemData.icon` (IconData) → `iconAsset` (String) — data layer đổi type icon, UI layer đổi cách vẽ (gradient badge + SvgPicture). Port verbatim ~11 file settings chrome: `SettingsDialogShell` (LayoutBuilder clamp + header sheen + close), `SettingsCard` (4 section + `_rowsFor` sealed switch + `v$appVersion` + QzdsGameButton save), `SettingsSection`, `SettingSwitchRow`, `SettingTimePickerRow`, `SettingsAccountRow` (auth row — residual), `MenuSettingsDialog` + scope (`_SettingsTimePickerOverlay` foregroundOverlay — nested overlay pattern), `NotificationTimePickerDialog`/`TimePickerWheels`/`WheelPicker`. Monolith `settings_dialog.dart` 461 dòng xoá. phụ: ARB sentence-case + `.toUpperCase()` tại render. +4 test: 313/313."
sidebar:
  order: 2
  label: Settings chrome iconAsset
---

# Bài 02 — Settings chrome: `iconAsset` và cái chết của monolith

## Mục tiêu

Sau bài này bạn sẽ:

- Hiểu vì sao `SettingItemData.icon` kiểu `IconData` là một
  **sai khác tạm thời** với senior — và vì sao đổi sang `String iconAsset`
  không chỉ là đổi một field mà là đổi cả *cách vẽ icon*
  (Material glyph → SVG asset trong gradient badge).
- Biết mẫu **data-layer trước, UI-layer sau**: đổi type ở
  `sealed class` DTO rồi để compile error dẫn đường tới mọi
  consumer — một lần nữa, sealed-family là công cụ điều phối
 refactor.
- Đọc được anatomy của một dialog "senior-grade" phân mảnh:
  shell (khung + header + close) → card (sections + save) →
  section (nhóm tiêu đề) → row (switch/time-picker) — mỗi file
  < 200 dòng, mỗi lớp một trách nhiệm.
- Hiểu **nested overlay**: settings dialog có thể mở thêm
  time-picker dialog *bên trong* — không qua route, mà qua
  `foregroundOverlay` slot của `MenuDialogBackdrop` + một
  `ModalBarrier` thứ hai.
- Nắm convention: **ARB giữ sentence-case, `.toUpperCase()`
  ở render** — vì casing là quyết định trình bày, không phải
  quyết định nội dung.

## Bạn đang ở đâu

Sau Bài 01 nền móng đã đủ. Giờ nhìn vào settings — vùng chạm
đầu tiên của sweep:

```text
learner (trước bài này):
  lib/widgets/menu/settings_dialog.dart   461 dòng — MỘT file chứa
       shell + header + sections + rows + account + time-picker
       + close + version … private-widget chất chồng
  lib/data/settings/setting_item_data.dart
       field `IconData icon` — Material glyph, không phải SVG
  icon hình tròn đơn sắc; không có header vàng sheen;
       không có account row; casing 'SETTINGS' nướng sẵn trong ARB

senior lib/widgets/menu/settings/:
       11 file — shell/card/section/row×2/account/dialog/scope/
       time-picker×3 — mỗi file một trách nhiệm
```

 Trong danh sách đối chiếu với senior, mục tương ứng ghi đúng hai chữ "icon IconData"
nhưng kéo theo toàn bộ chênh lệch chrome. Và phần residual còn dở:
trong app senior, đăng nhập/đăng xuất không chỉ nấp sau avatar
menu — `SettingsAccountRow` đưa hành động tài khoản vào ngay
settings dialog.

## Vì sao việc này quan trọng ngay bây giờ

Settings dialog là **dialog phức tạp nhất của menu-side**: nó
đủ mọi khó — sealed DTO, VM scoped, permission-as-state, nested
overlay, wheel picker, auth chrome. Port xong nó, mọi dialog
còn lại (leaderboard, auth, sign-out) là bài tập nhẹ hơn vì
pattern đã thấy hết ở đây. Đây cũng là nơi đầu tiên `iconAsset`
xuất hiện — convention sẽ lặp lại ở leaderboard (`rankAsset`,
`avatarAsset`) ở Bài 03 và onboarding badge ở Bài 06: **icon
là path asset, không phải glyph font**.

## Bạn đã biết gì

| Đã học | Ở đâu | Nhắc ngắn |
|---|---|---|
| sealed class + exhaustive switch | M15, M22 | `SettingItemData` đã là sealed 2-variant; `_rowsFor` switch không cần `default` |
| `SvgPicture.asset` + `ColorFilter` | M28 | Game icon đã SVG hoá; settings là vùng `IconData` sót lại |
| Dialog-scoped VM | M16 | `SettingsViewModel` sống/chết cùng dialog subtree qua `ChangeNotifierProvider(create:)` trong scope |
| Permission-as-state | M27 | `effectiveNotificationEnabled = setting && hasPermission` — quyền OS là input của render |
| `ListWheelScrollView` | M16 | `WheelPicker`/`TimePickerWheels` — drum-picker giờ:phút |
| Token nguồn duy nhất | M28·01 | `AppTokens.settingsIconGradient`, `qzdsIconBadgeSm`… đã có sẵn từ nền móng |
| Quy trình sweep | M29·01 | Đọc → diff → port verbatim → verify |

## Mental model củng cố — "DTO sealed chỉ đường, monolith nát thành lớp"

Hai pattern cũ gặp nhau ở đây:

**1. Field-type swap lan bằng compile error** — đổi `IconData
icon` thành `String iconAsset` ở base class sealed: compiler
lập tức chỉ mọi constructor call, mọi `item.icon` consumer.
Bạn không "tìm chỗ cần sửa" — compiler liệt kê hộ. Đây là lý
do sealed + `final` field là nền refactor an toàn.

**2. Monolith → decomposition theo trục "đổi vì lý do gì"** —
461 dòng `settings_dialog.dart` trộn 5 lý do đổi: khung dialog
(shell), nội dung (card), nhóm (section), một dòng (row), tài
khoản (account). Senior tách mỗi trách nhiệm một file — và bản
thân *tên file* trở thành documentation.

## Dart cần dùng

| Dart | Vai trò ở đây | Xem lại |
|---|---|---|
| `String iconAsset` thay `IconData icon` | DTO mang path, UI quyết định render | mới |
| `if (item.subtitle case final subtitle?)` | if-case destructuring — chỉ render dòng phụ khi có | |
| `switch (item) { SettingSwitchItemData() => … SettingTimePickerItemData() => … }` | switch-expression kiệt hợp trên sealed → row tương ứng | |
| `'v$appVersion'` | interpolation hiển thị version; rỗng → ẩn row | cơ bản M01 |
| `label.toUpperCase()` | casing tại render, không tại ARB | |

## Flutter cần dùng

| Flutter | Vai trò ở đây | Xem lại |
|---|---|---|
| `SvgPicture.asset(path, semanticsLabel:)` | icon SVG trong badge + header | |
| `LinearGradient` trên `Container` | badge enabled/disabled — màu trạng thái là *gradient khác*, không phải opacity | mới tại đây |
| `LayoutBuilder` + `ConstrainedBox(maxHeight:)` + `SingleChildScrollView` | dialog co theo viewport thay vì overflow | |
| `ModalBarrier(dismissible: false)` trong `foregroundOverlay` | time-picker chặn tap xuống dialog dưới | nested overlay |
| `ListWheelScrollView` | drum giờ/phút | |
| `Switch` + `WidgetStateProperty.resolveWith` | track/thumb/outline theo trạng thái | M16 |

## Ví dụ độc lập — iconAsset chạy qua sealed family

```dart
/// VÍ DỤ ĐỘC LẬP — DartPad chạy được (không cần Flutter UI).
/// Mô phỏng: DTO đổi icon-type, sealed switch chọn renderer.
sealed class Item {
  final String iconAsset; // trước là IconData — giờ là path
  const Item({required this.iconAsset});
}

final class SwitchItem extends Item {
  final bool on;
  const SwitchItem({required super.iconAsset, required this.on});
}

final class PickerItem extends Item {
  final int hour;
  const PickerItem({required super.iconAsset, required this.hour});
}

String render(Item item) => switch (item) {
  SwitchItem() => 'switch-row asset=${item.iconAsset} on=${item.on}',
  PickerItem() => 'picker-row asset=${item.iconAsset} h=${item.hour}',
};

void main() {
  const items = [
    SwitchItem(iconAsset: 'assets/speaker.svg', on: true),
    PickerItem(iconAsset: 'assets/filter.svg', hour: 9),
  ];
  items.map(render).forEach(print);
}
```

## Android / Compose bridge

:::note[Android / Compose bridge — "vector drawable vs font glyph"]
- **SIMILARITY**: `IconData`→`iconAsset` giống chuyển từ
  `Icons.Default.*` (font glyph) sang `painterResource(R.drawable
.speaker)` — asset riêng của app, giàu màu, giống hệt senior.
- **IMPORTANT DIFFERENCE**: `SvgPicture.asset` nhận *path
  string* — mất compile-time safety của `IconData` (typo path
  chỉ lỗi runtime). Bù lại bằng `AppAssets` const catalogue
  (Bài 01) — đó là lý do catalogue phải đi trước.
- **DO NOT ASSUME**: đừng nghĩ `enabled=false` = `Opacity(0.4)`.
  Badge tắt là **gradient xám khác hẳn** (`qzdsGrey100` →
  `qzdsGrey100@0.8`), không phải làm mờ badge bật — trạng thái
  là design riêng, không phải phép toán trên trạng thái kia.
:::

## Senior project connection

| File senior @ `main@c8eb860` | Dùng để chứng minh |
|---|---|
| `lib/data/settings/setting_item_data.dart` | `iconAsset` field — shape sealed y hệt, chỉ type icon đổi |
| `lib/view_models/settings/settings_item_factory.dart` | `AppAssets.icon{Speaker,Music,Vibration,BellNotification,Filter}` — data-layer nối catalogue |
| `lib/widgets/menu/settings/setting_switch_row.dart` | `_SettingIconBadge` — badge gradient + SVG, enabled/disabled |
| `lib/widgets/menu/settings/settings_dialog_shell.dart` | shell: LayoutBuilder clamp, header vàng + `headerSheen`, close button |
| `lib/widgets/menu/settings/settings_card.dart` | 4 `SettingsSection` + `_rowsFor` sealed switch + `v$appVersion` + `QzdsGameButton` done |
| `lib/widgets/menu/settings/settings_account_row.dart` | auth row — residual converge |
| `lib/widgets/menu/settings/menu_settings_dialog_scope.dart` | `ChangeNotifierProvider(create:)` + `_SettingsTimePickerOverlay` foregroundOverlay |
| `lib/widgets/menu/settings/{notification_time_picker_dialog,time_picker_wheels,wheel_picker}.dart` | picker stack — ListWheel drum |
| *(deleted)* `lib/widgets/menu/settings_dialog.dart` (learner, 461d) | monolith retire — zero import sau port |
| `test/widgets/menu_settings_dialog_test.dart` (6) + `test/widgets/notification_time_picker_dialog_test.dart` (3) | test port verbatim; net +4 sau khi `settings_dialog_test` cũ retire |

## Build it step by step

### Bước 1 — Đổi field ở DTO, để compiler dẫn đường

```dart
// learner-app/lib/data/settings/setting_item_data.dart (trích)
sealed class SettingItemData {
  final String iconAsset;   // ← trước: final IconData icon;
  final String text;
  final String? subtitle;
  final SettingType settingType;
}

final class SettingSwitchItemData extends SettingItemData {
  final bool isEnabled;
  // … equality so sánh iconAsset thay icon
}

final class SettingTimePickerItemData extends SettingItemData {
  final int hour;
  final int minute;
  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
```

:::tip[Field-swap recipe]
Đổi field ở base sealed → `flutter analyze` → compiler liệt kê
mọi constructor call và mọi `item.icon` cũ. Sửa theo danh sách
đó, không theo trí nhớ. `equality`/`hashCode` phải đổi cùng
field — sót là test equality đỏ.
:::

### Bước 2 — Factory nối DTO với catalogue

```dart
// learner-app/lib/view_models/settings/settings_item_factory.dart (trích)
return [
  SettingSwitchItemData(
    iconAsset: AppAssets.iconSpeaker,          // ← const Bài 01
    text: soundText,
    isEnabled: settings.soundEnabled,
    settingType: SettingType.sound,
  ),
  // … music → iconMusic, haptic → iconVibration
  SettingSwitchItemData(
    iconAsset: AppAssets.iconBellNotification,
    text: notificationsText,
    subtitle: notificationsHint,
    isEnabled: effectiveNotificationEnabled,
    settingType: SettingType.notifications,
  ),
  if (effectiveNotificationEnabled)
    SettingTimePickerItemData(
      iconAsset: AppAssets.iconFilter,
      text: notificationTimeText,
      hour: settings.notificationHour,
      minute: settings.notificationMinute,
      settingType: SettingType.notifications,
    ),
];
```

Lưu ý `collection-if`: row chọn giờ **chỉ tồn tại** khi
notification effective — danh sách item đã là "view" của trạng
thái, UI không phải `if` lần nữa (render-by-state).

### Bước 3 — `_SettingIconBadge`: icon là design, không phải glyph

```dart
// learner-app/lib/widgets/menu/settings/setting_switch_row.dart (trích)
class _SettingIconBadge extends StatelessWidget {
  final String iconAsset;
  final String semanticLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final gradient = enabled
        ? AppTokens.settingsIconGradient
        : LinearGradient(
            colors: [
              AppTokens.qzdsGrey100,
              AppTokens.qzdsGrey100.withValues(alpha: 0.8),
            ],
          );

    return Container(
      width: AppTokens.qzdsIconBadgeSm,
      height: AppTokens.qzdsIconBadgeSm,
      padding: const EdgeInsets.all(
        (AppTokens.qzdsIconBadgeSm - AppTokens.qzdsIconXs) / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusMd),
        gradient: gradient,
      ),
      child: SvgPicture.asset(iconAsset, semanticsLabel: semanticLabel),
    );
  }
}
```

Ba điểm dễ trượt:
- **Padding tính từ token**: `(badgeSm - iconXs) / 2` — icon
  luôn giữa badge dù đổi size; không hardcode `8`.
- **Disabled ≠ mờ**: gradient xám riêng, không phải
  `Opacity(0.4)` quanh badge bật.
- **`semanticsLabel` từ data**: `item.text` truyền xuống —
  screen reader đọc "Sound icon" qua `settingsIconSemanticLabel`
  (key mới Bài 01).

### Bước 4 — Shell: khung có clip, header có sheen

```dart
// learner-app/lib/widgets/menu/settings/settings_dialog_shell.dart (trích)
return ConstrainedBox(
  constraints: BoxConstraints(maxHeight: constraints.maxHeight),
  child: SingleChildScrollView(
    child: Container(
      decoration: BoxDecoration(
        gradient: AppTokens.settingsDialogOuterGradient,
        borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusLg),
        // …
      ),
      child: Container(
        // card clips children — header bo đúng curve của card
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppTokens.white100,
          borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusLg),
        ),
        child: Stack(
          children: [
            _SettingsHeader(text: headerText, iconAsset: iconAsset),
            Padding(/* content offset qua header */ child: child),
            if (onClose != null) Positioned(/* top-right */ …),
          ],
        ),
      ),
    ),
  ),
);
```

Comment senior (verbatim) giải thích vì sao card dùng
`clipBehavior` thay `border`: *"A border here would inset the
header by a pixel while it kept the card's radius, and the two
off-centre arcs leave a rim that thickens at the corners."* —
đây là kiểu comment "vì sao KHÔNG làm cách hiển nhiên" đáng
giá nhất của verbatim port.

### Bước 5 — Card: `_rowsFor` switch kiệt hợp + casing tại render

```dart
// learner-app/lib/widgets/menu/settings/settings_card.dart (trích)
return SettingsDialogShell(
  key: const ValueKey('settings-card'),
  headerText: l10n.settingsTitle.toUpperCase(),   // ← senior
  iconAsset: AppAssets.iconSetting,
  onClose: onSaveSettings,
  child: Column(
    children: [
      SettingsSection(title: l10n.settingsSectionLanguage, …),
      SettingsSection(title: l10n.settingsSectionAudio,
        children: _rowsFor(const {
          SettingType.sound, SettingType.music, SettingType.haptic})),
      SettingsSection(title: l10n.settingsSectionNotifications, …),
      SettingsSection(title: l10n.settingsSectionAccount, …),
      // 'v$appVersion' rỗng → ẩn; QzdsGameButton save
    ],
  ),
);

List<Widget> _rowsFor(Set<SettingType> types) => [
  for (final item in items)
    if (types.contains(item.settingType))
      switch (item) {
        SettingSwitchItemData() => SettingSwitchRow(
          item: item, onToggle: onSettingToggle),
        SettingTimePickerItemData() => SettingTimePickerRow(
          item: item, onTap: () => onTimePickerClick(item)),
      },
];
```

:::caution[casing là render, không phải content]
Learner cũ có ARB `"settingsTitle": "SETTINGS"` — casing nướng
vào nội dung. Senior: `"settingsTitle": "Settings"` +
`.toUpperCase()` ở widget. Khác biệt có kỷ luật: một nơi
(`dialog`) muốn HOA, nơi khác (menu item) muốn thường — ARB
giữ *ngữ nghĩa*, widget giữ *trình bày*. Batch này đi kèm **31
diff về casing value**: mọi key kiểu 'START GAME' →
sentence-case + uppercase ở chỗ render.
:::

### Bước 6 — Account row + scope với nested overlay

`SettingsAccountRow` (file `settings_account_row.dart`) đưa
hành động tài khoản vào dialog: avatar + tên khi đã đăng nhập,
hint + nút Sign in khi guest; `_AccountActionButton` đổi
filled/outlined theo `isAuthenticated`. Callback `onAccountAction`
đi từ screen → scope → card → row — **data xuống, intent lên**.

```dart
// learner-app/lib/widgets/menu/settings/menu_settings_dialog_scope.dart (trích)
return MenuDialogBackdrop(
  onDismiss: widget.onDismiss,
  foregroundOverlay: const _SettingsTimePickerOverlay(), // ← slot
  child: MenuSettingsDialog(/* … */),
);

// _SettingsTimePickerOverlay.build (trích):
if (!viewModel.timePickerVisible) return const SizedBox.shrink();
return ClipRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: AppTokens.dialogHazeBlurSigma, …),
    child: Stack(fit: StackFit.expand, children: [
      const ModalBarrier(
        key: ValueKey('settings-time-picker-modal-barrier'),
        color: AppTokens.dialogHazeScrim,
        dismissible: false,          // picker đang mở: tap dưới bị chặn
      ),
      SafeArea(child: Center(child: DesignFrame(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque, onTap: () {},
          child: NotificationTimePickerDialog(/*…*/),
        ),
      ))),
    ]),
  ),
);
```

:::note[Nested overlay — dialog trong dialog, không route]
Time-picker **không** push route thứ hai. Nó là state của
dialog-VM (`timePickerVisible`) render vào slot
`foregroundOverlay` của backdrop — một `BackdropFilter` +
`ModalBarrier(dismissible: false)` **thứ hai** phủ lên. Tap
ngoài picker bị barrier chặn (không lan tới backdrop-dismiss
của settings); `GestureDetector(onTap:(){})` trong card nuốt
tap. Đây là áp vào chính nó một lớp nữa — overlay là
widget trong Stack, do state quyết định.
:::

## Hiểu code — 6 chi tiết dễ trượt

**1. `headerSheen` là token const ở `app_design_tokens.dart`**
— `DecoratedBox(gradient: headerSheen)` phủ lên header vàng;
không có `alignment` trên container header vì nó sẽ wrap sheen
vào `Align` làm sheen co về đúng chiều cao title-row (comment
verbatim trong file).

**2. `Switch` không render chữ "on/off"** — chỉ thumb/track;
trạng thái đọc qua badge + track color. `WidgetStateProperty
.resolveWith` trả `qzdsYellow600` khi selected — outline đổi
theo state, không phải const.

**3. `SettingsCard` key `'settings-card'`, save key
`'settings-save-button'`** — test và preview tìm widget bằng
`find.byKey`; key này là **contract** senior chọn sẵn, đổi key
= test senior port về đỏ ngay. Verbatim cả string key.

**4. `onClose: onSaveSettings` — nút ✕ cũng "save"** — senior
gộp dismiss vào `saveSettings` event (`SettingsDismissRequested`)
vì settings persist *lúc toggle*, không phải lúc đóng. Nút ✕
chỉ là "đóng" — không có dirty-state để commit.

**5. `_snackBarText` là switch-expression kiệt hợp** trên
`SettingsSnackBarMessage` 4-variant — thêm enum mới quên nhánh
= compile error (ở event-enum, không chỉ ở class).

**6. `didLoadSettings` guard trong event-bridge** —
`_attachViewModel` chạy ở `didChangeDependencies` (có thể chạy
lại khi dependency đổi); flag `_didLoadSettings` đảm bảo
`loadSettings()` chỉ fire một lần dù bridge rebuild.

## Chạy và quan sát

```bash
cd learner-app
flutter analyze                                  # clean
flutter test test/widgets/menu_settings_dialog_test.dart \
             test/widgets/notification_time_picker_dialog_test.dart
# 6 + 3 case port verbatim
flutter test                                   # 313/313 (+4)
ls lib/widgets/menu/ | grep settings_dialog    # monolith đã xoá
grep -rn "IconData icon" lib/data/settings/    # → trống
grep -rn "\.icon\b" lib/widgets/menu/settings/ # → chỉ iconAsset
```

Quan sát trên app: mở Settings → icon loa/nhạc/rung là SVG
trong badge tím vàng gradient; tắt một switch → badge của nó
chuyển gradient xám; mở Notification Time → nền mờ blur lần
hai, tap ngoài picker không đóng được settings.

## Thử nghiệm

| Thử | Dự đoán | Thực tế |
|---|---|---|
| Đổi `_SettingIconBadge` disabled thành `Opacity(0.4)` bọc badge | Nhìn giống không? | Không — Opacity làm mờ cả icon lẫn viền bo; gradient xám chỉ đổi nền badge, icon SVG vẫn nét. Test pixel khác; designer nhìn khác |
| Bỏ `ModalBarrier(dismissible:false)` khỏi `_SettingsTimePickerOverlay` | Tap ngoài picker làm gì? | Tap lan xuống `MenuDialogBackdrop` → settings dialog dismiss *dưới* picker đang mở — trạng thái vô lý. Barrier thứ hai là bắt buộc |
| Trả `iconAsset: AppAssets.iconSpeaker` cho time-picker item | Compile? | Compile ngon — `iconAsset` chỉ là String; nhầm icon là lỗi *visual*, không phải lỗi type. Catalogue giảm typo nhưng không ngăn nhầm semantics — factory comment theo `SettingType` giúp review |
| Để ARB `"settingsTitle": "SETTINGS"` bỏ `.toUpperCase()` | Có lỗi? | Không lỗi — nhưng ngày một nơi khác cần "Settings" thường lại phải thêm key trùng nghĩa. Convention tách nội dung/trình bày tồn tại vì ngày đó |

## Lỗi hay gặp

| Lỗi | Vì sao | Sửa |
|---|---|---|
| `Unable to load asset: assets/images/icons/speaker.svg` | Bài 01 chưa ship icons/ hoặc path const lệch tên file | quay lại `diff -rq` Bài 01; path const phải khớp tên file case-sensitive |
| `item.icon` còn sót → compile error | quên field-swap ở một consumer | để `flutter analyze` liệt kê — đừng sửa bằng trí nhớ |
| Time-picker mở mà tap ngoài đóng cả settings | thiếu `ModalBarrier`/`GestureDetector` nuốt tap | foregroundOverlay cần cả hai: barrier chặn + opaque tap trong card |
| Badge disabled vẫn tím | dùng `Opacity` thay gradient khác | disabled là `LinearGradient` xám riêng — verbatim `_SettingIconBadge` |
| `'SETTINGS'` trong ARB vẫn hard-coded HOA | chưa áp convention | ARB sentence-case + `.toUpperCase()` tại render (`settings_card.dart:48`) |

## Tự làm

**PREDICT** — Trong `_SettingsTimePickerOverlay`, nếu bỏ
`ModalBarrier` nhưng giữ `GestureDetector(onTap:(){})` quanh
picker, tap vào vùng ngoài picker sẽ làm gì?

:::note[Gợi ý]
Hai cơ chế khác nhau: barrier "ăn" tap vùng trống; detector
quanh card "ăn" tap *trên card*. Vùng trống ngoài card nằm
trên backdrop của ai?
:::

<details>
<summary>Đáp án</summary>

Tap ngoài picker lan xuống `MenuDialogBackdrop` của *settings*
→ `onDismiss` → settings đóng trong khi picker vẫn coi mình
đang mở (VM `timePickerVisible` vẫn true — nhưng scope chứa nó
đã unmount). `ModalBarrier(dismissible:false)` là lớp ngăn
bắt buộc cho overlay lồng.

</details>

**DEBUG** — Tester báo: "switch Notifications bật nhưng icon
chuông vẫn xám". Đọc `buildSettingItems` + `SettingsViewModel
.effectiveNotificationEnabled`, tìm nguyên nhân đúng senior.

:::note[Gợi ý]
`isEnabled` của row notification không đến trực tiếp từ
`settings.notificationEnabled`.
:::

<details>
<summary>Đáp án</summary>

`isEnabled: effectiveNotificationEnabled` = `notificationEnabled
&& _hasNotificationPermission`. Người dùng bật switch
nhưng OS từ chối quyền → `hasPermission=false` → effective=false
→ badge xám + snackbar `notificationPermissionRequired`. Đây
là *hành vi đúng*, không phải bug: switch hiển thị trạng thái
effective, không hiển thị mong muốn.

</details>

**PRODUCE** — Viết lại `_rowsFor` thành một `Widget rowFor(
SettingItemData item)` rồi dùng trong `SettingsSection`. So
sánh với bản list-comprehension hiện tại: bản nào dễ thêm
variant `SettingSliderItemData` hơn?

:::note[Gợi ý]
Cả hai đều cần switch kiệt hợp. Khác biệt nằm ở chỗ lọc
`types.contains` — giữ ở đâu?
:::

<details>
<summary>Đáp án</summary>

```dart
Widget _rowFor(SettingItemData item) => switch (item) {
  SettingSwitchItemData() => SettingSwitchRow(
    item: item, onToggle: onSettingToggle),
  SettingTimePickerItemData() => SettingTimePickerRow(
    item: item, onTap: () => onTimePickerClick(item)),
};

List<Widget> _rowsFor(Set<SettingType> types) => [
  for (final item in items)
    if (types.contains(item.settingType)) _rowFor(item),
];
```

Tách `rowFor` riêng tốt hơn: thêm variant chỉ đụng *một* switch
một chỗ; filter-section giữ nguyên. Senior chọn inline-switch
trong `_rowsFor` vì chỉ có 2 variant — khi variant thứ ba đến,
refactor này là bước tự nhiên.

</details>

## Kiểm tra hiểu biết

**H: Vì sao icon là `String` chứ không phải `IconData`?** —
Vì icon senior là SVG asset riêng, không phải Material glyph.
DTO chỉ mang *tham chiếu* (path); widget quyết định *render*
(`SvgPicture` + badge). Tách tham chiếu/render là cùng một
nguyên tắc với ARB-phrase/render-casing.

**H: `settings_dialog.dart` 461 dòng đi đâu?** — Bị xoá sau
khi 11 file con port xong và `grep` xác nhận zero import. Đây
là mẫu chung của sweep: monolith retire khi decomposition đứng
vững — điều kiện xoá là *zero reference*, không phải cảm giác
"chắc xong rồi".

**H: `ModalBarrier` thứ hai trong overlay khác `ModalBarrier`
của route ở chỗ nào?** — Không khác về bản chất — cùng widget;
khác ở chủ sở hữu: nó do dialog-scope render trong Stack (in-
tree), không do `showDialog` route inject.

**H: Vì sao `Switch` + `GestureDetector` cùng gọi `onToggle`?** —
Row-tap và switch-drag đều là "đổi trạng thái" — senior cho cả
row là hit-target (`HitTestBehavior.opaque`), switch là affordance
trực quan; hai đường kích hoạt, một intent.

## Ta cố ý chưa thêm

- **Chưa render `iconAsset` của time-picker row đặc biệt** —
  `SettingTimePickerRow` dùng cùng badge; khác chỉ ở trailing
  (text giờ thay switch).
- **Chưa port `foregroundOverlay` cho dialog khác** — slot đó
  mới chỉ có settings dùng; auth/sign-out không cần overlay con.
- **`SettingsViewModel` không đổi** — VM đã verbatim từ M27
  (permission, coordinator, app-version seam). Batch này đổi
  *chrome*, không đổi *state machine*.
- **Không thêm test cho từng row nhỏ** — coverage đi qua 6
  case `menu_settings_dialog_test` (dialog-level); row đơn lẻ
  được bao phủ gián tiếp — convention senior.

## Checkpoint hoàn thành

- [x] `setting_item_data.dart`: `String iconAsset` — sealed
 family giữ nguyên shape, equality đổi theo field.
- [x] `_SettingIconBadge`: `SvgPicture.asset` trong gradient
      badge; enabled/disabled = **hai gradient**, không opacity.
- [x] ~11 file settings chrome verbatim; monolith
      `settings_dialog.dart` (461d) xoá, zero import.
- [x] `_SettingsTimePickerOverlay` + `ModalBarrier(dismissible:
      false)` — nested overlay pattern.
- [x] phụ: ARB sentence-case, `.toUpperCase()` tại
      render; 31 value-diff về casing.
- [x] `flutter analyze` clean · `flutter test` **313/313**
      (+4: menu_settings 6 + picker 3 − test cũ retire).

## 🤖 AI Local — Kiểm tra project sau bài này

Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn.

```text
Bạn là Project Alignment Reviewer cho project Flutter tôi đang tự code theo khóa học. Bài tôi vừa học xong: m29/02 — "Settings chrome: `iconAsset`, `_SettingIconBadge`, và cái chết của monolith" (DTO `SettingItemData.icon: IconData` → `iconAsset: String` — data-layer đổi type, UI đổi cách vẽ; port ~11 file `widgets/menu/settings/` verbatim: `SettingsDialogShell` LayoutBuilder-clamp + header-sheen + close, `SettingsCard` 4-section + `_rowsFor` sealed-switch + `v$appVersion` + QzdsGameButton save, `SettingsSection`, `SettingSwitchRow`/`SettingTimePickerRow` + `_SettingIconBadge` gradient+SVG, `SettingsAccountRow` auth-row, `MenuSettingsDialog`+scope `_SettingsTimePickerOverlay` foregroundOverlay nested-overlay, `NotificationTimePickerDialog`/`TimePickerWheels`/`WheelPicker`; `settings_dialog.dart` 461d XOÁ; ARB sentence-case + `.toUpperCase()` render; +4 → 313).

CHỈ REVIEW — KHÔNG SỬA. Được: đọc file, xem cây thư mục, chạy `git status`, `git diff`, `flutter analyze`, `flutter test`. Cấm: sửa file, formatter, `flutter pub get` hoặc đổi dependency/lockfile, patch, commit, reset, revert, refactor, xoá file. Thấy vấn đề → báo cáo + gợi ý hướng sửa trong phạm vi đã học; không tự sửa.

PROJECT ROOT: thư mục chứa `pubspec.yaml`. Nhiều project mà mơ hồ → `BLOCKED_PROJECT_ROOT`.

PHẠM VI: chỉ chấm theo EXPECTED STATE + INVARIANTS bên dưới; ngoài danh sách = không tính thiếu. Field-swap compile-forced — sót `icon:`/`.icon` call-site = analyze-đỏ.

EXPECTED STATE SAU BÀI NÀY:
- `lib/data/settings/setting_item_data.dart` (STRICT): `sealed class SettingItemData` — `final String iconAsset` (was `final IconData icon`); `SettingSwitchItemData`/`SettingTimePickerItemData` ctor `required super.iconAsset`; equality/`hashCode` so `iconAsset` (STRICT sót equality = test-đỏ).
- `lib/view_models/settings/settings_item_factory.dart` (STRICT): emit `iconAsset: AppAssets.iconSpeaker`/`iconMusic`/`iconVibration`/`iconBellNotification`/`iconFilter` per-item (STRICT — `Icons.*` còn = BEHIND); `collection-if` `SettingTimePickerItemData` chỉ-khi `effectiveNotificationEnabled` (render-by-state).
- `lib/widgets/menu/settings/` ~11 FILE MỚI (STRICT verbatim, mỗi <250d):
  - `settings_dialog_shell.dart` — `LayoutBuilder` + `ConstrainedBox(maxHeight:)` + `SingleChildScrollView` + outer `settingsDialogOuterGradient` + inner card `white100` `clipBehavior: Clip.antiAlias` (STRICT clip thay border — header bo đúng curve) + `Stack[_SettingsHeader(text, iconAsset), Padding(child), Positioned close]` + `headerSheen` overlay;
  - `settings_card.dart` — `SettingsDialogShell(key: 'settings-card', headerText: l10n.settingsTitle.toUpperCase(), iconAsset: AppAssets.iconSetting, onClose: onSaveSettings)` + `Column` 4 `SettingsSection` (language/audio/notifications/account) + `_rowsFor(Set<SettingType>)` switch-expression kiệt hợp `SettingSwitchItemData() → SettingSwitchRow / SettingTimePickerItemData() → SettingTimePickerRow` + `v$appVersion` isNotEmpty + `QzdsGameButton` save `key: 'settings-save-button'` (STRICT key-string verbatim — test contract; `toUpperCase()` ở render không ARB);
  - `settings_section.dart` — title + children nhóm;
  - `setting_switch_row.dart` — `_SettingIconBadge` `width/height: AppTokens.qzdsIconBadgeSm` + padding `(badgeSm - iconXs) / 2` tính-từ-token + `LinearGradient` enabled `AppTokens.settingsIconGradient` vs disabled `LinearGradient(qzdsGrey100 → qzdsGrey100@0.8)` (STRICT disabled = gradient-xám-RIÊNG — `Opacity(0.4)` bọc = DIVERGED) + `SvgPicture.asset(iconAsset, semanticsLabel:)`; `Switch` + `WidgetStateProperty.resolveWith` track/thumb/outline;
  - `setting_time_picker_row.dart` — formattedTime + tap;
  - `settings_account_row.dart` — avatar + tên (auth) / hint + Sign-in (guest) + `_AccountActionButton` filled/outlined theo `isAuthenticated` + `onAccountAction` intent-lên (STRICT auth-row residual converge);
  - `menu_settings_dialog_scope.dart` — `ChangeNotifierProvider(create:)` + `MenuDialogBackdrop(foregroundOverlay: const _SettingsTimePickerOverlay())` + `_SettingsTimePickerOverlay` — `timePickerVisible → SizedBox.shrink` : `ClipRect(BackdropFilter(dialogHazeBlurSigma, Stack[ModalBarrier(key: 'settings-time-picker-modal-barrier', dialogHazeScrim, dismissible: false), SafeArea(Center(DesignFrame(GestureDetector(onTap: () {}, NotificationTimePickerDialog))))]))` (STRICT nested-overlay: barrier-thứ-hai chặn tap-xuống-settings; `onTap: () {}` nuốt tap-trên-card);
  - `notification_time_picker_dialog.dart`/`time_picker_wheels.dart`/`wheel_picker.dart` — ListWheel drum giờ:phút;
  - `menu_settings_dialog.dart` — host dialog.
- `lib/widgets/menu/settings_dialog.dart` 461d — **ĐÃ XOÁ** (STRICT còn = retire-incomplete; `grep -rn 'settings_dialog.dart'` lib chỉ về scope-import path mới).
- ARB casing (STRICT): `settingsTitle` = 'Settings'/'Cài đặt' sentence-case (STRICT — 'SETTINGS'/'CÀI ĐẶT' nướng-sẵn = DIVERGED casing-content-lẫn); `.toUpperCase()` tại render chỗ cần HOA.
- `test/widgets/menu_settings_dialog_test.dart` 6-case + `notification_time_picker_dialog_test.dart` 3-case (STRICT verbatim — retire `settings_dialog_test` cũ).
- `flutter analyze` sạch — `grep -rn 'IconData icon' lib/data/settings/` TRỐNG + `grep -rn '\.icon\b' lib/widgets/menu/settings/` chỉ `iconAsset` (STRICT compile-forced completeness); `flutter test` → **313/313** (STRICT 309 + 4).
- KHÔNG ĐƯỢC có (chưa đến): `LeaderboardEntryData.avatarAsset`/`rankAsset`/`style`/`_LeaderboardRecord`/`entryFromRow`/`LeaderboardAvatar`/`LeaderboardEntryCard`/`menu_leaderboard_dialog*` (BÀI 03); `menu_screen_content`/`profile/`×5/`gradient_cta_button`/`screen_*_inset`/`MenuLevelProgress` visual (BÀI 04); `MenuDialogState`/`menu_dialog_layer`/`menu_dialog_backdrop`/`menu_screen_view`/`PopScope canPop`/`_dialogDismissLocked` (BÀI 05 — `showSettingsDialog` route-fn vẫn là transport hiện-tại); onboarding-header-config/dialog-card/step-actions/step-indicator/overlay-4-class/scope-FutureBuilder-chain (BÀI 06); `menu_tokens.dart` xoá (BÀI 06); previews/`main` verbatim (BÀI 07); `MenuSettings*`/`MenuAuth*`/`MenuSignOut*`/`MenuLeaderboard*` `*Requested` events retire (BÀI 05 — `MenuScreenUiEvent` vẫn 6-variant).

INVARIANTS NỀN — phải CÒN NGUYÊN:
- Bài 01: 45-const AppAssets + OnboardingTokens + 50 assets + ARB +11/−2 + 309; M28 visual game-side; `SettingsViewModel` M27 (notificationService/coordinator/effectiveNotificationEnabled/Future.wait/_loadAppVersion — VM KHÔNG đổi, chỉ UI render đổi); `MenuDialogBackdrop`/`foregroundOverlay` slot (đã dùng nested-overlay — file có thể tồn tại từ Bài 02 scope hoặc Bài 05 land — theo senior cả hai dùng); `settings_view_model_test` 12-case; `effectiveNotificationEnabled` AND-gate; `SettingsSnackBarMessage` 4-variant `_snackBarText` switch kiệt hợp; M16 dialog-scoped-VM concept; M24 `AuthRepository`/auth-state (account-row đọc).

Mục (STRICT) phải đúng; mục khác chấm semantic. Code vượt checkpoint → `AHEAD_COMPATIBLE`; thiếu bắt buộc → `BEHIND` + bằng chứng file/symbol. Monolith còn hoặc `icon:` sót = NEEDS_FIX; `Opacity` thay gradient-disabled = DIVERGED; ARB casing nướng HOA = DIVERGED.

OUTPUT (đúng format; mục trống → "None"):
LESSON: m29/02
PROJECT_ALIGNMENT: ON_TRACK | NEEDS_FIX | DIVERGED | BLOCKED
COURSE_POSITION: ON_TRACK | BEHIND | AHEAD_COMPATIBLE | AHEAD_RISKY
READY_FOR_NEXT_LESSON: YES | YES_AFTER_FIXES | NO
VERIFICATION_PERFORMED:
WHAT_MATCHES:
GAPS:
AHEAD_OF_COURSE:
DIVERGENCES:
REQUIRED_FIXES_BEFORE_CONTINUING:
EVIDENCE: file/symbol → observation
FILES_MODIFIED_BY_REVIEW: NONE
```
