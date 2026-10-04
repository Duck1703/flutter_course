# M01 — WEBSITE QA (Argus, post-integration)

- `npm run build` → **PASS**: 167 pages built in ~10.5s (unchanged
  count vs baseline; no new/changed routes).
- `m01` routes present: `/m01/`, `/m01/01-flutter-dart-va-project-dau-tien/`,
  `/m01/02-main-runapp-va-cay-widget/`, `/m01/03-chay-app-hot-reload-va-tooling/`.
- Warnings observed (non-blocking, pre-existing/incremental):
  `starlight-docs-loader` duplicate-id notice on the two re-synced files
  (same file id re-registered during incremental content sync; page
  count and routes unaffected); `pagefind` windows-x64 unsupported
  (pre-existing env limitation); sitemap `site` option notice
  (pre-existing config).
- Rendered-content fidelity: approved text is the site source — no
  transform layer could alter it.

**WEBSITE_QA: PASS**
