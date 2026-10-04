# Step 29 — audits: future-leakage, generic-prompt, no-review, solution-leak
import glob, io, os, re, sys

sys.stdout.reconfigure(encoding='utf-8')
ROOT = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(os.path.dirname(ROOT)))
DOCS = os.path.join(REPO, 'web', 'src', 'content', 'docs')

files = sorted(glob.glob(os.path.join(DOCS, 'm*', '0*.md')))
findings = []

def segsplit(seg):
    """Split an AI-Local segment into (expected_state, rest) rough parts."""
    exp = ''
    m = re.search(r'EXPECTED STATE SAU BÀI NÀY:(.*?)(INVARIANTS|KHÔNG ĐƯỢC|INVARIANTS NỀN)',
                  seg, re.S)
    if m:
        exp = m.group(1)
    return exp

# --- AUDIT 1: future-leakage ------------------------------------------------
# Landmarks per milestone = first lesson where the symbol is *introduced*.
# A hit inside EXPECTED STATE of an earlier milestone is only a leak when the
# line is not a negation ("KHÔNG", "chưa", "AHEAD", exclusion), and not a
# substring of a longer identifier.
LANDMARKS = [
    (8,  ['QuizQuestion', 'QuizState']),
    (10, ['SharedPreferences', 'ProfileStore', 'GameResult']),
    (11, ['ChangeNotifier', 'notifyListeners']),
    (12, ['ChangeNotifierProvider', 'context.read', 'context.watch',
          'AppDependencyScope']),
    (13, ['MenuUiEvent']),
    (14, ['UserProfileRepository', 'MultiProvider', 'BehaviorSubject']),
    (15, ['GameDialogState']),
    (16, ['SettingsViewModel', 'SettingItemData']),
    (17, ['AppLocalizations', 'app_en.arb', 'gen-l10n']),
    (18, ['OnboardingViewModel', 'OnboardingOverlay']),
    (19, ['GameScreenViewModel', 'GameSessionState', 'AppNavigationController']),
    (20, ['usedFeatureButtons', 'fiftyFifty', 'audiencePoll',
          'walkAway', 'GameFeatureButtonData']),
    (21, ['GameDialogLayer', 'PopScope']),
    (22, ['LevelConfig', 'MenuLevelProgress']),
    (23, ['SupabaseClientService', 'LeaderboardRepository',
          'SupabaseLeaderboardRepository']),
    (24, ['AuthRepository', 'GoogleSignIn', 'AuthSession',
          'UserProfileSyncRepository']),  # contract @m24/03
    (25, ['UserProfileSyncRepositoryImpl', 'AppUserData']),
    (26, ['GameAction', 'GameEffect', 'GameReducer', 'core/dre', 'dre/']),
    (27, ['LocalNotificationService', 'flutter_local_notifications',
          'share_plus', 'SharePlus', 'package_info_plus', 'GameShareRequested',
          'GameShareResult']),
    (28, ['AppTokens', 'flutter_svg', 'SvgPicture',
          'GameCountdownTimer', 'GameMoneyAmount', 'GameQuestionPanel',
          'GameDialogShell', 'iconAsset', 'GameScreenBody',
          'GameFeatureButtonBar', 'DesignFrame']),
    (29, ['MenuDialogState', 'MenuDialogLayer', 'MenuDialogBackdrop',
          'MenuScreenView', 'OnboardingTokens', 'OnboardingHeaderConfig',
          'OnboardingDialogCard', 'ProfileAvatarImage', 'LevelProgressCard',
          'MenuScreenContent', 'GradientCtaButton', 'LeaderboardEntryCard',
          'LeaderboardAvatar', 'widget_previews']),
]

NEG = re.compile(r'KHÔNG|chưa|AHEAD|retire|xoá|đã xoá|không được|'
                 r'không cần|mới xoá|mới retire|sớm', re.I)

for path in files:
    rel = os.path.relpath(path, DOCS).replace(os.sep, '/')
    mnum = int(rel.split('/')[0][1:])
    text = io.open(path, encoding='utf-8').read()
    seg = text[text.rindex('## 🤖 AI Local'):]
    exp = segsplit(seg)
    if not exp:
        continue
    for mn, marks in LANDMARKS:
        if mnum < mn:
            for mark in marks:
                for mm in re.finditer(re.escape(mark), exp):
                    i = mm.start()
                    # word-boundary on the right side of identifier
                    if i + len(mark) < len(exp) and (
                            exp[i + len(mark)].isalnum() or
                            exp[i + len(mark)] == '_'):
                        continue
                    line = exp[max(0, exp.rfind('\n', 0, i) + 1):
                               exp.find('\n', i) if exp.find('\n', i) > 0
                               else len(exp)]
                    if NEG.search(line):
                        continue
                    findings.append(
                        f'FUTURE_LEAK {rel} expects `{mark}` (m{mn:02d})')

# --- AUDIT 2: generic-prompt ------------------------------------------------
# A review prompt must carry lesson-specific evidence: >=3 backticked
# identifiers AND >=2 lib/|test/|assets paths in EXPECTED STATE.
for path in files:
    rel = os.path.relpath(path, DOCS)
    text = io.open(path, encoding='utf-8').read()
    seg = text[text.rindex('## 🤖 AI Local'):]
    if 'Bạn là Project Alignment Reviewer' not in seg:
        continue
    ticks = set(re.findall(r'`([^`\n]{2,60})`', seg))
    paths = [t for t in ticks if '/' in t or t.endswith('.dart')
             or t.endswith('.yaml') or t.endswith('.arb')]
    if len(ticks) < 8 or len(paths) < 1:
        findings.append(
            f'GENERIC_SUSPECT {rel} ticks={len(ticks)} paths={len(paths)}')

# --- AUDIT 3: no-review justification ---------------------------------------
for path in files:
    rel = os.path.relpath(path, DOCS)
    text = io.open(path, encoding='utf-8').read()
    seg = text[text.rindex('## 🤖 AI Local'):]
    if 'Bạn là Project Alignment Reviewer' in seg:
        continue
    if not re.search(r'thuần|không (thay đổi|đổi)|read-ahead|đọc trước|'
                     r'không cần', seg, re.I):
        findings.append(f'NOREVIEW_NO_REASON {rel}')
    if '```text' in seg:
        findings.append(f'NOREVIEW_HAS_FENCE {rel}')

# --- AUDIT 4: exercise-solution leak ----------------------------------------
# Real leak vector = a lesson's hidden-answer block copied into the AI Local
# segment. Quiz terminology ("ô đáp án", "Đáp án chưa đúng") and self-contained
# Q&A inside no-review notes ("đáp án: **1**") are not violations.
for path in files:
    rel = os.path.relpath(path, DOCS)
    text = io.open(path, encoding='utf-8').read()
    seg = text[text.rindex('## 🤖 AI Local'):]
    for pat in ('<details>', '<summary>', 'answer:</', 'Solution:'):
        if pat in seg:
            findings.append(f'SOLUTION_LEAK[{pat}] {rel}')

print(f'audited={len(files)} findings={len(findings)}')
for x in findings:
    print(' ', x)
