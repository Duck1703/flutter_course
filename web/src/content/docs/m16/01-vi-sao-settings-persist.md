---
title: "Bài 1 · Vì sao settings phải sống qua repository"
description: "Cài đặt phải sống sót khi tắt app: repository + stream là nguồn truth duy nhất; UI chỉ là bản render. Bài thuần lý thuyết — chưa đổi code."
sidebar:
  label: "Bài 1 · Vì sao settings persist"
  order: 1
---

## Mục tiêu

Sau bài này bạn **giải thích được**:

- Vì sao một công tắc âm thanh để trong `setState` của màn menu là
  **sai chỗ** — và điều gì xảy ra khi app khởi động lại.
- Vòng lặp settings đúng: `toggle → VM → repo.save → subject emit →
  stream → VM → notifyListeners → UI rebuild`.
- Vì sao "stream là nguồn truth duy nhất" — VM **không được** giữ một
  bản copy riêng song song với repository.

**Bài này không sửa code** — nó xây mental model mà bốn bài sau dùng.

## Bạn đang ở đâu

- Milestone: **M16** (bài 1/5). Course đã có: `UserSettingsData` +
  `UserSettingsRepository` + `UserSettingsRepositoryImpl`
  từ **M14** — repository settings đã *tồn tại* nhưng **chưa có UI
  nào dùng nó**.
- App cuối M15: menu có avatar + tên + nút chơi; chưa có icon cài đặt.
  Công tắc âm thanh demo của M03 đã bị gỡ ở Step-10 — vì nó
  là `setState` giả, không persist.
- M16 biến repository "đang ngủ" thành **feature settings thật**: mở
  dialog từ icon bánh răng, gạt switch, đóng app, mở lại — cài đặt
  vẫn còn.

## Vì sao việc này quan trọng ngay bây giờ

Tưởng tượng bạn cài settings theo cách cũ:

```dart
class _MenuScreenState extends State<MenuScreen> {
  bool _soundOn = false;   // ← đây là cái đã bị gỡ ở Step-10
```

Ba vấn đề chết người:

1. **Không persist**: `_soundOn` sống trong `State` của widget — tắt
   app là mất. Người chơi tắt âm thanh, hôm sau mở app lại ồn ào.
2. **Không chia sẻ**: màn game cần đọc `soundOn` để phát/tắt tiếng —
   nhưng biến đó bị nhốt trong `_MenuScreenState`, widget khác không
   với tới.
3. **Không có chủ sở hữu rõ**: ai ghi? ai đọc? ai persist? — ba câu
   hỏi không câu trả lời.

Cách senior giải (và cách course đã học): settings là **dữ kiện của
app**, không phải của một màn hình — nên nó sống trong
**repository**, được đọc/ghi qua stream, và UI chỉ là bản render
mới nhất của stream đó. Cái mới của M16 không phải pattern — pattern
bạn đã học ở M14 — mà là **áp pattern vào một domain thứ hai**:
`profile` xong, giờ tới `settings`.

## Bạn đã biết gì

- **Repository boundary** (M14/01): lớp giữa domain và storage.
- **BehaviorSubject / ValueStream / `.value` / replay** (M14/03): subscriber mới nhận ngay giá trị hiện tại.
- **`ChangeNotifier` + `notifyListeners`** (M11) và
  **`ChangeNotifierProvider` create/auto-dispose** (M12).
- **`Provider<T>.value` + `context.read`/`watch`** (M12–M14): DI theo contract.
- **`UserSettingsRepository`** contract + fake (M14): `save/load/
  userSettingsStream`.
- **State-driven UI** (M15): render = hàm của state.

## Mental model mới — "vòng lặp persist"

Đây là sơ đồ duy nhất bạn cần nhớ; mọi bài sau chỉ lắp từng đoạn:

```
┌─────┐  tap   ┌──────────┐  copyWith   ┌──────────────┐
│ UI  │──────→ │ Settings │───────────→ │ Repository   │
│ row │        │ViewModel │  save()     │ (interface)  │
└─────┘        └──────────┘             └──────┬───────┘
   ↑                                          │ ghi SharedPreferences
   │                                          ↓ + emit
   │   rebuild ← notifyListeners ←      BehaviorSubject
   │        (VM _handleSettings ← stream.listen)
```

Ba luật bất biến — senior giữ đúng ba luật này:

1. **UI không tự giữ giá trị.** Switch hiển thị `item.isEnabled` đến
   từ `settingItems` của VM — không có `bool _sound` trong widget.
2. **VM không tự tin bản copy.** `toggleSetting` gọi
   `repo.saveUserSettings(copyWith(...))`; giá trị mới quay về qua
   `userSettingsStream` → `_handleSettings` → `notifyListeners`.
   Stream là nguồn truth — nếu save lỗi, UI tự quay về trạng thái
   cũ vì stream không đổi.
3. **Persistence là tác dụng phụ của repo.** `saveUserSettings` ghi
   `SharedPreferences` VÀ emit — khởi động sau `loadUserSettings()`
   nạp lại đúng giá trị đã lưu.

