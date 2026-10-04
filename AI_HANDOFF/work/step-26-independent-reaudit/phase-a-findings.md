# STEP 26 — PHASE A · FINDINGS REGISTER (frozen pre-history)

Levels: PEDAGOGICAL_BLOCKER > LEARNING_RISK > FRICTION > NOTE.
Every material finding was independently re-verified by the auditor of record
against the actual file text or the Flutter SDK — two agent-reported claims
were REFUTED and are recorded as such (m01/02 "no const ctor", m02/03
BorderRadius.circular, m04/index "no EXP wiring").

## BLOCKER

### F26-B-01 — m12/02 instructs `context.watch<MenuViewModel>()` before the provider exists
- Level: **PEDAGOGICAL_BLOCKER** · P1/P6/P12
- Evidence: "Build it step by step" (L96–158) applies `context.watch`/`context.read` on `MenuViewModel` inside `_MenuScreenViewState`. `ChangeNotifierProvider<MenuViewModel>` is only created in m12/03 (verified m12/03:115–119). `_MenuScreenView` itself is the M11 StatefulWidget renamed — in m12/03. Removing `_viewModel` (instructed L135) leaves `initState`/`dispose` dangling. L173–178 claims analyze/test "xanh".
- Learner impact: literal execution → `ProviderNotFoundException` at menu open (or analyze errors); learner blames themselves; the sequence physically cannot be followed.
- Why pedagogical: sequential-executability violation + false outcome claim — not style.
- Required outcome: learner can apply each instructed step at its position and get the claimed result.
- Remediation class: restructure ordering (keep `ListenableBuilder` until m12/03, or move provider creation earlier, or mark section explicitly as preview and drop the "xanh" claim).

## LEARNING_RISK (13)

### F26-R-02 — m04/04 exercise uses phantom classes
`PlayerProfile(displayName:, totalCoins:)`, `UserStats(gamesPlayed:, bestScore:)`, `test/models/app_models_test.dart` (L301–339) — none exist; course teaches `UserProfileData` in `test/user_profile_data_test.dart`. Answer cannot compile. → rewrite exercise against `UserProfileData`.

### F26-R-03 — m08/04 answer code is broken in three ways
`find.text('CHƠI')` (L344) never matches `'BẮT ĐẦU CHƠI'` (same file L238/246); `pumpAndSettle` (L345) never settles on MenuScreen's periodic ticker — contradicts own Lỗi #4 (L303–305); `NavigatorObserver`/`_RecordingObserver` required but never taught; `find.byType(ElevatedButton)` hint (L323) targets a widget the menu lacks; "6 widget test" claimed vs 5 shown. → fix finder + pumps + counts; teach or remove observer.

### F26-R-04 — m09/04 invokes undefined helper `answerCorrectly`
Used L153, claimed "đã có từ M08"; grep across all docs: defined nowhere. Test cannot compile. "+5 test" claimed, 4 shown (missing CHƠI LẠI). → define the helper inline or in m08/04; fix counts.

### F26-R-05 — m10/04 exercise contradicts its own contract and uses foreign API
Expects `reset()` → `load()` → `isNull` (L349–350, L372–378) while the body teaches `reset()` WRITES defaults (`setString(key, jsonEncode(defaults))`, L32–35, L341–342) — `load()` returns `UserProfileData`, never null, and the body explicitly distinguishes "chưa từng lưu" vs "đã reset" (L305–306). Answer also uses `ProfileStore()` no-arg, `PlayerProfile(displayName:)`, key `'player_profile'` (real: `'user_profile'`); hint claims `fromMap` has try/catch (it doesn't — try/catch is in `load`). → rewrite against real API; expect `equals(const UserProfileData())`.

### F26-R-06 — m11/03 exercise answer doesn't compile
`MenuViewModel()` no-arg + `vm.toggleSound()` (L261–276) vs actual `MenuViewModel({required ProfileStore store})` (m11/01:149) and no `toggleSound` on VM (State-private `_toggleSound`). → `MenuViewModel(store: await makeStore(const {}))` + a real method.

### F26-R-07 — m14/02 two false Dart claims in CORE contract lesson
L41 "`abstract interface class` — CHỈ chữ ký, không thân hàm, không ctor" (false: member bodies + ctors allowed); L199 "`extends` trên `abstract interface class` không compile" (false within declaring library — and the course's own convention puts impl in the same file → the exercise's predicted analyzer error never appears). → scope claims correctly ("extends fails OUTSIDE the contract's library"); reword member claim.

### F26-R-08 — m20/01 experiment references absent fields
"Thử nghiệm" (L166–174) instructs keeping `remaining > 0` and asks for `remaining`'s value — the printed `Wallet` (L114–136) has `usedCoupons`/`canUse`, no `remaining`/`_used`. → align experiment with shown code (e.g., remove `canUse`'s contains-check → second `use` succeeds silently).

