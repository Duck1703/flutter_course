# M23 STATUS LEDGER — Supabase bootstrap & first remote read (leaderboard)

Milestone: **M23** | Step: 18 (long run M23→M24→M25, hard stop before M26)
Baseline: learner `168/168`, analyze clean, `build web` PASS, site 120 pages.
Senior: `main@c8eb860` clean & unchanged (read-only).

## Stage ledger

| # | Stage | Owner | State | Evidence |
|---|-------|-------|-------|----------|
| 0 | Baseline regression | Atlas | DONE | pub get OK · analyze clean · test 168/168 · build web PASS · site 120 pages · senior `main@c8eb860` clean |
| 1 | Milestone brief | Atlas | DONE | `01-brief.md` |
| 2 | Implementation | Flux | DONE | `02-implementation.md` |
| 3 | Implementation QA | Argus | PASS_WITH_FINDINGS (non-blocking) | `03-implementation-qa.md` |
| 4 | IMPLEMENTATION_APPROVED | Atlas | DONE | |
| 5 | Content authoring | Lumen | DONE | `04-content-draft.md` + `lessons/` |
| 6 | Content QA | Argus | PASS → REVERIFIED PASS | `05-content-qa.md` |
| 7 | CONTENT_APPROVED | Atlas | DONE | |
| 8 | Site handoff | Atlas | DONE | `06-site-handoff.md` |
| 9 | Website integration | Forge | DONE (126 pages) | `07-site-integration.md` |
| 10 | Website QA | Argus | PASS_WITH_FINDINGS (tally only) | `08-site-qa.md` |
| 11 | SITE_APPROVED | Atlas | DONE | |
| 12 | Sequential replay | Atlas | PASS 168→171→171→175→184→193 | `10-sequential-replay.md` |
| 13 | Final regression | Atlas | PASS (analyze · 193/193 · web · site) | |
| 14 | Post-PASS mutation check | Atlas | CLEAN | |
| 15 | Final verdict | Atlas | **MILESTONE_COMPLETE** | `11-final-verdict.md` |
| 16 | Canonical sync | Atlas | DONE | project-context/* updated |
| 17 | M23→M24 handoff | Atlas | DONE — M24_READY: YES | `12-m23-handoff-to-m24.md` |

## Live-environment ledger (authoritative)

| Check | Result |
|-------|--------|
| LIVE_SUPABASE_CONNECTIVITY | NOT_PERFORMED — no project credentials in env |
| Config source | `--dart-define=SUPABASE_URL` / `--dart-define=SUPABASE_PUBLISHABLE_KEY` (names only; values never committed) |
| Unconfigured runtime path | `DisabledLeaderboardRepository` static fallback — must work |

## Scope gates (from roadmap)

IN: env class + conditional init; leaderboard contract; disabled-static
impl; Supabase impl; dialog VM (4 states + requestId guard); dialog UI;
menu row tappable; learner SQL setup copy; deterministic fake tests.

OUT: auth (M24), writes/sync/RLS depth (M25), realtime, error taxonomy
beyond catch→error, DRE (M26), leaderboard visual parity (M28),
menu dialog layer (M29).
