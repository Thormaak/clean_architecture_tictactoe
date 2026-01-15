import 'package:result_dart/result_dart.dart';

import '../../../../core/application/usecases/use_case.dart';
import '../../domain/entities/audio_settings.dart';
import '../../domain/failures/audio_settings_failures.dart';
import '../../domain/repositories/i_audio_settings_repository.dart';

/// Use case for saving audio settings
class SetAudioSettingsUseCase
    implements UseCase<Unit, SetAudioSettingsFailure, AudioSettings> {
  final IAudioSettingsRepository _repository;

  SetAudioSettingsUseCase(this._repository);

  @override
  AsyncResultDart<Unit, SetAudioSettingsFailure> call(
    AudioSettings params,
  ) async {
    try {
      return await _repository.setAudioSettings(params);
    } catch (_) {
      return Failure(const SetAudioSettingsSaveFailed());
    }
  }
}
