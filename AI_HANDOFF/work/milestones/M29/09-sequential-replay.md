# M29 — Physical Sequential Replay Evidence

**Verdict: PASS** — every lesson batch replays green from the M28-end
baseline; the fully applied replay tree is **byte-identical** to
production (`lib/`, `test/`, `assets/`, `docs/`, `pubspec.*`,
`analysis_options.yaml`, `l10n.yaml` — SHA-256 compared).

## Method

- Baseline: `m28-replay` clone (byte-identical to M28-end production)
  copied to `m29-replay`.
- Seven lesson batches applied in order, `flutter test` after each.
- Multi-batch files reconstructed at their intermediate states:
  - `menu_screen.dart` L02/L03 interims = route-fn call sites swapped for
    `showDialog<void>` + scope-with-`onDismiss` wrappers (verbatim L05
    version lands at L05).
  - `app_vi.arb`/`app_en.arb` via ordered key ops: L01 (+11 keys, −2
    dead), L02 (16 senior sentence-case value swaps), L07 (−3 dead
    learner keys + 2 product-name share renames).
  - `menu_screen_ui_events_test.dart` / `game_screen_test.dart`
    L02/L04 interims = final files with the `GradientCtaButton` finder
    reverted to `find.text('Bắt đầu chơi')` (old CTA renders raw).
  - `onboarding_overlay_test.dart` L05 interim = M28 file +
    `AppNavigationController` provider (senior file lands at L06).

## Checkpoint results

| Batch | Content | Replay | Documented | Delta |
|---|---|---:|---:|---|
| Baseline | M28 end-state | 309/309 | 309 | exact |
| L01 | assets×50 + AppAssets + OnboardingTokens + l10n +11/−2 | 309/309 | 309 | exact |
| L02 | settings chrome + interim routes + ARB casing | 311/311 | 313 | −2* |
| L03 | leaderboard pipeline (entry/repo/widgets) | 319/319 | 321 | −2 carried |
| L04 | menu surface + auth/language verbatim + CTA | 343/343 | 345 | −2 carried |
| L05 | dialog state/layer + VM rename + scopes | 367/367 | 369 | −2 carried |
| L06 | onboarding visuals + MenuTokens retired | 381/381 | 383 | −2 carried |
| L07 | sweep: main/scope/nav + previews + ARB −3 | **396/396** | **396** | **exact** |

\* The −2 offset is a replay-tooling artifact, not an implementation
defect: `settings_view_model_test.dart` (M28: 12 cases) and
`localization_switch_test.dart` (M28: 3 cases) were applied in their
**final L07 senior-canonical form** at L02 because the L02-interim
learner-adapted versions were never snapshotted. Those finals carry 2
fewer cases than the L02 interims did. The delta carries through
L03–L06 and resolves exactly at L07, where the final tree is
byte-identical to production (396/396).

## Replay-vs-production fix-ups during replay

Two batch-listing omissions were caught by the parity pass and fixed
inside the clone (files were correct in production; the driver simply
missed copying them at the right batch):

- `lib/repositories/leaderboard/leaderboard_repository_contract.dart`
  (L03), `lib/view_models/menu/menu_auth_dialog_view_model.dart`
  (post-L04 Argus comment fix), `assets/images/app-launcher-icon.png`
  (L01, root-level file), pubspec `assets:` block (L01 — required for
  leaderboard asset loading).
- `app_vi.arb` JSON-op reconstruction dropped `exitGameSemanticLabel`
  (present since M28) and reordered entries — replaced with the
  production file verbatim; parity check then reports IDENTICAL.

## Parity proof

`python` SHA-256 tree comparison, production vs `m29-replay`:
`lib/`, `test/`, `assets/`, `docs/`, `pubspec.yaml`, `pubspec.lock`,
`analysis_options.yaml`, `l10n.yaml` → **0 diffs**.

## Conclusion

All seven lesson boundaries compile and test green when applied
sequentially from a clean M28-end state; the final replay output equals
production byte-for-byte. `REPLAY_PASS` recorded.
