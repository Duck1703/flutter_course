---
title: "Bài 5 · ListWheelScrollView picker + tests + tổng hợp M16"
description: "ListWheelScrollView.useDelegate + FixedExtentScrollController (controller trong State, dispose) → picker giờ đổi nội dung dialog theo state; test VM + widget; bài Tự làm mở rộng sealed family."
sidebar:
  label: "Bài 5 · Time picker + tổng hợp"
  order: 5
---

## Mục tiêu

Sau bài này bạn **làm được**:

- Build picker hai bánh xe bằng `ListWheelScrollView.useDelegate` +
  `FixedExtentScrollController` — và giải thích vì sao controller
  **phải sống trong `State`** (không `new` trong `build`).
- Nối picker bằng **state**: `timePickerVisible` lái nội dung dialog —
  không mở dialog thứ hai.
- Viết test widget cho dialog: `pumpWidget` → tap → `pumpAndSettle` →
  assert persist; biết khi nào cần `ensureVisible` (hàng dưới fold).
- Tự thêm một variant sealed mới vào family `SettingItemData`
  (bài Tự làm).

## Bạn đang ở đâu

- M16 bài 5/5 — kết milestone. Bài 4 đã có dialog chạy; bài này thêm
  picker giờ + bộ test chứng minh vòng lặp persist + bài tập mở rộng.

## Vì sao việc này quan trọng ngay bây giờ

Hàng "Giờ thông báo" cần một **picker** — không phải `showTimePicker`
của Material (senior không dùng nó — app chọn giờ:phút bằng hai bánh
xe cuộn). `ListWheelScrollView` là lần đầu course gặp widget
cuộn-có-controller: controller là object sở hữu scroll position —
new trong `build` sẽ tạo controller mới **mỗi lần rebuild**, leak cái
cũ và mất vị trí cuộn. Đây là lý do `_TimeWheel` là `StatefulWidget`.

## Bạn đã biết gì

- `StatefulWidget`/lifecycle `initState`/`dispose`.
- Render-by-state: `timePickerVisible` lái nội dung dialog (field từ
  bài 3; nhánh render thêm trong bài này).
- `padLeft` + `SettingTimePickerItemData` (bài 2), VM methods
  `showTimePicker`/`onNotificationTimeSelected` (bài 3).
- Widget test `pumpWidget`/`tap`/`pumpAndSettle`/`ensureVisible`
  (M08–M15).

## Flutter cần dùng

| API | Ví dụ | Nghĩa |
|---|---|---|
| `ListWheelScrollView.useDelegate` | bánh xe cuộn item cố định | picker kiểu iOS: mỗi item cao `itemExtent` |
| `FixedExtentScrollController` | `initialItem: hour` | controller sở hữu vị trí cuộn — PHẢI dispose |
| `FixedExtentScrollPhysics` | `physics:` | snap vào từng item thay vì cuộn tự do |
| `onSelectedItemChanged` | `(i) => _hour = i` | callback khi bánh dừng ở item mới |

## Ví dụ độc lập — controller ownership

```dart
// SAI: controller chết-ngắn-mỗi-build → leak + mất vị trí.
class BadWheel extends StatelessWidget {
  Widget build(_) => ListWheelScrollView.useDelegate(
    controller: FixedExtentScrollController(initialItem: 0), // ← leak!
    ...
  );
}

// ĐÚNG: controller thuộc State — một đời với widget.
class _WheelState extends State<Wheel> {
  late final FixedExtentScrollController _controller;
  void initState() { super.initState();
    _controller = FixedExtentScrollController(initialItem: widget.initial); }
  void dispose() { _controller.dispose(); super.dispose(); }
  Widget build(_) => ListWheelScrollView.useDelegate(controller: _controller, ...);
}
```

Senior `WheelPicker` giữ controller trong `State` đúng như vậy — đây
là phiên bản `ScrollController` của cùng một luật: **ai tạo ra
controller, người đó dispose**.

## Android / Compose bridge

- **SIMILARITY:** cuộn snap-item ≈ `LazyColumn` + `SnapFlingBehavior`
  / View `NumberPicker`.
