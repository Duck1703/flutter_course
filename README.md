# flutter_course

AI Millionaire — khóa học Flutter tiếng Việt cho người mới bắt đầu
(M01–M29), dựng lại 1:1 kiến trúc app Flutter Accelerator AI.

- `learner-app/` — Flutter app của học viên (Provider + MVVM + DRE)
- `web/` — trang khóa học Astro/Starlight
- `project-context/` — trạng thái canonical của khóa học
- `AI_HANDOFF/` — artifacts quy trình Agent Product
- `lessons/` — nội dung bài học

## Chạy app

```bash
cd learner-app
flutter pub get
flutter test
flutter run
```

## Chạy website

```bash
cd web
npm install
npm run dev
```
