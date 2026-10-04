## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — thuần mental model (save = hiệu ứng cạnh của transition kết thúc; `hasSavedResult`; bảng 4 điểm kết thúc → payload). Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, xác nhận baseline còn nguyên trước khi cắt ở Bài 4:

```bash
flutter analyze   # sạch
flutter test      # 157/157 — y hệt cuối M21
```

Và cơ chế scaffold CŨ phải vẫn còn sống nguyên (chưa retire — đó là việc của Bài 4):

- `lib/data/game/game_result.dart` tồn tại.
- `GameSessionState.resolvedResult` + `clearResolvedResult` vẫn trong state file.
- `MenuViewModel.applyGameResult`, `GameScreenViewModel.buildGameResult`, `openGame` trả `Future<GameResult?>`, `Navigator.pop(result)` đều còn.
- `UserProfileData` vẫn có `expForNextLevel`/`gainExp`/`expPercent`/`expPerCorrectAnswer`.

Kiểm tra hiểu (tự trả lời): "nếu user bấm VỀ MENU trên dialog game-over, `saveCallCount` là mấy?" — đáp án: **1** (`_endGame` đã ghi, `backToMenu` thấy `hasSavedResult` → bỏ qua).

Checkpoint code sang bài sau: không file/field mới — transport route-result vẫn là cơ chế duy nhất đưa kết quả về menu.
