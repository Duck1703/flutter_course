# Step 28 · 04 — Production Route Smoke

Real-browser smoke: headless Chrome 143 via puppeteer-core, desktop viewport 1440×900, `networkidle0`.

| Route | Milestone | HTTP | content chars | `<pre>` code blocks | sidebar | h1 | broken imgs | h-scroll |
|---|---|---|---|---|---|---|---|---|
| `/` | home | 200 | 1449 | 0 | n/a (splash layout, links → /m01/) | "AI Millionaire — Khoá học Flutter" | 0 | no |
| `/m01/01-flutter-dart-va-project-dau-tien/` | M01 | 200 | 8540 | 5 | yes | "Bài 1 · Flutter, Dart và project đầu tiên" | 0 | no |
| `/m12/02-read-vs-watch/` | M12 | 200 | 10151 | 4 | yes | "Bài 2 · read vs watch" | 0 | no |
| `/m21/02-game-dialog-layer/` | M21 | 200 | 28428 | 10 | yes | "Bài 2 · GameDialogLayer — skeleton & backdrop" | 0 | no |
| `/m26/04-game-reducer/` | M26 | 200 | 21578 | 12 | yes | "Bài 4 · GameReducer — bảng transition thuần" | 0 | no |
| `/m29/07-hoi-tu-quet-cuoi/` | M29 | 200 | 26346 | 16 | yes | "Bài 07 — Hội tụ & quét cuối" | 0 | no |

Additional direct probes (curl): `/m01/` index 200, `/m29/` index 200, `/roadmap/` 200, `/concepts/` 200, `/state-progression/` 200.

All sampled pages: Vietnamese content rendered, Starlight CSS applied, sidebar navigation present, code blocks present and styled, no horizontal overflow, no broken images.

Verdict: HOME/M01/M12/M21/M26/M29/NAVIGATION_SMOKE = PASS.
