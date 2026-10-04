---
title: "M16 — Settings: cài đặt persist qua repository"
description: "Settings dialog thật: gear → event → dialog-scoped ViewModel → Switch/chips/wheel-picker → repository → stream → rebuild. Persist sống sót khi restart app."
sidebar:
  label: Tổng quan M16
  order: 0
---

# M16 · Settings — cài đặt persist qua repository

Milestone biến `UserSettingsRepository` "đang ngủ" (từ M14) thành
feature thật: icon ⚙ trên menu mở dialog CÀI ĐẶT — 4 switch persist
(sound/music/haptic/thông báo), chips ngôn ngữ ghi `languageCode`,
hàng chọn giờ bằng picker hai bánh xe, hàng tài khoản display-only.

## Bài học

| # | Bài | Trọng tâm |
|---|-----|-----------|
| 1 | Vì sao settings persist | vòng lặp toggle→repo→stream→rebuild; 3 luật single-source-of-truth |
| 2 | SettingItemData + factory | sealed family lái list UI; collection-if; padLeft |
| 3 | SettingsViewModel | **CORE: dialog-scoped VM — scope = lifetime**; sealed SettingsUiEvent |
| 4 | Settings dialog UI | Switch controlled; row-tap opaque; gear→event→showDialog; account row |
| 5 | Time picker + tổng hợp | ListWheelScrollView + controller ownership; widget tests; Tự làm variant mới |

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** Settings là dữ kiện app-level → repository persist;
   dialog-scoped VM (provider trong subtree dialog = VM chết cùng
   dialog); `Switch` controlled; `ListWheelScrollView` + controller
   ownership; sealed `SettingItemData` lái danh sách hàng.
2. **Giải thích được?** Vì sao UI không giữ giá trị; vì sao stream
   là nguồn truth duy nhất; vì sao `context.read` ở caller chứ không
   trong dialog; vì sao controller không `new` trong `build`.
3. **Viết lại không copy?** Tự làm: thêm `SettingInfoItemData` —
   variant mới, case mới trong switch, section filter mới, test mới.
4. **Nếu … thì sao?** Thêm `SettingType` → compiler liệt kê mọi chỗ
   cần xử; xoá `notifyListeners` → UI đơ lại.
5. **Cần ở đâu sau?** M17 lái `MaterialApp.locale` từ `languageCode`
   đã persist; M21 thay `showDialog` bằng dialog layer; M27 nối
   permission/schedule thật cho toggle thông báo.

## Còn lại sau M16

- `languageCode` guard whitelist → M17.
- Notification permission/schedule → M27.
- Account row auth + version → M22+/M27.
- `MenuDialogSettings` entry → M21.
- `iconAsset` → `IconData` → xem lại M24.
