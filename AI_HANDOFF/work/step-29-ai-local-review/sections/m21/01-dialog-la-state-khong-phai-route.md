## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — thuần mental model (dialog = projection của `dialogState`, 3 "mùi" của scaffold route, ví dụ overlay standalone). Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, chỉ cần xác nhận baseline còn nguyên trước khi phá ở Bài 2:

```bash
flutter analyze   # sạch
flutter test      # 147/147 — y hệt cuối M20, không file nào đổi
```

Kiểm tra hiểu (tự trả lời, không cần AI): tìm `_showCurrentDialog` trong `lib/screens/game_screen.dart` và đếm số chỗ `emitEvent(GameDialogRequested(...))` trong `game_screen_view_model.dart` — phải đếm được **10 chỗ**. Đó chính là "giá route" M21 sẽ trả xong ở Bài 4. Không đếm được 10 chỗ thường nghĩa là project đã đi trước (đã cắt scaffold = AHEAD) hoặc có chỗ emit bị thiếu từ M19–M20.

Checkpoint code sang bài sau: không file/field mới nào — màn vẫn chạy `showDialog` + `_GameDialogHost` (ListenableBuilder) + cờ `_dialogOpen` + nhánh `action == null` re-route.
