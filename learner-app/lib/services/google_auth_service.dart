// ignore_for_file: prefer_initializing_formals

import 'package:google_sign_in/google_sign_in.dart';

import '../core/supabase_environment.dart';

/// Cặp token Google trả về cho repo — M24, port nguyên văn senior
/// `lib/services/google_auth_service.dart`. `idToken` là thứ Supabase
/// cần (`signInWithIdToken`); `accessToken` đi kèm khi scope được cấp.
class GoogleAuthTokens {
  final String idToken;
  final String? accessToken;

  const GoogleAuthTokens({required this.idToken, this.accessToken});
}

/// Contract mỏng bọc `google_sign_in` — repo chỉ thấy `signIn()` trả
/// tokens (null = user cancel), không thấy API package. `signOut()`
/// tách khỏi Supabase signOut để xoá luôn phiên Google phía thiết bị.
abstract interface class GoogleAuthService {
  Future<GoogleAuthTokens?> signIn();

  Future<void> signOut();
}

/// Impl trên `google_sign_in` **v7** — API mới hoàn toàn so với v6:
/// KHÔNG còn `GoogleSignIn().signIn()` legacy; phải `initialize()` một
/// lần rồi `GoogleSignIn.instance.authenticate(scopeHint:)`.
///
/// - `initialize(clientId:, serverClientId:)`: clientId iOS +
///   serverClientId (Web client id — Supabase verify idToken bằng nó)
///   đọc từ dart-define qua [SupabaseEnvironment]; chuỗi rỗng → null.
/// - `authenticate(scopeHint:)`: mở flow chọn tài khoản; trả
///   `GoogleSignInAccount` → `account.authentication.idToken` là
///   idToken cho Supabase.
/// - `authorizationForScopes`/`authorizeScopes`: lấy accessToken cho
///   scope đã xin (best-effort — Supabase chỉ bắt buộc idToken).
///
/// Lỗi package ném `GoogleSignInException` — repo bắt và map sang
/// `AuthActionResult` (cancel → 'Sign in was cancelled.').
class GoogleAuthServiceImpl implements GoogleAuthService {
  static const _scopes = ['email', 'profile'];

  final SupabaseEnvironment _environment;
  var _isInitialized = false;

  GoogleAuthServiceImpl({required SupabaseEnvironment environment})
    : _environment = environment;

  @override
  Future<GoogleAuthTokens?> signIn() async {
    await _initialize();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw StateError('Google sign-in is not supported on this platform.');
    }

    final account = await GoogleSignIn.instance.authenticate(
      scopeHint: _scopes,
    );
    final idToken = account.authentication.idToken;

    if (idToken == null || idToken.trim().isEmpty) {
      throw StateError('Google did not return an ID token.');
    }

    final authorization =
        await account.authorizationClient.authorizationForScopes(_scopes) ??
        await account.authorizationClient.authorizeScopes(_scopes);

    return GoogleAuthTokens(
      idToken: idToken,
      accessToken: authorization.accessToken,
    );
  }

  @override
  Future<void> signOut() async {
    await _initialize();
    await GoogleSignIn.instance.signOut();
  }

  /// `initialize` chỉ được gọi ĐÚNG MỘT LẦN (v7 requirement) — cờ
  /// `_isInitialized` chặn gọi lại ở mọi lần sign-in/sign-out sau.
  Future<void> _initialize() async {
    if (_isInitialized) {
      return;
    }

    await GoogleSignIn.instance.initialize(
      clientId: _emptyToNull(_environment.googleIosClientId),
      serverClientId: _emptyToNull(_environment.googleWebClientId),
    );
    _isInitialized = true;
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
