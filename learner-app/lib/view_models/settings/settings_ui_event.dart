/// Event một-lần của settings dialog — cùng pattern `MenuScreenUiEvent`
/// (M13/M15): VM bắn ý định, widget bridge nghe và biến thành hành động
/// UI (đóng dialog, hiện SnackBar). Sealed → switch ở bridge kiệt hợp.
///
/// Senior: `lib/view_models/settings/settings_ui_event.dart`.
sealed class SettingsUiEvent {
  const SettingsUiEvent();
}

/// VM xin đóng dialog (nút XONG). Widget bridge nghe → `Navigator.pop`.
final class SettingsDismissRequested extends SettingsUiEvent {
  const SettingsDismissRequested();
}

/// Loại thông báo SnackBar — VM báo LOẠI, widget dịch ra chữ hiển thị
/// (senior làm vậy để M17 map enum → chuỗi l10n; nếu VM mang sẵn chữ
/// thì đổi ngôn ngữ phải chui vào VM).
enum SettingsSnackBarMessage {
  loadFailed,
  updateFailed,
  notificationTimeUpdateFailed,
  // M27: xin quyền thông báo bị từ chối (FR-27 converge).
  notificationPermissionRequired,
}

/// VM xin hiện SnackBar báo lỗi/nhắc.
final class SettingsSnackBarRequested extends SettingsUiEvent {
  final SettingsSnackBarMessage message;

  const SettingsSnackBarRequested(this.message);
}
