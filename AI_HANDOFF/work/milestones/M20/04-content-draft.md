# M20 — CONTENT DRAFT MANIFEST (Lumen)

## Intake gate

`IMPLEMENTATION_APPROVED` confirmed — `04-implementation-approval.md`
on disk after Argus impl QA PASS + remediation (FR-34 register row,
dead-arm removal, semanticLabel, comment). Learner app verified:
`flutter analyze` clean, `flutter test` **147/147**, `flutter build
web` pass. Senior unchanged (`main@c8eb860`).

## Lessons authored (5 + index)

| File | Concepts | Exercise |
|---|---|---|
| `index.md` | milestone map + result summary + deferred list | — |
| `01-lifeline-la-luat-game.md` | **D-35** `Set<T>` state (CORE home); `GameFeatureButtonType`; `_canUseFeature` order; `Wallet` isolated example | comprehension checkpoint |
| `02-du-lieu-va-helper-lifeline.md` | **D-36** `firstWhere`/`{for}`/`fromCharCode`/`List.generate`/`fold`; `GameAudiencePollItemData` + `GameFeatureButtonData`; `audiencePercentile` + new `copyWith`; 4 state fields + clear flags; helper verbatim + tests; ARB +12 | helper unit tests (5) |
| `03-nam-muoi-nam-muoi-va-hoi-khan-gia.md` | **F-28** `LinearProgressIndicator`/`AnimatedOpacity`/`Semantics`/`IconData`-as-data; mapper `featureButtons`/`visibleOptionTexts`; `handleFeatureClick`/`_canUseFeature`; triple blank-guard; staged 2-button bar | Tự làm (advisory): merge ✕→handleFeatureClick? (answer: no — different guards) |
| `04-hoi-ai-va-dung-cuoc-choi.md` | staged dialog emit (one route two forms); `_GameDialogHost` ListenableBuilder live-read; `resolvedResult` chốt-at-transition; walk-away `won:false`; AI 700ms | Tự làm PREDICT: AI double-tap/close-mid-load trace |
| `05-tests-regression-tu-lam.md` | test pyramid map; DEBUG forgotten-used-write; **PRODUCE** lifeline-6 skeleton | PRODUCE + PREDICT + DEBUG |

## Registry / graph updates (done before QA)

- `LEARNER_CONCEPT_REGISTRY.md`: +D-35 (CORE, M20/01), +D-36
  (NORMAL, M20/02–03), +F-28 (NORMAL, M20/03) — all TAUGHT.
- `PREREQUISITE_GRAPH.md`: M20 section appended (edges M19 machine
  + D-35/D-36/F-28; feeds M21/M22/M26/M28).
- `SENIOR_FIDELITY_REGISTER.md`: FR-34 row (Flux remediation,
  pre-approval).

## Depth assignments (per brief Learning Design Check)

- CORE: D-35 (L01) — isolated `Wallet` example + mental-model +
  bridge + checkpoint. Only new CORE this milestone.
- NORMAL: D-36 (L02), F-28 (L03).
- Reuse: A-20 mapper, A-18 phase guard, D-33 `flowToken`/timer,
  D-34 clear flags, F-16 `ListenableBuilder` (new application:
  inside `showDialog` route), F-25/D-31 l10n.

≤3 major new concepts per page: L01=1 (D-35), L02=1 (D-36+mechanical
data), L03=2 (F-28 + mapper/VM wiring — wiring is reuse of A-20),
L04=1 (staged dialog semantics; `resolvedResult` is D-34 extension),
L05=0 new.

## Checkpoint arithmetic (honest, from M19 final 126)

| Lesson end | Count | Delta |
|---|---|---|
| L02 | **131** | +5 helper tests |
| L03 | **141** | +6 VM (guards 2, fiftyFifty 2, poll 2) +2 mapper +2 widget (bar+50:50, poll) |
| L04 | **147** | +4 VM (AI 2, walkAway 2) +2 widget (AI, walkAway); mapper test upgraded to 4-button assert |
| L05 | **147** | recap + exercises + `flutter build web` |

## Sequential-staging notes (G24 honesty)

- L02 lands data-only: `featureButtons` field on `GameScreenData`
  is **deliberately deferred to L03** (required param would break
  the M19 mapper mid-lesson; lesson documents this explicitly).
