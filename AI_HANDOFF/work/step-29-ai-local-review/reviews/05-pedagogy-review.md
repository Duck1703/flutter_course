# PEDAGOGY REVIEW — Step 29: per-lesson AI Local project-alignment review layer

> Reviewer: Pedagogy Reviewer (`pedagogy-reviewer`) — independent; did not
> author or modify any reviewed file.
> Artifact under review: trailing `## 🤖 AI Local — Kiểm tra project sau bài
> này` section appended to all 132 lesson pages
> `web/src/content/docs/m*/0*.md` (29 milestones).
> CONTENT_REVISION: `c8a1d5f8461b3c02` (declared fingerprint — see intake note)
> git HEAD: `9cfc544` on `feature/step29-ai-local-review-checkpoints`
> Companion technical review: **NOT READ** (independence rule §1). No file
> under `reviews/` or elsewhere containing a QA verdict was opened.
> Verdict: **PEDAGOGY_PASS_WITH_NOTES**

## Intake gate

This is a remediation-mode / audit review (contract §9): the artifact is a
uniform appended layer, not milestone production. Inputs checked:

| Required input | Present? |
|---|---|
| Scope + design rules (`02-classification-rules.md`, task briefing) | Y |
| All 132 learner-facing lesson files at one revision | Y — `git status` shows the 132 modified lesson files on the step-29 branch over HEAD `9cfc544`; every file contains exactly one AI Local h2, always the last h2 (verified programmatically) |
| Fixed learner profile (experienced programmer, Android bg, Flutter/Dart beginner, Vietnamese-medium) | Y (agent definition) |
| Reviewer did not author/modify artifact | Y |
| Companion review unseen | Y |

**Fingerprint note (honest discrepancy):** the declared
`CONTENT_REVISION c8a1d5f8461b3c02` could not be reproduced locally with the
contract §2 method or sha256/sha1 variants tried (sorted hash-object list →
sha1 gives `784a819e8cc4a3a65e6fc5c118847c6a21ca8f89`; sha256 variants differ
again). Recorded here so Atlas can verify the companion review names the same
declared fingerprint. The reviewed bytes themselves are unambiguous: the
working tree at the branch above. This does not block the review — the content
set is fully identified — but if the two reviews' fingerprints or file sets
differ, this review must be treated as stale per §7.

**Structural census (mechanical, all 132 files):**

