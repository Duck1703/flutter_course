# Step 28 · 09 — Duplicate Project Plan

## Duplicate

`flutter_course` (`prj_lcAhw4Ps0CMLYOxSsVsIJTeB5Mhy`) duplicates `flutter`'s pipeline: same repo, same branch, same build, both auto-deploy. Its `fluttercourse-java-spring.vercel.app` alias is additionally SSO-protected (302 → vercel.com/sso-api) — unsuitable for learners and suggests the project may have been created under an account with deployment protection on.

## Why NOT deleted in Step 28

- Task forbids deletions; consolidation belongs to a later human-approved task.
- Deleting `flutter_course` removes its aliases (cyan) which are harmless but public — external links to it would die silently.

## Cleanup recommendation (deferred, human action)

`DUPLICATE_PROJECT_CLEANUP_RECOMMENDED=YES` — recommended sequence for a future step:

1. In Vercel UI, open project `flutter_course` → confirm Git connection points to `Duck1703/flutter_course` and root dir `web`.
2. Confirm no env vars/domains/integrations unique to `flutter_course` are needed.
3. Optionally delete alias `fluttercourse-java-spring.vercel.app` (SSO-walled, brand-confusing) or the whole project.
4. Delete project `flutter_course` — verify `flutter` continues deploying `main` normally.

Before deletion verify: `flutter` retains working Git integration (proven), opal alias stable (proven), no DNS/domain dependencies on flutter_course aliases.

VERCEL_PROJECT_DELETED=NO.
