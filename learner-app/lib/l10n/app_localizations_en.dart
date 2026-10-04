// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Millionaire';

  @override
  String get settingsSemanticLabel => 'Settings';

  @override
  String get leaderboardSemanticLabel => 'Leaderboard';

  @override
  String get startGameButton => 'Start Game';

  @override
  String get accountSemanticLabel => 'Account';

  @override
  String get menuGuestName => 'Guest';

  @override
  String get menuGuestSyncHint => 'Sign in to sync';

  @override
  String get menuSyncedStatus => 'Synced';

  @override
  String get syncProgressTitle => 'Sync Your Progress';

  @override
  String get syncProgressDescription =>
      'Use your phone account to sync progress across devices.';

  @override
  String get signInWithGoogleButton => 'Sign in with Google';

  @override
  String get signInWithAppleButton => 'Sign in with Apple';

  @override
  String get signInWithEmailButton => 'Sign in with Email';

  @override
  String get continueAsGuestButton => 'Continue as Guest';

  @override
  String get emailFieldLabel => 'Email';

  @override
  String get passwordFieldLabel => 'Password';

  @override
  String get confirmPasswordFieldLabel => 'Confirm Password';

  @override
  String get backButton => 'Back';

  @override
  String get signInButton => 'Sign in';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get enterEmailPasswordError => 'Enter your email and password.';

  @override
  String get enterValidEmailError => 'Enter a valid email address.';

  @override
  String get confirmPasswordError => 'Confirm your password.';

  @override
  String get passwordMinLengthError =>
      'Use at least 6 characters for your password.';

  @override
  String get passwordsDoNotMatchError => 'Passwords do not match.';

  @override
  String get accountTitle => 'Account';

  @override
  String get signOutPrompt =>
      'Sign out and return this device to the guest profile?';

  @override
  String get signOutButton => 'Sign out';

  @override
  String profileLevel(int level) {
    return 'Level $level';
  }

  @override
  String get totalEarningsLabel => 'Total earnings';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardEmptyMessage => 'No leaderboard data yet';

  @override
  String get leaderboardLoadErrorMessage => 'Unable to load leaderboard';

  @override
  String get leaderboardLoadingMessage => 'Loading leaderboard...';

  @override
  String get retryButton => 'Retry';

  @override
  String rankSemanticLabel(int rank) {
    return 'Rank $rank';
  }

  @override
  String get gamesJoinedLabel => 'Played';

  @override
  String get gamesWonLabel => 'Won';

  @override
  String get menuWinRateLabel => 'Win rate';

  @override
  String get nextButton => 'Next';

  @override
  String get gameOverTitle => 'Game Over';

  @override
  String get moneyLadderTitle => 'Money Ladder';

  @override
  String get exitGameTitle => 'Exit Game?';

  @override
  String get exitGameMessage =>
      'Your progress will be lost. Are you sure you want to exit?';

  @override
  String get exitGameButton => 'Exit Game';

  @override
  String get continuePlayingButton => 'Continue Playing';

  @override
  String get aiExplanationsTitle => 'AI Explanations';

  @override
  String get understandButton => 'Understand';

  @override
  String get fiftyFiftySemanticLabel => '50:50';

  @override
  String get askAudienceSemanticLabel => 'Ask the Audience';

  @override
  String get askAiSemanticLabel => 'Ask AI';

  @override
  String get walkAwaySemanticLabel => 'Walk Away';

  @override
  String get exitGameSemanticLabel => 'Exit Game';

  @override
  String optionSemanticLabel(String label, String answer) {
    return 'Option $label, $answer';
  }

  @override
  String get selectedStateLabel => 'Selected';

  @override
  String get correctStateLabel => 'Correct';

  @override
  String get incorrectStateLabel => 'Incorrect';

  @override
  String prizeAmountSemanticLabel(String amount) {
    return 'Prize amount $amount';
  }

  @override
  String timeRemainingSemanticLabel(String time) {
    return 'Time remaining $time';
  }

  @override
  String get walkAwayTitle => 'Walk Away?';

  @override
  String get walkAwayMessage =>
      'You\'ll take home your current winnings and end the game. This cannot be undone.';

  @override
  String get confirmWalkAwayButton => 'Confirm Walk Away';

  @override
  String get keepPlayingButton => 'Keep Playing';

  @override
  String get aiAssistantTitle => 'AI Assistant';

  @override
  String get audienceHelpTitle => 'Audience Help';

  @override
  String get aiThinkingMessage => 'AI is thinking...';

  @override
  String get youEarnedLabel => 'You earned';

  @override
  String get congratulationsTitle => 'Congratulations';

  @override
  String get playAgainButton => 'Play Again';

  @override
  String get menuButton => 'Menu';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsSectionAudio => 'Sound & haptics';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get doneButton => 'Done';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get settingsLoadErrorMessage => 'Unable to load settings';

  @override
  String get settingsUpdateErrorMessage => 'Unable to update settings';

  @override
  String get settingsNotificationTimeUpdateErrorMessage =>
      'Unable to update notification time';

  @override
  String get settingsGuestSyncHint =>
      'Sign in to sync progress & join the leaderboard';

  @override
  String get soundSetting => 'Sound';

  @override
  String get musicSetting => 'Music';

  @override
  String get hapticSetting => 'Haptic Feedback';

  @override
  String get notificationsSetting => 'Notifications';

  @override
  String get notificationTimeSetting => 'Notification Time';

  @override
  String get settingsNotificationsHint => 'Once a day';

  @override
  String get enableNotificationsButton => 'Enable Notifications';

  @override
  String get getStartedButton => 'Get Started';

  @override
  String get maybeLaterButton => 'Maybe Later';

  @override
  String get onboardingWelcomeTitle => 'Welcome to AI Quiz!';

  @override
  String get onboardingWelcomeDescription =>
      'Test your knowledge with AI questions, earn rewards, and climb the leaderboard. Pick a language to begin.';

  @override
  String get onboardingNotificationTitle => 'Your Daily Reminder';

  @override
  String get onboardingNotificationDescription =>
      'One reminder a day so you never miss a round. No spam — change the time or turn it off anytime.';

  @override
  String get onboardingNotificationTimeLabel => 'Daily reminder time';

  @override
  String get onboardingNotificationTimeHint => 'Change it in Settings';

  @override
  String get onboardingReadyTitle => 'You\'re All Set!';

  @override
  String get onboardingReadyDescription =>
      'Your first round is waiting. Good luck!';

  @override
  String get onboardingReadyQuestionsLabel => 'questions';

  @override
  String get onboardingReadyLifelinesLabel => 'lifelines';

  @override
  String get onboardingReadyLadderLabel => 'prize ladder';

  @override
  String get onboardingSkipIntroButton => 'Skip intro';

  @override
  String get shareResultButton => 'Share Result';

  @override
  String shareResultMessage(String amount) {
    return 'I won $amount in AI Millionaire!';
  }

  @override
  String shareVictoryResultMessage(String amount, String message) {
    return 'I won $amount in AI Millionaire! $message';
  }

  @override
  String get resultCopiedSnackBar => 'Result copied to clipboard';

  @override
  String get settingsNotificationPermissionRequiredMessage =>
      'Notification permission required';

  @override
  String get closeButton => 'Close';

  @override
  String get hourPickerSemanticLabel => 'Hour picker';

  @override
  String get languageSetting => 'Language';

  @override
  String menuExpToNextLevel(String exp, int level) {
    return '$exp EXP to Level $level';
  }

  @override
  String get menuExperienceLabel => 'Experience';

  @override
  String get menuLeaderboardEntrySubtitle => 'See this week\'s top 10';

  @override
  String get menuLevelShort => 'LEVEL';

  @override
  String get menuMaxLevelReached => 'Max level reached';

  @override
  String get minutePickerSemanticLabel => 'Minute picker';

  @override
  String get saveButton => 'Save';

  @override
  String settingsIconSemanticLabel(String label) {
    return '$label icon';
  }
}
