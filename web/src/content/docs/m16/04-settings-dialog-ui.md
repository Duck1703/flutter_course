---
title: "Bài 4 · Settings dialog — Switch row, chips, gear → event → dialog"
description: "Switch control đầu tiên của course + hàng tap-to-toggle (GestureDetector opaque) + language chips + account row; icon gear → MenuSettingsRequested → showDialog; event bridge trong dialog."
sidebar:
  label: "Bài 4 · Settings dialog UI"
  order: 4
---

## Mục tiêu

Sau bài này bạn **làm được**:

- Dùng `Switch` đúng nghĩa **controlled component**: `value` từ data,
  `onChanged` gọi VM — Switch không tự giữ state.
- Bọc cả hàng bằng `GestureDetector(behavior: HitTestBehavior.opaque)`
  để bấm đâu cũng toggle — đúng senior `SettingSwitchRow`.
- Nối đường: gear icon → `requestSettings()` → `MenuSettingsRequested`
  → bridge → `showDialog` → `SettingsDialogScope` → VM sống trong
  dialog.
- Render danh sách hàng bằng `switch` kiệt hợp trên sealed
  `SettingItemData`.

## Bạn đang ở đâu

- M16 bài 4/5. Bài 3 đã có `SettingsViewModel`; bài này build **phần
  nhìn thấy**: dialog UI + đường mở dialog từ icon gear.
- Kết bài: bấm bánh răng trên menu → dialog CÀI ĐẶT mở, 4 switch +
  chips ngôn ngữ + hàng tài khoản; picker giờ là bài 5.

## Vì sao việc này quan trọng ngay bây giờ

Đây là lần đầu course có **form control thật**. `Switch` trông đơn
giản nhưng chứa một bẫy tư duy: nó *trông* như tự giữ trạng thái bật/
tắt — thật ra là **controlled**: bạn truyền `value`, nó vẽ; người
dùng chạm → `onChanged` báo lên; ai quyết định đổi `value`? Vòng lặp
persist của bài 1: `onChanged → VM → repo → stream → VM → rebuild`.
Bấm mà `value` chưa đổi = Switch không nhúc nhích — UI là *hệ quả*,
không phải nguồn.

## Bạn đã biết gì

- Event bridge menu (M13): tap → `vm.request…()` → event →
  `showDialog`/snack trong `_handleUiEvent`.
- `showDialog`/`AlertDialog` (M09), `GestureDetector`.
- `Provider` trong subtree + `context.read`/`watch`.
- Sealed item + exhaustive switch render (bài 2 + M15).

## Flutter cần dùng

| API | Ví dụ | Nghĩa |
|---|---|---|
| `Switch` | `Switch(value: item.isEnabled, onChanged: (_) => vm.toggleSetting(item))` | controlled toggle — `value` từ data |
| `GestureDetector(behavior: HitTestBehavior.opaque)` | quanh cả `Row` | bấm đâu trong hàng cũng chạy `onTap` |
| `HitTestBehavior.opaque` | tham số trên | vùng hit-test gồm cả phần "trống" của hàng |
| `CircleAvatar` | placeholder avatar | ảnh đại diện tròn — dùng tạm `Icons.person` |

`Switch` là first-appearance: hãy nhớ — nó **không** có state
riêng. Quên `onChanged` = switch chết; quên cập nhật `value` = switch
giật về.

## Ví dụ độc lập

```dart
bool enabled = false;

// Sai: Switch "trông" bật nhưng value vẫn false → UI nói dối.
Switch(value: enabled, onChanged: (v) {/* không set gì */});

// Đúng: onChanged cập nhật NGUỒN, rebuild đổi value.
Switch(
  value: enabled,
  onChanged: (v) => setState(() => enabled = v),   // isolated demo
);
```

Trong app thật, `setState` được thay bằng `vm.toggleSetting(item)` —
cùng nguyên lý: `onChanged` đổi *nguồn*, không đổi *switch*.

## Android / Compose bridge

- **SIMILARITY:** `Switch(checked=..., onCheckedChange=...)` trong
  Compose y hệt — cả hai đều controlled.
