import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/profile/user_profile_data.dart';

/// Circular profile picture shared by the menu header pill and the settings
/// account row.
///
/// Guests always see the bundled avatar. Authenticated users see their remote
/// photo when the URL is usable, and a first-letter fallback otherwise.
class ProfileAvatarImage extends StatelessWidget {
  final UserProfileData data;
  final bool isAuthenticated;
  final double size;

  const ProfileAvatarImage({
    super.key,
    required this.data,
    required this.isAuthenticated,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox.square(dimension: size, child: _image()),
    );
  }

  Widget _image() {
    if (!isAuthenticated) {
      return Image.asset(
        AppAssets.avatar,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    final avatarUrl = _validAvatarUrl(data.avatarUrl);

    if (avatarUrl == null) {
      return _initialAvatar();
    }

    return Image.network(
      avatarUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _initialAvatar(),
    );
  }

  Widget _initialAvatar() {
    return DecoratedBox(
      key: const ValueKey('menu-profile-avatar-initial'),
      decoration: const BoxDecoration(color: Color(0x3322C55E)),
      child: Center(
        child: Text(
          _initial(data.username),
          style: AppTokens.headline5.copyWith(
            color: AppTokens.white100,
            fontSize: size * 0.46,
          ),
        ),
      ),
    );
  }

  static String? _validAvatarUrl(String? value) {
    if (value == null) {
      return null;
    }

    final uri = Uri.tryParse(value.trim());

    if (uri == null || uri.host.isEmpty) {
      return null;
    }

    return switch (uri.scheme) {
      'http' || 'https' => uri.toString(),
      _ => null,
    };
  }

  static String _initial(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '?';
    }

    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }
}
