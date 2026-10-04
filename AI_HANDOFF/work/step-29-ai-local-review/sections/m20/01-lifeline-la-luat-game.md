## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — thuần mental model: lifeline là luật game sống trong `GameSessionState` (`Set<GameFeatureButtonType> usedFeatureButtons`), guard đọc / mutation ghi; ví dụ `Wallet` là standalone. Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, hỏi AI local: *"Đọc `GameSessionState` và `GameScreenViewModel` hiện tại — chỗ nào sẽ đặt một `Set` 'đã dùng' cho lifeline, và method nào sẽ là cổng guard trước mutation?"* — câu trả lời đúng: field trên `GameSessionState` (bài 2), `handleFeatureClick`/`_canUseFeature` (bài 3).

Checkpoint code sang bài sau: không file/field mới nào — app chạy y hệt cuối M19 (126/126).
