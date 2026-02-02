import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_settings_failures.freezed.dart';

@freezed
sealed class GetAudioSettingsFailure
    with _$GetAudioSettingsFailure
    implements Exception {
  const factory GetAudioSettingsFailure.unexpected() =
      GetAudioSettingsUnexpected;
}

@freezed
sealed class SetAudioSettingsFailure
    with _$SetAudioSettingsFailure
    implements Exception {
  const factory SetAudioSettingsFailure.saveFailed() =
      SetAudioSettingsSaveFailed;

  const factory SetAudioSettingsFailure.unexpected() =
      SetAudioSettingsUnexpected;
}
