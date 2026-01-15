import 'package:result_dart/result_dart.dart';

import '../../../../core/application/usecases/use_case.dart';
import '../../domain/failures/locale_repository_failures.dart';
import '../../domain/repositories/i_locale_repository.dart';
import '../../domain/entities/app_locale.dart';

/// Use case for getting the saved locale preference
class GetLocaleUseCase
    implements UseCase<AppLocale, GetLocaleFailure, NoParams> {
  final ILocaleRepository _localeRepository;

  GetLocaleUseCase(this._localeRepository);

  @override
  AsyncResultDart<AppLocale, GetLocaleFailure> call(NoParams params) async {
    try {
      return await _localeRepository.getLocale();
    } catch (e) {
      return Failure(const GetLocaleFailure.repositoryError());
    }
  }
}
