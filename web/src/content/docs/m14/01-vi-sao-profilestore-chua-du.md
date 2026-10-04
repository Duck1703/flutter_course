---
title: "Bài 1 · Vì sao ProfileStore chưa đủ — mental model repository"
description: "Storage primitive vs ranh giới ứng dụng; dependency direction; vì sao VM không được biết SharedPreferences. Bài này thuần lý thuyết — chưa đổi code."
sidebar:
  label: "Bài 1 · Vì sao ProfileStore chưa đủ"
  order: 1
---

## Mục tiêu

Sau bài này bạn **giải thích được** — bằng lời của mình, không cần code:

- "Repository" là gì, và nó khác "storage" ở chỗ nào.
- Vì sao `MenuViewModel` ôm trực tiếp `ProfileStore` là một ranh giới
  sai trong project này.
- "Dependency direction" — mũi tên phụ thuộc nên chỉ về hướng nào.

**Bài này không sửa một dòng code nào** — đó là chủ đích. M14 đổi
kiến trúc nền của app; hiểu mental model trước thì bảy bài sau chỉ là
"gõ ra cái đã hiểu".

## Bạn đang ở đâu

- Milestone: **M14** (bài 1/7) — milestone nặng nhất từ đầu course.
- App hiện tại (cuối M13): `MenuViewModel` giữ `ProfileStore`
  concrete, gọi `load()`/`save()`/`reset()` tay, tự quản
  `MenuLoadState` loading/ready/failed.
- M14 sẽ thay toàn bộ bằng kiến trúc **repository + stream state**
  đúng shape senior — đây là điểm course ngừng "dạy từng mảnh" và bắt
  đầu "kiến trúc như app thật".

## Vì sao việc này quan trọng ngay bây giờ

`ProfileStore` làm đúng việc của nó: một key, JSON encode/decode, ba
hàm đọc-ghi. Nhưng nó chỉ là **primitive lưu trữ** — trả lời câu hỏi
"*ghi vào đĩa thế nào*". Project senior cần một ranh giới khác:
**repository** — trả lời câu hỏi "*ai được đọc/ghi profile, và ai đang
nghe khi nó đổi*".

Hai vấn đề cụ thể với bản concrete hiện tại:

1. **VM biết quá nhiều.** `MenuViewModel` ôm `ProfileStore` — nghĩa là
   nó biết tồn tại SharedPreferences, JSON, key `'user_profile'`. Muốn
   test VM mà không chạm prefs? Phải `extends ProfileStore` và override
   hàm — hacky và dễ vỡ.
2. **Dữ liệu đứng yên.** `load()` trả về một snapshot; nếu sau này một
   nơi khác ghi profile (ví dụ sync từ server — senior có), VM không
   hề biết. Ai muốn dữ liệu mới phải tự hỏi lại. `MenuLoadState` của
   M11–M13 chính là miếng vá cho thiếu hụt đó.

## Mental model mới: hai lớp, hai câu hỏi

```
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│   Widget /   │      │  Repository  │      │   Storage    │
│  ViewModel   │─────▶│  (contract)  │─────▶│  primitive   │
│              │      │              │      │ (prefs/JSON) │
└──────────────┘      └──────────────┘      └──────────────┘
   "tôi cần gì"          "việc gì được         "ghi đĩa
                          làm / ai nghe          thế nào"
                          khi đổi"
```

Ba quy tắc của mô hình này trong project senior:

- **VM chỉ nói chuyện với contract**, không bao giờ chạm storage
  trực tiếp. VM hỏi "profile hiện tại là gì / lưu cái này" — nó
  *không biết* bên dưới là SharedPreferences, remote backend, hay
  memory. Đổi impl không đổi VM.
- **Repository giữ stream state.** Nó không chỉ đọc-ghi — nó *phát*
  giá trị mới cho mọi subscriber. "Dữ liệu đứng yên" hết khi đọc =
  emit vào stream.
- **Mũi tên phụ thuộc chỉ đi một chiều**: UI → contract → impl.
  Impl không bao giờ biết VM tồn tại. Đây là "dependency direction"
  — khi vẽ ngược (VM biết impl) là khi test bắt đầu đau.

> Đây là cách *project này* chia ranh giới — không phải dogma "mọi
> app phải có repository". Senior cần nó vì có nhiều impl cùng tồn
> tại (thật + fake + remote sau này) và VM không được biết chi tiết
> SharedPreferences.

