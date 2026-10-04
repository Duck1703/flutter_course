import 'package:ai_millionaire_course/data/settings/user_settings_data.dart';
import 'package:ai_millionaire_course/repositories/settings/user_settings_repository.dart';
import 'package:rxdart/rxdart.dart';

/// Test double cho `UserSettingsRepository` — cùng pattern
/// `FakeUserProfileRepository`: `implements` contract + subject riêng.
/// Consumer thật của repo này là settings dialog (M16); fake đã sẵn
/// sàng vì contract-first cho phép viết nó mà không cần impl.
class FakeUserSettingsRepository implements UserSettingsRepository {
  final BehaviorSubject<UserSettingsData> _subject;
  var saveCallCount = 0;
  var loadCallCount = 0;

  FakeUserSettingsRepository({
    UserSettingsData initialSettings = const UserSettingsData(),
  }) : _subject = BehaviorSubject<UserSettingsData>.seeded(initialSettings);

  @override
  ValueStream<UserSettingsData> get userSettingsStream => _subject.stream;

  UserSettingsData get value => _subject.value;

  @override
  Future<UserSettingsData> loadUserSettings() async {
    loadCallCount++;
    return _subject.value;
  }

  @override
  Future<void> saveUserSettings(UserSettingsData settings) async {
    saveCallCount++;
    _subject.add(settings);
  }

  @override
  Future<void> dispose() => _subject.close();
}
