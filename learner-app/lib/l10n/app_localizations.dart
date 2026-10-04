import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Millionaire'**
  String get appTitle;

  /// No description provided for @settingsSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsSemanticLabel;

  /// No description provided for @leaderboardSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardSemanticLabel;

  /// No description provided for @startGameButton.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGameButton;

  /// No description provided for @accountSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSemanticLabel;

  /// No description provided for @menuGuestName.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get menuGuestName;

  /// No description provided for @menuGuestSyncHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync'**
  String get menuGuestSyncHint;

  /// No description provided for @menuSyncedStatus.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get menuSyncedStatus;

  /// No description provided for @syncProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync Your Progress'**
  String get syncProgressTitle;

  /// No description provided for @syncProgressDescription.
  ///
  /// In en, this message translates to:
  /// **'Use your phone account to sync progress across devices.'**
  String get syncProgressDescription;

  /// No description provided for @signInWithGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogleButton;

  /// No description provided for @signInWithAppleButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithAppleButton;

  /// No description provided for @signInWithEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get signInWithEmailButton;

  /// No description provided for @continueAsGuestButton.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuestButton;

  /// No description provided for @emailFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailFieldLabel;

  /// No description provided for @passwordFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordFieldLabel;

  /// No description provided for @confirmPasswordFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordFieldLabel;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @enterEmailPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password.'**
  String get enterEmailPasswordError;

  /// No description provided for @enterValidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get enterValidEmailError;

  /// No description provided for @confirmPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password.'**
  String get confirmPasswordError;

  /// No description provided for @passwordMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters for your password.'**
  String get passwordMinLengthError;

  /// No description provided for @passwordsDoNotMatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatchError;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @signOutPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign out and return this device to the guest profile?'**
  String get signOutPrompt;

  /// No description provided for @signOutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutButton;

  /// No description provided for @profileLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String profileLevel(int level);

  /// No description provided for @totalEarningsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total earnings'**
  String get totalEarningsLabel;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No leaderboard data yet'**
  String get leaderboardEmptyMessage;

  /// No description provided for @leaderboardLoadErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to load leaderboard'**
  String get leaderboardLoadErrorMessage;

  /// No description provided for @leaderboardLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading leaderboard...'**
  String get leaderboardLoadingMessage;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @rankSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank}'**
  String rankSemanticLabel(int rank);

  /// No description provided for @gamesJoinedLabel.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get gamesJoinedLabel;

  /// No description provided for @gamesWonLabel.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get gamesWonLabel;

  /// No description provided for @menuWinRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get menuWinRateLabel;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @gameOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOverTitle;

  /// No description provided for @moneyLadderTitle.
  ///
  /// In en, this message translates to:
  /// **'Money Ladder'**
  String get moneyLadderTitle;

  /// No description provided for @exitGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Game?'**
  String get exitGameTitle;

  /// No description provided for @exitGameMessage.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be lost. Are you sure you want to exit?'**
  String get exitGameMessage;

  /// No description provided for @exitGameButton.
  ///
  /// In en, this message translates to:
  /// **'Exit Game'**
  String get exitGameButton;

  /// No description provided for @continuePlayingButton.
  ///
  /// In en, this message translates to:
  /// **'Continue Playing'**
  String get continuePlayingButton;

  /// No description provided for @aiExplanationsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Explanations'**
  String get aiExplanationsTitle;

  /// No description provided for @understandButton.
  ///
  /// In en, this message translates to:
  /// **'Understand'**
  String get understandButton;

  /// No description provided for @fiftyFiftySemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'50:50'**
  String get fiftyFiftySemanticLabel;

  /// No description provided for @askAudienceSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask the Audience'**
  String get askAudienceSemanticLabel;

  /// No description provided for @askAiSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get askAiSemanticLabel;

  /// No description provided for @walkAwaySemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Walk Away'**
  String get walkAwaySemanticLabel;

  /// No description provided for @exitGameSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Exit Game'**
  String get exitGameSemanticLabel;

  /// No description provided for @optionSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Option {label}, {answer}'**
  String optionSemanticLabel(String label, String answer);

  /// No description provided for @selectedStateLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selectedStateLabel;

  /// No description provided for @correctStateLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correctStateLabel;

  /// No description provided for @incorrectStateLabel.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrectStateLabel;

  /// No description provided for @prizeAmountSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Prize amount {amount}'**
  String prizeAmountSemanticLabel(String amount);

  /// No description provided for @timeRemainingSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Time remaining {time}'**
  String timeRemainingSemanticLabel(String time);

  /// No description provided for @walkAwayTitle.
  ///
  /// In en, this message translates to:
  /// **'Walk Away?'**
  String get walkAwayTitle;

  /// No description provided for @walkAwayMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ll take home your current winnings and end the game. This cannot be undone.'**
  String get walkAwayMessage;

  /// No description provided for @confirmWalkAwayButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Walk Away'**
  String get confirmWalkAwayButton;

  /// No description provided for @keepPlayingButton.
  ///
  /// In en, this message translates to:
  /// **'Keep Playing'**
  String get keepPlayingButton;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistantTitle;

  /// No description provided for @audienceHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Audience Help'**
  String get audienceHelpTitle;

  /// No description provided for @aiThinkingMessage.
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get aiThinkingMessage;

  /// No description provided for @youEarnedLabel.
  ///
  /// In en, this message translates to:
  /// **'You earned'**
  String get youEarnedLabel;

  /// No description provided for @congratulationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations'**
  String get congratulationsTitle;

  /// No description provided for @playAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgainButton;

  /// No description provided for @menuButton.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsSectionAudio.
  ///
  /// In en, this message translates to:
  /// **'Sound & haptics'**
  String get settingsSectionAudio;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAccount;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @settingsLoadErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to load settings'**
  String get settingsLoadErrorMessage;

  /// No description provided for @settingsUpdateErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to update settings'**
  String get settingsUpdateErrorMessage;

  /// No description provided for @settingsNotificationTimeUpdateErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to update notification time'**
  String get settingsNotificationTimeUpdateErrorMessage;

  /// No description provided for @settingsGuestSyncHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync progress & join the leaderboard'**
  String get settingsGuestSyncHint;

  /// No description provided for @soundSetting.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundSetting;

  /// No description provided for @musicSetting.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get musicSetting;

  /// No description provided for @hapticSetting.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticSetting;

  /// No description provided for @notificationsSetting.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSetting;

  /// No description provided for @notificationTimeSetting.
  ///
  /// In en, this message translates to:
  /// **'Notification Time'**
  String get notificationTimeSetting;

  /// No description provided for @settingsNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Once a day'**
  String get settingsNotificationsHint;

  /// No description provided for @enableNotificationsButton.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotificationsButton;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedButton;

  /// No description provided for @maybeLaterButton.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLaterButton;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AI Quiz!'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge with AI questions, earn rewards, and climb the leaderboard. Pick a language to begin.'**
  String get onboardingWelcomeDescription;

  /// No description provided for @onboardingNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Daily Reminder'**
  String get onboardingNotificationTitle;

  /// No description provided for @onboardingNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'One reminder a day so you never miss a round. No spam — change the time or turn it off anytime.'**
  String get onboardingNotificationDescription;

  /// No description provided for @onboardingNotificationTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder time'**
  String get onboardingNotificationTimeLabel;

  /// No description provided for @onboardingNotificationTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Change it in Settings'**
  String get onboardingNotificationTimeHint;

  /// No description provided for @onboardingReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'\'re All Set!'**
  String get onboardingReadyTitle;

  /// No description provided for @onboardingReadyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your first round is waiting. Good luck!'**
  String get onboardingReadyDescription;

  /// No description provided for @onboardingReadyQuestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get onboardingReadyQuestionsLabel;

  /// No description provided for @onboardingReadyLifelinesLabel.
  ///
  /// In en, this message translates to:
  /// **'lifelines'**
  String get onboardingReadyLifelinesLabel;

  /// No description provided for @onboardingReadyLadderLabel.
  ///
  /// In en, this message translates to:
  /// **'prize ladder'**
  String get onboardingReadyLadderLabel;

  /// No description provided for @onboardingSkipIntroButton.
  ///
  /// In en, this message translates to:
  /// **'Skip intro'**
  String get onboardingSkipIntroButton;

  /// No description provided for @shareResultButton.
  ///
  /// In en, this message translates to:
  /// **'Share Result'**
  String get shareResultButton;

  /// No description provided for @shareResultMessage.
  ///
  /// In en, this message translates to:
  /// **'I won {amount} in AI Millionaire!'**
  String shareResultMessage(String amount);

  /// No description provided for @shareVictoryResultMessage.
  ///
  /// In en, this message translates to:
  /// **'I won {amount} in AI Millionaire! {message}'**
  String shareVictoryResultMessage(String amount, String message);

  /// No description provided for @resultCopiedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Result copied to clipboard'**
  String get resultCopiedSnackBar;

  /// No description provided for @settingsNotificationPermissionRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Notification permission required'**
  String get settingsNotificationPermissionRequiredMessage;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @hourPickerSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Hour picker'**
  String get hourPickerSemanticLabel;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// No description provided for @menuExpToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'{exp} EXP to Level {level}'**
  String menuExpToNextLevel(String exp, int level);

  /// No description provided for @menuExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get menuExperienceLabel;

  /// No description provided for @menuLeaderboardEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'See this week\'\'s top 10'**
  String get menuLeaderboardEntrySubtitle;

  /// No description provided for @menuLevelShort.
  ///
  /// In en, this message translates to:
  /// **'LEVEL'**
  String get menuLevelShort;

  /// No description provided for @menuMaxLevelReached.
  ///
  /// In en, this message translates to:
  /// **'Max level reached'**
  String get menuMaxLevelReached;

  /// No description provided for @minutePickerSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Minute picker'**
  String get minutePickerSemanticLabel;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @settingsIconSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'{label} icon'**
  String settingsIconSemanticLabel(String label);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
