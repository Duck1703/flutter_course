---
title: "Bài 2 · SettingItemData — sealed family lái danh sách UI"
description: "enum SettingType + sealed SettingItemData + factory buildSettingItems: mô hình hoá 'một hàng settings' thành dữ liệu, collection-if cho hàng có điều kiện, padLeft cho giờ."
sidebar:
  label: "Bài 2 · SettingItemData + factory"
  order: 2
---

## Mục tiêu

Sau bài này bạn **làm được**:

- Viết `enum SettingType` + `sealed class SettingItemData` với hai
  variant `SettingSwitchItemData` / `SettingTimePickerItemData`.
- Viết factory `buildSettingItems` trả về `List<SettingItemData>` —
  dùng **collection-`if`** để hàng chọn giờ chỉ tồn tại khi
  thông báo đang bật.
- Giải thích vì sao "một hàng settings" được mô hình hoá thành **dữ
  liệu** thay vì viết thẳng widget.

## Bạn đang ở đâu

- M16 bài 2/5. Bài 1 đã vẽ vòng lặp persist; bài này tạo **mảnh dữ
  liệu** chảy trong vòng lặp đó — phía "UI hiển thị cái gì".
- `UserSettingsData` (7 field) đã có sẵn từ M14 — bài này **không đụng**
  model đó; ta build tầng mô tả hàng UI phía trên nó.

## Vì sao việc này quan trọng ngay bây giờ

Dialog settings của senior không hardcode từng `Row(...)`: nó build một
`List<SettingItemData>` — "hàng nào tồn tại, hàng đó mang dữ kiện gì" —
rồi render theo variant. Lợi ích thật, thấy ngay trong bài 4:

- Thêm hàng mới = thêm một phần tử vào list — **UI tự đếm**.
- Hàng "giờ thông báo" chỉ xuất hiện khi `notificationEnabled` —
  logic đó nằm trong factory, **test được không cần pump widget**.
- Compiler bảo vệ: sealed family + switch kiệt hợp — quên render một
  variant là lỗi biên dịch (M15 đã chứng minh trên event + dialog).

## Bạn đã biết gì

- `sealed class` + tập variant đóng cùng file (M15/02).
- `switch` expression kiệt hợp + object pattern (M15/03).
- `enum` (M08), `copyWith` (M04), `==`/`hashCode` tự viết
  (M14 model files).

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
|---|---|---|
| `enum` dispatch key | `SettingType.sound` | gắn "loại hàng" vào data — switch biết toggle cái gì |
| `sealed class` + `final class` | `final class SettingSwitchItemData extends SettingItemData` | hàng switch mang thêm `isEnabled` |
| collection-`if` | `if (effective) SettingTimePickerItemData(...)` | hàng chỉ tồn tại khi điều kiện đúng |
| `String.padLeft` | `'7'.padLeft(2, '0')` → `'07'` | format phút/giờ 2 chữ số |

`padLeft` là lần đầu xuất hiện: `n.toString().padLeft(2, '0')`
→ chuỗi ít nhất 2 ký tự, lấp `'0'` bên trái. `20:07` chứ không `20:7`.

## Ví dụ độc lập

```dart
// Tối giản: hai loại hàng trong một menu in ra console.
sealed class RowData { const RowData(this.label); final String label; }
final class ToggleRow extends RowData {
  const ToggleRow(super.label, {required this.on});
  final bool on;
}
final class LinkRow extends RowData { const LinkRow(super.label); }

String render(RowData r) => switch (r) {
  ToggleRow(:final on) => '${r.label}: ${on ? "BẬT" : "TẮT"}',
  LinkRow() => '${r.label} →',
};

void main() {
  final rows = <RowData>[
    ToggleRow('Âm thanh', on: true),
    if (DateTime.now().hour > 0) LinkRow('Giờ thông báo'),
  ];
  rows.forEach(print);
}
```

Thử xoá case `LinkRow` khỏi `render` — compiler báo ngay
`non_exhaustive_switch_expression`. Đó là "danh sách lái bởi variant".

## Android / Compose bridge

- **SIMILARITY:** sealed class + `when` kiệt hợp của Kotlin y hệt —
  đây là cùng một pattern "algebraic data type lái UI".
- **IMPORTANT DIFFERENCE:** `ListWheelScrollView`/picker ở bài 5 không
  có tương đương 1:1 trong View system (NumberPicker gần nhất).
