import 'package:ai_millionaire_course/core/app_assets.dart';
import 'package:ai_millionaire_course/data/leaderboard/leaderboard_entry_data.dart';
import 'package:ai_millionaire_course/repositories/auth/auth_repository.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:ai_millionaire_course/view_models/leaderboard/leaderboard_dialog_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth_repository.dart';
import 'fake_leaderboard_repository.dart';

class LeaderboardDialogViewModelHarness {
  final List<UserProfileRepository> profileRepositories = [];
  final List<AuthRepository> authRepositories = [];
  final List<LeaderboardDialogViewModel> viewModels = [];

  void resetPreferences() {
    SharedPreferences.setMockInitialValues({});
  }

  Future<void> dispose() async {
    for (final viewModel in viewModels) {
      viewModel.dispose();
    }

    for (final repository in profileRepositories) {
      await repository.dispose();
    }

    for (final repository in authRepositories) {
      await repository.dispose();
    }
  }

  Future<UserProfileRepository> createProfileRepository() async {
    final repository = await UserProfileRepositoryImpl.create();
    profileRepositories.add(repository);
    return repository;
  }

  Future<LeaderboardDialogViewModel> createViewModel({
    UserProfileRepository? profileRepository,
    FakeAuthRepository? authRepository,
    FakeLeaderboardRepository? leaderboardRepository,
  }) async {
    final profile = profileRepository ?? await createProfileRepository();
    final auth = authRepository ?? FakeAuthRepository();
    authRepositories.add(auth);
    final viewModel = LeaderboardDialogViewModel(
      leaderboardRepository:
          leaderboardRepository ?? FakeLeaderboardRepository(),
      authRepository: auth,
      userProfileRepository: profile,
    );
    viewModels.add(viewModel);
    return viewModel;
  }
}

const leaderboardEntry = LeaderboardEntryData(
  rank: 1,
  name: 'REMOTE PLAYER',
  level: 9,
  score: '9.000',
  avatarAsset: AppAssets.avatarMitUotChayTask,
  rankAsset: AppAssets.leaderboardRank1,
  style: LeaderboardRowStyle.first,
);

const secondLeaderboardEntry = LeaderboardEntryData(
  rank: 2,
  name: 'SECOND PLAYER',
  level: 8,
  score: '8.000',
  avatarAsset: AppAssets.avatarLopTruongBiNgo,
  rankAsset: AppAssets.leaderboardRank2,
  style: LeaderboardRowStyle.second,
);

const currentEntry = LeaderboardEntryData(
  rank: 7,
  name: 'CURRENT PLAYER',
  level: 5,
  score: '5.000',
  avatarAsset: AppAssets.avatarTauHuDiChill,
  rankAsset: AppAssets.leaderboardRankCurrent,
  style: LeaderboardRowStyle.currentUser,
  isCurrentUser: true,
);
