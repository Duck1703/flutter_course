# 00 — Audit Charter (Atlas)

**Audit:** M01–M13 Strict Senior-Fidelity Audit
**Date:** 2026-10-05 (post-M13 production run)
**Initiated by:** THE HUMAN / supervising ChatGPT
**Mode:** READ-ONLY. No remediation, no M14, no changes to `learner-app/**`,
`web/**`, or the senior repository.

## 1. Audit requirement

> The teaching website must track the senior Flutter source 1:1 in technical
> truth and project direction. Do not invent or creatively change product
> behavior, architecture intent, feature semantics, data flow, or target
> implementation. Beginner-friendly explanation is allowed; technical
> reinterpretation is not.

Central question:

> Does the course built from M01 through M13 still teach the same application
> represented by the senior Flutter source?

"1:1" means **senior product truth + architecture destination + feature
semantics + data flow + state responsibilities + final behavior** remain the
canonical destination — not byte-for-byte code identity at M01.

## 2. Scope

- All 13 completed milestones M01–M13.
- All learner-app source files authored/modified through M13
  (15 `lib/` files + 9 `test/` files).
- All 44 published lesson files + 13 milestone index pages on the website.
- Roadmap M14–M29 audited **only** for convergence mapping of M01–M13
  simplifications.

## 3. Repositories & baselines

| Repo | Path | Baseline |
|---|---|---|
| Senior (READ-ONLY) | `D:\vibe_coding\flutter\flutter-accelerator-ai` | branch `main`, HEAD `c8eb860`, `git status` clean |
| Course workspace | `D:\vibe_coding\flutter\flutter-course-accelerator-ai` | **not a git repository** — integrity enforced by write-scope discipline; learner/web files untouched |
| Learner app | `learner-app/` | `flutter analyze` clean; `flutter test` 57/57 PASS; `flutter build web` PASS |
| Website | `web/` | `npm run build` PASS — 61 pages; known Pagefind (windows-x64 unsupported) + sitemap `site` warnings, unchanged |

## 4. Audit dimensions (F1–F15)

F1 product behavior · F2 feature semantics · F3 architecture direction ·
F4 state ownership · F5 data flow · F6 navigation · F7 persistence ·
F8 models · F9 async/stream · F10 UI events (M13 deep) · F11 code-snippet ·
F12 teaching claims · F13 simplification honesty · F14 convergence guarantee ·
F15 course-only invention.

## 5. Classification vocabulary

`MATCH` · `TEMPORARY_VALID_SIMPLIFICATION` (all five honesty criteria met:
senior identified, labelled temporary, difference explained, convergence
milestone mapped, no contradictory mental model) · `UNJUSTIFIED_DEVIATION` ·
`INVENTED_BEHAVIOR` · `MISSING_SENIOR_BEHAVIOR` · `MISLEADING_TEACHING` ·
`PREMATURE_DIVERGENCE` · `UNVERIFIED`.

## 6. Severity vocabulary

- **CRITICAL** — course teaches a different product/architecture direction.
- **HIGH** — meaningful senior behavior/data flow wrong or invented.
- **MEDIUM** — simplification insufficiently labelled/mapped; teaching claim
  that shapes a wrong mental model.
- **LOW** — naming/presentation/detail discrepancy, no mental-model damage.
- **INFO** — correct deliberate difference.

## 7. Role assignment

| Role | Audit duty | Artifact(s) |
|---|---|---|
| Atlas (audit lead) | charter, scope freeze, milestone matrix, convergence audit, verdict, remediation ordering | 00, 05 (w/ Flux), 06 (w/ Flux), 07, 10, 11 |
| Flux | senior↔learner source comparison, traceability map | 01, 02, 03 |
| Lumen | lesson↔code↔senior fidelity, danger-phrase + analogy audit | 04, 08 (w/ Forge) |
| Forge | website coverage/structure audit | part of 08 |
| Argus | independent verification & challenge of all findings | 09 |

Single-agent honesty (D21): roles are simulated by stage boundaries,
independent on-disk artifacts, and fresh re-reads of real source. This is
stated, not hidden.

## 8. Pass/remediation/fail criteria

- `STRICT_FIDELITY_PASS`: zero CRITICAL/HIGH; every simplification labelled +
  convergent; no surviving invented product behavior; full mapping coverage.
- `PASS_WITH_REMEDIATION`: no CRITICAL; findings exist but direction is
  faithful and every gap is fixable by remediation tasks.
- `FAIL_MAJOR_DIVERGENCE`: the course is headed toward a different product.
- `BLOCKED_INSUFFICIENT_EVIDENCE`: cannot verify.

## 9. Evidence standard

Every conclusion cites an on-disk path (+ symbol/line where useful) in the
senior repo, learner repo, or website. Prior PASS verdicts are **not**
accepted as fidelity proof. UNVERIFIED never counts as PASS.