- **IMPORTANT DIFFERENCE:** ở Flutter controller là object *bạn tạo*
  và *bạn dispose* — không có hệ thống tự thu hồi. Quên = leak.
- **DO NOT ASSUME:** `initialItem` chỉ có nghĩa lúc attach lần đầu —
  rebuild không nhảy lại vị trí (đó là điểm của controller).

## Senior project connection

- `lib/widgets/menu/settings/time_picker_wheels.dart` +
  `wheel_picker.dart` — senior: `ListWheelScrollView.useDelegate` +
  `FixedExtentScrollController(initialItem:)` + `onSelectedItemChanged`,
  bọc chrome fade/magnifier. Learner giữ đúng primitives, bớt chrome
  (permitted simplification).
- `lib/widgets/menu/settings/notification_time_picker_dialog.dart`
  (senior) — `XÁC NHẬN`/`HỦY` + temp `_hour`/`_minute` trong State;
  confirm mới gọi callback persist — giống learner.
- Senior phủ picker bằng overlay trong dialog layer (`MenuDialogLayer`,
  M21); learner swap *nội dung* của cùng `AlertDialog` — cùng ý tưởng
  render-theo-state, khác cơ chế.

## Build it step by step

**Bước 1 — `lib/widgets/menu/settings/notification_time_picker_dialog.dart`**

`NotificationTimePicker` (stateful — giữ lựa chọn tạm):

```dart
class NotificationTimePicker extends StatefulWidget {
  final int currentHour;
  final int currentMinute;
  final void Function(int hour, int minute) onConfirm;
  final VoidCallback onDismiss;
  // ctor...

  @override
  State<NotificationTimePicker> createState() => _State();
}

class _State extends State<NotificationTimePicker> {
  late int _hour = widget.currentHour;
  late int _minute = widget.currentMinute;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _TimeWheel(count: 24, initialIndex: _hour,
                   onChanged: (i) => setState(() => _hour = i)),
        const Text(':', style: ...),
        _TimeWheel(count: 60, initialIndex: _minute,
                   onChanged: (i) => setState(() => _minute = i)),
      ]),
      Row(// XÁC NHẬN → widget.onConfirm(_hour, _minute)
          // HỦY      → widget.onDismiss()
      ),
    ]);
  }
}
```

`_hour`/`_minute` là **UI-state tạm của picker** — không persist tới
khi bấm XÁC NHẬN. Đúng senior: selection tạm sống trong `State`,
commit qua callback.

`_TimeWheel` = `StatefulWidget` theo đúng pattern ở ví dụ độc lập —
controller trong `initState`, `dispose` trong `dispose`,
`onSelectedItemChanged: widget.onChanged`.

**Bước 2 — nối vào dialog:**

Mở `lib/widgets/menu/settings/settings_dialog.dart` (bài 4), thêm
import:

```dart
import 'notification_time_picker_dialog.dart';
```

Rồi trong `_SettingsDialog.build`, NGAY SAU `context.watch`, thêm
early-return render picker:

```dart
    if (viewModel.timePickerVisible) {
      // Bài 5: swap sang picker — cùng dialog, khác content.
      return AlertDialog(
        title: const Text('GIỜ THÔNG BÁO'),
        content: NotificationTimePicker(
          currentHour: viewModel.timePickerHour,
          currentMinute: viewModel.timePickerMinute,
          onConfirm: viewModel.onNotificationTimeSelected,
          onDismiss: viewModel.dismissTimePicker,
        ),
      );
    }
```

Chuỗi: tap hàng giờ → `vm.showTimePicker(h, m)` → `timePickerVisible`
= true → `context.watch` rebuild → content đổi sang picker → XÁC NHẬN
→ `onNotificationTimeSelected` → persist + `timePickerVisible` false
→ quay lại nội dung chính. **Không route thứ hai** — state lái nội
dung.

**Bước 3 — tests `test/settings_view_model_test.dart`** (đã có sẵn
trong impl; đọc lại để hiểu):

