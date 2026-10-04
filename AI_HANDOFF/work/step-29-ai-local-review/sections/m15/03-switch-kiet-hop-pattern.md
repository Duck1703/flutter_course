## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — `switch` expression + object patterns vẫn luyện trên ví dụ độc lập `PaymentState`/`ConnectionState`. Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, hỏi AI local: *"Viết `String describe(ConnectionState)` bằng switch expression kiệt hợp với object pattern `(:final retries)`; rồi cho xem compiler báo gì nếu thiếu một case."* — đối chiếu với `non_exhaustive_switch_expression` trong bài.

Checkpoint code sang bài sau: project vẫn y hệt cuối M14. `_handleUiEvent` vẫn là `is`-chain — switch kiệt hợp áp dụng vào app ở bài 4–5, chưa phải bây giờ.