- **IMPORTANT DIFFERENCE:** `HitTestBehavior.opaque` không có tương
  đương trực tiếp — trong Android bạn đặt `onClick` trên row view.
- **DO NOT ASSUME:** `onChanged(null)` (disable) ≠ switch xám —
  disabled là `onChanged: null`; đừng disable bằng cách nuốt callback.

## Senior project connection

- `lib/widgets/menu/settings/setting_switch_row.dart` — senior:
  `GestureDetector(behavior: HitTestBehavior.opaque, onTap: () =>
  onToggle(item))` quanh cả hàng; `Switch` vẫn giữ `onChanged` riêng.
- `lib/widgets/menu/settings/settings_card.dart` — `SettingsCard`
  chia section Language / Audio / Notifications / Account + nút Done;
  `_rowsFor` = switch kiệt hợp trên variant.
- `lib/widgets/menu/settings/menu_settings_dialog_scope.dart` —
  scope bọc provider + event bridge; `SettingsCard` không tự mở
  dialog — scope làm.
- `lib/widgets/menu/profile/menu_profile_header.dart` — gear icon
  `GlassIconButton(iconGear, onTap: onSettingsTap)` →
  `vm.requestSettingsDialog()`; learner tương đương bằng
  `GestureDetector` + `Icons.settings` →
  `vm.requestSettings()` → `MenuSettingsRequested`.

## Build it step by step

**Bước 1 — entry point: `lib/screens/menu_screen.dart`**

Trong `_ProfileHeader` thêm field `onSettingsTap` + icon cuối Row:

```dart
final VoidCallback onSettingsTap;
// ctor: required this.onSettingsTap

// cuối Row của header:
const SizedBox(width: MenuTokens.spacingSm),
// M16: icon cài đặt (senior GlassIconButton(iconGear)).
GestureDetector(
  onTap: onSettingsTap,
  child: const Icon(Icons.settings, color: MenuTokens.textSecondary),
),
```

Call-site: `_ProfileHeader(profile: ..., onSettingsTap: viewModel.requestSettings)`.

**Bước 2 — event mới + bridge**

`menu_screen_ui_event.dart` — thêm variant thứ ba:

```dart
final class MenuSettingsRequested extends MenuScreenUiEvent {
  const MenuSettingsRequested();
}
```

`menu_view_model.dart`:

```dart
void requestSettings() {
  _events.add(const MenuSettingsRequested());
}
```

`menu_screen.dart` bridge:

```dart
case MenuSettingsRequested():
  // M16: event một-lần "mở settings" → widget showDialog.
  unawaited(_openSettings());
```

và `_openSettings() => showSettingsDialog(context);`

**Bước 2b — vá test vỡ kiệt hợp + test event mới**

Thêm variant sealed → `test/sealed_state_test.dart` báo
`non_exhaustive_switch` ngay (compiler đếm case — đúng thứ M15 dạy).
Thêm arm:

```dart
      MenuSettingsRequested() => 'settings',
```

Trong `test/menu_view_model_test.dart`, thêm test event mới theo đúng
mẫu `requestGame`:

```dart
    test(
      'requestSettings → bắn MenuSettingsRequested lên events (M16)',
      () async {
        final repo = FakeUserProfileRepository();
        addTearDown(repo.dispose);
        final vm = MenuViewModel(userProfileRepository: repo);
        addTearDown(vm.dispose);

        final emitted = vm.events.first;
        vm.requestSettings();

        expect(await emitted, isA<MenuSettingsRequested>());
      },
    );
```

**Bước 3 — `lib/widgets/menu/settings/settings_dialog.dart`**

Ba tầng: hàm mở → scope → bridge → nội dung.

```dart
Future<void> showSettingsDialog(BuildContext context) {
  final settingsRepository = context.read<UserSettingsRepository>();
  final profileRepository = context.read<UserProfileRepository>();
  return showDialog<void>(
    context: context,
    builder: (_) => SettingsDialogScope(
      settingsRepository: settingsRepository,
      profile: profileRepository.userProfileStream.value,
    ),
  );
}
```

