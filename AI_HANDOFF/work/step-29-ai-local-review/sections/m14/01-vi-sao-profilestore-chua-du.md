## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — thuần lý thuyết: repository vs storage, dependency direction, vì sao VM không được biết SharedPreferences. Bạn không cần AI kiểm tra code ở đây.

Nếu muốn, hãy hỏi AI local một câu: *"Giải thích lại bằng ví dụ: vì sao `MenuViewModel` ôm `ProfileStore` concrete là dependency direction sai, và repository sẽ sửa nó thế nào?"* — rồi tự đối chiếu với mental model trong bài.

Checkpoint code sang bài sau: `lib/data/profile/profile_store.dart` **vẫn còn** và `MenuViewModel` vẫn đang dùng nó — đúng ý đồ, đừng xoá sớm (bài 7 mới xoá).
