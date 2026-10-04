/// Hồ sơ người chơi — model bất biến đầu tiên của course (M04).
///
/// M14 (FR-19): field set đạt parity với `UserProfileData` senior
/// (`lib/data/profile/user_profile_data.dart`) — `totalEarnings`
/// (String đã format, vd '1.000.000 VNĐ') và `totalQuestionCount`
/// được thêm; `toMap`/`fromMap` theo đúng shape senior gồm parse
/// phòng thủ đầy đủ (int ≥ 0, string non-empty, `_moneyFromDisplay`,
/// purge profile demo cũ).
///
/// M22 (FR-01/FR-03 converge): field set giờ khớp senior NGUYÊN BỘ —
/// `expForNextLevel`, `gainExp`, `expPerCorrectAnswer`,
/// `applyGameResult`, `expPercent` đã retire: ngưỡng cấp suy ra qua
/// `LevelConfig.getExpRequiredForLevel`, chính sách progression sống
/// trong `GameScreenViewModel._applyLevelProgression`, tỉ lệ thanh EXP
/// trong `MenuLevelProgress.ratio`. Map cũ trên disk vẫn còn key
/// `expForNextLevel` — `fromMap` chỉ đọc key nó cần, key lạ bị bỏ qua.
class UserProfileData {
  static const defaultUsername = '0XFF';
  static const defaultLevel = 1;
  static const defaultTotalMoneyWon = 0;
  static const defaultTotalEarnings = '0 VNĐ';
  static const defaultGamesJoined = 0;
  static const defaultGamesWon = 0;

  // Profile demo cũ của senior (xem `_isLegacyDemoProfile`): nếu
  // storage từng chứa đúng bộ giá trị showcase này thì fromMap trả
  // về defaults thay vì hiển thị số liệu giả.
  static const _legacyDemoUsername = 'TÀU HỦ ĐI CHILL';
  static const _legacyDemoLevel = 12;
  static const _legacyDemoTotalMoneyWon = 1000000;
  static const _legacyDemoTotalEarnings = '1.000.000 VNĐ';
  static const _legacyDemoGamesJoined = 20;
  static const _legacyDemoGamesWon = 12;

  final String username;
  final int level;
  final String totalEarnings;
  final int currentExp;
  final int totalQuestionCount;
  final int totalMoneyWon;
  final int gamesJoined;
  final int gamesWon;
  final String? avatarUrl;

  /// Hồ sơ mặc định — ĐÚNG giá trị senior.
  const UserProfileData({
    this.username = defaultUsername,
    this.level = defaultLevel,
    this.totalEarnings = defaultTotalEarnings,
    this.currentExp = 0,
    this.totalQuestionCount = 0,
    this.totalMoneyWon = defaultTotalMoneyWon,
    this.gamesJoined = defaultGamesJoined,
    this.gamesWon = defaultGamesWon,
    this.avatarUrl,
  });

