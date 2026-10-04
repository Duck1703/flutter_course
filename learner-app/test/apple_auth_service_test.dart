import 'dart:convert';

import 'package:ai_millionaire_course/services/apple_auth_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

void main() {
  test(
    'Apple service hashes nonce and returns first-login profile fields',
    () async {
      String? capturedNonce;
      late List<AppleIDAuthorizationScopes> capturedScopes;
      final service = AppleAuthServiceImpl(
        generateRawNonce: () => 'raw-nonce',
        requestCredential: ({required scopes, nonce}) async {
          capturedScopes = scopes;
          capturedNonce = nonce;
          return const AuthorizationCredentialAppleID(
            userIdentifier: 'apple-user',
            givenName: 'Apple',
            familyName: 'Player',
            authorizationCode: 'auth-code',
            email: 'apple@example.com',
            identityToken: 'id-token',
            state: null,
          );
        },
      );

      final tokens = await service.signIn();

      expect(capturedScopes, [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);
      expect(
        capturedNonce,
        sha256.convert(utf8.encode('raw-nonce')).toString(),
      );
      expect(tokens.idToken, 'id-token');
      expect(tokens.rawNonce, 'raw-nonce');
      expect(tokens.email, 'apple@example.com');
      expect(tokens.displayName, 'Apple Player');
    },
  );

  test('Apple service rejects credentials without an ID token', () async {
    final service = AppleAuthServiceImpl(
      generateRawNonce: () => 'raw-nonce',
      requestCredential: ({required scopes, nonce}) async {
        return const AuthorizationCredentialAppleID(
          userIdentifier: 'apple-user',
          givenName: null,
          familyName: null,
          authorizationCode: 'auth-code',
          email: null,
          identityToken: null,
          state: null,
        );
      },
    );

    expect(service.signIn(), throwsStateError);
  });
}
