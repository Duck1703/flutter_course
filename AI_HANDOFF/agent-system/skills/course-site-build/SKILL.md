---
name: course-site-build
description: Forge operating protocol — integrating CONTENT_APPROVED drafts into the Astro/Starlight course website, routes/sidebar/links, production build verification, website handoff reporting. Load when acting as Forge.
---

# course-site-build — Forge operating protocol

Identity and boundaries:
`../../agents/forge-course-website-engineer.md`.

## Follow (canonical, do not restate)

- `../../contracts/WEBSITE-HANDOFF-CONTRACT.md` — valid inputs + boundary
- `project-context/WEBSITE_ARCHITECTURE.md` — stack, routes, sidebar,
  CSS policy, build commands, known caveats
- `../../QUALITY-GATES.md` — G10 G13 G14 G15

## Operating loop

1. **Intake gate.** Require `06-site-handoff.md` + recorded
   `CONTENT_APPROVED`. Missing → refuse start; report to Atlas.
2. **Plan.** Map each approved lesson file → route; sidebar group +
   position; callout/code conventions per existing `m01`–`m12` pages.
3. **Integrate.** Create `web/src/content/docs/m{N}/` pages; update
   `astro.config.mjs` sidebar; flip `roadmap.md` status for this
   milestone only.
4. **Preserve meaning.** Presentation adaptation only — never rewrite
   code, soften warnings, or drop steps. Contradictions → Atlas.
5. **Build + verify.** `npm run build`; confirm new routes in output;
   sanity-check generated HTML for the new pages; record warnings.
   Known carryovers (pagefind windows-x64, sitemap `site` unset) are
   named, not hidden.
6. **Report.** Write the integration report for Argus: routes produced,
   deviations made (presentation only), build output, checks performed.

## Site conventions (from existing site — verify, don't assume)

- Astro + Starlight, static-first (decision D10/D12).
- Content: `web/src/content/docs/m{NN}/index.md` + numbered lessons.
- Sidebar groups live in `astro.config.mjs`.
- No deployment — local build only, ever, without human authorization.

## What Forge never does

Changes teaching meaning, code semantics, or scope; integrates
unapproved drafts; modifies `learner-app/`; self-approves.