```dart
test('bật notifications → hàng giờ xuất hiện trong settingItems', () async {
  final vm = SettingsViewModel(settingsRepository: FakeUserSettingsRepository());
  expect(vm.settingItems.any((i) => i is SettingTimePickerItemData), isFalse);
  await vm.toggleSetting(/* SettingType.notifications, isEnabled: false */);
  final timeItem = vm.settingItems
      .whereType<SettingTimePickerItemData>().first;
  expect(timeItem.formattedTime, '20:00');
});
```

`is`/`whereType` — kiểm kiểu variant trong list; kết hợp với
collection-`if` của factory, đây là cách test "hàng có điều kiện"
không cần pump widget.

**Bước 4 — widget test `test/widgets/settings_dialog_test.dart`** (file
mới, 5 test):

```dart
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:ai_millionaire_course/widgets/menu/settings/settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../helpers/fake_user_profile_repository.dart';
import '../helpers/fake_user_settings_repository.dart';

/// M16 — settings dialog widget test: dialog-scoped VM, switch row,
/// time row conditional, language chips, dismiss event → pop.
Widget _dialogHost(FakeUserSettingsRepository repo) {
  // SettingsDialogScope tự tạo SettingsViewModel — chỉ cần bọc đủ
  // MaterialApp để có ScaffoldMessenger/Navigator/Directionality.
  return MaterialApp(
    home: SettingsDialogScope(
      settingsRepository: repo,
      profile: const UserProfileData(username: 'TestPlayer'),
    ),
  );
}

void main() {
  testWidgets('dialog render 4 switch rows + chips + nút XONG', (tester) async {
    final repo = FakeUserSettingsRepository();
    addTearDown(repo.dispose);
    await tester.pumpWidget(_dialogHost(repo));
    await tester.pump();

    expect(find.text('CÀI ĐẶT'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(4));
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Tiếng Việt'), findsOneWidget);
    expect(find.text('XONG'), findsOneWidget);
    // FR-28: hàng tài khoản hiển thị-only (chưa auth — M22+).
    expect(find.text('TestPlayer'), findsOneWidget);
    // Thông báo tắt → chưa có hàng giờ.
    expect(find.text('Giờ thông báo'), findsNothing);
  });

  testWidgets('bấm Switch âm thanh → persist qua repo', (tester) async {
    final repo = FakeUserSettingsRepository();
    addTearDown(repo.dispose);
    await tester.pumpWidget(_dialogHost(repo));
    await tester.pump();

    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(repo.value.soundEnabled, isTrue);
    expect(repo.saveCallCount, 1);
  });

  testWidgets('bật thông báo → hàng giờ hiện, chọn giờ persist', (
    tester,
  ) async {
    final repo = FakeUserSettingsRepository();
    addTearDown(repo.dispose);
    await tester.pumpWidget(_dialogHost(repo));
    await tester.pump();

    await tester.tap(find.byType(Switch).at(3));
    await tester.pumpAndSettle();

    expect(find.text('Giờ thông báo'), findsOneWidget);

    // Hàng giờ nằm dưới viewport trong scroll view của dialog —
    // cuộn vào tầm nhìn trước khi bấm.
    await tester.ensureVisible(find.text('Giờ thông báo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Giờ thông báo'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('GIỜ THÔNG BÁO'), findsOneWidget);

    await tester.tap(find.text('XÁC NHẬN'));
    await tester.pumpAndSettle();

    // Giờ mặc định 20:00 đã persist (picker giữ lựa chọn hiện tại).
    expect(repo.value.notificationHour, 20);
    expect(find.text('CÀI ĐẶT'), findsOneWidget);
  });

  testWidgets('chọn Tiếng Việt → persist languageCode', (tester) async {
    final repo = FakeUserSettingsRepository();
    addTearDown(repo.dispose);
    await tester.pumpWidget(_dialogHost(repo));
    await tester.pump();

    await tester.tap(find.text('Tiếng Việt'));
    await tester.pump();

    expect(repo.value.languageCode, 'vi');
  });

  testWidgets('XONG → dialog pop', (tester) async {
    final repo = FakeUserSettingsRepository();
    addTearDown(repo.dispose);
    var dismissed = false;
    final profileRepo = FakeUserProfileRepository();
    addTearDown(profileRepo.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<UserSettingsRepository>.value(value: repo),
            Provider<UserProfileRepository>.value(value: profileRepo),
          ],
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                await showSettingsDialog(context);
                dismissed = true;
              },
              child: const Text('mở'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('mở'));
    await tester.pump();
    expect(find.text('CÀI ĐẶT'), findsOneWidget);

    await tester.tap(find.text('XONG'));
    await tester.pump();
    expect(find.text('CÀI ĐẶT'), findsNothing);
    expect(dismissed, isTrue);
  });
}
```

