# M24 — Content QA (ARGUS)

Reviewer: ARGUS (independent, read-only w.r.t. fixes). Scope: five lessons +
`lessons/index.md`, `04-content-draft.md`, ledgers `01`–`03`, learner app
(source of truth), senior repo read-only @ `c8eb860` (verified
`git rev-parse HEAD`), registries under `project-context/`.

Evidence clones used (throwaway, %TEMP%):
- `m24-content-qa` — copy of shipped learner-app for the L03 DEBUG replay;
  restored byte-identical after the run (diff vs production = IDENTICAL),
  scratch test deleted.
- `m24-seq` — `m16-replay` M23-end clone carried through the L04 and L05
  file sets for the sequential-executability proof.

## Verified claims (evidence)

1. **Sequential executability — VERIFIED physically.**
   - M23-end clone (`m24-seq` baseline): `flutter test` → **193/193**.
   - L04-end reconstruction (L01–L04 file set; `MenuViewModel` keeps
     `resetProfile`/`MenuSnackBarRequested`, no `requestAuthAction`;
     `menu_screen_ui_event.dart`, ARB, `sealed_state_test` left at M23):
     `flutter analyze` → **No issues found**; `flutter test` → **219/219**.
     No dangling references; the sealed switch stays exhaustive because the
     retired variants still exist at that point.
   - L05 file set applied on top → `flutter test` → **224/224**.
   - Test-count deltas inside the files match the ledger:
     `supabase_auth_repository_test.dart` = 2 Apple (L02) + 2 session +
     4 disabled (L01) = 8; `menu_view_model_test` 11→14 at L04 (+3 auth
     stream) →15 at L05 (+3 `requestAuthAction`, −2 retired) ✓.
   - Note: the `m16-replay` clone is a reconstruction — non-M24 files
     (`menu_tokens.dart`, `game_screen_data.dart`, `user_settings_data.dart`,
     `game_dialog_layer_test.dart`, `game_screen_presentation_mapper*.dart`)
     carry cosmetic drift vs production (comments/one moved widget test).
     Test counts per file are equal (10/10, 6/6) and none of these files is
     touched by M24 content, so the milestone claims are unaffected.

2. **L03 DEBUG exercise is REAL** — `03-sync-seam-va-coordinator.md:361-437`.
   Scratch `test/m24_coordinator_guard_exercise_test.dart` (verbatim lesson
   content) green on shipped code; after planting the exact prescribed bug
   (`menu_auth_action_coordinator.dart` — replace `is!` guard + sync with
   `if (session is AuthSessionAuthenticated) { sync }`) the scratch test
   fails at `expect(result.isSuccess, isFalse)` — `Expected: false, Actual:
   true`, matching the lesson's stated answer incl. `syncCallCount == 0`.
   The cross-referenced shipped test `menu_auth_dialog_view_model_test.dart`
   `'success without session → failure "no active session" (guard)'` (test
   at :374, asserts at :393) fails identically under the bug. Restored +
   scratch deleted afterward.

3. **Command truth** — lessons use `flutter test` (×20), `flutter analyze`
   (×12), `flutter pub get`, `flutter gen-l10n` (L05 :266/:282/:346/:411 —
   correctly re-run after ARB edits), `flutter run`, `flutter build web`
   (verified in `02-implementation.md:93` "√ Built build\web"). Zero
   `dart test` occurrences. All `dart-define` examples use only
   `SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY`/`GOOGLE_WEB_CLIENT_ID`/
   `GOOGLE_IOS_CLIENT_ID` with `<your-…>` placeholders (`05:299-301`,
   `index:80-81`, `02:517-525`).

4. **Symbol truth vs learner** — every quoted learner symbol exists:
   `AuthSessionData`/`AuthSessionGuest`/`AuthSessionAuthenticated`,
   `AuthActionResult`, `AuthRepository`, `DisabledAuthRepository`,
   `AuthRepositoryImpl`, `authSessionFromAppleAuthResponse`,
   `GoogleAuthServiceImpl` (+`initialize`/`authenticate(scopeHint:)`/
   `authorizationForScopes`/`authorizeScopes` in `google_auth_service.dart`),
   `AppleAuthServiceImpl`, `UserProfileSyncRepository`/`…Disabled`,
   `ProfileSync{Idle,InProgress,Failed}`, `MenuAuthActionCoordinator`
   (incl. `_signInAndSync` guard `is! AuthSessionAuthenticated` →
   `'Sign in failed: no active session.'`), `MenuAuthDialogViewModel`/
   `MenuSignOutDialogViewModel` + their `…UiEvent`/`…DismissRequested`/
   `…SnackBarRequested` families, `MenuViewModel.requestAuthAction`,
   `MenuAuthRequested`/`MenuSignOutRequested`, `showMenuAuthDialog`,
   `showMenuSignOutDialog`, `MenuLoadingOverlay`, `_EmailAuthMode`,
   `_minimumPasswordLength`, `_sessionProfileOverride`, ARB keys
   (`menuGuestName`, `accountSemanticLabel`, `menuSyncedStatus`,
   `signOutPrompt`, `enterEmailPasswordError`, `passwordMinLengthError`,
   `passwordsDoNotMatchError`), widget key `menu-profile-pill`. No legacy
   `GoogleSignIn().signIn()` anywhere in executable code.

