# M23 HANDOFF TO M24

## M23 verdict

**MILESTONE_COMPLETE** — Supabase bootstrap + leaderboard.

## Architecture landed for M24 to consume

- `SupabaseEnvironment.fromEnvironment()` — 4 dart-defines already
  parsed: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`,
  `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID`.
  `isGoogleConfigured` + `configurationError` already exist — M24
  USES them; do not re-add.
- `SupabaseClientService.initialize(env)` → `SupabaseClient?` —
  called in `main()`; the nullable client is the conditional-DI key.
- `main()` pattern established:
  `supabaseClient == null ? Disabled…Repository : Supabase…Repository`.
  M24 auth repo slots into the same conditional — extend, don't fork.
- `AppDependencyScope` — `Provider<CONTRACT>.value` convention; add
  `Provider<AuthRepository>` the same way.
- `UserProfileRepository` — present on scope; sign-out/profile-reset
  semantics (FR-11/FR-12 convergence) interact with it.
- `LeaderboardDialogViewModel` — FR-35 guest seam:
  `_currentLeaderboardUserId()` ≡ `null`. M24 injects
  `AuthRepository` into ctor, restores senior `switch(authState)`
  → uid, and `MenuLeaderboardDialogScope` passes
  `context.read<AuthRepository>()`. Do not forget the dialog scope
  call-site + tests.

## Register rows M24 owns

- **FR-11** (menu reset button scaffold → sign-out dialog coordinator).
- **FR-12** (menu snackbar emit site → dialog ViewModels).
- **FR-28** (account row/auth identity → real session).
- **FR-35** (leaderboard VM guest seam → AuthRepository injection).
- FR-30 (icon pipeline) — re-evaluate only; likely stays →M28.

## Known backend assumptions for M24

- `LIVE_SUPABASE_CONNECTIVITY: NOT_PERFORMED` — no credentials.
  M24's live-auth gate inherits NOT_PERFORMED unless a safe env appears.
- `public.users` has `auth_uuid` FK → `auth.users` + owner RLS —
  the M25 sync target already exists in the shipped SQL.
- `google_sign_in` NOT yet in pubspec — senior pins `^7.2.0`
  (`GoogleSignIn.instance.initialize` + `authenticate()`, not legacy
  `signIn()`); verify package age at add time.
- Apple auth exists senior-side but roadmap defers it to appendix —
  do not build it in the core path.

## M24 prerequisites (from roadmap)

- M15 sealed-state conventions (session sealed family).
- M23 Supabase client + conditional DI (landed, verified).
- `AuthSessionData` sealed guest/authenticated model (new in M24).
- `google_sign_in` v7 API surface (new in M24).

## Post-PASS state

- `POST_PASS_MUTATION_CHECK: CLEAN`
- Senior `main@c8eb860` unchanged, 0 porcelain.
- Learner: analyze clean, 193/193, build web PASS.
- Site: 126 pages, M23 AVAILABLE, M24+ PLANNED.

## M24_READY: **YES**
