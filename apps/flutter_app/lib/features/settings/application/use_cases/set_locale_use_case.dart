import 'package:result_dart/result_dart.dart';

import '../../../../core/application/usecases/use_case.dart';
import '../../domain/failures/locale_repository_failures.dart';
import '../../domain/repositories/i_locale_repository.dart';
import '../../domain/entities/app_locale.dart';

/// Use case for saving a locale preference
class SetLocaleUseCase implements UseCase<Unit, SetLocaleFailure, AppLocale> {
  final ILocaleRepository _localeRepository;

  SetLocaleUseCase(this._localeRepository);

  @override
  AsyncResultDart<Unit, SetLocaleFailure> call(AppLocale params) async {
    try {
      return await _localeRepository.setLocale(params);
    } catch (e) {
      return Failure(const SetLocaleFailure.saveFailed());
    }
  }
}