- 119 sections contain exactly one ` ```text ` fenced prompt — matches the
  declared REVIEW_REQUIRED count.
- 13 sections are NO_REVIEW notes — exact match with the declared list:
  m12/02, m14/01, m14/03, m15/01, m15/02, m15/03, m16/01, m17/01, m18/01,
  m19/01, m20/01, m21/01, m22/01.
- All 119 prompts share one identical Vietnamese intro line; all prompts end
  `FILES_MODIFIED_BY_REVIEW: NONE`; zero governance tokens
  (`A-/D-/F-/FR-/G-xx`, `MILESTONE_GATE`, reviewer names, `CONTENT_REVISION`)
  appear inside any learner-facing section (regex scan, 0 hits).
- Section sizes: ~35–50 lines each; prompt bodies bounded.

## Deep-read sample (34 sections)

Prompts read in full: m01/01, m01/02, m01/03, m02/04, m03/03, m04/02, m05/03,
m06/03, m07/02, m08/02, m09/03, m10/04, m11/01, m13/02, m14/06, m14/07,
m17/03, m19/04, m20/03, m23/04, m24/03, m25/05, m26/01, m27/05, m28/06,
m29/05, m29/07.
NO_REVIEW notes read in full: all 13 (m12/02, m14/01, m14/03, m15/01–03,
m16/01, m17/01, m18/01, m19/01, m20/01, m21/01, m22/01).

Every milestone m01–m29 is covered by at least one full read.

## Per-lesson P1–P12 table (adapted to this artifact class)

This layer does not teach — it verifies. Mapping used:
P1→"assumes only checkpoint knowledge", P2→"positions problem (drift) honestly",
P3→"correct mental model of what 'done' means at this checkpoint",
P4→"Vietnamese clarity of section+prompt", P5→"learner-facing load of the
section+report", P6→"bridges report to the learner's own project",
P7→"copy-vs-reasoning: does the layer replace learner judgement?",
P8→"teaches self-verification habits", P9→"active self-check where applicable",
P10→"misconception risk (false 'done'/'failed' signal)", P11→"learner noise",
P12→"outcome truth (report = alignment truth at THIS point)".
Lesson-body teaching dimensions are out of scope (each milestone already has
its own pedagogy review).

| Lesson (section) | P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 | Verdict | Key evidence |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| m01/01 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | "`lib/main.dart` VẪN LÀ app counter … đây không phải lỗi" — honest deferral from lesson 1 |
| m01/02 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | "Chưa có StatefulWidget … đó là bài sau, không phải thiếu" |
| m01/03 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | reviews *hygiene after experiments* — clever framing of a tooling lesson |
| m02/04 | 4 | 4 | 4 | 4 | 3 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | "KHÔNG có GestureDetector/onTap … không phải thiếu" prevents the classic false-gap |
| m03/03 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | Tự-làm artifact (`_MuteDot`) anticipated as acceptable — no false flag |
| m04/02 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | "kiểm tra hành vi method, không chỉ sự tồn tại" — behaviour-level check |
| m05/03 (gate) | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | `~13` approximate test count; `await`-in-main marked "shape chuẩn bị, không phải thiếu" |
| m06/03 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | catches leftover experiment code "quên xoá" — teaches cleanup habit |
| m07/02 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | "bấm ô đáp án không có gì xảy ra là ĐÚNG" |
| m08/02 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | "`unused_element` tạm thời là chấp nhận" — preempts false alarm |
| m09/03 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | "`showDialog` trong build … → DIVERGED" flags a real beginner bug class |
| m10/04 (gate) | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | strict ordering semantics; "~43" test count |
| m11/01 | 4 | 4 | 4 | 4 | 3 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | "UI VẪN dùng FutureBuilder … là đúng" mid-refactor honesty |
| m13/02 | 4 | 4 | 4 | 4 | 3 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | checks mechanism (subscribe site, double-subscribe guard), not just presence |
| m14/06 | 4 | 4 | 4 | 4 | 3 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | bridge-state `ProfileStore` "bỏ sớm = ProviderNotFoundException" — protects learner from premature cleanup |
| m14/07 (gate) | 4 | 4 | 4 | 4 | 3 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | RETIRE list makes "deleted = correct" explicit — crucial for refactor lessons |
| m17/03 | 4 | 4 | 4 | 4 | 3 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | "UI VẪN hiển thị literal tiếng Việt … đó là bài 4" |
| m19/04 | 4 | 4 | 4 | 4 | 2 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | ~40-line spec block; load lands on the AI, learner's task stays copy-paste — high but justified for a 6-phase FSM |
| m20/03 | 4 | 4 | 4 | 4 | 2 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | "arm aiAssistant/walkAway … `break` có chủ đích — BÀI 4 mới nối" |
| m23/04 | 4 | 4 | 4 | 4 | 3 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | names the exact failure ("Thiếu `_isLatestRequest` ở một nhánh = NEEDS_FIX") with its evidence path |
| m24/03 | 4 | 4 | 4 | 4 | 3 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | privacy rule (no real email/password in logs) even inside the checklist |
| m25/05 (gate) | 4 | 4 | 4 | 3 | 2 | 4 | 4 | 4 | — | 4 | 2 | 4 | pass | register shifts telegraphic ("contract-trước-impl-sau", "nuốt"); honesty-check bullet is excellent pedagogy |
| m26/01 | 4 | 4 | 4 | 4 | 3 | 4 | 4 | 4 | — | 4 | 3 | 4 | pass | NO-CODE-DELTA review is justified here — it catches learners who jumped into DRE early; see PED-003 |
| m27/05 | 4 | 4 | 4 | 3 | 2 | 4 | 4 | 4 | — | 4 | 2 | 4 | pass | 11-item boundary list ("VM context-free", "screen tự resolve origin") — strong divergence map, very dense prose |
| m28/06 (gate) | 4 | 4 | 4 | 3 | 2 | 4 | 4 | 4 | — | 4 | 2 | 4 | pass | atomic-swap completeness check is the right thing to verify; prose heavily compressed |
| m29/05 | 4 | 4 | 4 | 3 | 2 | 4 | 4 | 4 | — | 4 | 2 | 4 | pass | event-vs-state judgement rule ("điều-gì TỒN-TẠI vs XẢY-RA") teaches the core distinction inside the prompt |
| m29/07 (final gate) | 4 | 4 | 4 | 3 | 2 | 4 | 4 | 4 | — | 4 | 2 | 4 | pass | declared-gaps handled honestly; OUTPUT extends fixed contract — see PED-004 |
| m12/02 (NR) | — | — | — | 4 | 4 | 4 | — | 4 | 3 | — | 4 | 4 | pass | honest reason + redirects to m12/01 prompt for status check |
| m14/01 (NR) | — | — | — | 4 | 4 | 4 | — | 4 | 3 | — | 4 | 4 | pass | self-check question + "đừng xoá sớm (bài 7 mới xoá)" — protects against eager cleanup |
| m15/02 (NR) | — | — | — | 4 | 4 | 4 | — | 4 | 3 | — | 4 | 4 | pass | optional self-check mirrors the lesson's own exercise |
| m21/01 (NR) | — | — | — | 4 | 4 | 4 | — | 4 | 4 | — | 4 | 4 | pass | "đếm 10 chỗ emit" — a real verification *skill*, with the failure interpretation explained |
| m22/01 (NR) | — | — | — | 4 | 4 | 4 | — | 4 | 4 | — | 4 | 4 | pass | lists exactly which old-scaffold pieces must still be alive + a self-quiz with answer |
| m15/01, m15/03, m14/03, m16/01, m17/01, m18/01, m19/01, m20/01 (NR) | — | — | — | 4 | 4 | 4 | — | 4 | 3 | — | 4 | 4 | pass | uniform pattern: honest reason → optional AI question or manual check → "Checkpoint code sang bài sau" stating what must remain |

`—` = dimension not applicable to a no-delta note.

## Instrument: copy-vs-reasoning (P7) — applied to the layer itself

| Risk hypothesis | Evidence found | Judgement |
|---|---|---|
| "AI grades my homework" → learner stops judging | Every prompt opens `CHỈ REVIEW — KHÔNG SỬA` with an explicit Cấm list (no edits/format/patch/commit/refactor/delete) and closes `FILES_MODIFIED_BY_REVIEW: NONE`; fix suggestions are bounded "trong phạm vi đã học; không tự sửa" | verifier, not fixer — by construction |
| Learner could feed EXPECTED STATE to an AI as an implementation spec | The specs (m19/04, m27/05, m29/05) contain no information beyond what the lesson itself already taught/shown; the layer adds no new answers | no added leak |
| Report does the thinking the checkpoint checklist used to do | Per-lesson `Điểm kiểm tra hoàn thành`/`Checkpoint hoàn thành` lists are retained untouched above the section; the AI layer is additive, not a replacement | complementary |
| NO_REVIEW lessons teach dependence anyway | Opposite observed: notes route the learner to *manual* checks (grep counts, `flutter test` baselines, count-the-emit-sites exercises) | builds self-verification |

## Instrument: scaffold/habit value (P8 analog)

The layer models a genuinely transferable engineering habit: define expected
state → inspect evidence (`EVIDENCE: file/symbol → observation`) → classify
(behind/ahead/diverged) → fix yourself. m21/01's "đếm số chỗ
`emitEvent(GameDialogRequested)` — phải đếm được 10 chỗ" is an exemplary
self-verification exercise. Ahead-classification (`AHEAD_COMPATIBLE` vs
`AHEAD_RISKY`/`DIVERGED`) teaches the learner that "more code" is not
"better progress" — a useful metacognitive frame.

## Instrument: learner-facing noise (P11)

- Governance IDs/pipeline vocabulary inside sections: **0 occurrences** (scan).
- Contract terms `STRICT`, `semantic`, `EXPECTED STATE`, `INVARIANTS NỀN`,
  `AHEAD_*`, `BLOCKED_PROJECT_ROOT`, `DIVERGED` appear in every prompt but
  each is self-explained inline at least once per prompt ("Mục (STRICT) phải
  đúng tên … mục khác chấm semantic — cách viết tương đương được chấp nhận").
  They name the *reviewer's* mechanics, which the learner only needs to
  skim — acceptable.
- Test-count literals (`116/116`, `259/259`, `369/369`) are meaningful to the
  learner (their own suite size) — fine; see PED-005 for the edge case.
- `TEACHING SCAFFOLD` (m27/05), `DECLARED-GAP` (m29/07), `GATE` (m14/07,
  m25/05) are internal-flavored caps-lock terms; each is contextually
  explained ("scaffold này ĐÚNG — GameDialogButton … là M28"; "declared,
  không-phải-defect"). Borderline — contributes to PED-002.
- **Register shift:** prompts up to ~m24 use clean flowing Vietnamese; from
  ~m25/05 through m29 the prose compresses into hyphenated telegraphic
  creole ("KIẾN-TRÚC TRỌNG-TÂM", "switch-kiệt-hợp", "4-scope keyed
  `ValueKey(transitionKey)`", "retire-incomplete", "kết-quả-zero",
  "nuốt-tap-trong", "tham số CONTRACT"). Noise density rises exactly where
  content difficulty rises — the P11 failure pattern — though the learner's
  mandatory interaction with the block is only copy-paste (see PED-002).

## Instrument: checkpoint-fairness / misconception risk (P10 analog)

- The scope rule is the layer's backbone and it is worded correctly
  everywhere sampled: "thứ ngoài danh sách — kể cả thứ 'tốt/chuẩn' — KHÔNG
  tính là thiếu. Project học theo từng bài, đừng chấm theo app hoàn chỉnh"
  (m01/01). This prevents the failure where a reviewer grades the project
  against the finished app.
- Intentionally-absent items are consistently framed as design, not deficit:
  "`_PlayButton` … KHÔNG có GestureDetector/onTap (STRICT: chưa có tương
  tác — đó là thiết kế của khoá học, không phải thiếu)" (m02/04); "bài cố ý
  để trống … có rồi là ahead-of-course" (m07/02); "KHÔNG ĐƯỢC có (chưa đến)"
  lists throughout m23–m29.
- Refactor lessons correctly invert "deleted = missing": m14/07 retire list,
  m29/05 "`showDialog` còn = BEHIND retire-incomplete". This matters —
  otherwise the most confusing report for a beginner is "you deleted code,
  GAP" when deletion was the assignment.
- Misconception risk of false reassurance is guarded by `DIVERGED` /
  `AHEAD_RISKY` classes and the evidence line — sampled prompts always tie
  verdicts to observable files/symbols.
- m26/01 contains the only "soft" check observed ("Người học hiểu được … ghi
  nhận trong WHAT_MATCHES nếu thấy note/commit") — flagged PED-003.

## Findings

```text
ID:              PED-001
Level:           FRICTION
Lesson:          all 132 files, section intro line; absence in
                 getting-started.md / roadmap.md / index.mdx / concepts.md
