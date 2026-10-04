import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../repositories/auth/auth_repository_contract.dart';
import '../../repositories/profile/user_profile_repository.dart';
import '../../repositories/profile/user_profile_sync_repository_contract.dart';
import 'menu_auth_action_coordinator.dart';

/// Sự kiện một-lần của dialog đăng xuất — M24, cùng shape sealed với
/// auth dialog (senior-verbatim): dismiss + snackbar.
sealed class MenuSignOutDialogUiEvent {
  const MenuSignOutDialogUiEvent();
}

final class MenuSignOutDialogDismissRequested extends MenuSignOutDialogUiEvent {
  const MenuSignOutDialogDismissRequested();
}

final class MenuSignOutDialogSnackBarRequested
    extends MenuSignOutDialogUiEvent {
  final String message;

  const MenuSignOutDialogSnackBarRequested(this.message);
}

/// VM của sign-out dialog — M24, port nguyên văn senior
/// `view_models/menu/menu_sign_out_dialog_view_model.dart`.
///
/// `signOut()` → `MenuAuthActionCoordinator.signOut()` — coordinator
/// lo chuỗi repo.signOut + `resetUserProfile()` (FR-11: hành vi nút
/// reset M10 sống tiếp ở đây, không còn trên menu). VM chỉ lo
/// single-flight + dịch kết quả sang dismiss/snackbar events.
class MenuSignOutDialogViewModel extends ChangeNotifier {
  final StreamController<MenuSignOutDialogUiEvent> _events;
  final MenuAuthActionCoordinator _authActions;
  var _isLoading = false;
  var _isDisposed = false;

  MenuSignOutDialogViewModel({
    required AuthRepository authRepository,
    required UserProfileRepository userProfileRepository,
    required UserProfileSyncRepository profileSyncRepository,
  }) : _events = StreamController<MenuSignOutDialogUiEvent>.broadcast(),
       _authActions = MenuAuthActionCoordinator(
         authRepository: authRepository,
         userProfileRepository: userProfileRepository,
         profileSyncRepository: profileSyncRepository,
       );

  Stream<MenuSignOutDialogUiEvent> get events => _events.stream;

  bool get isLoading => _isLoading;

  Future<bool> signOut() async {
    if (_isLoading) return false;

    _setLoading(true);
    debugPrint('[auth] sign-out started');

    try {
      final result = await _authActions.signOut();
      if (_isDisposed) return false;
      debugPrint(
        '[auth] sign-out completed '
        'success=${result.isSuccess} message="${result.message}"',
      );

      if (result.isSuccess) {
        _emitDismissRequested();
      }

      _emitSnackBar(result.message);
      return result.isSuccess;
    } catch (error) {
      debugPrint('[auth] sign-out exception: $error');
      _emitSnackBar('Sign out failed: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool isLoading) {
    if (_isDisposed || _isLoading == isLoading) {
      return;
    }

    _isLoading = isLoading;
    notifyListeners();
  }

  void _emitDismissRequested() {
    if (!_isDisposed && !_events.isClosed) {
      _events.add(const MenuSignOutDialogDismissRequested());
    }
  }

  void _emitSnackBar(String message) {
    if (!_isDisposed && !_events.isClosed) {
      _events.add(MenuSignOutDialogSnackBarRequested(message));
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _events.close();
    super.dispose();
  }
}
