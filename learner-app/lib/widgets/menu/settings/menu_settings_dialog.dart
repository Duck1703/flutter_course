import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/profile/user_profile_data.dart';
import '../../../data/settings/setting_item_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../view_models/settings/settings_view_model.dart';
import 'settings_card.dart';

class MenuSettingsDialog extends StatelessWidget {
  final UserProfileData profile;
  final bool isAuthenticated;
  final VoidCallback? onAccountAction;

  const MenuSettingsDialog({
    super.key,
    this.profile = const UserProfileData(),
    this.isAuthenticated = false,
    this.onAccountAction,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: SettingsCard(
        key: const ValueKey('menu-settings-dialog'),
        items: viewModel.localizedSettingItems(
          soundText: l10n.soundSetting,
          musicText: l10n.musicSetting,
          hapticText: l10n.hapticSetting,
          notificationsText: l10n.notificationsSetting,
          notificationTimeText: l10n.notificationTimeSetting,
          notificationsHint: l10n.settingsNotificationsHint,
        ),
        selectedLanguageCode: viewModel.languageCode,
        appVersion: viewModel.appVersion,
        profile: profile,
        isAuthenticated: isAuthenticated,
        onLanguageSelected: viewModel.selectLanguage,
        onSettingToggle: viewModel.toggleSetting,
        onTimePickerClick: (item) => _showTimePicker(viewModel, item),
        onSaveSettings: viewModel.saveSettings,
        onAccountAction: onAccountAction,
      ),
    );
  }

  void _showTimePicker(
    SettingsViewModel viewModel,
    SettingTimePickerItemData item,
  ) {
    viewModel.showTimePicker(item.hour, item.minute);
  }
}
