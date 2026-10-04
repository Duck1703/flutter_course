import '../core/app_design_tokens.dart';
import '../data/game/game_screen_data.dart';
import '../data/game/game_session_state_data.dart';
import '../data/profile/user_profile_data.dart';
import '../data/settings/user_settings_data.dart';
import '../view_models/settings/settings_item_factory.dart';

const previewUserSettings = UserSettingsData(
  soundEnabled: true,
  musicEnabled: true,
  hapticEnabled: true,
  notificationEnabled: true,
  notificationHour: 20,
  notificationMinute: 30,
);

const previewProfile = UserProfileData(
  username: 'Preview Player',
  level: 12,
  totalEarnings: '1,000,000 VND',
  currentExp: 12400,
  totalMoneyWon: 1000000,
  gamesJoined: 20,
  gamesWon: 12,
);

const previewGameTimer = GameTimerData(
  totalTime: Duration(seconds: 30),
  remainingTime: Duration(seconds: 18),
);

const previewGameAnswers = [
  GameAnswerOptionData(answerLabel: 'A', answerText: 'Neural network'),
  GameAnswerOptionData(
    answerLabel: 'B',
    answerText: 'Decision tree',
    state: GameAnswerState.selected,
    audiencePercentile: 24,
  ),
  GameAnswerOptionData(
    answerLabel: 'C',
    answerText: 'Gradient descent',
    state: GameAnswerState.correct,
    audiencePercentile: 61,
  ),
  GameAnswerOptionData(
    answerLabel: 'D',
    answerText: 'Hash table',
    state: GameAnswerState.incorrect,
    audiencePercentile: 15,
  ),
];

const previewFeatureButtons = [
  GameFeatureButtonData(
    type: GameFeatureButtonType.fiftyFifty,
    iconAsset: AppAssets.iconGameFiftyFifty,
    semanticLabel: 'Fifty fifty',
  ),
  GameFeatureButtonData(
    type: GameFeatureButtonType.audiencePoll,
    iconAsset: AppAssets.iconGameAudience,
    semanticLabel: 'Audience poll',
  ),
  GameFeatureButtonData(
    type: GameFeatureButtonType.aiAssistant,
    iconAsset: AppAssets.iconGameSparkle,
    semanticLabel: 'AI assistant',
  ),
  GameFeatureButtonData(
    type: GameFeatureButtonType.walkAway,
    iconAsset: AppAssets.iconGameTrophy,
    semanticLabel: 'Walk away',
    isEnabled: false,
  ),
];

const previewGameScreenData = GameScreenData(
  money: GameMoneyData(amount: '500,000 VND', animationTrigger: 1),
  question: GameQuestionData(
    questionText: 'Which technique adjusts model weights to reduce loss?',
    currentQuestionIndex: 8,
    totalQuestions: 15,
    category: 'AI Basics',
    difficulty: 'Medium',
  ),
  answers: previewGameAnswers,
  featureButtons: previewFeatureButtons,
  timer: previewGameTimer,
);

const previewAudienceItems = [
  GameAudiencePollItemData(option: 'A', percentage: '12%', progress: 0.12),
  GameAudiencePollItemData(option: 'B', percentage: '24%', progress: 0.24),
  GameAudiencePollItemData(option: 'C', percentage: '51%', progress: 0.51),
  GameAudiencePollItemData(option: 'D', percentage: '13%', progress: 0.13),
];

const previewLadderItems = [
  GameMoneyLadderItemData(
    index: 15,
    amount: '1,000,000 VND',
    isCurrent: false,
    isSpecial: true,
  ),
  GameMoneyLadderItemData(
    index: 14,
    amount: '900,000 VND',
    isCurrent: false,
    isSpecial: false,
  ),
  GameMoneyLadderItemData(
    index: 13,
    amount: '750,000 VND',
    isCurrent: true,
    isSpecial: false,
  ),
  GameMoneyLadderItemData(
    index: 10,
    amount: '400,000 VND',
    isCurrent: false,
    isSpecial: true,
  ),
  GameMoneyLadderItemData(
    index: 5,
    amount: '20,000 VND',
    isCurrent: false,
    isSpecial: true,
  ),
];

final previewSettingsItems = buildSettingItems(
  settings: previewUserSettings,
  effectiveNotificationEnabled: true,
);
