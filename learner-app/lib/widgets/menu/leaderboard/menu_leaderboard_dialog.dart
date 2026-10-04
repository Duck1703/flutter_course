import 'package:flutter/material.dart';
import '../../../core/app_design_tokens.dart';
import '../../../data/leaderboard/leaderboard_entry_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../leaderboard/leaderboard_popup_body.dart';

const _composeYellow500 = Color(0xFFFFC107);
const _frameBorderGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0x4DFFFFFF), Color(0xE6FFFFFF), Color(0x4DFFFFFF)],
);
const _dialogShellKey = ValueKey('leaderboard-dialog-shell');
const _frameBorderKey = ValueKey('leaderboard-transparent-frame-border');
const _compactHeightThreshold = 480.0;
const _compactWidthThreshold = 340.0;
const _outsideDismissInset = AppTokens.spacingXl;

class MenuLeaderboardDialog extends StatelessWidget {
  final LeaderboardPopupState state;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onRetry;

  const MenuLeaderboardDialog({
    super.key,
    this.state = const LeaderboardPopupSuccess(),
    this.onRefresh,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          key: _dialogShellKey,
          width: _resolveWidth(constraints.maxWidth),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: _resolveMaxHeight(constraints.maxHeight),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _LeaderboardDialogTitle(),
                const SizedBox(height: AppTokens.spacingXxs),
                Flexible(
                  child: _LeaderboardDialogFrame(
                    state: state,
                    onRefresh: onRefresh,
                    onRetry: onRetry,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _resolveMaxHeight(double availableHeight) {
    if (!availableHeight.isFinite ||
        availableHeight <= _compactHeightThreshold) {
      return availableHeight;
    }

    return availableHeight - (_outsideDismissInset * 2);
  }

  double? _resolveWidth(double availableWidth) {
    if (!availableWidth.isFinite || availableWidth <= _compactWidthThreshold) {
      return null;
    }

    return availableWidth - (_outsideDismissInset * 2);
  }
}

class _LeaderboardDialogFrame extends StatelessWidget {
  final LeaderboardPopupState state;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onRetry;

  const _LeaderboardDialogFrame({
    required this.state,
    required this.onRefresh,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: _frameBorderKey,
      foregroundPainter: _LeaderboardFrameBorderPainter(),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.leaderboardDialogBorderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            AppTokens.radius4 - AppTokens.leaderboardDialogBorderWidth,
          ),
          child: AnimatedSwitcher(
            duration: AppTokens.dialogMotionLong,
            reverseDuration: AppTokens.motionMedium,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.linear,
            child: LeaderboardPopupBody(
              key: ValueKey(state.runtimeType),
              state: state,
              onRefresh: onRefresh,
              onRetry: onRetry,
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardFrameBorderPainter extends CustomPainter {
  const _LeaderboardFrameBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = AppTokens.leaderboardDialogBorderWidth;
    final rect = Offset.zero & size;
    final borderRect = rect.deflate(strokeWidth / 2);
    final borderRadius = Radius.circular(AppTokens.radius4 - strokeWidth / 2);
    final paint = Paint()
      ..shader = _frameBorderGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(RRect.fromRectAndRadius(borderRect, borderRadius), paint);
  }

  @override
  bool shouldRepaint(covariant _LeaderboardFrameBorderPainter oldDelegate) {
    return false;
  }
}

class _LeaderboardDialogTitle extends StatelessWidget {
  const _LeaderboardDialogTitle();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTokens.leaderboardDialogTitleHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radius4),
        color: _composeYellow500,
        boxShadow: const [
          BoxShadow(
            color: Color(0xE0FFFDE7),
            blurRadius: AppTokens.spacingMd,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Text(
        AppLocalizations.of(context).leaderboardTitle.toUpperCase(),
        style: AppTokens.headline5.copyWith(
          color: AppTokens.white100,
          shadows: const [Shadow(color: Color(0xFFFFFDE7), blurRadius: 12)],
        ),
      ),
    );
  }
}
