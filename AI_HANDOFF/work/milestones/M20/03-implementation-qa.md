# M20 — Implementation QA (Argus, independent)

Reviewer: Argus subagent (read-only vs authoring context; ran commands
itself). Scope: learner-app M20 lifelines vs senior `@c8eb860`.

## Commands actually run (reproduced)

| Command | Claimed | Observed |
|---|---|---|
| `flutter analyze` | clean | `No issues found!` ✓ |
| `flutter test` | 147/147 | `+147: All tests passed!` — exactly 147 ✓ (helper 5, VM 27, mapper 6, widget 14, sealed 5) |
| `flutter build web --release` | Built | `√ Built build\web` (42.4s) ✓ |
| senior repo | `c8eb860` clean | HEAD = `c8eb860ed9f4…`, `git status` empty ✓ |

## Senior fidelity (diffed symbol-by-symbol — all hold)

- `applyGameFiftyFifty` verbatim (correct + FIRST wrong kept, rest
  blanked, non-growable, no `Random`).
- `buildGameAudiencePoll` verbatim (68/52/42; `_splitWrongAudience`
  50%/32%/rest; sum 100).
- `buildGameAudiencePollItems` verbatim (null→`0%`).
- `_canUseFeature` order verbatim: phase gate → walkAway amount>0 →
  exitGame true → `!used.contains`.
- Single-use writes: exactly 3 lifelines; walkAway/exit excluded.
- AI flow: immediate loading + `flowToken+1` + used-flag + 700ms;
  result applied only if `dialogState is GameAIAssistantDialog`
  (≡ senior guard); result = correctOption + 85% + `aiHintMessage`.
- Walk-away: gate `playing && _walkAwayAmount>0` → confirm dialog →
  `phase:victory`, `remainingTime:0`, `GameVictoryDialog`, recorded
  `resolvedResult{won:false, earned:amount, questionsAnswered:i+1}` ≡
  senior `_confirmWalkAway`.
- Exit NOT in bottom bar (mapper emits 3 + walkAway iff `canWalkAway`);
  ✕/back only — senior-true.
- Blanked options triple-guarded: mapper `isEmpty→idle` first, widget
  `onTap:null`, VM `answerText.isEmpty` — ≡ senior.
- Reset semantics: `visibleOptionTexts`/`audiencePercentiles` per
  question; `usedFeatureButtons` per game — ≡ senior.
- Back routing ≡ senior; new dialogs ride generic dismiss→resume.
- l10n: all 12 keys byte-identical to senior, both locales.
- Regression: all 126 M19 tests pass inside 147; mid-game exit →
  profile transport intact; no weakened assertions; AI-late-result
  test genuinely exercises the dismissed-dialog guard.
- Forbidden scope: none — no DRE, no in-Stack layer, no network, no
  `share_plus`/`flutter_svg`; senior repo untouched.

## Findings

1. **MINOR (non-blocking)** — FR-34 register row missing from
   `project-context/SENIOR_FIDELITY_REGISTER.md` (ends at FR-32) while
   brief/evidence reference it. Deviation itself is registered in
   milestone artifacts + tagged in code (`game_screen_data.dart:114`,
   `mapper:128`, `game_screen.dart:555-558`) — bookkeeping fix; append
   FR-34 (flat IconData buttons → senior SVG/`CustomPainter`, M20→M28,
   ACTIVE_TEMPORARY) before Atlas approval.
2. **NIT** — `game_screen.dart:86-88`: `notStarted && Hidden →
   startNewGame()` post-frame arm unreachable (first `build` throws
   `RangeError` before it can fire); only the missed-event recovery arm
   is live. Harmless dead code.
3. **NIT** — ✕ `IconButton` uses `tooltip: title`; senior uses
   `semanticLabel: l10n.exitGameSemanticLabel`. Key exists; wire it.
4. **NIT** — `game_session_state_data.dart:33` comment overcount
   ("9 variant (10 lớp kể cả hidden)" — family is 9 subclasses
   *including* hidden).
5. **NIT** — `buildGameAudiencePollItems` referenced only by its test
   in learner code; senior likewise (previews). Faithful dead port.

## Verdict

**VERDICT: PASS** — zero blocking findings; senior semantics verbatim
where claimed; all commands reproduce; every deviation permitted by the
brief and labeled in code. FR-34 row should be appended before Atlas
approval but does not gate this stage.
