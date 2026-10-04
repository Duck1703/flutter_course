---
title: Khoá học này dành cho ai?
description: Đối tượng học viên, cách dùng khoá học và cách mỗi bài học được tổ chức.
sidebar:
  order: 1
---

## Bạn là ai?

Khoá học này được viết cho một profile rất cụ thể:

- Bạn **đã biết lập trình** — biến, hàm, class, collection, control flow.
- Bạn **đã làm Android**: Kotlin, Jetpack Compose, ViewModel, repository pattern.
- Bạn **chưa từng viết Dart hoặc Flutter** — hoặc chỉ mới nhìn qua.

Nếu đúng vậy, bạn đang ở đúng chỗ. Mỗi khái niệm Dart/Flutter đều được giải thích
từ đầu, và kiến thức Android của bạn được dùng làm **cầu nối** — không phải lối tắt.

:::tip[Cầu nối Android / Compose]
Trong mỗi bài, phần *Cầu nối Android* chỉ ra điểm giống (SIMILARITY), điểm khác
quan trọng (IMPORTANT DIFFERENCE) và cạm bẫy tư duy (DO NOT ASSUME). Analogy chỉ
để tăng tốc — Flutter có mental model riêng và bạn cần học nó đúng nghĩa.
:::

## Khoá học xây dựng cái gì?

Bạn sẽ tái xây dựng từng bước app quiz **AI Millionaire** — một app Flutter
production-grade kiểu "Ai là triệu phú": menu hub, ván chơi 15 câu có đếm giờ,
3 lifeline (50:50, hỏi khán giả, hỏi AI), bảng xếp hạng, cài đặt, onboarding,
và lớp tài khoản Supabase tuỳ chọn.

Codebase senior gốc tồn tại thật và được dùng làm **bằng chứng tham chiếu** —
khi bài học nói "app senior làm như thế này", luôn có đường dẫn file cụ thể để
bạn mở ra đọc. Bạn **không copy** code senior; bạn hiểu nó, rồi tự xây phiên bản
đơn giản hơn, rồi nâng dần lên.

:::note[Trong project senior]
Các khung "Trong project senior" trỏ tới file/symbol thật trong repository gốc
(ví dụ `lib/main.dart`, `MenuScreenView`). Đọc để đối chiếu — đừng dán vào app.
:::

## Vòng lặp học → xây → kiểm chứng

Mỗi milestone đi theo cùng một nhịp:

1. **Khái niệm mới** — nó tồn tại để giải quyết vấn đề gì?
2. **Mental model** — mô hình đơn giản nhất mà vẫn đúng.
3. **Ví dụ nhỏ** — đoạn code tối thiểu chạy được.
4. **Cầu nối Android** — map sang thứ bạn đã biết, kèm cảnh báo khác biệt.
5. **Soi code senior** — app thật dùng khái niệm này ở đâu, vì sao?
6. **Tự implement** — viết phiên bản đơn giản trong learner app.
7. **Chạy và quan sát** — mọi bài đều kết thúc bằng thứ nhìn thấy được.
8. **Kiểm tra hiểu biết** — câu hỏi nhỏ, trả lời được bằng app đang chạy.

## Cấu trúc bài học

Mỗi bài học có cùng bộ khung: mục tiêu → bạn đang ở đâu → tại sao cần ngay bây
giờ → mental model → Dart/Flutter cần thiết → cầu nối Android → bằng chứng senior
→ implement từng bước → đọc hiểu code → chạy và quan sát → lỗi thường gặp →
kiểm tra hiểu biết → "cố ý chưa làm gì" → điểm kiểm tra hoàn thành.

Phần *"Cố ý chưa làm"* quan trọng không kém phần code: nó nói rõ bạn đang dùng
phiên bản **đơn giản hoá có chủ đích**, và kiến trúc senior sẽ quay lại ở
milestone nào.

## Chuẩn bị môi trường

Bạn cần:

- **Flutter SDK** stable (kiểm tra: `flutter --version`).
- **Một target để chạy**: Android emulator/device, Chrome cho web, hoặc iOS
  simulator nếu trên macOS. Kiểm tra bằng `flutter doctor`.
- Một editor có Flutter plugin (VS Code hoặc Android Studio) — tiện cho Hot
  Reload, nhưng command line là đủ.

Không cần cài thêm package bên thứ ba nào cho M01–M03 — chỉ Flutter SDK.

## Quy ước trong bài học

- **learner app**: project Flutter bạn đang xây (package `ai_millionaire_course`).
- **app senior / project senior**: repository tham chiếu `flutter-accelerator-ai`
  (package `ai_millionaire`) — mục tiêu cuối cùng.
- **milestone** (`M01`, `M02`, ...): một bước có kết quả chạy được, kiểm chứng được.
- **bài học**: đơn vị nhỏ hơn trong mỗi milestone — một trang như trang này.
- Code block luôn ghi rõ **đường dẫn file** và **thêm mới hay thay thế**.

:::caution[Nguyên tắc quan trọng]
Mỗi đoạn code mới xuất hiện đều được giải thích trước hoặc ngay khi dùng. Nếu bạn
gặp một khái niệm chưa từng được giới thiệu, đó là lỗi của bài học — hãy quay lại
bài trước hoặc lộ trình để kiểm tra thứ tự.
:::

Sẵn sàng? Đọc [lộ trình M01–M29](/roadmap/) hoặc đi thẳng vào
[M01 — Chạy app Flutter đầu tiên](/m01/).