### F26-R-09 — m02/02 teaches false const rule, stated authoritatively 3×
"ConstrainedBox không const được vì constructor có assert" (L68, L244, L319). Asserts are legal in const ctors — `const BoxDecoration` (same milestone) proves it. Right conclusion, false rule → durable wrong mental model. → "constructor của nó không được khai báo const" (optionally: the assert calls a non-const-evaluable method).

### F26-R-10 — m02/03 invents an analyzer/assert prohibition
"`color:` và `gradient:` cùng trong một `BoxDecoration` — analyzer/assert: chỉ một nền" (L410–411, L372). No such assert exists in current SDK (only backgroundBlendMode); color+gradient is legal. → reword to a practice rule: choose one for clarity; if both, gradient wins.

### F26-R-11 — m03/03 contradicts m03/02 on setState-in-initState
"gọi `setState` trong `initState` là lỗi" (L275) vs m03/02 L254–256 (correct) "thừa, không lỗi". → align to m03/02.

### F26-R-12 — m28/05 largest verbatim port has no derive prompt
10 lib files + 5 test files verbatim (incl. whole dialog layer); 2 detail exercises. → add a derive tip like m29/05's (enumerate dialog variants + dismiss-rule matrix before reveal).

### F26-R-13 — m29/04 fifteen-file verbatim batch, weakest derive prompt
Naming-prediction only before ~15 ported files + re-ports. → split batch or convert one cluster into derive-and-compare.

## FRICTION (selected — systemic groups enumerated)

- F26-F-01 m01/02: non-const `MaterialApp` with all-const args → `prefer_const_constructors` fires; "No issues found!" claim false (analyze still exits 0; info-level).
- F26-F-02 m13/02: `didChangeDependencies` "chạy sau frame build đầu" — actually runs BEFORE first build (L129, L291).
- F26-F-03 m13/03: scaffold removal (`_soundOn`/`_playTapCount`/`_sessionTicker`/`menu_session_ticker.dart`) narrated in governance-flavored note, no learner-facing deletion steps.
- F26-F-04 m17/04: duplicated heading L441 + orphaned fragment "không phải key ARB." L253.
- F26-F-05 m18/01: `EXPLAIN_ONLY` internal tag L91; PopScope named before M19/05.
- F26-F-06 m18/03: CORE VM ported verbatim; DEBUG exercise only mitigation.
- F26-F-07 m18/04: "Thử nghiệm" second half non-actionable.
- F26-F-08 m19/03: `String.fromCharCode`/`List.generate`/`clamp` used as "known" (L36, L296) — registry first-teach M20/02–03; no independent exercise for A-20.
- F26-F-09 m19/04: `firstWhere` in tests before M20/02; "Argus bắt được bug ở implementation-qa r1" L211.
- F26-F-10 m19/05: "Argus r1" references L197, L466 + dup heading L439.
- F26-F-11 m19/06: npm/docs-site page-count bookkeeping L40–41; DEBUG analysis shown inline.
- F26-F-12 m21/02: ~670-line port; pointer-semantics compressed; FR-32/FR-34 comment L125.
- F26-F-13 m21/04: atomic cut has no intermediate compile checkpoint.
- F26-F-14 m22/04: duplicated heading L91; `_saveGameResult`/`_applyLevelProgression` ported sight-unseen L225–229.
- F26-F-15 m23/02: mental model (L114–131) reveals ternary + `main()` branch before derive block asks for them — partial answer leak; ~293 lines ported sight-unseen; mid-sentence code-splitting throughout.
- F26-F-16 m23/05: same line-splitting formatting defect; least-derived lesson in M23.
- F26-F-17 m24/02: ~694 verbatim lines (impl + google + apple + fake) in one sitting; derive block itself is strong; suggest splitting Apple.
- F26-F-18 m24/04: FR-28 comment L246; five edit surfaces.
- F26-F-19 m24/05: ~948-line widget port with fragments-only visibility; FR-28 L185.
- F26-F-20 m25/01: dangling `**` L136; line-splitting formatting.
- F26-F-21 m25/04: FR-36 comments; line-splitting formatting.
- F26-F-22 m25/05: "fidelity register"/"truy vết register"/FR-36 in objectives + test names — heaviest governance vocabulary in band.
- F26-F-23 m26/02: 97-line dispatch core revealed before any learner derivation (minor).
- F26-F-24 m26/04: guard-placement design revealed without derive step (minor).
- F26-F-25 m26/05: "(mapper A-20)" registry ID in learner diagram L79.
- F26-F-26 m26/06: "fidelity register" + mangled FR debris L22–24, L49–50.
- F26-F-27 m27/03: `FR-27` IDs inside comments the learner is told to write (L324, L404, L479); mangled "residual ở → M29/M30".
- F26-F-28 m27/05: FR-33 ×2; mangled "visual parity là **/ → M28**" L326.
- F26-F-29 m27/06: six registry IDs in ONE learner diagram (~L56–73) + stripped-ID wreckage L155–157, L270–272 — worst single noise site in course.
- F26-F-30 m03/01: SENIOR_FIDELITY_REGISTER FR-20/FR-21 + TEACHING SCAFFOLD jargon L155–188.
- F26-F-31 m06/01: FR-22 inside learner-facing scaffold box L153.
- F26-F-32 m07/03: "M07 gate PASS" L195.
- F26-F-33 m09/02: attributes `switch` to "bài 1/M08" — first switch is m09/03 (also m09/03 L33).
- F26-F-34 m10/01: `jsonDecode`/`jsonEncode`/`Map.from`/`on FormatException`/`fromMap` used before m10/02 teach (partially glossed).
- F26-F-35 m10/03: "route `MaterialPageRoute<void>` pop kèm giá trị sẽ ném" — actually compile-time error (own table correct).
- F26-F-36 m14/05: heavy load (model + 2 repos + `?`-element + 5 parse helpers); FR-19/26/01 ×5.
- F26-F-37 m14/07: FR-04/08/15 + "chuỗi cũ…remediation" meta-commentary L101–265.
- F26-F-38 m16/02: heading splice L373–376 — bullet text embedded in duplicated heading.
- F26-F-38b m28/02: stripped-ID debris L71/80/93/101 + "chưa có registry row" L63 + "Và `if-case` :" orphan.
- F26-F-39 m17/01 (+m18/01): self-check questions carry no answer keys; convention drift vs M16 `<details>`.
- F26-F-39b m28/06: 13-file transplant; atomic-swap ordering senior's — never derived (kept ACCEPTABLE: compile-forced ordering IS the taught concept).
- F26-F-40 m29/02: `FR-31` inside ported code comment L344; "Mục fidelity" L55; decomposition revealed before produce-alternative.
- F26-F-41 m29/07: capstone = verbatim convergence sweep + parity checkboxes; no rubric, no integrated design decision (self-contained + honest otherwise — verified `Capstone tự khép` note L210–218).
- Index FRICTION: F26-F-42 m01 (exercise misdescribed); F26-F-43 m02 ("banner đỏ-vàng" untaught); F26-F-44 m03 (didChangeDependencies listed); F26-F-45 m04 ("lên cấp" unreachable + `setUp` deferred) → NEEDS_ENRICHMENT; F26-F-46 m07 ("D20" token); F26-F-47 m08 (GameResult forward-ref + count); F26-F-48 m09 (pop(result) claimed); F26-F-49 m10 (FR-19 + reset wording); F26-F-50 m12 (MultiProvider attribution); F26-F-51 m14 (revision-history narration + FR-19); F26-F-52 m17 (`settingsFooterHint` vs `appTagline` + stray paren); F26-F-53 m26 (stripped-ID debris); F26-F-54 m27 (debris); F26-F-55 m28 (mangled FR row + debris — worst index debris); F26-F-56 m29 (heaviest governance-saturated page + debris) → NEEDS_ENRICHMENT.

