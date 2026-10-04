# SENIOR EVIDENCE CONTRACT — binding for every claim about the senior app

The senior repo `flutter-accelerator-ai/` is **read-only target/evidence**,
never a blind-copy source and never a runtime-verified reference.

## Citation requirements

Every substantive senior claim must carry:

- **path** — repository-relative `lib/...` / `test/...` path
- **symbol** — class/function/getter where practical
- **what the evidence supports** — one line

Fabricated line numbers are forbidden. Line numbers are not required;
symbol-level precision is. If you didn't open the file, you don't have
evidence.

## Evidence classes

| Class | Meaning | When to use |
|-------|---------|-------------|
| `DIRECT_EVIDENCE` | Statically readable in the cited source | You opened the file and the claim is literally there |
| `INFERENCE` | Reasoned conclusion from direct evidence | Architecture-level claims, "this is why" reasoning |
| `TEACHING_SIMPLIFICATION` | Deliberately simplified for the learner | Flat reward constants instead of the money ladder, etc. Must say what was simplified and when the real version arrives |
| `UNVERIFIED` | Not determinable from available evidence | Honest fallback — never a confident guess |

Flux evidence additionally uses: `VERIFIED` (command/test output exists),
`NOT VERIFIED` (claimed but not run), `SOURCE EVIDENCE` (read in senior
source), `IMPLEMENTATION DECISION` (our choice, not senior-derived),
`DEFERRED` (named future milestone).

**Runtime claims about the senior app are impossible in this workspace.**
The senior app is never built or run here — every senior claim is static
evidence. `VERIFIED` applies only to **learner-app** commands actually run.

## What's allowed where

- **Artifacts/briefs/QA:** cite `flutter-accelerator-ai/lib/...` paths
  freely — internal evidence trail.
- **Learner-facing lessons:** senior citations appear only in "Senior
  project connection" sections as inspection pointers ("notice how…"),
  never as copy sources, and lessons must be fully understandable without
  opening the senior repo (self-contained rule, D02/D16-style
  REFERENCE-INFORMED AUTHORING).

## Contradiction rule

If senior source contradicts a canonical decision or the roadmap, do not
resolve by invention: flag it → Atlas → if material, `BLOCKED_FOR_HUMAN`.
