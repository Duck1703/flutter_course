// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../core/supabase_environment.dart';
import '../../data/auth/auth_session_data.dart';
import 'auth_repository_contract.dart';

/// Impl auth khi Supabase CHƯA cấu hình — M24, port nguyên văn senior
/// `repositories/auth/disabled_auth_repository.dart`.
///
/// "Guest là một session thật": stream seed `AuthSessionGuest` ngay từ
/// đầu nên mọi consumer (menu header, leaderboard uid seam) luôn đọc
/// được state hợp lệ. Mọi thao tác sign-in trả `AuthActionResult.failure`
/// với message = `configurationError` của env (vd 'Supabase is not
/// configured.') hoặc fallback 'Sign in is unavailable.' — đúng chuỗi
/// senior; UI chỉ hiển thị message, không biết lý do phía dưới.
/// `signOut` luôn success: "đăng xuất khỏi guest" là no-op vô hại.
class DisabledAuthRepository implements AuthRepository {
  final SupabaseEnvironment _environment;
  final BehaviorSubject<AuthSessionData> _authStateSubject;

  DisabledAuthRepository({required SupabaseEnvironment environment})
    : _environment = environment,
      _authStateSubject = BehaviorSubject<AuthSessionData>.seeded(
        const AuthSessionGuest(),
      );

  @override
  ValueStream<AuthSessionData> get authStateStream => _authStateSubject.stream;

  @override
  Future<AuthSessionData> loadAuthState() async => _authStateSubject.value;

  @override
  Future<AuthActionResult> signInWithGoogle() async {
    return _unavailableResult('google sign-in');
  }

  @override
  Future<AuthActionResult> signInWithApple() async {
    return _unavailableResult('apple sign-in');
  }

  @override
  Future<AuthActionResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _unavailableResult('email sign-in');
  }

  @override
  Future<AuthActionResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return _unavailableResult('email sign-up');
  }

  @override
  Future<AuthActionResult> signOut() async {
    return const AuthActionResult.success('Signed out successfully.');
  }

  String get _unavailableMessage {
    return _environment.configurationError ?? 'Sign in is unavailable.';
  }

  AuthActionResult _unavailableResult(String action) {
    debugPrint('[auth] $action unavailable: $_unavailableMessage');
    return AuthActionResult.failure(_unavailableMessage);
  }

  @override
  Future<void> dispose() => _authStateSubject.close();
}
