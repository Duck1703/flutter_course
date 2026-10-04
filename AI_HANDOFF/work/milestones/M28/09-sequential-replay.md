# M28 — Physical sequential replay

**Baseline clone:** `Temp/m27-replay` (byte-identical to M27-end
production) copied → `Temp/m28-replay`. lib+test+pubspec+l10n tree
plus `assets/` (added at L01).

## Checkpoints

| Lesson | Batch applied | Expected | Actual |
|--------|---------------|----------|--------|
| Baseline | M27-end (old monolith layer, menu_tokens, no assets) | 259 | **259/259 PASS** |
| L01 | pubspec (2 deps + 2 asset dirs), 8 assets, `app_design_tokens` + `app_assets` + `surface_glow_gradient` + `design_frame`, 6 ARB keys + regen l10n | 259 | **259/259 PASS** (+0) |
| L02 | `qzds_game_button` + `glass_icon_button` + `game_screen_background` + qzds test | 263 | **263/263 PASS** (+4) |
| L03 | `game_countdown_timer` + `part` painter + `game_screen_top_bar` + timer test | 270 | **270/270 PASS** (+7) |
| L04 | money×4 (`motion`, `amount`, ladder CTA, ladder dialog) + money test | 276 | **276/276 PASS** (+6) |
| L05 | answers×3 + question panel + audience poll + dialogs×5 + 5 test files (answer_option, reveal_blink, question_panel, money_row, layer-replace) | 289 | **289/289 PASS** (+13) |
| L06 | `game_screen_data`(iconAsset) + mapper + feature button×2 + `game_screen_body` + `game_screen` + **delete** old `game_dialog_layer.dart`/`game_dialog_views.dart` + vm-test 2-site + ui-events + helpers + screen rewrite + flow + result-flow + feature-button test | 309 | **309/309 PASS** (+20) |

## Final parity

`diff -rq` production ↔ replay: **zero diffs** across `lib/`
(incl. `lib/l10n` generated), `test/`, `pubspec.yaml`,
`l10n.yaml`, `assets/`. Byte-identical.

## Verdict

**PASS** — lesson file-introduction order is executable
sequentially with real `flutter test` at every boundary; every
declared checkpoint count reproduced exactly; final tree
identical to production.
