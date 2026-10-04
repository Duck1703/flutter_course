# M17 — Step-24 Remediation Brief — CONTENT_REVISION ce01b81108dbce9c

## Audit

- 01 (A): motivation — noise only.
- 02 (A→E gap): pipeline setup solid, no Tự làm → ADD exercise:
  predict generated API + produce key pair + DEBUG broken ARB.
- 03 (A): derived-locale mental model strong; missing independent task →
  ADD PREDICT exercise (locale decision table + emit→rebuild trace).
- 04 (E): mechanical migration → ADD Tự làm: classify which strings belong
  in l10n + migrate the 'Phiên bản' label (from M16/05 exercise) end-to-end.
- 05 (A): strong end-to-end exercise exists — noise only.

## Changes

- m17/02 `## Tự làm — một key mới…`: PRODUCE+PREDICT+DEBUG, verified by
  `flutter gen-l10n` exit code and generated signature inspection.
- m17/03 `## Tự làm — dự đoán locale cho mọi đầu vào`: PREDICT table +
  5-point trace. Level: PREDICT.
- m17/04 `## Tự làm — migrate nốt hàng "Phiên bản"`: classify-and-migrate;
  extends `localizedSettingItems` with a 7th param via the lesson's own
  param-threading pattern. Level: PRODUCE + DERIVE decision.
- Noise: ~40 prose tokens removed; `FR-26` kept only where it names the
  real test group (`group('FR-26 — languageCode whitelist …')` — verified
  in `test/localization_switch_test.dart`).

Mental-model ledger: no NEW models (locale-as-derived-state already taught).
No senior-claim change. No M18+ concept leak.
