import 'package:rxdart/rxdart.dart';

import '../../data/auth/auth_session_data.dart';

/// Kết quả của MỘT HÀNH ĐỘNG auth — M24, port nguyên văn senior
/// `repositories/auth/auth_repository_contract.dart`.
///
/// Khác với *state* (ai đang đăng nhập — [AuthSessionData] trên
/// stream): đây là value-type báo "lần thử vừa rồi đi thế nào" —
/// success/failure + message cho snackbar. VM dialog quyết định
/// dismiss hay giữ dialog dựa trên `isSuccess`.
class AuthActionResult {
  final bool isSuccess;
  final String message;

  const AuthActionResult._({required this.isSuccess, required this.message});

  const AuthActionResult.success(String message)
    : this._(isSuccess: true, message: message);

  const AuthActionResult.failure(String message)
    : this._(isSuccess: false, message: message);
}

/// Contract repository auth — M24, port nguyên văn senior.
///
/// "Session là state; sign-in là action": `authStateStream` giữ PHIÊN
/// hiện tại (seeded `BehaviorSubject` — cùng pattern `userProfileStream`
/// của M14, listener mới được replay ngay), còn các method signIn/signUp/
/// signOut trả [AuthActionResult] một-lần.
///
/// Hai impl senior: `AuthRepositoryImpl` (Supabase thật) và
/// `DisabledAuthRepository` (guest mode khi thiếu dart-define) —
/// `main()` chọn impl theo `supabaseClient == null` (DI có điều kiện
/// M23). Test dùng `FakeAuthRepository` viết tay — cùng một boundary.
abstract interface class AuthRepository {
  /// Stream phiên — luôn có giá trị hiện tại qua `.value`.
  ValueStream<AuthSessionData> get authStateStream;

  /// Đọc lại phiên từ nguồn (client.auth.currentUser) và emit.
  Future<AuthSessionData> loadAuthState();

  Future<AuthActionResult> signInWithGoogle();

  Future<AuthActionResult> signInWithApple();

  Future<AuthActionResult> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthActionResult> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<AuthActionResult> signOut();

  Future<void> dispose();
}
