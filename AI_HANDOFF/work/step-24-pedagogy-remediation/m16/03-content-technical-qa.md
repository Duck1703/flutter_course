# Argus Technical QA — M16 — CONTENT_REVISION 18c1fed8924a5cd5

VERDICT: **PASS**

Claims verified against learner-app code:

- m16/02 exercise: `buildSettingItems({settings, effectiveNotificationEnabled})`
  signature real (`settings_item_factory.dart`); `SettingTimePickerItemData`
  carries `hour`/`minute`/`formattedTime`; conditional `if
  (effectiveNotificationEnabled)` row real; `==`/`hashCode` fields real.
  Exercise ask (add `isEnabled` + always-emit) is technically coherent and
  verifiable. Statement "emit-guard `!=` in VM" verified
  (`settings_view_model.dart` equality-guarded emit).
- m16/03 exercise: three-tier scope truth verified — `AppDependencyScope`
  above `MaterialApp`; `MenuViewModel` under Navigator; dialog-route
  `ChangeNotifierProvider` dispose-on-pop verified via
  `menu_settings_dialog_scope.dart` pattern. `context.read` reachability
  claims match the existing "Lỗi hay gặp" section.
- m16/04 exercise: `viewModel.settingItems`, `SettingSwitchItemData.isEnabled`,
  `whereType` counting — all real API surface in learner code.
- Noise removal: verified no numeric args stripped (pump(300),
  ConstrainedBox(375), (7,30) intact — spot-checked `git diff`).
- Code comments containing FR-xx remain = match actual learner-app comment
  convention (verified `level_config.dart`, `localization_switch_test.dart`).
- No snippets added that don't compile conceptually; no paths/commands wrong.
- G24: sequencing intact — exercises reference only ≤M16 constructs.

Findings: none blocking.
