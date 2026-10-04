# Release-kit walkthrough (M29 — explained, không chạy)

Tài liệu này giải thích bộ máy release mà project senior vendored sẵn
tại `scripts/kit/` + `.release-kit/` — nó là gì, đọc ở đâu, và tại sao
learner app **cố tình không copy**.

## 1. Senior có gì

Repo senior (`flutter-accelerator-ai`) chứa hai mảng:

- `scripts/kit/` — bản vendored của **flutter-release-kit**, một toolkit
  bash project-agnostic: debug/release build Android & iOS, hot-reload
  scripts, và pipeline beta (Google Play internal testing / TestFlight).
  Kit tự chứa hoàn toàn (riêng `bin/`, `lib/`, `templates/`, `docs/`),
  không bake sẵn kiến thức của app cụ thể.
- `.release-kit/project.env` — file **commit** khai báo các dart-define
  runtime của app (ví dụ `SUPABASE_URL`,
  `SUPABASE_PUBLISHABLE_KEY`, `GOOGLE_WEB_CLIENT_ID`). Giá trị thật
  (secrets) nằm trong `config/runtime.env` **gitignored** — kit chỉ đọc,
  không commit secret.

Ý tưởng cốt lõi: *"one source of truth — from hot reload to beta
release."* Cùng một tập dart-define được tái dùng cho mọi lệnh build,
thay vì gõ lại `--dart-define` ở từng nơi.

## 2. Tại sao learner không copy

1. **Read-only + scope**: senior repo là tham chiếu chỉ-đọc; M29 yêu
   cầu *hiểu* release kit, không *thực thi* nó. Course không có
   keystore/credential nào để chạy ký — và cũng không nên có trong
   môi trường học.
2. **Không có build target cần ký**: quy trình QA của course là
   `flutter test` + `flutter analyze` + `flutter build web`. Kit chủ
   yếu phục vụ APK/AAB/IPA ký + beta track — ngoài phạm vi app học tập.
3. **Secret boundary giữ nguyên**: learner đã đọc `SUPABASE_URL` /
   `SUPABASE_PUBLISHABLE_KEY` qua `--dart-define` trực tiếp trong
   `main.dart` (đúng pattern senior). Học viên tự cung cấp key của
   project Supabase *của mình* khi chạy — không có shared config nào
   cần kit quản lý.

## 3. Nếu học viên muốn dùng thật

Đọc senior `scripts/kit/README.md` (bilingual, có `docs/vi/`), sau đó
với repo *của riêng mình*:

```bash
scripts/kit/install.sh   # cài kit vào repo riêng
# khai báo dart-define trong .release-kit/project.env
# đặt giá trị thật trong config/runtime.env (gitignored)
```

Quy tắc bất biến của course vẫn áp dụng: **không bao giờ commit
secret** — kit được thiết kế đúng ranh giới đó (project.env commit,
runtime.env gitignore).

## 4. Feature checklist

Đối chiếu cuối cùng app-level với `project-context/FEATURE_INVENTORY.md`
được ghi ở `AI_HANDOFF/work/milestones/M29/` — checklist artifact, không
phải file của app.
