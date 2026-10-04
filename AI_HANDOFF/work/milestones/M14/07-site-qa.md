# M14 — Site QA (Argus)

Milestone: M14 — Repository contracts & rxdart BehaviorSubject
Reviewer: Argus · Date: 2026-10-02 · Revision: r1
Under review: `web/` integration per `06-site-handoff.md`
Independence: sequential role simulation — verified against built
`dist/` output + config on disk.

## Verdict: PASS

## Verified on disk

| Check | Result |
|---|---|
| `web/src/content/docs/m14/` exists with index + 4 lessons | ✅ 5 files, names match the approved draft |
| Content fidelity | ✅ `abstract interface class` ×8 in lesson 01 build output; `BehaviorSubject` ×14 in lesson 02; retirement text (`Đang tải hồ sơ` quoted as *retired* label) in lesson 04 — matches approved drafts |
| `astro.config.mjs` sidebar entry | ✅ `M14 · Repository & BehaviorSubject`, `autogenerate: m14`, Phase D group, after M13 — rendered in built HTML sidebar |
| Roadmap page | ✅ M14 row → `status-available`; M15 row remains `status-planned` (no premature flip) |
| Routes | ✅ `/m14/`, `/m14/01…04/` all generated in `dist/` |
| Prev/next links | ✅ Starlight autogenerate ordering works; `/m14/04…` link rendered from lesson 03's page |
| `npm run build` | ✅ PASS — 66 pages (was 61; +5 M14), exit 0 |
| No m15/ directory or future-milestone routes | ✅ `dist/` has no `/m15` |
| Build caveats (pre-existing, unchanged) | duplicate-id `roadmap` warn; pagefind skip on windows-x64; sitemap `site` warn — all pre-existing, not M14-introduced |

## Not performed

Browser/visual QA — NOT_PERFORMED (no browser tooling invoked;
stated honestly per contract).

## Required for approval

None. Recommend Atlas `SITE_APPROVED`.
