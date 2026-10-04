# M17 Implementation Notes — Localization (en/vi)

## What landed (learner-app)

- `pubspec.yaml`: `generate: true` (flutter section), `flutter_localizations`
  (sdk), `intl: any` (senior-identical declaration; resolves 0.20.2).
- `l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`,
  `output-localization-file: app_localizations.dart`.
- `lib/l10n/app_en.arb` + `app_vi.arb`: **48 keys each, identical key
  sets**. 31 keys are senior-shared (identical names + en values,
  e.g. `settingsLoadErrorMessage`, `settingsUpdateErrorMessage`,
  `settingsGuestSyncHint`); 17 learner-invented (course surface).
  `wrongFeedback` uses U+2014 em dash.
- Generated `app_localizations*.dart` committed under `lib/l10n/`
  (senior convention — generated code checked in).
- `main.dart`: `StreamBuilder` over
  `UserSettingsRepository.userSettingsStream` with
  `initialData: settingsStream.value` → `_selectedLocaleFor` →
  `MaterialApp.locale`; `localizationsDelegates` + `supportedLocales`
  from `AppLocalizations`; `onGenerateTitle` → `l10n.appTitle`.
- `user_settings_data.dart`: FR-26 converged — `languageCode` now
  validated by `_supportedLanguageCode` (whitelist via
  `SupportedLanguageData.isSupportedCode`); `_nonEmptyLanguageCode`
  removed; `import 'supported_language_data.dart'`; header `///`→`//`.
- String ownership: **UI owns `BuildContext`/`AppLocalizations`**;
  `SettingsViewModel`/`buildSettingItems` stay context-free —
  `localizedSettingItems(soundText:, musicText:, …)` receives strings
  from the widget layer (senior shape).
- Localized surfaces: menu screen, settings dialog (+picker), game
  chrome (dialog states, snackbar, feedback). Excluded per brief:
  quiz-bank content, repository raw errors, onboarding (→ M18) —
  tracked as **FR-31** (SIMPLIFIED, ACTIVE_TEMPORARY).
- Tests: `test/helpers/localized_test_app.dart`; existing hosts pinned
  `locale: vi`; new `test/localization_switch_test.dart` (3 tests —
  whitelist en/vi kept, invalid/null → `null`, live locale switch
  widget test). **90/90**.

## Register deltas

- FR-26 → **CONVERGED at M17**.
- FR-31 → OPEN (ACTIVE_TEMPORARY; onboarding l10n portion closes in M18).

## Verified state

`flutter analyze` clean; 90/90 tests; `flutter gen-l10n` exit 0;
`flutter build web` pass; senior `main@c8eb860` unchanged.
