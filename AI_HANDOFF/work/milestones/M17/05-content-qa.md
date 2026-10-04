# M17 — CONTENT QA (Argus) + SEQUENTIAL REPLAY

## QA chain

| Round | Verdict | Findings |
|---|---|---|
| r1 initial | **FAIL** | 4 MAJOR + ~10 MINOR + 1 NIT |
| r2 re-verify | **FAIL** | 1 MAJOR (import path, introduced by r1 fix) + 2 NIT |
| r3 re-verify | **FAIL** | F-15 incomplete — earlier remediation silently didn't persist (stale-write anomaly) |
| r4 re-verify | **PASS** | zero findings |

## r1 findings → resolutions (all verified)

- MAJOR: L04 snippet used nonexistent getters `l10n.musicText`/
  `notificationsText` → fixed to `musicSetting`/`notificationsSetting`
  (disk match).
- MAJOR: L05 Tự làm incoherent (asserted a menu-screen string inside
  a test that pumps the settings dialog) → tagline now renders inside
  `SettingsDialogScope`'s subtree; exercise/hint/solution coherent.
- MAJOR: L04 missing `playAgainButton`/`menuButton` (`dialogContext`)
  migration → added to Bước 6.
- MAJOR: undeclared template drops → added non-droppable sections
  (L03 "Flutter cần dùng" + CORE-required Tự làm; L04/L05 "Dart cần
  dùng" + bridge); manifest now declares every remaining drop.
- MINORs fixed: bare `StreamBuilder` (senior/disk parity), senior
  `navigationController.navigatorKey` quote, "byte-identical"→
  "nội dung y hệt", senior vi-ARB `@key` convention, snackbar
  learner-scaffolding framing, prereq IDs (D-15), index "chrome"
  wording, `_snackBarText` owner named, import instructions, mid-
  lesson "test đỏ" callout, L01 file count.

## r2 finding → resolution

- MAJOR: import instructions used `'../../l10n/…'` for
  `lib/screens/` files → corrected to `'../l10n/…'` (disk-verified)
  in both Bước 5 and Bước 6. NITs (L03 generic-name prose, L02
  paren note) fixed.

## r3 finding → resolution (replay-driven)

- F-15: L03 Bước 1 lacked `import 'supported_language_data.dart'`
  instruction + `///`→`//` header note — caught by physical replay
  (L03 analyze failed on the M16-state clone). All three elements
  now present; gap-register F-15 marked RESOLVED.

## Sequential replay (physical, M16-end-state clone `Temp\m16-replay`)

| Stage | Result | Lesson claim |
|---|---|---|
| M16 baseline | 87/87, analyze clean | — |
| L02 (pubspec+l10n.yaml+ARBs+gen-l10n) | gen exit 0, clean, **87/87** | ✓ claimed |
| L03 (fromMap whitelist + main.dart) | clean, **87/87** | ✓ claimed |
| L04 (factory/VM/4 UI + helper + 4 test patches) | clean, **87/87** | ✓ claimed |
| L05 (+localization_switch_test) | **90/90**, `build web` √ | ✓ claimed |

Replay used production-verified file content for the mechanical
migration (Argus diffed every embedded snippet byte-equal). The
L03 defect found by replay is registered + fixed (F-15).

## Verdict: **PASS** — all findings resolved, replay physically proven.