- **DO NOT ASSUME:** collection-`if` trong list literal KHÔNG phải
  `if` thường — nó chỉ hợp lệ *bên trong* literal `[]`/`{}`/`()`.

## Senior project connection

- `lib/data/settings/setting_item_data.dart` — senior: cùng
  `SettingType` {sound, music, haptic, notifications}, cùng 2 variant;
  khác một chi tiết — senior dùng `iconAsset` (đường dẫn SVG), learner
  dùng `IconData` vì app chưa có pipeline icon assets.
- `lib/view_models/settings/settings_item_factory.dart` — senior
  `buildSettingItems({settings, effectiveNotificationEnabled, ...})`
  + các chuỗi localized. Learner giữ cùng chữ ký trừ texts (l10n là
  M17 — label tiếng Việt cứng tạm thời).

## Build it step by step

**Bước 1 — file mới `lib/data/settings/setting_item_data.dart`:**

```dart
import 'package:flutter/material.dart';

/// Loại hàng setting — key dispatch cho switch + map sang field
/// của UserSettingsData. Thêm giá trị mới → mọi switch kiệt hợp
/// trên SettingType buộc phải xử lý (compiler là checklist).
enum SettingType { sound, music, haptic, notifications }

sealed class SettingItemData {
  final IconData icon;
  final String text;
  final String? subtitle;
  final SettingType settingType;

  const SettingItemData({
    required this.icon,
    required this.text,
    this.subtitle,
    required this.settingType,
  });
}
```

`subtitle` có `?` vì chỉ một số hàng cần dòng phụ.

**Bước 2 — hai variant + `==`/`hashCode`:**

```dart
final class SettingSwitchItemData extends SettingItemData {
  final bool isEnabled;
  const SettingSwitchItemData({
    required super.icon,
    required super.text,
    super.subtitle,
    required super.settingType,
    required this.isEnabled,
  });

  @override
  bool operator ==(Object other) =>
      other is SettingSwitchItemData &&
      other.icon == icon && other.text == text &&
      other.subtitle == subtitle &&
      other.settingType == settingType && other.isEnabled == isEnabled;

  @override
  int get hashCode =>
      Object.hash(icon, text, subtitle, settingType, isEnabled);
}

final class SettingTimePickerItemData extends SettingItemData {
  final int hour;
  final int minute;
  const SettingTimePickerItemData({
    required super.icon,
    required super.text,
    required super.settingType,
    required this.hour,
    required this.minute,
  });

  /// '7:5' → '07:05' — padLeft lấp '0' bên trái tới đủ 2 ký tự.
  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  // == / hashCode tương tự trên (icon,text,settingType,hour,minute)
}
```

`formattedTime` là **derived value** — getter tính từ `hour`/`minute`,
không lưu thêm field. Đúng senior: `SettingTimePickerItemData` có
`formattedTime` y hệt.

**Bước 3 — `lib/data/settings/supported_language_data.dart`:**

```dart
/// Ngôn ngữ app hỗ trợ — model cho hàng chọn ngôn ngữ.
/// M16: chip ghi languageCode thật; M17 mới lái MaterialApp.locale.
class SupportedLanguageData {
  static const english = SupportedLanguageData(code: 'en', nativeName: 'English');
  static const vietnamese = SupportedLanguageData(code: 'vi', nativeName: 'Tiếng Việt');
  static const values = [english, vietnamese];

  final String code;
  final String nativeName;
  const SupportedLanguageData({required this.code, required this.nativeName});

  static bool isSupportedCode(String? code) =>
      values.any((language) => language.code == code);

  static SupportedLanguageData? fromCode(String? code) {
    for (final language in values) {
      if (language.code == code) return language;
    }
    return null;
  }
}
```

:::caution[TEACHING SCAFFOLD]
`isSupportedCode`/`fromCode` tồn tại từ bây giờ nhưng
`UserSettingsData.fromMap` **chưa** gọi chúng — guard whitelist hội
tụ ở **M17** cùng lúc `MaterialApp.locale` nối vào.
:::

**Bước 4 — factory `lib/view_models/settings/settings_item_factory.dart`:**

