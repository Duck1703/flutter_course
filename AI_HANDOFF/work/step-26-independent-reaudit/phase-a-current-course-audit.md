# STEP 26 — PHASE A · CURRENT-COURSE PEDAGOGY AUDIT

> Independent, read-only, full-course audit. Frozen BEFORE any historical
> Step-21–25 report was opened. All judgements below derive ONLY from the
> current learner-facing course, current standards, current learner-app,
> and the senior reference (for fidelity spot-checks only, not pedagogy).

- AUDITED_COMMIT: `9323e57` (branch `remediation/step25-m23-m29-derive-first`, worktree clean)
- COURSE_CONTENT_REVISION: `48f8f30f9cc62a22` (SHA-256 over 161 files: m01–m29 lessons + indexes)
- Senior reference: `c8eb860`, clean (read-only, verified)
- Audit coverage: 132 learner lessons + 29 milestone indexes — every file read by the audit team, every material finding independently verified by the auditor of record against the actual file text or the Flutter SDK.

## Audience model

Experienced programmer — Kotlin / Android / Jetpack Compose background, beginner in Dart AND Flutter. Android familiarity may accelerate; it must never substitute for Flutter teaching.

## Executive judgement

The course is **technically honest and mostly well-sequenced**, with genuinely strong concept teaching (streams, sealed models, event-vs-state, repository boundaries, DRE-as-project-choice framing, honesty about `NOT_PERFORMED` live checks). **It is not release-ready**: one lesson is sequentially broken (m12/02 instructs `context.watch<MenuViewModel>()` before any provider supplies it), and twelve lessons carry material weaknesses — non-compiling exercise answers, foreign-codebase exercise transplants, false Dart/Flutter claims in authoritative sections, an unrunnable experiment, and two transcription-peak late-course lessons where volume outruns the reasoning asks.

## Verified material defects (auditor-of-record confirmations)

