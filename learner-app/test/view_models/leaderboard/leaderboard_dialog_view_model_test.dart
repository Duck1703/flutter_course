import 'package:ai_millionaire_course/core/app_assets.dart';
import 'package:ai_millionaire_course/data/auth/auth_session_data.dart';
import 'package:ai_millionaire_course/data/leaderboard/leaderboard_entry_data.dart';
import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/repositories/leaderboard/leaderboard_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_leaderboard_repository.dart';
import '../../helpers/leaderboard_dialog_view_model_harness.dart';

void main() {
  late LeaderboardDialogViewModelHarness harness;

  setUp(() {
    harness = LeaderboardDialogViewModelHarness()..resetPreferences();
  });

  tearDown(() => harness.dispose());

  test(
    'starts in loading state before the dialog scope triggers a load',
    () async {
      final viewModel = await harness.createViewModel();

      expect(viewModel.state, isA<LeaderboardPopupLoading>());
    },
  );

  test('loads leaderboard success state', () async {
    final leaderboardRepository = FakeLeaderboardRepository(
      snapshot: const LeaderboardSnapshot(
        entries: [leaderboardEntry],
        currentEntry: currentEntry,
      ),
    );
    final viewModel = await harness.createViewModel(
      leaderboardRepository: leaderboardRepository,
    );
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.loadLeaderboard();

    final state = viewModel.state;
    expect(state, isA<LeaderboardPopupSuccess>());
    final success = state as LeaderboardPopupSuccess;
    expect(success.entries.single.name, 'REMOTE PLAYER');
    expect(success.currentEntry?.name, 'CURRENT PLAYER');
    expect(leaderboardRepository.lastCurrentUserId, isNull);
    expect(leaderboardRepository.loadCallCount, 1);
    expect(notifications, greaterThanOrEqualTo(1));
  });

  test('shows empty leaderboard state', () async {
    final viewModel = await harness.createViewModel(
      leaderboardRepository: FakeLeaderboardRepository(
        snapshot: const LeaderboardSnapshot(entries: []),
      ),
    );

    await viewModel.loadLeaderboard();

    expect(viewModel.state, isA<LeaderboardPopupEmpty>());
  });

  test('passes auth uid for current leaderboard row', () async {
    final authRepository = FakeAuthRepository(
      initialSession: const AuthSessionAuthenticated(uid: 'user-1'),
    );
    final leaderboardRepository = FakeLeaderboardRepository(
      snapshot: const LeaderboardSnapshot(
        entries: [leaderboardEntry],
        currentEntry: currentEntry,
      ),
    );
    final viewModel = await harness.createViewModel(
      authRepository: authRepository,
      leaderboardRepository: leaderboardRepository,
    );

    await viewModel.loadLeaderboard();

    final state = viewModel.state as LeaderboardPopupSuccess;
    expect(leaderboardRepository.lastCurrentUserId, 'user-1');
    expect(state.entries.single.name, 'REMOTE PLAYER');
    expect(state.currentEntry?.name, 'CURRENT PLAYER');
    expect(state.currentEntry?.rank, 7);
  });

  test('prefers synced profile avatar for current row', () async {
    final profileRepository = await harness.createProfileRepository();
    await profileRepository.saveUserProfile(
      const UserProfileData(
        username: 'PROFILE PLAYER',
        avatarUrl: 'https://example.com/profile-avatar.png',
      ),
    );
    final viewModel = await harness.createViewModel(
      profileRepository: profileRepository,
      leaderboardRepository: FakeLeaderboardRepository(
        snapshot: const LeaderboardSnapshot(
          entries: [leaderboardEntry],
          currentEntry: LeaderboardEntryData(
            rank: 7,
            name: 'CURRENT PLAYER',
            level: 5,
            score: '5.000',
            avatarAsset: AppAssets.avatarTauHuDiChill,
            avatarUrl: 'https://example.com/leaderboard-avatar.png',
            rankAsset: AppAssets.leaderboardRankCurrent,
            style: LeaderboardRowStyle.currentUser,
            isCurrentUser: true,
          ),
        ),
      ),
    );

    await viewModel.loadLeaderboard();

    final state = viewModel.state as LeaderboardPopupSuccess;
    expect(state.currentEntry?.rank, 7);
    expect(state.currentEntry?.score, '5.000');
    expect(
      state.currentEntry?.avatarUrl,
      'https://example.com/profile-avatar.png',
    );
  });

  test('falls back to local current leaderboard row', () async {
    final profileRepository = await harness.createProfileRepository();
    await profileRepository.saveUserProfile(
      const UserProfileData(
        username: 'LOCAL PLAYER',
        level: 4,
        totalMoneyWon: 4000,
        avatarUrl: 'https://example.com/avatar.png',
      ),
    );
    final viewModel = await harness.createViewModel(
      profileRepository: profileRepository,
      leaderboardRepository: FakeLeaderboardRepository(
        snapshot: const LeaderboardSnapshot(entries: [leaderboardEntry]),
      ),
    );

    await viewModel.loadLeaderboard();

    final state = viewModel.state as LeaderboardPopupSuccess;
    expect(state.entries.single.name, 'REMOTE PLAYER');
    expect(state.currentEntry?.name, 'LOCAL PLAYER');
    expect(state.currentEntry?.level, 4);
    expect(state.currentEntry?.score, '4.000');
    expect(state.currentEntry?.avatarUrl, 'https://example.com/avatar.png');
    expect(state.currentEntry?.isCurrentUser, isTrue);
  });
}
