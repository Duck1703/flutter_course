import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_environment.dart';

/// Khởi tạo Supabase client CÓ ĐIỀU KIỆN — M23, port nguyên văn
/// `lib/services/supabase_client_service.dart` của senior.
///
/// "Sentinel" của senior là `SupabaseClient?`: thiếu cấu hình → trả
/// `null` (không throw, không khởi tạo) và `main()` đổi sang impl
/// `Disabled…` theo đúng một chỗ `supabaseClient == null ? … : …`.
/// Cấu hình đủ → `Supabase.initialize` (SDK mở kênh REST/realtime)
/// rồi trả `supabase.client`.
class SupabaseClientService {
  const SupabaseClientService._();

  static Future<SupabaseClient?> initialize(
    SupabaseEnvironment environment,
  ) async {
    if (!environment.isSupabaseConfigured) {
      return null;
    }

    final supabase = await Supabase.initialize(
      url: environment.supabaseUrl,
      publishableKey: environment.publishableKey,
    );

    return supabase.client;
  }
}