`context.read` ở **caller** rồi truyền instance: repo app-scope lẽ
ra vẫn đọc được từ trong route (scope nằm trên Navigator) — nhưng
truyền tay giữ `SettingsDialogScope` tự chứa, pump một mình trong test
không cần `MultiProvider` giả. Profile truyền snapshot (hàng tài
khoản display-only).

```dart
class SettingsDialogScope extends StatelessWidget {
  final UserSettingsRepository settingsRepository;
  final UserProfileData profile;

  const SettingsDialogScope({
    super.key,
    required this.settingsRepository,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsViewModel>(
      create: (_) => SettingsViewModel(settingsRepository: settingsRepository),
      child: _SettingsDialogEventBridge(profile: profile),
    );
  }
}
```

**Bước 4 — event bridge (lặp đúng mẫu 3-khâu của M13):**

```dart
class _SettingsDialogEventBridgeState extends State<...> {
  SettingsViewModel? _viewModel;
  StreamSubscription<SettingsUiEvent>? _eventSubscription;
  var _didLoadSettings = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachViewModel(context.read<SettingsViewModel>());
  }

  void _attachViewModel(SettingsViewModel viewModel) {
    if (_viewModel == viewModel) return;
    _eventSubscription?.cancel();
    _viewModel = viewModel;
    _eventSubscription = viewModel.events.listen(_handleUiEvent);
    if (!_didLoadSettings) {
      _didLoadSettings = true;
      unawaited(viewModel.loadSettings());
    }
  }

  void _handleUiEvent(SettingsUiEvent event) {
    switch (event) {
      case SettingsDismissRequested():
        Navigator.of(context).pop();
      case SettingsSnackBarRequested(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_snackBarText(message))));
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
```

**Bước 5 — nội dung dialog: sections + rows**

:::caution[TEACHING SCAFFOLD]
`timePickerVisible` của VM đã tồn tại (Bài 3) nhưng bản L04 **chưa**
render nhánh picker — `NotificationTimePicker` chỉ được tạo ở
**Bài 5**, kèm `import` + early-return trong `build`. Gạt "Thông báo"
ở L04 sẽ hiện hàng giờ (state đổi) nhưng bấm vào chưa mở picker —
đúng dự kiến, đừng "fix" sớm bằng file tự bịa.
:::

```dart
class _SettingsDialog extends StatelessWidget {
  final UserProfileData profile;
  const _SettingsDialog({required this.profile});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();

    return AlertDialog(
      backgroundColor: MenuTokens.backgroundBottom,
      title: const Text('CÀI ĐẶT', ...),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SettingsSectionTitle('NGÔN NGỮ'),
            _LanguageChipRow(
              selectedLanguageCode: viewModel.languageCode,
              onLanguageSelected: viewModel.selectLanguage,
            ),
            const _SettingsSectionTitle('ÂM THANH'),
            for (final item in viewModel.settingItems)
              if (const {SettingType.sound, SettingType.music,
                      SettingType.haptic}.contains(item.settingType))
                _SettingItemRow(item: item, viewModel: viewModel),
            const _SettingsSectionTitle('THÔNG BÁO'),
            for (final item in viewModel.settingItems)
              if (item.settingType == SettingType.notifications)
                _SettingItemRow(item: item, viewModel: viewModel),
            const _SettingsSectionTitle('TÀI KHOẢN'),
            _SettingsAccountRow(profile: profile),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: viewModel.saveSettings,
                   child: const Text('XONG', ...)),
      ],
    );
  }
}
```

`for` + `if` trong `children:` — **collection elements**: danh sách
widget được build từ data. Section filter bằng `SettingType` — thêm
`SettingType` mới mà quên section = hàng không hiện (nhưng switch
render vẫn kiệt hợp nếu thêm *variant*).

**Bước 6 — `_SettingItemRow` dispatch theo variant:**

```dart
class _SettingItemRow extends StatelessWidget {
  final SettingItemData item;
  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      SettingSwitchItemData switchItem => _SettingSwitchRow(
          item: switchItem, viewModel: viewModel),
      SettingTimePickerItemData timeItem => _SettingTimePickerRow(
          item: timeItem,
          onTap: () => viewModel.showTimePicker(
              timeItem.hour, timeItem.minute)),
    };
  }
}
```

