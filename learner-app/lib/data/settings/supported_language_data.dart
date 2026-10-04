/// Ngôn ngữ app hỗ trợ — M16 đến cùng hàng chọn ngôn ngữ trong
/// settings dialog (chip ghi `languageCode` thật, đúng senior).
///
/// Đúng shape senior `lib/data/settings/supported_language_data.dart`:
/// cùng 2 giá trị, cùng `values`, `isSupportedCode`, `fromCode`.
/// M17 sẽ dùng `code` để lái `MaterialApp.locale` — đó là khi chữ
/// hiển thị đổi thật; M16 chỉ lưu lựa chọn.
class SupportedLanguageData {
  static const english = SupportedLanguageData(
    code: 'en',
    nativeName: 'English',
  );
  static const vietnamese = SupportedLanguageData(
    code: 'vi',
    nativeName: 'Tiếng Việt',
  );
  static const values = [english, vietnamese];

  final String code;
  final String nativeName;

  const SupportedLanguageData({required this.code, required this.nativeName});

  static bool isSupportedCode(String? code) {
    return values.any((language) => language.code == code);
  }

  static SupportedLanguageData? fromCode(String? code) {
    for (final language in values) {
      if (language.code == code) {
        return language;
      }
    }

    return null;
  }
}