  /// Tạo bản sao với một vài trường thay đổi — "immutable update".
  ///
  /// Tham số nullable: không truyền (`null`) nghĩa là giữ nguyên giá trị cũ.
  UserProfileData copyWith({
    String? username,
    int? level,
    String? totalEarnings,
    int? currentExp,
    int? totalQuestionCount,
    int? totalMoneyWon,
    int? gamesJoined,
    int? gamesWon,
    String? avatarUrl,
  }) {
    return UserProfileData(
      username: username ?? this.username,
      level: level ?? this.level,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      currentExp: currentExp ?? this.currentExp,
      totalQuestionCount: totalQuestionCount ?? this.totalQuestionCount,
      totalMoneyWon: totalMoneyWon ?? this.totalMoneyWon,
      gamesJoined: gamesJoined ?? this.gamesJoined,
      gamesWon: gamesWon ?? this.gamesWon,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  /// Serialize profile thành `Map` — bước giữa trước khi `jsonEncode`.
  ///
  /// `'avatarUrl': ?avatarUrl` là null-aware element của Dart 3.8:
  /// key bị BỎ hoàn toàn khi `avatarUrl == null` (senior dùng đúng
  /// cú pháp này — map trên disk không mang key null).
  Map<String, Object> toMap() {
    return <String, Object>{
      'username': username,
      'level': level,
      'totalEarnings': totalEarnings,
      'currentExp': currentExp,
      'totalQuestionCount': totalQuestionCount,
      'totalMoneyWon': totalMoneyWon,
      'gamesJoined': gamesJoined,
      'gamesWon': gamesWon,
      'avatarUrl': ?avatarUrl,
    };
  }

  /// Deserialize từ `Map` — parse PHÒNG THỦ đúng senior: storage có
  /// thể chứa dữ liệu cũ, thiếu trường, hoặc sai kiểu. Quy tắc: field
  /// nào không tin được thì rơi về giá trị mặc định — profile hỏng
  /// vẫn cho app chạy, không crash.
  ///
  /// Thứ tự parse `totalEarnings` trước `totalMoneyWon` là của senior:
  /// nếu key tiền int bị hỏng/mất, `_moneyFromDisplay` khôi phục con
  /// số từ chuỗi hiển thị ('1.000.000 VNĐ' → 1000000).
  factory UserProfileData.fromMap(Map<String, Object?> map) {
    const defaults = UserProfileData();
    final totalEarnings = _stringValue(
      map['totalEarnings'],
      defaults.totalEarnings,
    );
    final totalMoneyWon = _intValue(
      map['totalMoneyWon'],
      _moneyFromDisplay(totalEarnings) ?? defaults.totalMoneyWon,
    );

    final profile = UserProfileData(
      username: _stringValue(map['username'], defaults.username),
      level: _intValue(map['level'], defaults.level),
      totalEarnings: totalEarnings,
      currentExp: _intValue(map['currentExp'], defaults.currentExp),
      totalQuestionCount: _intValue(
        map['totalQuestionCount'],
        defaults.totalQuestionCount,
      ),
      totalMoneyWon: totalMoneyWon,
      gamesJoined: _intValue(map['gamesJoined'], defaults.gamesJoined),
      gamesWon: _intValue(map['gamesWon'], defaults.gamesWon),
      avatarUrl: _nullableStringValue(map['avatarUrl']),
    );

    return profile._isLegacyDemoProfile ? defaults : profile;
  }

  /// Đọc `String` phòng thủ: chỉ nhận chuỗi non-empty (sau trim) —
  /// `''` hoặc `'   '` trên disk nghĩa là "không có dữ liệu", rơi về
  /// fallback thay vì hiển thị tên rỗng.
  static String _stringValue(Object? value, String fallback) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return fallback;
  }

  /// Đọc `String?` phòng thủ: vắng/null/rỗng/sai kiểu đều về null —
  /// khác [_stringValue] ở chỗ field nullable KHÔNG có fallback
  /// (null là giá trị hợp lệ của nó).
  static String? _nullableStringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }

  /// Đọc `int` phòng thủ: `is int` bảo đảm đúng kiểu VÀ `>= 0` —
  /// counters không được âm; double `1.5` trong JSON cũng bị bỏ qua.
  static int _intValue(Object? value, int fallback) {
    if (value is int && value >= 0) {
      return value;
    }

    return fallback;
  }

  /// Khôi phục số tiền từ chuỗi hiển thị '1.000.000 VNĐ': lọc mọi
  /// ký tự không phải chữ số rồi parse. Null khi không còn chữ số.
  static int? _moneyFromDisplay(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return null;
    }

    return int.tryParse(digits);
  }

  /// Nhận diện đúng profile demo cũ từng được seed ở bản senior:
  /// mọi field khớp nguyên bộ → coi là dữ liệu showcase, không phải
  /// người chơi thật → fromMap trả defaults.
  bool get _isLegacyDemoProfile {
    return username == _legacyDemoUsername &&
        level == _legacyDemoLevel &&
        totalEarnings == _legacyDemoTotalEarnings &&
        currentExp == 0 &&
        totalQuestionCount == 0 &&
        totalMoneyWon == _legacyDemoTotalMoneyWon &&
        gamesJoined == _legacyDemoGamesJoined &&
        gamesWon == _legacyDemoGamesWon &&
        avatarUrl == null;
  }

  /// Format tiền theo convention VNĐ — đúng helper của senior.
  static String formatVnd(int amount) => '${formatThousands(amount)} VNĐ';

  /// Nhóm chữ số theo 3, phân cách bằng dấu chấm: 1000000 → '1.000.000'.
  static String formatThousands(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      final remaining = digits.length - index;

      buffer.write(digits[index]);

      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  /// Tỉ lệ thắng dạng chuỗi — '—' khi chưa chơi ván nào.
  /// Helper hiển thị phía learner (additive, không phải field).
  String get winRateDisplay {
    if (gamesJoined == 0) return '—';
    return '${(gamesWon * 100 / gamesJoined).round()}%';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserProfileData &&
            username == other.username &&
            level == other.level &&
            totalEarnings == other.totalEarnings &&
            currentExp == other.currentExp &&
            totalQuestionCount == other.totalQuestionCount &&
            totalMoneyWon == other.totalMoneyWon &&
            gamesJoined == other.gamesJoined &&
            gamesWon == other.gamesWon &&
            avatarUrl == other.avatarUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      username,
      level,
      totalEarnings,
      currentExp,
      totalQuestionCount,
      totalMoneyWon,
      gamesJoined,
      gamesWon,
      avatarUrl,
    );
  }
}