| # | Site | Defect | Verification performed |
|---|------|--------|------------------------|
| 1 | `m12/02-read-vs-watch.md` | **PEDAGOGICAL_BLOCKER** — "Build it step by step" instructs `context.watch<MenuViewModel>()` + removal of `_viewModel` inside `_MenuScreenViewState`. At m12/02 the provider `ChangeNotifierProvider<MenuViewModel>` does not exist (it arrives in m12/03) → runtime `ProviderNotFoundException`; deleting `_viewModel` leaves `initState`/`dispose` dangling → analyze fails. The class `_MenuScreenView` itself is only created (by rename) in m12/03. The lesson claims `flutter analyze`/`test` "xanh" (L175). Read m12/01, m12/02, m12/03 in sequence — confirmed. |
| 2 | `m04/04` | **LEARNING_RISK** — Tự làm + answer key reference `PlayerProfile`, `UserStats`, `test/models/app_models_test.dart` (L301–339). None exist; the course teaches `UserProfileData` in `test/user_profile_data_test.dart`. Foreign transplant — cannot compile. Grep of m04 lessons + learner-app confirms. |
| 3 | `m08/04` | **LEARNING_RISK** — answer code uses `find.text('CHƠI')` (actual button text is `'BẮT ĐẦU CHƠI'`, used at L238/L246 in the same file) → `findsNothing` → tap throws; `await tester.pumpAndSettle()` (L345) on `MenuScreen` whose periodic ticker never settles — contradicting the lesson's own "Lỗi thường gặp" #4 (L300–305); `NavigatorObserver` demanded but never taught; `find.byType(ElevatedButton)` hint targets a widget the menu doesn't use; "6 widget test" claimed, 5 shown. Read L220–376 — confirmed. |
| 4 | `m09/04` | **LEARNING_RISK** — `answerCorrectly(tester, i)` used at L153 and claimed "đã có từ M08". Grep across all docs: defined NOWHERE. Test listing cannot compile. Also "+5 test" claimed, 4 shown. Confirmed. |
| 5 | `m10/04` | **LEARNING_RISK** — exercise answer expects `await store.reset()` → `await store.load()` → `isNull`, but the same lesson teaches `reset()` WRITES defaults via `setString(key, jsonEncode(defaults))` (L32–35, L341–342); `load()` returns non-nullable `UserProfileData`. Answer also uses phantom `ProfileStore()` no-arg ctor, `PlayerProfile(displayName:)`, key `'player_profile'` (real: `'user_profile'`). Triple-broken: compile + contract + self-contradiction of the reset≠absent distinction the body teaches 300 lines earlier. Confirmed. |
| 6 | `m11/03` | **LEARNING_RISK** — exercise answer calls `MenuViewModel()` no-arg + `vm.toggleSound()`; the lesson's own tests construct `MenuViewModel(store: await makeStore(const {}))` and `toggleSound` is a State-private method. Cannot compile. Confirmed against m11/01 L149, m11/03 L261–269. |
| 7 | `m14/02` | **LEARNING_RISK** — two false Dart claims in a CORE contract lesson: "`abstract interface class` = CHỈ chữ ký — không thân hàm, không ctor" (L41 — false: interface classes may declare ctors and member bodies) and "`extends UserProfileRepository` trên `abstract interface class` không compile" (L199 — false within the declaring library, and the course's own convention puts impl in the same file → `extends` compiles silently; the exercise's predicted analyzer error will not appear). Verified against dart.dev semantics. |
| 8 | `m20/01` | **LEARNING_RISK** — "Thử nghiệm" instructs changing the guard to `remaining > 0` and asks what `remaining` becomes — the printed `Wallet` (L114–136) has `usedCoupons`/`canUse`, no `remaining`/`_used`. Unrunnable anchor experiment. Read both sections — confirmed. |
| 9 | `m02/02` | **LEARNING_RISK** — "ConstrainedBox không const được vì constructor có assert" stated 3× (L68, L244, L319) including in "Lỗi thường gặp". SDK: `ConstrainedBox` ctor is indeed non-const, but asserts ARE legal in const ctors — `const BoxDecoration` in the same milestone has an assert. Teaches a false generalization ("assert kills const") learners will carry. SDK source verified. |
| 10 | `m02/03` | **LEARNING_RISK** — "`color:` và `gradient:` cùng trong `BoxDecoration` — analyzer/assert: chỉ một nền" (L410–411) invents a prohibition that does not exist; only the `backgroundBlendMode` assert remains — color+gradient is legal (color paints under gradient). SDK ctor verified. |
| 11 | `m03/03` | **LEARNING_RISK** — "gọi `setState` trong `initState` là lỗi" (L275) directly contradicts m03/02's (correct) "thừa, không lỗi" two lessons earlier. Internal contradiction on a lifecycle rule. Both texts verified. |
| 12 | `m28/05` | **LEARNING_RISK** — largest single-lesson transcription in the course (10 lib files + 5 test files verbatim, incl. the whole dialog-layer subsystem) with no derive prompt; two detail-probing exercises cannot carry the volume. Scaffold fading fails at the point independence should peak. |
| 13 | `m29/04` | **LEARNING_RISK** — 15-file verbatim batch + re-ports; the only derive prompt is naming-prediction, the weakest in the band. |

## FRICTION findings (localized, non-blocking individually)

