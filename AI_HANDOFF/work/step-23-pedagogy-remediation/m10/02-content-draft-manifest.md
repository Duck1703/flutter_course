# M10 — CONTENT DRAFT MANIFEST

CONTENT_REVISION: `29f20f18|2602c25c|5d943d08|9a8b5175`

| Lesson | Change type | CORE | Exercise level | Decision required | Verification |
|---|---|---|---|---|---|
| m10/01 | TỰ_LÀM | — | PREDICT | classify persisted-vs-runtime + name minimal persist change | restart app, compare |
| m10/02 | ISOLATED_EXAMPLE (JSON roundtrip) + TỰ_LÀM | D-15, D-16 | DEBUG | predict per-field fallback on corrupt map + 3 decode paths | DartPad `is`/`jsonDecode` |
| m10/03 | TỰ_LÀM | — | PREDICT | result on 6 return paths incl. popUntil counterfactual | trace against lesson wiring |
| m10/04 | NONE (existing exercise) | — | — | — | retained |

Exercise answer keys verified against actual M10 dialog-action +
`pop(result)` wiring (not M09's popUntil). Senior key-parity
`'user_profile'` untouched.
