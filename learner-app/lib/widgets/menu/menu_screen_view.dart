import 'package:flutter/material.dart';

import '../../view_models/menu/menu_screen_view_model.dart';
import '../common/design_frame.dart';
import '../common/game_screen_background.dart';
import '../onboarding/onboarding_overlay_scope.dart';
import 'gradient_cta_button.dart';
import 'menu_dialog_layer.dart';
import 'menu_screen_content.dart';
import 'profile/menu_profile_header.dart';
import 'screen_bottom_inset.dart';
import 'screen_top_inset.dart';

class MenuScreenView extends StatefulWidget {
  final MenuScreenViewModel viewModel;

  const MenuScreenView({super.key, required this.viewModel});

  @override
  State<MenuScreenView> createState() => _MenuScreenViewState();
}

class _MenuScreenViewState extends State<MenuScreenView> {
  var _dialogDismissLocked = false;

  MenuScreenViewModel get viewModel => widget.viewModel;

  void _setDialogDismissLocked(bool locked) {
    if (!mounted || _dialogDismissLocked == locked) {
      return;
    }

    setState(() {
      _dialogDismissLocked = locked;
    });
  }

  void _requestDialogDismiss() {
    if (_dialogDismissLocked) {
      return;
    }

    viewModel.dismissCurrentDialog();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !viewModel.dialogState.isVisible,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop &&
            viewModel.dialogState.isVisible &&
            !_dialogDismissLocked) {
          viewModel.dismissCurrentDialog();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const Positioned.fill(child: GameScreenBackground()),
            Column(
              children: [
                const ScreenTopInset(),
                DesignFrame(
                  child: MenuProfileHeader(
                    data: viewModel.userData,
                    isAuthenticated: viewModel.isAuthenticated,
                    onAccountTap: viewModel.requestAuthAction,
                    onSettingsTap: viewModel.requestSettingsDialog,
                  ),
                ),
                Expanded(
                  child: MenuScreenContent(
                    userData: viewModel.userData,
                    onLeaderboardTap: viewModel.requestLeaderboardDialog,
                  ),
                ),
                DesignFrame(
                  child: GradientCtaButton(onTap: viewModel.requestGame),
                ),
                const ScreenBottomInset(),
              ],
            ),
            Positioned.fill(
              child: MenuDialogLayer(
                dialogState: viewModel.dialogState,
                onDismiss: _requestDialogDismiss,
                onDismissLockChanged: _setDialogDismissLocked,
                profile: viewModel.userData,
                isAuthenticated: viewModel.isAuthenticated,
                onAccountAction: viewModel.requestAuthAction,
              ),
            ),
            const Positioned.fill(child: OnboardingOverlayScope()),
          ],
        ),
      ),
    );
  }
}
