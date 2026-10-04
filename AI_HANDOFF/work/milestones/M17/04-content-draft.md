# M17 — CONTENT DRAFT (Lumen)

Role: Lumen. Inputs: `01-brief.md`, approved implementation
(`02`/`03` incl. post-QA ARB renames), LESSON_TEMPLATE V2,
BEGINNER_CONTENT_STANDARD, concept registry + prereq graph (updated
with D-31/F-25/A-16 before authoring).

## Lesson set (5 lessons + index)

| File | Depth | New concepts | Reinforcement |
|---|---|---|---|
| `01-vi-sao-l10n-gen.md` | LIGHT/theory | resource-vs-code mental model; fallback chain | A-08, F-11, F-17 |
| `02-arb-gen-l10n-setup.md` | NORMAL | **D-31** ARB + `@key` placeholders + `''` escaping; gen-l10n pipeline | D-05 (JSON) |
| `03-materialapp-locale-streambuilder.md` | CORE | **F-25** (delegates/locale/of); **A-16** app-root stream→locale; FR-26 whitelist | A-08, F-11 |
| `04-di-chuyen-chu-sang-l10n.md` | NORMAL | `localizedSettingItems` params-into-VM (A-16 phần 2); `localizedTestApp` | F-25, D-31 |
| `05-synthesis-tests-tu-lam.md` | NORMAL | — (synthesis) | D-31, F-25, A-16, FR-26 |

## Declared section merges/drops (template V2)

- L01 (LIGHT/theory, no code changes): drops "Dart/Flutter cần
  dùng" (no APIs taught — mental model only), "Ví dụ độc lập"
  (folded into the mental-model pipeline diagram), "Build it step
  by step", "Hiểu code", "Thử nghiệm", "Lỗi hay gặp", "Tự làm" —
  nothing to run yet. Keeps Mục tiêu / Bạn đang ở đâu / Vì sao /
  Bạn đã biết / Mental model / Bridge / Senior connection / Chạy
  (note-only) / Kiểm tra / Ta cố ý / Checkpoint.
- L02 (NORMAL): drops "Mental model mới" (the model lives in L01;
  L02 is mechanical setup) and "Tự làm" (milestone's production
  exercise lives in L03+L05). All other sections present incl.
  Bridge.
- L03 (CORE): **full skeleton** — incl. "Flutter cần dùng" and a
  "Tự làm" (supported-language guard unit test, PREDICT+PRODUCE).
- L04 (NORMAL): drops "Mental model mới" and "Ví dụ độc lập"
  (mechanical migration of one already-taught pattern; the model
  is A-16 from L03) and "Tự làm" (L05 carries it). "Dart cần
  dùng" + "Android bridge" kept per non-droppable rule; adds a
  "dự kiến đỏ giữa bài" callout before Bước 7.
- L05 (NORMAL/synthesis): drops "Mental model mới" and "Ví dụ
  độc lập" (synthesis+test lesson; concepts already isolated in
  L02/L03). "Dart cần dùng" + "Android bridge" kept.

## CORE_CONCEPT coverage check (G17/G23)

- **F-25 AppLocalizations/delegates/locale**: pipeline mental model
  (L01), isolated minimal-ARB example (L02), production application
  `main.dart` + `of(context)` everywhere (L03/L04), mistakes section
  (L03/L04), senior evidence (`main.dart`, `l10n.yaml` identical
  content) — ✔.
- **A-16 locale-as-derived-state + UI-owns-strings**: mental model
  ("locale = f(languageCode)"), isolated `_selectedLocaleFor`
  example, production `StreamBuilder` wiring (L03), VM-param
  boundary (L04), mistakes (context-into-VM ban) — ✔.
- **D-31 ARB format**: isolated example + full-file steps (L02),
  mistakes (trailing comma/`''`/missing `@key`) — ✔ NORMAL depth.

## Active learning (G21)

- Tự làm: L03 (CORE-required) `supported_language_data_test.dart`
  guard unit test (PREDICT+PRODUCE, hidden solution); L05 (PRODUCE)
  `appTagline` key en+vi → regen → render inside the settings dialog
  (the switch test's host subtree) → extend switch test (hidden
  solution).
- DEBUG/PREDICT: remove `initialData` flicker (L03), missing
  delegates stack trace (L04), `fr`→null→fallback (L03/L05),
  assert-en-when-null experiment (L05).
- Thử nghiệm blocks in every lesson.

## Senior fidelity in content (G16)

- Real paths cited: `l10n.yaml` (identical content, LF vs CRLF),
  `app_en.arb`
  (senior 119 keys vs learner 48 — delta registered FR-31),
  `main.dart` (`StreamBuilder`/`initialData`/`onGenerateTitle`/
  `_selectedLocaleFor` — navigatorKey omitted, declared),
  `settings_view_model.dart` (`localizedSettingItems` signature 1:1),
  `menu_settings_dialog_scope.dart` (`_snackBarText` enum→l10n),
  `settings_account_row.dart` (`settingsGuestSyncHint`),
  `language_chip_row.dart` (`nativeName` not l10n),
  `widget_test.dart` (locale-follows-persisted test parity).
- Simplifications/deltas registered: FR-26 (converged this
  milestone), FR-31 (NEW row — 48-key subset, baked casing, VM
  snackbar literal), FR-27/28/29/30 unchanged.

## Sequential executability (G24)

- L01 theory (no code) → L02 pubspec/l10n.yaml/ARBs+gen-l10n
  (checkpoint: gen 0, analyze clean, tests still 87 — nothing
  consumes l10n yet) → L03 fromMap whitelist + main.dart wiring
  (checkpoint: 87/87 — literals still rendered) → L04 full
  migration + `localized_test_app` + 4 test-file patches in the SAME
  lesson (tests would break the moment screens use `of(context)`;
  checkpoint 87/87 via vi pin) → L05 new test file + Tự làm
  (checkpoint 90/90 + build web).
- No forward references: `localized_test_app.dart` is created in L04
  before the test files are patched to use it; `localization_switch_
  test.dart` is created in L05 only when everything it asserts
  exists. ARB content blocks in L02 match `lib/l10n/*.arb` on disk
  verbatim (48 keys, @key blocks present in vi too).
