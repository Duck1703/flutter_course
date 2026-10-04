import 'dart:convert';

import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/repositories/auth/auth_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_dialog_state.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_screen_ui_event.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_screen_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  late SharedPreferences preferences;
  late List<UserProfileRepository> repositories;
  late List<AuthRepository> authRepositories;
  late List<MenuScreenViewModel> viewModels;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    repositories = [];
    authRepositories = [];
    viewModels = [];
  });

  tearDown(() async {
    for (final viewModel in viewModels) {
      viewModel.dispose();
    }

    for (final repository in repositories) {
      await repository.dispose();
    }

    for (final repository in authRepositories) {
      await repository.dispose();
    }
  });

  Future<UserProfileRepository> createRepository() async {
    final repository = await UserProfileRepositoryImpl.create();
    repositories.add(repository);
    return repository;
  }

  MenuScreenViewModel createViewModel(
    UserProfileRepository repository, {
    FakeAuthRepository? authRepository,
  }) {
    final auth = authRepository ?? FakeAuthRepository();
    authRepositories.add(auth);
    final viewModel = MenuScreenViewModel(
      userProfileRepository: repository,
      authRepository: auth,
    );
    viewModels.add(viewModel);
    return viewModel;
  }

  test(
    'menu view model exposes default user data from repository stream',
    () async {
      final viewModel = createViewModel(await createRepository());

      expect(viewModel.userData.username, '0XFF');
      expect(viewModel.userData.level, 1);
      expect(viewModel.userData.currentExp, 0);
      expect(viewModel.userData.totalEarnings, '0 VNĐ');
      expect(viewModel.userData.gamesJoined, 0);
      expect(viewModel.userData.gamesWon, 0);
    },
  );

  test('menu view model emits game action event', () async {
    final viewModel = createViewModel(await createRepository());
    final events = <MenuScreenUiEvent>[];
    final subscription = viewModel.events.listen(events.add);

    viewModel.requestGame();
    await pumpEventQueue();

    expect(events.single, isA<MenuGameRequested>());

    await subscription.cancel();
    viewModel.dispose();
    viewModels.remove(viewModel);
  });

  test('menu view model starts with no active dialog', () async {
    final viewModel = createViewModel(await createRepository());

    expect(viewModel.dialogState, const MenuDialogNone());
    expect(viewModel.dialogState.isVisible, isFalse);
  });

  test('menu view model opens leaderboard dialog once', () async {
    var notifications = 0;

    final viewModel = createViewModel(await createRepository());
    viewModel.addListener(() => notifications++);
    viewModel.requestLeaderboardDialog();
    viewModel.requestLeaderboardDialog();

    expect(viewModel.dialogState, const MenuDialogLeaderboard());
    expect(viewModel.dialogState.isVisible, isTrue);
    expect(notifications, 1);
  });

  test('menu view model dismisses current dialog once', () async {
    final viewModel = createViewModel(await createRepository());
    var notifications = 0;

    viewModel.requestLeaderboardDialog();
    viewModel.addListener(() => notifications++);
    viewModel.dismissCurrentDialog();
    viewModel.dismissCurrentDialog();

    expect(viewModel.dialogState, const MenuDialogNone());
    expect(notifications, 1);
  });

  test('menu view model opens auth dialog for guests', () async {
    final viewModel = createViewModel(await createRepository());

    viewModel.requestAuthAction();

    expect(viewModel.dialogState, const MenuDialogAuth());
  });

  test(
    'menu view model opens sign out dialog for authenticated users',
    () async {
      final authRepository = FakeAuthRepository(
        initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
      );
      final viewModel = createViewModel(
        await createRepository(),
        authRepository: authRepository,
      );

      viewModel.requestAuthAction();

      expect(viewModel.dialogState, const MenuDialogSignOut());
    },
  );

  test('menu view model mirrors repository profile stream changes', () async {
    final repository = await createRepository();
    final viewModel = createViewModel(repository);
    var notifications = 0;
    const updatedUserData = UserProfileData(username: 'PLAYER TWO');

    viewModel.addListener(() => notifications++);
    await repository.saveUserProfile(updatedUserData);
    await pumpEventQueue();

    expect(viewModel.userData.username, 'PLAYER TWO');
    expect(notifications, 1);
  });

  test('menu view model does not notify when user data is unchanged', () async {
    final repository = await createRepository();
    final viewModel = createViewModel(repository);
    var notifications = 0;

    viewModel.addListener(() => notifications++);
    await repository.saveUserProfile(const UserProfileData());
    await pumpEventQueue();

    expect(notifications, 0);
  });

  test('user profile data round-trips through a map', () {
    const userData = UserProfileData(
      username: 'PLAYER TWO',
      level: 3,
      totalEarnings: '2.500 VNĐ',
      gamesJoined: 7,
      gamesWon: 4,
    );

    expect(UserProfileData.fromMap(userData.toMap()), userData);
  });

  test('user profile data parses legacy earnings into sync money', () {
    final userData = UserProfileData.fromMap({
      'username': 'LEGACY PLAYER',
      'level': 3,
      'totalEarnings': '2.500 VNĐ',
      'gamesJoined': 7,
      'gamesWon': 4,
    });

    expect(userData.totalEarnings, '2.500 VNĐ');
    expect(userData.totalMoneyWon, 2500);
  });

  test('user profile data falls back from invalid map values', () {
    final userData = UserProfileData.fromMap({
      'username': '',
      'level': -1,
      'totalEarnings': '',
      'gamesJoined': 'bad',
      'gamesWon': -2,
    });

    expect(userData, const UserProfileData());
  });

  test('user profile data normalizes exact legacy demo profile', () {
    final userData = UserProfileData.fromMap({
      'username': 'TÀU HỦ ĐI CHILL',
      'level': 12,
      'totalEarnings': '1.000.000 VNĐ',
      'currentExp': 0,
      'totalQuestionCount': 0,
      'totalMoneyWon': 1000000,
      'gamesJoined': 20,
      'gamesWon': 12,
    });

    expect(userData, const UserProfileData());
  });

  test('repository loads default profile when preferences are empty', () async {
    final repository = await createRepository();

    expect(await repository.loadUserProfile(), const UserProfileData());
    expect(repository.userProfileStream.value, const UserProfileData());
  });

  test('repository factory creates independent profile streams', () async {
    final results = await Future.wait([createRepository(), createRepository()]);

    expect(identical(results.first, results.last), isFalse);
    expect(results.first.userProfileStream.value, const UserProfileData());
    expect(results.last.userProfileStream.value, const UserProfileData());
  });

  test('repository falls back when cached profile is not a map', () async {
    await preferences.setString('user_profile', jsonEncode(['bad']));
    final repository = await createRepository();

    expect(await repository.loadUserProfile(), const UserProfileData());
    expect(repository.userProfileStream.value, const UserProfileData());
  });

  test('repository saves and loads profile data', () async {
    final repository = await createRepository();
    const userData = UserProfileData(
      username: 'CACHE PLAYER',
      level: 8,
      totalEarnings: '8.000 VNĐ',
      gamesJoined: 9,
      gamesWon: 5,
    );

    await repository.saveUserProfile(userData);

    expect(repository.userProfileStream.value, userData);
    expect(await repository.loadUserProfile(), userData);
  });

  test('repository falls back when cached profile is corrupt', () async {
    await preferences.setString('user_profile', 'not-json');
    final repository = await createRepository();

    expect(await repository.loadUserProfile(), const UserProfileData());
    expect(repository.userProfileStream.value, const UserProfileData());
  });

  test('repository emits cached profile when loaded', () async {
    const userData = UserProfileData(username: 'STREAM CACHE');
    await preferences.setString('user_profile', jsonEncode(userData.toMap()));
    final repository = await createRepository();

    final emission = expectLater(
      repository.userProfileStream.skip(1),
      emits(userData),
    );
    await repository.loadUserProfile();

    await emission;
    expect(repository.userProfileStream.value, userData);
  });

  test('repository does not emit when profile value is unchanged', () async {
    final repository = await createRepository();
    final emissions = <UserProfileData>[];
    final subscription = repository.userProfileStream
        .skip(1)
        .listen(emissions.add);

    await repository.saveUserProfile(const UserProfileData());
    await pumpEventQueue();

    expect(emissions, isEmpty);

    await subscription.cancel();
  });

  test('menu view model notifies when cached profile loads', () async {
    const userData = UserProfileData(username: 'CACHE PLAYER');
    await preferences.setString('user_profile', jsonEncode(userData.toMap()));
    final repository = await createRepository();
    final viewModel = createViewModel(repository);
    var notifications = 0;

    viewModel.addListener(() => notifications++);
    await viewModel.loadUserProfile();

    expect(viewModel.userData, userData);
    expect(notifications, 1);
  });

  test('menu view model ignores repository emissions after dispose', () async {
    final repository = await createRepository();
    final viewModel = createViewModel(repository);

    viewModel.dispose();
    viewModels.remove(viewModel);
    await repository.saveUserProfile(
      const UserProfileData(username: 'LATE PLAYER'),
    );
    await pumpEventQueue();

    expect(viewModel.userData, const UserProfileData());
  });
}
