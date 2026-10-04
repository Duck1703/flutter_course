part of '../game_screen_view_model.dart';

extension _GameScreenViewModelResultPersistence on GameScreenViewModel {
  Future<void> _saveGameResult({
    required int earnedAmount,
    required bool isWin,
    required int questionCount,
  }) async {
    try {
      final current = await userProfileRepository.loadUserProfile();
      final nextMoneyWon = current.totalMoneyWon + earnedAmount;
      final leveledProfile = _applyLevelProgression(
        profile: current,
        gainedExp: earnedAmount,
      );

      final savedProfile = leveledProfile.copyWith(
        totalEarnings: UserProfileData.formatVnd(nextMoneyWon),
        totalMoneyWon: nextMoneyWon,
        gamesJoined: current.gamesJoined + 1,
        gamesWon: current.gamesWon + (isWin ? 1 : 0),
        totalQuestionCount: current.totalQuestionCount + questionCount,
      );

      await userProfileRepository.saveUserProfile(savedProfile);
      debugPrint('[game] result saved locally; checking profile sync');
      await _syncSavedGameResult();
    } catch (error) {
      debugPrint('Failed to save game result: $error');
    }
  }

  Future<void> _syncSavedGameResult() async {
    try {
      final session = await authRepository.loadAuthState();

      if (session is AuthSessionAuthenticated) {
        debugPrint('[game] result profile sync started');
        await profileSyncRepository.syncUserProfile(session);
        debugPrint('[game] result profile sync completed');
        return;
      }

      debugPrint('[game] result profile sync skipped; session=guest');
    } catch (error) {
      debugPrint('[game] result profile sync failed: $error');
    }
  }

  UserProfileData _applyLevelProgression({
    required UserProfileData profile,
    required int gainedExp,
  }) {
    var nextLevel = _normalizedLevel(profile.level);
    var nextExp = profile.currentExp + gainedExp;

    while (nextLevel < LevelConfig.maxLevel) {
      final expForNextLevel = LevelConfig.getExpRequiredForLevel(nextLevel);

      if (nextExp < expForNextLevel) break;

      nextExp -= expForNextLevel;
      nextLevel++;
    }

    return profile.copyWith(level: nextLevel, currentExp: nextExp);
  }

  int _normalizedLevel(int level) {
    if (level < LevelConfig.minLevel) return LevelConfig.minLevel;
    if (level > LevelConfig.maxLevel) return LevelConfig.maxLevel;
    return level;
  }
}
