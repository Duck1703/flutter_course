import 'package:flutter/material.dart';

import '../../core/app_design_tokens.dart';
import '../../data/leaderboard/leaderboard_entry_data.dart';

const _avatarRingWidth = 2.0;
const _avatarRingGap = 2.0;
const _avatarRingSize = 52.0;

class LeaderboardAvatar extends StatelessWidget {
  final LeaderboardEntryData entry;

  const LeaderboardAvatar({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final ringInset = _ringInset(entry);

    return SizedBox.square(
      dimension: _avatarRingSize,
      child: DecoratedBox(
        key: ValueKey('leaderboard-avatar-ring-${entry.rank}'),
        decoration: _ringDecoration(entry),
        child: Padding(
          key: ValueKey('leaderboard-avatar-gap-${entry.rank}'),
          padding: EdgeInsets.all(ringInset),
          child: ClipOval(child: _AvatarImage(entry: entry)),
        ),
      ),
    );
  }

  BoxDecoration _ringDecoration(LeaderboardEntryData entry) {
    final color = _ringColor(entry);

    return BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color, width: _avatarRingWidth),
      boxShadow: [BoxShadow(color: _ringGlowColor(entry), blurRadius: 8)],
    );
  }

  double _ringInset(LeaderboardEntryData entry) {
    return _avatarRingWidth + (_isCurrentUserEntry(entry) ? 0 : _avatarRingGap);
  }

  bool _isCurrentUserEntry(LeaderboardEntryData entry) {
    return entry.isCurrentUser ||
        entry.style == LeaderboardRowStyle.currentUser;
  }

  Color _ringColor(LeaderboardEntryData entry) {
    if (_isCurrentUserEntry(entry)) {
      return AppTokens.green400;
    }

    return switch (entry.rank) {
      1 => AppTokens.yellow400,
      2 => AppTokens.mint500,
      3 => const Color(0xFFFF8A00),
      4 => AppTokens.purple300,
      5 => const Color(0xFFFF5FA2),
      6 => const Color(0xFF64B5F6),
      7 => const Color(0xFFA3E635),
      8 => const Color(0xFFFFD166),
      9 => const Color(0xFFB388FF),
      10 => const Color(0xFF2DD4BF),
      _ => AppTokens.white50,
    };
  }

  Color _ringGlowColor(LeaderboardEntryData entry) {
    if (_isCurrentUserEntry(entry)) {
      return const Color(0x6689E87F);
    }

    return switch (entry.rank) {
      1 => const Color(0x66FACC15),
      2 => const Color(0x6600E0FF),
      3 => const Color(0x66FF8A00),
      4 => const Color(0x66AA9BFF),
      5 => const Color(0x66FF5FA2),
      6 => const Color(0x6664B5F6),
      7 => const Color(0x66A3E635),
      8 => const Color(0x66FFD166),
      9 => const Color(0x66B388FF),
      10 => const Color(0x662DD4BF),
      _ => AppTokens.white20,
    };
  }
}

class _AvatarImage extends StatelessWidget {
  final LeaderboardEntryData entry;

  const _AvatarImage({required this.entry});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _validAvatarUrl(entry.avatarUrl);

    if (avatarUrl == null) {
      return _fallbackAvatar();
    }

    return Image.network(
      avatarUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _initialAvatar(),
    );
  }

  String? _validAvatarUrl(String? value) {
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

  Widget _fallbackAvatar() {
    if (entry.isCurrentUser ||
        entry.style == LeaderboardRowStyle.currentUser ||
        entry.avatarUrl != null) {
      return _initialAvatar();
    }

    return _assetAvatar();
  }

  Widget _assetAvatar() {
    return Image.asset(entry.avatarAsset, fit: BoxFit.cover);
  }

  Widget _initialAvatar() {
    return DecoratedBox(
      key: ValueKey('leaderboard-avatar-initial-${entry.rank}'),
      decoration: const BoxDecoration(color: Color(0x3322C55E)),
      child: Center(
        child: Text(
          _initial(entry.name),
          style: AppTokens.body4.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _initial(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '?';
    }

    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }
}
