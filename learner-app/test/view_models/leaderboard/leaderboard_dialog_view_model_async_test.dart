import 'dart:async';

import 'package:ai_millionaire_course/data/leaderboard/leaderboard_entry_data.dart';
import 'package:ai_millionaire_course/repositories/leaderboard/leaderboard_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_leaderboard_repository.dart';
import '../../helpers/leaderboard_dialog_view_model_harness.dart';

void main() {
  late LeaderboardDialogViewModelHarness harness;

  setUp(() {
    harness = LeaderboardDialogViewModelHarness()..resetPreferences();
  });

  tearDown(() => harness.dispose());

  test('refresh preserves success rows while showing refresh state', () async {
    final initialLoad = Completer<LeaderboardSnapshot>();
    final refreshLoad = Completer<LeaderboardSnapshot>();
    final viewModel = await harness.createViewModel(
      leaderboardRepository: FakeLeaderboardRepository(
        completers: [initialLoad, refreshLoad],
      ),
    );

    final initialFuture = viewModel.loadLeaderboard();
    initialLoad.complete(
      const LeaderboardSnapshot(
        entries: [leaderboardEntry],
        currentEntry: currentEntry,
      ),
    );
    await initialFuture;

    final refreshFuture = viewModel.refresh();

    var state = viewModel.state as LeaderboardPopupSuccess;
    expect(state.isRefreshing, isTrue);
    expect(state.entries.single.name, 'REMOTE PLAYER');

    refreshLoad.complete(
      const LeaderboardSnapshot(
        entries: [secondLeaderboardEntry],
        currentEntry: currentEntry,
      ),
    );
    await refreshFuture;

    state = viewModel.state as LeaderboardPopupSuccess;
    expect(state.isRefreshing, isFalse);
    expect(state.entries.single.name, 'SECOND PLAYER');
  });

  test('stale leaderboard load cannot overwrite newer result', () async {
    final firstLoad = Completer<LeaderboardSnapshot>();
    final secondLoad = Completer<LeaderboardSnapshot>();
    final viewModel = await harness.createViewModel(
      leaderboardRepository: FakeLeaderboardRepository(
        completers: [firstLoad, secondLoad],
      ),
    );

    final staleFuture = viewModel.loadLeaderboard();
    final freshFuture = viewModel.loadLeaderboard();

    secondLoad.complete(
      const LeaderboardSnapshot(
        entries: [secondLeaderboardEntry],
        currentEntry: currentEntry,
      ),
    );
    await pumpEventQueue();

    var state = viewModel.state as LeaderboardPopupSuccess;
    expect(state.entries.single.name, 'SECOND PLAYER');

    firstLoad.complete(
      const LeaderboardSnapshot(
        entries: [leaderboardEntry],
        currentEntry: currentEntry,
      ),
    );
    await Future.wait([staleFuture, freshFuture]);

    state = viewModel.state as LeaderboardPopupSuccess;
    expect(state.entries.single.name, 'SECOND PLAYER');
  });

  test('shows retryable leaderboard error state', () async {
    final viewModel = await harness.createViewModel(
      leaderboardRepository: FakeLeaderboardRepository(
        error: Exception('nope'),
      ),
    );

    await viewModel.loadLeaderboard();

    final state = viewModel.state;
    expect(state, isA<LeaderboardPopupError>());
    expect(
      (state as LeaderboardPopupError).message,
      LeaderboardPopupMessage.loadError,
    );
  });

  test('retry starts a new load', () async {
    final leaderboardRepository = FakeLeaderboardRepository(
      snapshot: const LeaderboardSnapshot(
        entries: [leaderboardEntry],
        currentEntry: currentEntry,
      ),
    );
    final viewModel = await harness.createViewModel(
      leaderboardRepository: leaderboardRepository,
    );

    viewModel.retry();
    expect(viewModel.state, isA<LeaderboardPopupLoading>());
    await pumpEventQueue();

    expect(viewModel.state, isA<LeaderboardPopupSuccess>());
    expect(leaderboardRepository.loadCallCount, 1);
  });
}
