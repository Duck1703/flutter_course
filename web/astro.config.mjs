import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  integrations: [
    starlight({
      title: 'AI Millionaire — Flutter Course',
      description:
        'Khoá học xây dựng lại app AI Millionaire bằng Flutter, dành cho lập trình viên Android/Kotlin mới bắt đầu với Dart/Flutter.',
      defaultLocale: 'root',
      locales: {
        root: {
          label: 'Tiếng Việt',
          lang: 'vi',
        },
      },
      customCss: ['./src/styles/custom.css'],
      sidebar: [
        {
          label: 'Bắt đầu',
          items: [
            { label: 'Khoá học này dành cho ai?', slug: 'getting-started' },
            { label: 'Lộ trình M01–M29', slug: 'roadmap' },
            { label: 'Tra cứu concept', slug: 'concepts' },
            { label: 'Tiến trình state', slug: 'state-progression' },
          ],
        },
        {
          label: 'Phase A — Định hướng',
          items: [
            {
              label: 'M01 · Chạy app đầu tiên',
              autogenerate: { directory: 'm01' },
            },
            {
              label: 'M02 · Layout tĩnh',
              autogenerate: { directory: 'm02' },
            },
            {
              label: 'M03 · State & tương tác',
              autogenerate: { directory: 'm03' },
            },
          ],
        },
        {
          label: 'Phase B — Nền tảng app nhỏ',
          items: [
            {
              label: 'M04 · Model & unit test',
              autogenerate: { directory: 'm04' },
            },
            {
              label: 'M05 · Future & FutureBuilder',
              autogenerate: { directory: 'm05' },
            },
            {
              label: 'M06 · Stream & StreamBuilder',
              autogenerate: { directory: 'm06' },
            },
            {
              label: 'M07 · Navigator push/pop',
              autogenerate: { directory: 'm07' },
            },
          ],
        },
        {
          label: 'Phase C — Vòng lặp game cốt lõi',
          items: [
            {
              label: 'M08 · Mini-quiz',
              autogenerate: { directory: 'm08' },
            },
            {
              label: 'M09 · Ván game trọn vẹn',
              autogenerate: { directory: 'm09' },
            },
            {
              label: 'M10 · SharedPreferences & JSON',
              autogenerate: { directory: 'm10' },
            },
          ],
        },
        {
          label: 'Phase D — Kiến trúc state',
          items: [
            {
              label: 'M11 · ChangeNotifier',
              autogenerate: { directory: 'm11' },
            },
            {
              label: 'M12 · Provider & scope',
              autogenerate: { directory: 'm12' },
            },
            {
              label: 'M13 · Event một-lần từ VM',
              autogenerate: { directory: 'm13' },
            },
            {
              label: 'M14 · Repository & BehaviorSubject',
              autogenerate: { directory: 'm14' },
            },
            {
              label: 'M15 · Sealed & state-driven UI',
              autogenerate: { directory: 'm15' },
            },
          ],
        },
        {
          label: 'Phase E — App local giàu tính năng',
          items: [
            {
              label: 'M16 · Settings persist',
              autogenerate: { directory: 'm16' },
            },
            {
              label: 'M17 · Localization (en/vi)',
              autogenerate: { directory: 'm17' },
            },
            {
              label: 'M18 · Onboarding overlay (lần đầu)',
              autogenerate: { directory: 'm18' },
            },
          ],
        },
        {
          label: 'Phase F — Chiều sâu senior',
          items: [
            {
              label: 'M19 · Game VM có cấu trúc',
              autogenerate: { directory: 'm19' },
            },
            {
              label: 'M20 · Lifelines & nút feature',
              autogenerate: { directory: 'm20' },
            },
            {
              label: 'M21 · Dialog layer kiểu senior',
              autogenerate: { directory: 'm21' },
            },
            {
              label: 'M22 · Lưu kết quả & lên cấp',
              autogenerate: { directory: 'm22' },
            },
            {
              label: 'M23 · Supabase & Bảng xếp hạng',
              autogenerate: { directory: 'm23' },
            },
            {
              label: 'M24 · Đăng nhập & Phiên',
              autogenerate: { directory: 'm24' },
            },
            {
              label: 'M25 · Đồng bộ hồ sơ',
              autogenerate: { directory: 'm25' },
            },
            {
              label: 'M26 · Kiến trúc DRE',
              autogenerate: { directory: 'm26' },
            },
            {
              label: 'M27 · Platform extras',
              autogenerate: { directory: 'm27' },
            },
            {
              label: 'M28 · Visual parity & motion',
              autogenerate: { directory: 'm28' },
            },
            {
              label: 'M29 · Senior alignment sweep',
              autogenerate: { directory: 'm29' },
            },
          ],
        },
      ],
    }),
  ],
});
