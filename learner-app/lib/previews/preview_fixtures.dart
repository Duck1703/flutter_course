import 'package:flutter/material.dart';

import '../core/app_design_tokens.dart';
import '../data/game/game_screen_data.dart';
import '../data/settings/setting_item_data.dart';
import '../data/settings/supported_language_data.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common/design_frame.dart';
import '../widgets/common/game_screen_background.dart';
export 'preview_sample_data.dart';

Widget previewApp(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: AppTokens.screenBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.spacingMd),
            child: DesignFrame(child: child),
          ),
        ),
      ),
    ),
  );
}

Widget previewGameApp(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: GameScreenBackground()),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.spacingMd),
                child: DesignFrame(child: child),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget previewLayerApp(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: GameScreenBackground()),
          Positioned.fill(child: child),
        ],
      ),
    ),
  );
}

Widget previewPlainApp(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void previewNoop() {}
void previewAnswerTap(GameAnswerOptionData value) {}
void previewFeatureTap(GameFeatureButtonData value) {}
void previewSettingSwitchTap(SettingSwitchItemData value) {}
void previewSettingTimeTap(SettingTimePickerItemData value) {}
void previewLanguageTap(SupportedLanguageData value) {}
void previewStringValue(String value) {}
void previewIntValue(int value) {}
Future<void> previewRefresh() async {}
