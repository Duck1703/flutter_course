# M01 — FORGE INTEGRATION (Step-23)

Approved revision integrated **in place** — Step-23 edits land directly
in `web/src/content/docs/m01/` (the site's content source), so
integration = verify approved content is what shipped to the site
source with zero Forge prose changes.

- Frontmatter intact on both edited files (`title`, `description`,
  `sidebar.label`, `sidebar.order` unchanged — verified by grep).
- No route/sidebar/index changes; `index.md` untouched.
- No links added/removed; internal link `](/m02/)` in m01/03 unchanged.
- Approved content == site content (same files, same blob SHAs).
