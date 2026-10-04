import 'package:ai_millionaire_course/data/profile/user_profile_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfileData', () {
    test('constructor mặc định khớp defaults của senior', () {
      const profile = UserProfileData();

      // Senior `UserProfileData`: defaultUsername '0XFF',
      // defaultTotalEarnings '0 VNĐ', mọi counter = 0.
      // M22: field set khớp senior nguyên bộ — không còn
      // `expForNextLevel`; ngưỡng cấp suy qua LevelConfig (FR-01).
      expect(profile.username, '0XFF');
      expect(profile.level, 1);
      expect(profile.totalEarnings, '0 VNĐ');
      expect(profile.currentExp, 0);
      expect(profile.totalQuestionCount, 0);
      expect(profile.totalMoneyWon, 0);
      expect(profile.gamesJoined, 0);
      expect(profile.gamesWon, 0);
      expect(profile.avatarUrl, isNull);
    });

    test('copyWith thay đúng trường được chọn, giữ nguyên phần còn lại', () {
      const profile = UserProfileData();
      final updated = profile.copyWith(username: 'Minh', level: 5);

      expect(updated.username, 'Minh');
      expect(updated.level, 5);
      expect(updated.currentExp, profile.currentExp);
      expect(updated.gamesWon, profile.gamesWon);
    });

    test('hai profile cùng giá trị thì bằng nhau và có cùng hashCode', () {
      const a = UserProfileData();
      const b = UserProfileData();

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a == b, isTrue);
      expect(identical(a, b), isTrue); // cùng một const instance được canonicalize
    });

    test('copyWith tạo object mới, không sửa object cũ', () {
      const profile = UserProfileData();
      final updated = profile.copyWith(level: 2);

      expect(identical(profile, updated), isFalse);
      expect(profile.level, 1); // object cũ không đổi
    });

    test('winRateDisplay trả — khi chưa chơi, phần trăm khi đã chơi', () {
      expect(const UserProfileData().winRateDisplay, '—');
      expect(
        const UserProfileData(gamesJoined: 4, gamesWon: 2).winRateDisplay,
        '50%',
      );
    });

    test('formatThousands nhóm chữ số bằng dấu chấm', () {
      expect(UserProfileData.formatThousands(0), '0');
      expect(UserProfileData.formatThousands(999), '999');
      expect(UserProfileData.formatThousands(150000), '150.000');
      expect(UserProfileData.formatThousands(1000000), '1.000.000');
    });

    test('formatVnd ghép format với đơn vị VNĐ (M14: thay getter '
        'totalEarningsDisplay)', () {
      // M14: `totalEarnings` là FIELD String — senior lưu chuỗi đã
      // format, không derive lúc hiển thị. `formatVnd` là helper
      // senior tạo ra chuỗi đó.
      expect(const UserProfileData().totalEarnings, '0 VNĐ');
      expect(UserProfileData.formatVnd(150000), '150.000 VNĐ');
    });
  });

  // ------------------------------------------------------------------
  // M10 — serialization (toMap/fromMap) + chính sách tiến trình
  // ------------------------------------------------------------------

  group('UserProfileData toMap/fromMap (M10)', () {
    test('round-trip: fromMap(toMap(profile)) bằng chính nó', () {
      const profile = UserProfileData(
        username: 'Minh',
        level: 3,
        totalEarnings: '150.000 VNĐ',
        currentExp: 250,
        totalQuestionCount: 11,
        totalMoneyWon: 150000,
        gamesJoined: 4,
        gamesWon: 2,
        avatarUrl: 'https://example.com/a.png',
      );

      expect(UserProfileData.fromMap(profile.toMap()), equals(profile));
    });

    test('toMap BỎ key avatarUrl khi null (null-aware element `?`)', () {
      final map = const UserProfileData().toMap();

      // Senior semantics: key vắng hẳn khỏi JSON — không ghi null.
      expect(map.containsKey('avatarUrl'), isFalse);
      expect(
        const UserProfileData(avatarUrl: 'a.png')
            .toMap()
            .containsKey('avatarUrl'),
        isTrue,
      );
    });

    test('map thiếu hết field → tất cả rơi về mặc định', () {
      final profile = UserProfileData.fromMap(const {});

      expect(profile, equals(const UserProfileData()));
    });

    test('field sai kiểu (chuỗi thay int) → field đó về mặc định', () {
      final profile = UserProfileData.fromMap(const {
        'username': 'Minh',
        'level': 'ba', // sai kiểu
        'gamesJoined': 7,
      });

      expect(profile.username, 'Minh'); // đúng kiểu thì giữ
      expect(profile.level, 1); // sai kiểu → default
      expect(profile.gamesJoined, 7);
    });

    test('số thực trong map không được nhận làm int', () {
      // jsonDecode của "1.5" cho double — _intValue phải loại nó ra.
      final profile = UserProfileData.fromMap(const {
        'level': 2.5,
      });

      expect(profile.level, 1);
    });

    test('avatarUrl vắng hoặc null → null', () {
      expect(UserProfileData.fromMap(const {}).avatarUrl, isNull);
      expect(
        UserProfileData.fromMap(const {'avatarUrl': null}).avatarUrl,
        isNull,
      );
      expect(
        UserProfileData.fromMap(const {'avatarUrl': 'x.png'}).avatarUrl,
        'x.png',
      );
    });

    // ── M14 (FR-19): parse phòng thủ đầy đủ của senior ─────────────

    test('int ÂM → về mặc định (counters không được âm)', () {
      final profile = UserProfileData.fromMap(const {
        'level': -3,
        'gamesWon': -1,
        'totalQuestionCount': -99,
      });

      expect(profile.level, 1);
      expect(profile.gamesWon, 0);
      expect(profile.totalQuestionCount, 0);
    });

    test('string RỖNG/chỉ-space → về mặc định', () {
      final profile = UserProfileData.fromMap(const {
        'username': '   ',
        'totalEarnings': '',
      });

      expect(profile.username, '0XFF');
      expect(profile.totalEarnings, '0 VNĐ');
    });

    test('totalMoneyWon hỏng → khôi phục từ totalEarnings '
        '(_moneyFromDisplay)', () {
      // Senior: `totalEarnings` là chuỗi display có gốc số — nếu key
      // int mất, con số được lục lại từ chuỗi ('1.000.000 VNĐ' → 1M).
      final profile = UserProfileData.fromMap(const {
        'totalEarnings': '1.000.000 VNĐ',
        'totalMoneyWon': 'hỏng',
      });

      expect(profile.totalMoneyWon, 1000000);
      expect(profile.totalEarnings, '1.000.000 VNĐ');
    });

    test('legacy demo profile → bị purge về defaults', () {
      // Bộ giá trị showcase cũ của senior — khớp NGUYÊN BỘ mới purge
      // (một field lệch thì coi là profile thật).
      final purged = UserProfileData.fromMap(const {
        'username': 'TÀU HỦ ĐI CHILL',
        'level': 12,
        'totalEarnings': '1.000.000 VNĐ',
        'currentExp': 0,
        'totalQuestionCount': 0,
        'totalMoneyWon': 1000000,
        'gamesJoined': 20,
        'gamesWon': 12,
      });
      expect(purged, const UserProfileData());

      final kept = UserProfileData.fromMap(const {
        'username': 'TÀU HỦ ĐI CHILL',
        'level': 13, // lệch khỏi bộ demo → giữ nguyên
        'gamesJoined': 20,
        'gamesWon': 12,
      });
      expect(kept.username, 'TÀU HỦ ĐI CHILL');
      expect(kept.level, 13);
    });
  });

}
