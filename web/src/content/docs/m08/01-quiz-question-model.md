---
title: "Bài 1 · QuizQuestion & ngân hàng câu hỏi"
description: "Model câu hỏi bất biến (question/options/correctIndex) và bank const 4 câu về các khái niệm đã học — dữ liệu trước, UI sau."
sidebar:
  label: "Bài 1 · QuizQuestion model"
  order: 1
---

## Mục tiêu

Viết model `QuizQuestion` bất biến và ngân hàng `quizQuestions` gồm 4 câu
const — nền dữ liệu mà `GameScreen` sẽ render ở các bài sau.

## Bạn đang ở đâu

- Milestone: **M08 — Mini-quiz & widget test** (bài 1/4)
- App hiện tại: `GameScreen` là layout tĩnh (M07) — câu hỏi và đáp án
  hard-code trong widget, giống menu trước M04.

## Vì sao việc này quan trọng ngay bây giờ

Đúng bài học M04 lặp lại ở quy mô mới: **dữ liệu rải trong widget = không
thể test, không thể thay đổi, không thể đếm câu**. Muốn "câu tiếp theo"
ta cần một *danh sách* câu hỏi — tức là một model + một `List`. Nguyên tắc
giống hệt: model trước, UI sau.

## Bạn đã biết gì

- Mọi thứ của M04: `final`, `const` ctor, named params `required`,
  `List<T>`, method trong model. Đây là áp dụng lại, không phải khái niệm
  mới — chỉ có 2 điểm Dart nhỏ mới (bảng dưới).

## Mental model mới

**Một câu quiz = một object bất biến; cả bộ quiz = một `List` const.**

```
QuizQuestion
├─ question: 'Widget nào có State…?'
├─ options: ['StatelessWidget', 'StatefulWidget', 'Scaffold', 'Container']
└─ correctIndex: 1        ← options[1] = 'StatefulWidget' là đúng
```

Câu hỏi không bao giờ "đổi" — sai lúc chơi chỉ là *trạng thái màn hình*
thay đổi (đang chọn gì, đã chốt chưa). Tách rõ: **dữ liệu câu hỏi**
(immutable, `const`) vs **state lượt chơi** (mutable trong `State` — bài 2).

## Dart cần dùng

| Cú pháp | Ví dụ | Nghĩa |
| --------- | ------- | ------- |
| `const List<QuizQuestion>` | `const quizQuestions = [QuizQuestion(…), …]` | Danh sách compile-time: tạo 1 lần, mọi `import` dùng chung instance |
| Method trên model | `q.isCorrect(i)` | Logic chấm điểm sống trong model — UI không rải `== correctIndex` |

Vì sao không có `explanation`/`category`/`id` như senior? Model chỉ chứa
đúng thứ UI dùng — thêm trường "cho giống senior" là phạm quy tắc M04
(model vì nhu cầu, không vì parity).

## Flutter cần dùng

Không có API mới — bài này ở tầng Dart/data.

## Android / Compose bridge

- SIMILARITY: `const quizQuestions` ≈ `val questions = listOf(...)` trong
  `object`/`companion` — dữ liệu tĩnh gom một chỗ.
- IMPORTANT DIFFERENCE: `const` list của Dart là *compile-time canonical*
  — hai chỗ dùng `quizQuestions[0]` là **cùng một instance**, không phải
  bản copy.
- DO NOT ASSUME: `List` của Dart bất biến — `const` list thì thật sự
  immutable, nhưng `List` thường vẫn mutable; model giữ `final List` là đủ.

## Senior project connection

- `flutter-accelerator-ai/lib/data/game/game_quiz_question_data.dart` —
  `GameQuizQuestionData`: `id`, `question`, `options`, `correctOption`
  (lưu **chuỗi** đáp án đúng, không phải index), `category`, `difficulty`,
  `explanation` per-option. Bản learner gọn hơn nhiều: `correctIndex`
  (int) đủ cho UI 4 ô.
- `flutter-accelerator-ai/lib/data/game/game_sample_easy_questions_data.dart`
  — bank senior là `const` list theo difficulty (easy/medium/hard).
  Ta giữ **một** bank `const` — cùng pattern, khác quy mô.

## Build it step by step

### Bước 1 — Model câu hỏi

```dart
// lib/data/game/quiz_question.dart — FILE MỚI
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  bool isCorrect(int index) => index == correctIndex;
}
```

- Folder `lib/data/game/` mới — quy ước senior (`data/game/`) khi data của
  domain "game" xuất hiện; `data/profile/` của M04 vẫn là profile.
- Không `copyWith`/`==`/`hashCode`: câu hỏi không bao giờ bị "cập nhật"
  hay so sánh — chỉ đọc. Chỉ viết khi cần (M04 đã nói: equality để phục vụ
  việc so sánh, không phải nghi lễ).

### Bước 2 — Ngân hàng câu hỏi

