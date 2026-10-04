# WEBSITE HANDOFF — M{N}: ⟨name⟩

> Produced by: Atlas — from the `CONTENT_APPROVED` draft
> Recipient: Forge (`forge-course-website-engineer`)
> Contract: `../../contracts/WEBSITE-HANDOFF-CONTRACT.md`
> Content source of truth: `lessons/*.md` ⟨approved revision⟩

## 1. Routes

| Route | Source file | Title |
|-------|-------------|-------|
| `/m{N}/` | `lessons/index.md` | ⟨title⟩ |
| `/m{N}/01-⟨slug⟩/` | `lessons/01-⟨slug⟩.md` | ⟨title⟩ |

## 2. Sidebar placement

- `astro.config.mjs` group: ⟨e.g. "Phase D — …"⟩
- Position within group: ⟨order⟩
- New group needed? ⟨YES/NO — label if yes⟩

## 3. Page order

⟨ordered list; index first⟩

## 4. Callout semantics

| Draft marker | Site component |
|--------------|----------------|
| ⟨:::note/:::tip/caution/danger mapping⟩ | ⟨Starlight aside type⟩ |

## 5. Code block requirements

- Language: `dart` unless stated
- Filename-in-comment convention: ⟨yes/no — follow existing pages⟩
- Add/replace annotations must survive integration verbatim

## 6. Previous/next links

⟨chain; include phase-boundary notes⟩

## 7. Roadmap status update

`web/src/content/docs/roadmap.md`: M{N} PLANNED → AVAILABLE
(only this milestone).

## 8. Assets

⟨list, or "none"⟩

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
