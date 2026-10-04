// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../data/auth/auth_session_data.dart';
import '../../repositories/auth/auth_repository_contract.dart';
import '../../repositories/profile/user_profile_repository.dart';
import '../../repositories/profile/user_profile_sync_repository_contract.dart';

/// Bộ điều phối hành động auth cho các dialog VM — M24, port nguyên
/// văn senior `view_models/menu/menu_auth_action_coordinator.dart`.
///
/// Vì sao có lớp này thay vì dialog VM gọi repo trực tiếp? MỘT chuỗi
/// "sign-in thành công" thật sự gồm 3 bước:
///   signIn* → loadAuthState → (authenticated) → syncUserProfile
/// và chuỗi "sign-out" gồm:
///   signOut → resetUserProfile (profile local về mặc định — đây là
///   nơi semantics nút reset cũ của M10 dời đến; FR-11/FR-12).
/// Coordinator giữ chuỗi đó một chỗ — cả `MenuAuthDialogViewModel` lẫn
/// `MenuSignOutDialogViewModel` đều dùng, không ai copy nửa chuỗi.
///
/// Guard quan trọng trong `_signInAndSync`: repo báo SUCCESS nhưng
/// `loadAuthState` vẫn guest → trả `failure('no active session')`.
/// Sign-in không tạo được session thì không coi là đăng nhập —
/// exercise DEBUG của lesson cố tình xoá guard này.
///
/// `syncUserProfile` chạy vào `UserProfileSyncRepository` contract —
/// `main()` chọn `UserProfileSyncRepositoryImpl` (merge + upsert
/// `public.users`, M25) khi đủ cấu hình, còn
/// `UserProfileSyncRepositoryDisabled` (no-op) khi unconfigured.
class MenuAuthActionCoordinator {
  final AuthRepository _authRepository;
  final UserProfileRepository _userProfileRepository;
  final UserProfileSyncRepository _profileSyncRepository;

  const MenuAuthActionCoordinator({
    required AuthRepository authRepository,
    required UserProfileRepository userProfileRepository,
    required UserProfileSyncRepository profileSyncRepository,
  }) : _authRepository = authRepository,
       _userProfileRepository = userProfileRepository,
       _profileSyncRepository = profileSyncRepository;

  Future<AuthActionResult> signInWithGoogle() async {
    return _signInAndSync('google sign-in', _authRepository.signInWithGoogle);
  }

  Future<AuthActionResult> signInWithApple() async {
    return _signInAndSync('apple sign-in', _authRepository.signInWithApple);
  }

  Future<AuthActionResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    debugPrint(
      '[auth] email sign-in requested '
      'emailPresent=${email.trim().isNotEmpty} '
      'emailHasAt=${email.trim().contains('@')}',
    );
    return _signInAndSync(
      'email sign-in',
      () => _authRepository.signInWithEmail(email: email, password: password),
    );
  }

  /// Đăng ký khác sign-in ở một chỗ: repo có thể trả success mà KHÔNG
  /// có session (confirm-email) — khi đó vẫn trả result gốc, chỉ sync
  /// profile nếu session thật sự authenticated (đúng nhánh senior).
  Future<AuthActionResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    debugPrint(
      '[auth] email sign-up requested '
      'emailPresent=${email.trim().isNotEmpty} '
      'emailHasAt=${email.trim().contains('@')} '
      'passwordMeetsMinimum=${password.length >= 6}',
    );
    final result = await _authRepository.signUpWithEmail(
      email: email,
      password: password,
    );
    debugPrint(
      '[auth] email sign-up repository result '
      'success=${result.isSuccess} message="${result.message}"',
    );

    if (!result.isSuccess) {
      return result;
    }

    final session = await _authRepository.loadAuthState();
    debugPrint('[auth] email sign-up session=${_sessionLabel(session)}');

    if (session is AuthSessionAuthenticated) {
      await _profileSyncRepository.syncUserProfile(session);
      debugPrint('[auth] email sign-up profile sync completed');
    }

    return result;
  }

  Future<AuthActionResult> _signInAndSync(
    String label,
    Future<AuthActionResult> Function() signIn,
  ) async {
    final result = await signIn();
    debugPrint(
      '[auth] $label repository result '
      'success=${result.isSuccess} message="${result.message}"',
    );

    if (!result.isSuccess) {
      return result;
    }

    final session = await _authRepository.loadAuthState();
    debugPrint('[auth] $label session=${_sessionLabel(session)}');

    if (session is! AuthSessionAuthenticated) {
      return const AuthActionResult.failure(
        'Sign in failed: no active session.',
      );
    }

    await _profileSyncRepository.syncUserProfile(session);
    debugPrint('[auth] $label profile sync completed');
    return result;
  }

  /// Sign-out → trên success: `resetUserProfile()` (thiết bị về hồ sơ
  /// khách — hành vi cuối cùng của nút "ĐẶT LẠI HỒ SƠ" M10 sau khi
  /// scaffold retire, FR-11).
  Future<AuthActionResult> signOut() async {
    final result = await _authRepository.signOut();
    debugPrint(
      '[auth] sign-out repository result '
      'success=${result.isSuccess} message="${result.message}"',
    );

    if (result.isSuccess) {
      await _userProfileRepository.resetUserProfile();
    }

    return result;
  }

  String _sessionLabel(AuthSessionData session) {
    return switch (session) {
      AuthSessionAuthenticated() => 'authenticated',
      AuthSessionGuest() => 'guest',
    };
  }
}
