## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — ví dụ `PaymentState`/`ConnectionState` là Dart độc lập (scratch), chưa áp dụng vào app. Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, hỏi AI local: *"Viết một sealed class `ConnectionState` với 3 variant (offline, connecting kèm `retries`, online) — nhớ luật cùng file, base không khởi tạo, `const` ctor, `final class` cho variant lá."* — đối chiếu với đáp án trong bài.

Checkpoint code sang bài sau: project không đổi so với cuối M14 — `MenuUiEvent` vẫn `abstract`, `_endReason` vẫn enum nullable. Đừng áp dụng sealed vào app sớm — đó là nội dung bài 4–5.
