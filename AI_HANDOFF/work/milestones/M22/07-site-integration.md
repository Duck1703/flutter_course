# M22 — SITE INTEGRATION (Forge)

## Actions

1. Copied 6 approved lesson files → `web/src/content/docs/m22/`
   (index + 01–05).
2. `astro.config.mjs` — sidebar entry
   `M22 · Lưu kết quả & lên cấp` → `autogenerate: m22`, after M21.
3. `roadmap.md` — M22 row status `PLANNED` → `AVAILABLE`.
4. `state-progression.md` — appended **Bước 13 — Save kết quả trong
   VM + `LevelConfig` progression (M22)**: problem/mechanism/owner/
   data-flow/remaining table; M21's own "Còn thiếu" row keeps its
   historical reference to M22 (pointing forward is correct).
5. `concepts.md` — +3 rows: Config-table progression (D-38 →
   M22/02), Derived view-model `fromProfile` (D-39 → M22/03),
   VM-side async save boundary (A-22 → M22/01+04).

## Build evidence

```
npm run build → [build] 120 page(s) built — Complete!
/m22/, /m22/01…/05 all present in output.
```

- Pagefind `windows-x64` warning + sitemap `site` warning: known
  non-fatal platform issues identical to prior milestone builds.
- Page count: 114 (post-M21) + 6 = **120**.

## Notes for QA

- M22 frontmatter `sidebar.order` = 1–5 within m22 group; index
  carries `order: 0`.
- Cross-links inside lessons use absolute `/m22/<slug>/` paths —
  verified they resolve under docs routing.
- No learner-app or senior files touched at this stage.
