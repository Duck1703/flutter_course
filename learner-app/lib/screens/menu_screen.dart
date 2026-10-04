import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../navigation/app_navigation_controller.dart';
import '../repositories/auth/auth_repository_contract.dart';
import '../repositories/profile/user_profile_repository.dart';
import '../view_models/menu/menu_screen_view_model.dart';
import '../view_models/menu/menu_screen_ui_event.dart';
import '../widgets/menu/menu_screen_view.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MenuScreenViewModel>(
          create: (context) => MenuScreenViewModel(
            userProfileRepository: context.read<UserProfileRepository>(),
            authRepository: context.read<AuthRepository>(),
          )..loadUserProfile(),
        ),
      ],
      child: const _MenuScreenEventBridge(),
    );
  }
}

class _MenuScreenEventBridge extends StatefulWidget {
  const _MenuScreenEventBridge();

  @override
  State<_MenuScreenEventBridge> createState() => _MenuScreenEventBridgeState();
}

class _MenuScreenEventBridgeState extends State<_MenuScreenEventBridge> {
  late AppNavigationController _navigationController;
  MenuScreenViewModel? _viewModel;
  StreamSubscription<MenuScreenUiEvent>? _eventSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigationController = context.read<AppNavigationController>();
    _attachMenuViewModel(context.read<MenuScreenViewModel>());
  }

  void _attachMenuViewModel(MenuScreenViewModel viewModel) {
    if (_viewModel == viewModel) {
      return;
    }

    _eventSubscription?.cancel();
    _viewModel = viewModel;
    _eventSubscription = viewModel.events.listen(_handleUiEvent);
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _handleUiEvent(MenuScreenUiEvent event) {
    switch (event) {
      case MenuGameRequested():
        _navigationController.openGame();
      case MenuSnackBarRequested(:final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MenuScreenViewModel>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: MenuScreenView(viewModel: viewModel),
    );
  }
}