5. **Honesty** — `LIVE_AUTH_FLOW: NOT_PERFORMED` in `02:50`,
   `05:292` (caution boxes), `index:27/51/73`, `04-content-draft.md:10`;
   provider smoke table is optional/placeholder-only. No claim of live
   Google/Apple/Supabase auth.

6. **Security** — no real-looking secrets (`eyJ`, `AIza`, service-role,
   real supabase URLs absent); only the 4 define names + `<your-…>`;
   test literals are declared fake fixtures; client-key vs RLS boundary
   taught correctly (B-01 reinforced). Apple content is quarantined in a
   labelled APPENDIX (`02:252`, `:::note[APPENDIX]`), non-required path.

7. **Pedagogy** — auth ≠ authorization ≠ profile taught explicitly
   (`01:100`, B-06); every M25/M26 term (`upsert`, `merge`,
   `DreChangeNotifier`/`asyncOp`, `syncStateStream` consumer) appears only
   inside labelled deferrals (`03:162/458-460`, `index:67-68`, synthesis).
   Android/Compose bridge present in all five lessons; prior concepts cited
   in `Bạn đã biết gì` resolve to earlier milestones (`unawaited` → M11
   D-17, etc.).

8. **Registries** — `LEARNER_CONCEPT_REGISTRY.md` rows D-43/D-44/A-25/A-26/
   B-03..B-07 are sane and internally consistent; `PREREQUISITE_GRAPH.md`
   M24 block (:271-314) closes — every `needs` ID (D-26/27, A-05/08/11/15,
   B-01/02, D-19/40, F-13/18/25/27/31 …) resolves to a registry row;
   `SENIOR_FIDELITY_REGISTER.md` FR-11/FR-12/FR-28/FR-35 marked CONVERGED at
   M24 with matching code evidence (checked against learner files);
   FR-36 = ACTIVE_TEMPORARY → M25 with the always-Disabled `main()`
   divergence documented — matches shipped code.

9. **Checkpoint arithmetic** — `193 → 199(+6) → 201(+2) → 201(+0) →
   219(+18) → 224(+5 net)`; net +31; independently verified 193/219/224 on
   the replay clone; `index:88-90` states the same expansion.

10. **Frontmatter/links** — all six files carry valid
    title/description/sidebar(label+order 0–5) frontmatter; index `/m24/`
    links map 1:1 to lesson slugs.

## Findings (defects — content fixes required)

- **F-1 (symbol truth — senior misattribution).**
  `lessons/05-auth-ui.md:160`, "Senior project connection" table:
  `view_models/menu/menu_screen_ui_event.dart` is claimed to contain
  `MenuAuthRequested`/`MenuSignOutRequested` "verbatim" **and** that senior
  "cũng không có" `MenuSnackBarRequested`. Both halves are false @c8eb860:
  senior's file contains exactly `MenuGameRequested` +
  `MenuSnackBarRequested` (`lib/view_models/menu/menu_screen_ui_event.dart:
  5,9`), and senior routes account taps via `MenuDialogAuth`/
  `MenuDialogSignOut` **state** (`menu_screen_view_model.dart:98-102`,
  `menu_dialog_state.dart:39-53`). `MenuAuthRequested`/
  `MenuSignOutRequested` are learner-only events (the M29 transport
  divergence). The lesson itself states the correct divergence at `:96`
  ("senior đặt `MenuDialogAuth`/`MenuDialogSignOut`"), the shipped VM
  docstring (`menu_view_model.dart:165-169`) and `index:122-123` also get it
  right — the table row is an isolated but real factual error claiming
  senior symbols that do not exist.

- **F-2 (template — undeclared section folds, gate G23).**
  `04-content-draft.md:166-171` asserts "Every lesson carries the full
  Template-V2 spine" and declares only two merges; but:
  - `02-supabase-auth-impl.md` has no `## Senior project connection`
    heading — senior reading is folded into `## Đọc impl —
    AuthRepositoryImpl theo nhịp` (:164) + the Apple APPENDIX (:252).
  - `05-auth-ui.md` has no `## Hiểu code` heading — line-level walkthrough
    is folded into the build steps (:192-229 carry it).
  Both are heading-level deviations requiring declaration; semantic coverage
  exists in both cases, so severity is minor.

## Note on scope

