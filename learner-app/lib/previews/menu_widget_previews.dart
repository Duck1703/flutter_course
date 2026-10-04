import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';

import '../data/leaderboard/leaderboard_entry_data.dart';
import '../repositories/auth/auth_repository_contract.dart';
import '../repositories/leaderboard/leaderboard_repository_contract.dart';
import '../repositories/profile/user_profile_repository.dart';
import '../repositories/profile/user_profile_sync_repository_contract.dart';
import '../view_models/menu/menu_dialog_state.dart';
import '../view_models/menu/menu_level_progress.dart';
import '../widgets/menu/gradient_cta_button.dart';
import '../widgets/menu/leaderboard/menu_leaderboard_dialog.dart';
import '../widgets/menu/menu_dialog_backdrop.dart';
import '../widgets/menu/menu_dialog_layer.dart';
import '../widgets/menu/menu_screen_content.dart';
import '../widgets/menu/leaderboard/leaderboard_entry_card.dart';
import '../widgets/menu/profile/level_progress_card.dart';
import '../widgets/menu/profile/menu_profile_header.dart';
import '../widgets/menu/profile/earnings_card.dart';
import '../widgets/menu/profile/stats_card.dart';
import '../data/profile/user_profile_data.dart';
import '../widgets/menu/screen_bottom_inset.dart';
import '../widgets/menu/screen_top_inset.dart';
import 'preview_app_dependencies.dart';
import 'preview_fixtures.dart';

@Preview(
  name: 'Menu profile header',
  group: 'Menu',
  size: Size(390, 120),
  wrapper: previewGameApp,
)
Widget menuProfileHeaderPreview() {
  return MenuProfileHeader(
    data: previewProfile,
    isAuthenticated: true,
    onAccountTap: previewNoop,
    onSettingsTap: previewNoop,
  );
}

@Preview(
  name: 'Menu profile header guest',
  group: 'Menu',
  size: Size(390, 120),
  wrapper: previewGameApp,
)
Widget menuProfileHeaderGuestPreview() {
  return MenuProfileHeader(
    data: const UserProfileData(),
    isAuthenticated: false,
    onAccountTap: previewNoop,
    onSettingsTap: previewNoop,
  );
}

@Preview(
  name: 'Menu content',
  group: 'Menu',
  size: Size(390, 520),
  wrapper: previewGameApp,
)
Widget menuScreenContentPreview() {
  return SizedBox(
    height: 460,
    child: MenuScreenContent(
      userData: previewProfile,
      onLeaderboardTap: previewNoop,
    ),
  );
}

@Preview(
  name: 'Gradient CTA',
  group: 'Menu',
  size: Size(390, 140),
  wrapper: previewGameApp,
)
Widget gradientCtaButtonPreview() {
  return GradientCtaButton(onTap: previewNoop);
}

@Preview(
  name: 'Level progress card',
  group: 'Menu Profile',
  size: Size(390, 220),
  wrapper: previewGameApp,
)
Widget levelProgressCardPreview() {
  return LevelProgressCard(
    progress: MenuLevelProgress.fromProfile(previewProfile),
  );
}

@Preview(
  name: 'Leaderboard entry card',
  group: 'Menu',
  size: Size(390, 160),
  wrapper: previewGameApp,
)
Widget leaderboardEntryCardPreview() {
  return LeaderboardEntryCard(onTap: previewNoop);
}

@Preview(
  name: 'Earnings card',
  group: 'Menu Profile',
  size: Size(390, 180),
  wrapper: previewGameApp,
)
Widget earningsCardPreview() {
  return const EarningsCard(data: previewProfile);
}

@Preview(
  name: 'Stats card',
  group: 'Menu Profile',
  size: Size(390, 180),
  wrapper: previewGameApp,
)
Widget statsCardPreview() {
  return const StatsCard(data: previewProfile);
}

@Preview(
  name: 'Menu leaderboard dialog',
  group: 'Menu Dialogs',
  size: Size(390, 620),
  wrapper: previewGameApp,
)
Widget menuLeaderboardDialogPreview() {
  return const SizedBox(
    height: 560,
    child: MenuLeaderboardDialog(
      state: LeaderboardPopupSuccess(),
      onRefresh: null,
      onRetry: null,
    ),
  );
}

@Preview(
  name: 'Menu dialog backdrop',
  group: 'Menu Dialogs',
  size: Size(390, 760),
  wrapper: previewLayerApp,
)
Widget menuDialogBackdropPreview() {
  return MenuDialogBackdrop(
    onDismiss: previewNoop,
    child: const MenuLeaderboardDialog(
      state: LeaderboardPopupSuccess(),
      onRefresh: null,
      onRetry: null,
    ),
  );
}

@Preview(
  name: 'Menu dialog layer',
  group: 'Menu Dialogs',
  size: Size(390, 760),
  wrapper: previewLayerApp,
)
Widget menuDialogLayerPreview() {
  return MultiProvider(
    providers: [
      Provider<UserProfileRepository>(
        create: (_) => PreviewUserProfileRepository(),
      ),
      Provider<AuthRepository>(create: (_) => PreviewAuthRepository()),
      Provider<UserProfileSyncRepository>(
        create: (_) => PreviewProfileSyncRepository(),
      ),
      Provider<LeaderboardRepository>(
        create: (_) => PreviewLeaderboardRepository(),
      ),
    ],
    child: MenuDialogLayer(
      dialogState: const MenuDialogLeaderboard(),
      onDismiss: previewNoop,
    ),
  );
}

@Preview(
  name: 'Screen insets',
  group: 'Menu',
  size: Size(390, 120),
  wrapper: previewGameApp,
)
Widget screenInsetsPreview() {
  return const Column(
    mainAxisSize: MainAxisSize.min,
    children: [ScreenTopInset(), ScreenBottomInset()],
  );
}
