import 'dart:async';

import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/repositories/auth/auth_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_sync_repository.dart';
import 'package:ai_millionaire_course/view_models/menu/menu_auth_dialog_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_profile_sync_repository.dart';

void main() {
  late List<UserProfileRepository> repositories;
  late List<AuthRepository> authRepositories;
  late List<UserProfileSyncRepository> profileSyncRepositories;
  late List<MenuAuthDialogViewModel> viewModels;

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

  Future<MenuAuthDialogViewModel> createViewModel({
    FakeAuthRepository? authRepository,
    FakeUserProfileSyncRepository? profileSyncRepository,
  }) async {
    final auth = authRepository ?? FakeAuthRepository();
    final sync = profileSyncRepository ?? FakeUserProfileSyncRepository();
    authRepositories.add(auth);
    profileSyncRepositories.add(sync);

    final viewModel = MenuAuthDialogViewModel(
      authRepository: auth,
      userProfileRepository: await createRepository(),
      profileSyncRepository: sync,
    );
    viewModels.add(viewModel);
    return viewModel;
  }

  test(
    'successful Google sign in syncs profile and requests dismiss',
    () async {
      final authRepository = FakeAuthRepository(
        signInSession: const AuthSessionAuthenticated(
          uid: 'user-1',
          email: 'player@example.com',
        ),
      );
      final syncRepository = FakeUserProfileSyncRepository();
      final viewModel = await createViewModel(
        authRepository: authRepository,
        profileSyncRepository: syncRepository,
      );
      final events = <MenuAuthDialogUiEvent>[];
      final subscription = viewModel.events.listen(events.add);

      final didSignIn = await viewModel.signInWithGoogle();
      await pumpEventQueue();

      expect(didSignIn, isTrue);
      expect(authRepository.signInCallCount, 1);
      expect(syncRepository.syncCallCount, 1);
      expect(syncRepository.lastSyncedSession?.uid, 'user-1');
      expect(viewModel.isLoading, isFalse);
      expect(events.whereType<MenuAuthDialogDismissRequested>(), hasLength(1));
      expect(
        events.whereType<MenuAuthDialogSnackBarRequested>().single.message,
        'Signed in successfully.',
      );

      await subscription.cancel();
    },
  );

  test('failed Google sign in keeps auth dialog and skips sync', () async {
    final authRepository = FakeAuthRepository(
      signInResult: const AuthActionResult.failure('Sign in failed.'),
    );
    final syncRepository = FakeUserProfileSyncRepository();
    final viewModel = await createViewModel(
      authRepository: authRepository,
      profileSyncRepository: syncRepository,
    );
    final events = <MenuAuthDialogUiEvent>[];
    final subscription = viewModel.events.listen(events.add);

    final didSignIn = await viewModel.signInWithGoogle();
    await pumpEventQueue();

    expect(didSignIn, isFalse);
    expect(authRepository.signInCallCount, 1);
    expect(syncRepository.syncCallCount, 0);
    expect(viewModel.isLoading, isFalse);
    expect(events.whereType<MenuAuthDialogDismissRequested>(), isEmpty);
    expect(
      events.whereType<MenuAuthDialogSnackBarRequested>().single.message,
      'Sign in failed.',
    );

    await subscription.cancel();
  });

  test('successful Apple sign in syncs profile and requests dismiss', () async {
    final authRepository = FakeAuthRepository(
      appleSignInSession: const AuthSessionAuthenticated(
        uid: 'apple-user',
        email: 'apple@example.com',
        displayName: 'Apple Player',
      ),
    );
    final syncRepository = FakeUserProfileSyncRepository();
    final viewModel = await createViewModel(
      authRepository: authRepository,
      profileSyncRepository: syncRepository,
    );
    final events = <MenuAuthDialogUiEvent>[];
    final subscription = viewModel.events.listen(events.add);

    final didSignIn = await viewModel.signInWithApple();
    await pumpEventQueue();

    expect(didSignIn, isTrue);
    expect(authRepository.appleSignInCallCount, 1);
    expect(syncRepository.syncCallCount, 1);
    expect(syncRepository.lastSyncedSession?.uid, 'apple-user');
    expect(syncRepository.lastSyncedSession?.displayName, 'Apple Player');
    expect(viewModel.isLoading, isFalse);
    expect(events.whereType<MenuAuthDialogDismissRequested>(), hasLength(1));
    expect(
      events.whereType<MenuAuthDialogSnackBarRequested>().single.message,
      'Signed in successfully.',
    );

    await subscription.cancel();
  });

  test('failed Apple sign in keeps auth dialog and skips sync', () async {
    final authRepository = FakeAuthRepository(
      appleSignInResult: const AuthActionResult.failure(
        'Sign in was cancelled.',
      ),
    );
    final syncRepository = FakeUserProfileSyncRepository();
    final viewModel = await createViewModel(
      authRepository: authRepository,
      profileSyncRepository: syncRepository,
    );
    final events = <MenuAuthDialogUiEvent>[];
    final subscription = viewModel.events.listen(events.add);

    final didSignIn = await viewModel.signInWithApple();
    await pumpEventQueue();

    expect(didSignIn, isFalse);
    expect(authRepository.appleSignInCallCount, 1);
    expect(syncRepository.syncCallCount, 0);
    expect(viewModel.isLoading, isFalse);
    expect(events.whereType<MenuAuthDialogDismissRequested>(), isEmpty);
    expect(
      events.whereType<MenuAuthDialogSnackBarRequested>().single.message,
      'Sign in was cancelled.',
    );

    await subscription.cancel();
  });

  test('duplicate social taps are blocked while Apple sign in loads', () async {
    final authRepository = FakeAuthRepository(
      appleSignInCompleter: Completer<AuthActionResult>(),
    );
    final viewModel = await createViewModel(authRepository: authRepository);

    final firstSignIn = viewModel.signInWithApple();
    await pumpEventQueue();
    final secondSignIn = await viewModel.signInWithApple();

    expect(secondSignIn, isFalse);
    expect(authRepository.appleSignInCallCount, 1);
    expect(viewModel.isLoading, isTrue);

    authRepository.appleSignInCompleter!.complete(
      const AuthActionResult.success('Signed in successfully.'),
    );

    expect(await firstSignIn, isTrue);
    expect(viewModel.isLoading, isFalse);
  });

  test('successful email sign in syncs profile and requests dismiss', () async {
    final authRepository = FakeAuthRepository(
      emailSignInSession: const AuthSessionAuthenticated(
        uid: 'email-user',
        email: 'player@example.com',
      ),
    );
    final syncRepository = FakeUserProfileSyncRepository();
    final viewModel = await createViewModel(
      authRepository: authRepository,
      profileSyncRepository: syncRepository,
    );
    final events = <MenuAuthDialogUiEvent>[];
    final subscription = viewModel.events.listen(events.add);

    final didSignIn = await viewModel.signInWithEmail(
      email: 'player@example.com',
      password: 'password123',
    );
    await pumpEventQueue();

    expect(didSignIn, isTrue);
    expect(authRepository.emailSignInCallCount, 1);
    expect(authRepository.lastEmail, 'player@example.com');
    expect(authRepository.lastPassword, 'password123');
    expect(syncRepository.syncCallCount, 1);
    expect(syncRepository.lastSyncedSession?.uid, 'email-user');
    expect(events.whereType<MenuAuthDialogDismissRequested>(), hasLength(1));
    expect(
      events.whereType<MenuAuthDialogSnackBarRequested>().single.message,
      'Signed in successfully.',
    );

    await subscription.cancel();
  });

  test('failed email sign in keeps auth dialog and skips sync', () async {
    final authRepository = FakeAuthRepository(
      emailSignInResult: const AuthActionResult.failure('Sign in failed.'),
    );
    final syncRepository = FakeUserProfileSyncRepository();
    final viewModel = await createViewModel(
      authRepository: authRepository,
      profileSyncRepository: syncRepository,
    );
    final events = <MenuAuthDialogUiEvent>[];
    final subscription = viewModel.events.listen(events.add);

    final didSignIn = await viewModel.signInWithEmail(
      email: 'player@example.com',
      password: 'bad-password',
    );
    await pumpEventQueue();

    expect(didSignIn, isFalse);
    expect(authRepository.emailSignInCallCount, 1);
    expect(syncRepository.syncCallCount, 0);
    expect(viewModel.isLoading, isFalse);
    expect(events.whereType<MenuAuthDialogDismissRequested>(), isEmpty);

    await subscription.cancel();
  });

  test('email signup with authenticated session syncs profile', () async {
    final authRepository = FakeAuthRepository(
      emailSignUpSession: const AuthSessionAuthenticated(
        uid: 'new-email-user',
        email: 'new@example.com',
      ),
    );
    final syncRepository = FakeUserProfileSyncRepository();
    final viewModel = await createViewModel(
      authRepository: authRepository,
      profileSyncRepository: syncRepository,
    );
    final events = <MenuAuthDialogUiEvent>[];
    final subscription = viewModel.events.listen(events.add);

    final didSignUp = await viewModel.signUpWithEmail(
      email: 'new@example.com',
      password: 'password123',
    );
    await pumpEventQueue();

    expect(didSignUp, isTrue);
    expect(authRepository.emailSignUpCallCount, 1);
    expect(syncRepository.syncCallCount, 1);
    expect(syncRepository.lastSyncedSession?.uid, 'new-email-user');
    expect(viewModel.isLoading, isFalse);
    expect(events.whereType<MenuAuthDialogDismissRequested>(), hasLength(1));

    await subscription.cancel();
  });

  test(
    'email signup without active session dismisses dialog without sync',
    () async {
      final authRepository = FakeAuthRepository(
        emailSignUpResult: const AuthActionResult.success(
          'Check your email to confirm your account.',
        ),
        emailSignUpSession: const AuthSessionGuest(),
      );
      final syncRepository = FakeUserProfileSyncRepository();
      final viewModel = await createViewModel(
        authRepository: authRepository,
        profileSyncRepository: syncRepository,
      );
      final events = <MenuAuthDialogUiEvent>[];
      final subscription = viewModel.events.listen(events.add);

      final didSignUp = await viewModel.signUpWithEmail(
        email: 'new@example.com',
        password: 'password123',
      );
      await pumpEventQueue();

      expect(didSignUp, isTrue);
      expect(authRepository.emailSignUpCallCount, 1);
      expect(syncRepository.syncCallCount, 0);
      expect(events.whereType<MenuAuthDialogDismissRequested>(), hasLength(1));
      expect(
        events.whereType<MenuAuthDialogSnackBarRequested>().single.message,
        'Check your email to confirm your account.',
      );

      await subscription.cancel();
    },
  );

  test('sign in completion after dispose does not notify listeners', () async {
    final authRepository = FakeAuthRepository(
      signInCompleter: Completer<AuthActionResult>(),
    );
    final viewModel = await createViewModel(authRepository: authRepository);
    var notifications = 0;

    viewModel.addListener(() => notifications++);
    final signInFuture = viewModel.signInWithGoogle();
    await pumpEventQueue();
    viewModel.dispose();
    viewModels.remove(viewModel);
    authRepository.signInCompleter!.complete(
      const AuthActionResult.success('Signed in successfully.'),
    );

    expect(await signInFuture, isFalse);
    expect(notifications, 1);
  });
}
