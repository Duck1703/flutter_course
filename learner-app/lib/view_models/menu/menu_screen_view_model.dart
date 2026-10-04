// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../data/auth/auth_session_data.dart';
import '../../data/profile/user_profile_data.dart';
import '../../repositories/auth/auth_repository_contract.dart';
import '../../repositories/profile/user_profile_repository.dart';
import 'menu_dialog_state.dart';
import 'menu_screen_ui_event.dart';

class MenuScreenViewModel extends ChangeNotifier {
  final StreamController<MenuScreenUiEvent> _events;
  final UserProfileRepository _userProfileRepository;
  final AuthRepository _authRepository;
  late final StreamSubscription<UserProfileData> _userProfileSubscription;
  late final StreamSubscription<AuthSessionData> _authStateSubscription;
  UserProfileData _userData;
  AuthSessionData _authState;
  MenuDialogState _dialogState = const MenuDialogNone();
  var _isDisposed = false;

  MenuScreenViewModel({
    required UserProfileRepository userProfileRepository,
    required AuthRepository authRepository,
  }) : _events = StreamController<MenuScreenUiEvent>.broadcast(),
       _userProfileRepository = userProfileRepository,
       _authRepository = authRepository,
       _userData = userProfileRepository.userProfileStream.value,
       _authState = authRepository.authStateStream.value {
    _userProfileSubscription = _userProfileRepository.userProfileStream.listen(
      _handleUserProfile,
    );
    _authStateSubscription = _authRepository.authStateStream.listen(
      _handleAuthState,
    );
  }

  Stream<MenuScreenUiEvent> get events => _events.stream;

  UserProfileData get userData => _userData;

  bool get isAuthenticated => _authState.isAuthenticated;

  MenuDialogState get dialogState => _dialogState;

  Future<void> loadUserProfile() async {
    await _userProfileRepository.loadUserProfile();
    await _authRepository.loadAuthState();
  }

  void _handleUserProfile(UserProfileData userData) {
    if (_isDisposed) {
      return;
    }

    final shouldNotify = _userData != userData;

    _userData = userData;

    if (shouldNotify) {
      notifyListeners();
    }
  }

  void _handleAuthState(AuthSessionData authState) {
    if (_isDisposed) {
      return;
    }

    final shouldNotify = _authState != authState;

    _authState = authState;

    if (shouldNotify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _userProfileSubscription.cancel();
    _authStateSubscription.cancel();
    _events.close();
    super.dispose();
  }

  void requestLeaderboardDialog() {
    _setDialogState(const MenuDialogLeaderboard());
  }

  void requestSettingsDialog() {
    _setDialogState(const MenuDialogSettings());
  }

  void requestAuthAction() {
    _setDialogState(
      _authState is AuthSessionAuthenticated
          ? const MenuDialogSignOut()
          : const MenuDialogAuth(),
    );
  }

  void requestGame() {
    _events.add(const MenuGameRequested());
  }

  void dismissCurrentDialog() {
    _setDialogState(const MenuDialogNone());
  }

  bool _setDialogState(MenuDialogState state) {
    if (_isDisposed) {
      return false;
    }

    if (_dialogState == state) {
      return false;
    }

    _dialogState = state;
    notifyListeners();
    return true;
  }
}
