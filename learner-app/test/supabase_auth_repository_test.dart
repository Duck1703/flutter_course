import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/repositories/auth/supabase_auth_repository.dart';
import 'package:ai_millionaire_course/services/apple_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Apple auth response preserves first-login profile fields', () {
    final session = authSessionFromAppleAuthResponse(
      AuthResponse(
        user: const User(
          id: 'apple-user',
          appMetadata: <String, dynamic>{},
          userMetadata: <String, dynamic>{},
          aud: 'authenticated',
          createdAt: '2026-06-28T00:00:00Z',
        ),
      ),
      const AppleAuthTokens(
        idToken: 'id-token',
        rawNonce: 'raw-nonce',
        email: 'apple@example.com',
        givenName: 'Apple',
        familyName: 'Player',
      ),
    );

    expect(
      session,
      const AuthSessionAuthenticated(
        uid: 'apple-user',
        email: 'apple@example.com',
        displayName: 'Apple Player',
      ),
    );
  });

  test('Apple auth response keeps Supabase user metadata when present', () {
    final session = authSessionFromAppleAuthResponse(
      AuthResponse(
        user: const User(
          id: 'apple-user',
          appMetadata: <String, dynamic>{},
          userMetadata: <String, dynamic>{
            'full_name': 'Supabase Player',
            'avatar_url': 'https://example.com/avatar.png',
          },
          aud: 'authenticated',
          email: 'supabase@example.com',
          createdAt: '2026-06-28T00:00:00Z',
        ),
      ),
      const AppleAuthTokens(
        idToken: 'id-token',
        rawNonce: 'raw-nonce',
        email: 'apple@example.com',
        givenName: 'Apple',
        familyName: 'Player',
      ),
    );

    expect(
      session,
      const AuthSessionAuthenticated(
        uid: 'apple-user',
        email: 'supabase@example.com',
        displayName: 'Supabase Player',
        photoUrl: 'https://example.com/avatar.png',
      ),
    );
  });
}
