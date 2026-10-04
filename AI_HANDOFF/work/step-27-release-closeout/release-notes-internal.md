# INTERNAL RELEASE NOTES — AI Millionaire Flutter Course (M01–M29)

## Scope
- 29 milestones (m01–m29), **132 learner lessons** + 29 milestone indexes, Vietnamese beginner-first.
- Learner Flutter app (`learner-app/`): full guided reconstruction of the senior AI Millionaire app — menu → state → async/streams → persistence → Provider/MVVM → events → repositories → settings/l10n/onboarding → game FSM → dialog layer → lifelines → Supabase/auth/profile sync → DRE architecture → platform → visual parity → convergence sweep.
- Website (`web/`): Astro 5 + Starlight static site, **167 pages**.

## Remediation chain (Steps 21–26A)
- Step 21: independent pedagogy + fidelity audit → `NOT_RELEASE_READY_PEDAGOGY` (4 high findings).
- Step 22: governance hardening — independent Pedagogy Reviewer role + dual same-revision review pipeline.
- Steps 23–25: band remediation — M01–M13 exercise backfill (44/44 `Tự làm`), M16–M22 targeted fixes, M23–M29 derive-first prompts + ~1,106 governance-ID tokens stripped.
- Step 26: independent full-course re-audit → `NOT_RELEASE_READY_PEDAGOGY` (1 blocker + 12 risks; caught 5 non-compiling backfilled exercise answers + sequential break at m12/02).
- Step 26A: targeted closure — all 14 plan items + 3 discovered M12 defects; ~50 broken tables repaired; Argus PASS + Pedagogy PASS_WITH_NOTES on frozen revision `3c62ec07839270` (EOL-invariant `a9ab104c665a0605`).

## Final technical baseline
`flutter analyze` clean · `flutter test` **396/396** · `flutter build web` PASS · Astro **167 pages** · `git diff --check` clean · senior repo untouched @ `c8eb860` · zero `ACTIVE_TEMPORARY` fidelity debt.

## Known non-blocking notes
m27/06 whitespace; ~14 dangling `—` table glosses; frontmatter "converge." descriptions; m29/04 "sweep" naming; pagefind windows-x64; sitemap `site:` pending deployment config. Detail: `post-release-editorial-backlog.md`.

## Deployment
No existing deployment configuration. Vercel static deploy of `web/` is the documented target; ready for manual or connected deployment.
