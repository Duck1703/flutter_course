import 'package:flutter/foundation.dart';

/// Model phiên đăng nhập — M24, port nguyên văn senior
/// `lib/data/auth/auth_session_data.dart`.
///
/// Sealed union (đúng kỹ thuật M15) mô tả "bạn là AI":
/// - [AuthSessionGuest]: khách — state chính danh, KHÔNG phải null/lỗi.
///   Local profile vẫn chơi bình thường; chỉ không sync.
/// - [AuthSessionAuthenticated]: đã đăng nhập — mang `uid` (auth
///   identity, khoá ngoại vào `public.users.auth_uuid` ở M25) +
///   các field profile lấy từ provider.
///
/// Mọi `switch` trên `AuthSessionData` được compiler kiểm kiệt hợp —
/// thêm variant thứ ba mà quên xử lý là lỗi biên dịch.
@immutable
sealed class AuthSessionData {
  const AuthSessionData();

  /// `true` khi phiên hiện tại là authenticated — shortcut của
  /// `this is AuthSessionAuthenticated` cho UI (header đổi pill…).
  bool get isAuthenticated => this is AuthSessionAuthenticated;
}

final class AuthSessionGuest extends AuthSessionData {
  const AuthSessionGuest();

  @override
  bool operator ==(Object other) => other is AuthSessionGuest;

  @override
  int get hashCode => 0;
}

final class AuthSessionAuthenticated extends AuthSessionData {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const AuthSessionAuthenticated({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  bool operator ==(Object other) {
    return other is AuthSessionAuthenticated &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode => Object.hash(uid, email, displayName, photoUrl);
}