Concept:         —
Evidence:        The intro presumes a running tool: "Dán prompt dưới đây vào
                 AI local đang mở tại project Flutter bạn đang tự code. AI
                 chỉ review và báo cáo, không được tự sửa code." A repo-wide
                 grep shows "AI local"/"AI Local" appears ONLY inside the
                 appended sections — no learner-facing page defines the
                 term, names what qualifies (an agentic coding AI with
                 filesystem+terminal access at the project root), states the
                 step is optional, or says what to do with the report. First
                 encounter is m01/01, right after `flutter create`.
Learner risk:    A learner without such a tool cannot tell whether the step
                 is required (sections sit right at the "milestone complete"
                 point, reading like a gate); a learner with one gets no
                 guidance that REQUIRED_FIXES are *theirs* to implement.
                 Mild, recurring, and self-contained per page.
Why pedagogical: an unexplained tool dependency + missing optionality/
                 fallback is an instruction-clarity gap (P4), not style.
Required outcome: learner can answer, on first encounter, "what counts as
                 AI local, do I need it to continue, and who applies the
                 fixes" — e.g. one aside in getting-started.md or a
                 one-line fallback in the intro ("nếu bạn chưa có, bỏ qua —
                 checklist phía trên là đủ").
Remediation class: ENRICH
Owner:           Lumen
```

```text
ID:              PED-002
Level:           FRICTION
Lesson:          m25/05, m26/01, m27/05, m28/06, m29/05, m29/07 sections —
                 `text` prompt blocks (sampled; pattern also visible in the
                 longest late-course sections by line-count scan)
Concept:         —
Evidence:        Compare m01/01 ("Nếu thấy nhiều project Flutter mà không rõ
                 đâu là của tôi → BLOCKED_PROJECT_ROOT, đừng đoán") with
                 m29/05 ("KIẾN-TRÚC TRỌNG-TÂM M29: `MenuDialogState` sealed
                 5-variant `isVisible`/`transitionKey=>runtimeType` →
                 `MenuDialogLayer` `SizedBox.expand`+`AnimatedSwitcher`
                 `dialogMotionLong` + switch-kiệt-hợp → 4-scope keyed
                 `ValueKey(transitionKey)` …") and m28/06's ~211-word single
                 bullet on `game_feature_button.dart`. Late prompts pack
                 5–10 verification items per hyphenated bullet.
Learner risk:    the learner can always copy-paste, but can no longer read
                 the prompt to sanity-check that the report's GAPS/DIVERGENCES
                 correspond to what was actually asked — the one judgement
                 act the workflow leaves to them. The compressed creole is
                 harder Vietnamese, exactly in the hardest milestones.
Why pedagogical: P5/P11 — comprehension load of learner-visible text rises
                 with difficulty; the fix is prose style inside the block,
                 not less rigor.
Required outcome: a mid-course learner skimming any prompt can identify what
                 each bullet asks the reviewer to check, without decoding
                 stacked hyphenated compounds.
Remediation class: ENRICH
Owner:           Lumen
```

```text
ID:              PED-003
Level:           NOTE
Lesson:          m26/01 — EXPECTED STATE, 4th bullet
Concept:         —
Evidence:        "Người học hiểu được (không kiểm được bằng file — ghi nhận
                 trong WHAT_MATCHES nếu thấy note/commit): bốn vai DRE …"
Learner risk:    the reviewer may produce a WHAT_MATCHES entry conditioned
                 on "notes/commits" the learner was never told to write —
                 a confusing report line for something unverifiable.
Why pedagogical: checkpoints should only promise verdicts the evidence can
                 support; an "understanding" check the AI cannot perform
                 weakens the report's honesty contract.
Required outcome: report fields assert only what project evidence shows;
                 understanding-level items belong to the lesson's self-check,
                 or should be phrased as optional learner-self-report.
Remediation class: REMOVE_NOISE
Owner:           Lumen
```

```text
ID:              PED-004
Level:           NOTE
Lesson:          m29/07 — OUTPUT block
Concept:         —
Evidence:        Adds `DECLARED_GAPS_AND_DEVIATIONS:` line and
                 "(FINAL_COURSE_GATE)" suffix; reinterprets
                 READY_FOR_NEXT_LESSON ("course-complete → YES nghĩa-là
                 graduate"). The design contract says the OUTPUT format is
                 fixed.
Learner risk:    none — the addition is pedagogically sensible for a final
                 gate; the deviation is contract conformance, not learner
                 harm. Recorded so the technical reviewer/Atlas can decide
                 whether the fixed-format rule permits gate extensions.
Required outcome: either conform the block to the fixed format or amend the
                 contract to allow documented gate extensions.
Remediation class: GOVERNANCE_ONLY
Owner:           Atlas
```

```text
ID:              PED-005
Level:           NOTE
Lesson:          m07/02 (`15 xanh`), m19/04 (`116/116` STRICT), m20/03
                 (`141/141` STRICT), m25/05 (`236/236` STRICT), m29/05
                 (`369/369` STRICT), m29/07 (`396/396` STRICT)
Concept:         —
Evidence:        exact test counts marked STRICT; compare the safer `~13`/
                 `~43` usage in m05/03 and m10/04.
Learner risk:    a learner who added tests via Tự-làm exercises will report
                 e.g. 117/117 and may receive a GAP/NEEDS_FIX line on a
                 correct project — mitigated in-prompt by AHEAD_OF_COURSE +
                 the semantic clause, so the expected misroute is rare.
Required outcome: exact counts keep working; where learner-added tests are
                 plausible, allow "≥N" or route extra tests to
                 AHEAD_OF_COURSE explicitly.
Remediation class: CLARIFY_MODEL
Owner:           Lumen
```

```text
ID:              PED-006
Level:           NOTE
Lesson:          m12/02 vs the other 12 NO_REVIEW notes
Concept:         —
Evidence:        m12/02 uses the contract-terse form ("**Không cần review
                 project ở bài này.**" + redirect to m12/01's prompt); the
                 m14–m22 notes use a richer but non-canonical form
                 ("Bài này **không thay đổi project**" + self-check +
                 "Checkpoint code sang bài sau").
Learner risk:    none harmful — both forms are honest; the richer form is
                 arguably the better teaching artifact. Consistency only.
Required outcome: pick one no-review template; the m14–m22 pattern (reason +
                 optional check + forward checkpoint) is the stronger one.
Remediation class: GOVERNANCE_ONLY
Owner:           Atlas
```

## Verdict rationale

`PEDAGOGY_PASS_WITH_NOTES` — two FRICTION findings and four NOTEs; no
LEARNING_RISK, no PEDAGOGICAL_BLOCKER (contract §5 mapping).

The layer's core pedagogy is sound and, in places, exemplary:

- **Checkpoint fairness is the standout strength.** Every sampled prompt
  states the scope rule ("đừng chấm theo app hoàn chỉnh"), names what is
  intentionally absent and *why*, marks STRICT vs semantic so correct-but-
  different work doesn't false-flag, and gives ahead-of-course work a
  taxonomy instead of a penalty. A beginner's worst outcome — "the AI said
  my correct project is broken" — is designed against repeatedly.
- **Verifier, not grader.** The read-only contract is airtight and uniform;
  fixes stay with the learner; `FILES_MODIFIED_BY_REVIEW: NONE` makes the
  boundary auditable. The per-lesson checklists remain the primary
  self-check; this is an additive net for drift the learner cannot yet
  self-detect.
- **Self-verification is taught, not just outsourced.** The NO_REVIEW notes
  are honest (real reasons, not convenience), and the best ones (m21/01's
  count-the-emit-sites, m22/01's old-scaffold inventory, m14/01's "đừng xoá
  sớm") hand the learner a manual check they can repeat forever.
- **Zero governance bleed** — confirmed by scan, not sampling luck.

The two FRICTIONs are real but shallow and cheap to remediate: the tool the
whole layer depends on is never defined or marked optional, and late-course
prompts outrun a beginner's ability to sanity-read them. Neither blocks
learning the actual lessons; both deserve a fix before this layer is called
final.

## Checks not performed

- Per-file verification of every EXPECTED STATE bullet against its lesson's
  taught content (119 files): **NOT_RUN** — claim-level technical truth is
  Argus's lane; pedagogy sampled 27 prompt sections + all 13 notes.
- Reproducing the declared `CONTENT_REVISION` computation method:
  attempted, **failed** — see intake note; the reviewed byte set is fully
  identified via branch+file-set.
- Whether the fenced prompts actually elicit well-formed reports from
  specific local AI tools: **NOT_RUN** (no tool execution; outside scope).

## Delta review — revision 36301c0f4b6f4835

> Bounded re-review of the PED-001 remediation only. Reviewer: Pedagogy
> Reviewer — independent; did not author or modify the delta.
> Prior revision: `c8a1d5f8461b3c02` (PEDAGOGY_PASS_WITH_NOTES).
> Delta revision under review: `CONTENT_REVISION: 36301c0f4b6f4835`.
> git HEAD: `9cfc544` + working tree (132 modified
> `web/src/content/docs/m*/0*.md`; layer still uncommitted).
> Companion technical review: **NOT READ** (independence rule).
> Scope: the shared intro line of the `## 🤖 AI Local` section on the 119
> REVIEW pages. Out of scope: prompt bodies, NO_REVIEW notes, lesson
> content, PED-002…PED-006 (standing, unchanged — see below).

### Delta intake

The declared fix: the shared intro line now reads —

> "Dán prompt dưới đây vào **AI local** — một trợ lý code chạy trên máy
> bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong
> IDE). Bước này tuỳ chọn nhưng đáng làm sau mỗi bài: AI chỉ review và
> báo cáo, không tự sửa code — mọi fix vẫn là của bạn."

Mechanical census of the working tree:

- New line present in **exactly 119 files**, byte-identical
  (`sort -u` = 1 variant), each file exactly 1 occurrence, always inside
  the `## 🤖 AI Local` section as the first paragraph.
- Old wording fully removed: `đang mở tại project` / `AI local đang mở`
  → **0 hits** repo-wide.
- All 13 NO_REVIEW pages (m12/02, m14/01, m14/03, m15/01, m15/02,
  m15/03, m16/01, m17/01, m18/01, m19/01, m20/01, m21/01, m22/01)
  contain **0** `Dán prompt` occurrences — untouched by the delta;
  m15/02's AI Local section verified byte-identical to the pre-existing
  `sections/` snapshot.
- Prompt bodies unchanged: fragments quoted in the prior review still
  verbatim in place (m01/01 scope rule + `BLOCKED_PROJECT_ROOT`, m02/04
  `` `GestureDetector`/`onTap` `` STRICT bullet, m21/01 count-the-emit-sites
  exercise, m29/05 `KIẾN-TRÚC TRỌNG-TÂM`). 119 `FILES_MODIFIED_BY_REVIEW:
  NONE` markers intact; section structure (heading → intro → ```text
  fence) uniform.
- Spot-checks (11 pages, all course phases): m01/01, m05/03, m10/04,
  m14/07, m15/04, m15/05, m19/04, m23/04, m25/05, m28/06, m29/07 — all
  carry the identical line in the identical position.
- Fingerprint: declared `36301c0f4b6f4835` could not be reproduced with
  the contract §2 method or sha1/sha256 variants tried (same honest
  limitation as the prior review). The reviewed byte set is unambiguous:
  the 132 modified lesson files in the working tree on `9cfc544`. The
  new fingerprint differs from `c8a1d5f8461b3c02`, consistent with a new
  revision. If the companion review names a different fingerprint or
  file set, treat this delta verdict as stale per §7.

### 1. Does the new wording resolve PED-001? — YES

Judged as the beginner at m01/01 who just ran `flutter create`, the
finding's three required-outcome questions are now all answered inline,
at the exact point of first encounter:

| Required outcome | New wording | Verdict |
|---|---|---|
| "what counts as AI local" | "một trợ lý code chạy trên máy bạn, có quyền đọc file và chạy lệnh trong project (ví dụ AI agent trong IDE)" | Met — names the tool class, its capability surface (read files + run commands in the project), and a concrete recognisable anchor (IDE agent). Correctly *excludes* chat-only tools (a web chatbot passes neither "trên máy bạn" nor "đọc file/chạy lệnh trong project") — tighter than the old line. |
| "do I need it to continue" | "Bước này tuỳ chọn nhưng đáng làm sau mỗi bài" | Met — explicit `tuỳ chọn` removes the gate-reading the section's position created; "đáng làm" keeps the recommendation honest rather than marking it skippable-filler. |
| "who applies the fixes" | "AI chỉ review và báo cáo, không tự sửa code — mọi fix vẫn là của bạn" | Met — ownership assigned explicitly; consistent with the prompt body's `CHỈ REVIEW — KHÔNG SỬA` contract and `REQUIRED_FIXES` being the learner's job. |

The remediation chose the inline route — one of the two options the
finding offered ("e.g. one aside in getting-started.md **or** a
one-line fallback in the intro"). Inline is arguably the stronger fix:
the definition sits exactly where the need arises, on every page, with
no dependency on the learner having read a setup doc.

### 2. Vietnamese quality

Natural, fluent, register-consistent with the course's existing
VN/EN developer vocabulary. "trợ lý code chạy trên máy bạn", "tuỳ chọn
nhưng đáng làm", "mọi fix vẫn là của bạn" are idiomatic. "AI agent trong
IDE" is the correct concrete anchor for this learner profile
(experienced programmer — recognises Cursor/Copilot-style tools).
No new jargon: `prompt`, `IDE`, `review`, `fix` are all already in
course use (the prompts themselves carry `NEEDS_FIX`/`REQUIRED_FIXES`).
Reading load: ~45 words, two sentences, at the top of the section —
minimal.

### 3. Uniformity + NO_REVIEW integrity

Confirmed per the census above: 119/119 byte-identical, correct
position in all 11 spot-checks, zero old-line remnants, 13/13 NO_REVIEW
pages untouched.

### 4. New learner-facing issues introduced by the sentence — none at FRICTION+

Residual NOTE-level observations (do not block; no new finding filed):

- `getting-started.md`, `roadmap.md`, `index.mdx`, `concepts.md` still
  carry no durable definition of "AI local". The inline fix satisfies
  PED-001's required outcome on its own; a one-line definition in
  getting-started remains optional polish (every first encounter is a
  REVIEW page carrying the definition).
- Some NO_REVIEW notes still use the bare term (e.g. m15/02 "hỏi AI
  local"). Harmless: the earliest NO_REVIEW page (m12/02) doesn't use
  it in body text at all, and every NO_REVIEW page postdates dozens of
  definitional occurrences.
- "tuỳ chọn nhưng đáng làm" — optional-but-recommended is the right
  framing; no residual gate ambiguity.
- No governance tokens, no contract vocabulary added; no contradiction
  with the prompt body's read-only contract.

### Standing findings on revision 36301c0f4b6f4835

- PED-001 (FRICTION): **RESOLVED** by this delta.
- PED-002 (FRICTION, prompt-prose compression m25/05–m29/07),
  PED-003 (NOTE, m26/01 understanding-check), PED-004 (NOTE, m29/07
  OUTPUT extension — routed to Atlas), PED-005 (NOTE, STRICT test
  counts), PED-006 (NOTE, NO_REVIEW template split): **UNCHANGED** —
  prompt bodies and notes untouched by the delta; verified verbatim
  above.

### Delta verdict

**PEDAGOGY_PASS_WITH_NOTES** on `CONTENT_REVISION: 36301c0f4b6f4835`.

Mechanical basis (contract §5): the delta resolves PED-001 with zero
regression and introduces no new finding; one standing FRICTION
(PED-002) plus four NOTEs persist on the revision → notes/friction only,
no LEARNING_RISK, no PEDAGOGICAL_BLOCKER.