- L03's `_buildFeatureButtons` emits **2 buttons** (fiftyFifty +
  audiencePoll); `handleFeatureClick` switch has 2 `break` stubs
  for aiAssistant/walkAway with `// Bài 4 nối`. L04 adds both +
  `canWalkAway` gating + updates the mapper/widget bar test
  (auto_awesome `findsNothing`→`findsOneWidget`).
- `submitAnswer` `isEmpty` guard **already exists from M19**
  (ported verbatim with `_submitAnswer`); L03 step (d) instructs
  the learner to *verify* it, not add it. `resolvedResult` fields
  are inert until L04 wires writers.
- Test helper change `..startNewGame()` belongs to L03 (first
  point where `screenData` indexes `visibleOptionTexts`).
- **Sealed variant staging (post-QA-r1 fix):** `GameDialogState`
  is sealed → adding a variant without its `_title`/`_content`/
  `_actions` arms is an immediate compile error (no `_` arm).
  Therefore variants land **with their UI**: L02 gets only the
  plain `GameAudiencePollItemData` class (non-sealed, additive);
  L03 adds `GameAudiencePollDialog` + its 3 arms + sealed-test
  arm (7 variants); L04 adds `GameConfirmWalkAwayDialog` +
  `GameAIAssistantDialog` + their arms (9 variants). L02 stays
  analyze-clean as promised.

## Declared section merges/drops (template V2)

- L01 (theory): drops step-by-step build + Tự làm — no code
  changes; keeps mental model + isolated `Wallet` + bridge +
  senior connection + comprehension checkpoint.
- L02: `Mental model mới` kept (Map-keyed-by-text); `Thử nghiệm`
  kept (fold-invariant predict); `Tự làm` folded — mechanical
  data+helper step whose check is analyze+131 tests.
- L03: `Ví dụ độc lập` folded (50:50 bar interaction *is* the
  runnable check); keeps bridge + senior connection + `Thử
  nghiệm` + mistakes + caution (injected-VM start) + Tự làm +
  checkpoint (141).
- L04: `Ví dụ độc lập` folded (staged dialog only exists in-app);
  keeps bridge + senior connection + `Thử nghiệm` + mental-model
  + Dart table + full code + traps + Tự làm + checkpoint (147).
- L05 (synthesis, LIGHT): merges mental-model into test-map
  table; drops `Thử nghiệm`/`Lỗi hay gặp`/bridge — its PREDICT
  section *is* the experiment and the bridge would be redundant
  at wrap-up; keeps PRODUCE + PREDICT + DEBUG + regression +
  checkpoint.

## Scaffolding declarations

- `showDialog` interim → **M21** in-Stack `GameDialogLayer`
  (FR-07); declared in L01/L04/index.
- Flat `IconData` feature buttons (no painter/SVG) — **FR-34 →
  M28**; declared in L03 caution + index.
- `ChangeNotifier` VM (no DRE) → **M26**; declared in L01/index.
- `resolvedResult` interim carrier for route-pop transport →
  **M22** (FR-04); declared in L04/index.
- Simulated AI is **senior's real behavior** (no network ever);
  declared honestly in index `:::note` — not a simplification.
- `GameShareResultEvent` unassigned (FR-33); named in L05/index.

## Senior evidence references used

- `reducer/game_reducer_feature_flow.dart` (dispatch, `_canUseFeature`
  order, `_showAIAssistant` 700ms + dialog-type guard, used-writes)
- `support/game_lifeline_helper.dart` (verbatim 3 functions)
- `dre/game_dre_state.dart` (`GameState` lifeline fields)
- `data/game/game_screen_data.dart` (enum + button DTO)
- `game_screen_presentation_mapper.dart` (`_buildAnswers`/
  `_answerState`/`_buildFeatureButtons`, exit excluded)
- `bridge/game_screen_view_model_effects.dart` (dialog events)
- `widgets/game/lifelines/*` (bar/button/poll-row shapes; FR-34
  simplification source)
- `widgets/game/dialogs/game_help_dialogs.dart` + `game_confirm_dialogs.dart`
  (AI loading has no action button; walk-away body = confirm shape)
- `l10n/app_{en,vi}.arb` (12 keys byte-identical)

## Content-author self-check

