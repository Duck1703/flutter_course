// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/auth/auth_session_data.dart';
import '../../services/apple_auth_service.dart';
import '../../services/google_auth_service.dart';
import 'auth_repository_contract.dart';

/// Impl auth trên Supabase — M24, port nguyên văn senior
/// `repositories/auth/supabase_auth_repository.dart`.
///
/// Ba nguồn cấp session, một đầu ra:
/// - Subject seed từ `client.auth.currentUser` (session sót lại từ
///   lần mở app trước — Supabase lưu session trong storage).
/// - `onAuthStateChange` listener trong ctor: MỌI thay đổi auth phía
///   Supabase (token refresh, signOut từ nơi khác…) tự emit về stream.
/// - Mỗi method sign-* gọi API rồi `_emit` session map từ response.
///
/// `_sessionFromUser` map `User` → `AuthSessionData`: uid + email trực
/// tiếp; displayName/photoUrl lấy phòng thủ từ `userMetadata`
/// (`full_name`/`name`, `avatar_url`/`picture`) qua `_metadataString` —
/// metadata provider nào cũng có thể thiếu/khác key.
///
/// `_sessionProfileOverride` (appendix, Apple): Apple chỉ trả tên/email
/// ở LẦN ĐẦU đăng nhập; khi Supabase session về sau thiếu các field đó,
/// override lưu session đã enrich và `_applySessionProfileOverride`
/// vá lại mỗi emit. `signOut` xoá override.
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;
  final GoogleAuthService _googleAuthService;
  final AppleAuthService _appleAuthService;
  final BehaviorSubject<AuthSessionData> _authStateSubject;
  late final StreamSubscription<AuthState> _authSubscription;
  AuthSessionAuthenticated? _sessionProfileOverride;

  AuthRepositoryImpl({
    required SupabaseClient client,
    required GoogleAuthService googleAuthService,
    required AppleAuthService appleAuthService,
  }) : _client = client,
       _googleAuthService = googleAuthService,
       _appleAuthService = appleAuthService,
       _authStateSubject = BehaviorSubject<AuthSessionData>.seeded(
         _sessionFromUser(client.auth.currentUser),
       ) {
    _authSubscription = _client.auth.onAuthStateChange.listen(
      (state) => _emit(
        _applySessionProfileOverride(_sessionFromUser(state.session?.user)),
      ),
      onError: (_) => _emit(const AuthSessionGuest()),
    );
  }

  @override
  ValueStream<AuthSessionData> get authStateStream => _authStateSubject.stream;

  @override
  Future<AuthSessionData> loadAuthState() async {
    final session = _applySessionProfileOverride(
      _sessionFromUser(_client.auth.currentUser),
    );
    _emit(session);
    return session;
  }

  /// Google: `GoogleAuthService.signIn()` lấy idToken (+accessToken),
  /// rồi `client.auth.signInWithIdToken(provider: OAuthProvider.google)`
  /// đổi token Google lấy session Supabase. null tokens = user cancel.
  /// `GoogleSignInException` được map riêng: `canceled` → message
  /// 'Sign in was cancelled.' giống các nhánh cancel khác.
  @override
  Future<AuthActionResult> signInWithGoogle() async {
    try {
      final tokens = await _googleAuthService.signIn();

      if (tokens == null) {
        return const AuthActionResult.failure('Sign in was cancelled.');
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: tokens.idToken,
        accessToken: tokens.accessToken,
      );
      _emit(_sessionFromAuthResponse(response));
      return const AuthActionResult.success('Signed in successfully.');
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return const AuthActionResult.failure('Sign in was cancelled.');
      }

      return AuthActionResult.failure('Sign in failed: ${error.description}');
    } on AuthException catch (error) {
      return AuthActionResult.failure('Sign in failed: ${error.message}');
    } catch (error) {
      return AuthActionResult.failure('Sign in failed: $error');
    }
  }

  /// Apple (appendix — iOS only): idToken + rawNonce →
  /// `signInWithIdToken(provider: OAuthProvider.apple, nonce:)`.
  @override
  Future<AuthActionResult> signInWithApple() async {
    try {
      final tokens = await _appleAuthService.signIn();
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: tokens.idToken,
        nonce: tokens.rawNonce,
      );
      _emit(_sessionFromAppleAuthResponse(response, tokens));
      return const AuthActionResult.success('Signed in successfully.');
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return const AuthActionResult.failure('Sign in was cancelled.');
      }

      return AuthActionResult.failure('Sign in failed: ${error.message}');
    } on SignInWithAppleException catch (error) {
      return AuthActionResult.failure('Sign in failed: $error');
    } on AuthException catch (error) {
      return AuthActionResult.failure('Sign in failed: ${error.message}');
    } catch (error) {
      return AuthActionResult.failure('Sign in failed: $error');
    }
  }

  @override
  Future<AuthActionResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      _emit(_sessionFromAuthResponse(response));
      return const AuthActionResult.success('Signed in successfully.');
    } on AuthException catch (error) {
      return AuthActionResult.failure('Sign in failed: ${error.message}');
    } catch (error) {
      return AuthActionResult.failure('Sign in failed: $error');
    }
  }

  /// Đăng ký email: `signUp` có thể KHÔNG tạo session ngay (khi project
  /// bật confirm-email) → `_sessionFromActiveSession` chỉ lấy
  /// `response.session` — session guest thì trả success kèm message
  /// 'Check your email to confirm your account.' (đúng senior).
  @override
  Future<AuthActionResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      final session = _sessionFromActiveSession(response);
      _emit(session);

      return session is AuthSessionAuthenticated
          ? const AuthActionResult.success('Account created successfully.')
          : const AuthActionResult.success(
              'Check your email to confirm your account.',
            );
    } on AuthException catch (error) {
      return AuthActionResult.failure('Sign up failed: ${error.message}');
    } catch (error) {
      return AuthActionResult.failure('Sign up failed: $error');
    }
  }

  /// Sign-out: `client.auth.signOut()` → clear override + emit Guest,
  /// rồi best-effort `googleAuthService.signOut()` để xoá phiên Google
  /// trên thiết bị (lỗi ở bước này KHÔNG làm kết quả thất bại).
  @override
  Future<AuthActionResult> signOut() async {
    try {
      await _client.auth.signOut();
      _sessionProfileOverride = null;
      _emit(const AuthSessionGuest());

      try {
        await _googleAuthService.signOut();
      } catch (_) {
        return const AuthActionResult.success('Signed out successfully.');
      }

      return const AuthActionResult.success('Signed out successfully.');
    } on AuthException catch (error) {
      return AuthActionResult.failure('Sign out failed: ${error.message}');
    } catch (error) {
      return AuthActionResult.failure('Sign out failed: $error');
    }
  }

  void _emit(AuthSessionData state) {
    if (!_authStateSubject.isClosed && _authStateSubject.value != state) {
      _authStateSubject.add(state);
    }
  }

  AuthSessionData _sessionFromAuthResponse(AuthResponse response) {
    return _sessionFromUser(
      response.session?.user ?? response.user ?? _client.auth.currentUser,
    );
  }

  AuthSessionData _sessionFromAppleAuthResponse(
    AuthResponse response,
    AppleAuthTokens tokens,
  ) {
    final enrichedSession = authSessionFromAppleAuthResponse(
      response,
      tokens,
      fallbackUser: _client.auth.currentUser,
    );

    if (enrichedSession is AuthSessionAuthenticated) {
      _sessionProfileOverride = enrichedSession;
    }

    return enrichedSession;
  }

  AuthSessionData _sessionFromActiveSession(AuthResponse response) {
    return _sessionFromUser(response.session?.user ?? _client.auth.currentUser);
  }

  AuthSessionData _applySessionProfileOverride(AuthSessionData session) {
    final override = _sessionProfileOverride;
    if (session is! AuthSessionAuthenticated || override?.uid != session.uid) {
      return session;
    }

    return AuthSessionAuthenticated(
      uid: session.uid,
      email: session.email ?? override?.email,
      displayName: session.displayName ?? override?.displayName,
      photoUrl: session.photoUrl ?? override?.photoUrl,
    );
  }

  static AuthSessionData _sessionFromUser(User? user) {
    if (user == null) {
      return const AuthSessionGuest();
    }

    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final displayName =
        _metadataString(metadata, 'full_name') ??
        _metadataString(metadata, 'name');
    final photoUrl =
        _metadataString(metadata, 'avatar_url') ??
        _metadataString(metadata, 'picture');

    return AuthSessionAuthenticated(
      uid: user.id,
      email: user.email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  static String? _metadataString(Map<String, dynamic> metadata, String key) {
    final value = metadata[key];

    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }

  @override
  Future<void> dispose() async {
    await _authSubscription.cancel();
    await _authStateSubject.close();
  }
}

/// Mapping Apple response → session, enrich bằng token fields —
/// top-level function (senior verbatim) để test gọi trực tiếp mà không
/// dựng `SupabaseClient` (seam test của `supabase_auth_repository_test`).
///
/// Apple chỉ gửi email/tên ở LẦN ĐẦU: session từ Supabase user thiếu
/// `email`/`displayName` thì bù bằng `tokens.email`/`tokens.displayName`;
/// `photoUrl` Apple không cung cấp nên giữ nguyên của session.
AuthSessionData authSessionFromAppleAuthResponse(
  AuthResponse response,
  AppleAuthTokens tokens, {
  User? fallbackUser,
}) {
  final session = AuthRepositoryImpl._sessionFromUser(
    response.session?.user ?? response.user ?? fallbackUser,
  );

  if (session is! AuthSessionAuthenticated) {
    return session;
  }

  return AuthSessionAuthenticated(
    uid: session.uid,
    email: session.email ?? tokens.email,
    displayName: session.displayName ?? tokens.displayName,
    photoUrl: session.photoUrl,
  );
}
