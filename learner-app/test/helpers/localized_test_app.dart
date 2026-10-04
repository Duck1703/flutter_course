import 'package:ai_millionaire_course/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// M17 — host MaterialApp cho widget test: gắn delegates +
/// supportedLocales + ghim `locale: vi` để assertion tiếng Việt hiện
/// hữu giữ nguyên ý nghĩa. Senior test tương đương assert English
/// (device locale en) — learner test chọn vi để không viết lại.
///
/// M19: `navigatorKey` optional để test gắn key của
/// `AppNavigationController` — điều hướng context-free hoạt động được
/// trong môi trường test giống `main.dart` thật.
MaterialApp localizedTestApp({
  required Widget home,
  Locale locale = const Locale('vi'),
  Widget? child, // alias khi cần bọc như MultiProvider phía trên
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return MaterialApp(
    locale: locale,
    navigatorKey: navigatorKey,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child ?? home,
  );
}