```dart
import 'package:flutter/material.dart';
import '../../data/settings/setting_item_data.dart';
import '../../data/settings/user_settings_data.dart';

/// Dữ liệu → hàng UI: đọc UserSettingsData, trả list mô tả hàng.
/// Hàng giờ CHỈ xuất hiện khi thông báo effective — "hàng có điều
/// kiện" là dữ liệu, không phải if/else trong widget tree.
List<SettingItemData> buildSettingItems({
  required UserSettingsData settings,
  required bool effectiveNotificationEnabled,
}) {
  return [
    SettingSwitchItemData(
      icon: Icons.volume_up,
      text: 'Âm thanh',
      settingType: SettingType.sound,
      isEnabled: settings.soundEnabled,
    ),
    SettingSwitchItemData(
      icon: Icons.music_note,
      text: 'Nhạc nền',
      settingType: SettingType.music,
      isEnabled: settings.musicEnabled,
    ),
    SettingSwitchItemData(
      icon: Icons.vibration,
      text: 'Rung',
      settingType: SettingType.haptic,
      isEnabled: settings.hapticEnabled,
    ),
    SettingSwitchItemData(
      icon: Icons.notifications,
      text: 'Thông báo',
      subtitle: 'Mỗi ngày một lần',
      settingType: SettingType.notifications,
      // Switch theo giá trị EFFECTIVE — FR-27: senior AND thêm quyền
      // OS (`&& _hasNotificationPermission`) ở M27; giờ bằng flag.
      isEnabled: effectiveNotificationEnabled,
    ),
    if (effectiveNotificationEnabled)
      SettingTimePickerItemData(
        icon: Icons.schedule,
        text: 'Giờ thông báo',
        settingType: SettingType.notifications,
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
      ),
  ];
}
```

`if` nằm **trong** list literal → khi `effectiveNotificationEnabled`
sai, phần tử không tồn tại — UI không phải "ẩn" gì cả.

## Hiểu code

- `super.icon`/`super.text` — **super parameter**: tham số con chuyển
  thẳng lên ctor cha, không cần `this.icon` trong thân.
- `SettingTimePickerItemData` kế thừa `settingType` =
  `SettingType.notifications` — cùng type với switch thông báo, vì
  nó *là* phần phụ của setting đó.
- `==`/`hashCode` cần thiết vì `settingItems` được rebuild mỗi
  `notifyListeners` — equality cho phép `expect` so sánh và cho phép
  emit-guard `!=` so giá trị cũ/mới.

## Chạy và quan sát

*(Chạy sau Bài 3 — test này cần `SettingsViewModel` tồn tại.)*

```bash
flutter test test/settings_view_model_test.dart -t "hàng giờ"
```

Test `bật notifications → hàng giờ xuất hiện trong settingItems` bật
notifications rồi assert `settingItems` chứa một
`SettingTimePickerItemData` với `hour == 20`, `formattedTime ==
'20:00'` — hàng có điều kiện chỉ sinh ra khi flag bật. Ở cuối Bài 2
bạn chỉ có data + factory — verify tay bằng cách in
`buildSettingItems(settings: const UserSettingsData(notificationEnabled: true),
effectiveNotificationEnabled: true).length` trong `dart run` scratch
hoặc test tạm nếu muốn.

## Thử nghiệm

Trong factory, đổi `if (effectiveNotificationEnabled)` thành
`if (true)`. Dự đoán: dialog lúc notifications tắt sẽ thấy gì? Vì sao
đó là bug *UX* chứ không phải crash?

## Lỗi hay gặp

1. **Hardcode `isEnabled: true/false`** — factory đọc state thật từ
   `settings`; cứng giá trị = UI luôn render sai.
2. **Quên `hour`/`minute` trong `==` của time item** — hai item "giờ
   khác nhau" được coi bằng nhau → emit-guard `!=` có thể nuốt
   thay đổi.
3. **Đặt time row NGOÀI `if`** — hàng giờ hiển thị cả khi thông báo
   tắt; learner nhìn "giờ" của một tính năng đang tắt.

## Tự làm — "xám đi" thay vì "biến mất"

Yêu cầu mới: hàng **Giờ thông báo** không được *biến mất* khi
notifications tắt nữa — nó vẫn hiện nhưng **mờ đi** (disabled look),
để người dùng thấy tính năng tồn tại và hiểu vì sao chưa dùng được.

