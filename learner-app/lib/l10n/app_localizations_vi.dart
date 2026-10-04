// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'AI Millionaire';

  @override
  String get settingsSemanticLabel => 'Cài đặt';

  @override
  String get leaderboardSemanticLabel => 'Bảng xếp hạng';

  @override
  String get startGameButton => 'Bắt đầu chơi';

  @override
  String get accountSemanticLabel => 'Tài khoản';

  @override
  String get menuGuestName => 'Khách';

  @override
  String get menuGuestSyncHint => 'Đăng nhập để đồng bộ';

  @override
  String get menuSyncedStatus => 'Đã đồng bộ';

  @override
  String get syncProgressTitle => 'Đồng bộ tiến trình';

  @override
  String get syncProgressDescription =>
      'Dùng tài khoản trên điện thoại để đồng bộ tiến trình giữa các thiết bị.';

  @override
  String get signInWithGoogleButton => 'Đăng nhập với Google';

  @override
  String get signInWithAppleButton => 'Đăng nhập với Apple';

  @override
  String get signInWithEmailButton => 'Đăng nhập bằng email';

  @override
  String get continueAsGuestButton => 'Tiếp tục với khách';

  @override
  String get emailFieldLabel => 'Email';

  @override
  String get passwordFieldLabel => 'Mật khẩu';

  @override
  String get confirmPasswordFieldLabel => 'Xác nhận mật khẩu';

  @override
  String get backButton => 'Quay lại';

  @override
  String get signInButton => 'Đăng nhập';

  @override
  String get createAccountButton => 'Tạo tài khoản';

  @override
  String get enterEmailPasswordError => 'Nhập email và mật khẩu.';

  @override
  String get enterValidEmailError => 'Nhập địa chỉ email hợp lệ.';

  @override
  String get confirmPasswordError => 'Xác nhận mật khẩu của bạn.';

  @override
  String get passwordMinLengthError => 'Dùng ít nhất 6 ký tự cho mật khẩu.';

  @override
  String get passwordsDoNotMatchError => 'Mật khẩu không khớp.';

  @override
  String get accountTitle => 'Tài khoản';

  @override
  String get signOutPrompt => 'Đăng xuất và đưa thiết bị này về hồ sơ khách?';

  @override
  String get signOutButton => 'Đăng xuất';

  @override
  String profileLevel(int level) {
    return 'Cấp độ $level';
  }

  @override
  String get totalEarningsLabel => 'Tổng thưởng đã kiếm';

  @override
  String get leaderboardTitle => 'Bảng xếp hạng';

  @override
  String get leaderboardEmptyMessage => 'Chưa có dữ liệu bảng xếp hạng';

  @override
  String get leaderboardLoadErrorMessage => 'Không thể tải bảng xếp hạng';

  @override
  String get leaderboardLoadingMessage => 'Đang tải bảng xếp hạng...';

  @override
  String get retryButton => 'Thử lại';

  @override
  String rankSemanticLabel(int rank) {
    return 'Hạng $rank';
  }

  @override
  String get gamesJoinedLabel => 'Đã chơi';

  @override
  String get gamesWonLabel => 'Đã thắng';

  @override
  String get menuWinRateLabel => 'Tỉ lệ thắng';

  @override
  String get nextButton => 'Tiếp tục';

  @override
  String get gameOverTitle => 'Kết thúc';

  @override
  String get moneyLadderTitle => 'Thang tiền thưởng';

  @override
  String get exitGameTitle => 'Thoát trò chơi?';

  @override
  String get exitGameMessage =>
      'Tiến trình của bạn sẽ mất. Bạn chắc chắn muốn thoát?';

  @override
  String get exitGameButton => 'Thoát trò chơi';

  @override
  String get continuePlayingButton => 'Tiếp tục chơi';

  @override
  String get aiExplanationsTitle => 'Giải thích AI';

  @override
  String get understandButton => 'Đã hiểu';

  @override
  String get fiftyFiftySemanticLabel => '50:50';

  @override
  String get askAudienceSemanticLabel => 'Hỏi khán giả';

  @override
  String get askAiSemanticLabel => 'Hỏi AI';

  @override
  String get walkAwaySemanticLabel => 'Dừng cuộc chơi';

  @override
  String get exitGameSemanticLabel => 'Thoát trò chơi';

  @override
  String optionSemanticLabel(String label, String answer) {
    return 'Đáp án $label, $answer';
  }

  @override
  String get selectedStateLabel => 'Đã chọn';

  @override
  String get correctStateLabel => 'Đúng';

  @override
  String get incorrectStateLabel => 'Sai';

  @override
  String prizeAmountSemanticLabel(String amount) {
    return 'Giải thưởng $amount';
  }

  @override
  String timeRemainingSemanticLabel(String time) {
    return 'Thời gian còn lại $time';
  }

  @override
  String get walkAwayTitle => 'Dừng cuộc chơi?';

  @override
  String get walkAwayMessage =>
      'Bạn sẽ mang về số tiền hiện tại và kết thúc trò chơi. Không thể hoàn tác.';

  @override
  String get confirmWalkAwayButton => 'Xác nhận dừng';

  @override
  String get keepPlayingButton => 'Chơi tiếp';

  @override
  String get aiAssistantTitle => 'Trợ lý AI';

  @override
  String get audienceHelpTitle => 'Hỏi khán giả';

  @override
  String get aiThinkingMessage => 'AI đang suy nghĩ...';

  @override
  String get youEarnedLabel => 'Bạn nhận được';

  @override
  String get congratulationsTitle => 'Chúc mừng';

  @override
  String get playAgainButton => 'Chơi lại';

  @override
  String get menuButton => 'Menu';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsSectionLanguage => 'Ngôn ngữ';

  @override
  String get settingsSectionAudio => 'Âm thanh & rung';

  @override
  String get settingsSectionNotifications => 'Thông báo';

  @override
  String get settingsSectionAccount => 'Tài khoản';

  @override
  String get doneButton => 'Xong';

  @override
  String get confirmButton => 'Xác nhận';

  @override
  String get cancelButton => 'Hủy';

  @override
  String get settingsLoadErrorMessage => 'Không thể tải cài đặt';

  @override
  String get settingsUpdateErrorMessage => 'Không thể cập nhật cài đặt';

  @override
  String get settingsNotificationTimeUpdateErrorMessage =>
      'Không thể cập nhật giờ thông báo';

  @override
  String get settingsGuestSyncHint =>
      'Đăng nhập để đồng bộ tiến trình & lên bảng xếp hạng';

  @override
  String get soundSetting => 'Âm thanh';

  @override
  String get musicSetting => 'Nhạc';

  @override
  String get hapticSetting => 'Rung phản hồi';

  @override
  String get notificationsSetting => 'Thông báo';

  @override
  String get notificationTimeSetting => 'Giờ thông báo';

  @override
  String get settingsNotificationsHint => 'Mỗi ngày một lần';

  @override
  String get enableNotificationsButton => 'Bật thông báo';

  @override
  String get getStartedButton => 'Bắt đầu';

  @override
  String get maybeLaterButton => 'Để sau';

  @override
  String get onboardingWelcomeTitle => 'Chào mừng đến AI Quiz!';

  @override
  String get onboardingWelcomeDescription =>
      'Kiểm tra kiến thức với câu hỏi AI, kiếm thưởng và leo bảng xếp hạng. Chọn ngôn ngữ để bắt đầu.';

  @override
  String get onboardingNotificationTitle => 'Nhắc bạn mỗi ngày';

  @override
  String get onboardingNotificationDescription =>
      'Một nhắc nhở mỗi ngày để bạn không bỏ lỡ ván chơi. Không spam, đổi giờ hoặc tắt bất cứ lúc nào.';

  @override
  String get onboardingNotificationTimeLabel => 'Giờ nhắc mỗi ngày';

  @override
  String get onboardingNotificationTimeHint => 'Đổi trong Cài đặt';

  @override
  String get onboardingReadyTitle => 'Bạn đã sẵn sàng!';

  @override
  String get onboardingReadyDescription =>
      'Ván đầu tiên đang chờ bạn. Chúc may mắn!';

  @override
  String get onboardingReadyQuestionsLabel => 'câu hỏi';

  @override
  String get onboardingReadyLifelinesLabel => 'trợ giúp';

  @override
  String get onboardingReadyLadderLabel => 'thang thưởng';

  @override
  String get onboardingSkipIntroButton => 'Bỏ qua giới thiệu';

  @override
  String get shareResultButton => 'Chia sẻ kết quả';

  @override
  String shareResultMessage(String amount) {
    return 'Tôi đã thắng $amount trong AI Millionaire!';
  }

  @override
  String shareVictoryResultMessage(String amount, String message) {
    return 'Tôi đã thắng $amount trong AI Millionaire! $message';
  }

  @override
  String get resultCopiedSnackBar => 'Đã sao chép kết quả';

  @override
  String get settingsNotificationPermissionRequiredMessage =>
      'Cần cấp quyền thông báo';

  @override
  String get closeButton => 'Đóng';

  @override
  String get hourPickerSemanticLabel => 'Chọn giờ';

  @override
  String get languageSetting => 'Ngôn ngữ';

  @override
  String menuExpToNextLevel(String exp, int level) {
    return '$exp EXP để lên Cấp $level';
  }

  @override
  String get menuExperienceLabel => 'Kinh nghiệm';

  @override
  String get menuLeaderboardEntrySubtitle => 'Xem top 10 tuần này';

  @override
  String get menuLevelShort => 'CẤP';

  @override
  String get menuMaxLevelReached => 'Đã đạt cấp tối đa';

  @override
  String get minutePickerSemanticLabel => 'Chọn phút';

  @override
  String get saveButton => 'Lưu';

  @override
  String settingsIconSemanticLabel(String label) {
    return 'Biểu tượng $label';
  }
}
