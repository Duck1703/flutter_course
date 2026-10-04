# CONTENT QA — Step 29: per-lesson AI Local project-alignment review layer

> Reviewer: Argus (`argus-course-qa-reviewer`) — independent, technical
> surface only. I did not author this artifact and have not modified it.
> Artifact under review: trailing `## 🤖 AI Local — Kiểm tra project sau
> bài này` section appended to all 132 lesson pages
> `web/src/content/docs/m*/0*.md`, plus supporting artifacts in
> `AI_HANDOFF/work/step-29-ai-local-review/`.
> Verdict: **PASS**

## Intake gate

| Required input | Present? |
|---|---|
| Artifact under review (132 modified lesson pages + step-29 work area) | Y — verified on disk |
| Design contract `02-classification-rules.md` (acts as scope/brief) | Y |
| `registry.json` / `registry.md` (132 lessons, type + checkpoint per lesson) | Y |
| `inventory.json`, `00-precheck.md`, `01-lesson-inventory.md` | Y |
| Section sources `sections/mNN/*.md` (132 files) | Y |
| Real files on disk (lesson pages, learner project, repo state) | Y |
| Mechanical validators `validate_sections.py`, `audit_sections.py` | Y — ran read-only |

## Environment / revision evidence

- `git rev-parse HEAD` → `9cfc544391849ca66997d0ee71ae71426118e95f` (matches required `9cfc544`).
- Working tree: 133 `git status --short` entries = 132 modified `web/src/content/docs/m*/0*.md` + untracked `AI_HANDOFF/work/step-29-ai-local-review/`. **Zero** index pages modified, **zero** `learner-app/` changes, **zero** other paths.
- `git diff --stat`: 132 files changed, **5187 insertions(+), 0 deletions** — pure appends. Spot-checked `git diff web/src/content/docs/m10/04-ap-ket-qua-va-reset.md`: hunk is append-at-EOF only.
- `git grep -l "🤖 AI Local" HEAD -- web/src/content/docs` → 0: no pre-existing sections; clean append as `01-lesson-inventory.md` claims.
- `CONTENT_REVISION` fingerprint: mandated `c8a1d5f8461b3c02` (see NON_BLOCKING N1 — method could not be reproduced; my independent recomputation recorded for the staleness tripwire).

## Checks performed (independent of the artifact's own validators)

