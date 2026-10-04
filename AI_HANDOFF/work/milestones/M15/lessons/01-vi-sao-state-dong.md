---
title: "Bài 1 · Vì sao cần state đóng — finite variants vs trường rời rạc"
description: "Từ nhóm biến rời rạc tới một tập state đóng; invalid combinations; UI hỏi 'đang ở state nào'. Bài thuần lý thuyết — chưa đổi code."
sidebar:
  label: "Bài 1 · Vì sao cần state đóng"
  order: 1
---

## Mục tiêu

Sau bài này bạn **giải thích được**:

- Vì sao một nhóm biến rời rạc (`isLoading`, `hasError`, `_endReason`…)
  cho phép **tổ hợp vô nghĩa** mà compiler không chặn.
- "Tập state đóng" là gì — và vì sao UI nên hỏi *"mình đang ở state
  nào?"* thay vì đọc nhiều cờ.
- Ý nghĩa của "state-driven UI": render = hàm của state.

**Bài này không sửa code** — nó xây mental model mà bốn bài sau dùng.

## Bạn đang ở đâu

- Milestone: **M15** (bài 1/5) — milestone đầu tiên sau khi course có
  đủ nền: enum (M08), `switch` (M09), event bridge (M13), repository
  stream (M14).
- App cuối M14: menu bridge dùng `if (event is …)`; màn chơi lưu lý
  do kết thúc bằng `GameEndReason? _endReason` và mở `AlertDialog` tay.
- M15 sẽ nâng hai chỗ đó lên "tập đóng" đúng shape senior — nhưng trước
  hết phải thấy *vì sao* cần nâng.

## Vì sao việc này quan trọng ngay bây giờ

Nhìn kỹ state đang mở dialog của game ở cuối M14:

```dart
GamePhase _phase = GamePhase.finished;
GameEndReason? _endReason = GameEndReason.timeout;
```

Hai field này là **hai biến độc lập**. Compiler cho phép mọi tổ hợp —
kể cả những tổ hợp vô nghĩa:

```dart
_phase = GamePhase.answering;
_endReason = GameEndReason.victory;   // đang chơi mà "vừa thắng"??
```

`_endReason != null` nhưng `_phase == answering` — app đang trong một
state "không tồn tại". Không lỗi biên dịch, không crash — chỉ là UI có
thể render sai mà không ai báo. Đây là dạng bug kinh điển của mô hình
"cờ rời rạc": **số tổ hợp hợp lệ nhỏ hơn số tổ hợp compiler cho phép**.

Cách senior giải: mô hình hoá trực tiếp *tập các state hợp lệ* — một
kiểu dữ liệu chỉ chứa đúng các variant tồn tại thật. `GameDialogState`
của senior không có cách nào biểu diễn "đang chơi nhưng vừa thắng" —
tổ hợp đó *không thể được tạo ra*.

## Bạn đã biết gì

- `enum` (M08): tập giá trị đóng — nhưng mỗi giá trị **không mang dữ
  liệu riêng**.
- `switch` statement trên enum (M09): compiler cảnh báo khi thiếu case.
- UI event một-lần vs state (M13): event = "việc vừa xảy ra", state =
  "đúng cho tới khi đổi".
- `is` type check (M13/01 gloss): đọc kiểu runtime của object.

## Mental model mới — "tập đóng các variant"

Hình dung state UI như **danh sách màn hình con hợp lệ**: một dialog
kết quả của game *chỉ có thể* là một trong vài thứ — "không có dialog",
"dialog ván thua (kèm lý do)", "dialog chiến thắng". Mỗi variant:

- **có tên riêng** — đọc tên là biết UI đang hiện gì;
- **mang payload riêng** — `GameEndedDialog` cần lý do, `GameDialogHidden`
  không cần gì;
- **loại trừ lẫn nhau** — một object chỉ là một variant tại một thời điểm.

Khác với enum: enum chỉ là tên không mang payload. Khác với cờ rời rạc:
không có tổ hợp vô nghĩa nào được phép tồn tại.

Giới hạn của mental model này: "tập đóng" chỉ đáng giá khi các variant
**thật sự hữu hạn và biết trước**. Danh sách mở (item không đếm trước
được) thì sealed không áp dụng — ta sẽ nói lại ở bài 2.

## Dart cần dùng

Không có syntax mới — bài lý thuyết. Nhắc lại: `enum` (M08) và
`switch` statement (M09) là hai công cụ "tập đóng" đã học; M15 nâng
chúng lên `sealed` (bài 2) + `switch` expression (bài 3).

## Flutter cần dùng

Không có API mới — điểm Flutter của milestone nằm ở bài 5
(`switch` trên state chọn nội dung dialog).

## Ví dụ độc lập — "boolean soup"

Không liên quan project — minh hoạ vấn đề bằng một form thanh toán:

```dart
// Kiểu "cờ rời rạc" — mỏi mắt và nguy hiểm:
bool isLoading = false;
bool hasError = false;
bool isDialogOpen = false;

// Tổ hợp compiler vẫn cho qua, dù vô nghĩa:
isLoading = true;
isDialogOpen = true;   // đang tải MÀ dialog lỗi đã mở?
```

