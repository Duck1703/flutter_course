# Step 28 · 01 — Vercel Project Inventory

## Access method + limitation

`VERCEL_TOKEN` is set in env (value not exposed). Probes:

| Probe | Result |
|---|---|
| `npx vercel` version | 62.2.0 — works |
| `GET /v9/projects` (token scope) | returns ONLY `java-spring-course` (`prj_vKMykAGa5CsL4VEJvUTcOwzJkyHo`) |
| `GET /v9/projects/prj_smy4y3CCRwMu66TTPDoZYoA7GKzc` (`flutter`) | `{"error":{"code":"not_found","message":"Project not found."}}` |
| `GET /v9/projects/prj_lcAhw4Ps0CMLYOxSsVsIJTeB5Mhy` (`flutter_course`) | same `not_found` |
| `GET /v2/teams` | `forbidden` |

**Conclusion:** the token is scoped to a different Vercel account/team than the one owning the two Flutter projects. Direct project-config inspection (root dir, git link object, build command, env) is NOT independently verifiable through this token. Findings below combine (a) human-supplied deployment metadata and (b) externally observable production behavior. No field is claimed beyond evidence.

## Comparison table

| Field | `flutter` | `flutter_course` |
|---|---|---|
| Project ID | `prj_smy4y3CCRwMu66TTPDoZYoA7GKzc` | `prj_lcAhw4Ps0CMLYOxSsVsIJTeB5Mhy` |
| Git repo | `Duck1703/flutter_course` (supplied meta) | `Duck1703/flutter_course` (supplied meta) |
| Prod branch | `main` (supplied meta) | `main` (supplied meta) |
| Latest prod deploy | `dpl_3zeC2EbsuYX1WiXCAPqgiffAXAfa` | `dpl_H83hbs5jgk8inxfAhWWnDKrRSSxZ` |
| Latest SHA | `676c448` (supplied) | `676c448` (supplied) |
| Status | READY (supplied + live 200) | READY (supplied + live 200) |
| Source type | `import` (supplied) | `git` (supplied) |
| Domains | `flutter-opal.vercel.app` → public 200 | `fluttercourse-cyan.vercel.app` → public 200; `fluttercourse-java-spring.vercel.app` → **302 → vercel.com/sso-api (SSO-protected alias)** |
| Git-linked | UNKNOWN via API — resolved empirically in 08-git-auto-deploy | see 08 |
| Root dir / framework / build cmd | UNKNOWN via API (build output shape matches `web/` + Astro by content fingerprint) | same |

## Duplication

Two projects serve byte-identical content for the same repo+branch+commit (home HTML 26918 chars identical on both public domains). This is a genuine duplicate production architecture — documented, not hidden, not deleted in Step 28.
