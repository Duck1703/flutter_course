# M16 — CONTENT QA (Argus)

Two passes on final on-disk lesson files (write-tool staleness noted;
all verdicts grep-verified on disk).

## Pass 1 — FAIL (2 MAJOR + 5 MINOR)
- MAJOR-1: L02 factory snippet contradicted `settings_item_factory.dart`
  (sound subtitle present; notifications missing `'Mỗi ngày một lần'` +
  `effectiveNotificationEnabled`). → FIXED.
- MAJOR-2: false claim ×4+ (dialog context can't see MultiProvider) —
  `AppDependencyScope` is ABOVE Navigator, so app repos ARE reachable;
  real rationale for caller-read+pass-instance = self-contained scope.
  Fixed in L03, L04, `settings_dialog.dart`, `menu_screen.dart`,
  brief ADDENDUM-2. → FIXED.
- MINOR-1 L02 run-section not sequential → deferred marker + real test
  filter. MINOR-2 wrong repo class name → `UserSettingsRepositoryImpl`.
  MINOR-3 `late` untracked → glossed in L03 + registry D-30.
  MINOR-4 L01 undeclared drops → Kiểm tra hiểu biết added + draft
  declares all drops. MINOR-5 Tự làm missing `case SettingType.info`
  arm → step 4 + solution updated. All → FIXED.

## Pass 2 — focused re-verify → PASS
- All 7 findings confirmed resolved on disk; no new contradictions;
  FR-26 wording consistent (persist now / guard+locale = M17);
  snippets match shipped files.
- 2 new cosmetic nits fixed post-PASS (stray comment fragment in
  `menu_screen.dart`; L02 `super.subtitle` snippet divergence) —
  targeted re-read verified both removed; `flutter analyze` clean.

## Gates (final files)
G16 PASS · G17 PASS · G18 PASS · G19 PASS · G20 PASS · G21 PASS ·
G22 PASS · G23 PASS · G24 PASS

## Verdict
**M16_CONTENT_QA: PASS** (post-remediation state verified fresh)
