import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:ai_millionaire_course/repositories/profile/user_profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test impl THẬT của `UserProfileRepository` — M14. `create()` gọi
/// `SharedPreferences.getInstance()` nên test seed prefs bằng
/// `setMockInitialValues` rồi `await create()` — giống hệt cách
/// `main()` tạo repo.
Future<UserProfileRepositoryImpl> makeRepo(
  Map<String, Object> initialValues,
) async {
  SharedPreferences.setMockInitialValues(initialValues);
  return UserProfileRepositoryImpl.create();
}

void main() {
  group('UserProfileRepositoryImpl (M14)', () {
    test('seeded: stream.value là profile mặc định ngay từ ctor',
        () async {
      final repo = await makeRepo(const {});
      addTearDown(repo.dispose);

      // BehaviorSubject.seeded → `.value` tồn tại ĐỒNG BỘ, không
      // cần await event — đây là lý do senior chọn nó.
      expect(repo.userProfileStream.value, const UserProfileData());
    });

    test('loadUserProfile: prefs trống → emit defaults', () async {
      final repo = await makeRepo(const {});
      addTearDown(repo.dispose);

      final loaded = await repo.loadUserProfile();

      expect(loaded, const UserProfileData());
      expect(repo.userProfileStream.value, const UserProfileData());
    });

    test('loadUserProfile: prefs đã lưu → stream.value khôi phục đúng',
        () async {
      const saved = UserProfileData(username: 'Minh', gamesJoined: 7);
      // Seed disk bằng repo thứ nhất.
      final writer = await makeRepo(const {});
      await writer.saveUserProfile(saved);
      await writer.dispose();

      // Repo mới trên CÙNG prefs — KHÔNG gọi setMockInitialValues lần
      // nữa (nó reset mock store về map trống, xoá mất dữ liệu vừa ghi).
      // `create()` → getInstance() trả về đúng instance đang mock.
      final repo = await UserProfileRepositoryImpl.create();
      addTearDown(repo.dispose);

      // Seeded vẫn là defaults — disk chưa được đọc.
      expect(repo.userProfileStream.value, const UserProfileData());

      await repo.loadUserProfile();
      expect(repo.userProfileStream.value, equals(saved));
    });

    test('saveUserProfile: ghi disk + emit lên stream + cập nhật .value',
        () async {
      final repo = await makeRepo(const {});
      addTearDown(repo.dispose);
      final seen = <UserProfileData>[];
      final sub = repo.userProfileStream.listen(seen.add);
      addTearDown(sub.cancel);

      const profile = UserProfileData(username: 'An', gamesWon: 2);
      await repo.saveUserProfile(profile);
      // `subject.add` đưa event vào queue — listener nhận ở microtask
      // kế; flush queue trước khi assert.
      await pumpEventQueue();

      // Subscriber nhận SEED (defaults) rồi giá trị mới — replay của
      // BehaviorSubject.
      expect(seen, [const UserProfileData(), profile]);
      expect(repo.userProfileStream.value, profile);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_profile'), contains('"gamesWon":2'));
    });

    test('save giá trị TRÙNG hiện tại → không emit thêm', () async {
      final repo = await makeRepo(const {});
      addTearDown(repo.dispose);
      await repo.loadUserProfile();
      final seen = <UserProfileData>[];
      final sub = repo.userProfileStream.listen(seen.add);
      addTearDown(sub.cancel);

      await repo.saveUserProfile(const UserProfileData());
      await pumpEventQueue();

      // Chỉ nhận đúng seed; emit-guard `value != userData` chặn
      // event thừa — senior `_emitUserProfile` làm đúng vậy.
      expect(seen, [const UserProfileData()]);
    });

    test('resetUserProfile = ghi defaults đè key (không xoá key)',
        () async {
      final repo = await makeRepo(const {});
      addTearDown(repo.dispose);
      await repo.saveUserProfile(
        const UserProfileData(username: 'Minh', gamesJoined: 3),
      );

      await repo.resetUserProfile();

      expect(repo.userProfileStream.value, const UserProfileData());
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('user_profile');
      expect(raw, isNotNull); // key TỒN TẠI — reset là ghi đè
      expect(raw, contains('"gamesJoined":0'));
    });

    test('listener subscribe MUỘN vẫn nhận giá trị hiện tại (replay)',
        () async {
      final repo = await makeRepo(const {});
      addTearDown(repo.dispose);
      await repo.saveUserProfile(const UserProfileData(username: 'Late'));

      // Subscribe SAU khi save — broadcast controller của M13 sẽ bỏ
      // lỡ event này; BehaviorSubject replay giá trị mới nhất.
      final seen = <UserProfileData>[];
      final sub = repo.userProfileStream.listen(seen.add);
      addTearDown(sub.cancel);
      await Future<void>.delayed(Duration.zero);

      expect(seen.single.username, 'Late');
    });

    test('dispose → emit sau dispose không ném (isClosed guard)',
        () async {
      final repo = await makeRepo(const {});
      await repo.dispose();

      // `_emitUserProfile` guard `isClosed`: add vào closed subject
      // sẽ ném StateError — load sau dispose vẫn trả về defaults
      // sạch chứng tỏ guard hoạt động (ValueStream không public
      // isClosed — nó là view read-only; cờ sống ở subject bên trong).
      expect(
        await repo.loadUserProfile(),
        const UserProfileData(),
      );
    });
  });
}