- **m01/02** — non-const `MaterialApp` with all-const args (`title`, `debugShowCheckedModeBanner`, `home: const WelcomeScreen`) → `prefer_const_constructors` fires; lesson claims "No issues found!" and teaches that exact lint in Lỗi #1. Self-correcting but a false first-checkpoint claim.
- **m13/02** — `didChangeDependencies` described as "chạy sau frame build đầu" (L129, L291); it actually runs BEFORE the first build (after initState, when dependencies become available). Practical conclusion (subscribe there) is right; the timing claim is wrong.
- **m13/03** — scaffold retirement (`_soundOn`, `_playTapCount`, `_sessionTicker`, `menu_session_ticker.dart`) is *narrated* in a governance-flavored "ghi chú fidelity-remediation" note with no explicit learner-facing deletion steps/diff; learner files may retain them past M13 while later text presumes removal.
- **m23/02** — mental model (L114–131) reveals the `supabaseClient == null ? Disabled : Supabase` ternary + `main()` branch location BEFORE the derive block asks learners to derive the config matrix and branch point; derive partially pre-answered (Q1/Q3/Q5 still earn reasoning).
- **m29/07 capstone** — self-contained (`Capstone tự khép` note verified) and honest (NOT_PERFORMED block, 6/12 preview gap, release-kit-not-run), but the deliverable is a verbatim convergence sweep + parity checkboxes: no integrated design decision across state/events/ownership/deps/UI/lifecycle, no rubric. Final-independence evidence is weaker than the task requires.
- **Systemic governance noise (P11)** — registry IDs in learner-facing text/comments: `FR-20/FR-21` (m03/01), `FR-22` (m06/01), `FR-19` (m10/index, m14/05), `FD-09`/`D20`/`A-05`/`FR-15`/`FR-07`/`FR-08`/`FR-01`/`FR-04`/`FR-26` (M13–M15 band), `A-20` (m26/05), `A-35` (m27/01), `FR-27` inside ported comments the learner writes (m27/03 ×3, m27/04), `FR-33` (m27/05 ×2), six IDs in one diagram (m27/06), `A-38`/`D-48`/`F-38+F-39`/`A-39`/`F-41` (m28 band), `FR-31` inside a ported code comment (m29/02:344), `A-21`/`D-41` (m29/05, m29/03), "Argus"/"implementation-qa r1" agent names (m19/04:211, m19/05:197+466, m28/01:447), `EXPLAIN_ONLY` tag (m18/01), "Step-10" (m16/01), "gate PASS" checkpoints (m07/03, m08/04), "fidelity register"/"canonical sync"/"ACTIVE_TEMPORARY" vocabulary (m25/05, m28/index, m29/index, m10/04).
- **Broken prose / stripped-ID debris (~20 sites)** — duplicate headings: m16/02:373-376 (worst — a "Lỗi hay gặp" bullet spliced INTO the heading), m16/03:545, m16/04:499, m17/02:451, m17/03:370, m17/04:441, m19/02:491, m19/05:439, m20/02:645, m22/04:91; dangling `**`: m25/01:136, m28/02:71+80+93+101, m29/01:563; orphan fragments: m24/03:251, m24/04, m17/04:253, m27/05:326, m28/index:22-24+73-75+83+89, m29/index:33+49+50+55+119, m29/02:627, m29/04:347-348, m29/07:600+645, m26/index:221+263+414, m27/index:77.
- **Index misclaims (P12)** — m01/index (exercise described doesn't exist), m02/index ("banner đỏ-vàng" untaught), m03/index (`didChangeDependencies` listed as explainable — deferred), m04/index ("người chơi lên cấp" — wired `gainExp(10)` but cap 35000 makes level-up unreachable; `setUp` listed — deferred), m08/index (`GameResult` before m10/03; "6 test" vs 5), m09/index (`pop(result)` claimed — deferred to M10), m10/index (`FR-19`; loose reset wording), m12/index (MultiProvider attribution off), m17/index (`settingsFooterHint` vs actual `appTagline` + stray `)`), m26–m28 indexes (stripped-ID debris), m29/index (heaviest governance-saturated page + debris).
- **Concept-first-use leaks** — `String.fromCharCode`/`List.generate`/`firstWhere`/`fold` used in m19/03+ before their M20/02–03 registry teach; `jsonDecode`/`jsonEncode`/`Map.from`/`on FormatException`/`fromMap` in m10/01 code before m10/02's teaching (partially glossed); `late final` used m11/01 vs registry first-teach M16/03; `requestGame()`/event-bridge in m12/02's exercise table (M13 concepts); `PopScope` name-drop m18/01 before M19/05; `pumpEventQueue` in m14/03 exercise before m14/04 teach (glossed); `NavigatorObserver` untaught (m08/04); `ElevatedButton` hint points at widget the menu doesn't use (m08/04); `switch` attributed to "bài 2" though it debuts in m09/03 (m09/02+m09/03 prerequisites).
- **Count drift** — m08 (6 claimed/5 shown; "18 at start" arithmetic), m09/04 (+5 claimed/4 shown, missing CHƠI LẠI test), m19/06 npm-pagecount bookkeeping.
- **Answer-key convention drift** — M17/M18 self-check questions carry no answer keys; M16 uses `<details>`, M19/M20 inline.
- **m10/03** — imprecise claim that `pop(value)` on a `Route<void>` "sẽ ném/ép sai" — actually a compile-time type error (lesson table states it correctly).
- **m05/01** — test name "delay được tôn trọng (Duration.zero hoàn thành ngay)" never asserts timing.
- **m18/04** — second half of "Thử nghiệm" is non-actionable assertion.
- **m22/04** — `_saveGameResult`/`_applyLevelProgression` ported sight-unseen (instructed to transcribe from senior repo without the code shown).

## Band-level assessment

**M01–M05** — Concept teaching is sound (constraints, state models, async ordering, copyWith/equality are accurate and well-scaffolded; `gainExp` arithmetic verified). Damage concentrates in: three false/misleading claims in authoritative error lists (m02/02 const-assert rule, m02/03 color+gradient, m03/03 setState-initState), one phantom exercise (m04/04), four index overclaims. PREDICT-dominant exercises with genuine decisions and collapsed keys — good early scaffolding.

**M06–M10** — The strongest concept teaching in the early course (lazy streams, single-subscription `StateError` trap taught deliberately, timer ownership, phase machine, defensive JSON). Damage concentrates in exercise/test sections: m08/04 + m09/04 + m10/04 answers are broken or self-contradictory — all three in the "write your own test" layer where verifiability matters most. `answerCorrectly` is a phantom helper.

**M11–M15** — Best architecture sequencing in the course (manual lifecycle → Provider automates; manual state machine → streams; `abstract` events → sealed). Contains the single worst defect: m12/02 cannot be followed — it applies watch/read to a provider that doesn't exist until the next lesson and claims a green run. m11/03's answer doesn't compile; m14/02 teaches two false Dart rules; m13/03's scaffold removal is narrated not instructed.

**M16–M20** — Cleanest band: strong CORE teaching (dialog-scoped VMs, l10n pipeline, sealed step-states, lifeline Set-ledger, timer/flowToken guards), honest deferral marking, verified test arithmetic. One unrunnable experiment (m20/01), systemic duplicate-heading debris (9 sites), the M19↔M20 `firstWhere`/`fromCharCode` leak, three Argus-name governance leaks.

**M21–M25** — The derive-first interventions work where placed (m23/02, m24/02, m25/03 all have real pre-reveal design prompts with honest answer keys — the `username↔name` schema key and DRE variant names verified against learner code). Residual: partial answer-leak in m23/02's mental model; four sight-unseen/high-volume ports (m23/02 ~293 lines, m24/02 ~694, m24/05 ~948, m21/02 ~670); governance vocabulary concentrated in m25/05 + indexes.

**M26–M29** — DRE is consistently framed as project-local (verified — no universal-law violations). Honesty is exemplary (fake≠OS tables, six declared preview gaps, NOT_PERFORMED everywhere needed, passing-tests-≠-contract admissions in m28/02+m28/04). But the production act is transcription at the independence peak: derive prompts exist in ~1/3 of lessons and mostly before bounded slices; m28/05 and m29/04 are the worst exercise:volume ratios; the m29/07 capstone is honest and self-contained but rubric-free transcription. Governance noise and stripped-ID debris are heaviest in this band (m27/06, m28/index, m29/index).

## Course-arc answers

**FOLLOW→PREDICT→MODIFY→PRODUCE→DEBUG→DERIVE?** The distribution is healthy in shape (PREDICT 43, PRODUCE 45, MODIFY 9, DEBUG 18, DERIVE 7, RECOGNIZE 4, ~6 questions-only) and DEBUG appears exactly once guards/async exist to break (M18+). DERIVE appears only from m16/03 onward and in real force only in M23–M25 and scattered later tips. The arc exists but does not monotonically fade: M28–M29 reverts to heavy transcription.

**Sequential followability: FAIL** at one site (m12/02) plus ~6 sites of hidden-work (scaffold deletion not instructed, phantom helpers/classes, unverifiable exercises).

**Senior-hidden capstone: PARTIAL** — self-contained YES, rubric/integrated-decision NO.

**Android analogy safety: PASS** — every bridge audited carries a labeled difference; no unbounded equivalence found.

**Project-vs-Flutter boundary: PASS** — DRE, Provider-as-service-locator, repository-as-choice all explicitly bounded; no universal-law teaching found.

**NOT_PERFORMED honesty: PASS** — live-device/live-Supabase claims are consistently and accurately disclaimed.

## Phase A conclusion

- PEDAGOGICAL_BLOCKER: 1
- LEARNING_RISK findings: 13 (verified material defects listed above)
- FRICTION findings: ~45 discrete sites/groups
- NEEDS_ENRICHMENT lessons: 12 · REWRITE_REQUIRED: 1
- **Current-course judgement: NOT_RELEASE_READY_PEDAGOGY** — the blocker and the material risks are all localized and repairable with small targeted edits; none requires structural redesign.
