import 'package:ai_millionaire_course/core/supabase_environment.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test `SupabaseEnvironment` — M23. `String.fromEnvironment` là
/// compile-time nên test KHÔNG set được dart-define; phần kiểm được là
/// constructor + các predicate trên giá trị truyền tay (đúng test plan:
/// "test the ctor + predicates").
void main() {
  SupabaseEnvironment env({
    String url = '',
    String key = '',
    String webId = '',
    String iosId = '',
  }) {
    return SupabaseEnvironment(
      supabaseUrl: url,
      publishableKey: key,
      googleWebClientId: webId,
      googleIosClientId: iosId,
    );
  }

  test('thiếu url/key → isSupabaseConfigured false + configurationError',
      () {
    expect(env().isSupabaseConfigured, isFalse);
    expect(env().configurationError, 'Supabase is not configured.');
    // Chỉ một trong hai → vẫn chưa đủ.
    expect(env(url: 'https://x.supabase.co').isSupabaseConfigured, isFalse);
    expect(env(key: 'pk').isSupabaseConfigured, isFalse);
    // Khoảng trắng cũng coi như thiếu (trim).
    expect(env(url: '  ', key: '  ').isSupabaseConfigured, isFalse);
  });

  test('đủ url+key → isSupabaseConfigured true', () {
    final e = env(url: 'https://x.supabase.co', key: 'pk');
    expect(e.isSupabaseConfigured, isTrue);
    // Thiếu Google → configurationError báo Google (key M24).
    expect(e.configurationError, 'Google sign-in is not configured.');
  });

  test('đủ cả bốn → configurationError null; isGoogleConfigured đúng',
      () {
    final full = env(
      url: 'https://x.supabase.co',
      key: 'pk',
      webId: 'web-id',
      iosId: 'ios-id',
    );
    expect(full.isSupabaseConfigured, isTrue);
    expect(full.isGoogleConfigured, isTrue);
    expect(full.configurationError, isNull);

    expect(env(webId: 'web-id').isGoogleConfigured, isTrue);
    expect(env(iosId: 'ios-id').isGoogleConfigured, isFalse);
  });
}