```dart
// lib/data/game/quiz_questions.dart — FILE MỚI
import 'quiz_question.dart';

const quizQuestions = [
  QuizQuestion(
    question: 'Widget nào có State có thể thay đổi và rebuild UI?',
    options: ['StatelessWidget', 'StatefulWidget', 'Scaffold', 'Container'],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'Hàm nào báo cho Flutter rằng State thay đổi và cần rebuild?',
    options: ['rebuild()', 'notifyListeners()', 'setState()', 'refresh()'],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'Future<T> trong Dart đại diện cho điều gì?',
    options: [
      'Một luồng chạy song song',
      'Một danh sách giá trị theo thời gian',
      'Một kết quả sẽ có sau (hoặc lỗi)',
      'Một hàm đồng bộ trả về T',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'copyWith() của model bất biến dùng để làm gì?',
    options: [
      'Sửa trực tiếp field của object cũ',
      'Tạo object mới với vài trường thay đổi',
      'Sao chép một widget trong cây',
      'So sánh hai object',
    ],
    correctIndex: 1,
  ),
];
```

Câu hỏi ôn lại đúng M01–M06 — game vừa chơi vừa ôn. `flutter analyze`
phải sạch.

## Hiểu code

`const` lan truyền: `const quizQuestions` → mọi `QuizQuestion` bên trong
cũng const (constructor const + tham số const literal). `correctIndex` là
index vào `options` — `isCorrect(i)` che đi phép so sánh; khi UI cần biết
"đáp án đúng là ô nào" nó đọc `question.correctIndex` trực tiếp.

## Chạy và quan sát

- `flutter analyze` — sạch. App chạy y hệt cũ (model chưa được dùng —
  bình thường, đây là bước data).
- In nhanh: `print(quizQuestions.length)` trong `main()` tạm thời → 4.

## Lỗi hay gặp

1. **Để `correctIndex` vượt phạm vi options** — compile không báo lỗi;
   lỗi chỉ lộ lúc render. → Test integrity (bài 4 + file test sẵn).
2. **Copy bank senior cho "đầy đủ"** — 15 câu + explanation map sẽ kéo
   theo UI chưa học. Bank nhỏ là cố ý.
3. **Cho `options` mutable rồi sửa lúc chơi** — model phải immutable;
   "đã chọn" là state màn hình, không phải sửa câu hỏi.

## Kiểm tra hiểu biết

1. Vì sao `quizQuestions` khai báo `const`? — *Data cố định compile-time;
   một instance dùng chung toàn app, không cấp phát lại.*
2. `isCorrect(2)` trên câu 2 trả gì? — *`true` (`correctIndex: 2`,
   `setState()`).*
3. Vì sao model không cần `copyWith`? — *Câu hỏi không bao giờ "được cập
   nhật" — immutable-update chỉ cần khi state đổi qua object mới.*

## Tự làm (MODIFY)

Thêm một field mới cho `QuizQuestion`: `explanation` — lời giải thích
hiển thị sau khi chốt đáp án (senior cũng có khái niệm này; UI của nó
đến sau, hôm nay chỉ model + data).

Trước khi code, quyết:

1. `explanation` nên là `String` hay `String?`? Nên `required` không —
  nếu `required`, điều gì xảy ra với 4 câu đã có trong bank?
2. Thêm param mới vào constructor theo kiểu nào để **không phải sửa 4
   câu hiện có**?
3. Có cần `copyWith`/`==`/`hashCode` cho field mới không? (Nhớ lý do
   model này không có chúng từ đầu.)

Sau đó: thêm field + param, thêm `explanation` cho câu hỏi đầu tiên
trong bank, `flutter analyze`, và in thử `quizQuestions[0].explanation`
trong `main()` tạm thời.

:::note[Gợi ý]
"Không phải câu nào cũng có lời giải" là dữ kiện quan trọng cho quyết
định kiểu. Và named-param-optional có một đặc tính dễ quên: constructor
cũ gọi mà không truyền param mới vẫn hợp lệ.
:::

<details><summary>Đáp án</summary>

```dart
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation; // nullable: không phải câu nào cũng có giải thích

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation, // optional — nullable tự default null
  });

  bool isCorrect(int index) => index == correctIndex;
}
```

- `String?` + `this.explanation` (không `required`, không default): nếu
  là `required`, cả 4 câu trong bank biến thành lỗi compile — "một field
  mới" vô tình làm nghĩa vụ sửa mọi chỗ khởi tạo. Optional nullable giữ
  mọi call-site cũ hợp lệ: `explanation` của chúng tự `null`.
- Không cần `copyWith`/`==`: câu hỏi không được cập nhật hay so sánh —
  quyết định M04-style chỉ-viết-khi-cần vẫn đứng.
- Kiểm chứng: `flutter analyze` sạch (không sửa bank), `print` in ra
  explanation của câu 1 — câu 2–4 trả `null` đúng thiết kế.

</details>

## Ta cố ý chưa thêm

- `id`/`category`/`difficulty`/`explanation` — senior có; ta thêm khi UI
  thật sự cần (explanation dialog ở M19+, difficulty khi chia độ khó).
- Tải câu hỏi từ JSON/DB — M10+; `const` bank là đủ cho mini-quiz.
- `==`/`hashCode` — không có nhu cầu so sánh câu hỏi.

## Checkpoint hoàn thành

- [ ] `lib/data/game/quiz_question.dart` + `quiz_questions.dart` tồn tại,
  `const`, compile sạch.
- [ ] Bank có 4 câu, mỗi câu ≥2 options, `correctIndex` trong phạm vi.
