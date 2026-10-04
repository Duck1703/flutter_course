# M12 — CONTENT DRAFT MANIFEST

CONTENT_REVISION: `130f664d|c1c4b0c5|279597dc`

| Lesson | Change type | CORE | Exercise level | Decision required | Verification |
|---|---|---|---|---|---|
| m12/01 | ISOLATED_EXAMPLE (hand-rolled InheritedWidget, ~65 lines, zero packages) + TỰ_LÀM | F-17 | PREDICT | lookup outcome × position + build-vs-callback legality | DartPad / trace tree |
| m12/02 | TỰ_LÀM | F-18 | RECOGNIZE+PREDICT | read-vs-watch at 5 call-sites + predict watch-in-callback failure | app behavior / Provider error |
| m12/03 | NONE (existing exercise) | — | — | — | retained |

Hand-rolled example chosen over a `package:provider` snippet: zero
dependency, runnable in DartPad, exposes the mechanism Provider wraps.
