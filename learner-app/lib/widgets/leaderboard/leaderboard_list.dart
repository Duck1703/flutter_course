import 'package:flutter/material.dart';
import '../../core/app_design_tokens.dart';
import '../../data/leaderboard/leaderboard_entry_data.dart';
import 'leaderboard_row.dart';

const _currentRowHeight = 100.0;
const _listPadding = AppTokens.dialogQzdsSpacingSm;
const _rowSpacing = AppTokens.spacingXxs;
const _currentRowMaskHeight = _currentRowHeight + _listPadding + _rowSpacing;

class LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntryData> entries;
  final LeaderboardEntryData? currentEntry;
  final Future<void> Function()? onRefresh;
  final bool isRefreshing;

  const LeaderboardList({
    super.key,
    required this.entries,
    required this.currentEntry,
    this.onRefresh,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentEntry = this.currentEntry;
    final scrollBottomInset = currentEntry == null
        ? 0.0
        : _currentRowMaskHeight;

    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          bottom: scrollBottomInset,
          left: 0,
          child: ClipRRect(
            key: const ValueKey('leaderboard-scroll-mask'),
            borderRadius: BorderRadius.circular(AppTokens.radius4),
            child: _TopRowsScrollView(entries: entries, onRefresh: onRefresh),
          ),
        ),
        if (isRefreshing)
          const Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(
              key: ValueKey('leaderboard-refresh-progress'),
              minHeight: 2,
              backgroundColor: Colors.transparent,
              color: AppTokens.yellow400,
            ),
          ),
        if (currentEntry != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(_listPadding),
              child: LeaderboardRow(
                key: const ValueKey('leaderboard-current-user-row'),
                entry: currentEntry,
                height: _currentRowHeight,
              ),
            ),
          ),
      ],
    );
  }
}

class _TopRowsScrollView extends StatelessWidget {
  final List<LeaderboardEntryData> entries;
  final Future<void> Function()? onRefresh;

  const _TopRowsScrollView({required this.entries, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final scrollView = SingleChildScrollView(
      key: const ValueKey('leaderboard-scrollable-top-rows'),
      physics: onRefresh == null ? null : const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        _listPadding,
        _listPadding,
        _listPadding,
        _listPadding,
      ),
      child: Column(
        children: [
          for (final entry in entries) ...[
            LeaderboardRow(entry: entry),
            const SizedBox(height: _rowSpacing),
          ],
        ],
      ),
    );

    if (onRefresh == null) {
      return scrollView;
    }

    return RefreshIndicator.adaptive(onRefresh: onRefresh!, child: scrollView);
  }
}
