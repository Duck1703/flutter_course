import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contract repository onboarding — cờ "đã xem onboarding" (bool).
/// Đúng shape senior `repositories/onboarding/`: `ValueStream<bool>`
/// seeded `false`, một key `'onboarding_completed'`.
///
/// Repo tồn tại từ M14 nhưng CHƯA có consumer — onboarding gate/UI
/// tiếp quản ở M18 (roadmap ghi rõ "onboarding flag repo exists").
abstract interface class OnboardingRepository {
  ValueStream<bool> get onboardingCompletedStream;

  Future<bool> loadOnboardingCompleted();

  Future<void> setOnboardingCompleted();

  Future<void> dispose();
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  static const _completedKey = 'onboarding_completed';

  final SharedPreferences _preferences;
  final BehaviorSubject<bool> _completedSubject;

  OnboardingRepositoryImpl._(this._preferences)
    : _completedSubject = BehaviorSubject<bool>.seeded(false);

  static Future<OnboardingRepositoryImpl> create() async {
    final preferences = await SharedPreferences.getInstance();
    return OnboardingRepositoryImpl._(preferences);
  }

  @override
  ValueStream<bool> get onboardingCompletedStream => _completedSubject.stream;

  @override
  Future<bool> loadOnboardingCompleted() async {
    return _emitCompleted(_preferences.getBool(_completedKey) ?? false);
  }

  @override
  Future<void> setOnboardingCompleted() async {
    final didSave = await _preferences.setBool(_completedKey, true);

    if (!didSave) {
      throw StateError('Failed to save onboarding completion.');
    }

    _emitCompleted(true);
  }

  bool _emitCompleted(bool completed) {
    if (!_completedSubject.isClosed && _completedSubject.value != completed) {
      _completedSubject.add(completed);
    }

    return completed;
  }

  @override
  Future<void> dispose() => _completedSubject.close();
}
