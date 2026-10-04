import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../data/profile/user_profile_data.dart';
import '../../../data/settings/setting_item_data.dart';
import '../../../data/settings/supported_language_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/language_chip_row.dart';
import '../../common/qzds_game_button.dart';
import 'setting_switch_row.dart';
import 'setting_time_picker_row.dart';
import 'settings_account_row.dart';
import 'settings_dialog_shell.dart';
import 'settings_section.dart';

class SettingsCard extends StatelessWidget {
  final List<SettingItemData> items;
  final String? selectedLanguageCode;
  final String appVersion;
  final UserProfileData profile;
  final bool isAuthenticated;
  final ValueChanged<SupportedLanguageData> onLanguageSelected;
  final ValueChanged<SettingSwitchItemData> onSettingToggle;
  final ValueChanged<SettingTimePickerItemData> onTimePickerClick;
  final VoidCallback onSaveSettings;
  final VoidCallback? onAccountAction;

  const SettingsCard({
    super.key,
    required this.items,
    required this.selectedLanguageCode,
    required this.appVersion,
    required this.profile,
    required this.isAuthenticated,
    required this.onLanguageSelected,
    required this.onSettingToggle,
    required this.onTimePickerClick,
    required this.onSaveSettings,
    this.onAccountAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDialogShell(
      key: const ValueKey('settings-card'),
      headerText: l10n.settingsTitle.toUpperCase(),
      iconAsset: AppAssets.iconSetting,
      onClose: onSaveSettings,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsSection(
            title: l10n.settingsSectionLanguage,
            children: [
              LanguageChipRow(
                key: const ValueKey('settings-language-row'),
                selectedLanguageCode: selectedLanguageCode,
                onLanguageSelected: onLanguageSelected,
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spacingSm),
          SettingsSection(
            title: l10n.settingsSectionAudio,
            children: _rowsFor(const {
              SettingType.sound,
              SettingType.music,
              SettingType.haptic,
            }),
          ),
          const SizedBox(height: AppTokens.spacingSm),
          SettingsSection(
            title: l10n.settingsSectionNotifications,
            children: _rowsFor(const {SettingType.notifications}),
          ),
          const SizedBox(height: AppTokens.spacingSm),
          SettingsSection(
            title: l10n.settingsSectionAccount,
            children: [
              SettingsAccountRow(
                data: profile,
                isAuthenticated: isAuthenticated,
                onAccountAction: onAccountAction,
              ),
            ],
          ),
          if (appVersion.isNotEmpty) ...[
            const SizedBox(height: AppTokens.spacingSm),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'v$appVersion',
                style: AppTokens.qzdsCaption1.copyWith(
                  color: AppTokens.qzdsBlack600.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppTokens.spacingSm),
          QzdsGameButton(
            key: const ValueKey('settings-save-button'),
            text: l10n.doneButton.toUpperCase(),
            color: AppTokens.purple800,
            icon: Icons.check_circle,
            textGlow: true,
            onTap: onSaveSettings,
          ),
        ],
      ),
    );
  }

  List<Widget> _rowsFor(Set<SettingType> types) {
    return [
      for (final item in items)
        if (types.contains(item.settingType))
          switch (item) {
            SettingSwitchItemData() => SettingSwitchRow(
              item: item,
              onToggle: onSettingToggle,
            ),
            SettingTimePickerItemData() => SettingTimePickerRow(
              item: item,
              onTap: () => onTimePickerClick(item),
            ),
          },
    ];
  }
}
