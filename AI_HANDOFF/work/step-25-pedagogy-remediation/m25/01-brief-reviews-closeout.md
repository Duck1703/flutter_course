# M25 — Step-25 Brief + Dual Review + Atlas + Closeout

CONTENT_REVISION: `b35e885204d10a75` (sha256 of m25/*.md, frozen post-edit)

## Audit (all 5 lessons)

- 01 app-user-data + schema (S): schema mapping + parse-phòng-thủ strong;
  noise only.
- 02 merge-user-profile-for-sync (S): planted-bug DEBUG — protected. Noise.
- 03 sync-repository-impl (S, F-H3 target): mental model showed the sync
  pipeline diagram before the learner could derive it. Intervention:
  DERIVE-first admonition before `## Mental model mới` — learner derives
  write order, re-entrancy guard, three stream checkpoints, upsert shape,
  merge ownership; hidden answer compares to senior's actual pipeline.
- 04 main-di-va-game-vm (A): conditional DI reuse; noise only.
- 05 sync-tests-va-tong-ket (S): FakeAsync testing strong — protected. Noise.

## Interventions

- ADD_DERIVE_FIRST: m25/03 (write order, `_isSyncing`, emit points,
  upsert field set, merge ownership).
- REMOVE_NOISE: ~129 prose ID tokens; B-01…B-08 refs stripped.
- ORTHOGRAPHY: plain-VN compounds normalized.

## Argus Technical QA — PASS

- Answer key verified vs impl: `ProfileSyncInProgress/Failed/Idle`,
  `_isSyncing` flag + `finally` release, local-save-before-remote-upsert,
  `Failed` + rethrow, `onConflict: 'auth_uuid'`, `maybeSingle` fetch —
  all match shipped code. Upsert field set referenced via Bài 1 column
  map (username→name etc.) — schema-faithful.
- Noise pass prose-only; test counts (233/233) and commands intact.

## Pedagogy Reviewer — PEDAGOGY_PASS

- F-H3 at M25: learner derives the sync pipeline before the mental-model
  reveal; the ASCII diagram now functions as evidence-check.
- P7 improved; P9 DERIVE added; P3/P5 unchanged on protected lessons.

## Atlas — APPROVED

Dual review on the frozen revision; scope = m25/** + index only.

## Closeout

- Highest exercise level: BEFORE DEBUG → AFTER DERIVE+DEBUG.
- Verdict: **COMPLETE**.
