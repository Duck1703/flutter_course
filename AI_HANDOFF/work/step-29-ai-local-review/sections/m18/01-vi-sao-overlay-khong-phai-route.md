## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — thuần mental model: onboarding là lớp widget trong `Stack` (visibility = state từ repo), không phải route/dialog. Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, hỏi AI local: *"Đọc `lib/screens/menu_screen.dart` — chỗ nào hợp lý để chèn một `Stack` chứa overlay phủ toàn màn? `OnboardingRepository` trong `lib/repositories/` hiện có consumer nào chưa?"* — câu trả lời đúng: repo tồn tại từ M14 nhưng chưa ai dùng; `Stack` đặt quanh `Column` body của menu.

Checkpoint code sang bài sau: không file mới nào — `OnboardingRepository` vẫn chưa có consumer, đúng trạng thái.