| # | Check | Method | Result |
|---|-------|--------|--------|
| 1 | Coverage / exactly-once | Own script: counted `## 🤖 AI Local` per file over all 132 lessons; checked all 29 `index.md` | 132/132 exactly one; 0 missing; 0 duplicates; 0 index pages have it. Section is the last h2 and last content block in every file. PASS |
| 2 | Contract conformance | Own script over all 132: role line `Bạn là Project Alignment Reviewer`, `KHÔNG SỬA`, `BLOCKED_PROJECT_ROOT`, `PHẠM VI` scope rule, `EXPECTED STATE`, `INVARIANTS`, classification vocab (`AHEAD`/`DIVERGED`), fixed OUTPUT keys (`PROJECT_ALIGNMENT:`, `COURSE_POSITION:`, `READY_FOR_NEXT_LESSON:`, `EVIDENCE:`), tail `FILES_MODIFIED_BY_REVIEW: NONE`, `LESSON:` == page id, exactly one ```text fence | 0 problems across 119 REVIEW prompts. 13 NO_REVIEW pages: no prompt, no ```text fence, honest reason present. PASS |
| 3 | Checkpoint coherence | Full sweep (not just 15): extracted `**N/N**` from every prompt vs `registry.json checkpoint_tests`; monotonicity within milestones | 62 checkpointed prompts — all match registry, 0 mismatches. Non-decreasing within every milestone except two **documented retirements**: m18/05→m19/02 (102→95, prompt states "Suite đi từ 102 → 95 vì test cũ bị xóa + test mới thay"; STRICT "không phải 102/126") and m22/03→m22/04 (169→168, prompt states "168/168 = 169 −9 scaffold +8 persistence… số GIẢM từ 169 là đúng"). Pre-m17/05 REVIEW prompts have no `**N/N**` (intentional). PASS |
| 4 | Future-leakage | Own landmark scan (independent list): positive (non-negated) mentions of later-milestone symbols inside `EXPECTED STATE` regions | m01–m15: 5 hits, all symbols introduced at/before that milestone (e.g. `ChangeNotifier`@m11/01, `BehaviorSubject`@m14/05) — legitimate. m16–m28: 0 hits. Exclusions consistently phrased `KHÔNG`/`chưa`/`AHEAD` (e.g. m12/03 "KHÔNG có `MultiProvider` bắt buộc"; m05/03 "chưa có Navigator/repository/Provider… đều bài sau, không thiếu"; m19/02 "không `GameShareResultEvent` M27"). PASS |
| 5 | Self-containment | Grepped all segments for external/governance references (`AI_HANDOFF`, `registry`, `step-29`, `Argus`, `Atlas`, `APPROVED`, `CONTENT_REVISION`, `MILESTONE_GATE`, `Pedagogy`, `Lumen`); checked lesson-id cross-refs | 0 hits. Prompts name concrete `lib/`/`test/` paths, signatures, test names. Only cross-lesson ref: m12/02 → `m12/01` (backward pointer "dùng prompt của bài m12/01" — legitimate). PASS |
| 6 | Mechanical validators | `python …/validate_sections.py` → `files=132 failures=0`; `audit_sections.py` → `audited=132 findings=0` | Both clean — corroborated by independent checks 1–5 (not taken as sole evidence). PASS |
| 7 | Stray diffs / firewalls | `git status --short`, `git diff --stat`, `git status learner-app`, `git grep` at HEAD | Only expected files. 0 pre-existing sections at HEAD. `learner-app/` untouched. `lessons/` (root) contains only empty `m27/` — untouched. PASS |
| 8 | Site health | `cd web && npm run build` | Completes: `167 page(s) built in 8.23s`, Pagefind indexed 166 pages, sitemap created. No errors; only pre-existing informational notes (docs→404 entry note; git LF→CRLF checkout warnings are environment noise). PASS |
| 9 | Section-source fidelity | Per-file compare applied segment vs `sections/mNN/*.md` | 132/132 byte-identical (also: sha256 of concatenated applied segments == sha256 of concatenated section sources = `b172f06f37d1f759`). PASS |
| 10 | Placeholders / solution leaks | Own grep for `TODO`, `FIXME`, `XXX`, `<ĐIỀN`, `PLACEHOLDER`, `{{`, `}}`, `<details>`, `<summary>`, `answer:</`, `Solution:` in segments | `TODO` hit in m26/06 is inside quoted honesty-check text (`"TODO migrate"` — an instruction to verify no stale TODO remains), not a placeholder. `ĐÁP ÁN` hits in m08/03+m08/04 are quiz UI terminology (`CHỐT ĐÁP ÁN` button label, `đáp án sai` color), not leaked solutions. PASS |

## Eyeball spot-checks (beyond scripts)

Read in full: `m01/01` (DELTA), `m05/03` (MILESTONE_GATE), `m10/04` (MILESTONE_GATE), `m12/03` (MILESTONE_GATE), `m17/05` (INTEGRATION), `m19/02` (DELTA), `m22/04` (INTEGRATION), `m29/07` (final MILESTONE_GATE); NO_REVIEW pages `m12/02`, `m14/01`, `m21/01`, `m22/01`. All are checkpoint-scoped (not final-app), read-only, self-contained, and demand only at-checkpoint state. m29/07 correctly handles course-end cumulative state including declared gaps ("6-catalog-thiếu = DECLARED-GAP KHÔNG-phải-defect").

## Findings

Zero blocking findings. Non-blocking notes:

