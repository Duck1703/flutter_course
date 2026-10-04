# M18 — SEQUENTIAL REPLAY (physical)

Clone: `C:\Users\Lenovo\AppData\Local\Temp\m16-replay` (carried
through M17 replay — verified M17 end-state: l10n present,
`onboarding` repo+fake present, no overlay, `nextButton` not yet
renamed).

## Baseline (M17 end-state)

- `flutter analyze`: clean
- `flutter test`: **90/90**

## Replay log

| Step | Action per lesson | Checkpoint | Result |
|---|---|---|---|
| L01 | theory only — no code | — | n/a |
| L02 | create `data/onboarding/` (step data + content data); append 16 ARB keys both locales; rename `nextButton`→`gameNextButton` + call site; `flutter gen-l10n` | analyze clean, 90/90 | **PASS** |
| L03 | create `onboarding_view_model.dart` + `onboarding_view_model_test.dart` | 7/7 focused, 97/97 full, analyze clean | **PASS** |
| L04 | promote `LanguageChipRow`→`widgets/common/`; update `settings_dialog.dart`; create scope+overlay widgets; menu `Stack` wrap; patch 3 test hosts with `{'onboarding_completed': true}` | analyze clean, 97/97 | **PASS** |
| L05 | create `test/widgets/onboarding_overlay_test.dart`; full regression + `flutter build web` | 102/102 + build | **PASS** (5/5 focused, 102/102 full, `√ Built build\web`) |

## Defects found

**None.** Every checkpoint count matched the lesson claims exactly
(90 → 97 → 102). No compile gaps between lesson steps (L02's ARB
keys land before L04's call sites; L04 Bước 2's transient
missing-import is explicitly labelled in the lesson). No gap-register
entries opened.

## Replay verdict

**PASS** — M18 lesson sequence executes end-to-end from a verified
M17 end-state clone with all checkpoint claims truthful.
