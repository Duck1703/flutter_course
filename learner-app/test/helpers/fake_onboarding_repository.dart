import 'package:ai_millionaire_course/repositories/onboarding/onboarding_repository.dart';
import 'package:rxdart/rxdart.dart';

/// Test double cho `OnboardingRepository` — cùng pattern hai fake
/// repo kia. Consumer thật là onboarding gate (M18).
class FakeOnboardingRepository implements OnboardingRepository {
  final BehaviorSubject<bool> _subject;
  var setCallCount = 0;

  FakeOnboardingRepository({bool initiallyCompleted = false})
    : _subject = BehaviorSubject<bool>.seeded(initiallyCompleted);

  @override
  ValueStream<bool> get onboardingCompletedStream => _subject.stream;

  bool get value => _subject.value;

  @override
  Future<bool> loadOnboardingCompleted() async => _subject.value;

  @override
  Future<void> setOnboardingCompleted() async {
    setCallCount++;
    _subject.add(true);
  }

  @override
  Future<void> dispose() => _subject.close();
}
