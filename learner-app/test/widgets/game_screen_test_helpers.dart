import 'package:ai_millionaire_course/data/game/game_screen_data.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/navigation/app_navigation_controller.dart';
import 'package:ai_millionaire_course/repositories/auth/auth_repository_contract.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_sync_repository_contract.dart';
import 'package:ai_millionaire_course/screens/game_screen.dart';
import 'package:ai_millionaire_course/widgets/game/answers/game_answer_option.dart';
import 'package:ai_millionaire_course/widgets/game/dialogs/game_dialog_shell.dart';
import 'package:ai_millionaire_course/widgets/game/lifelines/game_feature_button.dart';
import 'package:ai_millionaire_course/widgets/game/money/game_money_ladder_cta_button.dart';
import 'package:flutter/material.dart';
import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_profile_sync_repository.dart';

Future<void> pumpGame(
  WidgetTester tester, {
  UserProfileRepository? userProfileRepository,
  AuthRepository? authRepository,
  UserProfileSyncRepository? profileSyncRepository,
  bool disableAnimations = false,
}) async {
  final repository = userProfileRepository ?? FakeGameProfileRepository();
  final auth = authRepository ?? FakeAuthRepository();
  final profileSync = profileSyncRepository ?? FakeUserProfileSyncRepository();
  final navigationController = AppNavigationController();

  if (userProfileRepository == null) {
    addTearDown(repository.dispose);
  }
  if (authRepository == null) {
    addTearDown(auth.dispose);
  }
  if (profileSyncRepository == null) {
    addTearDown(profileSync.dispose);
  }

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AppNavigationController>.value(value: navigationController),
        Provider<UserProfileRepository>.value(value: repository),
        Provider<AuthRepository>.value(value: auth),
        Provider<UserProfileSyncRepository>.value(value: profileSync),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: navigationController.navigatorKey,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: const GameScreen(),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> dismissMoneyLadder(WidgetTester tester) async {
  expect(find.text('MONEY LADDER'), findsOneWidget);
  await tester.tap(moneyLadderCta('UNDERSTAND'));
  await tester.pump(const Duration(milliseconds: 350));
}

GameAnswerState answerState(WidgetTester tester, String text) {
  return tester
      .widget<GameAnswerOption>(
        find.byWidgetPredicate(
          (widget) =>
              widget is GameAnswerOption && widget.data.answerText == text,
        ),
      )
      .data
      .state;
}

Finder answerOption(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is GameAnswerOption && widget.data.answerText == text,
  );
}

bool featureEnabled(WidgetTester tester, String label) {
  return tester
      .widget<GameFeatureButton>(
        find.byWidgetPredicate(
          (widget) =>
              widget is GameFeatureButton && widget.data.semanticLabel == label,
        ),
      )
      .data
      .isEnabled;
}

Finder dialogButton(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is GameDialogButton && widget.text == text,
  );
}

Finder moneyLadderCta(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is GameMoneyLadderCtaButton && widget.text == text,
  );
}

class FakeGameProfileRepository implements UserProfileRepository {
  final BehaviorSubject<UserProfileData> _subject;
  var saveCallCount = 0;

  FakeGameProfileRepository({
    UserProfileData initialProfile = const UserProfileData(),
  }) : _subject = BehaviorSubject<UserProfileData>.seeded(initialProfile);

  @override
  ValueStream<UserProfileData> get userProfileStream => _subject.stream;

  UserProfileData get value => _subject.value;

  @override
  Future<UserProfileData> loadUserProfile() async => _subject.value;

  @override
  Future<void> saveUserProfile(UserProfileData userData) async {
    saveCallCount++;
    _subject.add(userData);
  }

  @override
  Future<void> resetUserProfile() => saveUserProfile(const UserProfileData());

  @override
  Future<void> dispose() => _subject.close();
}