Quyết định **trước khi** xem đáp án — viết câu trả lời của bạn ra:

1. Hàng giờ giờ phải *luôn* được emit bởi factory — `if` điều kiện
   trong `buildSettingItems` thay thế bằng gì?
2. "Đang mờ" là *state* hay *presentation*? Nói khác đi: field mới
   thuộc về `SettingTimePickerItemData` hay thuộc widget
   `_SettingTimePickerRow`? Nếu đặt vào data — field kiểu gì, tên gì,
   map từ đâu trong `UserSettingsData`/param `effective…`?
3. `==`/`hashCode` của `SettingTimePickerItemData` cần đụng tới
   không? Vì sao (nhớ emit-guard `!=` ở Bài 3)?
4. `SettingType` có cần member mới không?

Sau khi quyết xong: implement — factory luôn emit hàng giờ, data
mang cờ enabled, widget tô mờ. Xác minh:

```bash
flutter analyze                       # sạch
# scratch check:
# buildSettingItems(settings với notificationsEnabled=false,
#   effectiveNotificationEnabled: false) vẫn chứa
#   SettingTimePickerItemData với cờ = false
```

:::note[Gợi ý]
Đừng nhét "enabled" vào `text` hay suy ra từ `hour == 0` — UI state
của hàng phải là *dữ kiện riêng* để `==` và test đọc được trực tiếp.
:::

<details><summary>Đáp án</summary>

1. Bỏ `if (effectiveNotificationEnabled)` — hàng giờ emit
   **không điều kiện**.
2. Là *state của item*, không phải việc của widget: thêm
   `final bool isEnabled` vào `SettingTimePickerItemData`, factory
   gán `isEnabled: effectiveNotificationEnabled`. Widget chỉ đọc
   `item.isEnabled` để chọn `Opacity`/màu — dữ liệu mô tả "có dùng
   được không", widget mô tả "trông thế nào".
3. Có — `isEnabled` phải vào `==`/`hashCode`, không thì toggle
   notifications sinh item "bằng" item cũ và emit-guard nuốt mất
   rebuild.
4. Không — `SettingType.notifications` đã là key đúng của hàng;
   "giờ" vẫn là phần phụ của setting đó.

Điểm học: **"ẩn hay mờ" là quyết định UX, nhưng cả hai đều đi qua
data** — factory quyết hàng nào *tồn tại với dữ kiện gì*, widget
quyết *render ra sao*. Đó là ranh giới data ↔ widget của pattern
này.

</details>

## Kiểm tra hiểu biết3. **Đặt time row NGOÀI `if`** — hàng giờ hiển thị cả khi thông báo
   tắt; learner nhìn "giờ" của một tính năng đang tắt.

## Kiểm tra hiểu biết

1. Vì sao `SettingType` tồn tại riêng thay vì so sánh `text`?
2. Collection-`if` khác `if` statement chỗ nào — và vì sao nó "xóa"
   hàng thay vì "ẩn" hàng?
3. `padLeft(2, '0')` trên `'7'` cho gì — và trên `'20'` cho gì?

<details><summary>Đáp án</summary>

1. `text` là chuỗi hiển thị — đổi label dịch thuật (M17) sẽ phá mọi
   `==` so sánh. `SettingType` là khóa domain ổn định, compiler check
   được kiệt hợp.
2. `if` statement điều khiển luồng chạy; collection-`if` điều khiển
   *phần tử có mặt trong list*. "Không có phần tử" ≠ "phần tử ẩn" —
   list không chứa nó, widget tree không render nó.
3. `'07'` và `'20'` — `padLeft` chỉ lấp cho tới độ dài tối thiểu,
   không cắt.

</details>

## Ta cố ý chưa thêm

- `iconAsset` String + `SvgPicture` (senior) — learner dùng `IconData`
  vì chưa có pipeline assets — xem lại M24.
- Localized text cho label — **M17**.
- Hàng version dưới account row (senior `v$appVersion`) — **M27**,
và là **bài Tự làm** ở cuối milestone.

## Checkpoint hoàn thành

- [ ] `flutter analyze` sạch với 2 file data + 1 factory mới.
- [ ] `buildSettingItems` trả 4 phần tử khi notifications tắt, 5 khi
      bật (verify bằng test hoặc print).
- [ ] `formattedTime` của `(7, 30)` = `'07:30'`.