Cùng màn hình, viết theo tập đóng:

```dart
// Khái niệm — chi tiết `sealed` ở bài 2:
// PaymentIdle | PaymentProcessing | PaymentSuccess(id) | PaymentFailure(error)
```

Bốn variant, mỗi variant là MỘT state hợp lệ. Không có "vừa processing
vừa success". UI chỉ cần hỏi: *"state hiện tại là variant nào?"*

## Android / Compose bridge

- **SIMILARITY**: Kotlin `sealed class` + `when` — ý tưởng giống hệt:
  tập đóng subtype, compiler kiểm tra đủ case.
- **IMPORTANT DIFFERENCE**: Dart `sealed` là *tính năng ngôn ngữ Dart 3*
  với luật riêng (cùng file, pattern matching, kiệt hợp trong `switch`
  expression). Bài 2–3 dạy cú pháp Dart — **đừng chỉ nhớ "giống
  Kotlin"** rồi bỏ qua phần syntax.
- **DO NOT ASSUME**: enum = đủ. Enum không mang payload riêng từng
  giá trị — `PaymentSuccess(transactionId)` không làm được bằng enum.

## Senior project connection

- `flutter-accelerator-ai/lib/data/game/game_session_state_data.dart`:
  `sealed class GameDialogState` — senior mô hình hoá **chín variant**
  dialog của màn chơi (thang tiền, xác nhận thoát, giải thích, trợ
  giúp khán giả, trợ giúp AI, kết thúc, chiến thắng…). UI không đếm
  cờ — nó `switch` trên state.
- `flutter-accelerator-ai/lib/widgets/game/dialogs/game_dialog_layer.dart`:
  `_dialogBody` là một `switch (dialog)` **expression** — mỗi variant
  trả về đúng widget tương ứng.

## Build it step by step

Không có code thay đổi trong bài này — lý thuyết chuẩn bị. Hãy tự trả
lời được: "màn game của mình đang có bao nhiêu *variant dialog hợp lệ*,
và hiện tại chúng được biểu diễn bằng cái gì?"

## Chạy và quan sát

Mở `learner-app/lib/screens/game_screen.dart` và tìm `_endReason`.
Nhận ra: nó là `GameEndReason?` — một field nullable rời rạc, không
ràng buộc gì với `_phase`. Đó chính là chỗ M15 sẽ thay.

## Thử nghiệm

Đếm tổ hợp: `_phase` (3 giá trị) × `_endReason` (3 + null) = **12 tổ
hợp compiler cho phép**. Liệt kê ra giấy: bao nhiêu tổ hợp *thực sự
có nghĩa* trong app? (Đáp án quan sát: 3 — đang chơi / đang reveal /
kết thúc-với-lý-do.) Phần còn lại là chỗ bug lặng trú.

## Lỗi hay gặp

- **"Thêm một bool cho nhanh"** — mỗi cờ mới *nhân đôi* số tổ hợp.
  Ba cờ = 8 tổ hợp, phần lớn vô nghĩa.
- **"Nullable field coi như state"** — `GameEndReason?` null nghĩa gì?
  "Chưa kết thúc"? Compiler không giúp bạn nhớ điều đó.
- **Oversell** — không phải mọi nhóm trạng thái đều cần sealed; bài 2
  nói rõ khi nào KHÔNG dùng.

## Tự làm

L01 là bài lý thuyết — bài tập sản xuất nằm ở L02/L05.

## Kiểm tra hiểu biết

1. Vì sao `isLoading + hasError + isDialogOpen` nguy hiểm hơn một
   variant duy nhất?
2. Enum đóng tập giá trị — vậy enum thiếu gì so với nhu cầu "mỗi
   variant mang dữ liệu riêng"?
3. "UI hỏi *đang ở state nào* rồi render" khác "set cờ rồi hy vọng UI
   đọc đúng" ở đâu?

<details><summary>Đáp án</summary>

1. Ba cờ tạo 8 tổ hợp; chỉ vài tổ hợp hợp lệ. Compiler không chặn tổ
   hợp vô nghĩa — bug lặng. Một variant sealed chỉ cho phép đúng các
   state tồn tại thật.
2. Enum không mang payload riêng từng giá trị — `Success(id)` không
   biểu diễn được bằng enum thuần.
3. Trường hợp đầu: state là nguồn truth duy nhất, UI là *hàm* của nó.
   Trường hợp sau: state phân tán trên nhiều biến, mỗi chỗ đọc tự diễn
   giải tổ hợp — dễ lệch.

</details>

## Ta cố ý chưa thêm

- Layer dialog trong `Stack` + `AnimatedSwitcher` của senior — **M21**.
- `MenuDialogState` trong learner — menu learner chưa có dialog nào
  (settings M16, leaderboard M23, auth M24); type sẽ đến cùng consumer
  đầu tiên của nó.

## Checkpoint hoàn thành

- [ ] Nêu được ví dụ tổ hợp vô nghĩa mà `_endReason` + `_phase` cho
      phép ở cuối M14.
- [ ] `flutter analyze` vẫn sạch (bài này không đổi code).