```text
ID:        QA-S29-001
Severity:  NON_BLOCKING
Artifact:  dispatch fingerprint (this review header), not the artifact
Evidence:  Recomputed sha256-16 over the 132 lesson files by 12+
           plausible methods; none yields `c8a1d5f8461b3c02`. My values:
           sha256-16 concat worktree-bytes (files already LF on disk;
           LF-normalized identical) = `2f77c9d030128d81`;
           CRLF-normalized = `001b24e710b8dd40`; sorted-list of
           `git hash-object` hexdigests = `db7200b75cadd2bb`;
           concat applied-sections only = `b172f06f37d1f759`;
           canonical-contract method (sha1, PEDAGOGY-REVIEW-CONTRACT §2)
           = `c32f63aa55bcebb2`.
Why it fails: nothing — the mandated value may use a method I cannot
           infer (different file set/separator/pipeline). Recorded so the
           fingerprint remains a usable staleness tripwire: any post-review
           edit changes ALL deterministic fingerprints.
Owner:     Atlas/orchestrator — document the fingerprint method if the
           value must be independently reproduced.
Required fix: none for PASS; method documentation recommended.
```

```text
ID:        QA-S29-002
Severity:  NON_BLOCKING
Artifact:  02-classification-rules.md vs applied NO_REVIEW sections
Evidence:  Doc prescribes literal marker `**Không cần review project ở
           bài này.**` + "No fence". Reality: only m12/02 uses the literal
           marker; the other 12 use `Bài này **không thay đổi project** —
           thuần …` / `không cần AI kiểm tra` phrasing (honest reasons,
           verified). m21/01 and m22/01 additionally contain ```bash
           fences with `flutter analyze`/`flutter test` baseline
           self-checks — learner-run commands, NOT ```text prompt fences.
Why it fails: it doesn't — dispatch contract says "concise honest
           reason, no prompt fence"; a bash self-check fence is not a
           prompt fence, and the artifact's own validator flags only
           ```text fences for NO_REVIEW. Doc-vs-implementation wording
           drift only.
Owner:     Lumen (doc sync optional).
Required fix: none for PASS; optionally relax the doc wording to
           "no prompt fence" to match.
```

```text
ID:        QA-S29-003
Severity:  NON_BLOCKING (pedagogy-route note, not a technical defect)
Artifact:  web/src/content/docs/m22/01-ket-qua-la-ghi-db.md §AI Local
Evidence:  NO_REVIEW note contains an inline self-check whose answer is
           revealed in-place: "…`saveCallCount` là mấy? — đáp án: **1**".
           Audit script classifies self-contained Q&A in no-review notes
           as non-violation; no lesson `<details>` answer block is copied
           into any AI Local segment (verified: 0 `<details>`/`<summary>`
           in all 132 segments; 124 lesson bodies do contain them).
Why it fails: it doesn't fail a technical gate — flagged for the
           companion reviewer's consideration only.
Owner:     Pedagogy Reviewer (informational) / Lumen.
Required fix: none for technical PASS.
```

## Verdict rationale

All eight required verification areas pass against disk evidence, not claims: every one of the 132 lesson pages carries exactly one trailing `## 🤖 AI Local` section (0 missing/0 duplicate/0 on index pages); all 119 REVIEW prompts satisfy the full contract (read-only `KHÔNG SỬA`, `BLOCKED_PROJECT_ROOT`, scope rule, EXPECTED STATE, INVARIANTS, classification rule, fixed OUTPUT tail `FILES_MODIFIED_BY_REVIEW: NONE`, page-matching `LESSON:` id); all 13 NO_REVIEW pages carry honest reasons and no prompt fence; all 62 `**N/N**` checkpoints match the registry with a sane progression and both decreases documented as intentional retirements; independent future-leakage and self-containment scans are clean; both author-supplied validators pass and are corroborated; the diff is exactly the expected append (+5187/−0 over the 132 files, `learner-app/` untouched, HEAD `9cfc544`); and `npm run build` still produces 167 pages. The un-reproduced mandated fingerprint is recorded as a non-blocking method-ambiguity note alongside my independently computed values.

## Companion review status (mandatory)

