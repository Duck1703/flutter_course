import 'package:flutter/material.dart';

import '../screens/game_screen.dart';

class AppNavigationController {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  AppNavigationController();

  Future<void> openGame() async {
    await _push<void>(
      MaterialPageRoute<void>(builder: (context) => const GameScreen()),
    );
  }

  void goBack() {
    _pop();
  }

  Future<T?> _push<T extends Object?>(Route<T> route) {
    return _navigator.push(route);
  }

  void _pop<T extends Object?>([T? result]) {
    final navigator = _navigator;

    if (navigator.canPop()) {
      navigator.pop(result);
    }
  }

  NavigatorState get _navigator {
    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      throw StateError(
        'AppNavigationController.navigatorKey is not attached to a Navigator.',
      );
    }

    return navigator;
  }
}
