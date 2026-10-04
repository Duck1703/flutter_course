# M20 — FORGE SITE INTEGRATION REPORT

## Intake gate

`CONTENT_APPROVED` confirmed (`06-content-approval.md`). Inputs:
5 lessons + index under `AI_HANDOFF/work/milestones/M20/lessons/`.

## Integration performed (presentation-only — no content edits)

| Target | Change |
|---|---|
| `web/src/content/docs/m20/` | 6 files copied verbatim from `lessons/` (index + 01–05) — byte-identical copies, same convention as m01–m19 |
| `web/astro.config.mjs` | sidebar group `M20 · Lifelines & nút feature` under `Phase F — Chiều sâu senior` (`autogenerate: m20`) |
| `web/src/content/docs/roadmap.md` | M20 status `PLANNED` → `AVAILABLE` |
| `web/src/content/docs/index.mdx` | "M01–M19 hoàn thiện" → "M01–M20"; "M20–M29" → "M21–M29" |
| `web/src/content/docs/state-progression.md` | appended `### Bước 11 — Lifelines: state sở hữu "quyền dùng-một-lần" (M20)` (Vấn đề/Cơ chế/Ai sở hữu/Hướng dữ liệu/Còn thiếu — matching prior steps' 5-row table) |
| `web/src/content/docs/concepts.md` | +9 rows: `Set<T>` immutable state (D-35), `firstWhere`, `{for}` map-comprehension, `List.generate`+`fromCharCode`, `fold<int>` (D-36 family), feature-gate hai lớp, `resolvedResult`, dialog một-route-hai-hình, `find.descendant`, `LinearProgressIndicator`/`AnimatedOpacity`/`Semantics` (F-28 family) — all cite real M20 lesson routes |

## Build verification

```
npm run build → astro build
  [content] Synced content — 3 duplicate-id warnings (roadmap,
  state-progression, concepts — KNOWN carryover: files exist in
  both docs collections, present since before M19)
  ✓ 108 page(s) built (102 → +6 /m20/ routes:
    /m20/, /m20/01-lifeline-la-luat-game/, /m20/02-du-lieu-va-helper-lifeline/,
    /m20/03-nam-muoi-nam-muoi-va-hoi-khan-gia/, /m20/04-hoi-ai-va-dung-cuoc-choi/,
    /m20/05-tests-regression-tu-lam/)
  pagefind windows-x64 unsupported — KNOWN carryover (search index
  skipped locally; documented in WEBSITE_ARCHITECTURE)
  sitemap `site` unset — KNOWN carryover
```

## Deviations

None. Presentation adaptation only (verbatim file copies);
no prose/code/warning changes.

## Known carryovers (named, not hidden)

- pagefind windows-x64 → search index not built locally.
- sitemap requires `site` option → skipped.
- Duplicate-id warnings for evergreen pages — pre-existing.
