import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_locale.freezed.dart';

/// Represents a locale for the application
///
/// This is a pure Domain object that wraps the language code
/// and provides conversion methods to/from Flutter's Locale type.
@freezed
sealed class AppLocale with _$AppLocale {
  const AppLocale._();

  const factory AppLocale({required String languageCode}) = _AppLocale;

  /// Supported locales
  static const String english = 'en';
  static const String french = 'fr';

  /// Create AppLocale from language code
  factory AppLocale.fromLanguageCode(String code) {
    return AppLocale(languageCode: code);
  }

  /// English locale
  static const AppLocale en = AppLocale(languageCode: english);

  /// French locale
  static const AppLocale fr = AppLocale(languageCode: french);

  /// Check if this is a valid supported locale
  bool get isSupported => languageCode == english || languageCode == french;

  /// Language code only (domain stays UI-agnostic)
  String get code => languageCode;
}
