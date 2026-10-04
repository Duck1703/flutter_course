# WEBSITE HANDOFF CONTRACT — Atlas → Forge

Forge receives **only** `CONTENT_APPROVED` material. The handoff artifact
is `AI_HANDOFF/work/milestones/M{N}/06-site-handoff.md`, produced by Atlas
from the approved draft (template: `templates/website-handoff-template.md`).

## The handoff must specify

1. **Routes** — every URL slug to create/update (`/m13/`, `/m13/01-…/`).
2. **Titles** — page titles + milestone group label.
3. **Sidebar placement** — exact `astro.config.mjs` group + position
   within it.
4. **Page order** — lesson sequence (index first, then numbered).
5. **Callout semantics** — which draft callout types map to which site
   component (note/tip/caution/danger per Starlight conventions).
6. **Code block requirements** — language tags, filenames-as-comments
   policy, diff-style marking rules (add/replace annotations must survive
   integration).
7. **Previous/next links** — ordering chain; phase-boundary transitions.
8. **Content source** — authoritative pointer to `lessons/*.md` files
   (approved revision).
9. **Learner checkpoints** — any milestone-overview status updates
   (`roadmap.md` PLANNED → AVAILABLE).
10. **Assets** — images/files to add, or explicit "none".

## Forge's boundary

- Forge may adjust **presentation**: heading levels, callout formatting,
  layout wrappers, responsive formatting, code-block framing.
- Forge may not change **meaning**: scope, code semantics, technical
  conclusions, exercise answers, warning severity.
- A content contradiction or error found during integration → Forge stops
  that page, reports to Atlas, continues other pages only if unaffected.
  Forge never rewrites learning content.
- `web/src/content/docs/roadmap.md` status flips happen inside this stage
  and only for the milestone actually being delivered.
