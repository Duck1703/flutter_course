import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../repositories/auth/auth_repository_contract.dart';
import '../../repositories/profile/user_profile_repository.dart';
import '../../repositories/profile/user_profile_sync_repository_contract.dart';
import 'menu_auth_action_coordinator.dart';

/// Sự kiện một-lần của dialog đăng nhập — M24, sealed union đúng
/// senior. Đây là điểm FR-12 converge: SNACKBAR giờ phát ra từ dialog
/// VM (trước đó emit qua `MenuSnackBarRequested` trên MenuScreenViewModel —
/// emit site đó đã retire; class vẫn tồn tại trong family theo senior).
/// Hai variant: xin đóng dialog / xin hiện snackbar.
sealed class MenuAuthDialogUiEvent {
  const MenuAuthDialogUiEvent();
}

final class MenuAuthDialogDismissRequested extends MenuAuthDialogUiEvent {
  const MenuAuthDialogDismissRequested();
}

final class MenuAuthDialogSnackBarRequested extends MenuAuthDialogUiEvent {
  final String message;

  const MenuAuthDialogSnackBarRequested(this.message);
}

/// VM của auth dialog — M24, port nguyên văn senior
/// `view_models/menu/menu_auth_dialog_view_model.dart`.
///
/// Dialog-scoped VM (sống/chết cùng dialog, Provider tự dispose).
/// Cờ `_isLoading` là single-flight: một action đang chạy thì mọi
/// method sign-* trả `false` ngay — chặn double-tap trong lúc chờ
/// network. `_isDisposed` guard: repo trả về SAU khi dialog đã đóng
/// thì không emit event/notify vào VM đã chết.
///
/// Kết quả → event: success → `DismissRequested` + `SnackBarRequested`
/// (đóng rồi báo message); failure → chỉ `SnackBarRequested`, dialog
/// ở lại cho người chơi thử lại.
class MenuAuthDialogViewModel extends ChangeNotifier {
  final StreamController<MenuAuthDialogUiEvent> _events;
  final MenuAuthActionCoordinator _authActions;
  var _isLoading = false;
  var _isDisposed = false;

  MenuAuthDialogViewModel({
    required AuthRepository authRepository,
    required UserProfileRepository userProfileRepository,
    required UserProfileSyncRepository profileSyncRepository,
  }) : _events = StreamController<MenuAuthDialogUiEvent>.broadcast(),
       _authActions = MenuAuthActionCoordinator(
         authRepository: authRepository,
         userProfileRepository: userProfileRepository,
         profileSyncRepository: profileSyncRepository,
       );

  Stream<MenuAuthDialogUiEvent> get events => _events.stream;

  bool get isLoading => _isLoading;

  Future<bool> signInWithGoogle() {
    return _runAuthAction(
      label: 'google sign-in',
      failurePrefix: 'Sign in failed',
      action: _authActions.signInWithGoogle,
    );
  }

  Future<bool> signInWithApple() {
    return _runAuthAction(
      label: 'apple sign-in',
      failurePrefix: 'Sign in failed',
      action: _authActions.signInWithApple,
    );
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _runAuthAction(
      label: 'email sign-in',
      failurePrefix: 'Sign in failed',
      action: () =>
          _authActions.signInWithEmail(email: email, password: password),
    );
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _runAuthAction(
      label: 'email sign-up',
      failurePrefix: 'Sign up failed',
      action: () =>
          _authActions.signUpWithEmail(email: email, password: password),
    );
  }

  void continueAsGuest() {
    _emitDismissRequested();
  }

  Future<bool> _runAuthAction({
    required String label,
    required String failurePrefix,
    required Future<AuthActionResult> Function() action,
  }) async {
    if (_isLoading) return false;

    _setLoading(true);
    debugPrint('[auth] $label started');

    try {
      final result = await action();
      if (_isDisposed) return false;
      debugPrint(
        '[auth] $label completed '
        'success=${result.isSuccess} message="${result.message}"',
      );

      if (result.isSuccess) {
        _emitDismissRequested();
      }

      _emitSnackBar(result.message);
      return result.isSuccess;
    } catch (error) {
      debugPrint('[auth] $label exception: $error');
      _emitSnackBar('$failurePrefix: $error');
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
      _events.add(const MenuAuthDialogDismissRequested());
    }
  }

  void _emitSnackBar(String message) {
    if (!_isDisposed && !_events.isClosed) {
      _events.add(MenuAuthDialogSnackBarRequested(message));
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _events.close();
    super.dispose();
  }
}