**Giới hạn của model này:** vòng lặp là *optimistic-honest* — repo
fake của course emit ngay; repo thật cũng emit ngay sau khi ghi
thành công. Nếu một ngày persistence cần "đã ghi xong mới đổi UI",
điểm chèn là **bên trong repository**, không phải UI/VM — đó là lý
do boundary tồn tại.

## Ví dụ độc lập

Tối giản hoá vòng lặp — không cần app Millionaire:

```dart
// Một "repo" tối thiểu trong test:
final subject = BehaviorSubject<int>.seeded(0);

// "VM" nghe stream và bật đèn:
subject.stream.listen((v) => print('UI nhận: $v'));

// "Toggle" = ghi vào nguồn, KHÔNG ghi vào UI:
subject.add(1);   // → 'UI nhận: 1'
subject.add(0);   // → 'UI nhận: 0'
```

UI không có biến riêng — nó in đúng thứ stream phát ra. M16 chỉ thay
`int` bằng `UserSettingsData` và `print` bằng `Switch`.

## Android / Compose bridge

- **SIMILARITY:** `SharedPreferences` cùng tên, cùng vai trò; Compose
  cũng render lại khi `StateFlow`/`LiveData` phát giá trị mới.
- **IMPORTANT DIFFERENCE:** ở đây repo *chủ động emit* qua
  `BehaviorSubject` mỗi lần save — không có `invalidate`/`reload`
  thủ công. Ai subscribe là tự có giá trị mới.
- **DO NOT ASSUME:** `BehaviorSubject` ≠ `StateFlow`. `.value` đọc
  snapshot hiện tại; `listen` nhận các emit tiếp theo — và subject
  phải được `close()` (repo learner lo điều đó ở M14).

## Senior project connection

- `lib/repositories/settings/user_settings_repository.dart` — repo
  thật: `SharedPreferences` key `'user_settings'`, `load`/`save` +
  `BehaviorSubject` emit-guard (`!=`).
- `lib/view_models/settings/settings_view_model.dart` — VM senior:
  seed từ `userSettingsStream.value` trong ctor rồi subscribe; mọi
  thay đổi đều qua `_saveSettings` → repo → stream →
  `_handleSettings` → `notifyListeners`. Không có "bản copy thứ hai".
- `lib/widgets/menu/settings/menu_settings_dialog_scope.dart` — VM
  được tạo bởi `ChangeNotifierProvider` **bên trong** dialog scope:
  settings state không lọt vào VM của cả màn menu.

## Thử nghiệm (chạy sau Bài 5)

Trong `test/settings_view_model_test.dart`, gọi
`vm.toggleSetting(item)` hai lần liền. Dự đoán: `repo.value`
lần lượt là gì — và `saveCallCount` là mấy? Vì sao không phải 0?

## Lỗi hay gặp

1. **"Switch giữ `_value` trong State của nó."** Sai — Switch là
   widget "controlled": `value` do ngoài truyền. Tự giữ = hai nguồn
   truth.
2. **"VM set `_settings` rồi mới save."** Đảo thứ tự phá luật 2 —
   lỗi save thì UI hiển thị giá trị chưa từng tồn tại trên disk.
3. **"Đọc `SharedPreferences` trực tiếp trong VM."** Vượt qua
   repository boundary — test không fake được, domain rò vào
   storage.

## Kiểm tra hiểu biết

1. `_soundOn` trong `_MenuScreenState` mất đi khi nào — và vì sao?
2. Vì sao VM gọi `_handleSettings` sau `repo.save` thay vì tự gán
   `_settings` trước?
3. Hàng Switch hiển thị `item.isEnabled` — nguồn của giá trị đó là
   gì trong chuỗi stream?

<details><summary>Đáp án</summary>

1. Khi `State` bị dispose (pop màn, process bị kill, restart app) —
   biến widget không vượt qua vòng đời app; `SharedPreferences` thì
   có.
2. Stream là nguồn truth: nếu save ném lỗi, `_settings` phải giữ giá
   trị CŨ — tự gán trước = UI hiển thị thứ chưa từng được lưu.
3. `SharedPreferences` → `loadUserSettings` → subject → `VM._settings`
   → `buildSettingItems` → `isEnabled` — data chảy một chiều.

</details>

## Ta cố ý chưa thêm

- Xin quyền + hẹn thông báo thật (`LocalNotificationService`,
  `SettingsNotificationCoordinator`) — **M27**.
- Nút đăng nhập/đăng xuất trên hàng tài khoản — **M22+**.
- `MaterialApp.locale` lái ngôn ngữ thật — **M17**.
- Dialog-layer trong `Stack` thay `showDialog` — **M21**.

## Checkpoint hoàn thành

- [ ] Vẽ lại được vòng lặp persist 5 bước không nhìn bài.
- [ ] Nói được 3 luật: UI không giữ giá trị / stream là truth /
      persistence là việc của repo.
- [ ] Chỉ ra được trong `user_settings_repository.dart` chỗ
      `SharedPreferences` được ghi và subject được emit.
