# STEP 26A — SCOPE LOCK

Branch: `remediation/step26a-final-release-blockers` (from 9323e57)
Baseline CONTENT_REVISION: `48f8f30f9cc62a22` (Step-26 audited revision)

## Editable (only these)

GROUP A — early factual claims:
- web/src/content/docs/m02/02-*.md (F26-R-09)
- web/src/content/docs/m02/03-*.md (F26-R-10)
- web/src/content/docs/m03/03-*.md (F26-R-11)

GROUP B — broken exercise answers:
- web/src/content/docs/m04/04-*.md (F26-R-02)
- web/src/content/docs/m08/04-*.md (F26-R-03)
- web/src/content/docs/m09/04-*.md (F26-R-04)
- web/src/content/docs/m10/04-*.md (F26-R-05)
- web/src/content/docs/m11/03-*.md (F26-R-06)

GROUP C — sequential blocker:
- web/src/content/docs/m12/02-*.md (F26-B-01)

GROUP D — technical teaching corrections:
- web/src/content/docs/m14/02-*.md (F26-R-07)
- web/src/content/docs/m20/01-*.md (F26-R-08)

GROUP E — late derive-first:
- web/src/content/docs/m28/05-*.md (F26-R-12)
- web/src/content/docs/m29/04-*.md (F26-R-13)

GROUP F — targeted noise/debris/index (register-named sites only):
- m27/03 (near prior finding lines ~324/404/479), m27/05, m27/06,
  m29/02 (~line 344), m29/index, m04/index
- debris sites named in the Step-26 register (dup headings, dangling
  `**`, orphan fragments) — only where repair is trivial
- index misclaims explicitly named: m04/index (lên cấp, setUp),
  m29/index (governance vocabulary)

## Forbidden

learner-app/** · senior repo · dependencies/pubspec · platform code ·
learner-app tests · routes/slug/sidebar changes · governance contracts ·
agent definitions · Step-21–26 historical evidence · new lessons/routes ·
M30 · unrelated FRICTION/NOTE cleanup.

## Review protocol

Per group: Lumen edit → frozen CONTENT_REVISION (sha256 of group's
changed files) → Argus (fresh agent, file paths only) + Pedagogy
Reviewer (fresh agent, same revision, independent) → Atlas reconcile.
Edits after review invalidate both reviews.

## Temp-verification policy

Exercise answers must be executed/mechanically validated against the
historical milestone API. Where direct execution needs a harness,
temp files live under `%TEMP%\step26a-verify\`, are deleted before
closeout, and results are recorded. TEMP_VERIFICATION_FILES_REMAINING
must be 0.