**Bước 7 — `_SettingSwitchRow` (senior: tap cả hàng):**

```dart
class _SettingSwitchRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => viewModel.toggleSetting(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MenuTokens.spacingXs),
        child: Row(children: [
          Icon(item.icon, color: MenuTokens.textSecondary, size: 20),
          const SizedBox(width: MenuTokens.spacingSm),
          Expanded(child: /* text + subtitle Column */),
          Switch(
            value: item.isEnabled,
            activeThumbColor: MenuTokens.accentYellow,
            onChanged: (_) => viewModel.toggleSetting(item),
          ),
        ]),
      ),
    );
  }
}
```

Không lo "double toggle": `Switch.onChanged` và `GestureDetector.onTap`
là hai đường gọi **tách** — tap vào Switch chạy `onChanged`, tap chỗ
khác chạy `onTap` (Switch nuốt gesture của nó). Senior làm y hệt.

**Bước 8 — `_LanguageChipRow` + `_SettingsAccountRow`**

```dart
Row(children: [
  for (final language in SupportedLanguageData.values) ...[
    Expanded(child: GestureDetector(
      onTap: () => onLanguageSelected(language),
      child: Container(/* chip: sáng khi code == selectedLanguageCode,
                          Text(language.nativeName) */),
    )),
    if (language != SupportedLanguageData.values.last)
      const SizedBox(width: MenuTokens.spacingSm),
  ],
])
```

`_SettingsAccountRow`: `Container` bo góc + `CircleAvatar(
Icons.person)` + `profile.username` + dòng phụ — **display-only**
(nút auth thật đến M22+).

## Hiểu code

- `switch (item)` trong `_SettingItemRow` dùng **declaration pattern**
  `SettingSwitchItemData switchItem` — bóc variant VÀ bind biến đúng
  kiểu; `item` field không promote được (field promotion cần tên
  private) nên phải bind.
- `timePickerVisible` điều khiển *nội dung dialog*, không mở dialog
  thứ hai — render-by-state trong cùng một `AlertDialog` (bài 5).
- Section `if` trên `SettingType` + variant `switch` trong
  `_SettingItemRow` là **hai lớp dispatch khác nhau**: group theo
  type (hiển thị), rồi render theo variant (kiểu widget).

## Chạy và quan sát

```bash
flutter run            # menu → icon ⚙ → dialog CÀI ĐẶT mở
flutter test           # toàn suite xanh (Bước 2b đã vá sealed_state_test)
# widget test dialog: file `settings_dialog_test.dart` tạo ở Bài 5
# (test của nó bấm tới picker — chỉ chạy được sau Bài 5)
```

Thấy: 4 switch, 2 chip ngôn ngữ (English/Tiếng Việt), hàng tài khoản
với username hiện tại, nút XONG đóng dialog. Gạt "Âm thanh" → đóng →
khởi động lại app → vẫn bật.

## Thử nghiệm

Trong `_SettingsDialog`, bỏ `context.watch` (đọc `viewModel` bằng
`context.read`). Dự đoán: gạt switch xong dialog có đổi không? Vì sao?

## Lỗi hay gặp

1. **`ProviderNotFoundException` khi đọc provider *dưới*
   Navigator trong dialog** — ví dụ `MenuViewModel` (scope màn hình);
   repo app-scope (trên `MaterialApp`) thì đọc được. Learner vẫn đọc
   ở caller + truyền instance để dialog scope self-contained.
2. **Switch "không ăn"** — `value` không nối vào stream: Switch chỉ
   đổi khi `_settings` đổi; kiểm tra repo fake có emit không.
3. **Quên `HitTestBehavior.opaque`** — vùng trống giữa icon và chữ
   không tap được.
4. **Tạo `SettingsViewModel` trong `MultiProvider`** — mất
   dialog-scope; picker-visible dính giữa các lần mở.

## Tự làm — dòng tóm tắt "N đang bật"

Thêm một dòng tóm tắt dưới title dialog: đếm bao nhiêu switch đang
bật và render `"3 nguồn đang bật"` (số thay đổi theo state).