`ensureVisible`: trong test viewport 800×600, nội dung dialog
với thêm hàng giờ tràn viewport — tap vào phần tử off-screen không
được hit-test. Cuộn vào tầm nhìn trước khi bấm.

## Hiểu code — ai sở hữu cái gì (bản đồ đầy đủ)

| Cái | Chủ | Lifetime |
|---|---|---|
| `UserSettingsData` | repository (BehaviorSubject) | app |
| `SettingsViewModel` | `ChangeNotifierProvider` trong dialog | dialog |
| `timePickerVisible`, `timePickerHour/Minute` | VM | dialog |
| `_hour`/`_minute` tạm | `State` của `NotificationTimePicker` | picker-phiên |
| `FixedExtentScrollController` | `State` của `_TimeWheel` | wheel |
| `_eventSubscription` | `State` của bridge | dialog |

Một milestone dạy ownership mà chính nó là bản đồ 5 tầng lifetime.

## Chạy và quan sát

```bash
flutter analyze        # sạch
flutter test           # 87/87
flutter build web      # √
```

App: ⚙ → bật Thông báo → bấm "Giờ thông báo" → picker 2 bánh → chọn
07:30 → XÁC NHẬN → hàng hiển thị `07:30`. Hot restart app → `07:30`
vẫn còn — persist qua `SharedPreferences`.

## Thử nghiệm

Bỏ `notifyListeners()` trong `dismissTimePicker`. Dự đoán hành vi
khi bấm HỦY — và tại sao test `GIỜ THÔNG BÁO` → `CÀI ĐẶT` phát hiện
được?

## Lỗi hay gặp

1. **`FixedExtentScrollController` trong `build`** — leak controller
   mỗi rebuild; wheel "giật" vị trí.
2. **Mở picker bằng `showDialog` lồng** — dialog-in-dialog: barrier
   chồng, pop sai cửa. Learner dùng state-swap — một dialog, đổi
   content.
3. **`onSelectedItemChanged` gọi `saveUserSettings` trực tiếp** —
   persist mỗi tích cuộn = 60 write khi lướt phút. Commit chỉ ở XÁC
   NHẬN (lựa chọn tạm sống trong `State`).
4. **Tap hàng off-screen trong test** — luôn `ensureVisible` trước.

## Tự làm — thêm variant `SettingInfoItemData`

Senior settings có hàng **version** (`v$appVersion`) — một hàng
không toggle, không picker: chỉ hiển thị. Learner chưa có
`package_info_plus` (M27), nhưng pattern "hàng read-only" đã đủ để
tự làm:

**Nhiệm vụ:**
1. Thêm variant `SettingInfoItemData` vào `setting_item_data.dart`:
   field `value` (`String`), `settingType` — cần một `SettingType`
   mới? Nghĩ trước: `SettingType` là key dispatch toggle — info row
   không toggle. Chọn: thêm `SettingType.info` vào enum.
2. `buildSettingItems` thêm
   `SettingInfoItemData(icon: Icons.info, text: 'Phiên bản',
   settingType: SettingType.info, value: '1.0')` cuối list.
3. `_SettingItemRow` — switch kiệt hợp sẽ **báo lỗi** cho tới khi bạn
   thêm case render `_SettingInfoRow` (icon + text + value).
