## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — thuần lý thuyết: vòng lặp persist `toggle → VM → repo.save → emit → VM → notify → UI`, ba luật "UI không giữ giá trị / stream là truth / persistence là việc của repo". Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, hỏi AI local: *"Đọc `lib/repositories/settings/user_settings_repository.dart` và chỉ ra: chỗ nào ghi SharedPreferences, chỗ nào emit lên subject — rồi giải thích vì sao `_soundOn` trong State của menu screen là sai chỗ."*

Checkpoint code sang bài sau: `UserSettingsRepository` + impl đã tồn tại (M14) nhưng **chưa có consumer** — đúng trạng thái; không có file settings-UI nào cả, công tắc `_soundOn` cũ đã bị gỡ từ sau M13.