- [x] Every "Bạn đã biết gì" cites taught registry IDs only.
- [x] Code snippets diffed against disk (VM methods, mapper,
      dialog arms, tests) — verified during authoring.
- [x] Checkpoints sequential: L02 131 / L03 141 / L04 147.
- [x] Scaffolds marked with caution + convergence milestone.
- [x] ≥1 PRODUCE exercise (L05 lifeline-6) + PREDICT + DEBUG.
- [x] No M21/M22/M26 scope taught as present.

## Contract coverage — remaining sections (§§2,4,5,6,7,10)

**Per-lesson learning goals** (đoạn `## Mục tiêu` của từng bài):
- L01: giải thích được lifeline-là-luat-game + mental model Set
  dùng-một-lần; chưa code.
- L02: viết được 4 field state + item/DTO + helper thuần verbatim
  + test helper; app không đổi hành vi.
- L03: wire 50:50 + poll xuyên mapper→VM→screen; bar 2 nút,
  ô trống ba-lớp-guard.
- L04: AI staged-dialog (một route hai hình, ListenableBuilder
  host) + walk-away `won:false` qua `resolvedResult`.
- L05: tự viết test + skeleton lifeline-6; regression toàn suite.

**Per-lesson prerequisites** (`## Bạn đã biết gì` → registry IDs):
- L01: D-34 (copyWith/clear*), D-27/A-14 (sealed), D-31/F-25 (ARB).
- L02: D-34, D-35 (Bài 1), D-15 map-literal, D-32 unmodifiable.
- L03: D-36 (Bài 2), D-33 (`flowToken`/`_schedule`), F-16
  `ListenableBuilder`, A-20 mapper pipeline.
- L04: D-33 (delay+token), D-17 `unawaited` (M11 — không phải M19),
  F-16 `ListenableBuilder`, A-18 phase guard.
- L05: toàn bộ M20 — synthesis, không concept mới.

**≤30-line incremental confirmation:** mọi `## Build it step by
step` block trong L02–L04 ≤ ~30 dòng code mỗi step (variant blocks
được tách riêng theo UI của chúng; mapper/VM/screen mỗi step một
file). Đoạn dài nhất: `_GameFeatureButton` widget ~50 dòng trong
L03 step 5(c) — được chừa làm một block vì nó là một widget hoàn
chỉnh (template cho phép "thêm widget mới" là một step).

**Code-explanation coverage:** mọi đoạn code trong L02–L04 đều có
prose giải thích ngay sau (Hiểu code / bullet "Hai điểm đáng đọc
kỹ" / bảng guard→hỏng). First-appearance APIs được đặt tên trong
bảng Dart/Flutter cần dùng (`firstWhere`, `{for}`, `fromCharCode`,
`List.generate`, `fold`, `LinearProgressIndicator`,
`AnimatedOpacity`, `Semantics`, `IconData`-as-data,
`find.descendant`).

**Per-lesson Android/Compose bridge:** L01 (Set↔Kotlin Set,
viewModelScope↔token-guard), L02 (sealed↔sealed-interface+when,
Map-text-keyed, IconData≠@DrawableRes), L03 (LinearProgressIndicator
↔Compose, AnimatedOpacity↔animateFloatAsState, Semantics↔semantics,
charCode label là senior-riêng), L04 (delay+token↔coroutine+
viewModelScope, victory-phase≠won). L05 (LIGHT): bridge gộp — mọi
API trong bài đã bridge ở L02–L04.

**Per-lesson common mistakes** (`## Lỗi hay gặp`): L02 ×4 (import
thiếu, featureButtons sớm, Random cho 50:50, quên Map.unmodifiable);
L03 ×5 (RangeError VM chưa start, shrink ô trống, Set.add runtime
error, reset used-set sai, firstWhere StateError); L04 (emit thứ
hai kèm event, …). L01/L05 là theory/synthesis — traps nằm trong
Checkpoint (L01) và DEBUG/PRODUCE (L05).

## Notes for QA

- Brief had planned IDs "F-29" + new "A-20 (simulated async)";
  execution resolved to **D-35/D-36/F-28** (registry) and A-20
  stays an M19 reused concept — execution choice, not a miss.
- Staging redesign (variants-with-arms) applied after QA r1;
  L02 checkpoint (131) + L03 (141) + L04 (147) arithmetic
  unchanged — sealed-test updates are *modifications*, not adds.
