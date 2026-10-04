# M16 — CONTENT DRAFT (Lumen)

Role: Lumen. Inputs: `01-brief.md` (incl. FR-26 addendum), approved
implementation (`02`/`03`), LESSON_TEMPLATE V2, BEGINNER_CONTENT_STANDARD,
concept registry + prereq graph (read from disk).

## Lesson set (5 lessons + index)

| File | Depth | New concepts | Reinforcement |
|---|---|---|---|
| `01-vi-sao-settings-persist.md` | LIGHT/theory | settings-persist loop model | A-06/08/10 |
| `02-setting-item-data-factory.md` | NORMAL | F-… data-driven rows; D-29 padLeft | D-26/27, enum dispatch |
| `03-settings-view-model-dialog-scoped.md` | CORE | **A-15 dialog-scoped VM** | F-18, A-05, A-08 |
| `04-settings-dialog-ui.md` | NORMAL | **F-23 Switch controlled**; HitTestBehavior.opaque | F-13, bridge 3-khâu |
| `05-time-picker-synthesis.md` | NORMAL | **F-24 ListWheelScrollView + FixedExtentScrollController** | F-06, F-14, A-14 |

## Declared section merges/drops (template V2)

- L01 (LIGHT, theory — no code changes): drops "Dart cần dùng",
  "Flutter cần dùng", "Build it step by step", "Hiểu code",
  "Chạy và quan sát", "Tự làm"; keeps Mục tiêu / Bạn đang ở đâu /
  Vì sao / Bạn đã biết / Mental model / Ví dụ độc lập / Bridge /
  Senior connection / Thử nghiệm (deferred to L05) / Lỗi hay gặp /
  Kiểm tra hiểu biết / Ta cố ý chưa thêm / Checkpoint. All drops
  declared here per V2.
- L02–L05: full template sections present.

## CORE_CONCEPT coverage check (G17/G23)

- **A-15 dialog-scoped VM**: mental model (scope=lifetime, 3-tier),
  isolated counter-dialog example, production application
  (SettingsDialogScope), mistakes section, senior evidence
  (`menu_settings_dialog_scope.dart`) — ✔ in L03.
- **F-23 Switch**: controlled-component model, isolated example,
  mistakes — ✔ in L04.
- **F-24 wheel picker + controller ownership**: isolated
  Bad/Good ownership example, senior WheelPicker evidence — ✔ in L05.

## Active learning (G21)

- Tự làm: `SettingInfoItemData` new variant (production, hidden
  solution) — L05.
- DEBUG/PREDICT tasks: remove `SettingType` case (L03), `if(true)`
  factory (L02), missing `notifyListeners` (L05), `read` vs `watch`
  (L04).
- Thử nghiệm blocks in every lesson.

## Senior fidelity in content (G16)

- Every senior claim cites real path+symbol verified at `c8eb860`:
  `settings_view_model.dart` (seed/`_saveSettings`/events),
  `menu_settings_dialog_scope.dart` (provider-in-dialog, bridge
  3-khâu + `_didLoadSettings`), `setting_switch_row.dart` (opaque
  row tap), `wheel_picker.dart` (controller in State),
  `settings_card.dart` (sections), `menu_profile_header.dart`
  (gear), `menu_screen_view_model.dart` (`requestSettingsDialog`).
- Simplifications declared with register rows: FR-16/26/27/28/29/30.
- FR-26 language: lessons say chips persist now; whitelist guard +
  locale switch = M17 (matches reverted guard + brief addendum).

## Sequential executability (G24)

- L01 no-code → L02 data+factory files → L03 VM+events →
  L04 dialog+gear wiring → L05 picker+tests. Each lesson's Build steps
  land on files that exist at that point (L04 references
  `SettingItemData`/VM already created). Widget-test snippet in L05
  requires `SettingsDialogScope(profile:)` — exists post-L04.
- Replay starts from M15 end-state (74-test baseline, settings repo
  dormant).

## Registry / graph / gap updates

- `LEARNER_CONCEPT_REGISTRY.md`: F-23, F-24, A-15, D-29 → TAUGHT at
  M16 (first-lesson + first-code = M16); reinforcement notes for
  A-06/08/10, D-26/27, F-13/17/18/21.
- `PREREQUISITE_GRAPH.md`: edge settings-repo (M14) → sealed items →
  dialog-VM → controls → persisted settings UI (M16).
- `CONTENT_GAP_REGISTER.md`: no new gaps found; nothing to open.
- `SENIOR_FIDELITY_REGISTER.md`: FR-27..FR-30 already opened at impl
  remediation (before content QA) — see 03-implementation-qa.md.

## Known content limits

- Lesson snippets are teaching extracts (some `...` elisions) —
  canonical truth is the learner-app source; snippets match final
  files in structure/API, trimmed for pedagogy.
- No localization taught yet — all strings Vi literals (M17 owns).
