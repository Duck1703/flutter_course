# 08 — Content Fidelity Findings (Lumen + Forge)

## Forge — website coverage audit (read-only)

| Check | Result |
|---|---|
| Build | `npm run build` exit 0 — **61 pages** (57 at M12 + 4 M13); warnings unchanged: Pagefind unsupported on windows-x64, sitemap `site` unset |
| Routes | all 44 lessons + 13 milestone index pages + `getting-started` + `roadmap` + root index present |
| Sidebar (`astro.config.mjs`) | M01–M13 wired under 4 phase groups; each `autogenerate` directory matches on-disk dir; M13 entry present |
| Roadmap page (`roadmap.md`) | statuses accurate: M01–M13 `AVAILABLE`, M14–M29 `PLANNED`; per-milestone summaries match shipped scope; no false "complete" claims |
| Frontmatter | all lesson files carry `title`/`description`/`sidebar.label` consistently |
| Snippet fidelity | sampled code blocks in m10/01, m10/03, m13/02, m13/03, m04/02 vs on-disk learner source — verbatim or correctly elided; no snippet teaches APIs absent from `learner-app/pubspec.yaml` |
| Website modified by audit | NO |

No website-structure finding: the site does not hide or misrepresent the
senior mapping; every lesson carries a "Trong project senior"/"Senior
project connection" section.

## Lumen — content fidelity findings

### F-C1 (feeds FD-01) — m03/01 false senior claim — MEDIUM, DEVIATION

- **Artifact:** `web/src/content/docs/m03/01-stateless-va-stateful.md` L91–95
- **Claim:** "menu của senior cũng là `StatefulWidget` với `_MenuScreenState`
  (giữ overlay/dialog state)"
- **Senior truth:** `MenuScreen extends StatelessWidget`
  (`lib/screens/menu_screen.dart` L13). The stateful pieces are
  `_MenuScreenEventBridge` (event subscription only) and `MenuScreenView`
  (holds only `_dialogDismissLocked`). `dialogState` lives in
  `MenuScreenViewModel`, not in a `State` class.
- **Why it matters:** teaches a wrong state-ownership picture precisely at
  the milestone teaching "where state should live"; ironically the real
  senior code demonstrates the lesson's own point better than the claim.
- **Remediation:** CONTENT_ONLY — correct the class names + ownership
  sentence; no code change.

### F-C2 (feeds FD-02) — course-only menu elements without removal mapping — MEDIUM

Lessons introduce sound toggle (m03), tap counter (m03), session ticker card
(m06), reset button (m10) and mark them ephemeral/demo in code comments, but
no lesson or roadmap line says when they leave the product. Learner finishing
M13 still sees all four on the menu — none exist in senior's menu.
Remediation: ROADMAP — attach explicit removal/replacement milestones
(sound→M16 settings; reset→M24 sign-out; ticker+counter→M29 or earlier
menu-parity step), or add a one-line removal notice in-course.

### F-C3 (feeds FD-04) — profile model parity — MEDIUM

m04/01 honestly lists senior's extra fields (`totalEarnings`,
`totalQuestionCount`, `LevelConfig` cap) and labels `expForNextLevel` as a
simplification → good. Gap: default *values* (`'Khách'`, 120/400 EXP) are
presented as "the guest profile" without noting senior's default is
`'0XFF'`/all-zeros; the fixture then becomes the persisted default. Minor
mislabel — the simplification is declared but its *values* are not
identified as non-senior. Remediation: CONTENT_ONLY note in m04/01 + M14/M22
must restore senior defaults/field set (roadmap precision).

### F-C4 (feeds FD-06) — `MenuLoadState` framing — MEDIUM

m11 lessons present load-state as the VM's job — technically correct for the
learner stage, but no lesson/comment says "senior's menu has no load state:
its repository is stream-seeded so data is instant; this enum retires at
M14". Risk: learner may carry "every screen needs a load-state enum" into the
repo era. Remediation: CONTENT_ONLY (+ note in M14 brief when produced).

### F-C5 (feeds FD-09) — snackbar emit-site nuance — LOW

m13/03 shows the senior `MenuSnackBarRequested` handler verbatim (verified)
but never states the senior menu VM does not emit it — senior's snackbar
events come from dialog VMs with their own types
(`MenuAuthDialogSnackBarRequested`, `MenuSignOutDialogSnackBarRequested`).
Not misleading-by-commission; incomplete-by-omission. Remediation:
CONTENT_ONLY one-liner.

### F-C6 (feeds FD-12) — M09 roadmap scope drift — MEDIUM

Roadmap M09 scope text lists "simple money amount per question", reveal
delay (`Future.delayed` as a Dart concept), and explanation dialog —
unshipped. `M07_M09_IMPLEMENTATION_NOTES.md` records the actual cut
(no money ladder, no lifelines, `GameEndReason` enum) and D18 covers the
15s timer. Content correctly teaches what shipped. Finding is between
**roadmap text** and **shipped scope**: ROADMAP remediation — annotate M09
scope with the as-built subset + confirm M19/M20 picks up every dropped item
(it does: ladder, pending/reveal, explanation, guaranteed amount, PopScope).

### Danger-phrase & analogy audit (Lumen)

- ~57 `giống hệt`/`y hệt`/`senior cũng`/`đúng như senior` hits reviewed —
  all either learner-internal comparisons or senior claims verified true.
  Only F-C1 fails.
- Android bridges use the required SIMILARITY / IMPORTANT DIFFERENCE /
  DO NOT ASSUME structure everywhere; none distort senior semantics
  (Stream≠Flow cold/hot caveat; broadcast≈SharedFlow with manual-cancel
  caveat; `pop(result)`≈`setResult`+`finish` with route-scoped caveat).
  No analogy steers away from the senior implementation.