```text
CONTENT_REVISION:             c8a1d5f8461b3c02
  (independent recomputation — sha256-16 concat worktree-bytes of the
   132 lesson files: 2f77c9d030128d81; method ambiguity → QA-S29-001)
PEDAGOGY_REVIEW_REQUIRED:     YES
PEDAGOGY_REVIEW_ARTIFACT:     pending
CONTENT_TECHNICAL_QA:         PASS
```

## Delta review — revision 36301c0f4b6f4835

> Bounded delta on the pedagogy fix PED-001 only: the shared intro line on
> the 119 REVIEW pages. Prior PASS findings carry over; only the delta was
> re-verified. Verdict: **PASS** (delta).

| # | Delta check | Evidence | Result |
|---|-------------|----------|--------|
| 1 | New intro verbatim on 119 REVIEW pages | Own script over `registry.json`: 119/119 pages contain the exact sentence `Dán prompt dưới đây vào **AI local** — … — mọi fix vẫn là của bạn.` exactly once; uniform position (line idx 2 of section, right after `## 🤖 AI Local` heading, before ```` ```text ```` fence) in all 119 | PASS |
| 2 | 13 NO_REVIEW pages unchanged | 13/13 pages have **zero** `Dán prompt` occurrences (list: m12/02, m14/01, m14/03, m15/01, m15/02, m15/03, m16/01, m17/01, m18/01, m19/01, m20/01, m21/01, m22/01). Section-source mtimes: all 13 NO_REVIEW sources stamped 01:25–01:41 (original generation), all 119 REVIEW sources re-stamped 02:22:38 (single fix batch); prior review artifact written 02:13:08 — between the two. Chain: old applied == old source (prior check 9) ∧ current applied == current source ∧ source untouched ⇒ applied unchanged | PASS |
| 3 | Section-source byte fidelity | Per-file compare: 132/132 applied segments byte-match `sections/mNN/*.md` (page ends with source bytes) | PASS |
| 4 | Mechanical validators | `validate_sections.py` → `files=132 failures=0`; `audit_sections.py` → `audited=132 findings=0` (exit 0 both) | PASS |
| 5 | Diff scope | `git status --short`: 132 ` M web/src/content/docs/m*/0*.md` + 1 untracked `AI_HANDOFF/work/step-29-ai-local-review/`; nothing else. `git diff --stat`: 132 files, **5187 insertions(+), 0 deletions** — pure appends; 0 deletions proves no mid-file edits. `git status learner-app/` empty. Note: dispatch estimated "~+5,250"; actual is 5,187 — identical to the prior revision's count, consistent with a line-for-line sentence swap (new intro is one physical line, same as old) | PASS |
| 6 | Fingerprint reproduction | **Reproduced `36301c0f4b6f4835`**: sha256 over sorted `glob.glob('web/src/content/docs/m*/0*.md')` (132 files), per file `h.update(path)` + `h.update(raw bytes)`, first 16 hex. Caveat: the documented "relpath-from-docs-dir-with-forward-slashes" description does NOT reproduce (`m01/01-…md` → `29070a4c0ff337e6`); the value that reproduces is the **raw glob path as Windows returns it** (`web/src/content/docs\m01\01-…md`, native separators). Fingerprint is valid and deterministic on this platform; doc wording ambiguous | PASS (with note) |

Delta findings: zero blocking. QA-S29-001 is resolved in part — the fingerprint method is now identifiable (raw glob path, not normalized relpath); recommend the orchestrator correct the method description for future reviewers.

```text
CONTENT_REVISION:             36301c0f4b6f4835
  (independently reproduced — sha256-16, raw Windows glob path + raw
   bytes over the 132 lesson files; documented "relpath fwd-slashes"
   variant yields 29070a4c0ff337e6)
PEDAGOGY_REVIEW_REQUIRED:     YES (delta was a pedagogy fix — PED-001;
   companion reviewer re-check on this revision is the peer call)
PEDAGOGY_REVIEW_ARTIFACT:     pending
CONTENT_TECHNICAL_QA:         PASS (delta)
```