**Phần A — quyết định TRƯỚC khi code.** Trả lời ra giấy:

1. Đếm ở đâu — trong `build` của dialog, trong một getter trên VM,
   hay trong `buildSettingItems` factory? Chọn một và bảo vệ bằng
   câu "ai cần biết con số này?".
2. Đọc state bằng `context.read` hay `context.watch`? Điểm khác
   nhau nhìn thấy được là gì nếu chọn sai?
3. Nguồn đếm là `viewModel.settingItems` (data) — `whereType` lọc
   `SettingSwitchItemData` rồi đếm `isEnabled` — hay đếm trên
   `UserSettingsData`? Cái nào đúng "nguồn truth đã đi qua factory"?

**Phần B — implement + verify.** Thêm `Text` vào dialog, chạy:

```bash
flutter analyze
flutter test          # widget test ghim: bật 2 switch → find.text('2 nguồn đang bật')
```

<details><summary>Đáp án</summary>

1. **Trong `build`** là lựa chọn đúng ở quy mô này: list ~5 item,
   đếm là O(n) tầm thường, và con số chỉ phục vụ *hiển thị* của
   dialog — không ai khác cần nó. Đặt getter trên VM cũng chấp nhận
   được nếu bảo vệ được ("VM là nơi duy nhất biết định nghĩa
   'đang bật'"), nhưng đặt trong `buildSettingItems` là **sai**:
   factory mô tả *hàng nào tồn tại*, không mô tả "UI muốn nói gì".
2. `context.watch` — `read` chỉ chụp một lần; gạt switch xong dòng
   tóm tắt đứng yên (đúng bẫy đã thử ở Thử nghiệm).
3. `viewModel.settingItems` — nó đã phản ánh `effective` merge của
   factory; đếm trên `UserSettingsData` thô bỏ qua guard
   `effectiveNotificationEnabled` và đếm sai hàng giờ.

```dart
// trong _SettingsDialog.build, trước ListView items:
final enabledCount = viewModel.settingItems
    .whereType<SettingSwitchItemData>()
    .where((i) => i.isEnabled)
    .length;
Text('$enabledCount nguồn đang bật'),
```

Điểm học: **VM state → derived UI → interaction** tạo thành một
vòng — bạn vừa tự kéo dữ liệu từ stream lên pixels mà không qua
bước nào mới.

</details>

## Kiểm tra hiểu biết## Kiểm tra hiểu biết

1. Vì sao `saveSettings()` của VM phát *event* thay vì gọi `pop`?
2. `_didLoadSettings` cờ dùng để làm gì — và vì sao không để trong
   `initState`?
3. Gear icon là `GestureDetector` — senior dùng `GlassIconButton`;
   khác biệt nào được register (row nào)?

<details><summary>Đáp án</summary>

1. VM không có `BuildContext` — quyết định "đóng" là của VM, hành
   động pop là của widget (bridge). Tách quyền/hành động = test VM
   không cần Navigator.
2. `didChangeDependencies` chạy lại khi provider thay đổi (hiếm),
   nhưng `loadSettings()` chỉ nên chạy một lần mỗi lần mở dialog —
   cờ chặn gọi lặp. `initState` chạy trước khi `context.read` an
   toàn cho inherited — bridge phải attach ở `didChangeDependencies`.
3. Learner dùng `Icons.settings` thay `iconGear` asset (chưa có
   pipeline assets); và event `MenuSettingsRequested` thay
   `MenuDialogSettings` state (đến M21).

</details>

## Ta cố ý chưa thêm

- `SettingsDialogShell`/glass styling + `transitionKey` của senior —
  learner dùng `AlertDialog` + tokens (M21).
- Nút đăng nhập trên account row + `v$appVersion` — **M22+/M27**
.
- `languageCode` lái locale thật — **M17** (chips giờ chỉ persist).

## Checkpoint hoàn thành

- [ ] Bấm ⚙ mở được dialog; XONG đóng lại.
- [ ] Gạt "Âm thanh" → `repo.saveCallCount` tăng (test) và
      `SharedPreferences` thật ghi (restart app vẫn giữ).
- [ ] `flutter analyze` + `flutter test` sạch/xanh.
