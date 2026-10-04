# M04 — CONTENT TECHNICAL QA (Argus)

CONTENT_REVISION: `9d39a9cb|a2ac0f67|399d0e66|b7110f6d`
CONTENT_TECHNICAL_QA: **PASS**
SENIOR_FIDELITY_CHANGED: NO

## Gate results

| Gate | Result | Evidence |
|---|---|---|
| G1 scope | PASS | `m04/{01,02,03}.md` only; additive |
| G7 snippet truth | PASS | `Badge`: valid pure Dart — `required`+default+nullable-param combos all compile; outputs verified (`a.tier`=1, `a.note`=null, `??` fallbacks). `Wallet`: canonicalization claim verified — two identical `const` do canonicalize to one instance; non-const `Wallet(coins:5)` vs `a` → identity `false` (default `Object.==`), correct. `MatchTicket` solution compiles; missing `code` → compile error "required named parameter 'code' must be provided" — exact analyzer message class correct. `spendExp` uses `copyWith` + `var`/`if` — all taught |
| G8/G9 mechanism claims | PASS | `gainExp` field-touch list verified against lesson code (`currentExp`,`level`,`expForNextLevel` only); `expPercent` formula `currentExp*100~/35000` and `winRateDisplay` `'—'` guard match bài-2 code; `_PlayButton` reads `tapCount` (State field) — all 5 predictions correct |
| G10 first-appearance | PASS | No untaught syntax in examples (`if`/`var`/`print`/`??`/named params all taught by M04). No `fromMap`, no `!.`/`?.`, no test API |
| G24 executability | PASS | DartPad exercises need no app state; m04/03 PREDICT uses existing `_onPlayTap` behavior (M04 file state) — read-only observation |
| G15 scaffold | PASS | `expForNextLevel` M22-retirement notes preserved verbatim; senior `'0XFF'`/35000 parity notes untouched |
| G16 senior | PASS | All senior citations (`user_profile_data.dart`, repository `!=` guard, menu card paths) unchanged |

## Findings

None. `PASS`.
