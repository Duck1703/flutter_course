## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — thuần lý thuyết: tập state đóng vs cờ rời rạc, vì sao `GamePhase` + `GameEndReason?` cho phép tổ hợp vô nghĩa. Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, hỏi AI local: *"Trong `game_screen.dart`, liệt kê các tổ hợp `_phase` × `_endReason` mà compiler cho phép nhưng vô nghĩa trong app — và một tập state đóng sẽ loại chúng thế nào?"* — đối chiếu với phân tích trong bài (12 tổ hợp → chỉ ~3 hợp lệ).

Checkpoint code sang bài sau: `game_screen.dart` vẫn giữ `GameEndReason? _endReason` + `showDialog` tay — đúng trạng thái cuối M14, chưa đổi gì.
