## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — thuần mental model: session game = máy trạng thái hữu hạn 6 phase, widget forward ý định, VM sở hữu quyết định. Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, hỏi AI local: *"Đọc `lib/screens/game_screen.dart` — liệt kê mọi biến state trong `_GameScreenState` (index, phase, dialog, timer, điểm…) và chỉ ra tổ hợp vô nghĩa có thể biểu diễn được (vd `phase=revealing` + `selected=null` + dialog Ended)."* — chính là "bằng chứng vấn đề" mà M19 giải quyết.

Checkpoint code sang bài sau: `game_screen.dart` vẫn là bản cũ 600+ dòng chạy được — đừng vội xé nó; Bài 2 mới stub.
