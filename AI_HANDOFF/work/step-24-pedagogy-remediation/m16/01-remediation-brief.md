# M16 — Step-24 Remediation Brief

## Audit (P1–P12 spot)

- 01 (A): motivation + persist loop model — strong; P11 noise only (12 IDs).
- 02 (A→E gap): factory/data mapping taught well; `Thử nghiệm` = 1-line predict;
  no independent production → ADD_PRODUCTION_EXERCISE (MODIFY + decision).
- 03 (E): scope=lifetime CORE, excellent 3-tier model + isolated counter example;
  no exercise exercising ownership → ADD_PRODUCTION_EXERCISE (scope decision).
- 04 (E): UI wiring; `Thử nghiệm` read-vs-watch predict exists; no production →
  ADD_PRODUCTION_EXERCISE (state→UI derived render).
- 05 (A): strong `SettingInfoItemData` produce exercise exists — P11 noise only.

## Changes (CONTENT_REVISION 18c1fed8924a5cd5)

- m16/02 `## Tự làm — "xám đi" thay vì "biến mất"`: requirement change
  (greyed vs hidden row) → decide data-vs-widget field, `==` impact,
  `SettingType` impact; implement + `flutter analyze` + factory scratch
  check. Level: MODIFY (with DERIVE decisions). Solution hidden.
- m16/03 `## Tự làm — ba VM mới, ba tầng scope`: three scope scenarios
  (ConfirmReset VM, MenuTabState, AppLocaleController) — decide tier, owner,
  lifetime, consequence of wrong tier. Level: DERIVE/design decision.
- m16/04 `## Tự làm — dòng tóm tắt "N đang bật"`: connect VM state →
  derived UI; decide compute site (build vs VM vs factory), read-vs-watch,
  count source; implement + widget test. Level: PRODUCE.
- All 5 files + index: learner-facing ID noise removed (registry tokens →
  human-readable refs; code comments with FR-xx kept — they mirror real
  learner-app code style and test names).

## Mental-model ledger

- KNOWN: scope=lifetime (03), persist loop (01), sealed-family-driven list (02).
- NEW added: none (exercises reuse existing models; 04's derived-count is
  application not new model).
- NEW→NEW deps: none.

## Constraints honored

No senior-claim change. No new concepts (Slider variant avoided — exercise
modifies existing `SettingTimePickerItemData` semantics). No M17+ content.
No route/slug/sidebar change.
