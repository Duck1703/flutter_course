# M22 — CONTENT QA (Argus round 1 + remediation)

## Round 1 verdict: FAIL → remediated

Argus independently reviewed `lessons/` + `04-content-draft.md` against
learner-app code, senior source, and content standards. Verdict FAIL
with 4 blockers, 6 minors, 5 nits. All fixed; reverify dispatched.

## Blockers fixed

- **B1 — fabricated senior symbol `_finalVictory`.** Senior has no
  such method; real call site is the victory branch of
  `_loadNextQuestionOrVictory` (`game_reducer_session_flow.dart:46–65`).
  Fixed in 4 places: `lessons/01` table, `lessons/05` parity table,
  `01-brief.md` call-site row, and the shipped learner comment at
  `game_screen_view_model.dart:448`.
- **B2 — stale `test/_diag_test.dart`.** Debug leftover constructing
  `GameScreenViewModel` without required `userProfileRepository` —
  broke `flutter analyze`. Deleted; suite is exactly **168** and
  analyze clean.
- **B3 — `dart test` ×2** (`lessons/02`, `lessons/03`) → `flutter test`
  (`flutter_test` needs dart:ui; `dart test` cannot run them).
- **B4 — `index.md` missing mandated tail.** Added
  "Điều milestone này cố ý chưa làm" (M24/25/26/27/28 items),
  "Checkpoint tổng kết", "Tổng kết milestone (synthesis)" with the
  5-question form; also expanded the multiplier summary to the full
  table (×2/×4/×5 milestones included).

## Minors fixed

- **M1** L05 grep-verification reworded — real output is ~16 hits of
  milestone-tagged comments + 2 new method names + 2 intentional local
  vars (`expForNextLevel` in `_applyLevelProgression`, `expPercent`
  in `_LevelCard`); claim now matches reality.
- **M2** "port verbatim" drift — L02 `LevelConfig` and L03
  `MenuLevelProgress` code blocks replaced with byte-exact file
  content; L03 `_LevelCard` snippet now quotes real on-disk comments
  (the invented comment removed); L04 `hasSavedResult` doc synced to
  `game_session_state_data.dart:296–302`. Also fixed a 3-space doc
  indent on that field while there.
- **M3** Android/Compose 3-line bridges added to L02 (Kotlin `object`
  + `mapOf`), L03 (`derivedStateOf` / computed props vs immutable
  derived view), L04 (`viewModelScope.launch` vs `unawaited` +
  in-state flag).
- **M4** dropped template sections declared in `04-content-draft.md`
  (self-check folded into Checkpoints; "Lỗi hay gặp" inline).
- **M5** stale `menu_view_model.dart:28` comment naming retired
  `applyGameResult` → reworded to "save của game VM".
- **M6** L04 file count: "bảy file" → "7 sửa + 1 xoá" (8 paths).

## Nits fixed

- `index.md` multiplier summary → full table.
- `00-status.md` Lumen row → DONE.
- `04-vm-save-mot-lan.md` internal `02-implementation.md` reference →
  senior path only.
- `05` `-n` filter narrowed to `"TRƯỚC"`.
- `01-brief.md` formula now notes `multiplier(level+1)`.

## Post-remediation verification

- `flutter analyze` — clean.
- `flutter test` — **168/168**.
- Senior untouched (`main@c8eb860`).

## Round 2 (reverify): NEW-1 + nit-α → fixed

Argus reverify confirmed all 15 remediations but flagged one new
substantive issue:

- **NEW-1 — L04 DEBUG planted bug was unobservable.** Guard read
  `next.hasSavedResult` — but `copyWith` propagates the flag, so
  `next.hasSavedResult ≡ _state.hasSavedResult`; order swap likewise
  invisible. The claimed red test would have stayed green. Rewrote
  the exercise: bug now emits `next` *without* `copyWith(hasSavedResult:
  true)` → flag never set → `backToMenu` after `_endGame` double-saves
  → `saveCallCount == 2` (verified by trace; matches the real tests
  `gameOver rồi backToMenu → hasSavedResult chặn save lần 2` and
  `…KHÔNG save lần 2`). Lesson takeaway preserved (flag must be
  written into emitted state).
- **nit-α** — grep count `~16` → exact **17**.
- nit-β (`_finalVictory` inside this file's own finding record) —
  intentional, kept.
- `lib/data/game/game_result.dart` deletion confirmed by directory
  listing (file absent).

## Round 3 (reverify): NEW-2 → fixed

- **NEW-2a** — the DEBUG answer originally named 2 red tests; the
  planted bug actually turns **3** red, and the most diagnostic one
  (`thua câu 2 → save 1 lần…`, which asserts `vm.state.hasSavedResult`
  `isTrue` directly) was omitted. Answer now enumerates all three,
  flag-assert called out as the earliest failure.
- **NEW-2b** — paraphrased test name replaced with the verbatim
  `thoát giữa ván sau safe haven → backToMenu save walkAway amount
  + stats; gọi lại → vẫn 1 lần`.

## Round 4 (reverify): cross-file stale refs → fixed

Lesson file itself verified correct; Argus sweep caught 3 stale
references to the OLD (pre-NEW-1) exercise outside it:

- `04-content-draft.md` L04 exercise cell → now describes the
  "quên set cờ" bug.
- `index.md` synthesis #3 → "DEBUG quên-set-cờ (Bài 4)".
- `index.md` synthesis #4 → the `đọc cờ trên next` counterfactual
  (provably false — copyWith propagates) replaced with the true
  one; synthesis #2 reworded to "check state hiện hành VÀ ghi cờ
  vào state đã emit".
