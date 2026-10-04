// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/app_assets.dart';
import '../../data/auth/auth_session_data.dart';
import '../../data/leaderboard/leaderboard_entry_data.dart';
import '../../data/profile/user_profile_data.dart';
import '../../repositories/auth/auth_repository_contract.dart';
import '../../repositories/leaderboard/leaderboard_repository_contract.dart';
import '../../repositories/profile/user_profile_repository.dart';

class LeaderboardDialogViewModel extends ChangeNotifier {
  final LeaderboardRepository _leaderboardRepository;
  final AuthRepository _authRepository;
  final UserProfileRepository _userProfileRepository;

  LeaderboardPopupState _state = const LeaderboardPopupLoading();
  var _requestId = 0;
  var _isDisposed = false;

  LeaderboardDialogViewModel({
    required LeaderboardRepository leaderboardRepository,
    required AuthRepository authRepository,
    required UserProfileRepository userProfileRepository,
  }) : _leaderboardRepository = leaderboardRepository,
       _authRepository = authRepository,
       _userProfileRepository = userProfileRepository;

  LeaderboardPopupState get state => _state;

  Future<void> loadLeaderboard({bool isRefresh = false}) async {
    if (_isDisposed) {
      return;
    }

    final requestId = ++_requestId;
    final previousState = _state;

    if (isRefresh && previousState is LeaderboardPopupSuccess) {
      _setState(
        LeaderboardPopupSuccess(
          entries: previousState.entries,
          currentEntry: previousState.currentEntry,
          isRefreshing: true,
        ),
      );
    } else {
      _setState(const LeaderboardPopupLoading());
    }

    try {
      final snapshot = await _leaderboardRepository.loadLeaderboard(
        currentUserId: _currentLeaderboardUserId(),
      );

      if (!_isLatestRequest(requestId)) {
        return;
      }

      if (snapshot.entries.isEmpty && snapshot.currentEntry == null) {
        _setState(const LeaderboardPopupEmpty());
        return;
      }

      _setState(
        LeaderboardPopupSuccess(
          entries: snapshot.entries,
          currentEntry: _profileBackedCurrentLeaderboardEntry(
            snapshot.currentEntry,
          ),
        ),
      );
    } catch (_) {
      if (!_isLatestRequest(requestId)) {
        return;
      }

      _setState(const LeaderboardPopupError());
    }
  }

  Future<void> refresh() => loadLeaderboard(isRefresh: true);

  void retry() {
    unawaited(loadLeaderboard());
  }

  String? _currentLeaderboardUserId() {
    return switch (_authRepository.authStateStream.value) {
      AuthSessionAuthenticated(:final uid) => uid,
      AuthSessionGuest() => null,
    };
  }

  LeaderboardEntryData _currentUserLeaderboardEntry() {
    final userData = _userProfileRepository.userProfileStream.value;

    return LeaderboardEntryData(
      rank: currentLeaderboardEntry.rank,
      name: userData.username,
      level: userData.level,
      score: _formatScore(userData.totalMoneyWon),
      avatarAsset: AppAssets.avatarTauHuDiChill,
      avatarUrl: userData.avatarUrl,
      rankAsset: AppAssets.leaderboardRankCurrent,
      style: LeaderboardRowStyle.currentUser,
      isCurrentUser: true,
    );
  }

  LeaderboardEntryData _profileBackedCurrentLeaderboardEntry(
    LeaderboardEntryData? currentEntry,
  ) {
    final userData = _userProfileRepository.userProfileStream.value;

    if (currentEntry == null) {
      return _currentUserLeaderboardEntry();
    }

    return LeaderboardEntryData(
      rank: currentEntry.rank,
      name: currentEntry.name,
      level: currentEntry.level,
      score: currentEntry.score,
      avatarAsset: AppAssets.avatarTauHuDiChill,
      avatarUrl: userData.avatarUrl ?? currentEntry.avatarUrl,
      rankAsset: AppAssets.leaderboardRankCurrent,
      style: LeaderboardRowStyle.currentUser,
      isCurrentUser: true,
    );
  }

  String _formatScore(int amount) {
    return UserProfileData.formatVnd(amount).replaceAll(' VNĐ', '');
  }

  bool _isLatestRequest(int requestId) {
    return !_isDisposed && requestId == _requestId;
  }

  void _setState(LeaderboardPopupState state) {
    if (_isDisposed) {
      return;
    }

    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
