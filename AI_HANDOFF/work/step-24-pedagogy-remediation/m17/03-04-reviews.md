# M17 — Dual Review — CONTENT_REVISION ce01b81108dbce9c

## Argus Technical QA — PASS

- gen-l10n behavior claims verified: placeholder-name mismatch across locales
  fails generation; `@key` metadata → typed method signature real;
  template-fallback for missing vi key real.
- `localizedSettingItems` signature verified in
  `settings_view_model.dart` (6 named String params) — exercise's "thêm
  param thứ bảy" follows the real mechanism.
- whitelist behavior (`fromMap` → null → `locale: null` → system/template
  fallback) matches lesson code and learner `user_settings_data.dart`.
- Group-name claim `group('FR-26 — languageCode whitelist…')` verbatim
  from `test/localization_switch_test.dart:19`.
- No code-mangling in noise pass (numeric args intact); no senior-claim
  change; G24 sequencing intact.

## Pedagogy Reviewer — PEDAGOGY_PASS

- F-M3 M17 portion resolved: 02/03/04 all have verifiable independent work
  (gen-l10n exit code; predict-then-reveal table; end-to-end migration).
- P8: learner decides key name + param threading before hidden answer.
- M17/04 exercise builds on the M16/05 artifact the learner themselves
  produced — real transfer, not synthetic.
- P11: register-speak ("register FR-31 ghi nhận…") removed; test-group
  `FR-26` name kept as code-truth exception (learners see it in test
  output — removing would create mismatch).
