# Step 29 · 03 — Validation & audit record

Frozen revision: `CONTENT_REVISION: 36301c0f4b6f4835` (post-delta; supersedes
`c8a1d5f8461b3c02` which was fully reviewed before the PED-001 intro fix).
git HEAD `9cfc544` + working-tree diff `132 files changed, +5,187
insertions, 0 deletions` — every change is the appended `## 🤖 AI Local`
block.

**Fingerprint method (exact, Windows):**
`files = sorted(glob.glob('web/src/content/docs/m*/0*.md'))` → for each:
`h.update(f.replace('web/src/content/docs/', '').encode('utf-8'))` —
leaves `mNN\NN-slug.md` with **backslashes** (glob's platform separator),
then `h.update(raw file bytes)`; sha256 hexdigest[:16]. The earlier
"forward-slash relpath" description was wrong; both reviewers verified
the corrected method reproduces the mandated value.

## Mechanical validation (`validate_sections.py`)

`files=132 failures=0`

Checks enforced: exactly-one `## 🤖 AI Local` heading per lesson page,
zero missing, zero duplicates, zero placeholders/template leftovers
(quoted rules *about* placeholders excluded), every ```text fence closed,
every REVIEW prompt ends `FILES_MODIFIED_BY_REVIEW: NONE`, read-only
contract (`KHÔNG SỬA`) present, `LESSON:` id locked to the page, section
is the last block of the page, NO_REVIEW pages carry no fence.

## Audits (`audit_sections.py`)

`audited=132 findings=0`

- **Future-leakage** — landmark-symbol table (corrected for real
  introduction points: `GameDialogState`@m15, `menu_tokens`@m02–m29/05,
  `UserProfileSyncRepository` contract@m24/03, `final class` convention
  @m13). Negation-aware: lines containing `KHÔNG`/`chưa`/`AHEAD`/`retire`
  are exclusions, not demands; right-side word-boundary enforced
  (`GameAnswerOption` ≠ `GameAnswerOptionData`). Initial heuristic run
  produced 36 candidate hits — all triaged as correct usage before
  rule-fix; 0 real findings.
- **Generic-prompt** — every REVIEW prompt carries ≥8 unique backticked
  identifiers and ≥1 concrete path; dense prompts (50–80 identifiers)
  are not flagged. 0 findings.
- **NO_REVIEW justification** — all 13 no-review sections carry a
  reason (pure theory / read-ahead / no file delta) and no prompt fence.
- **Exercise-solution leak** — no `<details>`/`<summary>`/answer blocks
  inside any AI Local segment. Quiz-game vocabulary ("ô đáp án",
  "Đáp án chưa đúng") and self-contained Q&A inside no-review notes
  ("đáp án: **1**") are not violations.

## Site build (post-Wave-F)

`npm run build` → **167 page(s) built, 166 Pagefind-indexed, vi** —
same as pre-feature baseline. Pre-existing duplicate-Starlight-id
warnings unchanged (M21/M22), non-blocking.

## Preview QA (built HTML inspection, `web/dist/`)

- Section renders as h2 inside `sl-markdown-content`; appears in
  page TOC ("🤖 AI Local — Kiểm tra project sau bài này").
- Prompt body renders inside Expressive-Code `<figure>`/`pre > code`
  with a working copy button (`data-code` attribute verified on
  m29/05 — full prompt text intact).
- Narrow viewport: `.expressive-code pre` keeps horizontal overflow
  scroll — acceptable at 375px; desktop 1440 inherits standard
  Starlight layout.
- Search: Pagefind indexes the section text (~20% of indexed words —
  74,400/368,426). Domain-aligned vocabulary; prompts use the same
  technical terms as the lessons. `data-pagefind-ignore` cannot wrap
  markdown-embedded content without breaking rendering — accepted
  trade-off; the `AI Local` heading itself doubles as a discoverable
  search term for the feature.

## Delta: PED-001 intro fix (post-review)

After the dual review on `c8a1d5f8461b3c02`, the shared intro line on all
119 REVIEW sections was replaced once — defines "AI local", marks the
step optional, and states the learner owns fixes. Applied byte-identical
to all 119 pages via `apply_sections.py`; 13 NO_REVIEW sections
untouched. New revision `36301c0f4b6f4835`; both reviewers re-verified
the delta on it: Argus **PASS**, Pedagogy
**PEDAGOGY_PASS_WITH_NOTES** (PED-001 resolved; PED-002..006 notes stand).

## Learner-app regression (untouched by Step 29)

- `git status -- learner-app/` → clean before and after verification.
- `flutter analyze` → **No issues found!**
- `flutter test` → **396/396 — All tests passed!**
- `flutter build web` → **√ Built build\web** (pre-existing
  CupertinoIcons font notice, benign).
