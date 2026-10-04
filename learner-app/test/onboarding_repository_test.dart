import 'package:ai_millionaire_course/repositories/onboarding/onboarding_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `OnboardingRepositoryImpl` — `ValueStream<bool>` seeded `false`
/// trên key `'onboarding_completed'`. Consumer thật là gate M18;
/// test ở đây chứng minh contract hoạt động đúng ngay từ M14.
Future<OnboardingRepositoryImpl> makeRepo(
  Map<String, Object> initialValues,
) async {
  SharedPreferences.setMockInitialValues(initialValues);
  return OnboardingRepositoryImpl.create();
}

void main() {
  group('OnboardingRepositoryImpl (M14)', () {
    test('seeded: onboardingCompletedStream.value == false', () async {
      final repo = await makeRepo(const {});
      addTearDown(repo.dispose);

      expect(repo.onboardingCompletedStream.value, isFalse);
    });

    test('setOnboardingCompleted: emit true + ghi disk', () async {
      final repo = await makeRepo(const {});
      addTearDown(repo.dispose);
      final seen = <bool>[];
      final sub = repo.onboardingCompletedStream.listen(seen.add);
      addTearDown(sub.cancel);

      await repo.setOnboardingCompleted();
      await pumpEventQueue(); // flush event queue của subject

      expect(seen, [false, true]); // replay seed rồi giá trị mới
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding_completed'), isTrue);
    });

    test('loadOnboardingCompleted khôi phục cờ đã lưu', () async {
      SharedPreferences.setMockInitialValues(
        const {'onboarding_completed': true},
      );
      final repo = await OnboardingRepositoryImpl.create();
      addTearDown(repo.dispose);

      expect(await repo.loadOnboardingCompleted(), isTrue);
      expect(repo.onboardingCompletedStream.value, isTrue);
    });

    test('set hai lần → không emit thêm (guard value !=)', () async {
      final repo = await makeRepo(const {});
      addTearDown(repo.dispose);
      await repo.setOnboardingCompleted();
      final seen = <bool>[];
      final sub = repo.onboardingCompletedStream.listen(seen.add);
      addTearDown(sub.cancel);

      await repo.setOnboardingCompleted();

      expect(seen, [true]); // chỉ replay — không event mới
    });
  });
}
