## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — thuần lý thuyết: resource vs literal, pipeline `ARB → gen-l10n → AppLocalizations → of(context)`, fallback chain. Bạn không cần AI kiểm tra code ở đây.

Nếu muốn tự kiểm, hỏi AI local: *"Liệt kê các literal tiếng Việt hardcode trong `lib/screens/` và `lib/widgets/` của app — mỗi chuỗi sẽ thành một key ARB tương lai; chuỗi nào là data (không l10n) theo bạn?"* — đối chiếu với ranh giới chrome-vs-data trong bài.

Checkpoint code sang bài sau: `lib/l10n/` chưa tồn tại, `languageCode` đã persist (M16) nhưng chưa lái gì — đúng trạng thái.
