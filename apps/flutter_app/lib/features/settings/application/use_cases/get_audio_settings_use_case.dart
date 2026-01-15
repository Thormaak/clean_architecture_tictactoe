import 'package:result_dart/result_dart.dart';

import '../../../../core/application/usecases/use_case.dart';
import '../../domain/entities/audio_settings.dart';
import '../../domain/failures/audio_settings_failures.dart';
import '../../domain/repositories/i_audio_settings_repository.dart';

/// Use case for getting the saved audio settings
class GetAudioSettingsUseCase
    implements UseCase<AudioSettings, GetAudioSettingsFailure, NoParams> {
  final IAudioSettingsRepository _repository;

  GetAudioSettingsUseCase(this._repository);

  @override
  AsyncResultDart<AudioSettings, GetAudioSettingsFailure> call(
    NoParams params,
  ) async {
    try {
      return await _repository.getAudioSettings();
    } catch (_) {
      return Failure(const GetAudioSettingsUnexpected());
    }
  }
}
