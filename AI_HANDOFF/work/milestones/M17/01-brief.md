# ATLAS BRIEF — M17: Localization (en/vi)

## SENIOR FIDELITY CHECK

**Senior target:** gen-l10n localization — `l10n.yaml` + ARB files +
generated `AppLocalizations` committed to `lib/l10n/`; `MaterialApp`
receives `localizationsDelegates`/`supportedLocales` from
`AppLocalizations`, `locale` driven by a `StreamBuilder` over
`userSettingsStream` (`_selectedLocaleFor(languageCode)` →
`Locale(code)` or null); `onGenerateTitle` →
`AppLocalizations.of(context).appTitle`; `UserSettingsData.fromMap`
whitelists via `_supportedLanguageCode` (`isSupportedCode`).

**Senior files/symbols:**
- `l10n.yaml` — `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`,
  `output-dir: lib/l10n`, `output-class: AppLocalizations`,
  `nullable-getter: false`, `use-escaping: true`
- `lib/l10n/app_en.arb` (162 keys, template), `app_vi.arb`,
  `app_localizations{,_en,_vi}.dart` — generated, **committed**
- `pubspec.yaml` — `flutter_localizations: sdk: flutter`,
  `intl: any`, `generate: true`
- `lib/main.dart` — `StreamBuilder(settingsStream, initialData:
  stream.value)` → `MaterialApp(locale: selectedLocale, ...)`
- `lib/data/settings/user_settings_data.dart` —
  `_supportedLanguageCode(Object?)`: non-String OR unsupported → null
- `test/widget_test.dart` — "app locale follows persisted language
  settings" (save `languageCode:'vi'` → expects Vietnamese text)

**Current learner state:** `SupportedLanguageData` + `languageCode`
persisted (M16); chips write `'en'`/`'vi'`; `UserSettingsData.fromMap`
still non-empty guard; all UI strings hardcoded Vietnamese literals;
no `flutter_localizations`/`intl`/l10n infra.

**Senior target state:** runtime locale switch en↔vi via persisted
setting; English source-of-truth ARB + Vietnamese ARB; app text flows
through `AppLocalizations.of(context)`; unsupported stored codes
silently drop to null.

**Register entries expected to close:** FR-26 → **CONVERGED**
(whitelist guard becomes senior-identical).

**Entries remaining active:** FR-05→M19, FR-07/16/29→M21,
FR-27→M27, FR-28→M22+/M27, FR-30→M24. New row needed: learner
localizes only ~45 menu/settings/game-chrome strings (senior has 162
keys incl. auth/onboarding surfaces the learner lacks) →
**FR-31 l10n coverage delta, ACTIVE_TEMPORARY → converges as those
surfaces land (M18 onboarding, M22 auth, M24+ chrome)**.

**Permitted simplifications:** fewer ARB keys (learner app is smaller);
quiz-bank content + repo error messages stay Vietnamese-only (senior
deliberately doesn't localize them either); `appTitle` via
`onGenerateTitle` optional if learner keeps static title — check senior
parity (senior uses it → learner adopts it).

**Forbidden alternatives:** custom JSON maps, hand-rolled translation
classes, third-party l10n packages (easy_localization etc.), locale
switching via anything but `MaterialApp.locale`, generating into
`.dart_tool` synthetic package (senior outputs into lib/ committed).

## LEARNING DESIGN CHECK

**New Dart concepts:** `Locale` (D-31, LIGHT); `intl` awareness (LIGHT,
folded into ARB lesson); string interpolation → ARB `{placeholder}`
mapping.

**New Flutter concepts:** `MaterialApp.locale`/`localizationsDelegates`/
`supportedLocales` (F-25, CORE); `AppLocalizations.of(context)` +
generated delegate + `Localizations` context lookup (F-26, CORE);
`onGenerateTitle` (LIGHT, part of F-25 row).

**New architecture concepts:** build-time code generation
(`generate: true`, `flutter gen-l10n`, generated files committed in
lib/) — A-16 (NORMAL); resource→generated-accessor→context pipeline
mental model.

**Prerequisites:** `languageCode` persistence (M16 ✓), `StreamBuilder`
+ `initialData` (F-11, M06 ✓), `context` l10n lookup ≈ `context.read`
mental model (F-17 ✓), sealed/settings rows (M16 ✓).

**Concept registry changes:** +F-25 (CORE), +F-26 (CORE), +D-31
(LIGHT), +A-16 (NORMAL); F-11/A-08 marked REINFORCED at root level.

**Depth classifications:** as above — two new CORE (MaterialApp l10n
wiring; AppLocalizations lookup), rest LIGHT/NORMAL.

**Mental models:** "string resource → generated accessor → context
lookup" (vs senior-identical); "locale is just widget input —
MaterialApp rebuild = language switch"; "persisted setting is the
single source; locale follows the stream like everything else".

**Isolated examples:** minimal `MaterialApp` + 2-key ARB demo before
touching the app; placeholder demo (`{level}`) on the real
`profileLevel` key.

**Independent exercise:** add a brand-new localized string NOT copied
from the senior set (e.g., a settings footnote or a semantic label) —
edit ARB en+vi, regenerate, consume; predict what an unsupported stored
`'fr'` does (whitelist → null → system fallback).

**Concept reinforcement:** StreamBuilder at app root (F-11),
BehaviorSubject `.value` seed (A-08), Provider context lookup analogy
(F-17), enum/whitelist validation (M16 FR-26 closure).

**Cognitive-load assessment:** biggest single-surface change so far —
every UI string moves. Keep ARB authoring mechanical (key list
table + copy pattern); isolate the three real concepts (gen pipeline,
MaterialApp wiring, context lookup). Lesson split below keeps each
concept in its own room.

**Lesson split (5):**
1. `01-vi-sao-l10n-gen.md` — why hardcoded strings don't scale; ARB =
   source-of-truth resources; pipeline mental model (theory).
2. `02-arb-gen-l10n-setup.md` — `l10n.yaml`, `generate: true`,
   app_en/app_vi ARB syntax, placeholders + escaping, `flutter
   gen-l10n`, generated files tour.
3. `03-materialapp-locale-streambuilder.md` — CORE: delegates/
   supportedLocales/locale + `StreamBuilder` on settings stream +
   `_selectedLocaleFor` + FR-26 whitelist in `fromMap` (lands here:
   "khi nào code lọ tới whitelist").
4. `04-di-chuyen-chu-sang-l10n.md` — mechanical migration of
   menu/settings/game chrome strings; `AppLocalizations.of(context)`;
   semanticLabel on gear; test updates (English assertions).
5. `05-synthesis-tests-tu-lam.md` — locale-switch widget test
   (senior parity), full regression, independent exercise.

**Sequential checkpoint strategy:** L02 ends with gen-l10n compiling
(app still Vietnamese-only text is FINE — `nullable-getter:false`,
fallback to en template — checkpoint = `flutter gen-l10n` exits 0 +
`flutter analyze` clean); L03 ends with runtime switch working;
L04/L05 converge tests to 87→~90.

## Explicit non-goals

- No onboarding localization (M18 owns onboarding strings).
- No ICU plurals/select — mention-only in L02.
- No RTL.
- No localizing quiz-bank content or repo messages (senior parity).
- No `AppNavigationController`/`navigatorKey` changes.
