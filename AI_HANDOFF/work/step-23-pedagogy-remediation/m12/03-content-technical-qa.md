# M12 — CONTENT TECHNICAL QA (Argus)

CONTENT_REVISION: `130f664d|c1c4b0c5|279597dc`
CONTENT_TECHNICAL_QA: **PASS**
SENIOR_FIDELITY_CHANGED: NO

## Gate results

| Gate | Result | Evidence |
|---|---|---|
| G1 scope | PASS | `m12/{01,02}.md` only; additive |
| G7 snippet truth | PASS | `UserScope` example reviewed: `InheritedWidget` subclass, `of()` via `dependOnInheritedWidgetOfExactType`, `updateShouldNotify` comparing `name` — correct raw API. Answers verified: (A) build-above-provider → `ProviderNotFoundException` — correct (context sits above the provider); (B)(C) watch inside build below provider → OK; (D) `watch` in `onTap` → throws — correct (Provider forbids watch outside build). m12/02 answer table verified: 1/4 watch, 2/3/5 read — matches lesson's own usage; watch-in-onPressed → exception (fail-fast) — correct Provider semantics |
| G8/G9 mechanism | PASS | lookup-only-up, dependency-registration-at-build-time, no-replay claims all accurate |
| G10 first-appearance | PASS | `read`/`watch`/provider APIs are this milestone's subjects; `dependOnInheritedWidgetOfExactType` is the lesson's own underlying mechanism (referenced in text); no `sealed`, no repository, no events |
| G24 executability | PASS | DartPad-Flutter runnable (only material import); predictions verifiable in app |
| G15 scaffold | PASS | no MultiProvider/repo/events added to example |
| G16 senior | PASS | screen-wraps-provider rationale and `didChangeDependencies` read-pattern cites consistent with senior `_MenuScreenEventBridge` |

## Findings

None. `PASS`.
