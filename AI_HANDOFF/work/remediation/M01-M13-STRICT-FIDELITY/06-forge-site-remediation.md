# 06 — Forge Site Integration Verification

> Role: Forge. Scope: verify the Argus-approved content remediation
> integrates into the Astro/Starlight site without structural damage.
> No new routes, no M14 pages, no sidebar restructuring.

## Build verification

```
$ npm run build   (web/)
→ astro build — 61 page(s) built in 6.23s — Complete!  exit 0
```

- **Pages:** 61 (unchanged from Step-09 baseline — no route added or lost).
- **Routes present:** `/`, `/getting-started`, `/roadmap`, `/m01`…`/m13`
  + all lesson routes; `/404.html`.
- **No `/m14` route exists** (verified: `ls dist | grep m14` → none; the
  `M14`/`m14` strings on `/roadmap/` are text mentions in the planned
  roadmap table — correct).
- **Sidebar:** Starlight autogenerate over `src/content/docs/mNN/` —
  unchanged; M01–M13 groups only.

## Known pre-existing warnings (unchanged from baseline, honest record)

- `[starlight-docs-loader] Duplicate id …` warnings — loader quirk
  present in baseline builds too; not introduced by remediation.
- `pagefind` skip — documented known caveat (no windows-x64 binary);
  site works, indexing is CI/deploy-side (`CURRENT_STATE.md` Environment).
- `@astrojs/sitemap` skip — missing `site` option, pre-existing.

## Content-in-dist spot checks

- `dist/m04/01-model-va-null-safety/` contains `0XFF` (corrected default).
- `dist/m03/01-stateless-va-stateful/` — corrected senior state-ownership
  section present (FD-01).
- `dist/m13/03-snackbar-event-va-test/` — "Scaffold đã retire" section +
  "dialog VMs" emit-site nuance live (FD-02/FD-09).
- `dist/m10/01-…` — `reset` API wording present (FD-05).

## Verdict

Site integration **PASS**: build green, routes stable, M14 not exposed,
remediated content live in dist.
