import 'dart:async';

import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/repositories/auth/auth_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_sync_repository.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_sign_out_dialog_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_profile_sync_repository.dart';

/// Test `MenuSignOutDialogViewModel` — M24, port nguyên văn senior
/// `test/menu_sign_out_dialog_view_model_test.dart`. Ca quan trọng
/// nhất chứng minh FR-11: sign-out thành công → coordinator gọi
/// `resetUserProfile()` → profile local về defaults + emit Guest.
void main() {
  late List<UserProfileRepository> repositories;
  late List<AuthRepository> authRepositories;
  late List<UserProfileSyncRepository> profileSyncRepositories;
  late List<MenuSignOutDialogViewModel> viewModels;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repositories = [];
    authRepositories = [];
    profileSyncRepositories = [];
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

    for (final repository in profileSyncRepositories) {
      await repository.dispose();
    }
  });

  Future<UserProfileRepository> createRepository() async {
    final repository = await UserProfileRepositoryImpl.create();
    repositories.add(repository);
    return repository;
  }

  Future<MenuSignOutDialogViewModel> createViewModel({
    FakeAuthRepository? authRepository,
    UserProfileRepository? userProfileRepository,
    FakeUserProfileSyncRepository? profileSyncRepository,
  }) async {
    final auth =
        authRepository ??
        FakeAuthRepository(
          initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
        );
    final profile = userProfileRepository ?? await createRepository();
    final sync = profileSyncRepository ?? FakeUserProfileSyncRepository();
    authRepositories.add(auth);
    profileSyncRepositories.add(sync);

    final viewModel = MenuSignOutDialogViewModel(
      authRepository: auth,
      userProfileRepository: profile,
      profileSyncRepository: sync,
    );
    viewModels.add(viewModel);
    return viewModel;
  }

  test('successful sign out resets profile and requests dismiss', () async {
    final repository = await createRepository();
    await repository.saveUserProfile(
      const UserProfileData(username: 'SIGNED IN PLAYER', level: 30),
    );
    final authRepository = FakeAuthRepository(
      initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
    );
    final viewModel = await createViewModel(
      authRepository: authRepository,
      userProfileRepository: repository,
    );
    final events = <MenuSignOutDialogUiEvent>[];
    final subscription = viewModel.events.listen(events.add);

    final didSignOut = await viewModel.signOut();
    await pumpEventQueue();

    expect(didSignOut, isTrue);
    expect(authRepository.signOutCallCount, 1);
    expect(repository.userProfileStream.value, const UserProfileData());
    expect(authRepository.authStateStream.value, const AuthSessionGuest());
    expect(viewModel.isLoading, isFalse);
    expect(events.whereType<MenuSignOutDialogDismissRequested>(), hasLength(1));
    expect(
      events.whereType<MenuSignOutDialogSnackBarRequested>().single.message,
      'Signed out successfully.',
    );

    await subscription.cancel();
  });

  test('failed sign out keeps dialog and preserves profile', () async {
    final repository = await createRepository();
    const profile = UserProfileData(username: 'SIGNED IN PLAYER', level: 30);
    await repository.saveUserProfile(profile);
    final authRepository = FakeAuthRepository(
      initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
      signOutResult: const AuthActionResult.failure('Sign out failed.'),
    );
    final viewModel = await createViewModel(
      authRepository: authRepository,
      userProfileRepository: repository,
    );
    final events = <MenuSignOutDialogUiEvent>[];
    final subscription = viewModel.events.listen(events.add);

    final didSignOut = await viewModel.signOut();
    await pumpEventQueue();

    expect(didSignOut, isFalse);
    expect(authRepository.signOutCallCount, 1);
    expect(repository.userProfileStream.value, profile);
    expect(
      authRepository.authStateStream.value,
      const AuthSessionAuthenticated(uid: 'user-1'),
    );
    expect(viewModel.isLoading, isFalse);
    expect(events.whereType<MenuSignOutDialogDismissRequested>(), isEmpty);
    expect(
      events.whereType<MenuSignOutDialogSnackBarRequested>().single.message,
      'Sign out failed.',
    );

    await subscription.cancel();
  });

  test('duplicate sign out taps are ignored while loading', () async {
    final completer = Completer<AuthActionResult>();
    final authRepository = FakeAuthRepository(
      initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
      signOutCompleter: completer,
    );
    final viewModel = await createViewModel(authRepository: authRepository);

    final firstResult = viewModel.signOut();
    expect(viewModel.isLoading, isTrue);

    final secondResult = await viewModel.signOut();
    expect(secondResult, isFalse);
    expect(authRepository.signOutCallCount, 1);

    completer.complete(const AuthActionResult.success('Signed out.'));
    expect(await firstResult, isTrue);
    expect(viewModel.isLoading, isFalse);
  });
}
