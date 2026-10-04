# M01 — CONTENT DRAFT MANIFEST (Lumen)

State: `DRAFTED`

## CONTENT_REVISION (frozen for dual review)

`git hash-object` blob SHAs of the milestone's lesson set:

| File | Blob SHA |
|---|---|
| `web/src/content/docs/m01/01-flutter-dart-va-project-dau-tien.md` | `919f9911f3f9ccbe84354e8f390c7642ab332c75` |
| `web/src/content/docs/m01/02-main-runapp-va-cay-widget.md` | `6cce1d1fc88617bc0dc844627767a6e30f1f97a9` |
| `web/src/content/docs/m01/03-chay-app-hot-reload-va-tooling.md` | `55d8c939b044fc164dbe200bbedfb47df6ef0bae` |

Any learner-facing edit after this stamp → new revision → both reviews
re-run.

## Per-lesson delta

| Lesson | Existing strengths preserved | Missing V2 element | Change type | CORE concepts | Exercise level | Learner decision required | Verification | Technical/senior claims affected |
|---|---|---|---|---|---|---|---|---|
| m01/01 | felt-problem framing, project anatomy, Android bridge, pubspec-as-declaration model | `Tự làm` | TỰ_LÀM | — (NORMAL) | PREDICT | apply `snake_case` rule to 4 naming cases incl. edge cases | run `flutter create --project-name` per case, compare accept/reject | NONE |
| m01/02 | 3-tree mental model, BuildContext≠Context caution, step rationale, read-the-code trace | isolated example + `Tự làm` | ISOLATED_EXAMPLE + TỰ_LÀM | F-01, F-03, D-02 (exercised), A-01 | PREDICT | predict compile vs display outcome when `MaterialApp` is removed; name MaterialApp's hidden services | `flutter run -d chrome` shows directionality error; restore afterwards | NONE |
| m01/03 | 3-level reload table, Apply-Changes bridge, honest "r vs R" exercise | — | NONE (EXISTING_ACTIVITY_RETAINED) | — | PREDICT (existing) | r-vs-R decision per change type | run + observe | NONE |

## Isolated example added

`m01/02` — `ProfileChip`: domain-neutral `StatelessWidget`, ~20 lines,
DartPad-Flutter runnable; exercises `required this.name`, `final` field,
`build`-returns-tree; explicitly connected back to `WelcomeScreen`.

## Declared section merges/drops (G23)

None new — m01/01 and m01/03 are NORMAL lessons; isolated example
intentionally absent (no CORE first-teaching concept); declared here
per template rule.
