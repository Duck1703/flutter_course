# Artifact 07 — Flux Technical Verification

All commands run on the production learner-app and web workspace
(not the replay clone). Learner-app source was NOT modified by this
remediation — content-only task; the verification proves it stayed
green.

| Check | Command | Result |
|---|---|---|
| Static analysis | `flutter analyze` | **PASS** — no issues |
| Unit + widget tests | `flutter test` | **PASS** — 69/69 |
| App build | `flutter build web` | **PASS** — `build/web` emitted |
| Site build | `npm run build` (web/) | **PASS** — 71 pages rendered; new routes `/concepts/`, `/state-progression/`, `m14/01`–`07` all emitted |

Site warnings (non-blocking, pre-existing):
- pagefind `windows-x64` unsupported — platform-binary limitation in
  the npx wrapper; search index skipped, site still builds.
- sitemap `site` option unset — pre-existing config gap.

Content-vs-code audits performed during writing:
- M13/03 exercise rewritten after discovering stale symbols: actual
  ctor is `MenuViewModel({required UserProfileRepository
  userProfileRepository})`, getter is `vm.events`, profile getter is
  `userData` — verified against
  `learner-app/lib/view_models/menu/menu_view_model.dart`.
- M14 lesson code checked line-by-line against real impl files
  (seeded `BehaviorSubject`, `isClosed`+equality emit guard,
  `dispose`→`close`, `MultiProvider` by-contract keys, VM `.value`
  seed + ctor subscription).
- `?element` parity claim verified against `user_profile_data.dart`.

Replay-clone verification lives in `10-sequential-replay.md`.

Learner-app diff vs pre-remediation state: **no production file
changed.** Senior source unchanged.
