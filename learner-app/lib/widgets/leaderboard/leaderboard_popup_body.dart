import 'package:flutter/material.dart';

import '../../core/app_design_tokens.dart';
import '../../data/leaderboard/leaderboard_entry_data.dart';
import '../../l10n/app_localizations.dart';
import 'leaderboard_list.dart';

const double _errorGlyphSize = 32;
const double _retryButtonMinWidth = 96;

class LeaderboardPopupBody extends StatelessWidget {
  final LeaderboardPopupState state;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onRetry;

  const LeaderboardPopupBody({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (state) {
      LeaderboardPopupSuccess(
        :final entries,
        :final currentEntry,
        :final isRefreshing,
      ) =>
        LeaderboardList(
          entries: entries,
          currentEntry: currentEntry,
          isRefreshing: isRefreshing,
          onRefresh: onRefresh,
        ),
      LeaderboardPopupEmpty(:final message) => _LeaderboardMessage(
        message: _messageText(l10n, message),
      ),
      LeaderboardPopupError(:final message) => _LeaderboardErrorMessage(
        message: _messageText(l10n, message),
        onRetry: onRetry,
      ),
      LeaderboardPopupLoading(:final message) => _LeaderboardLoadingMessage(
        message: _messageText(l10n, message),
      ),
    };
  }

  String _messageText(AppLocalizations l10n, LeaderboardPopupMessage message) {
    return switch (message) {
      LeaderboardPopupMessage.empty => l10n.leaderboardEmptyMessage,
      LeaderboardPopupMessage.loadError => l10n.leaderboardLoadErrorMessage,
      LeaderboardPopupMessage.loading => l10n.leaderboardLoadingMessage,
    };
  }
}

class _LeaderboardMessage extends StatelessWidget {
  final String message;

  const _LeaderboardMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spacingLg),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTokens.qzdsSubtitle2.copyWith(color: AppTokens.white100),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _LeaderboardErrorMessage({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: _errorGlyphSize,
              color: AppTokens.white100.withValues(alpha: 0.55),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTokens.qzdsSubtitle2.copyWith(
                color: AppTokens.white100,
              ),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            TextButton.icon(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppTokens.white100,
                backgroundColor: AppTokens.white20,
                minimumSize: const Size(
                  _retryButtonMinWidth,
                  AppTokens.qzdsButtonHeight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.qzdsRadiusMd),
                ),
              ),
              icon: const Icon(
                Icons.refresh,
                size: AppTokens.qzdsIconSm,
                color: AppTokens.white100,
              ),
              label: Text(
                l10n.retryButton.toUpperCase(),
                style: AppTokens.body5.copyWith(color: AppTokens.white100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardLoadingMessage extends StatelessWidget {
  final String message;

  const _LeaderboardLoadingMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: AppTokens.qzdsIconMd,
            height: AppTokens.qzdsIconMd,
            child: CircularProgressIndicator(
              key: ValueKey('leaderboard-loading-progress'),
              color: AppTokens.white100,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: AppTokens.spacingSm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTokens.qzdsSubtitle2.copyWith(color: AppTokens.white100),
          ),
        ],
      ),
    );
  }
}
