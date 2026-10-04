import 'dart:async';

import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/repositories/auth/auth_repository.dart';
import 'package:rxdart/rxdart.dart';

/// Test double cho `AuthRepository` — M24, port nguyên văn senior
/// `test/helpers/fake_auth_repository.dart` (fake viết tay, không mock
/// package — đúng quy ước `FakeUserProfileRepository` của M14).
///
/// Mỗi method sign-* có ba nút điều khiển:
/// - `…Result`: `AuthActionResult` trả về ngay;
/// - `…Session`: session add vào subject KHI result success — mô phỏng
///   "repo thật emit session sau sign-in";
/// - `…Completer`: script async đang-chờ (complete sau) để test
///   single-flight của VM.
/// `…CallCount` + `lastEmail`/`lastPassword` cho assert hành vi gọi.
class FakeAuthRepository implements AuthRepository {
  final BehaviorSubject<AuthSessionData> _authStateSubject;

  AuthActionResult signInResult;
  AuthActionResult appleSignInResult;
  AuthActionResult emailSignInResult;
  AuthActionResult emailSignUpResult;
  AuthActionResult signOutResult;
  AuthSessionData signInSession;
  AuthSessionData appleSignInSession;
  AuthSessionData emailSignInSession;
  AuthSessionData emailSignUpSession;
  Completer<AuthActionResult>? signInCompleter;
  Completer<AuthActionResult>? appleSignInCompleter;
  Completer<AuthActionResult>? signOutCompleter;
  var signInCallCount = 0;
  var appleSignInCallCount = 0;
  var emailSignInCallCount = 0;
  var emailSignUpCallCount = 0;
  var signOutCallCount = 0;
  String? lastEmail;
  String? lastPassword;

  FakeAuthRepository({
    AuthSessionData initialSession = const AuthSessionGuest(),
    this.signInResult = const AuthActionResult.success(
      'Signed in successfully.',
    ),
    this.appleSignInResult = const AuthActionResult.success(
      'Signed in successfully.',
    ),
    this.emailSignInResult = const AuthActionResult.success(
      'Signed in successfully.',
    ),
    this.emailSignUpResult = const AuthActionResult.success(
      'Account created successfully.',
    ),
    this.signOutResult = const AuthActionResult.success(
      'Signed out successfully.',
    ),
    this.signInSession = const AuthSessionAuthenticated(uid: 'user-1'),
    this.appleSignInSession = const AuthSessionAuthenticated(uid: 'apple-user'),
    this.emailSignInSession = const AuthSessionAuthenticated(uid: 'user-2'),
    this.emailSignUpSession = const AuthSessionAuthenticated(uid: 'user-3'),
    this.signInCompleter,
    this.appleSignInCompleter,
    this.signOutCompleter,
  }) : _authStateSubject = BehaviorSubject<AuthSessionData>.seeded(
         initialSession,
       );

  @override
  ValueStream<AuthSessionData> get authStateStream => _authStateSubject.stream;

  @override
  Future<AuthSessionData> loadAuthState() async => _authStateSubject.value;

  @override
  Future<AuthActionResult> signInWithGoogle() async {
    signInCallCount++;
    final deferredResult = await signInCompleter?.future;

    if (deferredResult != null) {
      _emitSessionIfSuccessful(deferredResult, signInSession);
      return deferredResult;
    }

    _emitSessionIfSuccessful(signInResult, signInSession);

    return signInResult;
  }

  @override
  Future<AuthActionResult> signInWithApple() async {
    appleSignInCallCount++;
    final deferredResult = await appleSignInCompleter?.future;

    if (deferredResult != null) {
      _emitSessionIfSuccessful(deferredResult, appleSignInSession);
      return deferredResult;
    }

    _emitSessionIfSuccessful(appleSignInResult, appleSignInSession);

    return appleSignInResult;
  }

  @override
  Future<AuthActionResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emailSignInCallCount++;
    lastEmail = email;
    lastPassword = password;

    if (emailSignInResult.isSuccess) {
      _authStateSubject.add(emailSignInSession);
    }

    return emailSignInResult;
  }

  @override
  Future<AuthActionResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    emailSignUpCallCount++;
    lastEmail = email;
    lastPassword = password;

    if (emailSignUpResult.isSuccess) {
      _authStateSubject.add(emailSignUpSession);
    }

    return emailSignUpResult;
  }

  @override
  Future<AuthActionResult> signOut() async {
    signOutCallCount++;
    final deferredResult = await signOutCompleter?.future;

    if (deferredResult != null) {
      return deferredResult;
    }

    if (signOutResult.isSuccess) {
      _authStateSubject.add(const AuthSessionGuest());
    }

    return signOutResult;
  }

  @override
  Future<void> dispose() => _authStateSubject.close();

  void _emitSessionIfSuccessful(
    AuthActionResult result,
    AuthSessionData session,
  ) {
    if (result.isSuccess) {
      _authStateSubject.add(session);
    }
  }
}
