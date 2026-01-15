import 'dart:ui';

import 'package:tictactoe/features/settings/domain/entities/app_locale.dart';

/// Maps Flutter Locale to domain AppLocale and back.
AppLocale appLocaleFromFlutter(Locale locale) {
  return AppLocale.fromLanguageCode(locale.languageCode);
}

Locale flutterLocaleFromApp(AppLocale locale) {
  return Locale(locale.languageCode);
}
