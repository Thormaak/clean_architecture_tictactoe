import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/features/settings/domain/failures/locale_repository_failures.dart';

import '../../domain/repositories/i_locale_repository.dart';
import '../../domain/entities/app_locale.dart';

/// Implementation of LocaleRepository using SharedPreferences
class LocaleRepositoryImpl implements ILocaleRepository {
  static const _localeKey = 'app_locale';

  final SharedPreferences _prefs;

  LocaleRepositoryImpl(this._prefs);

  @override
  AsyncResultDart<AppLocale, GetLocaleFailure> getLocale() async {
    final languageCode = _prefs.getString(_localeKey);
    if (languageCode == null) {
      return Failure(const GetLocaleFailure.notFound());
    }
    return Success(AppLocale(languageCode: languageCode));
  }

  @override
  AsyncResultDart<Unit, SetLocaleFailure> setLocale(AppLocale locale) async {
    try {
      final success = await _prefs.setString(_localeKey, locale.languageCode);
      if (success) {
        return Success(unit);
      } else {
        return Failure(const SetLocaleFailure.saveFailed());
      }
    } catch (e) {
      return Failure(const SetLocaleFailure.unexpected());
    }
  }

  @override
  AsyncResultDart<Unit, SetLocaleFailure> clearLocale() async {
    try {
      final success = await _prefs.remove(_localeKey);
      if (success) {
        return Success(unit);
      } else {
        return Failure(const SetLocaleFailure.saveFailed());
      }
    } catch (e) {
      return Failure(const SetLocaleFailure.unexpected());
    }
  }
}