QA verdict ≠ approval; Atlas gate remains. Fixes needed are confined to the
two content defects above — no code changes implied.

```
ARGUS_M24_CONTENT_QA: FAIL
TEMPLATE_V2: FAIL(+L02 missing 'Senior project connection' heading [folded, undeclared]; L05 missing 'Hiểu code' heading [folded, undeclared])
SYMBOL_TRUTH: FAIL(+05-auth-ui.md:160 — MenuAuthRequested/MenuSignOutRequested claimed senior-verbatim but are learner-only; senior file does contain MenuSnackBarRequested, contrary to claim)
COMMAND_TRUTH: PASS
DEBUG_BUG_REAL: YES(+physical replay: scratch test green→red 'Expected: false Actual: true'; shipped guard test menu_auth_dialog_view_model_test.dart:374/:393 also catches bug)
SEQUENTIAL_STATE_L04: COMPILES+219
CHECKPOINT_ARITHMETIC: PASS (193→219→224 verified on clone; +31 net)
HONESTY: PASS
SECURITY: CLEAN
REGISTRY_EDITS: PASS
BLOCKERS: fix 05-auth-ui.md:160 senior-connection row; declare or restore L02 'Senior project connection' + L05 'Hiểu code' sections
```

## REVERIFY

Post-remediation re-verify (senior re-read @ `c8eb860`; learner code
verified at restored state — `flutter analyze` clean, `flutter test`
224/224, see `03-implementation-qa.md` REVERIFY).

- **F-1 → RESOLVED.** `lessons/05-auth-ui.md:167` senior-connection row
  now reads: senior family = exactly `MenuGameRequested` +
  `MenuSnackBarRequested`; class + bridge case kept with **zero emit
  sites both sides**; `MenuAuthRequested`/`MenuSignOutRequested`
  labelled **learner-only transport** with senior's
  `MenuDialogAuth`/`MenuDialogSignOut` state cited
  (`menu_screen_view_model.dart:98-102`). Each clause verified verbatim
  against senior: `menu_screen_ui_event.dart:5,9` (2 variants),
  `menu_screen.dart:71` (case arm), senior grep = zero emits (settings
  uses `SettingsSnackBarRequested`, `settings_view_model.dart:218`).
  Lesson-internal narrative (:22-26, :59-65, :173-176, :197-199,
  :246-249, :363-366, :401-404, :420-423) is now uniformly
  "emit-site retire / class kept senior-true".
- **F-2 → RESOLVED.** `04-content-draft.md:166-187` declares both
  merges under gate G23: L02 `## Senior project connection` FOLDED into
  `## Đọc impl — AuthRepositoryImpl theo nhịp`; L05 `## Hiểu code`
  FOLDED into `## Build it step by step`. Structurally verified:
  L02 headings contain `Đọc impl` (:164) + `Hiểu code — hai câu hỏi hay
  hỏi` (:451) and NO `Senior project connection`; L05 has `Senior
  project connection` (:159) and NO `Hiểu code`.
- **Lesson sweep** — every `MenuSnackBarRequested` mention across L01–L05
  + `index.md` now says emit-site-retired / class-kept (index :40,
  :56-58; L04 :45-53, :265-266, :498-499; L05 throughout). No remaining
  "class deleted" claim in learner-facing content.
- **Registry edits verified consistent** — `SENIOR_FIDELITY_REGISTER.md`
  FR-12 (:36): "emit site retired (zero emit sites); class + bridge case
  kept senior-true (senior itself also has zero emit sites — channel
  contract, not dead code)". `PREREQUISITE_GRAPH.md` M24/05 (:299-300):
  "emit site `MenuSnackBarRequested` retire — class kept senior-true".
  Both match shipped code.
- **Residual (minor, non-lesson):** stale pre-restore claims remain in
  internal ledgers — `01-brief.md:65` ("`MenuSnackBarRequested` …
  REMOVED"), `01-brief.md:78-81` ("class + bridge case removed"),
  `02-implementation.md:45` ("**deleted `MenuSnackBarRequested`**"),
  `:82` ("−`MenuSnackBarRequested`"), `:126` ("deleted from sealed
  set"). Learner-facing content clean; recommend one-line ledger
  amendment noting the post-impl-QA restore.

```
ARGUS_M24_IMPL_REVERIFY: PASS — analyze CLEAN / tests 224/224 / FR-12 closure correct (emit-site retirement only; class + bridge case kept = senior parity, zero emits both sides)
ARGUS_M24_CONTENT_REVERIFY: PASS
F1_RESOLVED: YES
F2_RESOLVED: YES
NO_NEW_DEFECTS: NO — stale ledger lines (minor, non-lesson): `01-brief.md:65,78-81`, `02-implementation.md:45,82,126` still claim MenuSnackBarRequested deleted/removed
```
