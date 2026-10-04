# M27 — Sequential Replay

Clone: `C:\Users\Lenovo\AppData\Local\Temp\m27-replay` (built from the
verified byte-identical M26-end `m26-replay` clone; lib+test subset —
platform dirs absent, manifest verified verbatim by Argus instead).

## Checkpoints (lesson order, physical file application)

| Lesson | Applied | Result |
|---|---|---|
| Baseline | M26-end clone | **254/254** ✓ |
| L01 | `pubspec.yaml` (+5 deps) → `pub get`; manifest = verbatim-copy artifact (no platform dir in clone — Argus byte-verified vs senior) | **254/254** ✓ |
| L02 | `local_notification_service.dart` + `fake_local_notification_service.dart` (scaffold, no consumer) | **254/254** ✓ |
| L03 | coordinator + version loader + `settings_ui_event` + `settings_view_model` + `settings_dialog.dart` (L03-intermediate: version row withheld to L04) + ARB intermediates (share keys withheld to L05) + `flutter gen-l10n` + `settings_view_model_test` + `settings_dialog_test` + `localization_switch_test` | **259/259** ✓ (+5) |
| L04 | `main.dart` + `app_dependency_scope.dart` + `settings_dialog.dart` (production, version row) + `onboarding_overlay_scope.dart` + 4 `AppDependencyScope` hosts + `onboarding_overlay_test` + `onboarding_view_model.dart` (comment sync) | **259/259** ✓ |
| L05 | production ARBs + `gen-l10n` + action/effect/ui-event + reducer arm + bridge + VM `shareResult` + dialog views/layer + `game_screen.dart` + `game_dialog_layer_test` | **259/259** ✓ |
| L06 | regression only — `flutter analyze` | clean ✓ |

## Replay finding & disposition

At L03 the first `flutter test` run failed with 7 test-file compile
errors — all `settingsNotificationPermissionRequiredMessage isn't
defined` — because the clone carried stale M26-end generated
`app_localizations*.dart`. `flutter gen-l10n` regenerated from the
L03-intermediate ARBs → **259/259**. Not a content defect: the
lesson flow regens via `flutter pub get`/`gen-l10n`; recorded here
because replay clones carrying committed generated files need an
explicit regen step (same caveat would hit any ARB-changing
milestone replay).

## Final parity

`lib/`, `test/`, `pubspec.yaml`, `l10n.yaml`,
`analysis_options.yaml` — byte-identical to production:
`DIFFS: []`, `MISSING: []`, `EXTRA: []` (platform dirs +
generated tooling files excluded — not present in clone by
construction).
