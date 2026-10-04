import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/profile/user_profile_data.dart';

/// Contract của repository profile — M14.
///
/// `abstract interface class` (Dart 3): class chỉ mang chữ ký, không
/// thân, không ctor — nó mô tả "bất kỳ ai implement tôi phải có đúng
/// các member này". VM phụ thuộc vào CONTRACT này, không phải impl:
/// app thật dùng [UserProfileRepositoryImpl] (SharedPreferences),
/// test dùng `FakeUserProfileRepository` — cùng một boundary.
///
/// Đây đúng là ranh giới của project senior này (`repositories/profile/
/// user_profile_repository.dart`), không phải dogma chung: senior cần
/// contract vì nó có nhiều impl (thật + fake + remote sau này) và VM
/// không được biết chi tiết SharedPreferences.
abstract interface class UserProfileRepository {
  /// Stream state profile — kiểu `ValueStream` của rxdart: ngoài các
  /// event như Stream thường, nó luôn biết GIÁ TRỊ HIỆN TẠI qua `.value`.
  /// Listener mới subscribe sẽ nhận ngay giá trị mới nhất (subject đã
  /// được seed) — không có khoảng "chưa có dữ liệu".
  ValueStream<UserProfileData> get userProfileStream;

  /// Đọc profile từ disk vào stream. Trả về profile đã emit.
  Future<UserProfileData> loadUserProfile();

  /// Ghi profile xuống disk rồi emit lên stream — mọi subscriber
  /// (menu VM…) thấy giá trị mới ngay.
  Future<void> saveUserProfile(UserProfileData userData);

  /// Reset = GHI profile mặc định đè key (không xoá key) — semantics
  /// senior `resetUserProfile() => saveUserProfile(const UserProfileData())`.
  Future<void> resetUserProfile();

  /// Đóng subject — lifecycle thủ công vì `BehaviorSubject` không tự
  /// dọn. App-scoped repo sống cùng app; `dispose` chủ yếu cho test
  /// và hot-restart.
  Future<void> dispose();
}

/// Impl SharedPreferences — đúng shape senior: một file chứa cả
/// contract lẫn impl; ctor private `._` + `create()` async static
/// (vì `SharedPreferences.getInstance()` là Future — ctor không thể
/// await, nên construction đi qua factory).
///
/// `ProfileStore` của M10 đã được hấp thụ vào đây: cùng key
/// `'user_profile'`, cùng JSON codec, cùng ba nhánh fallback về
/// defaults — chỉ khác mọi kết quả đều đi QUA subject để emit.
class UserProfileRepositoryImpl implements UserProfileRepository {
  static const _profileKey = 'user_profile';

  final SharedPreferences _preferences;
  final BehaviorSubject<UserProfileData> _userProfileSubject;

  UserProfileRepositoryImpl._(this._preferences)
    : _userProfileSubject = BehaviorSubject<UserProfileData>.seeded(
        const UserProfileData(),
      );

  static Future<UserProfileRepositoryImpl> create() async {
    final preferences = await SharedPreferences.getInstance();
    return UserProfileRepositoryImpl._(preferences);
  }

  @override
  ValueStream<UserProfileData> get userProfileStream =>
      _userProfileSubject.stream;

  @override
  Future<UserProfileData> loadUserProfile() async {
    final encodedProfile = _preferences.getString(_profileKey);

    if (encodedProfile == null) {
      return _emitUserProfile(const UserProfileData());
    }

    try {
      final decodedProfile = jsonDecode(encodedProfile);

      if (decodedProfile is Map) {
        return _emitUserProfile(
          UserProfileData.fromMap(Map<String, Object?>.from(decodedProfile)),
        );
      }
    } on FormatException {
      return _emitUserProfile(const UserProfileData());
    }

    return _emitUserProfile(const UserProfileData());
  }

  @override
  Future<void> saveUserProfile(UserProfileData userData) async {
    final didSave = await _preferences.setString(
      _profileKey,
      jsonEncode(userData.toMap()),
    );

    if (!didSave) {
      throw StateError('Failed to save user profile.');
    }

    _emitUserProfile(userData);
  }

  @override
  Future<void> resetUserProfile() => saveUserProfile(const UserProfileData());

  /// Emit có guard đúng senior: subject đã đóng thì không add (add
  /// vào closed subject ném lỗi), và giá trị TRÙNG hiện tại thì bỏ
  /// qua — subscriber không nhận event thừa cho một "đổi" không đổi.
  UserProfileData _emitUserProfile(UserProfileData userData) {
    if (!_userProfileSubject.isClosed &&
        _userProfileSubject.value != userData) {
      _userProfileSubject.add(userData);
    }

    return userData;
  }

  @override
  Future<void> dispose() => _userProfileSubject.close();
}