4. `toggleSetting` chứa `switch` kiệt hợp trên `SettingType` —
   compiler sẽ báo `non_exhaustive_switch` ngay trong `toggleSetting`
   dù info item không bao giờ tới đây. Thêm `case SettingType.info:`
   với thân rỗng/no-op (hoặc `throw UnimplementedError()` — thảo luận
   chọn gì). Đây chính là điểm compiler-checklist.
5. Test: `vm.settingItems` chứa 1 `SettingInfoItemData` với `value
   == '1.0'`; widget test thấy `find.text('1.0')`.

:::note[Gợi ý]
Nhớ hậu quả của enum mới: `SettingType.info` xuất hiện trong mọi
`switch` kiệt hợp trên `SettingType` — kiểm tra `settings_dialog.dart`
section filter (`const {sound, music, haptic}` — info row sẽ không
rơi vào section nào nếu bạn không cho nó vào section TÀI KHOẢN hoặc
riêng). Đó là *thiết kế*: quyết định info row thuộc section nào.
:::

<details><summary>Đáp án</summary>

```dart
// setting_item_data.dart
enum SettingType { sound, music, haptic, notifications, info }

final class SettingInfoItemData extends SettingItemData {
  final String value;
  const SettingInfoItemData({
    required super.icon, required super.text,
    required super.settingType, required this.value,
  });
  // == / hashCode thêm value
}

// factory: thêm vào list cuối
SettingInfoItemData(
  icon: Icons.info, text: 'Phiên bản',
  settingType: SettingType.info, value: '1.0',
),

// toggleSetting: switch kiệt hợp đòi arm mới — info không toggle:
case SettingType.info:
  // read-only row — không có gì để toggle; cũng có thể
  // throw UnimplementedError() nếu muốn bắt lỗi sớm.

// _SettingItemRow: thêm case
SettingInfoItemData infoItem => _SettingInfoRow(item: infoItem),

// _SettingInfoRow: Row(icon, Expanded(Text(item.text)), Text(item.value))
// section: đặt dưới TÀI KHOẢN hoặc section riêng — filter theo
// SettingType.info.
```

Điểm học: **thêm variant = compiler chỉ từng chỗ cần sửa** — sealed
family là checklist tự động.

</details>

## Kiểm tra hiểu biết

1. Vì sao `_hour`/`_minute` sống trong `State` của picker thay vì VM?
2. `initialItem` vs `animateToItem` — khi nào cái nào?
3. `timePickerVisible` lái *nội dung* dialog — nếu dùng
   `showDialog` lồng thay thế, mất gì?

<details><summary>Đáp án</summary>

1. Lựa chọn tạm chưa persist — commit chỉ ở XÁC NHẬN; picker đóng
   không XN thì giá trị tạm vứt đi — đúng lifetime `State`.
2. `initialItem` = vị trí lúc attach (đọc từ settings hiện tại);
   `animateToItem` = di chuyển có animation tới item — controller
   API sau khi attach.
3. Mất render-by-state + overlay đúng kích cỡ của dialog cha; route
   mới có barrier/transition riêng — phức tạp hơn cho cùng kết quả.

</details>

## Ta cố ý chưa thêm

- Fade/magnifier chrome của `WheelPicker` senior — simplification
  (primitives giữ nguyên).
- Reschedule notification thật khi giờ đổi — **M27**.
- `SettingsDialogShell` + dialog layer — **M21**.
- Locale switch thật từ `languageCode` — **M17**.

## Checkpoint hoàn thành — TỔNG HỢP M16

- [ ] `flutter analyze` sạch; `flutter test` → 87/87; `flutter build
      web` √.
- [ ] ⚙ → dialog: gạt Âm thanh → restart app → vẫn giữ; bật Thông báo
      → hàng giờ xuất hiện → chọn 07:30 → persist qua restart.
- [ ] Chọn "Tiếng Việt" → `languageCode` persist (chữ chưa đổi —
      đến M17).
- [ ] Đóng dialog → mở lại → `timePickerVisible` đã reset (VM chết
      cùng dialog — chứng minh scope).
- [ ] Tự làm: `SettingInfoItemData` render được + test pass.
- [ ] Nói được 5 tầng ownership trong bảng "ai sở hữu cái gì" mà
      không nhìn bài.
