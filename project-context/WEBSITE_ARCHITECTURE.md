# Website Architecture

Canonical description of the course website inside this workspace. Written in
Step 03; update it when the website architecture actually changes.

## Stack

| Layer | Choice | Locked by |
|-------|--------|-----------|
| Framework | Astro 5.x (static output) | Step 03 task brief |
| Docs theme | `@astrojs/starlight` 0.34.x | Step 03 task brief |
| Content | Markdown / MDX content collection (`src/content/docs`) | Step 03 task brief |
| Styling | Starlight defaults + one `custom.css` override file | Step 03 decision D12 |
| Package manager | npm, `package-lock.json` committed | Step 03 task brief |
| Language | All learner-facing prose in **Vietnamese**; code identifiers in English | D13 |

Versions verified in this environment: Astro 5.18.2, Starlight 0.34.8,
Node v22.23.2, npm 10.9.8.

## Why this fits the course

- **Static-first**: the site must stay deployable to a static host (Vercel
  later) with zero backend. Astro outputs pure HTML at `npm run build`.
- **Docs, not an app**: Starlight supplies sidebar navigation, page anchors,
  code highlighting, dark theme, search shell, mobile layout — the course
  should not re-invent documentation infrastructure.
- **Content-as-files**: lesson progress is tracked by files in the repo, which
  keeps the project portable across agents/IDEs (D03).

## Folder structure

```
web/
  astro.config.mjs        # Starlight integration, site title/locale, sidebar
  package.json            # astro + @astrojs/starlight only; npm scripts
  tsconfig.json           # astro strict template (required by Astro tooling)
  src/
    content.config.ts     # docs collection wired to Starlight's docsSchema
    styles/custom.css     # single override file (see CSS policy below)
    content/docs/
      index.mdx           # homepage (splash template + hero actions)
      getting-started.md  # who the course is for, lesson contract, setup
      roadmap.md          # all M01–M29, AVAILABLE/PLANNED badges
      m01/                # index.md (milestone overview) + lessons 01–03
      m02/                # index.md + lessons 01–04
      m03/                # index.md + lessons 01–03
  dist/                   # build output (gitignored)
  node_modules/           # gitignored
```

## Route organization

Every file under `src/content/docs/` maps to a route by path:

- `/` — homepage (`index.mdx`)
- `/getting-started/`, `/roadmap/`
- `/mNN/` — milestone overview (`mNN/index.md`)
- `/mNN/NN-kebab-name/` — one lesson per file, `sidebar.order` controls
  in-group ordering; overview `index.md` uses `order: 0`, lessons `1..n`.

**Do not create `m04/`…`m29/` content directories.** Future milestones exist
only as PLANNED rows on the roadmap page until their step is authorized.

## Navigation / sidebar

Defined explicitly in `astro.config.mjs`:

- Group `Bắt đầu`: getting-started, roadmap (manual slugs).
- Group `Phase A — Định hướng`: `autogenerate` on `m01`, `m02`, `m03`
  directories — new lesson files appear automatically, ordered by
  `sidebar.order` frontmatter.
- Later phases get appended as new sidebar groups when their content exists.

## Component policy

- Use **Starlight-native** building blocks only: `:::note`/`:::tip`/
  `:::caution` asides, `Card`/`CardGrid` on the homepage, tables, details.
- No custom component library, no React islands, no CMS widgets.
- The recurring course blocks (Android bridge, senior evidence, checkpoint,
  common mistakes) are **heading conventions + asides**, not components —
  consistency comes from `LESSON_TEMPLATE.md`, not from a UI kit.

## CSS / customization policy

- Exactly one file: `src/styles/custom.css`, registered via
  `customCss` in `astro.config.mjs`.
- Keep it minimal: status badges for the roadmap, code font size, table
  overflow. No design system, no animations, no layout overrides.
- Visual identity comes from Starlight's theme defaults.

## Static-first rule

No database, auth, CMS, analytics, API routes, server actions, progress
accounts, or tracking. `output` stays Astro's default (static). If a future
feature needs a backend, it is a separate task with its own decision entry.

## Build commands

```bash
cd web
npm install        # first time / after package.json changes
npm run dev        # local dev server (hot reload for content)
npm run build      # production build → dist/
npm run preview    # serve dist/ locally
```

## Known environment caveats (Windows)

- `npm i` may miss Rollup's optional platform binary
  (`@rollup/rollup-win32-x64-msvc`) — npm bug npm/cli#4828. Fix:
  `npm i -D @rollup/rollup-win32-x64-msvc@<rollup version>`.
- `pagefind` (Starlight's search indexer) has no windows-x64 npm binary; the
  build logs a warning and skips indexing — the site still builds and works.
  On CI/Linux/Vercel pagefind installs normally.
- `@astrojs/sitemap` (bundled by Starlight) skips silently until `site:` is
  set in `astro.config.mjs` — intentionally absent until deployment exists.

## Deployment assumptions

- Target later: Vercel static deploy of `web/` (build command
  `npm run build`, output `dist`). Not configured yet — Step 03 is
  local-verification only, per task constraints.
- `site:` URL, analytics, and custom domain are deployment-phase decisions.

## Content extension strategy (M04–M29)

1. When milestone `mNN` is authorized, create `web/src/content/docs/mNN/`.
2. `index.md` = milestone overview (`order: 0`); lessons `01-*.md`…
   (`order: 1..n`), each following `LESSON_TEMPLATE.md`.
3. Add the `autogenerate` entry to the matching phase group in
   `astro.config.mjs` sidebar.
4. Flip the milestone's badge on `roadmap.md` from PLANNED to AVAILABLE.
5. Record the milestone row in `CONTENT_STATUS.md`.
