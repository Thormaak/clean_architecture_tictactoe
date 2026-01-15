import 'package:result_dart/result_dart.dart';
import 'package:tictactoe/features/settings/domain/failures/locale_repository_failures.dart';

import '../entities/app_locale.dart';

/// Repository interface for managing app locale preference
abstract class ILocaleRepository {
  /// Get the stored locale or null if none is saved
  AsyncResultDart<AppLocale, GetLocaleFailure> getLocale();

  /// Save a locale preference
  AsyncResultDart<Unit, SetLocaleFailure> setLocale(AppLocale locale);

  /// Clear the saved locale preference
  AsyncResultDart<Unit, SetLocaleFailure> clearLocale();
}