## NOTE (non-blocking)
- F26-N-40..74: minor leaks/drifts — m02/01 Container-before-taught; m04/01 "đã đăng ký" phrasing; m05/01 test-name overclaim; m05/02 self-referential "(xem bài M05…)"; m09/03 L33 switch-attribution; m11/01 `late final` gloss vs registry M16/03; m12/03 DECISIONS mention; m13/01+m13/02+m13/index D20; m15/04+m15/05+m15/index FR-15/A-05/FR-07; m16/01 "Step-10"; m16/03+m16/04+m17/02+m17/03+m17/04+m19/02+m19/05+m20/02 duplicated headings; m19/01 OrderMachine printed-not-produced; m20/03 Tự làm inside hint box; m20/05 inline answers; m22/01 truncated "(M11 — )" L58; m22/02 FR-01/03 L80; m23/01 "registry" jargon; m23/03+m23/04 truncated citations; m24/01 "allow-list"; m27/01 A-35 comment; m27/04 A-24+FR-27; m28/01 "Argus" L447 + registry-row ×3; m29/01+m29/03+m29/05 mangled prose/IDs; m24/m25 indexes parity counters; m13/m15 indexes D20/FR.

## Rejected prior-agent claims (verified against SDK/files)
- "MaterialApp has no const ctor" → FALSE (has one); lesson's runtime-params rationale is defensible — residual defect is only the lint-vs-"No issues found" mismatch (F26-F-01).
- "BorderRadius.circular not const is a false claim" → FALSE: SDK ctor is genuinely non-const (`BorderRadius.circular(...) : this.all(...)`) — the lesson is correct; no finding.
- "m04/index invents EXP/level wiring" → FALSE: m04/03 wires `gainExp(10)` on tap — residual is only the unreachable level-up overclaim (F26-F-45).
