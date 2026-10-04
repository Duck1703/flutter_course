## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — toàn bộ ví dụ `BehaviorSubject`/`ValueStream` chạy trên Dart độc lập; impl repo mới là bài 4. Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, hỏi AI local: *"Cho `s = BehaviorSubject<int>.seeded(10); s.add(20);` rồi một listener subscribe — listener nhận gì và vì sao? Đổi sang `StreamController.broadcast` thì khác gì?"* — đối chiếu với bảng state-stream vs event-stream trong bài.

Checkpoint code sang bài sau: `pubspec.yaml` đã có `rxdart` (bài 2); `user_profile_repository.dart` vẫn chỉ là contract trần — chưa có impl, chưa ai gọi.
