---
title: "M17 — Localization: app hai ngôn ngữ (en/vi)"
description: "Bản địa hoá thật: ARB + gen-l10n + AppLocalizations; MaterialApp.locale lái bởi settings stream — đổi ngôn ngữ trong settings, cả app đổi ngay, không restart."
sidebar:
  label: Tổng quan M17
  order: 0
---

# M17 · Localization — app hai ngôn ngữ (en/vi)

Milestone biến app từ "tiếng Việt viết cứng" thành app **hai ngôn
ngữ**: mọi chuỗi *chrome* (tiêu đề/nút/nhãn/section) sống trong file resource `.arb`, Flutter
sinh class `AppLocalizations` từ chúng, và `MaterialApp.locale` đi theo
`languageCode` đã persist trong settings từ M16. Chọn "English" trong
dialog → **cả app chuyển ngay**, không cần restart.

Đây cũng là lúc FR-26 khép lại: `languageCode` từ disk đi qua
whitelist `SupportedLanguageData.isSupportedCode` — mã lạ rớt về
`null` thay vì rò vào `Locale`.

## Bài học

| # | Bài | Trọng tâm |
|---|-----|-----------|
| 1 | Vì sao không viết cứng chữ | ARB = nguồn truth; pipeline ARB → gen-l10n → code; fallback chain |
| 2 | ARB + gen-l10n setup | `l10n.yaml` + `generate: true`; cú pháp ARB + placeholder `{x}`; file sinh ra |
| 3 | MaterialApp.locale ← stream | **CORE: app-root StreamBuilder lái locale**; FR-26 whitelist trong `fromMap` |
| 4 | Dời chữ sang l10n | `AppLocalizations.of(context)`; `localizedSettingItems` (VM không chạm context); test ghim `Locale('vi')` |
| 5 | Tổng hợp + test + Tự làm | locale-switch widget test (senior parity); 90/90; tự thêm key mới đầu-cuối |

## Tổng kết milestone (synthesis)

Trả lời được năm câu này là đủ:

1. **Học gì?** Chuỗi UI là *resource* (ARB), không phải literal trong
   code; `gen-l10n` biến ARB thành `AppLocalizations` type-safe;
   `MaterialApp(locale/delegates/supportedLocales)` cấp l10n cho cây;
   `StreamBuilder` bọc `MaterialApp` → locale đi theo stream.
2. **Giải thích được?** Vì sao en là template; vì sao `of(context)`
   cần delegates phía trên; vì sao đổi ngôn ngữ không cần restart;
   vì sao VM lấy chữ qua tham số chứ không tự `of(context)`.
3. **Viết lại không copy?** Tự làm: thêm key mới `settingsFooterHint`
   en+vi, regenerate, hiển thị trong dialog.
4. **Nếu … thì sao?** Lưu `'fr'` vào settings → whitelist → `null`
   → MaterialApp fallback; thiếu key ở vi → rớt về en; thiếu
   delegates → `AppLocalizations.of` ném lỗi.
5. **Cần ở đâu sau?** M18 gắn onboarding strings; M22+ mở rộng auth
   surface (FR-31 ghi nhận các key còn thiếu so với senior).

## Còn lại sau M17 (đã register)

- FR-26: `languageCode` whitelist — **CONVERGED** (đóng tại M17).
- FR-31: l10n coverage delta (48/119 keys senior; casing bake sẵn;
  snackbar reset hồ sơ là literal) → các key mới theo từng surface
  ở M18/M22/M23+; đổi casing chỉ khi cần parity pass.
- FR-27/FR-28/FR-29/FR-30: không đổi (M27/M22+/M21/M24).
