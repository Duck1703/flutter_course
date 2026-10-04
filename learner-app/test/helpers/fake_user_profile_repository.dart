import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:rxdart/rxdart.dart';

/// Test double cho `UserProfileRepository` — M14.
///
/// Đây là thu hoạch trực tiếp của contract-first: vì VM phụ thuộc
/// vào `abstract interface class`, test `implements` contract bằng
/// `BehaviorSubject` của riêng mình — không cần SharedPreferences,
/// không cần mock framework. Đúng pattern senior
/// (`test/widgets/game_screen_test_helpers.dart` →
/// `FakeGameProfileRepository implements UserProfileRepository`).
///
/// `saveUserProfile` không ghi disk — chỉ emit lên subject (đủ cho
/// VM-level test). `saveCallCount`/`loadCallCount` cho phép assert
/// hành vi "VM gọi repo" mà không cần biết cài đặt bên trong.
class FakeUserProfileRepository implements UserProfileRepository {
  final BehaviorSubject<UserProfileData> _subject;
  var saveCallCount = 0;
  var loadCallCount = 0;

  FakeUserProfileRepository({
    UserProfileData initialProfile = const UserProfileData(),
  }) : _subject = BehaviorSubject<UserProfileData>.seeded(initialProfile);

  @override
  ValueStream<UserProfileData> get userProfileStream => _subject.stream;

  /// Giá trị hiện tại của stream — đọc trực tiếp trong assert.
  UserProfileData get value => _subject.value;

  @override
  Future<UserProfileData> loadUserProfile() async {
    loadCallCount++;
    return _subject.value;
  }

  @override
  Future<void> saveUserProfile(UserProfileData userData) async {
    saveCallCount++;
    _subject.add(userData);
  }

  @override
  Future<void> resetUserProfile() => saveUserProfile(const UserProfileData());

  @override
  Future<void> dispose() => _subject.close();
}
