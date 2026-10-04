# STEP 26 — PHASE B · TECHNICAL VALIDATION (frozen post-Phase-A)

Argus-style technical audit. Does NOT inherit prior remediation PASS
verdicts — claims were re-verified against the current learner-app source,
the Flutter SDK, and the senior reference where relevant.

## Executed commands (actual outputs)

| Check | Command | Result |
|-------|---------|--------|
| Analyze | `flutter analyze` (learner-app/) | **PASS** — "No issues found! (ran in 4.7s)" |
| Tests | `flutter test` (learner-app/) | **PASS — 396/396** ("All tests passed!") |
| Web build | `flutter build web` (learner-app/) | **PASS** — "√ Built build\web" (69.4s; font tree-shake 99.4% reduction, wasm-dry-run hint — both non-blocking) |
| Site build | `npm run build` (web/) | **PASS — 167 page(s) built in 8.64s** — pagefind npx-wrapper failure on windows-x64 (pre-existing platform limitation, same as Step-25); sitemap WARN (no `site` option — pre-existing) |
| Whitespace | `git diff --check` | clean |
| Frontmatter | all 132 lessons + 29 indexes | **PASS** — valid YAML, `title:` present |
| Fence balance | all m01–m29 lesson files | **PASS** — zero unbalanced code fences |
| Routes/sidebar | Astro build output | all m01–m29 routes render; no unexpected routes; no milestone splits |

## Source integrity

| Item | State |
|------|-------|
| AUDITED_COMMIT | `9323e57` on `remediation/step25-m23-m29-derive-first`; worktree clean at audit start and throughout |
| COURSE_CONTENT_REVISION | `48f8f30f9cc62a22` — unchanged during audit (verified at Phase-A freeze) |
| learner-app/ | no source changes during audit (test/build artifacts only) |
| senior repo | `c8eb860ed9f4dbcda176c8282a9feb4d2d70d1d3`, `git status` clean — read-only |
| governance/agent-system | untouched |

## Answer-key spot validation (remediation-introduced teaching)

| Claim checked | Result |
|---------------|--------|
| m23/02 key: `Future<SupabaseClient?> initialize(SupabaseEnvironment)` + `null` sentinel | **VERIFIED** — `learner-app/lib/services/supabase_client_service.dart:16` matches exactly |
| m23/02 key: `Disabled vs Supabase` repo branch in `main()` | VERIFIED via learner-app `main.dart` DI structure |
| m25/03 key: `username ↔ 'name'` column | **VERIFIED** — `app_user_data.dart:38` `displayName: _stringValue(map['name'],…)`; `'name': displayName` in toUpsertMap. The corrected key is accurate (NOT `display_name`) |
| m26/03 contract inventory variant names | **VERIFIED** — `game_dre_action.dart` contains `GameStarted`, `GameAnswerSubmitted`, `GameWalkAwayConfirmed` (sealed family real) |
| m29/05 `MenuDialogState` 5-variant sealed family | **VERIFIED** — `menu_dialog_state.dart`: sealed base + `MenuDialogNone/Leaderboard/Settings/Auth/SignOut` final classes |
| m28/06 atomic-swap `icon→iconAsset` | consistent with learner-app DTO fields |
| m20/02 helpers (`firstWhere`/`fold`/`Map.unmodifiable`) | consistent with learner-app lifeline helpers |

## High-risk technical claims audited

- `didChangeDependencies` timing — m13/02's "sau frame build đầu" is technically wrong (hook runs before first build); recorded as F26-F-02, not a blocker since practical guidance is correct.
- `ConstrainedBox`/`BoxDecoration`/`BorderRadius.circular` const rules — verified against `flutter/packages/flutter` sources: m02/02's conclusion correct/reasoning wrong; m02/03's color+gradient assert claim FALSE (no such assert); `BorderRadius.circular` genuinely non-const (prior agent claim refuted).
- `abstract interface class` claims in m14/02 — two technically false statements confirmed (member bodies/ctors allowed; `extends` legal within declaring library).
- `reset()` semantics — m10/04's own body is technically correct (writes defaults, senior-parity); the exercise answer contradicts it.
- DRE architecture descriptions — consistent with learner-app `dre/` implementation; no invented mechanism found.
- `NOT_PERFORMED` claims — all honest; no live-backend/live-device claim anywhere it wasn't performed.

## Phase B verdict

**TECHNICAL_STATUS: PASS_WITH_NOTES**

The implementation baseline (396/396, clean analyze, web build, 167-page site) is verified first-hand. Technical falsity exists ONLY inside lesson text/answer keys (F26-R-05/07/09/10/11, F26-F-01/02/35) — all are content defects for targeted remediation, none indicates corrupted course infrastructure or altered senior truth. Remediation did not change learner-app behavior or senior content.

Senior fidelity: **PASS** (spot-checked mechanisms match; course's own senior-fidelity record is consistent with sampled evidence).

Phase-B artifact hash recorded in master report.
