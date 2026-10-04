# WEBSITE HANDOFF — M13: One-shot UI events from the VM

> Produced by: Atlas — from the `CONTENT_APPROVED` draft
> Recipient: Forge (`forge-course-website-engineer`)
> Contract: `../../contracts/WEBSITE-HANDOFF-CONTRACT.md`
> Content source of truth: `lessons/*.md` r2 (CONTENT_APPROVED)

## 1. Routes

| Route | Source file | Title |
|-------|-------------|-------|
| `/m13/` | `lessons/index.md` | M13 — Event một-lần từ ViewModel |
| `/m13/01-event-khong-phai-state/` | `lessons/01-event-khong-phai-state.md` | Bài 1 · Event ≠ state |
| `/m13/02-event-bridge-trong-state/` | `lessons/02-event-bridge-trong-state.md` | Bài 2 · Event bridge trong State |
| `/m13/03-snackbar-event-va-test/` | `lessons/03-snackbar-event-va-test.md` | Bài 3 · SnackBar event & test |

## 2. Sidebar placement

- `astro.config.mjs` group: "Phase D — Kiến trúc state"
- Position within group: after `M12 · Provider & scope` (last item)
- New group needed? NO — M13 belongs to Phase D per roadmap phase table

## 3. Page order

1. `index.md` (overview, `sidebar.order: 0`)
2. `01-event-khong-phai-state.md` (`order: 1`)
3. `02-event-bridge-trong-state.md` (`order: 2`)
4. `03-snackbar-event-va-test.md` (`order: 3`)

Order is carried by frontmatter `sidebar.order` — matches M12 pages.

## 4. Callout semantics

| Draft marker | Site component |
|--------------|----------------|
| (none used — draft uses plain markdown + code blocks + tables) | n/a |

## 5. Code block requirements

- Language: `dart` for all code fences; `text` for command output
- Filename-in-comment convention: yes — `// lib/...` header comments
  inside snippets, matching M10–M12 pages
- `// …`/`// ...` elision marks inside snippets must survive verbatim

## 6. Previous/next links

M12 lesson 3 → M13 index → M13 L1 → L2 → L3 (terminal in Phase D).
Starlight prev/next follows sidebar order; no manual links needed
beyond autogeneration.

## 7. Roadmap status update

`web/src/content/docs/roadmap.md`: M13 PLANNED → AVAILABLE
(only this milestone; M14 stays PLANNED).

## 8. Assets

None.

## 9. Explicit non-goals for Forge

- No rewriting of teaching content
- No scope changes
- Presentation adaptation only per contract

## 10. Next step

```text
NEXT STEP (INTERNAL)
  Who: Forge
  Input: this handoff + STATE: CONTENT_APPROVED
  Output: web/** changes + integration report for Argus
```

---

## FORGE INTEGRATION REPORT — M13

> Producer: Forge (`forge-course-website-engineer`)
> Input honoured: `CONTENT_APPROVED` draft r2 only; no content edits.

### Actions taken

1. Created `web/src/content/docs/m13/` with the four approved files
   copied verbatim (`index.md`, `01-…`, `02-…`, `03-…`).
2. `astro.config.mjs`: added
   `{ label: 'M13 · Event một-lần từ VM', autogenerate: { directory: 'm13' } }`
   as the last item of "Phase D — Kiến trúc state", after M12.
3. `web/src/content/docs/roadmap.md`: M13 status
   `status-planned` → `status-available` (PLANNED → AVAILABLE).
   M14+ rows untouched.
4. No other web files changed; M01–M12 content untouched.

### Verification

```text
$ npm run build → Complete. 61 page(s) built in 6.36s.   [VERIFIED]
  Routes confirmed in output:
    /m13/index.html
    /m13/01-event-khong-phai-state/index.html
    /m13/02-event-bridge-trong-state/index.html
    /m13/03-snackbar-event-va-test/index.html
  Warnings (pre-existing, non-blocking):
    - Pagefind windows-x64 binary not installable (known Step-06 note)
    - @astrojs/sitemap skipped: `site` option unset (pre-existing)
```

### Honesty notes

- Content fidelity: files copied byte-for-byte from approved drafts;
  Forge did not edit any teaching text or code.
- Visual/browser QA: not performed by Forge (build-time verification
  only) — left for Argus to state independently.
