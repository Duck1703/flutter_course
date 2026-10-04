import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Token Apple trả cho repo — M24, port nguyên văn senior
/// `lib/services/apple_auth_service.dart` (APPENDIX lesson — iOS-only,
/// port đủ để giữ senior parity nhưng không phải core path).
///
/// `rawNonce`: nonce gốc ta tạo (Supabase cần để verify lại);
/// Apple chỉ nhận sha256(nonce) — server so hash với nonce gốc.
/// `givenName`/`familyName` chỉ có ở LẦN ĐĂNG NHẬP ĐẦU (Apple không
/// trả lại sau đó) → `displayName` gộp lại để enrich session.
class AppleAuthTokens {
  final String idToken;
  final String rawNonce;
  final String? email;
  final String? givenName;
  final String? familyName;

  const AppleAuthTokens({
    required this.idToken,
    required this.rawNonce,
    this.email,
    this.givenName,
    this.familyName,
  });

  String? get displayName {
    final parts = [
      _trimToNull(givenName),
      _trimToNull(familyName),
    ].whereType<String>().toList();

    return parts.isEmpty ? null : parts.join(' ');
  }

  static String? _trimToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

/// Contract bọc `sign_in_with_apple` — repo chỉ thấy `signIn()`.
abstract interface class AppleAuthService {
  Future<AppleAuthTokens> signIn();
}

/// Seam test: hàm gọi package được inject — test truyền requester giả
/// để kiểm nonce/scopes mà không mở Apple sheet.
typedef AppleCredentialRequester =
    Future<AuthorizationCredentialAppleID> Function({
      required List<AppleIDAuthorizationScopes> scopes,
      String? nonce,
    });

/// Flow đúng chuẩn Sign in with Apple + Supabase:
/// 1. Tạo `rawNonce` ngẫu nhiên (16 byte, base64url).
/// 2. Gửi `sha256(rawNonce)` cho Apple (Apple nhét vào idToken).
/// 3. Trả `idToken` + `rawNonce` gốc cho repo — Supabase
///    `signInWithIdToken(nonce: rawNonce)` tự hash lại và đối chiếu
///    hash trong token → chống replay.
class AppleAuthServiceImpl implements AppleAuthService {
  final String Function() _generateRawNonce;
  final AppleCredentialRequester _requestCredential;

  AppleAuthServiceImpl({
    String Function()? generateRawNonce,
    AppleCredentialRequester? requestCredential,
  }) : _generateRawNonce = generateRawNonce ?? _defaultGenerateRawNonce,
       _requestCredential = requestCredential ?? _defaultRequestCredential;

  @override
  Future<AppleAuthTokens> signIn() async {
    final rawNonce = _generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    final credential = await _requestCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );
    final idToken = credential.identityToken;

    if (idToken == null || idToken.trim().isEmpty) {
      throw StateError('Apple did not return an ID token.');
    }

    return AppleAuthTokens(
      idToken: idToken,
      rawNonce: rawNonce,
      email: credential.email,
      givenName: credential.givenName,
      familyName: credential.familyName,
    );
  }

  static Future<AuthorizationCredentialAppleID> _defaultRequestCredential({
    required List<AppleIDAuthorizationScopes> scopes,
    String? nonce,
  }) {
    return SignInWithApple.getAppleIDCredential(scopes: scopes, nonce: nonce);
  }

  static String _defaultGenerateRawNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