**Android bridge:** đây chính là `interface UserProfileRepository` +
`UserProfileRepositoryImpl` inject qua Hilt — cùng một ý tưởng, cú
pháp Dart mới là phần duy nhất bạn chưa biết. `BehaviorSubject` ở
bài 3 ≈ `MutableStateFlow` bạn đã quen trong AndroidViewModel.

## Senior evidence

- `flutter-accelerator-ai/lib/repositories/profile/
  user_profile_repository.dart` — contract `abstract interface class`
  + `UserProfileRepositoryImpl` trong cùng file (senior đặt cặp
  contract/impl chung một file — learner theo y hệt).
- Senior có đến 3 impl kể cả `FakeUserProfileRepository` trong
  `test/widgets/game_screen_test_helpers.dart` — contract tồn tại
  *vì* có nhiều impl.

## Tự làm

**Nhận diện ranh giới — không cần code.** Trả lời bằng lời trước khi
xem đáp án:

1. Trong app hiện tại, liệt kê 3 thứ `MenuViewModel` "biết" mà theo
   mô hình repository nó *không nên* biết.
2. Một `CounterRepository` lưu biến đếm vào file text cũng là
   repository. Hỏi: `CounterScreen` cần biết dữ liệu nằm trong file
   text không? Nếu mai này đổi sang SharedPreferences, file nào phải
   sửa: screen, VM, hay impl?
3. Vì sao "VM gọi `repo.loadUserProfile()`" là mũi tên đúng hướng,
   còn "repo gọi `vm.notifyListeners()`" là ngược?

<details><summary><strong>Đáp án</strong></summary>

1. VM biết: tồn tại SharedPreferences; format JSON; key
   `'user_profile'`; hành vi load/save/reset là *đọc-ghi disk* (thay
   vì "hỏi một boundary"). Đây là chi tiết của lớp dưới.
2. Screen/VM không cần biết — chỉ impl sửa. Đó là cả lý do contract
   tồn tại: consumer phụ thuộc "việc gì làm được", không phụ thuộc
   "làm thế nào".
3. VM→repo đúng vì VM *cần* repo — phụ thuộc đi xuống một chiều.
   Repo→VM ngược vì repo không nên biết ai đang nghe: nó chỉ emit
   lên stream, ai subscribe thì tự nhận. Kênh ngược chiều là
   *subscription*, không phải *knowledge*.

</details>

## Tự kiểm tra

1. `ProfileStore` và `UserProfileRepository` khác nhau ở câu hỏi nào
   chúng trả lời? — *Store: "ghi đĩa thế nào". Repository: "ai được
   đọc/ghi, ai nghe khi đổi". Store là primitive, repository là
   ranh giới ứng dụng.*
2. Vì sao repository cần *stream* thay vì chỉ `Future<T> get()`? —
   *Snapshot không báo đổi; stream phát giá trị mới tới mọi
   subscriber — "dữ liệu đứng yên" là bug của pull-only.*
3. Mũi tên phụ thuộc đúng là? — *UI/VM → contract → impl. Impl
   không biết VM tồn tại; VM không biết impl là gì.*

## Ta cố ý chưa làm

- **Chưa viết một dòng code nào** — contract, subject, impl là ba
  bài kế tiếp. Đừng nhảy trước.
- **Chưa xoá `profile_store.dart`** — xoá nó bây giờ sẽ làm
  `MenuViewModel` hỏng; nó chỉ được xoá ở bài 7 sau khi VM đã chuyển
  sang contract.

## Checkpoint hoàn thành

- [ ] Giải thích được: "storage" và "repository" là hai khái niệm
      khác nhau trong app này — nêu được một ví dụ impl khác
      (remote/memory) mà VM không cần biết.
- [ ] Vẽ được dependency direction của M14 mà không nhìn lại sơ đồ.
- [ ] `flutter analyze` vẫn sạch (bài này không đổi code — nếu sạch
      trước thì sạch sau).

## 🤖 AI Local — Kiểm tra project sau bài này

Bài này **không thay đổi project** — thuần lý thuyết: repository vs storage, dependency direction, vì sao VM không được biết SharedPreferences. Bạn không cần AI kiểm tra code ở đây.

Nếu muốn, hãy hỏi AI local một câu: *"Giải thích lại bằng ví dụ: vì sao `MenuViewModel` ôm `ProfileStore` concrete là dependency direction sai, và repository sẽ sửa nó thế nào?"* — rồi tự đối chiếu với mental model trong bài.

Checkpoint code sang bài sau: `lib/data/profile/profile_store.dart` **vẫn còn** và `MenuViewModel` vẫn đang dùng nó — đúng ý đồ, đừng xoá sớm (bài 7 mới xoá).
