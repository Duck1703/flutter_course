# M24 — Step-25 Brief + Dual Review + Atlas + Closeout

CONTENT_REVISION: `fcc253145a1b9591` (sha256 of m24/*.md, frozen post-edit)

## Audit (all 5 lessons)

- 01 session-model (S): sealed `AuthSessionData` taught as the NEW concept —
  variants are the teaching payload, not an answer leak. Protected. Noise only.
- 02 supabase-auth-impl (S, F-H3 target): 317-line impl dissected well ("Đọc
  impl theo nhịp" 5 clusters) but learner had no chance to derive the repo's
  responsibilities/API/variants/SDK-boundary before the walkthrough. Intervention:
  DERIVE-first admonition before `## Đọc impl` — API surface, session-variant
  matrix, SDK-vs-abstraction line, two emission sources, throw-vs-return criteria;
  hidden answer compares to senior's actual five clusters.
- 03 sync-seam-coordinator (S): coordinator reasoning strong — protected. Noise.
- 04 dialog-vms-menu (A): noise only.
- 05 auth-ui (A): noise only.

## Interventions

- ADD_DERIVE_FIRST: m24/02 (API surface, variant matrix, SDK boundary,
  emission sources, error taxonomy).
- REMOVE_NOISE: ~143 prose ID tokens across m24; B-01…B-08 registry refs
  stripped from learner prose; descriptions normalized.
- ORTHOGRAPHY: plain-VN compounds de-hyphenated; tech coinages preserved.

## Argus Technical QA — PASS

- Derive answer key verified: `SupabaseAuthRepository` real API surface
  (`authStateChanges` stream, `currentSession` getter, `signInWithEmail/
  Google/Apple`, `signOut`, `Future<AuthActionResult>`), seeded
  `BehaviorSubject` + `onAuthStateChange` listener, guest-as-safe-default
  emit on listener error — all match learner/senior code.
- google_sign_in two-leg flow (idToken → Supabase verify) matches impl.
- Noise pass touched prose only; test counts, code spans, paths intact.

## Pedagogy Reviewer — PEDAGOGY_PASS

- F-H3 at M24: learner now produces repo contract skeleton unaided before
  the 317-line reveal; "plumbing = mechanical port" framing explicit.
- P7 improved; P9 DERIVE added; P11 noise cleared; P3/P5 unchanged —
  protected sealed-model lesson intact.

## Atlas — APPROVED

Dual review on `fcc253145a1b9591`; scope = m24/** + index only.

## Closeout

- Highest exercise level: BEFORE DEBUG → AFTER DERIVE+DEBUG.
- Verdict: **COMPLETE**.
