/// Cấu hình Supabase đọc từ compile-time — M23, port NGUYÊN VĂN
/// `lib/core/supabase_environment.dart` của senior.
///
/// `String.fromEnvironment('KEY')` đọc giá trị truyền lúc build qua
/// `--dart-define=KEY=...` — KHÔNG phải file .env, không phải runtime
/// config. Kết quả là hằng số biên dịch: không truyền gì thì chuỗi
/// rỗng (`''`), và `isSupabaseConfigured` trả `false` → app tự rơi về
/// impl "disabled" thay vì crash.
///
/// Bốn key đúng senior:
/// - `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`: cấu hình Supabase.
/// - `GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID`: cặp Google — app
///   dùng ở M24 (auth); giữ nguyên để shape cấu hình khớp senior.
///
/// Bảo mật: publishable key là key CÔNG KHAI của Supabase (đối lập
/// service-role) — quyền hạn nằm ở RLS phía server, không nằm trong
/// code client; vẫn không commit giá trị thật vào repo.
class SupabaseEnvironment {
  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static const _googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );

  final String supabaseUrl;
  final String publishableKey;
  final String googleWebClientId;
  final String googleIosClientId;

  const SupabaseEnvironment({
    required this.supabaseUrl,
    required this.publishableKey,
    required this.googleWebClientId,
    required this.googleIosClientId,
  });

  /// Đọc bốn dart-define ở trên — thiếu key nào thì field đó là `''`.
  factory SupabaseEnvironment.fromEnvironment() {
    return const SupabaseEnvironment(
      supabaseUrl: _url,
      publishableKey: _publishableKey,
      googleWebClientId: _googleWebClientId,
      googleIosClientId: _googleIosClientId,
    );
  }

  /// Đủ cấu hình để khởi tạo Supabase: cả url lẫn publishable key
  /// phải non-empty sau trim (khoảng trắng cũng coi như thiếu).
  bool get isSupabaseConfigured {
    return supabaseUrl.trim().isNotEmpty && publishableKey.trim().isNotEmpty;
  }

  /// Đủ cấu hình cho Google sign-in — M24 mới dùng tới.
  bool get isGoogleConfigured => googleWebClientId.trim().isNotEmpty;

  /// Chuỗi lỗi cấu hình đầu tiên gặp — `null` khi mọi thứ đã đủ.
  String? get configurationError {
    if (!isSupabaseConfigured) {
      return 'Supabase is not configured.';
    }

    if (!isGoogleConfigured) {
      return 'Google sign-in is not configured.';
    }

    return null;
  }
}
