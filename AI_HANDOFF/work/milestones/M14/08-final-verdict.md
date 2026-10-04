# M14 — Final Verdict (Atlas)

Milestone: M14 — Repository contracts & rxdart BehaviorSubject
Decided by: Atlas · Date: 2026-10-02

## Verdict: MILESTONE_COMPLETE

## Gate summary

| Gate | Result | Artifact |
|---|---|---|
| Implementation QA | PASS r1 | `03-implementation-qa.md` |
| IMPLEMENTATION_APPROVED | issued | `00-status.md` log |
| Content QA | PASS r1 | `05-content-qa.md` |
| CONTENT_APPROVED | issued | `00-status.md` log |
| Site QA | PASS r1 | `07-site-qa.md` |
| SITE_APPROVED | issued | `00-status.md` log |
| G16 Senior Fidelity | PASS | see below |

## G16 — Senior Fidelity & Convergence verdict: PASS

- **FR-08** → `CONVERGED`: `MenuLoadState`/`load()`/`loadState`/
  `_MenuLoading`/`_MenuErrorState` retired; ctor `.value` seed +
  `listen` per senior `MenuScreenViewModel`.
- **FR-09** → `CONVERGED`: `ProfileStore` deleted;
  `UserProfileRepository` contract + `UserProfileRepositoryImpl` +
  `BehaviorSubject`/`ValueStream` — file layout, member set, and emit
  semantics match senior.
- **FR-19** → `CONVERGED`: `UserProfileData` carries the senior field
  set (`+totalEarnings` String, `+totalQuestionCount`), senior
  defaults/constants, deep `fromMap` (non-empty strings, ≥0 ints,
  `_nullableStringValue`, `_moneyFromDisplay`, `_isLegacyDemoProfile`
  purge), `?avatarUrl` omission, `formatVnd`. Residual:
  `expForNextLevel` remains under **FR-01** → M22; additive display
  getters (`expPercent`, `winRateDisplay`) remain learner-side —
  `expPercent` converges with FR-01 at M22.
- **FR-26** → `ACTIVE_TEMPORARY` (opened): `languageCode` guard is
  non-empty-string; senior whitelists via `SupportedLanguageData` —
  converges M17 (localization vocabulary). Reason + milestone
  recorded; teaching simplification labeled in lesson 03.
- All other register rows untouched and still correctly ACTIVE.
- No unregistered deviations introduced (one doc-comment-only edit on
  `menu_ui_event.dart` — a file marked do-not-touch for *behavior*;
  accepted as maintenance forced by FR-08's retirement, noted by Argus).

## Regression

- `flutter pub get`: rxdart 0.28.0 resolved
- `flutter analyze`: 0 issues
- `flutter test`: **69/69** (52 → 69; repo-layer tests + stream-
  propagation coverage added, store-era tests migrated)
- `flutter build web`: PASS
- `npm run build`: PASS — 66 pages (+5), M14 routes + sidebar +
  roadmap AVAILABLE verified; M15+ still PLANNED
- Senior repo: `main` @ `c8eb860`, clean — UNCHANGED
- M01–M13: no behavioral regression; all prior tests still pass under
  the new repository wiring

## Scope check

M14 delivered exactly the roadmap scope; nothing of M15+ was started
(no sealed UI/event types, no settings/onboarding UI, no
GameViewModel/DRE/nav-controller, no auth/notifications, no advanced
RxDart operators).
