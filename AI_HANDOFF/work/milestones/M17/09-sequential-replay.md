# M17 — SEQUENTIAL REPLAY (physical, from M16 end-state)

Clone: `C:\Users\Lenovo\AppData\Local\Temp\m16-replay` — verified true
M16 end-state (no l10n config, FR-26 still non-empty guard, 87 tests).

| Lesson applied | Checkpoint | Result |
|---|---|---|
| M16 baseline | `flutter analyze` + `flutter test` | clean, **87/87** |
| L02 | pubspec (`generate: true`, `flutter_localizations`, `intl: any`) + `l10n.yaml` + 2 ARBs + `flutter gen-l10n` | gen exit 0 → `lib/l10n/` classes created; analyze clean; **87/87** |
| L03 | `user_settings_data.dart` whitelist (import + `_supportedLanguageCode` + remove `_nonEmptyLanguageCode` + `///`→`//` header) + `main.dart` StreamBuilder→`MaterialApp.locale` | analyze clean; **87/87** |
| L04 | factory localized params + `localizedSettingItems` + menu/settings-dialog/game-screen migrations + `localized_test_app` helper + 4 test hosts `locale: vi` | analyze clean; **87/87** |
| L05 | `test/localization_switch_test.dart` | **90/90** (+3); `flutter build web` ✓ |

## Replay-caught defect (fixed + registered)

- **F-15**: L03 Bước 1 lacked the `import 'supported_language_data.dart';`
  instruction and the `///`→`//` dangling-doc note — L03's "analyze
  clean" checkpoint was unreachable on the M16-state clone (undefined
  `SupportedLanguageData`). Remediated, persisted via python write,
  re-verified by Argus r4 → PASS; gap register F-15 RESOLVED.

## Verdict: replay **PASS** — every lesson checkpoint reachable in
order; production test count 87 → **90**.
